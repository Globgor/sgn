use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::WWW::Mechanize;

# The retired trial tree URL sends the user to the trials page instead of
# failing in trialtree.mas (its required breeding_programs argument was never set).

my $base = $ENV{SGN_TEST_SERVER} || 'http://localhost:3010';
my $mech = Test::WWW::Mechanize->new(autocheck => 0, max_redirect => 0);
$mech->post("$base/ajax/user/login", { username => 'janedoe', password => 'secretpw' });
is($mech->status, 200, 'janedoe logs in');

$mech->get("$base/breeders/trialtree");
is($mech->status, 302, '/breeders/trialtree redirects');
like($mech->response->header('Location'), qr{/breeders/trials\z}, 'to the trials page');

$mech->max_redirect(7);
$mech->get("$base/breeders/trialtree");
is($mech->status, 200, 'the trials page opens');

done_testing();
