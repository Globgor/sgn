=head1 NAME

t/unit/mason/text/sentences_secretom_detail_2.t - secretom/detail templates, part 2 of 2: sentences appear in the user's language

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
    '/secretom/detail/spinoffs.mas',
    'Characterization of the secretomes of divergent members of the CGA will likely provide insights into the mechanisms that are currently used by embryophytes for primary, secondary and cuticular cell wall formation and restructuring.',
    'This transition to harsh terrestrial conditions would have required the ability to resist new abiotic stresses, including desiccation and UV radiation, as well as the development of mechanisms to promote progeny dispersal.',
    'It is likely that polysaccharide and cuticular cell walls were essential for the transition to a terrestrial environment and yet the evolutionary origins of their biosynthesis are not well understood.',
    'We are using proteomic tools to study the molecular barriers between tomato species, with particular focus on secreted proteins as these are believed to be critical in establishing such barriers.',
    'This is an NSF Plant Genome program funded collaborative scientific endeavor to identify and understand the biological processes underlying species isolation within the Tomato family.',
    'One of the most important phases of plant evolution occurred approximately 460-480 million years ago when photosynthetic organisms developed the capacity to colonize land.',
);

done_testing;
