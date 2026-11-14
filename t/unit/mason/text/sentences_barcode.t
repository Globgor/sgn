=head1 NAME

t/unit/mason/text/sentences_barcode.t - barcode templates: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

page_sentences_ok(
    '/barcode/index.mas',
    'Or Upload {font}Tab-delimited Text File{end_font} With Stock Names:',
    'Or Upload {font}Tab-delimited Text File{end_font} With Trial Names:',
);

component_compiles_ok('/barcode/stock_download_result.mas');

component_compiles_ok('/barcode/trial_barcodes_download_result.mas');

page_sentences_ok(
    '/barcode/unique_barcode_download.mas',
    'Download unique barcodes as a PDF file: {link}Download{end_link}',
);

done_testing;
