=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_4.t - breeders_toolbox templates, part 4 of 6: sentences appear in the user's language

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
    '/breeders_toolbox/seedlot_details.mas',
    'Taken from this Seedlot ({name})',
    'Added to this Seedlot ({name})',
);

page_sentences_ok(
    '/breeders_toolbox/seedlots.mas',
    'Seedlot --> Trial: Find seedlots that provided seed to this trial',
    'Trial --> Seedlot: Find seedlots that are derived from this trial',
);

page_sentences_ok(
    '/breeders_toolbox/selection_index.mas',
    'The {bold}Calculate Rankings{end_bold} button will produce a SIN score and ranking for each accession, based on the selected parameters and phenotype means. The rankings and phenotype means are displayed in the {bold}Rankings{end_bold} and {bold}Unweighted Means{end_bold} tabs of the results section, where they can be manipulated, copied and downloaded. Below the results table, users have the option to {bold}save top ranked accessions to a list{end_bold}.',
);

done_testing;
