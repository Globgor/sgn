=head1 NAME

t/unit/mason/text/vectorviewer.t - vectorviewer templates: the text is shown in the user's language

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
    '/vectorviewer/vectorviewer.mas',
    'The VectorViewer appears in a section in the vector detail page and can be used to visualize the vector, as well as edit aspects of the vector annotation.',
    'More information is available in the Breedbase manual.',
    'To save edits, please click on the Save button.',
    'Quick Instructions for the VectorViewer',
    'Add/Edit a restriction enzyme site',
    'VectorViewer Quick Instructions',
);

done_testing;
