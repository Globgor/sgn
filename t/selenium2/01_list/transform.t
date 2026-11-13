
use strict;

use lib 't/lib';

use Test::More;
use SGN::Test::WWW::WebDriver;

my $d = SGN::Test::WWW::WebDriver->new();

$d->while_logged_in_as('submitter', sub {
    $d->get_ok("/about/index.pl", "get root url test");

    $d->wait_for_element("lists_link", "name");

    my $out = $d->find_element_ok("lists_link", "name", "find lists_link")->click();

    $d->wait_for_element("add_list_input", "id");

    print "Adding new list...\n";

    $d->find_element_ok("add_list_input", "id", "find add list input");
    $d->wait_for_element("add_list_input", "id");
    my $add_list_input = $d->find_element_ok("add_list_input", "id", "find add list input test");

    $d->wait_for_element("add_list_input", "id");

    $add_list_input->send_keys("new_test_list_transform");

    $d->wait_for_element("add_list_button", "id");

    $d->find_element_ok("add_list_button", "id", "find add list button test")->click();
    $d->wait_for_ajax(120);
    $d->wait_for_element("view_list_new_test_list_transform", "id", 120);
    $d->find_element_ok("view_list_new_test_list_transform", "id", "view list test")->click();

    $d->wait_for_element("dialog_add_list_item", "id");

    $d->find_element_ok("dialog_add_list_item", "id", "add test list")->send_keys("test_accession1\ntest_accession2\ntest_accession3_synonym1\n");

    $d->wait_for_element("dialog_add_list_item_button", "id");

    $d->find_element_ok("dialog_add_list_item_button", "id", "find dialog_add_list_item_button test")->click();

    print "Close list content dialog...\n";

    $d->wait_for_ajax(120);
    $d->wait_until(sub { $d->find_element("list_item_dialog_datatable", "id")->get_text() =~ /test_accession3_synonym1/ }, 120);
    $d->wait_for_element("close_list_item_dialog", "id");

    my $button = $d->find_element_ok("close_list_item_dialog", "id", "find close_list_item_dialog button test");

    $button->click() if ($button);

    print "Delete test list...\n";

    my $delete_link = $d->find_element_ok("delete_list_new_test_list_transform", "id", "find delete test list button");

    $delete_link->click() if $delete_link;

    $d->wait_until(sub { $d->driver->get_alert_text() }, 120);

    my $text = $d->driver->get_alert_text();

    $d->accept_alert_ok();

    $d->wait_until(sub { $d->driver->get_alert_text() }, 120);

    $d->accept_alert_ok();

    print "Deleted the list\n";

    $d->find_element_ok("close_list_dialog_button", "id", "find close dialog button")->click();

});

$d->driver->close();
done_testing();

