=head1 NAME

t/unit/mason/text/qtl_submission.t - qtl/submission templates: the text is shown in the user's language

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
    '/qtl/submission/guide/contact.mas',
    'Contact us',
);

page_texts_ok(
    '/qtl/submission/guide/further_reading.mas',
    'Further reading',
);

page_texts_ok(
    '/qtl/submission/guide/genotype_dataset.mas',
    'The genotype dataset should be in a text file and in the following format. The plant names in the genotype dataset must be exactly the same as the ones submitted in the phenotype dataset file in the previous step.',
    'Step 4: Genotype dataset',
);

page_texts_ok(
    '/qtl/submission/guide/index.mas',
    'QTL Data Submission Guidelines',
    'Detailed guide:',
);

page_texts_ok(
    '/qtl/submission/guide/phenotype_dataset.mas',
    'The phenotype dataset should be in a text file and in the following format. The traits names in the phenotype dataset must match exactly with the traits in the traits file, submitted in the previous step.',
    'Step 3: Phenotype dataset',
);

page_texts_ok(
    '/qtl/submission/guide/population_details.mas',
    'Step 1:  Population details',
);

page_texts_ok(
    '/qtl/submission/guide/qtl_analysis.mas',
    'Step 6: QTL analysis',
);

page_texts_ok(
    '/qtl/submission/guide/statistics.mas',
    'The qtl analysis uses R/QTL package and implements an interval mapping with the following parameters.',
    'Step 5: Statistical parameters',
);

page_texts_ok(
    '/qtl/submission/guide/traits_list.mas',
    'Use of the Solanaceae Phenotype Ontology is highly encouraged to allow cross-study comparative analysis but not required.',
    'The definition and unit are optional but would make the phenotype data more informative to users of the database.',
    'The traits list file needs to be in a text file and should look like the following format.',
    'Step 2: Traits list',
);

done_testing;
