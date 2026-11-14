=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_6.t - breeders_toolbox templates, part 6 of 6: sentences appear in the user's language

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
    '/breeders_toolbox/upload_transactions_dialogs.mas',
    '{bold}Note:{end_bold}To transfer seeds from existing seedlot to a previously stored plot, Please use {bold}Upload Seedlots Planted in Trial{end_bold} link in the Experimental Design section on the Trial Detail page.',
    'Must exist in the database. Seeds were used for this plot. You can also record seedlot used for each plot during uploading existing trial on the Manage Trials page',
    'Weight in grams of seedlot being transferred. Can be provided in conjunction with {amount}. Must provide a value for {amount} or {weight_gram} or both.',
    'Number of seeds being transaferred. Can be provided in conjunction with {weight_gram}. Must provide a value for {amount} or {weight_gram} or both.',
    'Number of seeds being transferred. Can be provided in conjunction with {weight_gram}. Must provide a value for {amount} or {weight_gram} or both.',
    'Weight in grams of seedlot being added. Can be provided in conjunction with {amount}. Must provide a value for {amount} or {weight_gram} or both.',
);

done_testing;
