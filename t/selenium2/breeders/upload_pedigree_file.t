use strict;

use lib 't/lib';

use Test::More 'tests' => 6;

use SGN::Test::WWW::WebDriver;
use SGN::Test::Fixture;

my $f = SGN::Test::Fixture->new();
my $t = SGN::Test::WWW::WebDriver->new();

$t->while_logged_in_as("submitter", sub { 
    $t->wait_for_ajax();

    $t->get_ok('/breeders/accessions');
    $t->wait_for_element('upload_pedigrees_link', 'id');

    $t->find_element_ok("upload_pedigrees_link", "id", "click on upload_pedigrees_link ")->click();
    $t->wait_for_element('pedigrees_uploaded_file', 'id');

    my $upload_input = $t->find_element_ok("pedigrees_uploaded_file", "id", "find file input");

    my $filename = $f->config->{basepath}."/t/data/pedigree_upload/upload_accession_selenium_test.txt";

    $t->driver()->upload_file($filename);

    $upload_input->send_keys($filename);
    $t->wait_until(sub { $upload_input->get_attribute("value") =~ /upload_accession_selenium_test\.txt$/ });

    $t->find_element_ok("upload_pedigrees_dialog_submit", "id", "validate upload pedigrees file")->click();
    $t->wait_for_element('upload_pedigrees_store', 'id', 120);

    $t->find_element_ok("upload_pedigrees_store", "id", "store upload pedigrees file to database")->click();
    $t->wait_for_element('pedigrees_upload_success_dismiss', 'id', 120);

    $t->find_element_ok("pedigrees_upload_success_dismiss", "id", "dismiss success modal ")->click();
    $t->wait_until(sub { !$t->find_element("pedigrees_upload_success_dialog_message", "id")->is_displayed() });

    }
);
$t->driver()->close();
done_testing();
