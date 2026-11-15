=head1 NAME

t/unit/mason/text/sentences_tools_motifs_finder.t - tools/motifs_finder templates: sentences appear in the user's language

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
    '/tools/motifs_finder/index.mas',
    '{bold}Fragmentation:{end_bold} normally the sampler allows itself to flexibly change the width of the motif and to introduce spacers. You can turn it on by unchecking the Fragmentation checkbox.',
    '{bold}Reverse complement:{end_bold} the sampler normally samples in both forward and reverse complement. You can turn off reverse complement sampling by checking the Reverse complement checkbox.',
    '3. Enter {bold}expected sites{end_bold}, expected number of sites in each motif must be entered. For multiple motifs, the sites are separated by commas; {example}',
    '2. Enter {bold}motif width(s){end_bold}, a width for each motif must be entered. For multiple motifs, the widths are separated by commas; {example}',
    '{bold}Number of seeds:{end_bold} the number of times that the sampler is restarted with separate initial models.',
    'Or Upload a {bold}sequence file{end_bold}. It must be in {bold}FASTA format{end_bold}.',
);

page_sentences_ok(
    '/tools/motifs_finder/motif_output.mas',
    '{link}Go back to input page{end_link}',
    'Motif Finder Result Summary',
    '{link}Back to top{end_link}',
);

done_testing;
