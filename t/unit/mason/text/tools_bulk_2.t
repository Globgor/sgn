=head1 NAME

t/unit/mason/text/tools_bulk_2.t - tools/bulk templates, part 2 of 2: the text is shown in the user's language

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
    '/tools/bulk/tabs/array_tab.mas',
    'Enter a list of identifiers or upload a file containing one identifier:',
    'And/or upload list file:',
    'Example:',
    'Submit',
);

page_texts_ok(
    '/tools/bulk/tabs/bac_end_tab.mas',
    'Enter a list of identifiers or upload a file containing identifers separated by whitespace (returns, spaces or tabs):',
    'Download BAC end information:',
    'raw sequence and/or quality',
    'trimmed seq. and/or quality',
    'And/or upload list file:',
    'Choose format and type:',
);

page_texts_ok(
    '/tools/bulk/tabs/bac_tab.mas',
    'Enter a list of identifiers or upload a file containing identifers separated by whitespace (returns, spaces or tabs):',
    'Clone name with chromosome (C01HBa0001A01)',
    'Arizona-style clone name (LE_HBa0001A01)',
    'Old Cornell-style clone name (P001A01)',
    'Download BAC information:',
    'And/or upload list file:',
);

page_texts_ok(
    '/tools/bulk/tabs/clone_tab.mas',
    'Enter a list of identifiers or upload a file containing identifers, one per line:',
    'Please select the information you would like for each identifier:',
    'TUS number (used to order clones)',
    'automatic (BLAST) annotation',
    'microarray spot id (SGN-S)',
    'And/or upload list file:',
);

page_texts_ok(
    '/tools/bulk/tabs/converter_tab.mas',
    'Enter a list of identifiers (SGN unigene ids or TOM1 array ids) or upload a file containing one identifer separated by whitespace (returns, spaces or tabs):',
    'Convert unigene ids to tomato genome ids',
    'Convert to newest version',
    'And/or upload list file:',
    'Example:',
    'Submit',
);

page_texts_ok(
    '/tools/bulk/tabs/feature_tab.mas',
    'Enter a list of feature identifier or upload a file containing one identifer separated by whitespace (returns, spaces or tabs):',
    'Download feature information',
    'And/or upload list file:',
    'feature sequence',
    'Example:',
    'Submit',
);

page_texts_ok(
    '/tools/bulk/tabs/gene_tab.mas',
    'Enter a list of gene identifier or upload a file containing one identifer separated by whitespace (returns, spaces or tabs):',
    'Download gene information',
    'And/or upload list file:',
    'Protein sequence',
    'cDNA sequence',
    'CDS sequence',
);

page_texts_ok(
    '/tools/bulk/tabs/unigene_tab.mas',
    'Check this box to convert each unigene in the list to its equivalent in the most current corresponding unigene build(s), if available',
    'Enter a list of identifiers or upload a file containing one identifer separated by whitespace (returns, spaces or tabs):',
    'longest ORF from 6-frame translation',
    'Download unigene information',
    'automatic (BLAST) annotation',
    'Download member information',
);

done_testing;
