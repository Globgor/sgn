=head1 NAME

t/unit/mason/text/solgs_search_1.t - solgs/search templates, part 1 of 2: the text is shown in the user's language

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
    '/solgs/search/all_traits_index.mas',
    'List of traits with GS data',
);

page_texts_ok(
    '/solgs/search/breeder_search_solgs.mas',
    'Back',
);

page_texts_ok(
    '/solgs/search/combine_trials_table.mas',
    'Selected trials',
    'More details',
    'Search again',
    'Description',
    'Location',
    'Trial',
);

page_texts_ok(
    '/solgs/search/list_type_training_population.mas',
    'Or use a list or dataset as a training population',
);

component_compiles_ok('/solgs/search/result.mas');

page_texts_ok(
    '/solgs/search/result/confirm/populations.mas',
    'Confirm',
);

component_compiles_ok('/solgs/search/result/populations.mas');

page_texts_ok(
    '/solgs/search/result/traits.mas',
    'Traits with genomic selection data',
    'Search Results',
);

page_texts_ok(
    '/solgs/search/selection_populations.mas',
    'search for a trial',
);

page_texts_ok(
    '/solgs/search/solgs.mas',
    'solGS: Genomic Prediction Modeling',
);

page_texts_ok(
    '/solgs/search/trait.mas',
    'solGS: Search Traits',
);

page_texts_ok(
    '/solgs/search/trait_search_form.mas',
    'enter trait name',
);

done_testing;
