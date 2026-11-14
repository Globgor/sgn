=head1 NAME

t/unit/mason/text/sentences_about_sgn.t - about/sgn templates: sentences appear in the user's language

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

component_compiles_ok('/about/sgn/index.mas');

page_sentences_ok(
    '/about/sgn/tools.mas',
    'SGN makes available a wide range of web-based bioinformatics tools for use by anyone, listed {link}here{end_link}. Some of our most popular tools include {link2}BLAST{end_link2} searches, the {link3}SolCyc biochemical pathways database{end_link3}, a {link4}CAPS experiment designer{end_link4}, an {link5}Alignment Analyzer{end_link5} and {link6}browser for phylogenetic trees{end_link6}. The {link7}VIGS tool{end_link7} can help predict the properties of VIGS (Viral Induced Gene Silencing) constructs.',
    'SGN is a home for Solanaceae and closely related genomes, such as selected Rubiaceae genomes (e.g., {i}Coffea{end_i}). The {link}tomato{end_link}, {link2}potato{end_link2}, {link3}pepper{end_link3}, and {link4}eggplant{end_link4} genome are examples of genomes that are currently available. If you would like to include a Solanaceae genome that you sequenced in SGN, please {link5}contact us{end_link5}.',
    'SGN houses EST collections for tomato, potato, pepper, eggplant and petunia and corresponding unigene builds. EST sequence data and cDNA clone resources greatly facilitate cloning strategies based on sequence similarity, the study of syntenic relationships between species in comparative mapping projects, and are essential for microarray technology.',
    'We have developed simple web interfaces for the SGN user-community to submit, annotate, and curate the Solanaceae locus and phenotype databases. Our goal is to share biological information, and have the experts in their field review existing data and submit information about their favorite genes and phenotypes.',
    'The data in SGN have been submitted by many different research groups around the world which are acknowledged on the corresponding pages on SGN. If you have data you would like to submit for display on SGN, please use the {link}contact us{end_link} web form.',
    'For more information about SGN datasets, see the {link}SGN Data Overview{end_link}. Entire datasets can also be downloaded from our {link2}FTP site{end_link2}.',
);

done_testing;
