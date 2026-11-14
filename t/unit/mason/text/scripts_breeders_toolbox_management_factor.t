=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_management_factor.t - scripts in the breeders_toolbox/management_factor templates: the script text is shown in the user's language

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
    '/breeders_toolbox/management_factor/edit_management_factor_details_dialogs.mas',
    'Please give a treatment description!',
    'Error saving treatment details!',
    'Please give a treatment date!',
    'Please give a treatment name!',
    'Please give a treatment type!',
    'Please give a treatment year!',
);

done_testing;
