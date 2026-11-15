=head1 NAME

t/unit/mason/text/breeders_toolbox_trial_2.t - breeders_toolbox/trial templates, part 2 of 7: the text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_texts_ok component_compiles_ok );

page_texts_ok(
    '/breeders_toolbox/trial/add_trial_used_seedlots.mas',
    'For plots of family name stock type, seedlots of cross members in the family can be used.',
    'This is for recording which seedlots were planted in which plots in this trial.',
    'The first row (header) should contain the following:',
    'Upload Used Seedlots in Trial',
    'File uploaded successfully.',
    'Upload Template Information',
);

page_texts_ok(
    '/breeders_toolbox/trial/change_plot_accessions_dialogs.mas',
    'It is not recommended to change accessions/cross_unique_ids/family_names at this point. Are you sure?',
    'One or more traits have been assayed for this trial;',
    'Accessions were not changed due to these errors:',
    'Plot accession was replaced successfully.',
    'Error Changing Plot Accessions',
    'Replace Plot Accessions',
);

page_texts_ok(
    '/breeders_toolbox/trial/correlation_workflow.mas',
    'Find Correlation Between Saved Measurements',
    'Select the input measurements to correlate',
    'Observation Unit Level:',
    'Correlation Method:',
    'Analysis Instance',
    'Trait(s):',
);

page_texts_ok(
    '/breeders_toolbox/trial/create_datacollector_dialog.mas',
    'Data Level:',
    'Trait List:',
    'Plants',
    'Submit',
    'Close',
    'Plots',
);

page_texts_ok(
    '/breeders_toolbox/trial/create_spreadsheet_dialog.mas',
    'Include Notes Column',
    'Leave blank for all',
    'Plants and Subplots',
    'Spreadsheet Format:',
    'Associated Images',
    'Sample Number:',
);

page_texts_ok(
    '/breeders_toolbox/trial/crossing_experiment_from_field_trial_linkage.mas',
    'Crossing Experiment(s) From This Field Trial',
);

page_texts_ok(
    '/breeders_toolbox/trial/derived_trait.mas',
    'Calculate Plot Phenotypes from Plant Phenotypes',
    'Generate Plot Phenotypes from Plant Phenotypes',
    'Overwrite Previous Plot Values for this Trait:',
    'The trait was created and saved successfully',
    'Always round down to nearest integer',
    'Always round up to nearest integer',
);

page_texts_ok(
    '/breeders_toolbox/trial/design.mas',
    '[LOADING...]',
);

page_texts_ok(
    '/breeders_toolbox/trial/design_section.mas',
    'Upload subplot entries using number of subplots per plot',
    'Upload plant entries using number of plants per subplot',
    'Upload subplot entries using subplot index number',
    'Upload plant entries using plant index number',
    'Add tissue sample entries',
    'Summary of Stock Entries',
);

page_texts_ok(
    '/breeders_toolbox/trial/design_section_management_factor.mas',
    'Tissue Sample Entries',
    'Accessions Planted',
    'Plant Entries',
    'Controls',
    'Subplots',
    'Plots',
);

page_texts_ok(
    '/breeders_toolbox/trial/design_section_management_regime.mas',
    'Add management factor',
);

page_texts_ok(
    '/breeders_toolbox/trial/download_layout_interface_dialog.mas',
    'Choose the columns you want to include (Or simply use defaults and click "Submit")',
    'Include summary of overall accession performance (for a list of traits):',
    'The field book layout file(s) were saved successfully',
    'Include existing plot phenotypes:',
    '--Select plot order--',
    '--Select start plot--',
);

done_testing;
