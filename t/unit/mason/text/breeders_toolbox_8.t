=head1 NAME

t/unit/mason/text/breeders_toolbox_8.t - breeders_toolbox templates, part 8 of 10: the text is shown in the user's language

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

component_compiles_ok('/breeders_toolbox/trial.mas');

component_compiles_ok('/breeders_toolbox/trial_trait.mas');

page_texts_ok(
    '/breeders_toolbox/trialtree.mas',
    'Breeding Programs -- -- Trials',
    'Download Trial',
    '[loading...]',
    'Information',
);

page_texts_ok(
    '/breeders_toolbox/trialtreefolders.mas',
    'Select multiple folders by holding \'Ctrl\'.',
    'Select multiple trials by holding \'Ctrl\'.',
    'Breeding Programs -- Folders -- Trials',
    'First Select Trial(s) to Download',
    'First Select Folder(s) to Edit',
    'Download Trial Phenotypes',
);

page_texts_ok(
    '/breeders_toolbox/upload_accession_rename_dialog.mas',
    'Accession renaming information may be uploaded in tab-delimited text file format',
    'The first row (header) should contain the following:',
    'The accession renaming list upload was successful.',
    'Store old names as synonyms of the accessions',
    'Upload Rename Accessions Information',
    'Upload Rename Accessions File:',
);

page_texts_ok(
    '/breeders_toolbox/upload_derived_accessions_dialog.mas',
    'The first row (header) should contain the following:',
    'Upload Template Information For Derived Accessions',
    'The derived accessions were saved successfully.',
    'Upload Derived Accessions Error',
    'Upload Derived Accessions',
    'File format information',
);

page_texts_ok(
    '/breeders_toolbox/upload_graft_dialogs.mas',
    'Graft may be uploaded in tab-delimited text file format',
    'The first row (header) should contain the following:',
    'The graft upload was successful.',
    'Upload Grafting Information',
    'File format information',
    'Results From Validation',
);

page_texts_ok(
    '/breeders_toolbox/upload_images.mas',
    'The "Associated Images" format is useful for uploading a zipfile of images in association with phenotype values.',
    'There should only be one barcode in each image, and the associated stock must already exist in the database.',
    'The phenotype values should be included in a .xls or .xlsx spreadsheet with the following columns:',
    'Upload multiple selected images that contain a barcode with a stock ID.',
    'Select multiple images directly for upload.',
    'Images with Associated Phenotypes:',
);

page_texts_ok(
    '/breeders_toolbox/upload_locations_dialogs.mas',
    'The first row (header) must contain the following:',
    'Optional values:',
    'Required values:',
    'Upload Locations',
    'Location File:',
    'Header:',
);

page_texts_ok(
    '/breeders_toolbox/upload_nirs_spreadsheet_dialogs.mas',
    'All other columns are required wavelengths. You can add how many columns you want upload -- there is no limit.',
    'With this model is possible to upload NIRS data just need to follow these columns',
    'Template for Upload NIRS .csv:',
    'Upload NIRS .csv template',
    'File format information',
    'Upload NIRS Spreadsheet',
);

page_texts_ok(
    '/breeders_toolbox/upload_pedigrees_dialogs.mas',
    'To Overwrite Parents In the Case That An Accession Already Has Male or Female Parents',
    'The first row (header) should contain the following:',
    'The Pedigree Upload Finished With No Errors.',
    'cross type descriptions:',
    'File format information',
    'Results From Validation',
);

done_testing;
