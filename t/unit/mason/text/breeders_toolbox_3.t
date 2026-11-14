=head1 NAME

t/unit/mason/text/breeders_toolbox_3.t - breeders_toolbox templates, part 3 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/derived_accession_usage_info_dialog.mas',
    'In some cases, you may want to add new accession names that have special relationships to other stock types in the database. For example, after preliminary phenotypic screening of progenies derived from different crosses in a trial, you may want to add new accession names for some plants in that trial.',
    'Relationship between each derived accession and its source is displayed on the accession detail page and its source detail page (accession/plant/tissue sample)',
    'The derived accession (stored as accession stock type) can be linked to another accession, or plant or tissue sample in the database.',
    'Linkage between derived accession, direct source and original source:',
    'How to add derived accessions:',
    'What are derived accessions:',
);

page_texts_ok(
    '/breeders_toolbox/discard_seedlots.mas',
    'The seedlots were marked as DISCARDED.',
    'Mark Seedlots as Discarded',
    'Reason for Discarding:',
    'List of Seedlots:',
    'Close & Reload',
    'Required',
);

page_texts_ok(
    '/breeders_toolbox/discard_single_seedlot.mas',
    'This seedlot was marked as DISCARDED.',
    'Mark this Seedlot as DISCARDED',
    'This seedlot was restored.',
    'Reason for Discarding:',
    'Close & Reload',
    'Seedlot Name:',
);

page_texts_ok(
    '/breeders_toolbox/discard_undo_seedlot_usage.mas',
    'Deleting a seedlot permanently removes that seedlot and all associated transactions from database. Discarding a seedlot inactivates the seedlot, but information related to that seedlot is still kept in the database.',
    'Using a List: Several seedlots can be discarded at once by using a list with seedlots list type. The link can be found at the buttom of Manage Seedlots (Available Seedlots) page.',
    'Discarded seedlots still can be viewed in seedlot details pages and are searchable. However, links for adding new transaction, editing details and transaction are removed.',
    'Discarding a seedlot can be reversed with UNDO function, but deletion a seedlot cannot be undone.',
    'Discarded seedlot can be reversed by using UNDO option at the buttom of Seedlot Details page',
    'Only users with curator role can mark seedlots as "DISCARDED" or undo discarding seedlots.',
);

page_texts_ok(
    '/breeders_toolbox/download.mas',
    'Choose a list for each parameter and click "Download".',
    'Download Crosses and Families of Progenies',
    'Include Accession Entry Numbers:',
    'Download Phenotypes Using Lists',
    'Download Accession Properties',
    'Include Intercrop Accessions:',
);

page_texts_ok(
    '/breeders_toolbox/drone_run_project.mas',
    'View and edit the public data agreement on this experiment.',
    'View basic information about the imaging event project.',
    'Edit Imaging Event Details',
    'Imaging Event Name:',
    'Description:',
    'Save Changes',
);

component_compiles_ok('/breeders_toolbox/file_list.mas');

page_texts_ok(
    '/breeders_toolbox/genotype_data_project.mas',
    'View information about genotyping plates in this project or move genotyping plates to this project.',
    'Delete genotyping project, genotyping plates and/or genotyping data associated with this project.',
    'View basic information about the genotyping protocols used in this genotyping project.',
    'Download archived VCF files associated with this genotyping project.',
    'View and edit the public data agreement on this experiment.',
    'View basic information about the genotyping project.',
);

page_texts_ok(
    '/breeders_toolbox/home.mas',
    'Create files for the Android Fieldbook app, upload files from Fieldbook to the database.',
    'Download phenotypic and genotypic data by trial, triat and location.',
    'Upload phenotype information for accessions in the database.',
    'Manage accessions. Add new accessions using fuzzy matching.',
    'Manage trials. Add new trials and create field layouts.',
    'Download barcodes for accessions and plots.',
);

page_texts_ok(
    '/breeders_toolbox/image_analysis_run.mas',
    'View basic information about this image analysis run.',
    'No per-image results are stored for this run.',
    'Image Analysis Results by Image',
    'Loading images…',
    'Run Details',
);

page_texts_ok(
    '/breeders_toolbox/image_analysis_run_details.mas',
    'Click a filename to jump to that image\'s results below.',
    'Pipeline Details',
    'Pipeline Version',
    'Analyzed Images',
    'Images Analyzed',
    'Loading images…',
);

page_texts_ok(
    '/breeders_toolbox/index.mas',
    'SNP Tool (coming soon)',
    'SGN Breeders Toolbox',
    'Tools in development',
    'Access QTL data',
    'Potato genome',
    'Tomato genome',
);

done_testing;
