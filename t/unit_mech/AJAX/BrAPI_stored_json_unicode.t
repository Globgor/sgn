use strict;
use warnings;
use utf8;

# Stored JSON with non-ASCII text: the additional info of an observation
# variable (cvtermprop) and the JSON description of an ontology root term
# (dbxref.description). The database driver returns them as characters, and
# decode_json accepts only UTF-8 octets: /brapi/v2/variables failed and the
# ontology authors and copyright were dropped.

use lib 't/lib';
use SGN::Test::Fixture;
use SGN::Model::Cvterm;
use Test::More;
use Test::WWW::Mechanize;
use JSON;

my $f = SGN::Test::Fixture->new();
my $dbh = $f->dbh();
my $base = 'http://localhost:3010';
my $mech = Test::WWW::Mechanize->new(autocheck => 0);
$mech->post("$base/brapi/v2/token", [ username => 'janedoe', password => 'secretpw', grant_type => 'password' ]);
my $token = eval { decode_json($mech->content)->{access_token} };
ok($token, 'janedoe gets a BrAPI token');
$mech->add_header(Authorization => "Bearer $token");

my ($variable_id) = $dbh->selectrow_array(q{
    SELECT cvterm.cvterm_id
      FROM cvterm
      JOIN cvterm_relationship rel ON rel.subject_id = cvterm.cvterm_id
      JOIN cvterm reltype ON reltype.cvterm_id = rel.type_id AND reltype.name = 'VARIABLE_OF'
     ORDER BY cvterm.cvterm_id LIMIT 1});
ok($variable_id, 'the fixture has an observation variable');
my $info_type = SGN::Model::Cvterm->get_cvterm_row($f->bcs_schema, 'cvterm_additional_info', 'trait_property')->cvterm_id;
my $note = 'Урожай зерна, кг/ділянку';
$dbh->do('INSERT INTO cvtermprop (cvterm_id, type_id, value, rank) VALUES (?, ?, ?, 0)',
         undef, $variable_id, $info_type, JSON->new->canonical->encode({ note => $note }));

$mech->get("$base/brapi/v2/variables?observationVariableDbId=$variable_id");
is($mech->status, 200, 'v2 variables answers for a variable with non-ASCII additional info');
my $variables = eval { decode_json($mech->content) } || {};
my ($variable) = grep { $_->{observationVariableDbId} eq $variable_id } @{ $variables->{result}{data} || [] };
is($variable && $variable->{additionalInfo}{note}, $note, 'v2 variables returns the additional info text');

$dbh->do('DELETE FROM cvtermprop WHERE cvterm_id = ? AND type_id = ?', undef, $variable_id, $info_type);

# /brapi/v2/ontologies runs the same decoding line, but lists only ontologies
# with composable cv types, and the fixture has none; v1 lists the fixture's.
for my $version ('v1') {
    $mech->get("$base/brapi/$version/ontologies");
    my $ontologies = eval { decode_json($mech->content) } || {};
    my $ontology = ($ontologies->{result}{data} || [])->[0];
    ok($ontology, "$version ontologies lists an ontology") or diag($mech->status . ' ' . substr($mech->content, 0, 600)), next;
    my ($dbxref_id, $old) = $dbh->selectrow_array(q{
        SELECT dbxref.dbxref_id, dbxref.description FROM cvterm JOIN dbxref USING (dbxref_id)
         WHERE dbxref.db_id = ? AND cvterm.name = ? AND cvterm.is_obsolete = 0 LIMIT 1},
        undef, $ontology->{ontologyDbId}, $ontology->{description});
    ok($dbxref_id, "$version ontology root term found");
    $dbh->do('UPDATE dbxref SET description = ? WHERE dbxref_id = ?', undef,
             JSON->new->canonical->encode({ authors => 'Олена Коваль', copyright => '© Інститут рослинництва' }), $dbxref_id);
    $mech->get("$base/brapi/$version/ontologies?ontologyDbId=$ontology->{ontologyDbId}");
    my $after = eval { decode_json($mech->content) } || {};
    my ($same) = grep { $_->{description} eq $ontology->{description} } @{ $after->{result}{data} || [] };
    is($same && $same->{authors}, 'Олена Коваль', "$version ontologies returns the authors stored in non-ASCII JSON");
    is($same && $same->{copyright}, '© Інститут рослинництва', "$version ontologies returns the copyright stored with them");
    $dbh->do('UPDATE dbxref SET description = ? WHERE dbxref_id = ?', undef, $old, $dbxref_id);
}

done_testing();
