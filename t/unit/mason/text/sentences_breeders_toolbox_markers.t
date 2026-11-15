=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_markers.t - breeders_toolbox/markers templates: sentences appear in the user's language

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
    '/breeders_toolbox/markers/manage_markers.mas',
    'From the "Manage Marker Alleles" screen find "{bold}Search for accessions{end_bold} with specific genotype" and select "GO".',
    'Lists of Marker Alleles can be used to {bold}Search for accessions{end_bold} containing the specified genotypes.',
    'These lists can also be used in the {bold}Search Wizard{end_bold} to filter the results of genotype downloads.',
    '{bold}Create a list{end_bold} of accessions from a genotype protocol.',
    'Select {bold}Add Marker Alleles to an existing List{end_bold}.',
    'Select {bold}Create a new List of Marker Alleles{end_bold}.',
);

done_testing;
