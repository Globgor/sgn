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
    '/breeders_toolbox/index.mas',
    'The purpose of this page is to give breeders direct links to breeder-relevant tools and data on SGN. It is a work in progress and your feedback or suggestions are welcome to build this into a comprehensive, easy to use and breeder-friendly resource.',
    '{link}QTL data submssion{end_link} and on-the-fly QTL analysis {link2}for Solanaceae traits{end_link2}',
    'Browse available controlled vocabularies using the SGN {link}Ontology browser{end_link}',
    '{link}Tomato Analyzer{end_link} - software for scoring fruit shape and other shapes.',
    '{link}TomatoMap.Net{end_link} - a site for Tomato Genetics at Ohio State University.',
    '{link}SolCAP{end_link} - the official SolCAP website at Michigan State University.',
);

page_sentences_ok(
    '/breeders_toolbox/location_edit.mas',
    '{i}Optional:{end_i} Nearest NOAA Weather Station ID ({link}Search Here{end_link})',
);

page_sentences_ok(
    '/breeders_toolbox/manage_drone_imagery.mas',
    'Growing Degree Days (GDD) are calculated using the average high and low temperature for each day from planting date to the date of the imaging event. {link}More Information on GDD{end_link}. The average daily high and low temperature is fetched from the {link2}NOAA NCDC{end_link2}.',
    'It will take time to finish processing your imaging event and calculating phenotypes for all plot polygon images, vegetative indices, and processing combinations. Once it is complete, the "Processing Icon" on the Manage->Aerial Imagery page will disappear for the imaging event.',
    '{bold}1.{end_bold} Click on the two right-most, highest peaks in the histogram. The right most peak represents the pixels we are interested in, while the peak immediately to the left of that peak represents the soil background.',
    '{bold}3.{end_bold} If the image looks good with the applied threshold, click Save. Otherwise, you can start over.',
    'The average daily precipitation is fetched from the {link}NOAA NCDC{end_link}.',
    '{bold}2.{end_bold} Click on the "Find Minimum" button.',
);

page_sentences_ok(
    '/breeders_toolbox/manage_genotype_qc.mas',
    '{bold} Run genotype quality control{end_bold} with the qc markers by comparing with existing protocol in the database.',
    'This requires two files for the storage: {em}Intertek grid file{end_em} which has allele calls for each genotype.',
    'The second file is a {em}Map file{end_em} which has all the SNP information.',
);

component_compiles_ok('/breeders_toolbox/manage_genotyping.mas');

done_testing;
