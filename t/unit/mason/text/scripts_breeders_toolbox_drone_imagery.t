=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_drone_imagery.t - scripts in the breeders_toolbox/drone_imagery templates: the script text is shown in the user's language

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

page_script_texts_ok(
    '/breeders_toolbox/drone_imagery/drone_imagery_analysis.mas',
    'The MARSS model fit and prediction only works for Time Series traits! Please go to Trait Selection and select time series traits.',
    'Saving spatial BLUPs currently only implemented for a single trial, so only select one field trial in your analysis',
    'You can only use pedigree info in the relationship matrix if you will compute the genotypes from the parents!',
    'Please select at least three phenotypes to use in random regression phenotype correlation structure!',
    'You can only use parental relationship matrices if you will compute the genotypes from the parents!',
    'Please only select a single field trial for now!',
);

page_script_texts_ok(
    '/breeders_toolbox/drone_imagery/drone_imagery_analytics.mas',
    'Please select at least three phenotypes to use in random regression permanent environment phenotype correlation structure!',
    'You can only use pedigree info in the relationship matrix if you will compute the genotypes from the parents!',
    'You can only use parental relationship matrices if you will compute the genotypes from the parents!',
    'Please give an analytics name OR select a previously saved analytics report, not both!',
    'Please give an analytics name or select a previously saved analytics report.',
    'Please only select a single field trial for now!',
);

page_script_texts_ok(
    '/breeders_toolbox/drone_imagery/drone_imagery_export_imaging_events.mas',
    'Please select at least one imaging event.',
    'Error exporting imaging events!',
);

page_script_texts_ok(
    '/breeders_toolbox/drone_imagery/raw_image_section.mas',
    'Error getting drone run band summary images!',
    'Are you sure you want to remove this image?',
    'Error removing drone image!',
);

page_script_texts_ok(
    '/breeders_toolbox/drone_imagery/standard_process_raw_images.mas',
    'Down not implemented if your first plot starts in top right. Please contact us or try rotating your image differently before assigning plot polygons (e.g. rotate image 90 degrees clockwise, then first plot starts in bottom right corner and plot assignment can follow going left).',
    'Down not implemented if first plot starts in top left. Please contact us or try rotating your image differently before assigning plot polygons (e.g. rotate image 90 degrees clock-wise, then first plot starts in top right and you can go left for plot assignment).',
    'Click the four corners of 10 single plots at random in the current imaging pass. For each single plot click the top left, then the top right, then the bottom right, then the bottom left.',
    'Please select a previously saved template before trying to apply it. If there is not a template listed, then you can create one using the templating tool above.',
    'Second plot cannot follow right or up from first plot if the first plot starts at the top right, because that is physically impossible.',
    'Second plot cannot follow left or up from first plot if the first plot starts at the top left, because that is physically impossible.',
);

page_script_texts_ok(
    '/breeders_toolbox/drone_imagery/upload_drone_imagery_dialogs.mas',
    'This can potentially take time to complete. Ensure the file(s) have completely transferred to the server before closing this tab.',
    'If you selected a drone run, do not try to make a new one at the same time!',
    'Please select a zipfile of Micasense radiocalibration panel images',
    'Please select the number of drone run bands you will upload',
    'Please select whether you are uploading orthomosaic images.',
    'Please give a vehicle name and description!',
);

done_testing;
