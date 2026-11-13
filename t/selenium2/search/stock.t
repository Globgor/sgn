
use strict;

use lib 't/lib';

use Test::More;
use SGN::Test::WWW::WebDriver;

my $d = SGN::Test::WWW::WebDriver->new();

$d->get_ok('/search/stocks');
my $page_source = lc($d->driver()->get_page_source());

ok($page_source =~ /search accessions/, "Search page title presence");

ok($page_source =~ /project location/, "Search options present");

$d->wait_for_element("any_name", "id");
$d->wait_for_element("//select[\@id=\"stock_type_select\"]/option[text()='accession']", "xpath");

$d->find_element_ok("any_name", "id", "find any_name html input element")->send_keys("test_accession1");

$d->find_element("//select[\@id=\"stock_type_select\"]/option[text()='accession']", "xpath","select stock type")->click();

$d->find_element_ok("submit_stock_search", "id", "submit search")->click();
$d->wait_for_ajax();
$d->wait_for_element("test_accession1", "partial_link_text");
$d->find_element_ok("test_accession1", "partial_link_text", "verify search")->click();

$d->driver->quit();
done_testing();
