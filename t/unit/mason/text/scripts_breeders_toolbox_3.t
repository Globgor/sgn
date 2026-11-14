=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_3.t - scripts in the breeders_toolbox templates, part 3 of 4: the script text is shown in the user's language

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
    '/breeders_toolbox/manage_roles.mas',
    'Really delete this role association?',
    'Association deleted.',
    'Role Added for User!',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_samples.mas',
    'Automatic export to genotyping vendors is currently not avaiable; however, you can download the layout and submit to vendor manually.',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_trial_phenotyping.mas',
    'An error occurred retrieving trial information',
    'An error occurred retrieving trait value',
    'An error occurred saving trait value',
);

page_script_texts_ok(
    '/breeders_toolbox/noaa_ncdc_analysis.mas',
    'Could not verify the NOAA StationID you provided. Go to Manage->Locations and make sure your location has a valid NOAA station id!',
    'No NOAA NCDC station id for this location. Go to Manage->Locations and edit your location to add a valid NOAA station id!',
    'The NOAA NCDC authorization token may not be valid! We could not verify your NOAA StationID. Please contact us!',
    'There was an error getting NOAA analysis!',
    'Error getting NOAA NCDC ID for location!',
    'Error getting NOAA NCDC analysis!',
);

page_script_texts_ok(
    '/breeders_toolbox/progress.mas',
    'observations [count]',
    'cannot show graph',
    'std dev',
);

page_script_texts_ok(
    '/breeders_toolbox/radargraph.mas',
    'Please select at least one dataset!',
);

page_script_texts_ok(
    '/breeders_toolbox/seedlot_details.mas',
    'Please provide an accession name OR a cross unique id as the content of the seedlot. Not both.',
    'Please provide an accession name or a cross unique id as the content of the seedlot.',
    'Please provide a starting amount OR weight in grams for new seedlot.',
    'Are you sure you want to delete this seedlot transaction?',
    'An error occurred editing seedlot transaction details',
    'Please provide a timestamp for new seedlot created.',
);

page_script_texts_ok(
    '/breeders_toolbox/seedlots.mas',
    'Are you sure you want to delete this seedlot?',
    'An error occurred deleting seed lot',
    'The seedlot has been deleted.',
    'Breeding Program',
    'Material Type',
    'Organization',
);

page_script_texts_ok(
    '/breeders_toolbox/seedlots_section.mas',
    'Breeding Program',
    'Seedlot Location',
    'Material Type',
    'Seedlot Name',
    'Weight(g)',
    'Box Name',
);

component_compiles_ok('/breeders_toolbox/trial.mas');

page_script_texts_ok(
    '/breeders_toolbox/trialtree.mas',
    'No leaf nodes selected for download.',
    'An error occurred',
);

page_script_texts_ok(
    '/breeders_toolbox/trialtreefolders.mas',
    'An error occurred while loading the trial data.',
);

done_testing;
