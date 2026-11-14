=head1 NAME

t/unit/mason/text/breeders_toolbox_6.t - breeders_toolbox templates, part 6 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/manage_genotype_qc.mas',
    'The steps below will guide you through uploading a new fingerprint or performing a quality control.',
    'The intertek quality control marker sets can be used in 2 ways:',
    'Upload Genotyping Data (VCF or Intertek Format)',
    'Only CSV file format is supported',
    'Run Genotype Quality Control',
    'sample grid file',
);

component_compiles_ok('/breeders_toolbox/manage_genotyping.mas');

page_texts_ok(
    '/breeders_toolbox/manage_images.mas',
    'Images are linked to observation units (plots, plants, tissue samples)',
    'Upload a zip file of images alongside phenotype values.',
    'Image descriptors (name, description, or filename):',
    'How images are linked, and how to upload them',
    'No image analysis runs have been saved yet.',
    'Select multiple images directly for upload.',
);

page_texts_ok(
    '/breeders_toolbox/manage_locations.mas',
    'Copy Locations to a List',
    'Manage Locations',
    'Location Table',
    'Location Map',
);

page_texts_ok(
    '/breeders_toolbox/manage_nirs.mas',
    'Manage NIRS Data',
);

page_texts_ok(
    '/breeders_toolbox/manage_odk_data_collection.mas',
    'ONA is currently being used for collecting crossing information. This requires exporting a crossing plan from here to the ONA server. The crossing plan guides collection of cross information and this data is synched with ONA using ODK. From here, we run a script twice a day, which pulls data on ONA into our database.',
    'Import Crossing Data from Selected Form on ONA',
    'Crossing Data: ONA ODK Application',
    'Summary of Received Plant Status',
    'What do I do from this page?',
    'Manage ODK Data Collection',
);

page_texts_ok(
    '/breeders_toolbox/manage_phenotyping.mas',
    'These files will not be shown anywhere else on the website',
    'Manage Phenotypic Data',
    'Your Obsoleted Files',
    'Your Uploaded Files',
);

page_texts_ok(
    '/breeders_toolbox/manage_plot_phenotyping.mas',
    'Enter a List of Trait Names:',
    'Manage Plot Phenotyping',
    'Or Paste From a List:',
    'Enter trait value:',
    'Or Use Trait List:',
    'Traits assayed',
);

page_texts_ok(
    '/breeders_toolbox/manage_populations_dialogs.mas',
    'Choose a List of Accessions to Add:',
    'Choose a List of Members to Add:',
    'Choose a List of Plants to Add:',
    'Choose a List of Plots to Add:',
    'Select a member type',
    'Create A Population',
);

component_compiles_ok('/breeders_toolbox/manage_projects.mas');

page_texts_ok(
    '/breeders_toolbox/manage_roles.mas',
    'Manage User Roles',
    '[LOADING...]',
    'Submit',
    'Close',
    'Role:',
    'Roles',
);

page_texts_ok(
    '/breeders_toolbox/manage_samples.mas',
    'View and create tissue samples for genotyping plates. Genotyping plates represent tissue samples in a 96 or 384 well plate layout.',
    'View and create tissue samples for field trials. Tissue samples come from a plant in a plot.',
    'View and create tissue samples for generic sampling trials.',
    'Manage Tissue Samples',
);

done_testing;
