=head1 NAME

t/unit/mason/text/scripts_search_markers.t - scripts in the search/markers templates: the script text is shown in the user's language

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
    '/search/markers/results.mas',
    'ERROR: Could not perform genotyped marker search',
    'ERROR: Could not perform mapped marker search',
    'No markers found',
    'Reference Genome',
    'Chromosome',
    'Map Units',
);

page_script_texts_ok(
    '/search/markers/search.mas',
    'Both the start and end position are required when filtering by position',
    'ERROR: Could not get genotyped chromosomes',
    'ERROR: Could not get genotyped protocols',
    'ERROR: Could not get mapped chromosomes',
    'ERROR: Could not get reference genomes',
    'ERROR: Could not get mapped protocols',
);

done_testing;
