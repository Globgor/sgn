=head1 NAME

t/unit/mason/text/solgs_population_1.t - solgs/population templates, part 1 of 2: the text is shown in the user's language

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
    '/solgs/population/download.mas',
    'Download data',
);

page_texts_ok(
    '/solgs/population/models/model/accuracy.mas',
    'Model accuracy statistics -- K-fold cross-validation method',
);

component_compiles_ok('/solgs/population/models/model/detail.mas');

page_texts_ok(
    '/solgs/population/models/model/gebv_pheno_regression.mas',
    'GEBVs vs observed phenotypes',
);

page_texts_ok(
    '/solgs/population/models/model/gebvs.mas',
    'Genomic estimated breeding values (GEBVs) - GBLUP method',
);

page_texts_ok(
    '/solgs/population/models/model/marker_effects.mas',
    'Marker effects',
    'Top 10 markers',
);

component_compiles_ok('/solgs/population/models/model/phenotype/trait_phenotype_data.mas');

page_texts_ok(
    '/solgs/population/models/model/phenotype/trait_phenotype_scatter.mas',
    'Reset zoom',
);

page_texts_ok(
    '/solgs/population/models/model/save_gebvs.mas',
    'Save genetic values',
    'Save GEBVs',
);

page_texts_ok(
    '/solgs/population/models/model/top_blups.mas',
    'Top 10 genotypes',
);

page_texts_ok(
    '/solgs/population/models/model/variance_components.mas',
    'Variance components',
);

done_testing;
