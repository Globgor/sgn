=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_sampling_trials.t - breeders_toolbox/sampling_trials templates: sentences appear in the user's language

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
    '/breeders_toolbox/sampling_trials/create_sampling_trials_dialogs.mas',
    '{i}Optional{end_i} Sample Concentration (ng/ul): {small}(If you used the same conc for all samples){end_small}',
    '{i}Optional{end_i} Sampling Volume (ul): {small}(If you used the same vol for all samples){end_small}',
    '{i}Optional{end_i} Extraction: {small}(If used the same extraction for all samples){end_small}',
    '{i}Optional{end_i} Tissue: {small}(If used the same tissue for all samples){end_small}',
    '{i}Optional{end_i} Person: {small}(If same person prepared all samples.){end_small}',
    '{i}Optional{end_i} Notes: {small}(Additional notes for these samples.){end_small}',
);

done_testing;
