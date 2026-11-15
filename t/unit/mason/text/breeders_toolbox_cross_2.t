=head1 NAME

t/unit/mason/text/breeders_toolbox_cross_2.t - breeders_toolbox/cross templates, part 2 of 3: the text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_texts_ok component_compiles_ok );

page_texts_ok(
    '/breeders_toolbox/cross/crossing_trial.mas',
    'View crossing details (e.g., pollination date, number of flowers, number of seeds)',
    'View target numbers of seeds/progenies and progress of crosses in this experiment.',
    'View cross unique ids, cross combination, cross type, parents in this experiment.',
    'View additional female and male parent info of crosses in this experiment.',
    'View field trial(s) that are part of this crossing experiment',
    'Delete crossing experiment or crosses in this experiment.',
);

page_texts_ok(
    '/breeders_toolbox/cross/crossingtrial_details.mas',
    'Download Crosses in this Crossing Experiment',
    'Crossing Experiment Name',
    'Upload New Crosses',
    'Breeding Program',
    'Change Folder',
    'Planting Date',
);

page_texts_ok(
    '/breeders_toolbox/cross/edit_crossingtrial_details_dialog.mas',
    'Error Saving Crossing Experiment Details',
    'Edit Crossing Experiment Details',
    'Crossing Experiment Name:',
    'Indicates pending change',
    'Breeding Program:',
    'Close & Reload',
);

page_texts_ok(
    '/breeders_toolbox/cross/family_deletion.mas',
    'Remove crosses from this family',
    'Delete this family',
    'Delete family',
);

component_compiles_ok('/breeders_toolbox/cross/family_parents.mas');

page_texts_ok(
    '/breeders_toolbox/cross/index.mas',
    'View crossing activities of this cross',
    'Additional Parent Info',
    'Crossing Experiment',
    'Field Crossing Data',
    'Cross Transactions',
    'Cross Combination',
);

page_texts_ok(
    '/breeders_toolbox/cross/intercross_file_info.mas',
    'Downloaded Intercross Files (Parents and Wishlist Files)',
    'Uploaded Intercross Files',
);

page_texts_ok(
    '/breeders_toolbox/cross/intercross_file_upload.mas',
    'Please do not modify header of the Intercross file. The first row (header) must contain the following:',
    'Use your customized cross unique ID previously stored in the database',
    'The crossing data from intercross file were saved successfully.',
    'Select your cross unique id format for intercross file',
    'Cross Unique ID and Template Information',
    'Use auto-generated cross unique ID',
);

page_texts_ok(
    '/breeders_toolbox/cross/intercross_parents_download.mas',
    'The Intercross parents file was created successfully.',
    'The file can be used directly with Intercross app.',
    'The first row (header) contains the following:',
    'Intercross Parents file is a CSV file (.csv).',
    'Names in the list must be uniquenames.',
    'Download Intercross Parents File',
);

page_texts_ok(
    '/breeders_toolbox/cross/intercross_wishlist_download.mas',
    'The Intercross wishlist file was created successfully.',
    'The file can be used directly with Intercross app.',
    'Intercross Wishlist file is a CSV file (.csv).',
    'The first row (header) contains the following:',
    'Names in the list must be uniquenames.',
    'Intercross Wishlist File Created',
);

page_texts_ok(
    '/breeders_toolbox/cross/progenies_from_family.mas',
    'Add progenies to a List',
);

page_texts_ok(
    '/breeders_toolbox/cross/progenies_in_crossingtrial.mas',
    'Upload progeny names that already EXIST in database',
    'Upload Progenies or Family Names',
    'Progeny and Family Name Info',
    'Number of Progenies',
    'Cross Combination',
    'Cross Unique ID',
);

done_testing;
