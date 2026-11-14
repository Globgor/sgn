=head1 NAME

t/unit/mason/text/sentences_search_phenotypes.t - search/phenotypes templates: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

component_compiles_ok('/search/phenotypes/qtl.mas');

page_sentences_ok(
    '/search/phenotypes/traits.mas',
    'Browse trait terms using the expandable tree below, or use the search boxes to find traits by exact ID or by searching their descriptions.',
);

done_testing;
