=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_1.t - breeders_toolbox templates, part 1 of 6: sentences appear in the user's language

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
    '/breeders_toolbox/add_accessions_dialogs.mas',
    'The first row (header) must contain the {bold}{accession_column}{end_bold} and {bold}{species_column}{end_bold} columns. Additional information can be included by selecting optional column(s) (see below). :',
);

page_sentences_ok(
    '/breeders_toolbox/create_seedlots_from_trial_dialogs.mas',
    'Each seedlot needs to have its initial contents (either a count or a weight) set. You can either set the same initial value for each seedlot, use the value from one of the traits recorded for this trial, or compute a new value from the recorded traits for this trial. If you are creating a seedlot for each accession and select a trait or a computed value as their initial value, then the sum of the trait values for each of the accession\'s plots will be used. The contents of each seedlot can be modified in the table below before its creation.',
    'Use the following variables as substitutions for the trait values to compute a new value for the initial seedlot contents. If you are creating one seedlot {strong}per plot{end_strong}, then the single plot trait value will be used in the computation. If you are creating one seedlot {strong}per accession{end_strong}, then the sum of the trait values for each plot of that accession will be used in the computation.',
    'This workflow will guide you through the process of creating seedlots from the accessions in a field trial. You can create one new seedlot for each plot or unique accession in the trial. You can also set the initial contents (count or weight) of the seedlot as the value of a recorded trait from the trial.',
    'Confirm the attributes for the new seedlots in the table below. If something is incorrect, navigate to the previous step and correct the information. Once all the information is correct, continue to the next step to create the seedlots.',
    'The following metadata is required for each seedlot. Fill out the form at the top apply the metadata to all of the seedlots. Then, each seedlot can be manually modified in the table below.',
    '{strong}NOTE:{end_strong} The formula is evaluated using javascript, so any basic operators {operators} or javascript Math functions {example} can be used.',
);

component_compiles_ok('/breeders_toolbox/crossing_experiment_tree.mas');

page_sentences_ok(
    '/breeders_toolbox/derived_accession_usage_info_dialog.mas',
    '{bold}Additional Info Section:{end_bold} Both direct source of that derived accession and its origin are displayed in the Additional Info section. If the direct source is a plant or tissue sample, the original source will also be provided (e.g., if the direct source is a plant in a trial, the original source of that plant name can be accession, cross or family name).',
    '{bold}Originated from a cross or a family name:{end_bold} The female parent, male parent and cross type of the cross or family name are used as parents and cross type of the derived accession. If the derived accession is originated from a cross, the accession is also stored as a progeny of that cross.',
    '{bold}Using a List:{end_bold} You can add derived accessions by using a list of accessions, plants or tissue samples as the sources of new accessions. A form will be generated for you to fill out new accession names and description. Please see \'Using a List\' link.',
    '{bold}Pedigree:{end_bold} Pedigree information of each derived accession depends on stock type of the original source (accession or cross or family name).',
    '{bold}Derived from plant{end_bold}: e.g., new accessions derived from plants originated from crosses or family names in trials.',
    '{bold}Derived from accession{end_bold}: e.g., new accession derived from another accession because of a mutation.',
);

done_testing;
