=head1 NAME

t/unit/mason/text/sequencing.t - sequencing templates: the text is shown in the user's language

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
    '/sequencing/sol100.mas',
    'The Solanaceae include more than 3000 species with wide adaptation, shape, chemistry, and distribution. Species of the family are of great agricultural, nutritional, horticultural and medicinal importance (e.g., potato, tomato, pepper, petunia and tobacco). This enormous diversity is contrasted by high conservation of gene order and content at the macro and micro syntenic levels. Solanaceae genomes can be genetically tied to a common framework linkage map, thus facilitating the identification of genes with homologous phenotypes in the different species. These features make Solanaceae an excellent taxon with which to address a central question in biology:',
    'How can a deeper understanding of the genetic basis of plant biodiversity be harnessed to better meet the needs of society in an environmentally friendly and sustainable manner?',
    'How can a common set of genes/proteins give rise to such a wide range of morphologically and ecologically distinct species?',
    'But also, studying the Solanaceae can generate answers to the currently highly relevant and urgent question:',
    'If you are sequencing a SOL-100 genome, please submit the genome to SGN.',
    'The SOL-100 sequencing project',
);

done_testing;
