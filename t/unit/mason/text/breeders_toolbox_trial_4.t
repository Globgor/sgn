=head1 NAME

t/unit/mason/text/breeders_toolbox_trial_4.t - breeders_toolbox/trial templates, part 4 of 7: the text is shown in the user's language

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
    '/breeders_toolbox/trial/genotype_comparison_workflow.mas',
    'Compare Genotypic Marker Composition On Saved Measurements',
    'Select the input measurements to use',
    'Compute Genotypes From Parents(s):',
    'Accessions (Leave empty for all):',
    'Only genotypes of dosage 0 or 2',
    'Select the accessions to use',
);

page_texts_ok(
    '/breeders_toolbox/trial/greenhouse_add_additional_accessions_dialog.mas',
    'add additional plants for accessions already in the greenhouse',
    'The additional stocks were added successfully.',
    'Default Number of Plants:',
    'add additional accessions',
    'Addition Type:',
    'Select a type',
);

page_texts_ok(
    '/breeders_toolbox/trial/jbrowse_instance.mas',
    '[loading...]',
);

page_texts_ok(
    '/breeders_toolbox/trial/management_factor_details.mas',
    'Treatment Description',
    'Treatment Date',
    'Treatment Name',
    'Treatment Type',
    'Treatment Year',
);

page_texts_ok(
    '/breeders_toolbox/trial/numerical_derivatives_row_and_column_workflow.mas',
    'Numerical Derivatives Across Row and Columns On Saved Measurements',
    'Select the input measurements to calculate derivatives for',
    'Calculate Numerical Derivatives Across Row and Columns',
    'First 2D Derivative',
    'Compute and Save!',
    'Derivative:',
);

component_compiles_ok('/breeders_toolbox/trial/phenotype_heatmap.mas');

page_texts_ok(
    '/breeders_toolbox/trial/phenotype_summary.mas',
    'Copy Selected Results to a List',
    'Group by treatments',
    'Choose Date Range:',
    'Group by accession',
    'Raw Data Histogram',
    'Percent Missing',
);

page_texts_ok(
    '/breeders_toolbox/trial/repetitive_measurements_data.mas',
    'View plots for repetitive measurement traits',
    'Repetitive Measurements Level:',
    'Observation Level:',
    'DateRange Slider:',
    'Tissue Samples',
    'Average value',
);

page_texts_ok(
    '/breeders_toolbox/trial/saved_measurement_analysis.mas',
    'Analysis tools on saved measurements',
);

page_texts_ok(
    '/breeders_toolbox/trial/set_phenotypes_fully_uploaded.mas',
    'Phenotypes Fully Uploaded?:',
    'Close',
    'Save',
    'Yes',
    'No',
);

page_texts_ok(
    '/breeders_toolbox/trial/summary_stock_entries.mas',
    'Download Entries',
    'Tissue Sample',
    'Accession',
    'Plant',
    'Plot',
);

page_texts_ok(
    '/breeders_toolbox/trial/time_series_accessions_workflow.mas',
    'Get Time-Series Plots For Accessions On Saved Measurements',
    'Select the input measurements to use in time series',
    'Accessions (Leave empty for all):',
    'Select the accessions to plot',
    'Use Cumulative Phenotype:',
    'Draw Error Bars:',
);

done_testing;
