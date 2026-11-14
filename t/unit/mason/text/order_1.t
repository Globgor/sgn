=head1 NAME

t/unit/mason/text/order_1.t - order templates, part 1 of 2: the text is shown in the user's language

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
    '/order/add_catalog_item_dialog.mas',
    'The catalog item was saved successfully.',
    'Please provide contact person username',
    'Item name must be in the database',
    'Contact Person Username:',
    'Please select a category',
    'Add New Catalog Item',
);

page_texts_ok(
    '/order/add_catalog_using_list_dialog.mas',
    'The catalog items were saved successfully.',
    'Please provide contact person username',
    'Add New Catalog Items Using List',
    'Contact Person Username:',
    'Please select a category',
    'Select a list type',
);

page_texts_ok(
    '/order/catalog.mas',
    'You do not have any item in your cart',
    'Order Form and Catalog',
    'Add Item Details',
    'Submit Order',
    'Your Order',
    'Your Cart',
);

page_texts_ok(
    '/order/catalog_item_details.mas',
    'The image was removed from the catalog item.',
    'The image was added successfully.',
    'The catalog item was delete.',
    'Contact Person Username',
    'Go to Catalog Page',
    'Breeding Program',
);

page_texts_ok(
    '/order/catalog_transgenic_lines.mas',
    'Filter by Item Type (wild type or transgenic plants):',
    'Filter by Vector Construct:',
    'Catalog Items (Accessions)',
    'Go to Manage Order Page',
    'Get Transgenic lines',
    'Type to Autocomplete',
);

page_texts_ok(
    '/order/create_item_file_dialog.mas',
    'Create Ordering Item File',
    'Download',
    'Close',
);

page_texts_ok(
    '/order/create_ontology_file_dialog.mas',
    'Create a Progress Ontology File for the Android Fieldbook App',
    'Type name here',
    'Create File',
    'Ontologies:',
    'File name:',
    'Submit',
);

page_texts_ok(
    '/order/edit_catalog_details_dialog.mas',
    'The catalog info was saved successfully.',
    'Edit Catalog Item Details',
    'Breeding Program:',
    'Additional Info:',
    'Material Source:',
    'released variety',
);

page_texts_ok(
    '/order/generate_identifier_barcode_dialog.mas',
    'Design Custom Barcodes Using a List',
    '32 Unique label Size Sticker Paper',
    'Enable 2D Barcode For FieldBook:',
    '20 label Size Sticker Paper',
    '32 label Size Sticker Paper',
    'Generate Identifier Barcode',
);

page_texts_ok(
    '/order/manage_catalog_usage_info.mas',
    'Each item in the catalog has \'available\' status by default. Vendors can change the status to \'unavailable\' by using editing catalog info dialog on each Catalog Item Details page. Once the item becomes unavailable, the request/shopping cart link is hidden and users are not able to order the item.',
    'Category: This field can be customized. Currently there are four categories for catalog items (released variety, pathogen assay, control, transgenic line), please contact us if you would like to add more categories.',
    'Contact Person Username: Each catalog item is associated with a vendor (please use username). When a user requests this item. The vendor is notified by email. Ordering details can be viewd on the Manage Orders page',
    'When you add new items, \'Item Type\', \'Material Type\', \'Species\' and \'Variety\' fields will be filled automatically based on item stock type and associated info stored in the database.',
    'Item Name: This version of catalog allows only accesssion, seedlot, population, vector_construct stock type. If you would like to add more stock types, please contact us.',
    'You can choose one of the three methods for adding catalog item(s) based on the number of items and details.',
);

page_texts_ok(
    '/order/order_details.mas',
    'Go to Manage Order Page',
    'Submitted Date',
    'Sent Order to',
    'Ordered by',
    'Comments',
    'Details',
);

page_texts_ok(
    '/order/re_open_dialog.mas',
    'The order has been re-opened.',
    'Re-Open Order',
    'Success',
    'Submit',
    'Close',
);

done_testing;
