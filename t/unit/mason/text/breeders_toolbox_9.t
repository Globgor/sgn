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

done_testing;
