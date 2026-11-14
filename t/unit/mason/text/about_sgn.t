=head1 NAME

t/unit/mason/text/about_sgn.t - about/sgn templates: the text is shown in the user's language

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

component_compiles_ok('/about/sgn/index.mas');

page_texts_ok(
    '/about/sgn/publications.mas',
    'Selected Publications',
);

page_texts_ok(
    '/about/sgn/status.mas',
    'Accessions with Phenotype Data',
    'Accessions with Genotype Data',
    'Total Phenotype Observations',
    'Genotyping Protocols',
    'Breeding Programs',
    'Phenotype Trials',
);

page_texts_ok(
    '/about/sgn/tools.mas',
    'SGN community-driven gene and phenotype database',
    'Solanaceae and other Genomes',
    'Maps and Markers',
    'Unigenes',
    'Tools',
    'Data',
);

done_testing;
