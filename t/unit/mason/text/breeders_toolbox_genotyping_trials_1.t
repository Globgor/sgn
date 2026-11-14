=head1 NAME

t/unit/mason/text/breeders_toolbox_genotyping_trials_1.t - breeders_toolbox/genotyping_trials templates, part 1 of 4: the text is shown in the user's language

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
    '/breeders_toolbox/genotyping_trials/create_genotyping_trial_dialogs.mas',
    'The "contents" of each well can be either a tissue sample, plant name, subplot name, plot name, or accession name. This "source" name must be in the database already. This is useful if you provide a field trial entity (such as a plot or subplot or plant or tissue sample name), so that phenotypes and genotypes can be directly compared.',
    'If you provided us with information about where the tissue sample in each well originated (e.g. it came from a plot name or a subplot name or plant name or tissue sample name in a field trial), we will automatically create linkage between the field trial(s) and this genotyping plate.',
    'Automatic submission to the Genotyping Facility currently not working. You can submit it from the Genotyping Plate\'s detail page or download the information from the Genotyping Plate\'s detail page and submit it yourself after clicking Submit',
    'If you choose to submit your genotyping plate to a genotyping facility (Cornell IGD, Intertek, BGI, etc) we can generate the files they require for you. Please be aware of their requirements, such as blank well positions and concentrations.',
    'Select a list for the source material going into each well. Your list should be a one to one pairing to each well e.g. if you want to fill 95 wells you should supply a list of 95 elements.',
    'Is your genotyping plate linked with field trials in the database? This information can also be added from the genotyping plate detail page once the trial is saved in the database.',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/delete_genotyping_plate.mas',
    'Do not delete a genotype layout for an experiment that has already been submitted to the sequencing facility.',
    'Delete all genotyping data derived from this genotyping plate.',
    'The genotyping data was deleted successfully.',
    'Do you want to delete this protocol?',
    'Delete Genotyping Plate Layout',
    'Delete genotyping plate layout',
);

component_compiles_ok('/breeders_toolbox/genotyping_trials/detail.mas');

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/download_genotyping_trial_layouts_dialogs.mas',
    'Download Breedbase Formatted File',
    'Download Genotyping Plate Layouts',
    'Download Intertek Formatted File',
    'Download DartSeq Formatted File',
    'Close',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/edit_genotyping_trial_details_dialog.mas',
    'Edit Genotyping Plate Details',
    'Error Saving Trial Details',
    'Indicates pending change',
    'Genotyping Plate Name:',
    'Genotyping Facility:',
    'Plate Sample Type:',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/files_section.mas',
    'Uploaded Additional Files',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/format/as_table.mas',
    '[LOADING...]',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/genotyping_trial_tree.mas',
    'Breeding Programs -- Folders -- Genotyping Plates',
    '[loading...]',
    'Information',
    'Refresh',
    'Search',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/layout.mas',
    '[LOADING...]',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/layout_as_list.mas',
    '[LOADING...]',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/plate_genotyping_data.mas',
    'sample name and accession name',
    'Number of Marker Scores',
    'Sample Unit Level:',
    'Sample Unit level',
    'Accession Name',
    'Description',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_trials/replace_plate_accessions_dialog.mas',
    'Well accession was replaced successfully...',
    'Replace Well Accession',
    'Enter New Accession:',
    'Accession:',
    'Sample ID:',
    'Sample:',
);

done_testing;
