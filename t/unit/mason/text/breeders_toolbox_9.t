=head1 NAME

t/unit/mason/text/breeders_toolbox_9.t - breeders_toolbox templates, part 9 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/upload_phenotype_datacollector.mas',
    'To include timestamp information for your measurements, click the checkbox "Includes Timestamps".',
    'The first row (header) should contain the following:',
    'Two or more traits can be uploaded at the same time.',
    '(tab-delimited text formats are NOT supported)',
    'Must be in .xls or .xlsx excel file format',
    'Example without timestamps:',
);

page_texts_ok(
    '/breeders_toolbox/upload_phenotype_spreadsheet.mas',
    'The "Detailed" format includes a special header as well as additional columns for design information.',
    'To include timestamp information for your measurements, click the checkbox "Includes Timestamps".',
    'Please click the above button to generate the required phenotype spreadsheet.',
    'Phenotype spreadsheet must be uploaded in .xls or .xlsx excel file format',
    'Two or more traits can be uploaded at the same time.',
    '(tab-delimited text formats are NOT supported)',
);

page_texts_ok(
    '/breeders_toolbox/upload_seedlots_dialogs.mas',
    'Crosses must exist in the database before adding your seed lots. The reason for this is that a cross can produce many seed lots and so the cross must exists as a separate entity in the database. We also want to be careful about adding new crosses into the database because we do not want data to be incorrectly linked to duplicates.',
    'Accessions must exist in the database prior to adding seedlots of them. The reason for this is that an accession can be exist in many seedlots and therefore exists as a separate entity in the database. We also want to be careful about adding new accessions into the database because we do not want incorrectly duplicated data.',
    'Submit your seedlots again. You should have corrected all errors by now, but if not please take a look at the errors in the red box below. You can continue to modify your file and then click Upload until it works.',
    'Seedlots can be used in trials (e.g. they were planted in a plot) and they can be harvested from a plot or plant (e.g. a cross was performed and seeds were collected.)',
    'When adding crosses into the database, you can upload an Excel file or you can add seedlots one at a time.',
    'When adding accessions into the database, you can use either a list of accessions or an Excel file.',
);

page_texts_ok(
    '/breeders_toolbox/upload_seedlots_inventory_dialogs.mas',
    'Seedlots must exist in the database prior to updating or adding inventory. The reason for this is that the inventory does not give information about the content (a named accession or a cross name) and this information is required for a seedlot to exist in the database. We also want to be careful about adding new seedlots into the database because we do not want data to be incorrectly linked to duplicates.',
    'You can use the "Inventory" Android Application to scan seedlot barcodes and record weight. If you prefer you can create your own CSV file and upload that, if you do not want to use the Inventory Application. For info about the format of the file to upload, go to the next tab.',
    'Submit your inventory again. You should have corrected all errors by now, but if not please take a look at the errors in the red box below. You can continue to modify your file and then click Upload until it works.',
    'A seedlot inventory consists of giving a location and current weight(g) to your seedlots. The seedlot name is the unique identifier for each seedlot and so should be encoded in a barcode on each seedlot packet.',
    'Seedlots can be used in trials (e.g. they were planted in a plot) and they can be harvested from a plot or plant (e.g. a cross was performed and seeds were collected.)',
    'It is also possible to manually enter a transaction by going to the seedlot detail page and clicking "Add New Transaction".',
);

done_testing;
