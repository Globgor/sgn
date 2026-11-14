=head1 NAME

t/unit/mason/text/breeders_toolbox_trial_3.t - breeders_toolbox/trial templates, part 3 of 7: the text is shown in the user's language

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
    '/breeders_toolbox/trial/download_phenotypes_dialog.mas',
    'Fast (Improves speed but may miss recent changes)',
    'Suppress User Defined Phenotype Outliers:',
    'For repeated measurements, return the:',
    'Include Intercrop Accessions:',
    '(Select none for all traits)',
    'Additional Search Options',
);

page_texts_ok(
    '/breeders_toolbox/trial/download_trials_phenotypes_dialog.mas',
    'Accession List (None gives all available accessions):',
    'Plant List (None gives all available plants):',
    'Trait List (None gives all available traits):',
    'Plot List (None gives all available plots):',
    'Suppress User Defined Phenotype Outliers:',
    'For repeated measurements, return the',
);

page_texts_ok(
    '/breeders_toolbox/trial/edit_fieldMap.mas',
    'Click on the change dimensions button to alter the dimensions of the field map, and the respective row and column attributes of the plots in your trial. Clicking on this button will open a dialogue that prompts you to enter an accession name if the change you are making will result in dimensions that are larger than the amount of plots in your trial. The result is that the map will fill in the extra space with filler plots, and the filler plots will have the accession entered in input in the dialogue.',
    'Field map is a tool that enable users to view the physical layout of plots in a trial. Maps can be generated on the fly while adding a trial or uploading a trial. Field map coordinates can also be uploaded independently after trials have been added or uploaded. It is a very intuitive, flexible and user friendly tool for manipulation/making changes to field trial layouts before phenotypes are uploaded.',
    'This button allows you to download an excel file which has an incrementally ordered list of the harvesting order for your trial based on the current layout of the field map. You can play around with the four options given to experiment with the different traversal patterns available. The harvesting order file will omit border plots, but it will include filler plots.',
    'This button allows you to download an excel file which has an incrementally ordered list of the planting order for your trial. It is very similar to the harvesting order, but since you will need to plant the borders too, it includes the border plots in the traversal of your map.',
    'These checkboxes allow you to add borders around your field map on any sides you would like. These plots are purely visual and have no real data associated with them. They will not be included in the database, but you can see them in your harvesting order if they are present.',
    'If your trial has trait data uploaded, you can view a heatmap of that data by selecting a trait from the dropdown menu. You will see a color weighting on the plots that corresponds with the value of each plot for a given trait.',
);

page_texts_ok(
    '/breeders_toolbox/trial/edit_trial_details_dialog.mas',
    'Error Saving Trial Details',
    'Indicates pending change',
    'Trial Will Be Genotyped:',
    'Trial Will Be Crossed:',
    'Edit Trial Details',
    'Breeding Program:',
);

page_texts_ok(
    '/breeders_toolbox/trial/export_trial_to_expression_atlas.mas',
    '3 Dimensions are: Traits, Row Number, Col Number',
    'First Select One or More Trials',
    'Export to Expression Atlas',
    'Go To Expression Atlas',
    'Select None for All',
    'Accession Name(s):',
);

page_texts_ok(
    '/breeders_toolbox/trial/files_section.mas',
    'Collections that contain at least one file from this trial',
    'Uploaded Phenotyping Files',
    'Uploaded Additional Files',
    'Phenotyping Spreadsheets',
    'Upload Phenotyping Files',
    'Data Collection Files',
);

page_texts_ok(
    '/breeders_toolbox/trial/generate_genotrial_barcode.mas',
    'Generate barcode for tissue samples and plate ID.',
    'Generate barcode for plots and accessions.',
    '32 Unique label Size Sticker Paper',
    'Generate genotyping plate barcode.',
    'Enable 2D Barcode For FieldBook:',
    'Print Duplicate Labels Per Row:',
);

page_texts_ok(
    '/breeders_toolbox/trial/generate_trial_barcode.mas',
    'Generate barcodes for cross unique ids, female parents and male parents in this crossing experiment.',
    '32 Unique label Size Sticker Paper',
    'Go To Label Designer (Recommended)',
    'Enable 2D Barcode For FieldBook:',
    'Print Duplicate Labels Per Row:',
    'Use Legacy Barcode Generator',
);

done_testing;
