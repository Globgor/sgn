=head1 NAME

t/unit/mason/text/scripts_tools_solgwas.t - scripts in the tools/solgwas templates: the script text is shown in the user's language

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
    '/tools/solgwas/index.mas',
    'An error occurred, the service may temporarily be unavailable',
    'An error occurred, the is some problem with data',
    'You must be logged in to use SolGWAS',
    'Please select at least one dataset!',
    'Please select a dataset and trait.',
    'Please select only one dataset!',
);

done_testing;
