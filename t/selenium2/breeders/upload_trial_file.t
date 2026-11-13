use lib 't/lib';

# use Test::More 'tests' => 40;
use Test::More 'tests' => 80;

use SGN::Test::WWW::WebDriver;
use SGN::Test::Fixture;

use strict;

my $f = SGN::Test::Fixture->new();
my $t = SGN::Test::WWW::WebDriver->new();


$t->while_logged_in_as("submitter", sub {


    for my $extension ("xls", "xlsx") {
        $t->wait_for_ajax();

        $t->get_ok('/breeders/trials');
        $t->wait_for_element('refresh_jstree_html', 'name');

        $t->find_element_ok("refresh_jstree_html", "name", "click on refresh_jstree_html ")->click();
        $t->wait_for_ajax(120);
        $t->wait_for_element('upload_trial_link', 'name', 120);

        $t->find_element_ok("upload_trial_link", "name", "click on upload_trial_link ")->click();
        $t->wait_for_ajax();
        $t->wait_for_element('next_step_upload_intro_button', 'id');

        # SCREEN 1 /Intro/
        $t->find_element_ok("next_step_upload_intro_button", "id", "click on next_step_upload_intro_button ")->click();
        $t->wait_for_element('upload_single_trial_design_tab', 'id');

        # SCREEN 2 /File formatting/
        $t->find_element_ok("upload_single_trial_design_tab", "id", "choose a single trial design tab (default)")->click();
        $t->wait_for_element('next_step_file_formatting_button', 'id');
        $t->find_element_ok('next_step_file_formatting_button', 'id', 'go to next screen - Intro')->click();
        $t->wait_for_element('trial_upload_name', 'id');

        # SCREEN 3 /Enter trial information/
        my $trial_name = "selenium_test_upload_trial_file";
        $t->find_element_ok("trial_upload_name", "id", "find trial name input")->send_keys($trial_name);

        $t->find_element_ok("trial_upload_breeding_program", "id", "find breeding program select")->click();
        $t->wait_for_element('//select[@id="trial_upload_breeding_program"]/option[@value="test"]', 'xpath');
        $t->find_element_ok('//select[@id="trial_upload_breeding_program"]/option[@value="test"]', 'xpath', "Select 'test' as value for breeding program")->click();

        $t->find_element_ok("trial_upload_location", "id", "find location select")->click();
        $t->wait_for_element('//select[@id="trial_upload_location"]/option[@value="test_location"]', 'xpath');
        $t->find_element_ok('//select[@id="trial_upload_location"]/option[@value="test_location"]', 'xpath', "Select 'test_location' as value for trial location")->click();

        $t->find_element_ok("trial_upload_trial_type", "id", "find trial type select")->click();
        $t->wait_for_element('//select[@id="trial_upload_trial_type"]/option[@title="phenotyping_trial"]', 'xpath');

        $t->find_element_ok('//select[@id="trial_upload_trial_type"]/option[@title="phenotyping_trial"]', 'xpath', "Select 'phenotyping_trial' as value for type of trial")->click();

        $t->find_element_ok("trial_upload_year", "id", "find trial year input")->click();
        $t->wait_for_element('//select[@id="trial_upload_year"]/option[@value="2015"]', 'xpath');
        $t->find_element_ok('//select[@id="trial_upload_year"]/option[@value="2015"]', 'xpath', "Select '2016' as value for year")->click();

        $t->find_element_ok('trial_upload_plot_width', 'id', "find trial plot width input")->send_keys("10");
        $t->find_element_ok('trial_upload_plot_length', 'id', "find trial plot length input")->send_keys("10");
        $t->find_element_ok('trial_upload_field_size', 'id', "find trial field size input")->send_keys("5");
        $t->find_element_ok('trial_upload_plant_entries', 'id', "find trial plants per plot input")->send_keys("10");

        $t->find_element_ok("trial_upload_description", "id", "find trial description input")->send_keys('Test test upload trial file - description');;

        $t->find_element_ok("trial_upload_trial_stock_type", "id", "find trial design select")->click();
        $t->wait_for_element('//select[@id="trial_upload_trial_stock_type"]/option[@value="accession"]', 'xpath');
        $t->find_element_ok('//select[@id="trial_upload_trial_stock_type"]/option[@value="accession"]', 'xpath', "Select 'accession' as value for stock type")->click();

        $t->find_element_ok("trial_upload_design_method", "id", "find trial design select")->click();
        $t->wait_for_element('//select[@id="trial_upload_design_method"]/option[@value="CRD"]', 'xpath');
        $t->find_element_ok('//select[@id="trial_upload_design_method"]/option[@value="CRD"]', 'xpath', "Select 'CRD' as value for design method")->click();

        my $upload_input = $t->find_element_ok("trial_uploaded_file", "id", "find file input");
        my $filename = $f->config->{basepath} . "/t/data/trial/trial_layout_example_other_plots.$extension";

        $t->driver()->upload_file($filename);
        $upload_input->send_keys($filename);
        $t->wait_until(sub { $t->driver->execute_script('return arguments[0].files.length === 1 && arguments[0].files[0].name === arguments[1].split("/").pop();', $upload_input, $filename) });

        $t->find_element_ok('next_step_trial_information_button', 'id', 'go to next screen - Intro')->click();
        # SCREEN 4 /Trial Linkage/

        $t->find_element_ok("upload_trial_trial_sourced", "id", "find trial sourced select")->click();
        $t->wait_for_element('//select[@id="upload_trial_trial_sourced"]/option[@value="no"]', 'xpath');
        $t->find_element_ok('//select[@id="upload_trial_trial_sourced"]/option[@value="no"]', 'xpath', "Select 'no' as value for trial sourced")->click();

        $t->find_element_ok("upload_trial_trial_will_be_genotyped", "id", "find 'trial will be genotyped' select")->click();
        $t->wait_for_element('//select[@id="upload_trial_trial_will_be_genotyped"]/option[@value="no"]', 'xpath');
        $t->find_element_ok('//select[@id="upload_trial_trial_will_be_genotyped"]/option[@value="no"]', 'xpath', "Select 'no' as value for trial will be genotyped")->click();

        $t->find_element_ok("upload_trial_trial_will_be_crossed", "id", "find 'trial will be crossed' select")->click();
        $t->wait_for_element('//select[@id="upload_trial_trial_will_be_crossed"]/option[@value="no"]', 'xpath');
        $t->find_element_ok('//select[@id="upload_trial_trial_will_be_crossed"]/option[@value="no"]', 'xpath', "Select 'no' as value for trial will be crossed")->click();

        $t->find_element_ok("upload_trial_validate_form_button", "id", "find and click trial validate form button")->click();
        $t->wait_for_ajax(120);
        $t->wait_until(sub { $t->find_element('upload_trial_submit_first', 'name')->is_enabled() }, 120);

        $t->find_element_ok("upload_trial_submit_first", "name", "find and click upload trial submit button")->click();

        # important sleep 60 seconds for a functionality - it can take ages to save a trail depend of the machine
        $t->wait_for_ajax(600);
        $t->wait_for_element('#trial_upload_workflow .workflow-complete-message [name="upload_trial_success_complete_button"]', 'css', 600);
        $t->wait_for_ajax(600);

        $t->find_element_ok("close_trial_upload_dialog", "id", "find and click close trial upload button")->click();

        $t->get_ok('/breeders/trials');
        $t->wait_for_element('refresh_jstree_html', 'name');

        $t->find_element_ok("refresh_jstree_html", "name", "refresh tree")->click();
        $t->wait_for_ajax(120);
        $t->wait_for_element('test', 'partial_link_text', 120);

        $t->find_element_ok("test", "partial_link_text", "check program in tree")->click();
        $t->wait_for_element('jstree-icon', 'class');

        $t->find_element_ok("jstree-icon", "class", "view drop down for program")->click();
        $t->wait_for_element("$trial_name", "partial_link_text");

        $t->find_element_ok("$trial_name", "partial_link_text", "check program in tree")->click();
        $t->wait_for_ajax();

        $f->clean_up_db();
    }
});

$t->driver->close();
done_testing();
