=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_cross_2.t - breeders_toolbox/cross templates, part 2 of 3: sentences appear in the user's language

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
    '/breeders_toolbox/cross/index.mas',
    '{bold}WARNING!{end_bold} Changing the parameters can have unpredicatable results in downstream analyses if they are inconsistent with other data.',
);

page_sentences_ok(
    '/breeders_toolbox/cross/intercross_file_upload.mas',
    '{bold}Cross Unique ID:{end_bold} You can let database automatically generate cross unique IDs for you or you can set up your own cross unique IDs in the database before uploading Intercross file. For the auto-generated cross unique ID, cross unique ID is a combination of crossing experiment name and incremental suffix number.',
    '{bold}Intercross file is an CSV file (.csv).{end_bold} Crosses in an intercross file must be in the same crossing experiment.',
);

page_sentences_ok(
    '/breeders_toolbox/cross/target_numbers_upload.mas',
    'Target numbers of seeds/progenies may be uploaded in an Excel file (.xls or .xlsx)',
);

page_sentences_ok(
    '/breeders_toolbox/cross/target_numbers_usage_info_dialog.mas',
    '{bold}Using Lists of Accessions{end_bold}: You can indicate target numbers of seeds and/or progenies by using a list of female accessions and a list of male accessions. Please use "Using Lists to Record Target Numbers" link in this section',
    '{bold}Uploading Target Numbers{end_bold}: Target numbers of seeds/progenies can be uploaded to the database using a spreadsheet. Please use "Upload Target Numbers" link in this section',
);

done_testing;
