=head1 NAME

t/unit/mason/text/sentences_genomes_3.t - genomes templates, part 3 of 3: sentences appear in the user's language

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
    '/genomes/Solanum_pennellii.mas',
    'By anchoring the {i}{species}{end_i} genome to the genetic map, we define candidate genes for stress tolerance and provide evidence that transposable elements had a role in the evolution of these traits.',
    'Introgression lines (ILs) in which large genomic regions of {i}{species2}{end_i} are replaced with the corresponding segments from {i}{species}{end_i} can show remarkably superior agronomic performance.',
    'Our work paves a path toward further tomato improvement and for deciphering the mechanisms underlying the myriad other agronomic traits that can be improved with {i}{species}{end_i} germplasm.',
    'Because of its extreme stress tolerance and unusual morphology, it is an important donor of germplasm for the cultivated tomato {i}{species2}{end_i}.',
    'It was sequenced by a group of scientists at MPI Golm and the University of Aachen and collaborators, under the direction of {person} and {person2}.',
    '{link}{i}{species}{end_i}{end_link} is a wild tomato that is relatively distant from the domesticated {link2}{i}{species2}{end_i}{end_link2}.',
);

page_sentences_ok(
    '/genomes/Solanum_pimpinellifolium.mas',
    '{link}{i}{species}{end_i}{end_link} is the wild tomato that is most closely related to the domesticated {link2}{i}{domesticated_species}{end_i}{end_link2}.',
    'Please contact {person} or {person2} (E-mail: {link}{email}{end_link} or {link2}{email2}{end_link2}) with any questions.',
    'It was sequenced by a group of scientists at the {link}{institution}{end_link}.',
    'Please cite {link}{citation}{end_link} when using this resource.',
    'These data have been published and are freely accessible.',
);

component_compiles_ok('/genomes/Solanum_tuberosum.mas');

done_testing;
