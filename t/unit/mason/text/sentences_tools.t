=head1 NAME

t/unit/mason/text/sentences_tools.t - tools templates: sentences appear in the user's language

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

component_compiles_ok('/tools/boxplotter.mas');

component_compiles_ok('/tools/fieldmap.mas');

component_compiles_ok('/tools/image_analysis.mas');

page_sentences_ok(
    '/tools/report.mas',
    'This is a {bold}CURATOR\'s{end_bold} tool which allows you to create customized reports based on scripts tailored to the specific instructions of your Breedbase instance. These reports are designed to meet your unique needs and provide detailed insights into your data. If you require a new report type or have specific requirements, please reach out to the Breedbase team for assistance.',
);

page_sentences_ok(
    '/tools/tc_convert_deprecated.mas',
    'SGN no longer maintains a specific tool for mapping between these two databases. Instead, for users to establish correspondences between these two sets, we recommend using the BLAST tools available on each of these sites.',
    'SGN and {link}the Gene Index Project (TGI){end_link}, now at {link2}DFCI{end_link2}, maintain independent unigene/TC databases, entries in which tend to have common member ESTs.',
    'Use the TGI TC sequences as input to the {link}SGN BLAST tool{end_link}, selecting one of the SGN unigene data sets.',
    'Use the SGN-U sequences as input to the BLAST tool at {link}the TGI site{end_link}.',
);

page_sentences_ok(
    '/tools/trait_designer.mas',
    'Check the {link}trait search page{end_link} to see if your trait has already been made before designing new traits.',
);

done_testing;
