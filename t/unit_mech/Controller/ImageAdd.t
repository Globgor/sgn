use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::WWW::Mechanize;
use SGN::Test::Fixture;

# /image/add is opened from a record's image section with type and type_id.
# Without them the page must answer 400 with a message instead of failing
# in its template (type_id is a required argument of add_image.mas).

my $f = SGN::Test::Fixture->new();
my $base = $ENV{SGN_TEST_SERVER} || 'http://localhost:3010';
my ($stock_id) = $f->dbh->selectrow_array("SELECT stock_id FROM stock WHERE uniquename = 'UG120001'");
ok($stock_id, 'fixture has the accession UG120001');

my $mech = Test::WWW::Mechanize->new(autocheck => 0);

$mech->get("$base/image/add");
like($mech->uri->path, qr{/user/login}, 'a visitor who is not logged in is sent to the login page');

$mech->post("$base/ajax/user/login", { username => 'janedoe', password => 'secretpw' });
is($mech->status, 200, 'janedoe logs in');

for my $query ('', '?type=stock', '?type_id=' . $stock_id, '?type=stock&type_id=abc', '?type=stock&type_id=') {
    $mech->get("$base/image/add$query");
    is($mech->status, 400, "/image/add$query answers 400");
    $mech->content_contains('Add image', "/image/add$query explains where to add an image");
}

$mech->get("$base/image/add?type=stock&type_id=$stock_id");
is($mech->status, 200, 'the upload form opens for an existing accession');
$mech->content_contains('name="upload_image_form"', 'the page holds the upload form');

done_testing();
