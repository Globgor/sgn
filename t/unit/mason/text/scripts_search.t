=head1 NAME

t/unit/mason/text/scripts_search.t - scripts in the search templates: the script text is shown in the user's language

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
    '/search/bulk.mas',
    'Could not get supported data types!',
    'Invalid response from the server!',
    'Could not run bulk search!',
    'Search',
);

page_script_texts_ok(
    '/search/genotyping_projects_accession_filter.mas',
    'No genotyping projects found for accessions',
);

page_script_texts_ok(
    '/search/genotyping_protocols_accession_filter.mas',
    'No genotyping protocols found for accessions',
);

component_compiles_ok('/search/stocks.mas');

component_compiles_ok('/search/stocks_graphicalfiltering.mas');

done_testing;
