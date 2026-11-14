use lib 't/lib';

use Test::More 'tests' => 10;

use SGN::Test::WWW::WebDriver;


my $t = SGN::Test::WWW::WebDriver->new();

$t->while_logged_in_as("curator", sub {

    $t->get_ok('/breeders/manage_programs');

    my $new_bp_link = $t->find_element_ok('new_breeding_program_link', 'id', 'new breeding program link');

    $new_bp_link->click();


    my $breeding_program_name_input = $t->find_element_ok('store_breeding_program_name', 'id', 'find store breeding program name input');

    $breeding_program_name_input->send_keys('WEBTEST');

    my $breeding_program_desc_input = $t->find_element_ok('store_breeding_program_desc', 'id', 'find store breeding program description input');

    $breeding_program_desc_input->send_keys('Test description.');

    my $ok_button = $t->find_element_ok('store_breeding_program_submit', 'id', 'find store breeding program button');

    $ok_button->click();


    $t->wait_until(sub { $t->driver->get_alert_text() });
    $t->driver->accept_alert();


    $t->get_ok('/breeders/manage_programs');


    $t->wait_until(sub { $t->driver->get_page_source() =~ m/WEBTEST/ });
    ok($t->driver->get_page_source() =~ m/WEBTEST/, "breeding program addition successful");


    my $delete_link = $t->find_element_ok('delete_breeding_program_link_WEBTEST', 'id', 'find breeding program delete link');


    $t->wait_until(sub { $t->is_visible($delete_link) && $delete_link->is_enabled() });
    $delete_link->click();


    $t->wait_until(sub { $t->driver->get_alert_text() =~ m/Delete breeding program WEBTEST/i });
    $t->driver->accept_alert();


    $t->wait_until(sub { $t->driver->get_page_source() !~ m/WEBTEST/ });
    $t->get_ok('/breeders/manage_programs');


    $t->wait_until(sub { $t->driver->get_page_source() !~ m/WEBTEST/ });
    ok($t->driver->get_page_source() !~ m/WEBTEST/, "breeding program deletion successful");
});

$t->driver()->close();
done_testing();
