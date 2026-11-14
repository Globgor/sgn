=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_2.t - scripts in the breeders_toolbox templates, part 2 of 4: the script text is shown in the user's language

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
    '/breeders_toolbox/delete_seedlots.mas',
    'An error occurred',
    'ERROR!',
);

page_script_texts_ok(
    '/breeders_toolbox/discard_seedlots.mas',
    'Please provide reason for discarding these seedlots',
    'An error occurred discarding seedlots',
    'Please select a list',
);

page_script_texts_ok(
    '/breeders_toolbox/discard_single_seedlot.mas',
    'Are you sure you want to UNDO marking this seedlot as DISCARDED ?',
    'Please provide reason for discarding this seedlot',
    'An error occurred processing your request',
    'An error occurred discarding seedlot',
    'Error retrieving seedlot info',
);

page_script_texts_ok(
    '/breeders_toolbox/download.mas',
    'The accession list could not be validated. Please correct the list(s) and try again',
    'The accession list did not pass validation. Please correct the list and try again',
    'The seedlot list did not pass validation. Please correct the list and try again',
    'You need to select a list of accessions and a protocol !',
    'You need to select an accession or a trial, or both!',
    'You need to select an accession list!',
);

page_script_texts_ok(
    '/breeders_toolbox/drone_run_project.mas',
    'Error saving details',
    'Details saved!',
);

page_script_texts_ok(
    '/breeders_toolbox/image_analysis_run.mas',
    'Could not load the image list.',
);

page_script_texts_ok(
    '/breeders_toolbox/location_edit.mas',
    'The NOAA NCDC authorization token may not be valid! We could not verify your NOAA StationID. Please contact us!',
    'Could not verify the NOAA StationID you provided, however, your details were still updated.',
    'An error occurred while storing the location details. Please try again later.',
    'A location abbreviation is required.',
    'A location longitude is required.',
    'A location altitude is required.',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_drone_imagery.mas',
    'Up not implemented if your first plot starts in bottom right. Please contact us or try rotating your image differently before assigning plot polygons (e.g. rotate image 90 degrees clockwise, then first plot starts in bottom left corner and plot assignment can follow going right).',
    'Down not implemented if your first plot starts in top right. Please contact us or try rotating your image differently before assigning plot polygons (e.g. rotate image 90 degrees clockwise, then first plot starts in bottom right corner and plot assignment can follow going left).',
    'Up not implemented if your first plot starts in bottom left. Please contact us or try rotating your image differently before assigning plot polygons (e.g. rotate image clockwise 90 degrees, then first plot starts in top-left corner and plot assignment can follow going right).',
    'Down not implemented if first plot starts in top left. Please contact us or try rotating your image differently before assigning plot polygons (e.g. rotate image 90 degrees clock-wise, then first plot starts in top right and you can go left for plot assignment).',
    'This only works for Micasense 5-band camera currently, where plot images are extracted for blue, green, red, NIR, and red-edge bands, and the standard process has been completed! So only select imaging events that meet this criteria!',
    'The standard process will continue in the background and may take some time. You can check the indicator on the manage aerial imagery page to see when it is complete.',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_images.mas',
    'Could not load recent analysis runs.',
    'Could not load image collections.',
    'Could not load collections.',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_odk_data_collection.mas',
    'Error retrieving available ODK crossing forms',
    'Error scheduling import of ODK crossing data.',
    'Error retrieving available ODK cross summary',
    'Error retrieving ODK phenotyping data.',
    'Error retrieving saved ODK ONA forms',
    'Error retrieving ODK crossing data.',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_phenotyping.mas',
    'Are you sure you want to delete all phenotype values related to this file from the database and make this file obsolete?',
    'Made phenotype file obsolete and deleted all related phenotype values in the database!',
    'Error deleting file and phenotypes!',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_plot_phenotyping.mas',
    'An error occurred retrieving trait value',
    'An error occurred saving trait value',
);

done_testing;
