=head1 NAME

t/unit/mason/text/qtl_qtl_form.t - qtl/qtl_form templates: the text is shown in the user's language

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

component_compiles_ok('/qtl/qtl_form/confirm.mas');

page_texts_ok(
    '/qtl/qtl_form/general_intro.mas',
    'Some basic information about the population,',
    'Genotype data file (tab delimited) and',
    'Phenotype data file (tab delimited),',
    'Traits data file (tab delimited),',
    'Statistical parameters.',
    'Required data:',
);

page_texts_ok(
    '/qtl/qtl_form/geno_form.mas',
    'Step 4: Submit Genotype Data',
    'Genotype Dataset:',
    'Genotype Dataset',
    'Submit',
);

page_texts_ok(
    '/qtl/qtl_form/intro.mas',
    'Step 0: Introduction',
    'Begin Uploading',
    'Introduction',
);

page_texts_ok(
    '/qtl/qtl_form/organism_form.mas',
    'associate organism',
    'Common name:',
);

page_texts_ok(
    '/qtl/qtl_form/pheno_form.mas',
    'Step 3: Submit Phenotype Data',
    'Phenotype Dataset:',
    'Phenotype Dataset',
    'Submit',
);

component_compiles_ok('/qtl/qtl_form/pop_form.mas');

page_texts_ok(
    '/qtl/qtl_form/stat_form.mas',
    'QTL genotype probability significance level:',
    'No. of permutations:',
    'QTL mapping method:',
    'QTL model:',
    'Submit',
    'Reset',
);

page_texts_ok(
    '/qtl/qtl_form/trait_form.mas',
    'Step 2: Submit Trait Data',
    'Trait dataset:',
    'Trait Dataset',
    'Submit',
);

done_testing;
