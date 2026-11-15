=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_4.t - scripts in the breeders_toolbox templates, part 4 of 4: the script text is shown in the user's language

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
    '/breeders_toolbox/upload_images.mas',
    'No image collections available',
    'Select a collection',
);

page_script_texts_ok(
    '/breeders_toolbox/upload_locations_dialogs.mas',
    'Please select a file',
    'An error occurred',
);

page_script_texts_ok(
    '/breeders_toolbox/upload_seedlots_dialogs.mas',
    'Seedlots were saved in the database',
    'Please choose a breeding program',
    'Please select a material type',
    'Please give a location',
    'Please select a file',
    'No file selected',
);

page_script_texts_ok(
    '/breeders_toolbox/upload_seedlots_inventory_dialogs.mas',
    'No file selected',
);

page_script_texts_ok(
    '/breeders_toolbox/upload_transactions_dialogs.mas',
    'Please choose a breeding program for new seedlots',
    'Please give a location for new seedlots',
    'Please select a file',
);

done_testing;
