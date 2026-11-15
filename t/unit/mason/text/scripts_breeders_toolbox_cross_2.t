=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_cross_2.t - scripts in the breeders_toolbox/cross templates, part 2 of 2: the script text is shown in the user's language

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
    '/breeders_toolbox/cross/intercross_parents_download.mas',
    'An error occurred creating the parents file.',
    'Please choose a list of female parents',
    'Please choose a list of male parents',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/intercross_wishlist_download.mas',
    'The female list did not pass validation. Names in the list must be uniquenames in the database',
    'The male list did not pass validation. Names in the list must be uniquenames in the database',
    'An error occurred creating the wishlist file.',
    'Please select female list',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/progenies_from_family.mas',
    'Cross Unique ID',
    'Progeny Name',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/seedlots_from_crossingtrial.mas',
    'Error retrieving breeding program name',
    'Error retrieving breeding program id',
    'Seedlot amount or weight is required',
    'An error occurred adding seedlot',
    'Cross Unique ID is required',
    'The seedlot has been added.',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/target_numbers_upload.mas',
    'Please select a file',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/target_numbers_using_lists.mas',
    'The female list did not pass validation. Names in the list must be uniquenames in the database',
    'The male list did not pass validation. Names in the list must be uniquenames in the database',
    'An error occurred storing target numbers.',
    'Please select female list',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/upload_crossingtrial_seedlots_dialog.mas',
    'Seedlots were saved in the database',
    'Please choose a breeding program',
    'Please give a location',
    'Please select a file',
    'No file selected',
);

page_script_texts_ok(
    '/breeders_toolbox/cross/upload_update_crosses.mas',
    'Please select a file',
);

done_testing;
