=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_genotyping_trials_2.t - breeders_toolbox/genotyping_trials templates, part 2 of 2: sentences appear in the user's language

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
    '/breeders_toolbox/genotyping_trials/upload_genotyping_data_dialogs.mas',
    'Exported Tissue Sample Name: The sample names in your VCF are {sample_names} that already exist in genotyping plates (e.g. 96 well plates) or sampling trials in the database. The sample names in your VCF file can be the {sample_name} triple pipe joined to the {accession_name} (e.g. {joined_names}) or just simply the {sample_name} corresponding to the genotyping plate well or sampling trial sample. This is the {strong}recommended format{end_strong}.',
    '{bold}Note:{end_bold} If your genotyping facility assigned facility marker names and facility sample names for the genotyping data generated, you have an option to directly use these facility names for uploading. After uploaded into database, the genotyping data will be automatically linked to the original marker names and sample names.',
    '{column} a reference to an entity in an external database (such as a matching gene entry in GrainGenes). The format of this value should be: {format} (such as {example}). The database name must already exist as an external database reference.',
    'If a marker name already exists in the selected protocol but its position, ref, or alt differs from this file. Note: chromosome reassignment is not supported; a marker will always be updated in its existing chromosome\'s storage row.',
    'The second step will be to upload the a file containing the metadata that are associated with each marker. The names of the markers in the file {strong}must match the marker names{end_strong} in the selected Genotyping Protocol.',
    '{bold}Optional columns:{end_bold} You can include additional marker information by selecting one or more column headers listed below. Please add the selected column(s) after "{column}" column.',
);

done_testing;
