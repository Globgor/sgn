use strict;

use lib 't/lib';

use Test::More 'tests' => 12;

use SGN::Test::WWW::WebDriver;
use SGN::Test::Fixture;

my $f = SGN::Test::Fixture->new();
my $t = SGN::Test::WWW::WebDriver->new();

$t->while_logged_in_as("submitter", sub {
    $t->wait_for_ajax();

    $t->get_ok('stock/38879/view');
    $t->wait_for_element("stock_images_section_onswitch", "id");

    my $images_onswitch = $t->find_element_ok("stock_images_section_onswitch",  "id",  "click to open image panel");
    $images_onswitch->click();
    $t->wait_for_element("add_new_image_button", "id");

    $t->find_element_ok("add_new_image_button", "id", "find add image button and click")->click();
    $t->wait_for_element("file", "name");

    # Add new image
    my $upload_input = $t->find_element_ok("file", "name", "find image input");
    my $filename = $f->config->{basepath}."/t/data/cassava_image.jpg";

    $t->driver()->upload_file($filename);
    $upload_input->send_keys($filename);
    $t->wait_until(sub { $upload_input->get_attribute('value') =~ /cassava_image\.jpg$/ });

    $t->find_element_ok("upload_image_submit", "id", "submit image upload")->click();
    $t->wait_for_element("store_image_submit", "id", 120);

    $t->find_element_ok("store_image_submit", "id", "store image upload")->click();
    $t->wait_until(sub { $t->find_element('pagetitle', 'id')->get_attribute('innerHTML') =~ /cassava_image.jpg/ }, 120);

    # check image redirected page for image content
    my $page_title = $t->find_element_ok(
        'pagetitle',
        'id',
        "find content of image name")->get_attribute('innerHTML');

    ok($page_title =~ /cassava_image.jpg/, "Verify page title name: cassava_image.jpg");

    # check image content on base page for stock view in image section
    $t->get_ok('stock/38879/view');
    $t->wait_for_element("stock_images_section_onswitch", "id");

    $images_onswitch = $t->find_element_ok("stock_images_section_onswitch",  "id",  "click to open image panel");
    $images_onswitch->click();
    $t->wait_until(sub { $t->is_visible($t->find_element('stock_images_section_content', 'id')) && $t->find_element('stock_images_section_content', 'id')->get_attribute('innerHTML') =~ /cassava_image.jpg/ });

    my $image_section = $t->find_element_ok(
        'stock_images_section_content',
        'id',
        "find content of image section")->get_attribute('innerHTML');

    ok($image_section =~ /cassava_image.jpg/, "Verify image file name in image section: cassava_image.jpg");

    }
);

$t->driver->close();
done_testing();
