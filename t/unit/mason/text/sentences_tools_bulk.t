=head1 NAME

t/unit/mason/text/sentences_tools_bulk.t - tools/bulk templates: sentences appear in the user's language

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

page_sentences_ok(
    '/tools/bulk/display/bulk_gene_download.mas',
    'Download as {link}Fasta{end_link}',
);

page_sentences_ok(
    '/tools/bulk/display/buttons.mas',
    'Page {page} of {pages}',
);

page_sentences_ok(
    '/tools/bulk/display/feature_download.mas',
    'Download as {link}Fasta{end_link}',
);

page_sentences_ok(
    '/tools/bulk/display/summary_page.mas',
    'Please verify that you used the correct search and that you chose the right unigene or bac assembly to download from. Also make sure that the submitted identifiers are appropriately formatted.',
);

page_sentences_ok(
    '/tools/bulk/gene_download.mas',
    'Download as {link}Fasta{end_link}',
);

page_sentences_ok(
    '/tools/bulk/tabs/unigene_tab.mas',
    '{image}convert unigene list to current build',
);

done_testing;
