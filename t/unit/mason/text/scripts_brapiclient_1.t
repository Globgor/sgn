=head1 NAME

t/unit/mason/text/scripts_brapiclient_1.t - scripts in the brapiclient templates, part 1 of 3: the script text is shown in the user's language

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
    '/brapiclient/authentication.mas',
    'Successfully logged out!',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/calls.mas',
    'An error occurred getting calls',
);

page_script_texts_ok(
    '/brapiclient/comparegenotypes.mas',
    'An error occurred.',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/crops.mas',
    'An error occurred getting crops',
);

page_script_texts_ok(
    '/brapiclient/germplasm_attributes.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/germplasm_detail.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/germplasm_search.mas',
    'An error occurred getting details to save!',
    'An error occurred in fuzzy search!',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/locations.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/maps.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/maps_detail.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/markerprofile_allelematrix.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/brapiclient/markerprofile_detail.mas',
    'An error occurred',
);

done_testing;
