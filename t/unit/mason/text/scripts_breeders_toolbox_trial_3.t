=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_trial_3.t - scripts in the breeders_toolbox/trial templates, part 3 of 5: the script text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form, as a JSON string inside a script. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_script_texts_ok component_compiles_ok );

component_compiles_ok('/breeders_toolbox/trial/phenotype_heatmap.mas');

page_script_texts_ok(
    '/breeders_toolbox/trial/phenotype_summary.mas',
    'An error occured retrieving trait histogram data.',
    'Error retrieving traits assayed in this trial',
    'No data available',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/repetitive_measurements_data.mas',
    'Please select an end date to view repetitive measurements.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/set_phenotypes_fully_uploaded.mas',
    'An error occurred trying to set phenotypes fully uploaded.',
    'Successfully saved',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/time_series_accessions_workflow.mas',
    'Error doing time series accessions!',
    'Please select at least one trait!',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_accessions.mas',
    'Error retrieving accessions.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_audit.mas',
    'Transaction Code',
    'Logged in User',
    'Primary Key',
    'Operation',
    'Timestamp',
    'Username',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_controls.mas',
    'Error retrieving controls.',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_controls_count.mas',
    'Error displaying controls count',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_coords.mas',
    'Psudo row and column numbers have been used in displaying the field map. Plots row and column numbers were generated from block_number and displayed in zigzag format. You can upload row and column numbers for this trial to reflect the field layout.',
    'An error occurred replacing plot accession',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_create_dialogs.mas',
    'No Locations Selected',
);

page_script_texts_ok(
    '/breeders_toolbox/trial/trial_deletion.mas',
    'An error occurred deleting trait',
    'No trait selected',
);

done_testing;
