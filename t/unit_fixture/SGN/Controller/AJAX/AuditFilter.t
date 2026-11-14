package main;

use strict;
use warnings;
use utf8;
use lib 't/lib';
use Test::More;
use JSON;
use SGN::Test::Fixture;
use SGN::Controller::AJAX::Audit;

# Wrap the actual DBI statement so the test counts rows delivered to Perl.
package AuditTest::Statement;
sub execute { my $self = shift; return $self->{sth}->execute(@_); }
sub fetchrow_array {
    my ($self) = @_;
    my @row = $self->{sth}->fetchrow_array();
    $self->{count}++ if @row;
    return @row;
}
package AuditTest::DB;
sub prepare {
    my ($self, $sql) = @_;
    $self->{statement} = bless { sth => $self->{dbh}->prepare($sql), count => 0 }, 'AuditTest::Statement';
    return $self->{statement};
}
package AuditTest::Context;
sub req { return $_[0]; }
sub dbc { return $_[0]; }
sub dbh { return $_[0]->{db}; }
sub stash { return $_[0]->{stash}; }
sub param { return $_[0]->{params}{$_[1]}; }

package main;
my $fixture = SGN::Test::Fixture->new();
my $dbh = $fixture->dbh();
$dbh->{RaiseError} = 1;
$dbh->begin_work();
my $error;
eval {
    my $name = "audit test ' \x{0416} $$";
    my $project_id = 1900000000 + ($$ % 100000000);
    my $base = -(($$ % 1000000) * 2000 + 2000);
    # Serialize the unlikely case of process IDs mapping to the same range.
    $dbh->do('SELECT pg_advisory_xact_lock(?)', undef, $base);
    for my $case (
        ['stock', 'stock_uniquename', $name, 'stock_match_after', 'uniquename', 'text'],
        ['trial', 'trial_id', "$project_id", 'match_project', 'project_id', 'integer'],
    ) {
        my ($action, $param, $value, $key, $field, $type) = @$case;
        my $table = $action eq 'stock' ? 'stock' : 'project';
        my $other = $action eq 'stock' ? "$name other" : $project_id - 1;
        my $id = "${table}_audit_id";
        my ($collision) = $dbh->selectrow_array(
            "SELECT count(*) FROM audit.${table}_audit WHERE $id BETWEEN ? AND ?",
            undef, $base - 1006, $base - 1);
        die "Audit test ID range is already occupied" if $collision;
        # Start with an actual row shape; change only the tested key.
        my $sql = "WITH template AS (SELECT to_jsonb(t) AS row FROM public.$table t LIMIT 1), "
            . "payload AS (SELECT row, jsonb_set(row, ARRAY[?], to_jsonb(?::$type)) AS target FROM template) "
            . "INSERT INTO audit.${table}_audit ($id, operation, before, after) "
            . "SELECT ? - n, CASE WHEN n = 3 THEN 'DELETE' "
            . "WHEN n IN (2, 4, 5, 6) THEN 'UPDATE' ELSE 'INSERT' END, "
            . "CASE WHEN n IN (3, 4) THEN target ELSE NULL END, "
            . "CASE WHEN n IN (3, 5) THEN NULL WHEN n = 4 THEN jsonb_set(row, ARRAY[?], to_jsonb(?::$type)) "
            . "WHEN n = 6 THEN row - ? "
            . "WHEN n IN (1, 2) THEN target ELSE row - ? END "
            . "FROM payload CROSS JOIN generate_series(1, 1006) AS n";
        my $inserted = $dbh->do($sql, undef, $field, $value, $base, $field, $other, $field, $field);
        die "Fixture $table row missing" unless $inserted == 1006;
        my $expected = $dbh->selectall_arrayref(
            "SELECT * FROM audit.${table}_audit WHERE $id IN (?, ?, ?) ORDER BY $id",
            undef, $base - 1, $base - 2, $base - 3);
        is(scalar @$expected, 3, "$action expected insert, update and delete rows exist");
        my $db = bless { dbh => $dbh }, 'AuditTest::DB';
        my $ctx = bless { db => $db, params => { $param => $value }, stash => {} }, 'AuditTest::Context';
        my $method = "retrieve_${action}_audits";
        SGN::Controller::AJAX::Audit->$method($ctx);
        my $result = $ctx->stash->{rest}{$key};
        utf8::decode($result) if $action eq 'trial';
        my $actual = decode_json($result);
        my @sorted = sort { $a->[7] <=> $b->[7] } @$actual;
        is_deeply(\@sorted, decode_json(encode_json($expected)), "$action returns the expected rows");
        is($db->{statement}{count}, 3, "$action fetches only matching rows");
    }
    1;
} or $error = $@ || 'Audit test failed';
$dbh->rollback();
die $error if defined $error;
done_testing();
