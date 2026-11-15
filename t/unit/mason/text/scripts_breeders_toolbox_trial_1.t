=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_trial_1.t - scripts in the breeders_toolbox/trial templates, part 1 of 5: the script text is shown in the user's language

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
    '/breeders_toolbox/trial/accession_rank_workflow.mas',
    'Please select at least one trait!',
    'Error doing accessions rank!',
    'Please give weights!',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/add_plants_per_plot.mas',
    'Only one plant per (row, column) coordinate is allowed. You must specify fewer plants per plot, or add rows and columns.',
    'You need to specify the number of rows and columns to give plant coordinates within plots.',
    'An error occurred saving plant entries',
    'Successfully created plant entries.',
    'File uploaded successfully',
    'Please select a file',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/add_plants_per_subplot.mas',
    'Only one plant per (row, column) coordinate is allowed. You must specify fewer plants per plot, or add rows and columns.',
    'You need to specify the number of rows and columns to give plant coordinates within plots.',
    'An error occurred saving plant entries',
    'Successfully created plant entries.',
    'File uploaded successfully',
    'Please select a file',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/add_subplots_per_plot.mas',
    'An error occurred saving subplot entries',
    'Successfully created subplot entries.',
    'File uploaded successfully',
    'Please select a file',
    'No file selected',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/add_tissue_sample_per_plant.mas',
    'Please check the Experimental Linkage section to see if this trial is linked to a Genotyping Plate already! You may not need to create new tissue samples for your use case!',
    'An error occurred creating tissue sample entries',
    'Successfully created tissue sample entries.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/add_trial_used_seedlots.mas',
    'Please select a file',
    'No file selected',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/change_plot_accessions_dialogs.mas',
    'An error occurred changing plot accessions',
    'Please select a file',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/correlation_workflow.mas',
    'Please select at least one trait!',
    'Error doing correlation!',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/create_datacollector_dialog.mas',
    'An error occurred creating a DataCollector file.',
    'You must select a Trait List first',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/create_spreadsheet_dialog.mas',
    'An error occurred creating a phenotype file.',
    'You must select a Trait List first',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/crossing_trial_from_field_trial_linkage.mas',
    'Error retrieving crossing experiment to field trial linkage.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/design.mas',
    'Error retrieving design.',
);

done_testing;
