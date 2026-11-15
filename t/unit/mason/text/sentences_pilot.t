=head1 NAME

t/unit/mason/text/sentences_pilot.t - Sentence pilot: sentences appear in the user's language

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
    '/breeders_toolbox/breeder_search_page.mas',
    'Download the original archived VCF files of entire genotyping projects. Select {strong}one or more genotyping projects and/or genotyping protocols{end_strong} to download a VCF file of any matching project(s).',
    'Download matching genotype records from the database. Select a {strong}single genotyping protocol{end_strong} and {strong}one or more accessions{end_strong} to download the matching genotype data.',
);

done_testing;
