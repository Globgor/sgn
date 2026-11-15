=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_trial_4.t - scripts in the breeders_toolbox/trial templates, part 4 of 5: the script text is shown in the user's language

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
    '/breeders_toolbox/trial/trial_entry_numbers.mas',
    'Are you sure you would like to remove the entry numbers from this trial? This action cannot be undone.',
    'ERROR: Could not load entry numbers due to a server error!',
    'An error occurred deleting the entry numbers.',
    'Success!',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_entry_numbers_template_dialog.mas',
    'ERROR: Could not generate upload template!',
    'Please select at least one Trial',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_entry_numbers_upload_dialog.mas',
    'ERROR: Could not upload and process file due to server error!',
    'Please select a file',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_nirs_data.mas',
    'An error occurred while fetching data',
    'Please select one protocol.',
    'Plot on Large Graph',
    'Spectra Graph',
    'Sample Name',
    'Accession',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_plants.mas',
    'Are you sure you want to delete the selected plants? Any associated tissue samples will also be deleted. This action cannot be undone.',
    'The new list was created, but a server error occurred adding items to it.',
    'A server error occurred making new list.',
    'A server error occurred, check console.',
    'Server error adding plants to list.',
    'Plants added to list.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_plots.mas',
    'The new list was created, but a server error occurred adding items to it.',
    'A server error occurred making new list.',
    'Server error adding plots to list.',
    'Plots added to list.',
    'An error occurred',
    'List created.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_plots_count.mas',
    'Error displaying plots count',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_raw_data.mas',
    'An error occurred while processing the request.',
    'Server error, check console.',
    'observation variable',
    'observation unit',
    'value, timestamp',
    'observation id',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_seedlots.mas',
    'Error retrieving plots.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_seedlots_count.mas',
    'Error displaying seedlots count',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_soil_data.mas',
    'Are you sure you want to delete this soil data id. The deletion cannot be undone.',
    'An error occurred during deletion',
    'Deletion was successful',
    'Type of Sampling',
    'Soil Data ID',
    'Description',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_status.mas',
    'Error retrieving trial completion phenotype section',
    'Error retrieving trial completion layout section',
);

done_testing;
