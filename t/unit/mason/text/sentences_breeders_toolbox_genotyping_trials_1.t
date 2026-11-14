=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_genotyping_trials_1.t - breeders_toolbox/genotyping_trials templates, part 1 of 2: sentences appear in the user's language

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
    '/breeders_toolbox/genotyping_trials/create_genotyping_trial_dialogs.mas',
    '{i}Optional{end_i} Blank Well: {small}(Cornell IGD requires a specific well to be blank.){end_small}',
    '{i}Optional{end_i} Extraction: {small}(If used the same extraction for all wells){end_small}',
    '{i}Optional{end_i} Tissue: {small}(If used the same tissue for all wells){end_small}',
    '{i}Optional{end_i} Person: {small}(If same person prepared all wells.){end_small}',
    '{i}Optional{end_i} Notes: {small}(Additional notes for these wells.){end_small}',
    '{i}Optional{end_i} NCBI Taxonomy ID: {small}(Official NCBI ID.){end_small}',
);

component_compiles_ok('/breeders_toolbox/genotyping_trials/format/as_table.mas');

component_compiles_ok('/breeders_toolbox/genotyping_trials/genotyping_trial_tree.mas');

page_sentences_ok(
    '/breeders_toolbox/genotyping_trials/submit_plates_dialog.mas',
    'Please click {link}HERE{end_link} to complete your order.',
);

done_testing;
