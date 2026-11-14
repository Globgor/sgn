=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_trial_5.t - scripts in the breeders_toolbox/trial templates, part 5 of 5: the script text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form, as a JSON string inside a script. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_script_texts_ok component_compiles_ok );

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_stocks.mas',
    'Stock Species',
    'Stock Name',
    'Stock Type',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_stocks_count.mas',
    'Error displaying accession count',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_subplots.mas',
    'Are you sure you want to delete the selected subplots? Any child stocks, such as plants or tissue samples, will also be deleted. This action cannot be undone.',
    'The new list was created, but a server error occurred adding items to it.',
    'A server error occurred making new list.',
    'A server error occurred, check console.',
    'Server error adding subplots to list.',
    'Subplots added to list.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_tissue_samples.mas',
    'Error retrieving tissue samples.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_tissue_sources.mas',
    'Error retrieving tissue sources.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_treatments.mas',
    'An error occurred deleting treatment data.',
    'Delete treatment data from all stocks?',
    'Error retrieving treatments.',
    'Treatment data removed.',
    'Total Stock Count',
    'Remove treatment',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/update_experimental_design_type.mas',
    'An error occurred updating trial status',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/update_trial_status_dialog.mas',
    'An error occurred updating trial status',
    'Please select a date',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/upload_additional_file.mas',
    'Are you sure you want to obsolete this file? This operation cannot be undone.',
    'Error retrieving additional uploaded files.',
    'No file collections available',
    'The file has been obsoleted.',
    'Select a collection',
    'An error occurred!',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/upload_plot_gps_dialogs.mas',
    'File uploaded successfully',
    'Please select a file',
    'No file selected',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/upload_soil_data_dialogs.mas',
    'Please indicate type of sampling',
    'Please provide description',
    'Please select a date',
    'Please select a file',
);

done_testing;
