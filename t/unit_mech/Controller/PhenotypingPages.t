use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::WWW::Mechanize;
use SGN::Test::Fixture;

# The plot and trial phenotyping pages are opened from an existing plot or
# trial. A missing, malformed, out-of-range or unknown id must give 400 with a
# message instead of an internal server error.

my $f = SGN::Test::Fixture->new();
my $base = $ENV{SGN_TEST_SERVER} || 'http://localhost:3010';
my ($plot_id) = $f->dbh->selectrow_array(
    "SELECT stock_id FROM stock JOIN cvterm ON cvterm_id = stock.type_id WHERE cvterm.name = 'plot' ORDER BY stock_id LIMIT 1");
my ($trial_id) = $f->dbh->selectrow_array("SELECT project_id FROM project WHERE name = 'Kasese solgs trial'");
ok($plot_id && $trial_id, 'fixture has a plot and a field trial');

my $mech = Test::WWW::Mechanize->new(autocheck => 0);
$mech->get("$base/breeders/plot_phenotyping?stock_id=$plot_id");
like($mech->uri->path, qr{/user/login}, 'a visitor who is not logged in is sent to the login page');
$mech->post("$base/ajax/user/login", { username => 'janedoe', password => 'secretpw' });
is($mech->status, 200, 'janedoe logs in');

for my $page (['plot_phenotyping', 'stock_id', 'plot'], ['trial_phenotyping', 'trial_id', 'trial']) {
    my ($path, $param, $record) = @$page;
    for my $value (undef, '', 'abc', '0', '-1', '999999999', '99999999999') {
        my $query = defined($value) ? "?$param=$value" : '';
        $mech->get("$base/breeders/$path$query");
        is($mech->status, 400, "/breeders/$path$query answers 400");
        $mech->content_contains("Open an existing $record", "/breeders/$path$query explains what to open");
    }
}

$mech->get("$base/breeders/plot_phenotyping?stock_id=$plot_id");
is($mech->status, 200, 'the plot phenotyping page opens for an existing plot');
$mech->get("$base/breeders/trial_phenotyping?trial_id=$trial_id");
is($mech->status, 200, 'the trial phenotyping page opens for an existing trial');

done_testing();
