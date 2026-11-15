=head1 NAME

t/unit/mason/text/sentences_links.t - links templates: sentences appear in the user's language

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
    '/links/related_sites.mas',
    'LycoTILL is an interactive and evolving database which allows search on-line of images and phenotype data of the tomato (cv /Red Setter/) mutant collection generated with EMS mutagenesis experiments. The Red Setter mutant population was developed for TILLING applications but can also be used for forward genetic studies.',
    'The European Cooperative Programme for Plant Genetic Resources (ECPGR) is a collaborative programme among most European countries aimed at ensuring the long-term conservation and facilitating the increased utilization of plant genetic resources in Europe ({link}Solanaceae{end_link}, {link2}Potato{end_link2})',
    'The AGI is the place to {link}order{end_link} many of the ESTs and BAC clones for many Solanaceae species such as potato. Please note that BAC and EST {link2}orders{end_link2} for tomato are handled by the {link3}Boyce Thompson Institute{end_link3}.',
    'The official website of the Solanum PBI project, containing species descriptions, specimen data from herbaria, nomenclatural data about names and their places of publication, and a bibliography of scientific articles about members of the family.',
    'The International Potato Center in Lima, Peru, with potato specific databases and resources, such as the {link}CIP Potato Genebank{end_link} and the {link2}World Potato Atlas{end_link2}',
    'Potato genome data from the Max-Planck Institute for Plant Breeding Research, Cologne, Germany, which includes SNP data, maps, marker sequences, references and more.',
);

done_testing;
