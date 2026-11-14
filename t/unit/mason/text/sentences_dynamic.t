=head1 NAME

t/unit/mason/text/sentences_dynamic.t - dynamic templates: sentences appear in the user's language

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
    '/dynamic/solcyc.mas',
    'SolCyc is a collection of Pathway Genome Databases (PGDBs) for {family} species generated using {link}Pathway Tools{end_link} software from {link2}SRI International{end_link2}, the same software that is used in {link3}AraCyc{end_link3} for {i}{arabidopsis}{end_i} and {link4}EcoCyc{end_link4} for {i}{ecoli}{end_i}.',
    'Note the availability of the {link}Omics viewer{end_link}, which allows microarray, gene chip, proteomics, and metabolomic information to be overlaid over the pathway overview diagrams.',
    'We currently maintain a Perl interface and a Java interface for Pathway Tools: {link}JavaCyc{end_link} and {link2}PerlCyc{end_link2}.',
    'Currently, databases for tomato, potato, and pepper are available, generated from the respective genome annotations.',
    'Databases that have received significant curation are marked with a {span}{tier}{end_span}.',
    'More information is available on the {link}software downloads{end_link} page.',
);

done_testing;
