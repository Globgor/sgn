=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_2.t - breeders_toolbox templates, part 2 of 6: sentences appear in the user's language

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
    '/breeders_toolbox/location_edit.mas',
    '{i}Optional:{end_i} Nearest NOAA Weather Station ID ({link}Search Here{end_link})',
);

page_sentences_ok(
    '/breeders_toolbox/manage_genotype_qc.mas',
    '{bold} Run genotype quality control{end_bold} with the qc markers by comparing with existing protocol in the database.',
    'This requires two files for the storage: {em}Intertek grid file{end_em} which has allele calls for each genotype.',
    'The second file is a {em}Map file{end_em} which has all the SNP information.',
);

component_compiles_ok('/breeders_toolbox/manage_genotyping.mas');

done_testing;
