=head1 NAME

t/unit/mason/text/stock_2.t - stock templates, part 2 of 2: the text is shown in the user's language

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
    '/stock/phenotypes.mas',
    'Trait code',
    'Trait',
    'Trial',
    'Value',
);

page_texts_ok(
    '/stock/population_delete.mas',
    'Delete Population',
);

page_texts_ok(
    '/stock/population_seedlots.mas',
    'Download Seedlot Info',
);

component_compiles_ok('/stock/related_stock.mas');

page_texts_ok(
    '/stock/sequencing_status.mas',
    'Enter sequencing info for accession:',
    'Funding organization project ID',
    'Funding agency project id:',
    'Sequencing organization',
    'Funding organization',
    'Genbank accession:',
);

page_texts_ok(
    '/stock/stockprops.mas',
    'Add Property',
    'Submit',
    'submit',
    'Close',
);

page_texts_ok(
    '/stock/traits.mas',
    'Standard deviation',
    'Average Value',
    'Trait name',
    'Trait ID',
    'Count',
);

page_texts_ok(
    '/stock/trials.mas',
    'Trial name',
    'Location',
    'Details',
    'Trials',
);

page_texts_ok(
    '/stock/upload_additional_accessions_file.mas',
    'Accession Related Images, such as a physical field image or an aerial picture of the field.',
    'Accession Related Documentation, such as protocols or permits for the accession.',
    'Accession Related Reports, such as supplementary information or publications.',
    'This is for uploading any additional files you may have for the accession.',
    'Possible additional files inlude, but are not limited to:',
    'Accession Related Recordings, whether audio or video.',
);

page_texts_ok(
    '/stock/vector_related_accessions.mas',
    'Copy Accessions to a List',
);

done_testing;
