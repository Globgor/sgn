use strict;

use lib 't/lib';

use Test::More;
use SGN::Test::Fixture;
use SGN::Test::WWW::WebDriver;
use CXGN::List;

my $d = SGN::Test::WWW::WebDriver->new();

my $f = SGN::Test::Fixture->new();

$d->while_logged_in_as("submitter", sub {

    $d->get_ok("/search/datasets", "get root url test");
    $d->wait_for_ajax();
    $d->wait_until(sub { $d->driver->execute_script(q{
        return jQuery.fn.dataTable.isDataTable('#dataset_search_results') &&
            jQuery('#dataset_search_results').DataTable().settings()[0]._bInitComplete === true;
    }) });
    $d->logout_ok();
});

$d->driver->close();
done_testing();


