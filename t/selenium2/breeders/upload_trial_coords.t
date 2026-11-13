use lib 't/lib';

use Test::More 'tests' => 11;

use SGN::Test::WWW::WebDriver;
use SGN::Test::Fixture;

use strict;

my $f = SGN::Test::Fixture->new();
my $t = SGN::Test::WWW::WebDriver->new();

$t->while_logged_in_as("submitter", sub {
    $t->wait_for_ajax();

    $t->get_ok('/breeders/trial/137');
    $t->wait_for_element('pheno_heatmap_onswitch', 'id');

    my $heatmap_onswitch = $t->find_element_ok("pheno_heatmap_onswitch",  "id",  "click to open pheno heatmap panel");

    $heatmap_onswitch->click();
    $t->wait_for_ajax();
    $t->wait_for_element('heatmap_upload_trial_coords_link', 'id');

    $t->find_element_ok("heatmap_upload_trial_coords_link", "id", "click on upload_trial_coords_link ")->click();

    my $upload_input = $t->find_element_ok("trial_coordinates_uploaded_file", "id", "find file input");

    my $filename = $f->config->{basepath}."/t/data/trial/upload_trial_coords_file.csv";

    $t->driver()->upload_file($filename);

    $upload_input->send_keys($filename);
    $t->wait_until(sub { $upload_input->get_attribute('value') =~ /upload_trial_coords_file\.csv$/ });

    $t->find_element_ok("upload_trial_coords_ok_button", "id", "submit upload trial coords file ")->click();
    $t->wait_for_ajax(150);
    $t->wait_for_element('trial_coord_upload_success_dialog_message_cancel', 'id', 150);

    $t->find_element_ok("trial_coord_upload_success_dialog_message_cancel", "id", "close success msg")->click();
    $t->wait_until(sub {
        my $attached = eval {
            $upload_input->get_attribute('value');
            1;
        };
        return !$attached && $t->driver->execute_script('return document.readyState === "complete" && !!document.getElementById("trial_fieldmap_download_layout_button");');
    }, 120);
    $t->wait_for_ajax(120);

    # RELOAD PAGE TO CHECK IF SUCCESS
    $t->get_ok('/breeders/trial/137');
    $t->wait_for_element('pheno_heatmap_onswitch', 'id');

    my $heatmap_onswitch = $t->find_element_ok("pheno_heatmap_onswitch",  "id",  "click to open pheno heatmap panel");

    $heatmap_onswitch->click();
    $t->wait_for_ajax();
    $t->wait_for_element('trial_fieldmap_download_layout_button', 'id');

    $t->find_element_ok("trial_fieldmap_download_layout_button", "id", "find a download button after upload coordinates");
    $t->wait_for_element('delete_field_map_hm_link', 'id');
    
    $t->find_element_ok("delete_field_map_hm_link", "id", "find a delete coordinates after upload button and click")->click();
    $t->wait_until(sub { $t->driver->get_alert_text() =~ /Are you sure you want to delete the spatial layout of this trial/ });

    $t->accept_alert_ok("find confirm deletion of coordinates after upload");
    }
);

eval { $t->driver()->close(); };
$f->clean_up_db();
done_testing();
