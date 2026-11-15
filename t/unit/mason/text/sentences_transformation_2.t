=head1 NAME

t/unit/mason/text/sentences_transformation_2.t - transformation templates, part 2 of 2: sentences appear in the user's language

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
    '/transformation/upload_qPCR_data_dialog.mas',
    '{column} (gene names in the spreadsheet must be stored in the database as genes in the vector construct or the selected endogenous control. {bold}Each vector construct can be associated with more than one gene by using comma-separated values (e.g., {example}).{end_bold})',
    'Cq data of an endogenous control ({gene_a}) and two targets ({gene_b} and {gene_c}). Each sample has two replicates. Note: there is no need to group the same replicate together as in the sample spreadsheet.',
    'For example:',
);

page_sentences_ok(
    '/transformation/upload_transformation_ids_dialog.mas',
    '{column} (if you would like to set any transformation identifier {bold}as a control{end_bold}, please indicate "{one}" for the "{column}" column. To {bold}set a control{end_bold} for any transformation ID, please use the link "Set Transformation Control" on the transformation ID detail page.)',
);

component_compiles_ok('/transformation/upload_transgenic_historical_data_dialog.mas');

done_testing;
