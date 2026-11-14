=head1 NAME

t/unit/mason/text/projects_varitome.t - projects/varitome templates: the text is shown in the user's language

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
    '/projects/varitome/index.mas',
    'Future crop improvement relies on harnessing the broader genetic diversity present in the ancestors of our crops. Recently, our team has gained detailed knowledge of the transition from wild species to the earliest tomato landraces. Cultivated tomato (Solanum lycopersicum var lycopersicum) evolved from semi-domesticated and wild populations of S. lycopersicum var cerasiforme, which in turn evolved from a subpopulation of the red-fruited wild species, S. pimpinellifolium. This knowledge allows us to select and exploit underutilized germplasm for the identification of genes controlling fruit quality and beneficial alleles that may have been left behind during crop domestication. With this information, we seek to gain fundamental insights into the molecular and biochemical pathways that impact the traits. This would lead to an advanced understanding into the regulation of basic plant processes of economic importance. To efficiently identify genes and pathways that control complex fruit quality traits in tomato, we propose the following specific aims:',
    'Assembly and phenotyping of a tomato population constituting the continuum of wild, semi-domesticated and ancestral landraces. This collection is named Varitome to distinguish it from other tomato sequencing projects.',
    'Identification of loci underlying fruit quality traits through genome-wide association studies (GWAS) and differentially expressed small RNAs.',
    'Varitome project: Exploitation of genetic and epigenetic variation in the regulation of tomato fruit quality traits',
    'Functional analysis of developmental and biochemical pathways that control fruit quality.',
    'Genetic confirmation of trait association with candidate regions to genes.',
);

done_testing;
