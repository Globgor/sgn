=head1 NAME

t/unit/mason/text/image.t - image templates: the text is shown in the user's language

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
    '/image/add_image.mas',
    'Note: By pressing the "Upload" button, you are considered to be the copyright owner of the image being uploaded and that you grant a non-exclusive license to display and use the image on webpages and materials related to this website.',
    'Upload Image',
    'Upload',
);

page_texts_ok(
    '/image/compare_images.mas',
    'Select the images you are interested in comparing',
    'Compare pixel values for two different images',
    'Select the comparison you are interested in',
    'Image comparison results',
    'Drone Run Band Name',
    'Drone Run Band Type',
);

page_texts_ok(
    '/image/confirm.mas',
    'Upload Image',
);

page_texts_ok(
    '/image/display_image.mas',
    'Associated objects',
    'Display properties',
    'Associated tags',
    'Object Type',
    'Stock Type',
    'add/remove',
);

page_texts_ok(
    '/image/display_order.mas',
    'Change display order for image',
    'Display order:',
    'change',
);

component_compiles_ok('/image/index.mas');

page_texts_ok(
    '/image/plot_images.mas',
    'Image collections for this trial',
    'Loading collections',
    'File Name/Details',
    'Accession Name',
    'Associations',
    'Trial Images',
);

page_texts_ok(
    '/image/print_images.mas',
    'The display image was set successfully.',
    'Close & Reload',
    'Success',
    'Close',
);

done_testing;
