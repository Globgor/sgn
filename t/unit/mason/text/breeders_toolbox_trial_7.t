=head1 NAME

t/unit/mason/text/breeders_toolbox_trial_7.t - breeders_toolbox/trial templates, part 7 of 7: the text is shown in the user's language

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
    '/breeders_toolbox/trial/update_experimental_design_type.mas',
    'Trial Design Type was updated successfully.',
    'Change to Experimental Design Type:',
    'Success',
    'Update',
    'Close',
);

page_texts_ok(
    '/breeders_toolbox/trial/update_trial_status_dialog.mas',
    'Trial status was updated successfully.',
    'Trial Activity Date:',
    'Close & Reload',
    'Trial Status:',
    'Success',
    'Update',
);

page_texts_ok(
    '/breeders_toolbox/trial/upload_additional_file.mas',
    'The collection is checked (or created) before any file is uploaded, so a problem with it stops the upload instead of leaving files outside the collection.',
    'Only files that upload successfully are added. A file can belong to several collections, and removing it from a collection does not delete the file.',
    'The result for each file is shown in the upload dialog. If one file fails, the others are still uploaded.',
    'Trial Related Images, such as a physical field image or an aerial picture of the field.',
    'Trial Related Reports, such as supplementary information or publications.',
    'Trial Related Documentation, such as protocols or permits for the trial.',
);

page_texts_ok(
    '/breeders_toolbox/trial/upload_plot_gps_dialogs.mas',
    'Each plot is represented as a polygon with four corners. You can choose to upload UTM31N and/or WGS84 coordinates.',
    'Each plot is represented as a point with one coordinate pair. You can upload WGS84 coordinates.',
    'GPS coordinates may be uploaded in an Excel file (.xls or .xlsx)',
    'The first row (header) should contain the following:',
    'This is for recording the GPS coordinates of plots.',
    'Upload GPS Coordinates for Plots',
);

page_texts_ok(
    '/breeders_toolbox/trial/upload_soil_data_dialogs.mas',
    'Soil data may be uploaded in an Excel file (.xls or .xlsx)',
    'The first row (header) must contain the following:',
    'Soil data were saved successfully.',
    'Upload Soil Data for this Trial',
    'Upload Soil Data File Error',
    'File format information',
);

page_texts_ok(
    '/breeders_toolbox/trial/weather.mas',
    '[loading...]',
);

done_testing;
