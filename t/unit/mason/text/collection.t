=head1 NAME

t/unit/mason/text/collection.t - collection templates: the text is shown in the user's language

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
    '/collection/add_files_to_collection_modal.mas',
    'Search collections by name...',
    'Add Files to Collection',
    'No collections found.',
    'Loading collections',
    'Cancel',
    'Add',
);

page_texts_ok(
    '/collection/add_to_collection_modal.mas',
    'Search your folders...',
    'Loading folders',
    'No folders yet.',
    'Add to Folder',
    'Cancel',
    'Save',
);

page_texts_ok(
    '/collection/collection.mas',
    'Collections grouped by breeding program, then project. Double click a collection to open it.',
    'Search collections by name, description, creator, or associated project.',
    'Contains file (name or comment):',
    'e.g. Gels from June extraction',
    'Show only my collections',
    'Collection description:',
);

page_texts_ok(
    '/collection/collection_details.mas',
    'Search by filename or description...',
    'Add Images to collection',
    'Collection Details',
    'Breeding program',
    'clear selection',
    'Add Selected',
);

page_texts_ok(
    '/collection/collections_tree.mas',
    'Double click a collection to view its detail page.',
    'Breeding Programs -- Collections',
    'Loading collections',
    '[loading...]',
    'Refresh',
    'Search',
);

page_texts_ok(
    '/collection/create_collection_modal.mas',
    'Breeding program',
    'Collection name',
    'Collection type',
    'New Collection',
    'Description',
    'No program',
);

done_testing;
