=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_trial_2.t - scripts in the breeders_toolbox/trial templates, part 2 of 5: the script text is shown in the user's language

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
    '/breeders_toolbox/trial/design_section_management_regime.mas',
    'Error retrieving management regime.',
    'Management factor submitted.',
    'Completion records',
    'Description',
    'Start Date',
    'End Date',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/download_layout_interface_dialog.mas',
    'An error occurred checking trial for plants or subplots.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/download_trials_phenotypes_dialog.mas',
    'No leaf nodes selected for download.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/edit_fieldMap.mas',
    'Analysis complete. Click below to correct spatial correlation on necessary traits.',
    'Moran P-value after spatial corrections',
    'Error calculating spatial correction.',
    'Error calculating spatial correction',
    'An error occurred replacing stock',
    'Error retrieving stocks.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/export_trial_to_expression_atlas.mas',
    'Project Name is required. This is the project name that will appear in the expression atlas.',
    'An error occurred exporting trial to Expression Atlas.',
    'Succesfully exported trial to Expression Atlas!',
    'Please select at least one trial.',
    'Export type is required.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/files_section.mas',
    'Could not load collections.',
    'Date Uploaded',
    'Uploaded By',
    'File Type',
    'Filename',
    'Options',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/generate_trial_barcode.mas',
    'Generate barcodes for Cross unique ids used in this trial',
    'Generate barcodes for family names used in this trial',
    'Generate barcodes for accessions used in this trial',
    'This crossing experiment has no female plant entry.',
    'This crossing experiment has no female plot entry.',
    'This crossing experiment has no male plant entry.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/genotype_comparison_workflow.mas',
    'Please select a genotyping protocol!',
    'Please select at least one trait!',
    'Error doing genotype comparison!',
    'Please give weights!',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/genotyping_trial_from_field_trial_linkage.mas',
    'Are you sure you want to remove the genotyping plate and field trial linkage? This operation cannot be undone.',
    'The genotyping plate link has been removed from the field trial.',
    'Error retrieving genotyping plate to field trial linkage.',
    'An error occurred!',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/greenhouse_add_additional_accessions_dialog.mas',
    'The list did not pass validation. Names in the list must be in the database',
    'An error occurred storing additional accessions for greenhouse trial.',
    'Please select an addition type',
    'Please select a list',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/jbrowse_instance.mas',
    'View the dataset for this trial in JBrowse',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/numerical_derivatives_row_and_column_workflow.mas',
    'Error doing numerical derivative!',
    'Please select at least one trait!',
    'Computed derivative and saved!',
);

done_testing;
