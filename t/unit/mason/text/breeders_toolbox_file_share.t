=head1 NAME

t/unit/mason/text/breeders_toolbox_file_share.t - breeders_toolbox/file_share templates: the text is shown in the user's language

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
    '/breeders_toolbox/file_share/file_dump_share_files.mas',
    'File Name',
    'User Name',
    'Options',
    'Date',
);

page_texts_ok(
    '/breeders_toolbox/file_share/manage_file_share_dump.mas',
    'Note, this is to upload unstructured data. Please continue to upload structured data into the actual database in order to use the organizational and analysis tools in Breedbase.',
    'View and download shared data files. Note that these are unstructured data files; please upload structured data into database!',
    'Select a file from your computer to upload to the file dump to share.',
    'Upload File to Share',
    'File Share Dump',
    'Upload File:',
);

done_testing;
