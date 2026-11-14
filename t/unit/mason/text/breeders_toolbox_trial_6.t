=head1 NAME

t/unit/mason/text/breeders_toolbox_trial_6.t - breeders_toolbox/trial templates, part 6 of 7: the text is shown in the user's language

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
    '/breeders_toolbox/trial/trial_entry_numbers_template_dialog.mas',
    'Select Trial(s) to assign Entry Numbers',
    'Generate Entry Numbers Template',
    'Download Entry Number Template',
    'Change Trial Selections',
    'Generating Template...',
    'Download Template',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_entry_numbers_upload_dialog.mas',
    'Ignore Warnings - check to upload even if there are warnings with the file',
    'Trial Entry Numbers may be uploaded in an Excel file (.xls or .xlsx)',
    'The first row (header) must contain the following:',
    'Upload Trial Entry Numbers',
    'Column Definitions:',
    'Entry Numbers File:',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_nirs_data.mas',
    'Multiple Sample Graph',
    'Sample Name:',
    'Clear Graph',
    'Select',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_plants.mas',
    'Add selection to existing list',
    'Add selection to new list',
    'New list description...',
    'Delete selected plants',
    'Add plants to a list',
    'Select/Deselect All',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_plots.mas',
    'Add selection to existing list',
    'Add selection to new list',
    'New list description...',
    'Add plots to a list',
    'Select/Deselect All',
    'New list name...',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_raw_data.mas',
    'Traits recorded across observation levels',
    'Refresh Materialized Phenotype View',
    'Choose trait and observation level',
    'Number of Traits Measured',
    'Observation Level:',
    'Observation Level',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_soil_data.mas',
    'Trial Soil Data',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_status.mas',
    'This trial has plot and plant entries saved. This means that phenotypes can be recorded on the plot and plant level.',
    'This trial has a design type saved. You can view and download this information in the Design section on this page.',
    'Update Trial Status',
    'Has Field Design',
    'Trial Activities',
    'Field Design',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_stocks.mas',
    'Add stocks to a List',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_subplots.mas',
    'Add selection to existing list',
    'Add selection to new list',
    'Delete selected subplots',
    'New list description...',
    'Add subplots to a list',
    'Select/Deselect All',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_treatments.mas',
    'Get treatment data',
    'Add Treatments',
    'Tissue Sample',
    'Subplot',
    'Plant',
    'Plot',
);

page_texts_ok(
    '/breeders_toolbox/trial/trial_upload_dialogs.mas',
    'Seedlots tested in your experimental trial must exist in the database prior to adding your trial. The reason for this is that a seedlot can be tested in many trials and therefore exists as a separate entity in the database. We also want to be careful about adding new seedlots into the database because we do not want data to be incorrectly linked to duplicates.',
    'Accessions tested in your trial must exist in the database prior to adding your trial. The reason for this is that an accession can be tested in many trials and therefore exists as a separate entity in the database. We also want to be careful about adding new accessions into the database because we do not want incorrectly duplicated data.',
    'If you go on to collect tissue samples for creating a 96 well plate for genotyping, when adding the genotyping plate (96 well plate layout) to the database you can use plot names or plant names or tissue sample names from this field trial. By doing so, we can create linkage between this field trial and the genotyping plate.',
    'If you go on to perform crosses on this field trial, each cross can be linked to specific female and male plots. When you upload these crosses we can then automatically link this field trial to the crossing experiment in the database.',
    'Is your trial linked with other field trials, genotyping plates, or crossing experiments in the database? If you are unsure, you can skip this. This information can be added from the trial detail page after the trial is saved.',
    'Submit your trial again. You should have corrected all errors by now, but if not please take a look at the errors in the red box below. You can continue to modify your file and then click Upload until it works.',
);

done_testing;
