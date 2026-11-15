=head1 NAME

t/unit/mason/text/barcode_tool.t - barcode/tool templates: the text is shown in the user's language

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
    '/barcode/tool/cross.mas',
    'For each cross, scan the CROSS barcode, then the FEMALE barcode below, followed by the barcode of the female parent. Then, scan the MALE barcode, followed by the barcode of the male parent. (Note: the male and female information can be scanned in any order).',
    'scan barcode of female parent',
    'scan barcode of male parent',
    'Enter number of flowers',
    'CassavaBase Cross Tool',
);

page_texts_ok(
    '/barcode/tool/dna.mas',
    'Cassavabase DNA extraction tool',
    'COLUMN',
    'ROW',
);

page_texts_ok(
    '/barcode/tool/metadata.mas',
    'CASSAVABASE METADATA BARCODE SHEET',
    'Today\'s Date',
    'Location',
    'Operator',
    'Project',
);

page_texts_ok(
    '/barcode/tool/multi_tool.mas',
    'Scan the barcode for the plant to be phenotyped, then scan the phenotype barcode, then enter the number on the keypad',
    'Scan the following barcodes once',
    'CASSAVABASE MULTI-BARCODE SHEET',
    'Today\'s Date',
    'Location',
    'Operator',
);

page_texts_ok(
    '/barcode/tool/numberpad.mas',
    'Keypad',
);

page_texts_ok(
    '/barcode/tool/tool.mas',
    'CASSAVABASE BARCODE TOOL',
);

done_testing;
