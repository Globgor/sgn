# Compare conditional deduplication with the original grouped stock search.
package main;

use strict;
use warnings;
use lib 't/lib';

use Test::More;
use SGN::Test::Fixture;
use SGN::Model::Cvterm;
use CXGN::Stock::Search;

{
    package StockSearchSQLCapture;
    use parent 'DBIx::Class::Storage::Statistics';

    sub query_start {
        my ($self, $sql) = @_;
        push @{$self->{statements}}, $sql;
    }

    sub query_end { return; }
}

my $fixture = SGN::Test::Fixture->new();
my $schema = $fixture->bcs_schema();
my $storage = $schema->storage();
my $dbh = $storage->dbh();
my $accession_type = SGN::Model::Cvterm->get_cvterm_row(
    $schema, 'accession', 'stock_type')->cvterm_id();
my $synonym_type = SGN::Model::Cvterm->get_cvterm_row(
    $schema, 'stock_synonym', 'stock_property')->cvterm_id();
my $date_type = SGN::Model::Cvterm->get_cvterm_row(
    $schema, 'acquisition date', 'stock_property')->cvterm_id();

sub run_search {
    my ($parameters, $old_behavior) = @_;
    my $search = CXGN::Stock::Search->new({
        bcs_schema => $schema,
        people_schema => $fixture->people_schema(),
        phenome_schema => $fixture->phenome_schema(),
        match_name => '',
        %$parameters,
    });
    my $capture = StockSearchSQLCapture->new();
    $capture->{statements} = [];
    my $old_debug = $storage->debug();
    my $old_debugobj = $storage->debugobj();
    $storage->debugobj($capture);
    $storage->debug(1);
    my @answer;
    my $original_search = \&DBIx::Class::ResultSet::search;
    my $ok = eval {
        no warnings 'redefine';
        local *DBIx::Class::ResultSet::search = sub {
            my ($rs, $where, $attrs) = @_;
            my @args = @_;
            if ($old_behavior && ref($attrs) eq 'HASH'
                && ($attrs->{order_by} || '') eq 'me.name') {
                $attrs = { %$attrs, distinct => 1 };
                # Restore master's unused stockprops join as well as distinct.
                my @joins = @{$attrs->{join}};
                if (!grep { !ref($_) && defined($_) && $_ eq 'stockprops' } @joins) {
                    splice @joins, 2, 0, 'stockprops';
                }
                $attrs->{join} = \@joins;
                $args[2] = $attrs;
            }
            return $original_search->(@args);
        };
        @answer = $search->search();
        1;
    };
    my $error = $@;
    $storage->debug($old_debug);
    $storage->debugobj($old_debugobj);
    die $error unless $ok;
    my @sql = grep { /\bFROM\s+(?:public\.)?stock\s+me\b/i } @{$capture->{statements}};
    return (\@answer, \@sql);
}

sub compare_search {
    my ($label, $parameters, $grouped, $expected_ids, $expected_total) = @_;
    my ($actual, $sql) = run_search($parameters, 0);
    my ($original, $old_sql) = run_search($parameters, 1);
    is_deeply($actual, $original, "$label: complete rows, returned order and records_total match master");
    cmp_ok(scalar(@$sql), '>=', 2, "$label: captured executed count and result SQL");
    ok(!grep({ !/\bGROUP\s+BY\b|\bDISTINCT\b/i } @$old_sql), "$label: baseline is grouped");
    ok(scalar(grep({ /\bORDER\s+BY\s+me\.name\b/i } @$sql)), "$label: SQL still orders by stock name");
    for my $statement (@$sql) {
        if ($grouped) {
            like($statement, qr/\bGROUP\s+BY\b|\bDISTINCT\b/i, "$label: deduplicates joined rows");
        } else {
            unlike($statement, qr/\bGROUP\s+BY\b|\bDISTINCT\b/i, "$label: no grouping or distinct");
            unlike($statement, qr/\bJOIN\s+(?:public\.)?stockprop\b/i, "$label: no multiplying stockprop join");
        }
    }
    if ($expected_ids) {
        is($actual->[1], defined($expected_total) ? $expected_total : scalar(@$expected_ids),
            "$label: total counts stocks before pagination");
        is_deeply([sort { $a <=> $b } map { $_->{stock_id} } @{$actual->[0]}],
            [sort { $a <=> $b } @$expected_ids], "$label: expected stocks without duplicates");
    }
    if ($label eq 'accession trial relationship' || $label eq 'direct trial experiment') {
        cmp_ok($actual->[1], '>', 0, "$label: exercises matching trial rows");
    }
    return;
}

{
    my $guard = $schema->txn_scope_guard();
    # Explicit unused negative primary keys avoid nextval: rollback cannot undo sequences.
    my ($stock_id) = $dbh->selectrow_array('SELECT LEAST(COALESCE(MIN(stock_id), 0), 0) - 1 FROM stock');
    my ($prop_id) = $dbh->selectrow_array('SELECT LEAST(COALESCE(MIN(stockprop_id), 0), 0) - 1 FROM stockprop');
    my ($organism_id) = $dbh->selectrow_array(
        'SELECT organism_id FROM stock WHERE uniquename = ?', undef, 'test_accession1');
    my $token = "stock-search-distinct-$$";
    for my $index (0 .. 1) {
        $dbh->do('INSERT INTO stock (stock_id, name, uniquename, type_id, organism_id, create_date) VALUES (?, ?, ?, ?, ?, ?)',
            undef, $stock_id - $index, "$token-$index", "$token-$index", $accession_type, $organism_id, $index ? '1999-01-01' : '2001-02-03');
        for my $type ($synonym_type, $date_type) {
            for my $rank (0 .. 1) {
                $dbh->do('INSERT INTO stockprop (stockprop_id, stock_id, type_id, value, rank) VALUES (?, ?, ?, ?, ?)',
                    undef, $prop_id--, $stock_id - $index, $type,
                    $type == $synonym_type ? "$token-alias" : '2001-02-03', $rank);
            }
        }
    }
    my @ids = ($stock_id, $stock_id - 1);
    compare_search('no filter', {}, 0);
    compare_search('type filter', { stock_type_id => $accession_type }, 0);
    compare_search('type name filter', { stock_type_name => 'accession' }, 0);
    compare_search('synonym contains', { match_name => "$token-alias", match_type => 'contains' }, 1, \@ids);
    compare_search('stockprop filter', {
        stockprops_values => { stock_synonym => { matchtype => 'exactly', value => "$token-alias" } },
    }, 0, \@ids);
    for my $date_parameter (qw(acquisition_date min_acquisition_date max_acquisition_date)) {
        compare_search($date_parameter, { stock_id_list => \@ids, $date_parameter => '2001-02-03' }, 1, \@ids);
    }
    compare_search('synonym and date aliases', {
        match_name => "$token-alias", acquisition_date => '2001-02-03',
    }, 1, \@ids);
    # Unique names make page membership well-defined; limit is an inclusive slice end.
    compare_search('first page', { stock_id_list => \@ids, limit => 0, offset => 0 }, 0, [$stock_id], 2);
    compare_search('second page', { stock_id_list => \@ids, limit => 1, offset => 1 }, 0, [$stock_id - 1], 2);
    for my $index (2 .. 3) {
        $dbh->do('INSERT INTO stock (stock_id, name, uniquename, type_id, organism_id) VALUES (?, ?, ?, ?, ?)',
            undef, $stock_id - $index, "$token-tied", "$token-$index", $accession_type, $organism_id);
    }
    compare_search('equal names without pagination', {
        stock_id_list => [$stock_id - 2, $stock_id - 3],
    }, 0, [$stock_id - 2, $stock_id - 3]);
    # A page cutting an equal-name group has no defined membership in master.
    my ($trial_id) = $dbh->selectrow_array(q{
        SELECT ep.project_id FROM stock s
        JOIN stock_relationship r ON r.object_id = s.stock_id
        JOIN nd_experiment_stock es ON es.stock_id = r.subject_id
        JOIN nd_experiment_project ep ON ep.nd_experiment_id = es.nd_experiment_id
        WHERE s.type_id = ? LIMIT 1
    }, undef, $accession_type);
    ok(defined($trial_id), 'fixture has an accession linked to a trial through a related stock');
    if (defined($trial_id)) {
        compare_search('accession trial relationship', {
            stock_type_id => $accession_type, trial_id_list => [$trial_id],
        }, 1);
        compare_search('direct trial experiment', { trial_id_list => [$trial_id] }, 1);
    }
    # The guard rolls back every inserted row, including when a search throws.
}

done_testing();
