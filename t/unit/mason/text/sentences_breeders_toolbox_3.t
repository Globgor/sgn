=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_3.t - breeders_toolbox templates, part 3 of 6: sentences appear in the user's language

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
    '/breeders_toolbox/manage_images.mas',
    'Each detected object is stored as a {bold}tissue sample{end_bold}, and its measurements are stored as {bold}observations{end_bold} on that sample, so results flow into the same phenotype tables as field data.',
    'To add images to a collection, select them in {link}image search{end_link} and use {bold}Add selected to collection{end_bold}.',
    'An image can belong to several collections, and removing it from one does not delete the image or affect the others.',
    'Each image must contain exactly one barcode, and the associated stock must already exist in the database.',
    'Fieldbook photos carry EXIF data with the observation unit name, trait name, and timestamp',
    'There are three ways to upload, depending on how the images relate to your data:',
);

page_sentences_ok(
    '/breeders_toolbox/manage_odk_data_collection.mas',
    'These services assist in creating forms, deploying forms to your mobile application, and visualizing data uploaded back from the mobile device.',
    'ODK is an application that allows mobile data collection using user defined forms on Android or IOS devices.',
    'Many services have developed web interfaces to better streamline the ODK experience.',
    'Data collected on the device can be instantaneously synched to the ODK server.',
    'Currently we are working with {link}ONA{end_link} as an ODK service.',
    'To find out more go to the {link}ODK site{end_link}.',
);

done_testing;
