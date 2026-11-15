=head1 NAME

t/unit/mason/text/scripts_order.t - scripts in the order templates: the script text is shown in the user's language

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
    '/order/add_catalog_item_dialog.mas',
    'Please provide contact username',
    'An error occurred adding item',
    'Please select a category',
    'Please provide a name',
);

page_script_texts_ok(
    '/order/add_catalog_using_list_dialog.mas',
    'Please provide contact username',
    'An error occurred adding item',
    'Please select a list type',
    'Please select a category',
    'Please select a list',
);

page_script_texts_ok(
    '/order/catalog.mas',
    'An error occurred saving your request',
    'An error occurred saving your order',
    'Error retrieving your cart',
    'Additional Info',
    'Material Source',
    'Material Type',
);

page_script_texts_ok(
    '/order/catalog_item_details.mas',
    'Really delete this catalog item? This action cannot be undone.',
    'An error occurred removing image',
    'An error occurred adding image',
    'Add or Remove Image',
    'Description',
    'Image',
);

page_script_texts_ok(
    '/order/catalog_transgenic_lines.mas',
    'An error occurred saving your request',
    'Please select a vendor',
);

page_script_texts_ok(
    '/order/edit_catalog_details_dialog.mas',
    'An error occurred adding item',
);

page_script_texts_ok(
    '/order/re_open_dialog.mas',
    'Please add comments for re-opening the order',
    'An error occurred re-opening the order',
);

page_script_texts_ok(
    '/order/re_order_dialog.mas',
    'An error occurred saving your request',
);

page_script_texts_ok(
    '/order/stocks.mas',
    'Please add comments for re-opening the order',
    'An error occurred updating the order',
    'Completion Date',
    'Submitted Date',
    'Order Details',
    'Order Number',
);

page_script_texts_ok(
    '/order/upload_catalog_items_dialog.mas',
    'Please select a file',
);

done_testing;
