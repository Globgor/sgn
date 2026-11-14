=head1 NAME

t/unit/mason/text/analyses.t - analyses templates: the text is shown in the user's language

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
    '/analyses/analysis_calculate_statistics.mas',
    'Genotyping Protocol To Calculate Genomic Relationship Matrix (optional. If none selected, an identity matrix is used):',
    'Go To Save Analysis Results For Genetic and Environment BLUPS and Residuals',
    'How to calculate the relationship matrix with high-throughput phenotypes:',
    'Observation Variables Phenotyped in the Selected Field Trial(s):',
    'Select a continuous trait (e.g. soil elevation curvature)',
    'Select the observation variable you are interested in',
);

page_texts_ok(
    '/analyses/analysis_details.mas',
    'Breeding Program',
    'Result Summary',
    'Analysis Name',
    'Description',
    'Protocol',
    'Created',
);

component_compiles_ok('/analyses/detail.mas');

page_texts_ok(
    '/analyses/index.mas',
    'Your Analyses and Analysis Models',
    'Single/Multi Trial GEBV Analysis',
    'Drone Imagery Statistics',
    'Upload Analysis',
    'Analysis Name',
    'Your Analyses',
);

page_texts_ok(
    '/analyses/model_deletion.mas',
    'Are you sure you want to delete this model?',
    'Proceed with deletion below...',
    'Delete Model',
    'Delete',
    'Close',
);

page_texts_ok(
    '/analyses/model_detail.mas',
    'View basic information about the model.',
    'View analyses derived from this model.',
    'Delete model from the database.',
);

page_texts_ok(
    '/analyses/model_detail_page_analyses_section.mas',
    'Analysis Description',
    'Analysis Name',
);

page_texts_ok(
    '/analyses/model_detail_page_section.mas',
    'Model Properties',
    'Description',
    'Model Files',
    'Model Name',
    'Model Type',
);

page_texts_ok(
    '/analyses/model_details.mas',
    'Model Description',
    'Model Properties',
    'Model Files',
    'Model Name',
    'Model Type',
);

page_texts_ok(
    '/analyses/store_new_analysis_values_and_model.mas',
    'An analysis is stored independently; however, it maintains associations to the results for the accessions and traits involved. In the case where a model is being trained for predictions e.g. genomic selection or CNN image predictions, those trained model weights can be saved.',
    'This is an optional step and is only available when there are actual results to save. Please move on to saving the model weights if there are no results to save.',
    'This step may be pre-populated if you are using a model that is already saved in the database. If there is no input enabled, move to the next step.',
    'This workflow will guide you through storing a new analysis and the results, and saving model weights',
    'Analysis Design (If left blank, design will be created using above accession names):',
    'Compose Trait Info With Time Term(optional):',
);

page_texts_ok(
    '/analyses/upload_analysis_dialogs.mas',
    'You should have a spreadsheet (.csv) where the first column names the accession names or plots, and the subsequent columns have result values.',
    '(1) Auxiliary File To Archive (optional) (e.g. log file, param file, grm input file):',
    '(2) Auxiliary File To Archive (optional) (e.g. log file, param file, grm input file):',
    '(3) Auxiliary File To Archive (optional) (e.g. log file, param file, grm input file):',
    'This workflow will guide you through uploading an analysis to the database',
    'Model File To Archive (optional) (this should be a model weights file):',
);

done_testing;
