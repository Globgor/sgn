=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_1.t - scripts in the breeders_toolbox templates, part 1 of 4: the script text is shown in the user's language

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
    '/breeders_toolbox/breeder_search_page_dataset_overlay.mas',
    'Are you sure you want to close the dataset creation help?',
    'Return',
    'Next',
);

done_testing;
