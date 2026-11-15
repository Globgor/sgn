=head1 NAME

t/unit/mason/text/breeders_toolbox_1.t - breeders_toolbox templates, part 1 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/add_accessions_dialogs.mas',
    'When checked, add synonyms of existing accession entries to the synonyms already stored in the database.  When not checked, remove any existing synonyms of existing accession entries and store only the synonyms in the upload file.',
    'Note: Use the fuzzy search to match similar names to prevent uploading of duplicate accessions. Fuzzy searching is much slower than regular search. Only a curator can disable the fuzzy search.',
    'Note: Use the fuzzy search to match similar names to prevent uploading of duplicate accessions. Fuzzy searching is much slower than regular search.',
    'When checked, automatically create a new accession list with the accessions in your upload file.',
    'The following accessions are new and will be added to the database:',
    'The following accessions already exist in the database:',
);

page_texts_ok(
    '/breeders_toolbox/add_derived_accessions_using_list_dialog.mas',
    'Description provided will be stored as description for the specify derived accession',
    'Add New Accessions Derived from Accessions/Plants/Tissue Samples Using a List',
    'List must be accessions, plants or tissue samples list type',
    'Derived accession names must not exist in the database',
    'New derived accessions were added successfully',
    'Names in the list must exist in the database',
);

done_testing;
