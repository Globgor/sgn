=head1 NAME

t/unit/mason/text/sentences_tools_qualityControl.t - tools/qualityControl templates: sentences appear in the user's language

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
    '/tools/qualityControl/dataset_quality_control.mas',
    'To validate a dataset you will need privilieges as {bold}CURATOR{end_bold} or {bold}BREEDER{end_bold}.',
    'Clicking on {bold}\'Select Other Traits\'{end_bold} you will see available traits in your dataset.',
    'If you want to ignore this step, please click on {bold}\'Next step\'{end_bold} button.',
    'Only {bold}CURATORS{end_bold} are allowed to restore the dataset to original values.',
);

done_testing;
