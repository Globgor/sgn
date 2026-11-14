=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_drone_imagery.t - breeders_toolbox/drone_imagery templates: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

page_sentences_ok(
    '/breeders_toolbox/drone_imagery/raw_image_section.mas',
    'Field Trials -> Imaging Events',
);

page_sentences_ok(
    '/breeders_toolbox/drone_imagery/standard_process_raw_images.mas',
    'It will take time to finish processing your drone run and calculating phenotypes for all plot polygon images, vegetative indices, and processing combinations. Once it is complete, the "Processing Icon" on the Manage->Drone Imagery page will disappear from the drone run.',
);

page_sentences_ok(
    '/breeders_toolbox/drone_imagery/upload_drone_imagery_dialogs.mas',
    '{bold}For Raw Image Captures{end_bold}: If you have raw aerial images (.TIFF, .JPG, .PNG) that have not been stitched into an orthophotomosaic image of the whole field, your raw images should be uploaded using a zipfile (.zip). Include at least 25 images in the zipfile. OpenDroneMap will be used to stitch the orthophotos and digital surface maps (DSM). OpenDroneMap works for color RGB images and for MicaSense 5-channel multi-spectral images.',
    '{bold}For Orthophotomosaics{end_bold}: If you already have orthophotomosaic image(s) of your entire field from external software, you can upload those images. Upload orthomosaics as .TIFF, .PNG, or .JPG images. Do not upload GeoTIFFs, instead upload reflectance raster images (.TIFF, .PNG, or .JPG). Orthophotomosaic images for multi-spectral cameras are expected to be perfectly super-imposable for all spectra.',
    'Your field trial(s) must already be in the database before you can upload images for it. Please go to {link}Manage->Field Trials{end_link} if it is not. Make sure the planting date is also set!',
    'Your field trial must already be in the database before you can upload images for it. Please go to {link}Manage->Field Trials{end_link} if it is not.',
    'Make sure there is >75% overlap in the images, so that the images can be properly assembled.',
);

done_testing;
