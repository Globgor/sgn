=head1 NAME

t/unit/mason/text/scripts_chado.t - scripts in the chado templates: the script text is shown in the user's language

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

component_compiles_ok('/chado/cvterm.mas');

page_script_texts_ok(
    '/chado/cvtermprops.mas',
    'An error occurred. Please try again later.',
    'Please fill in the field.',
    'an error occurred',
);

component_compiles_ok('/chado/relations.mas');

done_testing;
