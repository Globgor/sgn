=head1 NAME

t/unit/mason/text/brapiclient_3.t - brapiclient templates, part 3 of 3: the text is shown in the user's language

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
    '/brapiclient/studies_search.mas',
    'Studies Search',
    'Search',
);

page_texts_ok(
    '/brapiclient/studies_table.mas',
    'JSON (transformed to HTML table)',
    'Study Observation Units Table',
    'Get Phenotypes',
    'Excel (xlsx)',
    'Plant',
    'Plot',
);

page_texts_ok(
    '/brapiclient/studytypes.mas',
    'Show StudyTypes',
    'StudyTypes',
);

page_texts_ok(
    '/brapiclient/traits.mas',
    'Get Traits',
    'Traits',
);

page_texts_ok(
    '/brapiclient/traits_detail.mas',
    'Germplasm Details',
    'Get Trait Details',
);

page_texts_ok(
    '/brapiclient/trials.mas',
    'Trial Search',
    'Get Trials',
);

page_texts_ok(
    '/brapiclient/trials_detail.mas',
    'Get Trial Details',
    'Trial Detail',
);

done_testing;
