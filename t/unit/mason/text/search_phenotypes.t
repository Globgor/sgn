=head1 NAME

t/unit/mason/text/search_phenotypes.t - search/phenotypes templates: the text is shown in the user's language

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

component_compiles_ok('/search/phenotypes/qtl.mas');

page_texts_ok(
    '/search/phenotypes/stock.mas',
    'Copy items on this page to list:',
    'Search Accessions and Plots',
    'Search results',
    'Search',
);

page_texts_ok(
    '/search/phenotypes/traits.mas',
    'Search and browse tree of traits',
);

done_testing;
