=head1 NAME

t/unit/mason/text/solgs_population_2.t - solgs/population templates, part 2 of 2: the text is shown in the user's language

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
    '/solgs/population/models/models_summary.mas',
    'Training population',
    'Models summary',
    'Description',
    'Models',
);

page_texts_ok(
    '/solgs/population/selection_prediction_detail.mas',
    'Selection population summary',
);

page_texts_ok(
    '/solgs/population/training_population.mas',
    'There is no genotype data for this population.',
    'Training population summary',
    'Genotype Data',
);

page_texts_ok(
    '/solgs/population/trait_acronyms.mas',
    'Acronyms legend',
    'Acronym',
    'Trait',
);

page_texts_ok(
    '/solgs/population/traits_list.mas',
    'There are no phenotyped traits for this population.',
);

done_testing;
