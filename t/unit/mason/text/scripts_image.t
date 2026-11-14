=head1 NAME

t/unit/mason/text/scripts_image.t - scripts in the image templates: the script text is shown in the user's language

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
    '/image/compare_images.mas',
    'Please select two image types!',
    'Error comparing images!',
);

page_script_texts_ok(
    '/image/display_order.mas',
    'Successfully changed display_order',
    'an error occurred',
);

page_script_texts_ok(
    '/image/plot_images.mas',
    'Could not load collections.',
    'Error fetching stock names',
    'Accession Name',
    'Associations',
    'Description',
    'Submitter',
);

page_script_texts_ok(
    '/image/print_images.mas',
    'An error occured while setting the display image',
);

done_testing;
