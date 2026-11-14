=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_accessions.t - scripts in the breeders_toolbox/accessions templates: the script text is shown in the user's language

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
    '/breeders_toolbox/accessions/find_trials_by_accessions.mas',
    'Accession list did not pass validation. Please correct the list and try again',
    'You need to select an accession list!',
);

done_testing;
