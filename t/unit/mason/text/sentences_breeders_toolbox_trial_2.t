=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_trial_2.t - breeders_toolbox/trial templates, part 2 of 5: sentences appear in the user's language

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
    '/breeders_toolbox/trial/create_spreadsheet_dialog.mas',
    'Download Phenotype Spreadsheet for {trial}',
);

page_sentences_ok(
    '/breeders_toolbox/trial/download_layout_interface_dialog.mas',
    'Download {type} for {trial}',
    '{type} for {trial} Created',
    'Starting Plot:',
    'Plot Order:',
);

component_compiles_ok('/breeders_toolbox/trial/export_trial_to_expression_atlas.mas');

page_sentences_ok(
    '/breeders_toolbox/trial/files_section.mas',
    'No collections contain files from this trial yet. Files can be added to a collection from the {link}file collections page{end_link}.',
);

component_compiles_ok('/breeders_toolbox/trial/phenotype_heatmap.mas');

done_testing;
