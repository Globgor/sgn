=head1 NAME

t/unit/mason/text/search_markers.t - search/markers templates: the text is shown in the user's language

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
    '/search/markers/results.mas',
    'Markers From Genotype Projects',
    'Marker Search Results',
    'Modify Marker Search',
    'Markers from Maps',
    'Next',
    'Prev',
);

page_texts_ok(
    '/search/markers/search.mas',
    'Reference Genome / Map:',
    'Additional Filters',
    'Filter By Position',
    'Filter By Name',
    'Marker Search',
    'Marker Name:',
);

done_testing;
