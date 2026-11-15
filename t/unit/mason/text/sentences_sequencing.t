=head1 NAME

t/unit/mason/text/sentences_sequencing.t - sequencing templates: sentences appear in the user's language

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
    '/sequencing/sol100.mas',
    'The International SOL Genome Project (SOL) is a "virtual umbrella" organization for promoting, coordinating and actively seeking additional scientists, countries and funding agencies to participate in an expedition to understand, utilize and conserve natural biodiversity (see {link}{address}{end_link}).',
    '{bold}Submission to SGN requires prior submission to {link}Genbank{end_link}{end_bold} and a {bold}{link2}Genbank Project ID{end_link2}{end_bold}. Please contact {link3}{person}{end_link3} at Genbank or {link4}SGN{end_link4} for more information.',
    'Tie the available tomato, tobacco, potato and Asterid relatives coffee and Mimulus (monkey-flower) genome sequences to a common SOL physical and genetic map as well as other Asterid taxonomic groups, such as Antirrhinum, sweet potato and mint.',
    'SOL includes scientists from more than 30 countries that are united and excited about the sustainable and equitable use of natural biodiversity in biological research, plant breeding and conservation of these resources for the future.',
    'The SOL community will create a common Solanaceae-based genomic framework that includes sequences and phenotypes of 100 genomes encompassing the phylogenetic diversity of the group. Specific objectives are to:',
    'The SOL community has sequenced both the tomato genome and the potato genome through grants from national funding agencies as well as international collaborative projects.',
);

done_testing;
