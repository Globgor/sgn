=head1 NAME

t/unit/mason/text/sentences_potato_genome.t - potato_genome templates: sentences appear in the user's language

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
    '/potato_genome/potato_genome_overview.mas',
    'SGN Potato BLAST {link}BACs{end_link} | {link2}BAC ends{end_link2}',
    'Download BAC by BAC data: {link}SGN FTP site{end_link}',
);

done_testing;
