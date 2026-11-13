
use strict;

use lib 't/lib';

use Test::More;
use SGN::Test::WWW::WebDriver;



my $d = SGN::Test::WWW::WebDriver->new();

my $download_dir = $d->download_dir();


$d->while_logged_in_as("submitter", sub {
    # sleep(1);

    $d->get_ok("/about/index.pl", "get root url test");
    $d->wait_for_element("lists_link", "name");

    my $out = $d->find_element_ok("lists_link", "name", "find lists_link")->click();

    $d->wait_for_element("(//table[\@id='private_list_data_table']/thead/tr/th)[1]", "xpath");

    # Revert to original sorting: by list name, ascending
    $d->find_element_ok("(//table[\@id='private_list_data_table']/thead/tr/th)[1]", "xpath", "Sort table by List Name")->click();

    $d->wait_for_element("list_select_checkbox_808", "id");

    $d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list")->click();

    $d->wait_for_element("list_select_checkbox_810", "id");

    $d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list")->click();

    $d->wait_for_element("make_public_selected_list_group", "id");

    $d->find_element_ok("make_public_selected_list_group", "id", "make public selected list group")->click();

    $d->wait_until(sub { $d->driver->get_alert_text() }, 120);

    $d->accept_alert_ok();

    $d->wait_for_ajax(120);
    $d->wait_for_element("view_public_lists_button", "id");

    $d->find_element_ok("view_public_lists_button", "id", "view public lists")->click();

    $d->wait_for_element("view_public_list_johndoe_1_private", "id");

    $d->find_element_ok("view_public_list_johndoe_1_private", "id", "check view public lists");

    $d->wait_for_element("close_public_list_item_dialog", "id");

    $d->find_element_ok("close_public_list_item_dialog", "id", "close public lists")->click();

    $d->wait_until(sub { !$d->is_visible($d->find_element("public_list_dialog", "id")) });
    $d->wait_for_element("list_select_checkbox_808", "id");

    $d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list")->click();

    $d->wait_for_element("list_select_checkbox_810", "id");

    $d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list")->click();

    $d->wait_for_element("make_private_selected_list_group", "id");

    $d->find_element_ok("make_private_selected_list_group", "id", "make private selected list group")->click();

    $d->wait_until(sub { $d->driver->get_alert_text() }, 120);

    $d->accept_alert_ok();

    $d->wait_for_ajax(120);
    $d->wait_for_element("list_select_checkbox_808", "id");

    ## Combine two lists using union

    $d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list 808")->click();

    $d->wait_for_element("list_select_checkbox_810", "id");

    $d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list 810")->click();

    $d->wait_for_element("new_combined_list_name", "id");

    $d->find_element_ok("new_combined_list_name", "id", "name selected list group - union")->send_keys("combined_list_union");

    $d->find_element_ok("combine_selected_list_group_union", "id", "combine selected list group - union")->click();

    $d->wait_until(sub { $d->driver->get_alert_text() }, 120);

    $d->accept_alert_ok();

    $d->wait_until(sub { $d->driver->get_alert_text() =~ m/Added 4 items to the new List combined_list_union/i }, 120);

    ok($d->driver->get_alert_text() =~ m/Added 4 items to the new List combined_list_union/i, 'created selected list group - union');
    $d->accept_alert_ok();

    $d->wait_for_ajax(120);
    $d->wait_for_element("view_list_combined_list_union", "id", 120);

    $d->find_element_ok("view_list_combined_list_union", "id", "check view combined list - union");

    $d->wait_for_element("list_select_checkbox_808", "id");

    ## Combine two lists using intersection

    $d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list 808")->click();

    $d->wait_for_element("list_select_checkbox_4", "id");

    $d->find_element_ok("list_select_checkbox_4", "id", "checkbox select list 4")->click();

    $d->wait_for_element("new_combined_list_name", "id");

    $d->find_element_ok("new_combined_list_name", "id", "name selected list group - intersection")->send_keys("combined_list_intersection");

    $d->find_element_ok("combine_selected_list_group_intersection", "id", "combine selected list group - intersection")->click();

    $d->wait_until(sub { $d->driver->get_alert_text() }, 120);

    $d->accept_alert_ok();

    $d->wait_until(sub { $d->driver->get_alert_text() =~ /Are you sure you want to combine these list types:/ }, 120);

    # Accept alert about mismatched list types (one list doesn't have it's type set)
    $d->accept_alert_ok();

    $d->wait_until(sub { $d->driver->get_alert_text() =~ m/Added 2 items to the new List combined_list_intersection/i }, 120);

    ok($d->driver->get_alert_text() =~ m/Added 2 items to the new List combined_list_intersection/i, 'created selected list group - intersection');
    $d->accept_alert_ok();

    $d->wait_for_ajax(120);
    $d->wait_for_element("view_list_combined_list_intersection", "id", 120);

    $d->find_element_ok("view_list_combined_list_intersection", "id", "check view combined list - intersection");

    $d->wait_for_element("list_select_checkbox_808", "id");

    # Compare two lists

    unlink glob("$download_dir/*");

    $d->find_element_ok("list_select_checkbox_808", "id", "checkbox select list 808")->click();

    $d->wait_for_element("list_select_checkbox_810", "id");

    $d->find_element_ok("list_select_checkbox_810", "id", "checkbox select list 810")->click();

    $d->wait_for_element("compare_selected_list_group", "id");

    $d->find_element_ok("compare_selected_list_group", "id", "compare selected list group")->click();

    $d->wait_for_ajax(120);
    $d->wait_for_element("download_comparison_column", "id", 120);

    $d->find_element_ok("download_comparison_column", "id", "find download comparison column button")->click();

    my $previous_download_size;
    $d->wait_until(sub {
        my $path = "$download_dir/Only in johndoe_1_private.txt";
        return 0 unless -f $path;
        my $size = -s $path;
        my $stable = defined $previous_download_size && $size > 0 && $size == $previous_download_size;
        $previous_download_size = $size;
        return $stable;
    }, 60, 0.5);
    $d->wait_for_element("close_list_comparison_modal", "id");

    $d->find_element_ok("close_list_comparison_modal", "id", "find close comparison dialog button")->click();

    $d->wait_until(sub { !$d->is_visible($d->find_element("list_comparison_modal", "id")) });


    my @files = glob("$download_dir/*");

    ok(@files, "File downloaded to tmp directory");

    my $downloaded_file = "$download_dir/Only in johndoe_1_private.txt";

    ok(-f $downloaded_file, "Found downloaded file: $downloaded_file");

    open my $fh, '<', $downloaded_file or die "Could not open $downloaded_file: $!";
    my $contents = do {local $/; <$fh> };
    close $fh;

    my $expected = "test1\ntest2";
    like($contents, qr/\Q$expected\E/, "Downloaded file contains expected content");

    ## Delete list group

    $d->find_element_ok("delete_selected_list_group", "id", "delete selected list group")->click();

    $d->wait_until(sub { $d->driver->get_alert_text() }, 120);

    $d->accept_alert_ok();

    $d->wait_for_ajax(120);
    $d->wait_until(sub { $d->driver->execute_script(q{
        return !document.getElementById('list_select_checkbox_808') &&
            !document.getElementById('list_select_checkbox_810');
    }) }, 120);
    $d->wait_for_element("close_list_dialog_button", "id");


    $d->find_element_ok("close_list_dialog_button", "id", "find close dialog button")->click();

});

$d->driver->close();
done_testing();

