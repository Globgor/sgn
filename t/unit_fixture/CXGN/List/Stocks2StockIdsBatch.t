package main;
use strict;
use warnings;
use Test::More;
use lib 't/lib';
use SGN::Test::Fixture;
use CXGN::List::Transform;

# Run only on an isolated fixture database with no concurrent writers.
sub sequence_values {
    my ($dbh) = @_;
    my $names = $dbh->selectcol_arrayref(
        "SELECT format('%I.%I', schemaname, sequencename) FROM pg_sequences");
    my %values;
    for my $name (@$names) {
        my ($last, $called) = $dbh->selectrow_array("SELECT last_value, is_called FROM $name");
        $values{$name} = [$last, $called ? 1 : 0];
    }
    return \%values;
}
sub restore_sequences {
    my ($dbh, $values) = @_;
    my $now = sequence_values($dbh);
    for my $name (sort keys %$values) {
        my ($last, $called) = @{$values->{$name}};
        my ($now_last, $now_called) = @{$now->{$name}};
        next if $now_last == $last && $now_called == $called;
        $dbh->do('SELECT setval(?::regclass, ?, ?)', undef, $name, $last, $called);
    }
    return;
}
sub measured {
    my ($dbh, $pattern, $code) = @_;
    my ($prepares, $executes) = (0, 0);
    my $old = $dbh->{Callbacks};
    $dbh->{CachedKids} = {};
    $dbh->{Callbacks} = {
        prepare => sub { $prepares++ if $_[1] =~ $pattern; return; },
        ChildCallbacks => {
            execute => sub { $executes++ if $_[0]->{Statement} =~ $pattern; return; }
        }
    };
    my $result;
    my $ok = eval { $result = $code->(); 1 };
    my $error = $@;
    $dbh->{Callbacks} = $old;
    $dbh->{CachedKids} = {};
    die $error unless $ok;
    return ($result, $executes, $prepares);
}

my $f = SGN::Test::Fixture->new;
my $schema = $f->bcs_schema;
my $dbh = $schema->storage->dbh;
my $tf = CXGN::List::Transform->new;
my $types = $dbh->selectcol_arrayref('SELECT DISTINCT type_id FROM stock LIMIT 2');
die "Fixture needs two stock types" unless @$types == 2;
my ($type, $other_type) = @$types;
my $sequences = sequence_values($dbh);
$schema->txn_begin;
my $ok = eval {
    my @names = map { sprintf("stock_ids_queries_%d_%d", $$, $_) } 1..1001;
    my @ids;
    my $insert = $dbh->prepare('INSERT INTO stock (uniquename, type_id) VALUES (?, ?) RETURNING stock_id');
    for my $name (@names) {
        $insert->execute($name, $type);
        push @ids, $insert->fetchrow_array;
    }
    my $pattern = qr/\bFROM\s+(?:"?public"?\.)?"?stock"?\s/i;
    my $run = sub { $tf->transform($schema, 'stocks_2_stock_ids', $_[0]) };
    my ($one, $one_q, $one_p) = measured($dbh, $pattern, sub { $run->([$names[0]]) });
    is_deeply($one, { transform => [$ids[0]], missing => [] }, 'single stock');
    cmp_ok($one_q, '>', 0, 'counter sees stock executes');
    is($one_q, 1, 'one stock uses one query');
    cmp_ok($one_p, '>', 0, 'counter sees stock prepares');
    my @five = @names[0..4];
    my @fifty = @names[0..49];
    my ($five, $five_q) = measured($dbh, $pattern, sub { $run->(\@five) });
    my ($fifty, $fifty_q) = measured($dbh, $pattern, sub { $run->(\@fifty) });
    is_deeply($five->{transform}, [@ids[0..4]], 'five stocks retain order');
    is_deeply($fifty->{transform}, [@ids[0..49]], 'fifty stocks retain order');
    is($fifty_q, $five_q, 'stock query count does not grow within a batch');
    my ($many, $many_q) = measured($dbh, $pattern, sub { $run->(\@names) });
    is_deeply($many, { transform => \@ids, missing => [] }, 'input order across batches');
    is($many_q, 2, '1001 distinct stocks use two bounded queries');
    my $missing = "stock_ids_missing_$$";
    my ($mixed, $mixed_q) = measured($dbh, $pattern,
        sub { $run->([$names[1], $missing, $names[0], $names[1], $missing, undef]) });
    is_deeply($mixed, { transform => [$ids[1], $ids[0], $ids[1]],
        missing => [$missing, $missing, undef] }, 'duplicates and missing order retained');
    is($mixed_q, 1, 'repeated names are queried once');
    for my $empty ([], undef, {}) {
        my ($result, $q) = measured($dbh, $pattern, sub { $run->($empty) });
        is_deeply($result, { transform => [], missing => [] }, 'empty or non-array input');
        is($q, 0, 'empty input performs no stock query');
    }
    my $prefix = sprintf('stock_ids_edge_%d', $$);
    my @edge_names = ("${prefix}_Alpha", "${prefix}_alpha", "${prefix}_Alpha ",
        '', '0', "${prefix}_O'Brien", "${prefix}_" . chr(0x00e9));
    my $existing = $dbh->selectcol_arrayref(
        'SELECT uniquename FROM stock WHERE uniquename IN (?, ?)', undef, '', '0');
    die 'Fixture already contains an empty or zero stock name' if @$existing;
    # The old equality lookup put absent empty and zero names in missing.
    is_deeply($run->(['', '0']), { transform => [], missing => ['', '0'] },
        'absent empty and zero names are missing');
    my @edge_ids;
    for my $name (@edge_names) {
        $insert->execute($name, $type);
        push @edge_ids, $insert->fetchrow_array;
    }
    # The old equality lookup distinguished names by case.
    is_deeply($run->([@edge_names[0, 1]]),
        { transform => [@edge_ids[0, 1]], missing => [] }, 'case remains significant');
    # The old equality lookup retained a trailing space.
    is_deeply($run->([@edge_names[2, 0]]),
        { transform => [@edge_ids[2, 0]], missing => [] }, 'trailing space remains significant');
    # The old equality lookup resolved existing empty and zero names.
    is_deeply($run->([@edge_names[3, 4]]),
        { transform => [@edge_ids[3, 4]], missing => [] }, 'empty and zero names resolve');
    # The old equality lookup resolved a name containing a quote.
    is_deeply($run->([$edge_names[5]]),
        { transform => [$edge_ids[5]], missing => [] }, 'quoted name resolves');
    # The old equality lookup resolved a non-ASCII name.
    is_deeply($run->([$edge_names[6]]),
        { transform => [$edge_ids[6]], missing => [] }, 'non-ASCII name resolves');
    $insert->execute($names[0], $other_type);
    $insert->fetchrow_array;
    my $ambiguous = eval { $run->([$names[0]]); 1 };
    my $ambiguity_error = $@;
    ok(!$ambiguous, 'ambiguous stock names still fail');
    like($ambiguity_error, qr/^Found more than one id \d+ for stock \Q$names[0]\E\n$/, 'legacy ambiguity diagnostic');
    # The old per-name lookup died on the first occurrence of a repeated ambiguous name.
    my $repeated = eval { $run->([$names[0], $names[0]]); 1 };
    like($@, qr/^Found more than one id \d+ for stock \Q$names[0]\E\n$/,
        'repeated ambiguous name reports the legacy error');
    ok(!$repeated, 'repeated ambiguous name fails');
    # The old per-name lookup died after processing preceding valid names.
    my $after_valid = eval { $run->([$names[1], $names[2], $names[0]]); 1 };
    like($@, qr/^Found more than one id \d+ for stock \Q$names[0]\E\n$/,
        'ambiguity after valid names reports the legacy error');
    ok(!$after_valid, 'ambiguity after valid names fails');
    1;
};
my $error = $@;
$schema->txn_rollback;
restore_sequences($dbh, $sequences);
die $error unless $ok;
is_deeply(sequence_values($dbh), $sequences, 'sequences restored');
done_testing();
