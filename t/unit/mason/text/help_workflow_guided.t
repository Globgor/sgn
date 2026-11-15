=head1 NAME

t/unit/mason/text/help_workflow_guided.t - help/workflow_guided templates: the text is shown in the user's language

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
    '/help/workflow_guided/begin.mas',
    'Print barcode labels for my experiment (for your plots or plants or tissue samples in the field, or for your 96 well plate and tissue samples)',
    'Upload an experimental field trial into the database that you have saved on your computer in Excel',
    'Upload phenotypic data into the database that you have saved on your computer in Excel',
    'Design a completely new experimental field trial in the database',
    'Prepare a 96 or 384 well plate for a genotyping experiment',
    'Upload crosses and crossing information into the database',
);

page_texts_ok(
    '/help/workflow_guided/phenotype_upload_modal.mas',
    'Workflow for uploading phenotypes',
    'Nothing Here Yet',
    'Close',
);

page_texts_ok(
    '/help/workflow_guided/seedlot_inventory_modal.mas',
    'I conducted an inventory (in weight(g)) and want to update the database to reflect the current state of the inventory.',
    'I have new seedlots that need to be added into the database.',
    'Workflow for seedlot inventory',
    'Close',
    'Go',
);

page_texts_ok(
    '/help/workflow_guided/tissue_sample_help.mas',
    'After you have finished sampling, you can use these entities as source material for a genotyping plate (96 or 384 well plate). Click the button below to create a genotyping plate now, if you will create a 96 or 384 well plate.',
    'You can print barcodes for the entities you intend to sample on. These barcodes can be attached to your collection vials/containers to assist during sampling.',
    'The Android Coordinate application can help you create 96 or 384 well plates. Alternatively you can create your plate layout in Excel and upload it.',
    'The tissue sample in a 96 well plate can originate from another tissue sample name, plant name, plot name, or accession name.',
    'Tissue Sample Level: Each tissue sample collected from the field has a unique identifier, ideally with a barcode label.',
    'Tissue samples collected from the field are linked to a single plant, which is in turn linked to a single plot.',
);

page_texts_ok(
    '/help/workflow_guided/trial_barcoding_modal.mas',
    'Workflow for trial barcoding',
    'Nothing Here Yet',
    'Close',
);

page_texts_ok(
    '/help/workflow_guided/trial_comparison_modal.mas',
    'Workflow for comparing one or many trials',
    'Nothing Here Yet',
    'Close',
);

done_testing;
