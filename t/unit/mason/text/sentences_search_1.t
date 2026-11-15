=head1 NAME

t/unit/mason/text/sentences_search_1.t - search templates, part 1 of 2: sentences appear in the user's language

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
    '/search/advanced_search.mas',
    '{link}ESTs and libraries{end_link} - Find EST (Expressed Sequence Tag) libraries by keyword, e.g. library name, organism, tissue, development stage, or authors.',
    '{link}QTLs{end_link} - A web interface for uploading QTL raw data, on-the-fly QTL mapping and search interface for QTLs.',
    '{link}Genome features{end_link} - Search for many types of annotations and sequences.',
    '{link}Expression{end_link} - Search images contained in the SGN database.',
    '{link}Phenotypes{end_link} - Search for mutants, accessions, and traits.',
    '{link}Images{end_link} - Search images contained in the SGN database.',
);

component_compiles_ok('/search/quick_search.mas');

done_testing;
