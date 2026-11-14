=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_cross_1.t - scripts in the breeders_toolbox/cross templates, part 1 of 2: the script text is shown in the user's language

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
    '/breeders_toolbox/cross/add_cross_dialogs.mas',
    'An error occurred getting female plots or plants.',
    'Please provide female parent name',
    'Please provide male parent name',
    'Please provide trial name',
    'No female plot',
    'No male plot',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/add_family_members_using_list_dialog.mas',
    'The list did not pass validation. Cross Unique IDs in the list must be uniquenames with cross stock type in the database',
    'An error occurred adding new family members',
    'Please select a list of crosses.',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/add_progenies_dialogs.mas',
    'An error occurred storing the progenies. None were uploaded.',
    'Please select a family type',
    'Please select a file',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/all_cross_entries.mas',
    'Female Genome Structure',
    'Male Genome Structure',
    'Crossing Experiment',
    'Number of Progenies',
    'Pollination Date',
    'Cross Unique ID',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/cross_wishlist.mas',
    'Creating cross wishlist files and sending information to ONA... This can take time...',
    'You must select a male trial! It can be the same trial as the female trial.',
    'The female accession list contains elements that are not accessions.',
    'The male accession list contains elements that are not accessions.',
    'A maximum of 60 male accessions can be selected for each cross!',
    'A maximum of 60 male plots can be selected for each cross!',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/crosses_in_crossingtrial.mas',
    'Cross Combination',
    'Cross Unique ID',
    'Female Parent',
    'Female Ploidy',
    'Female Plant',
    'Female Plot',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/crosses_in_family.mas',
    'Crossing Experiment',
    'Number of Progenies',
    'Cross Unique ID',
    'Cross Type',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/crossing_experiment_deletion.mas',
    'Are you sure you want to delete all crosses in this crossing experiment? The deletion cannot be undone.',
    'Are you sure you want to delete this crossing experiment? The deletion cannot be undone.',
    'Are you sure you want to delete this cross? The deletion cannot be undone.',
    'An error occurred during deletion',
    'Deletion was successful',
    'Cross Unique ID',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/family_deletion.mas',
    'Are you sure you want to delete this family? The deletion cannot be undone.',
    'An error occurred during removing cross member',
    'An error occurred during delete this family',
    'Are you sure you want to remove this cross?',
    'The family was deleted',
    'The cross was removed',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/index.mas',
    'Really delete this cross? This action cannot be undone.',
    'Deletion was successful.',
    'An error occurred.',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/intercross_file_info.mas',
    'Create Date',
    'Created By',
    'File Type',
    'Filename',
    'Options',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/intercross_file_upload.mas',
    'Please select your cross ID format',
    'Please select a file',
);

done_testing;
