use strict;
use warnings;
use lib 't/lib';
use Test::More;
use SGN::Test::Fixture;
use CXGN::Cvterm;
use CXGN::List::Transform::Plugin::TraitIds2Synonyms;

sub measured {
    my ($dbh, $run) = @_;
    my %count = (prepare => 0, execute => 0);
    my $saved = $dbh->{Callbacks};
    $dbh->{CachedKids} = {};
    $dbh->{Callbacks} = {
        prepare => sub { $count{prepare}++; return; },
        prepare_cached => sub { $count{prepare}++; return; },
        ChildCallbacks => { execute => sub { $count{execute}++; return; } },
    };
    my $result;
    my $ok = eval { $result = $run->(); 1 };
    my $error = $@;
    $dbh->{Callbacks} = $saved;
    $dbh->{CachedKids} = {};
    die $error unless $ok;
    return ($result, \%count);
}

sub legacy_transform {
    my ($schema, $ids) = @_;
    my (@transform, @missing);
    for my $id (@$ids) {
        my $term = CXGN::Cvterm->new(schema => $schema, cvterm_id => $id);
        my $synonym = $term->get_single_synonym();
        if ($synonym) { push @transform, $synonym; }
        else { push @missing, $id; }
    }
    return { transform => \@transform, missing => \@missing };
}

my $fixture = SGN::Test::Fixture->new();
my $schema = $fixture->bcs_schema();
my $dbh = $schema->storage->dbh();
my $plugin = CXGN::List::Transform::Plugin::TraitIds2Synonyms->new();
my $with_synonyms = $dbh->selectcol_arrayref(
    'SELECT DISTINCT cvterm_id FROM cvtermsynonym ORDER BY cvterm_id');
my $without_synonyms = $dbh->selectcol_arrayref(
    'SELECT cvterm_id FROM cvterm WHERE NOT EXISTS '
    . '(SELECT 1 FROM cvtermsynonym WHERE cvtermsynonym.cvterm_id = cvterm.cvterm_id) '
    . 'ORDER BY cvterm_id LIMIT 5');
ok(@$with_synonyms, 'fixture has terms with synonyms');
ok(@$without_synonyms, 'fixture has terms without synonyms');
my ($missing_id) = $dbh->selectrow_array('SELECT COALESCE(MAX(cvterm_id), 0) + 1 FROM cvterm');
my @ids = (@$with_synonyms, @$without_synonyms, $missing_id);
push @ids, $with_synonyms->[0], $with_synonyms->[0] if @$with_synonyms;
my $eligible = $dbh->selectall_arrayref(
    "SELECT cvterm_id, synonym FROM cvtermsynonym "
    . "WHERE synonym NOT LIKE '% %' AND synonym NOT LIKE '%\\_%'");
my %eligible;
push @{ $eligible{$_->[0]} }, $_->[1] for @$eligible;

for my $candidate (@ids) {
    my $result = $plugin->transform($schema, [$candidate]);
    my $choices = $eligible{$candidate} || [];
    if (@$choices <= 1) {
        is_deeply($result, legacy_transform($schema, [$candidate]),
            "single or no eligible synonym matches Cvterm for $candidate");
    }
    else {
        my %allowed = map { $_ => 1 } @$choices;
        my $valid = @{ $result->{transform} } == 1
            && !@{ $result->{missing} }
            && $allowed{ $result->{transform}[0] };
        $valid ||= @{ $result->{missing} } == 1
            && !@{ $result->{transform} }
            && $result->{missing}[0] == $candidate
            && ($allowed{''} || $allowed{'0'});
        ok($valid, "unordered synonym is eligible for $candidate");
    }
}
is_deeply($plugin->transform($schema, []), legacy_transform($schema, []),
    'empty input matches Cvterm reference');

# The old CXGN::Cvterm cvterm_id attribute also has the Moose Int type.
for my $invalid ('not-an-integer', undef) {
    my $ok = eval { $plugin->transform($schema, [$invalid]); 1 };
    ok(!$ok, defined $invalid ? 'non-integer ID is rejected' : 'undef ID is rejected');
}
my ($id) = grep { @{ $eligible{$_} || [] } == 1 && $eligible{$_}[0] } @$with_synonyms;
ok(defined $id, 'fixture has a term with one eligible synonym');
BAIL_OUT('fixture lacks a single eligible synonym') unless defined $id;
my $canonical = $plugin->transform($schema, [$id]);
is_deeply($plugin->transform($schema, ["0$id"]), $canonical,
    'leading-zero ID returns the same synonym');

my ($excluded_id) = $dbh->selectrow_array(
    "SELECT cvterm_id FROM cvtermsynonym GROUP BY cvterm_id "
    . "HAVING COUNT(*) FILTER (WHERE synonym NOT LIKE '% %' "
    . "AND synonym NOT LIKE '%\\_%') = 0 ORDER BY cvterm_id LIMIT 1");
ok(defined $excluded_id, 'fixture has a term with only excluded synonyms');
BAIL_OUT('fixture lacks an excluded-only term') unless defined $excluded_id;
is_deeply($plugin->transform($schema, [$excluded_id]),
    { transform => [], missing => [$excluded_id] }, 'excluded-only term is missing');

is_deeply($plugin->transform($schema, [$id, $excluded_id, $id, $missing_id]),
    { transform => [$canonical->{transform}[0], $canonical->{transform}[0]],
      missing => [$excluded_id, $missing_id] },
    'mixed input preserves order and duplicates');

my (undef, $one) = measured($dbh, sub { $plugin->transform($schema, [$id]) });
my @twenty = ($id) x 20;
my (undef, $many) = measured($dbh, sub { $plugin->transform($schema, \@twenty) });
cmp_ok($one->{execute}, '>', 0, 'counter observes executed statements');
cmp_ok($one->{prepare}, '>', 0, 'counter observes prepared statements');
is($many->{execute}, $one->{execute}, 'twenty IDs execute the same number of statements as one');
is($many->{prepare}, $one->{prepare}, 'twenty IDs prepare the same number of statements as one');
BAIL_OUT('fixture needs at least twenty distinct terms') if @$with_synonyms < 20;
my @distinct = @$with_synonyms[0 .. 19];
my (undef, $distinct_count) = measured($dbh, sub { $plugin->transform($schema, \@distinct) });
is($distinct_count->{execute}, 1, 'distinct IDs execute one statement');
my @large = ($id) x 70_000;
my ($large_result, $large_count) = measured($dbh, sub { $plugin->transform($schema, \@large) });
is(scalar @{ $large_result->{transform} }, 70_000, 'large list retains every synonym');
is_deeply($large_result->{missing}, [], 'large list has no missing IDs');
ok(!(grep { $_ ne $canonical->{transform}[0] } @{ $large_result->{transform} }),
    'large list retains the expected synonym');
is($large_count->{execute}, $one->{execute}, 'large list executes the same number of statements as one');
is($large_count->{prepare}, $one->{prepare}, 'large list prepares the same number of statements as one');
done_testing();
