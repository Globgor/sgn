=head1 NAME

t/unit/mason/text/search_cross.t - search/cross templates: the text is shown in the user's language

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
    '/search/cross/cross_search_section.mas',
    'Search Cross Details Using Male Parents / Populations',
    'Search Cross Details Using Female Parents',
);

page_texts_ok(
    '/search/cross/cross_search_using_female.mas',
    'Search Cross Details Using Female Parents',
    'Choose female parent first',
    'Male Parent / Population:',
    'Male Parent / Population',
    'Copy crosses to a List',
    'Crossing Experiment',
);

page_texts_ok(
    '/search/cross/cross_search_using_male.mas',
    'Search Cross Details Using Male Parents / Populations',
    'Male Parent / Population:',
    'Choose male parent first',
    'Male Parent / Population',
    'Copy crosses to a List',
    'Crossing Experiment',
);

page_texts_ok(
    '/search/cross/parent_search.mas',
    'Select a list of accessions:',
    'Select a list of accessions',
    'Search Results',
    'Parents',
);

page_texts_ok(
    '/search/cross/progeny_search_section.mas',
    'Search Progenies of Male Parents / Populations',
    'Search Progenies of Female Parents',
);

page_texts_ok(
    '/search/cross/progeny_search_using_female.mas',
    'All Progenies of this Female Parent',
    'Search Progenies of Female Parents',
    'Choose female parent first',
    'Progenies of these Parents',
    'Male Parent / Population:',
    'Copy Progenies to a List',
);

page_texts_ok(
    '/search/cross/progeny_search_using_male.mas',
    'Search Progenies of Male Parents / Populations',
    'All Progenies of this Male Parent',
    'Progenies of these Parents',
    'Male Parent / Population:',
    'Choose male parent first',
    'Copy Progenies to a List',
);

done_testing;
