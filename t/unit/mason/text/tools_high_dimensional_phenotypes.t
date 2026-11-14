=head1 NAME

t/unit/mason/text/tools_high_dimensional_phenotypes.t - tools/high_dimensional_phenotypes templates: the text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_texts_ok component_compiles_ok );

page_texts_ok(
    '/tools/high_dimensional_phenotypes/download_high_dim_phenotypes_dialogs.mas',
    'Query Associated Stocks (e.g. Your dataset contains accessions, however, the high-dim phenotypes are saved for tissue samples of the accession):',
    'This workflow will guide you through downloading high-dimensional data from the database.',
    'Select the type of high-dimensional data to download',
    'Select a protocol for the data to download',
    'High-dimensional phenotype data includes:',
    'Select a dataset for the data to download',
);

page_texts_ok(
    '/tools/high_dimensional_phenotypes/download_high_dim_phenotypes_relationship_matrix_dialogs.mas',
    'Query Associated Stocks (e.g. Your dataset contains accessions, however, the high-dim phenotypes are saved for tissue samples of the accession):',
    'This workflow will guide you through downloading a relationship matrix from high-dimensional data from the database.',
    'Download high dimensional phenotypes relationship matrix',
    'Download High-Dimensional Phenotype Relationship Matrix',
    'Select the type of high-dimensional data to download',
    'Select a protocol for the data to download',
);

page_texts_ok(
    '/tools/high_dimensional_phenotypes/upload_high_dim_spreadsheet_dialogs.mas',
    'The samples for which you are uploading high-dimensional phenotypes must exist in the database already. They can be field trial entities such as plot names, plant names, and tissue sample names. They can be genotyping plate well tissue sample names. They can also be sample names from a sampling trial in the database.',
    'e.g. This describes mode, instrument settings, calibration procedure. Also, describes how the files from the LCMS machine were transformed into peak area. Finally, describes how metabolite annotations were assigned to peaks',
    'Upload details about the metabolites in a tabular spreadsheet (.csv) format with the following columns:',
    'Upload details about the transcripts in a tabular spreadsheet (.csv) format with the following columns:',
    'Upload Transcriptomics in a tabular spreadsheet (.csv) format with the following columns:',
    'This workflow will guide you through uploading high-dimensional data into the database.',
);

done_testing;
