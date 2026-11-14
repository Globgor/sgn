use lib 't/lib';

use Test::More 'tests' => 11;

use SGN::Test::WWW::WebDriver;
use SGN::Test::Fixture;

use strict;

my $f = SGN::Test::Fixture->new();
my $t = SGN::Test::WWW::WebDriver->new();

$t->while_logged_in_as("submitter", sub {

    $t->get_ok('/breeders/trial/137');

    my $heatmap_onswitch = $t->find_element_ok("pheno_heatmap_onswitch",  "id",  "click to open pheno heatmap panel");

    $heatmap_onswitch->click();

    $t->find_element_ok("heatmap_upload_trial_coords_link", "id", "click on upload_trial_coords_link ")->click();

    my $upload_input = $t->find_element_ok("trial_coordinates_uploaded_file", "id", "find file input");

    my $filename = $f->config->{basepath}."/t/data/trial/upload_trial_coords_file.csv";

    $t->driver()->upload_file($filename);

    $upload_input->send_keys($filename);

    $t->wait_until(sub { $t->driver->execute_script('return arguments[0].files.length === 1 && arguments[0].files[0].name === arguments[1].split("/").pop();', $upload_input, $filename) });
    $t->find_element_ok("upload_trial_coords_ok_button", "id", "submit upload trial coords file ")->click();

    $t->wait_for_reload(sub {
    $t->find_element_ok("trial_coord_upload_success_dialog_message_cancel", "id", "close success msg")->click();

    });
    # RELOAD PAGE TO CHECK IF SUCCESS
    $t->get_ok('/breeders/trial/137');

    my $heatmap_onswitch = $t->find_element_ok("pheno_heatmap_onswitch",  "id",  "click to open pheno heatmap panel");

    $heatmap_onswitch->click();

    $t->find_element_ok("trial_fieldmap_download_layout_button", "id", "find a download button after upload coordinates");
    
    $t->find_element_ok("delete_field_map_hm_link", "id", "find a delete coordinates after upload button and click")->click();

    $t->wait_until(sub { $t->driver->get_alert_text() =~ /Are you sure you want to delete the spatial layout of this trial/ });
    $t->accept_alert_ok("find confirm deletion of coordinates after upload");
    }
);

eval { $t->driver()->close(); };
$f->clean_up_db();
done_testing();
