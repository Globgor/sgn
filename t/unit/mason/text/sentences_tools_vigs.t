=head1 NAME

t/unit/mason/text/sentences_tools_vigs.t - tools/vigs templates: sentences appear in the user's language

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
    '/tools/vigs/input.mas',
    '6. Upload a {bold}expression values file{end_bold} (optional), It must be a tab delimited text file, with gene identifiers in the first column and a header in the first row:',
    '2. Choose {bold}n-mer size{end_bold}, nucleotide stretch size in bp, used to identify targeted regions (18-24, Default=21)',
    '3. Choose {bold}Fragment length{end_bold}, desired VIGS fragment length in bp (100-Sequence length, Default=300)',
    '4. Choose {bold}mismatches{end_bold}, number of mismatches allowed in the alignment (0-2, Default=0)',
    '1. Paste a {bold}sequence{end_bold} like in one of the examples:',
    'Or paste the {bold}gene ID{end_bold}:',
);

done_testing;
