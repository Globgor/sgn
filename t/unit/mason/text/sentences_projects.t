=head1 NAME

t/unit/mason/text/sentences_projects.t - projects templates: sentences appear in the user's language

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
    '/projects/solanaceae_project.mas',
    'The purpose of the meeting was to determine the feasibility, utility, strategy and level of international interest/commitment for sequencing the tomato genome as a reference for the family Solanaceae and other closely related plant families. The workshop brought together and international group of scientists to discuss:',
    'Over the coming decade the International Solanaceae Genome Project (SOL) will create a coordinated network of knowledge about the Solanaceae family aimed at answering two of the most important questions about life and agriculture:',
    'mechanisms by which such a sequencing project can be conducted as part of a multinational consortium, and 5) strategies for sequence information management, curation and public dissemination.',
    'How can a deeper understanding of the genetic basis of diversity be harnessed to better meet the needs of society in an environmentally-friendly way?',
    'How can a common set of genes/proteins give rise to such a wide range of morphologically and ecologically distinct organisms that occupy our planet?',
    'the current status of Solanaceae research - including aspects of plant biology for which Solanaceous species are a preferred model,',
);

done_testing;
