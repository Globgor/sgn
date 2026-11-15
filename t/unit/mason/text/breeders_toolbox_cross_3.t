=head1 NAME

t/unit/mason/text/breeders_toolbox_cross_3.t - breeders_toolbox/cross templates, part 3 of 3: the text is shown in the user's language

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
    '/breeders_toolbox/cross/seedlots_from_crossingtrial.mas',
    'Add New Seedlot',
    'Close',
    'Add',
);

page_texts_ok(
    '/breeders_toolbox/cross/target_numbers.mas',
    'Actual No. of Progenies',
    'Target No. of Progenies',
    'Actual No. of Seeds',
    'Target No. of Seeds',
    'Cross Unique IDs',
    'Female Accession',
);

page_texts_ok(
    '/breeders_toolbox/cross/target_numbers_upload.mas',
    'Please indicate target number of seeds and/or target number of progenies for each cross combination',
    'Upload Target Numbers of Seeds/Progenies for This Crossing Experiment',
    'The target numbers of seeds/progenies were saved successfully.',
    'The first row (header) must contain the following:',
    'Target Numbers Upload Information',
    'Upload File (.xls or .xlsx):',
);

page_texts_ok(
    '/breeders_toolbox/cross/target_numbers_usage_info_dialog.mas',
    'Crossing tool allows you to record crossing activities at accession, plot or plant level. As a result, the same parental combination can be associated with several cross unique ids depending on the number of female plots/plants and the number of male plots/plants. Once you set target numbers, this section will automatically track and aggregate actual numbers of seeds and/or numbers of progenies from different cross unique ids having the same parental combination. The progress will be updated every time you store new data in the database',
    'You can set target numbers of seeds and/or target numbers of progenies for parental combinations that you plan to include in this cossing experiment. Once target numbers are stored in the database, this section will automatically track crossing activities in this crossing experiment. Target numbers can be added before or after actual crossing activities are stored in the database.',
    'Tracking Progress of Each Parental Combination:',
    'Target Numbers of Seeds and/or Progenies:',
    'How to Use Target Numbers Section',
    'How to Record Target Numbers:',
);

page_texts_ok(
    '/breeders_toolbox/cross/target_numbers_using_lists.mas',
    'List of Female Parents and List of Male Parents:',
    'Record Target Numbers of Seeds and/or Progenies',
    'The target numbers were recorded successfully.',
    'Record Target Numbers',
    'List Information',
    'Female Parents:',
);

page_texts_ok(
    '/breeders_toolbox/cross/upload_crosses_confirm_barcode.mas',
    'Spreadsheet feature not implemented yet',
);

page_texts_ok(
    '/breeders_toolbox/cross/upload_crosses_confirm_spreadsheet.mas',
    'Upload cross file verification',
    'View uploaded data',
);

page_texts_ok(
    '/breeders_toolbox/cross/upload_crosses_dialogs.mas',
    'After cross unique ids are stored in the database, you can add field crossing data (e.g. pollination date, total number of flowers pollinated, total number of fruits set) or progenies to each cross unique id.',
    'Crossing experiments are for grouping crosses together. The grouping is most often done for crosses derived from the same field trial, the same year, or for crosses that have the same breeding objective.',
    'Field crossing data and progenies can be uploaded via links in crossing experiment detail page or can be added directly in each cross detail page.',
    'To set up crosses in the database, please provide required information. The first row (header) must contain the following:',
    'If you are uploading an Intercross file and using auto-generated cross unique IDs, please use manage Intercross section',
    'A cross can have a number of properties associated to it, such as number of flowers, pollination date, etc.',
);

page_texts_ok(
    '/breeders_toolbox/cross/upload_crossingtrial_seedlots_dialog.mas',
    'You may want to proceed to the seedlot detail page(s) for the seedlot(s) you just created.',
    'A seedlot is a collection of seeds harvested from a cross, accession, plot or plant.',
    'The seedlots were saved to the database with no errors! Congrats Click Here',
    'Provide basic information about the seedlots and upload your file',
    'Seedlots can have a specific location, box, weight(g), and count.',
    'Information about file format for uploading seed lots harvested',
);

page_texts_ok(
    '/breeders_toolbox/cross/upload_update_crosses.mas',
    'Additional Parent Info of existing crosses may be uploaded in an Excel file (.xls or .xlsx)',
    'At least one column of parent info listed below (please use exact column header as shown)',
    'At least one column of cross info listed below (please use exact column header as shown)',
    'Cross info of existing crosses may be uploaded in an Excel file (.xls or .xlsx)',
    'If you are uploading an Intercross file, please use manage Intercross section',
    'The first row (header) must contain the following:',
);

done_testing;
