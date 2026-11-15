=head1 NAME

t/unit/mason/text/barcode.t - barcode templates: the text is shown in the user's language

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
    '/barcode/index.mas',
    '32 Unique label Size Sticker Paper',
    'Download Plot Phenotyping Barcodes',
    'Add Text to Label, e.g. location:',
    'Enable 2D Barcode For FieldBook:',
    'Enter a List of Stock Names:',
    'Enter a List of Trial Names:',
);

page_texts_ok(
    '/barcode/multi_tool_input.mas',
    'Add New Location',
    'Add New Project',
    'Generate Form',
    'Location:',
    'Operator:',
    'Trait(s):',
);

page_texts_ok(
    '/barcode/printer_settings.mas',
    'Add text to label, e.g. location:',
    'Number of Label Columns Per Page:',
    'Number of Label Rows:',
    'Bottom Margin (mm):',
    'Right Margin (mm):',
    'Left Margin (mm):',
);

page_texts_ok(
    '/barcode/read.mas',
    'Scanning for Barcode...',
    'Barcode Reader',
    'Starting...',
);

page_texts_ok(
    '/barcode/stock_download_result.mas',
    'Download Barcodes',
);

page_texts_ok(
    '/barcode/trial_barcodes_download_result.mas',
    'Download Barcode Error:',
    'Download Trial Barcodes',
);

done_testing;
