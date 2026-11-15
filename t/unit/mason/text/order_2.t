=head1 NAME

t/unit/mason/text/order_2.t - order templates, part 2 of 2: the text is shown in the user's language

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
    '/order/re_order_dialog.mas',
    'Ordering Information',
    'Your Order',
    'Submit',
    'Close',
);

page_texts_ok(
    '/order/stocks.mas',
    'The order has been updated.',
    'Your Completed Orders',
    'Your Current Orders',
    'Go to Catalog Page',
    'Completed Date',
    'Submitted Date',
);

page_texts_ok(
    '/order/upload_catalog_items_dialog.mas',
    'Catalog Items may be uploaded in an Excel file (.xls or .xlsx)',
    'The first row (header) must contain the following:',
    'The catalog items were saved successfully.',
    'Upload Catalog Items File Error',
    'Upload File (.xls or .xlsx):',
    'File Format Information',
);

done_testing;
