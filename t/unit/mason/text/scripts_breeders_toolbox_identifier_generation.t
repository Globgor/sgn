=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_identifier_generation.t - scripts in the breeders_toolbox/identifier_generation templates: the script text is shown in the user's language

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
    '/breeders_toolbox/identifier_generation/list_identifier_generation.mas',
    'Error getting identifier list history!',
    'Error downloading new identifiers!',
);

page_script_texts_ok(
    '/breeders_toolbox/identifier_generation/manage_identifier_generation.mas',
    'Error submitting new identifier!',
);

done_testing;
