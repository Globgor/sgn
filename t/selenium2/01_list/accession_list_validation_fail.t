use strict;

use lib 't/lib';

use Test::More 'tests' => 17;
use SGN::Test::Fixture;
use SGN::Test::WWW::WebDriver;
use CXGN::List;
use SimulateC;

my $d = SGN::Test::WWW::WebDriver->new();

$d->while_logged_in_as( "submitter",  sub {
        $d->wait_for_ajax();

        $d->get_ok( "/search", "get root url test" );
        $d->wait_for_element("lists_link", "name");

        my $out = $d->find_element_ok( "lists_link", "name", "find lists_link" ) ->click();
        $d->wait_for_element("add_list_input", "id");
        print "Adding new list...\n";

        $d->find_element_ok( "add_list_input", "id", "find add list input" );
        $d->wait_for_element("add_list_input", "id");
        my $add_list_input = $d->find_element_ok( "add_list_input", "id",
            "find add list input test" );
        $d->wait_for_element("add_list_input", "id");
        $add_list_input->send_keys("new_test_list_accession_validation_fail");
        $d->wait_for_element("add_list_button", "id");
        $d->find_element_ok( "add_list_button", "id",
            "find add list button test" )->click();
        $d->wait_for_ajax(120);
        $d->wait_for_element("view_list_new_test_list_accession_validation_fail", "id", 120);
        $d->find_element_ok(
            "view_list_new_test_list_accession_validation_fail",
            "id", "view list test" )->click();

        $d->wait_for_element("dialog_add_list_item", "id");

        $d->find_element_ok( "dialog_add_list_item", "id", "add test list" )
            ->send_keys("element11\nelement22\nelement33\n");

        $d->wait_for_element("dialog_add_list_item_button", "id");

        $d->find_element_ok( "dialog_add_list_item_button", "id",
            "find dialog_add_list_item_button test" )->click();
        $d->wait_for_ajax(120);
        $d->wait_for_element("type_select", "id");

        $d->find_element_ok("type_select", "id", "validate list select")->click();
        $d->wait_for_element("//select[\@id='type_select']/option[\@name='accessions']", 'xpath');
        $d->find_element_ok("//select[\@id='type_select']/option[\@name='accessions']", 'xpath', "Select 'accessions' as value for list type")->click();
        $d->wait_for_ajax(120);

        $d->wait_for_element("list_item_dialog_validate", "id");
        $d->find_element_ok( "list_item_dialog_validate", "id",
            "submit list validate" )->click();
        $d->wait_for_element('//div[@id="validate_accession_error_display"]//div[@class="modal-content"]', 'xpath', 120);
        $d->wait_until(sub {
            my $content = $d->find_element('//div[@id="validate_accession_error_display"]//div[@class="modal-content"]', 'xpath')->get_attribute('innerHTML');
            return $content =~ /List Validation Report: Failed/ && $content =~ /element11/ && $content =~ /element22/ && $content =~ /element33/;
        }, 120);

        my $validation_result = $d->find_element_ok(
            '//div[@id="validate_accession_error_display"]//div[@class="modal-content"]',
            'xpath',
            "find content of validation modal")->get_attribute('innerHTML');
        $d->wait_for_ajax(120);

        ok($validation_result =~ /List Validation Report: Failed/, "Verify first validation result: 'List Validation Report: Failed'");
        ok($validation_result =~ /element11/, "Verify first validation result: 'element11'");
        ok($validation_result =~ /element22/, "Verify first validation result: 'element22'");
        ok($validation_result =~ /element33/, "Verify first validation result: 'element33'");
        $d->wait_for_element("close_missing_accessions_dialog", "id");


        $d->find_element_ok( "close_missing_accessions_dialog", "id",
            "find close missing accession dialog button" )->click();
        $d->wait_until(sub { !$d->find_element("validate_accession_error_display", "id")->is_displayed() });

}
);

$d->driver->close();
done_testing();


