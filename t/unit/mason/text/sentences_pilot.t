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

page_sentences_ok(
    '/breeders_toolbox/trial/edit_fieldMap.mas',
    'An accession used in a trial can be replaced by a new accession or another accession from the trial. When this replace option is used, it replaces every instances (plots and plants) of that accession in the trial. To do this, {bold}click on the Edit Field Map link{end_bold} by the top right of the physical trial layout section; {bold}click on Replace Accession button{end_bold}; {bold}select accession{end_bold} to replace from the trial and {bold}provide a new accession{end_bold} (must already exit in the database); {bold}click on Replace Trial Accession button{end_bold} to complete the operation.',
    'A plot accession can be replaced by an accession within or outside of the trial. To do this, {bold}click on the plot{end_bold} and {bold}provide the name of the new accession{end_bold} (must already exist in the database).',
    '- {bold}Input boxes{end_bold} used within the field map tool will automatically ({bold}autocomplete{end_bold}) give accession name options from the database when you start typing the accession name.',
    '- You have to be a {bold}curator{end_bold} or a {bold}submitter and associated to the breeding program{end_bold} of the trial to use the features of this tool.',
    'Edit Field Map For {trial}',
);

page_sentences_ok(
    '/tools/treatment_designer.mas',
    'Check the {link}treatment search page{end_link} to see if your treatment has already been made before designing new treatments.',
);

done_testing;
