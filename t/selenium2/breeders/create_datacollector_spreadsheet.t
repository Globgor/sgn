
use strict;

use lib 't/lib';

use Test::More 'tests' => 22;
use SGN::Test::WWW::WebDriver;
use SGN::Test::Fixture;

my $d = SGN::Test::WWW::WebDriver->new();
my $f = SGN::Test::Fixture->new();


$d->while_logged_in_as("submitter", sub {
    $d->wait_for_ajax();
	
	$d->get_ok('/breeders/trial/137');
	$d->wait_for_element("lists_link", "name");

	$d->find_element_ok("lists_link", "name", "find lists_link")->click();

	$d->find_element_ok("add_list_input", "id", "find add list input");

	my $add_list_input = $d->find_element_ok("add_list_input", "id", "find add list input test");
	$d->wait_for_element("add_list_input", "id");

	my $random_val = int(rand(1000));
	my $list_name = sprintf("selenium_test_list_datacollector_%d", $random_val);

	$add_list_input->send_keys($list_name);
	$d->wait_for_element("add_list_button", "id");

	$d->find_element_ok("add_list_button", "id", "find add list button test")->click();
	$d->wait_for_ajax(120);
	$d->wait_for_element("view_list_$list_name", "id", 120);

	$d->find_element_ok("view_list_$list_name", "id", "view list test")->click();
	$d->wait_for_element("updateListDescField", "id");

	$d->find_element_ok("updateListDescField", "id", "find list type")->send_keys($list_name);

	$d->find_element_ok("type_select", "id", "find list type")->click();
	$d->find_element_ok('option[name="traits"]', "css", "select type 'traits' from a list")->click();
	$d->wait_for_element("dialog_add_list_item", "id");

	$d->find_element_ok("dialog_add_list_item", "id", "add test list")->send_keys("dry matter content percentage|CO_334:0000092\nfresh root weight|CO_334:0000012\nfresh shoot weight measurement in kg|CO_334:0000016\nharvest index variable|CO_334:0000015\n");
	$d->wait_for_element("dialog_add_list_item_button", "id");

	$d->find_element_ok("dialog_add_list_item_button", "id", "find dialog_add_list_item_button test")->click();

	my $button = $d->find_element_ok("close_list_item_dialog", "id", "find close_list_item_dialog button test");

	$button->click();
	$d->wait_until(sub { !$d->is_visible($d->find_element("list_item_dialog", "id")) });

	$d->find_element_ok("close_list_dialog_button", "id", "find close dialog button")->click();

	$d->get_ok('/breeders/trial/137');
	$d->wait_for_element("trial_upload_files_onswitch", "id");

	my $trail_files_onswitch = $d->find_element_ok("trial_upload_files_onswitch",  "id",  "find and open 'trial upload files onswitch' and click");
	$trail_files_onswitch->click();
	$d->wait_for_element('create_DataCollector_link', 'id');

 	my $create_DataCollector_link = $d->find_element_ok('create_DataCollector_link', 'id', "find create data collector spreadsheet link");
	$create_DataCollector_link->click();
	$d->wait_for_element('trait_list_dc_list_select', 'id');

	$d->find_element_ok('trait_list_dc_list_select', 'id', "find and open list select input")->click();
	$d->wait_for_element("//select[\@id='trait_list_dc_list_select']//option[contains(text(),\"$list_name\")]", 'xpath');

	$d->find_element_ok("//select[\@id='trait_list_dc_list_select']//option[contains(text(),\"$list_name\")]", 'xpath', "Select a new $list_name from list select")->click();
	$d->wait_for_element('download_datacollector_data_level', 'id');

	$d->find_element_ok('download_datacollector_data_level', 'id', "find and open list of 'data levels' select input")->click();
	$d->wait_for_element('//select[@id="download_datacollector_data_level"]//option[@value="plots"]', 'xpath');

	$d->find_element_ok('//select[@id="download_datacollector_data_level"]//option[@value="plots"]', 'xpath', "Select plants as value for select data levels input")->click();
	$d->wait_for_element("create_DataCollector_submit_button", "id");

	$d->find_element_ok('create_DataCollector_submit_button', 'id', "find create excel file button and click")->click();
	# The generation callback hides working_modal; wait for it and AJAX to finish before logout.
	$d->wait_for_ajax(120);


	$d->logout_ok();
});

$d->driver->close();
$f->clean_up_db();
done_testing();




