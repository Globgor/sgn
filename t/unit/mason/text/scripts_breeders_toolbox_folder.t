=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_folder.t - scripts in the breeders_toolbox/folder templates: the script text is shown in the user's language

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
    '/breeders_toolbox/folder/edit_folder_name.mas',
    'An error occurred updating the folder name',
    'Successfully updated folder name',
);

page_script_texts_ok(
    '/breeders_toolbox/folder/folder_category_set.mas',
    'Categories set for folder!',
    'An error occurred',
);

page_script_texts_ok(
    '/breeders_toolbox/folder/folder_move.mas',
    'An error occurred trying to move folder.',
    'Cannot make a folder its own parent.',
);

page_script_texts_ok(
    '/breeders_toolbox/folder/folder_new.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/breeders_toolbox/folder/folder_set.mas',
    'An error occurred trying to associate a folder to the trial.',
    'Cannot make a folder its own parent.',
    '[ Protocol error. ]',
);

page_script_texts_ok(
    '/breeders_toolbox/folder/folders_edit.mas',
    'Error setting folder categories!',
);

done_testing;
