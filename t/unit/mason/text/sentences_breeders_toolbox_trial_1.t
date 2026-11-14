=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_trial_1.t - breeders_toolbox/trial templates, part 1 of 5: sentences appear in the user's language

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
    '/breeders_toolbox/trial/add_plants_per_plot.mas',
    'Upload plants to {trial} with number of plants per plot',
    'Upload plants to {trial} with plant index number',
    'Upload plants to {trial}',
    'Add plants to {trial}',
);

page_sentences_ok(
    '/breeders_toolbox/trial/add_plants_per_subplot.mas',
    'Upload plants to {trial} subplots with number of plants per subplot',
    'Upload plants to {trial} subplots with plant index number',
    'Upload plants to {trial} subplots',
    'Add plants to {trial} subplots',
);

page_sentences_ok(
    '/breeders_toolbox/trial/add_subplots_per_plot.mas',
    'Upload subplots to {trial} with number of subplots per plot',
    'Upload subplots to {trial} with subplot index number',
    'Upload subplots to {trial}',
    'Add subplots to {trial}',
);

page_sentences_ok(
    '/breeders_toolbox/trial/add_tissue_sample_per_plant.mas',
    'Add tissue samples to {trial}',
);

page_sentences_ok(
    '/breeders_toolbox/trial/create_datacollector_dialog.mas',
    'Download Datacollector for {trial}',
);

done_testing;
