=head1 NAME

t/unit/mason/text/scripts_search_cross.t - scripts in the search/cross templates: the script text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form, as a JSON string inside a script. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_script_texts_ok component_compiles_ok );

page_script_texts_ok(
    '/search/cross/cross_search_using_female.mas',
    'An error occurred',
    'No male parent',
);

page_script_texts_ok(
    '/search/cross/cross_search_using_male.mas',
    'An error occurred',
    'No female parent',
);

page_script_texts_ok(
    '/search/cross/parent_search.mas',
    'The accession list contains elements that are not accessions or are not uniquenames.',
    'Please select a list of accessions',
    'Number of Accessions',
    'Accession Names',
    'Female Parent',
    'Male Parent',
);

page_script_texts_ok(
    '/search/cross/progeny_search_using_female.mas',
    'An error occurred',
    'No male parent',
);

page_script_texts_ok(
    '/search/cross/progeny_search_using_male.mas',
    'An error occurred',
    'No female parent',
);

done_testing;
