=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_cross_1.t - breeders_toolbox/cross templates, part 1 of 3: sentences appear in the user's language

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
    '/breeders_toolbox/cross/add_cross_dialogs.mas',
    '{bold}polycross:{end_bold} Creates a group of open pollinated crosses. Each accession in the selected list becomes the female parent in an open cross, and all the members of the list grouped together form the male parent.',
    '{bold}bulk and open pollinated:{end_bold} A group of plants (usually a related family) that are pollinated by another group of plants or open pollinated (pollen may be from a group with known or unknown members).',
    '{bold}multicross:{end_bold} Creates a group of biparental crosses. Starting with a list of maternal accessions and a list of paternal accessions, direct crosses are made in order.',
    '{bold}reciprocal:{end_bold} Creates a group of biparental crosses. Starting with a list of accessions, all possible biparental cross combinations are made between them.',
    '{bold}open pollinated:{end_bold} An individual plant pollinated by a group of plants or open pollinated (pollen may be from a group with known or unknown members).',
    '{bold}bulk selfed:{end_bold} A group of plants (usually a related family) that are self pollinated (each individual selfed, not combined pollen).',
);

page_sentences_ok(
    '/breeders_toolbox/cross/cross_wishlist.mas',
    'Female Plots are in {span}Blue{end_span}',
);

done_testing;
