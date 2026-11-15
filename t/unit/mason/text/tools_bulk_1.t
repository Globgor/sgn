=head1 NAME

t/unit/mason/text/tools_bulk_1.t - tools/bulk templates, part 1 of 2: the text is shown in the user's language

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
    '/tools/bulk/converter.mas',
    'Paste the identifiers you would like to convert',
    'Affymetrix Chip Identifiers',
    'TOM Microarray Identifiers',
    'Gene models (ITAG 2.3)',
    'Bulk Converter',
    'Input is:',
);

page_texts_ok(
    '/tools/bulk/display/bulk_gene.mas',
    'Enter a list of gene identifier or upload a file containing one identifier separated by whitespace (returns, spaces or tabs):',
    'Download gene information',
    'And/or upload list file:',
    'Protein sequence',
    'cDNA sequence',
    'CDS sequence',
);

page_texts_ok(
    '/tools/bulk/display/bulk_gene_download.mas',
    'Your query was successful.',
    'Gene Download Summary',
);

page_texts_ok(
    '/tools/bulk/display/buttons.mas',
    'New query',
);

page_texts_ok(
    '/tools/bulk/display/buttons/next.mas',
    'Next Page',
);

page_texts_ok(
    '/tools/bulk/display/buttons/previous.mas',
    'Previous Page',
);

page_texts_ok(
    '/tools/bulk/display/buttons/summary.mas',
    'Summary Page',
);

page_texts_ok(
    '/tools/bulk/display/feature_download.mas',
    'Your query was successful.',
    'Feature Download Summary',
);

page_texts_ok(
    '/tools/bulk/display/features.mas',
    'Enter a list of feature identifier or upload a file containing one identifier separated by whitespace (returns, spaces or tabs):',
    'Download feature information',
    'And/or upload list file:',
    'feature sequence',
    'Example:',
    'Submit',
);

page_texts_ok(
    '/tools/bulk/display/summary_page.mas',
    'Please try your search again.',
    'Bulk download summary',
);

page_texts_ok(
    '/tools/bulk/gene_download.mas',
    'Your query was successful.',
    'Gene Download Summary',
);

page_texts_ok(
    '/tools/bulk/index.mas',
    'Bulk Download',
    'Converter',
    'BAC ends',
    'Features',
    'Unigenes',
    'Arrays',
);

done_testing;
