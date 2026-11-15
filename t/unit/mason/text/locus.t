=head1 NAME

t/unit/mason/text/locus.t - locus templates: the text is shown in the user's language

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
    '/locus/associate_locus.mas',
    'Associate locus',
);

page_texts_ok(
    '/locus/associate_unigene.mas',
    'associate unigene',
    'Unigene ID:',
);

page_texts_ok(
    '/locus/efp_browser_links.mas',
    'Developmental Atlas',
    'Rose lab atlas',
    'Seedling view',
);

component_compiles_ok('/locus/index.mas');

page_texts_ok(
    '/locus/locus_unigenes.mas',
    '[loading...]',
);

page_texts_ok(
    '/locus/merge_locus.mas',
    'merge locus',
    'locus name',
);

page_texts_ok(
    '/locus/network.mas',
    '[loading...]',
);

page_texts_ok(
    '/locus/print_mrna_features.mas',
    'unprocessed genomic sequence region underlying this gene',
    'Genomic sequence',
);

page_texts_ok(
    '/locus/registry.mas',
    'Please enter the values for the new registry name below (* is required)',
    'Registry Description:',
    'associate registry',
    '*Registry Symbol:',
    'Add New Registry',
    '*Registry Name:',
);

page_texts_ok(
    '/locus/solcyc.mas',
    '[loading...]',
);

page_texts_ok(
    '/locus/synonym.mas',
    'Locus synonyms',
    '[Add/Remove]',
);

done_testing;
