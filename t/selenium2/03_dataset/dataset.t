use strict;

use lib 't/lib';

use Test::More;
use SGN::Test::Fixture;
use SGN::Test::WWW::WebDriver;
use CXGN::List;

my $d = SGN::Test::WWW::WebDriver->new();

my $f = SGN::Test::Fixture->new();

$d->while_logged_in_as("submitter", sub {

    # get_ok waits until the page and its AJAX requests are done
    $d->get_ok("/search/datasets", "get root url test");
    $d->logout_ok();
});

$d->driver->close();
done_testing();


