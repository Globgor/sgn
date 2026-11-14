=head1 NAME

t/unit/mason/text/breeders_toolbox_folder.t - breeders_toolbox/folder templates: the text is shown in the user's language

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
    '/breeders_toolbox/folder/edit_folder_name.mas',
    'Close',
    'Save',
);

page_texts_ok(
    '/breeders_toolbox/folder/folder.mas',
    'Folder For Transformation Projects',
    'Download Genotyping Plate Layouts',
    'Tracking Activities Project Name',
    'Folder For Genotyping Projects',
    'Folder For Tracking Activities',
    'Genotyping Projects in Folder',
);

page_texts_ok(
    '/breeders_toolbox/folder/folder_category_set.mas',
    'Folder for Genotyping Projects:',
    'Folder for Genotyping Plates:',
    'Folder for Crosses:',
    'Folder for Trials:',
    'Close',
    'Save',
);

page_texts_ok(
    '/breeders_toolbox/folder/folder_move.mas',
    'The folder was moved successfully',
    'Folder Move Successful',
    'Breeding Program:',
    'Parent Folder:',
    'Folder Name:',
    'Move folder',
);

page_texts_ok(
    '/breeders_toolbox/folder/folder_new.mas',
    'The folder was created successfully',
    'New Folder Successful',
    'Breeding Program:',
    'Save new folder',
    'Parent Folder:',
    'Folder Name:',
);

page_texts_ok(
    '/breeders_toolbox/folder/folder_set.mas',
    'Save a trial to a folder',
    'Breeding Program:',
    'Close',
    'Save',
);

page_texts_ok(
    '/breeders_toolbox/folder/folders_edit.mas',
    'Folder(s) for Genotyping Projects:',
    'Folder(s) for Genotyping Plates:',
    'Edit Selected Folder(s)',
    'Folder(s) for Crosses:',
    'Folder(s) for Trials:',
    'Close',
);

done_testing;
