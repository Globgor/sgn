=head1 NAME

t/unit/mason/text/breeders_toolbox_7.t - breeders_toolbox templates, part 7 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/manage_sequence_metadata.mas',
    'Upload and query sequence metadata.',
    'Manage Sequence Metadata',
);

page_texts_ok(
    '/breeders_toolbox/manage_transcriptomics.mas',
    'Upload and download transcriptomic data.',
    'Manage Transcriptomic Data',
);

page_texts_ok(
    '/breeders_toolbox/manage_trial_phenotyping.mas',
    'Enter a List of Trait Names:',
    'Or Paste From a List:',
    'Stored trait value:',
    'Enter trait value:',
    'Or Use Trait List:',
    'Traits assayed',
);

page_texts_ok(
    '/breeders_toolbox/manage_upload.mas',
    'Upload progeny names that already EXIST in database',
    'Upload progeny names that are NOT in database',
    'Upload Cross Info of Existing Crosses',
    'Create An IGD Genotyping Plate',
    'Create Phenotyping Spreadsheet',
    'Go To Manage Genotyping Plates',
);

page_texts_ok(
    '/breeders_toolbox/management_factor.mas',
    'View and edit the public data agreement on this experiment.',
    'View experimental design information for this treatment.',
    'View and edit basic information about the treatment.',
);

page_texts_ok(
    '/breeders_toolbox/noaa_ncdc_analysis.mas',
    'Daily Temperature and Precipitation Chart',
    'Window Start (YYYY-MM-DD) (Optional):',
    'Window End (YYYY-MM-DD) (Optional):',
    'Analyze NOAA NCDC Weather Data',
    'Cumulative Values by Year:',
    'Start Date (YYYY-MM-DD):',
);

page_texts_ok(
    '/breeders_toolbox/progress.mas',
    'Breeding Progress',
    'Select Trait',
    '[loading...]',
    'Show Graph',
    'Show Stats',
);

page_texts_ok(
    '/breeders_toolbox/radargraph.mas',
    'Render Graph',
    '[loading...]',
    'Radar Graph',
);

page_texts_ok(
    '/breeders_toolbox/seedlot_details.mas',
    'You need to be logged in or you do not have sufficient privileges to mark this seedlot as DISCARDED.',
    'Taken From Existing Seedlot or the Same Accession/Cross:',
    'Only showing seedlots with matching content',
    'Transaction Amount (number of materials):',
    'The transaction was saved successfully.',
    'Starting Amount (number of materials):',
);

page_texts_ok(
    '/breeders_toolbox/seedlots.mas',
    'Make sure your seedlots are in the database. Use "Add New Seedlot" to add a single seedlot or "Upload New Seedlots" to add many.',
    'It is also possible to manually enter a transaction by going to the seedlot detail page and clicking "Add New Transaction".',
    'The inventory app is currently not available but you can continue using it if it is installed on your tablet device.',
    'You need to be logged in or you do not have sufficient privileges to mark seedlots as DISCARDED using lists.',
    'Plant material can be transferred into and out of a seedlot. Such as from a seedlot into a plot.',
    'Make sure your seedlots are barcoded. You can print these barcodes from the database.',
);

page_texts_ok(
    '/breeders_toolbox/seedlots_section.mas',
    'Copy Seedlots to a List',
    '[LOADING...]',
);

page_texts_ok(
    '/breeders_toolbox/selection_index.mas',
    'Accessions with missing phenotypes are excluded by default. If the allow missing phenotypes option is enabled, the rankings will expand to include any accessions which were planted in the trial but which are missing observations for one or more of the traits in the index. Missing phenotypes will not contribute to the SIN score, so the final SIN interpretation should change accordingly.',
    'A selection index is a method of optimizing selection by acting on multiple traits simultaneously. An index can accomplish this because it incorporates multiple sources of information about an individual into a single best linear prediction of breeding value. This selection index tool combines phenotypic observations with index coefficients into a selection index, SIN, of the form:',
    'The save option allows a user to enter a name, and save the current index formula as a dataset. It is then available for later use, and visible in their list manager where it can be edited or shared with others.',
    'By default the unadjusted mean of phenotypic observations is used. For each trait, users have the option to normalize these means using a control mean or the overall trial mean.',
    'One for each trait. Must be a positive or negative number, and should reflect the importance of the trait in the index. If left blank it defaults to 1.',
    'The select option allows a user to load a saved formula, which will consist of a saved combination of traits, coefficients, and normalization options.',
);

done_testing;
