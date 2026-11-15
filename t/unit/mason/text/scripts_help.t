=head1 NAME

t/unit/mason/text/scripts_help.t - scripts in the help templates: the script text is shown in the user's language

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
    '/help/contact.mas',
    'Please prove you are a human by answering the simple math question.',
    'Subject is required. Please fill in this field.',
    'Email is required. Please fill in this field.',
    'Body is required. Please fill in this field.',
    'Name is required. Please fill in this field.',
);

done_testing;
