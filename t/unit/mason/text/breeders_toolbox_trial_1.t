=head1 NAME

t/unit/mason/text/breeders_toolbox_trial_1.t - breeders_toolbox/trial templates, part 1 of 7: the text is shown in the user's language

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
    '/breeders_toolbox/trial/accession_rank_workflow.mas',
    'Select the input measurements to use in ranking',
    'Rank Accessions On Saved Measurements',
    'Accessions (Leave empty for all):',
    'Select the accessions to rank',
    'Give weightings for traits',
    'Trait Weightings',
);

page_texts_ok(
    '/breeders_toolbox/trial/add_management_factor_dialog.mas',
    'e.g. Twice weekly on Mondays and Thursdays starting 1 July 2025',
    'e.g. Fertilizer Brand Sprayed with 20N40P50K',
    'Add Management Factor to Trial',
    'Management factor description:',
    'These can be modified later.',
    'Application start date:',
);

page_texts_ok(
    '/breeders_toolbox/trial/add_plants_per_plot.mas',
    'One plant per (row,column) coordinate. Rows and columns will be populated in a Cartesian pattern. Row and column numbers start at 1 within each plot. If adding additional plants, there must be enough spaces to accommodate both the previous plants and the new plants.',
    'Rows and columns are at the plot level if each plot contains multiple plants. If including this data, both fields must be present.',
    'Plant names may be uploaded in an Excel (.xls or .xlsx)',
    'The first row (header) should contain the following:',
    'Assign row and column data to plants within plots?',
    'This is for recording individual plants in a plot.',
);

page_texts_ok(
    '/breeders_toolbox/trial/add_plants_per_subplot.mas',
    'One plant per (row,column) coordinate. Rows and columns will be populated in a Cartesian pattern. Row and column numbers start at 1 within each subplot. If adding additional plants, there must be enough spaces to accommodate both the previous plants and the new plants.',
    'Rows and columns are at the subplot level if each subplot contains multiple plants. If including this data, both fields must be present.',
    'Plant names may be uploaded in an Excel file (.xls or .xlsx)',
    'This is for recording individual plants in a subplot.',
    'The first row (header) should contain the following:',
    'Assign row and column data to plants within plots?',
);

page_texts_ok(
    '/breeders_toolbox/trial/add_subplots_per_plot.mas',
    'Subplot names may be uploaded in an Excel file (.xls or .xlsx)',
    'The first row (header) should contain the following:',
    'This is for recording individual subplots in a plot.',
    'May be uploaded in an Excel file (.xls or .xlsx)',
    'Maximum number of subplots per plot:',
    'Inherits Treatment(s) From Plots:',
);

page_texts_ok(
    '/breeders_toolbox/trial/add_tissue_sample_per_plant.mas',
    'You can use the same tissue name, e.g. root and root, more than once below. The tissue name will still be unique because of a tissue index e.g. 1 and 2 added to the end.',
    'Number of tissue samples per plant:',
    'Inherits Treatment(s) From Plots:',
    'Close',
    'Save',
);

page_texts_ok(
    '/breeders_toolbox/trial/add_trial_treatment_dialogs.mas',
    'Please click the above button to generate the required treatment spreadsheet. Note that treatment lists can be made just like trait lists.',
    'The "Detailed" format includes a special header as well as additional columns for design information.',
    'To include timestamp information for your measurements, click the checkbox "Includes Timestamps".',
    'Treatment spreadsheet must be uploaded in .xls or .xlsx excel file format',
    'Two or more treatments can be uploaded at the same time.',
    '(tab-delimited text formats are NOT supported)',
);

done_testing;
