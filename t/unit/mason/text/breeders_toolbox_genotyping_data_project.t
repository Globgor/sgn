=head1 NAME

t/unit/mason/text/breeders_toolbox_genotyping_data_project.t - breeders_toolbox/genotyping_data_project templates: the text is shown in the user's language

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
    '/breeders_toolbox/genotyping_data_project/add_existing_genotyping_plate_dialog.mas',
    'The genotyping plates were added successfully',
    'Move Genotyping Plate(s) to this Project',
    'Move Genotyping Plate to Project Error',
    'Save genotyping plate to a project',
    'Genotyping Project:',
    'Genotyping Plates:',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/create_genotyping_project_dialog.mas',
    'Genotyping Project can be used to group a series of genotyping plates and genotyping data. Genotyping Project should match Vendor Project if you have one.',
    'You may want to proceed to add genotyping plates and/or genotyping data in the genotyping project you just created.',
    'Finished! Your genotyping project is now in the database',
    'Enter basic information about the genotyping project',
    'Should match Vendor Project if you have one',
    'Location of Data Generation (optional):',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/details.mas',
    'Genotyping Project Name',
    'Genotyping Facility',
    'Breeding Program',
    'Description',
    'Created by',
    'Data Type',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/edit_genotyping_project_details_dialog.mas',
    'Error Saving Genotyping Project Details',
    'Edit Genotyping Project Details',
    'Genotyping Project Name:',
    'Indicates pending change',
    'Breeding Program:',
    'Close & Reload',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotype_archived_vcf.mas',
    'Date Uploaded',
    'Uploaded By',
    'File Name',
    'Options',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotype_data.mas',
    'Number of Marker Scores',
    'Refresh results',
    'Accession Name',
    'Description',
    'Sample Name',
    'Sample Type',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotyping_plates.mas',
    'Number of Samples',
    'Description',
    'Sample Type',
    'Plate Name',
    'Download',
    'Format',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotyping_project_deletion.mas',
    'Delete all genotyping plates in this project',
    'Delete Genotyping Protocol and All Data',
    'Delete Genotyping Project Data',
    'Delete Genotyping Plate(s)',
    'Delete Genotyping Project',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotyping_project_tree.mas',
    'Breeding Programs -- Folders -- Genotyping Projects',
    'Select multiple folders by holding \'Ctrl\'.',
    'Move genotyping project(s) to folder',
    'First Select Folder(s) to Edit',
    'Create new folder',
    'Edit Folder(s)',
);

component_compiles_ok('/breeders_toolbox/genotyping_data_project/manage_genotyping_projects.mas');

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/pcr_genotype_data.mas',
    'Download SSR Genotype Data',
    'Sample Name',
    'Sample Type',
    'Ploidy',
    'Close',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_data_project/protocols.mas',
    'Header Information Lines',
    'Number of Markers',
    'Reference Genome',
    'Species Name',
    'Description',
    'Marker Type',
);

done_testing;
