=head1 NAME

t/unit/mason/text/qtl_population.t - qtl/population templates: the text is shown in the user's language

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
    '/qtl/population/data_access.mas',
    'Data access',
);

page_texts_ok(
    '/qtl/population/download.mas',
    'Download',
);

page_texts_ok(
    '/qtl/population/genetic_map.mas',
    'Genetic map',
);

component_compiles_ok('/qtl/population/index.mas');

page_texts_ok(
    '/qtl/population/stat_tools.mas',
    'Please proceed with your QTL analysis of your trait of interest.',
    'Set your own QTL analysis parameters',
    'Use default QTL parameters',
);

page_texts_ok(
    '/qtl/population/traits_list.mas',
    'Analyze QTLs',
);

done_testing;
