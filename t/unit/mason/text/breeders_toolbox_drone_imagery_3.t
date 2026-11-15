=head1 NAME

t/unit/mason/text/breeders_toolbox_drone_imagery_3.t - breeders_toolbox/drone_imagery templates, part 3 of 3: the text is shown in the user's language

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
    '/breeders_toolbox/drone_imagery/upload_drone_imagery_dialogs.mas',
    'Base Date and Hour (For Fixed Camera Rigs e.g. Greenhouse or Growth Chambers) (Useful for fixed camera rigs capturing different pieces of a field experiment, and the capture time is not synchronized across camera rigs, but the rigs are on identical intervals. Can be the time of the first image for the rig.) (Leave empty if not applicable):',
    'In this process first upload a spreadsheet detailing the individual imaging events, then upload a zipfile containing the orthophotomosaic images for the imaging events, and finally upload a zipfile containing GeoJSON files detailing the positions of the plot-polygons for the imaging events.',
    'You can upload any image (PNG, TIFF, JPEG) which covers the entire experimental field, for example, interpolated soil data for altitude or electrical conductance EC measurements. Another example is for images from a phenotyping facility, greenhouse, or growth chamber.',
    'You can upload raw images (PNG, TIFF, JPEG) from a MicaSense 5-channel camera or a color image camera, for instance collected from an aerial drone, and then orthophotomosaics will be created using OpenDroneMap and saved in ImageBreed.',
    'You can choose to upload orthophotomosaic images (PNG, TIFF) created using external software (Pix4d, Agisoft, etc). Do not upload GeoTIFFs, instead upload reflectance raster images (.TIFF, .PNG, or .JPG).',
    'In this process first upload a spreadsheet detailing the individual imaging events, then upload a zipfile containing the orthophotomosaic images for the imaging events.',
);

done_testing;
