=head1 NAME

t/unit/mason/text/scripts_brapiclient_3.t - scripts in the brapiclient templates, part 3 of 3: the script text is shown in the user's language

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
    '/brapiclient/studies_table.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/studytypes.mas',
    'An error occurred getting seasons',
);

page_script_texts_ok(
    '/brapiclient/traits.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/traits_detail.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/trials.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/trials_detail.mas',
    'An error occurred',
);

done_testing;
