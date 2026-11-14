=head1 NAME

t/unit/mason/text/breeders_toolbox_drone_imagery_2.t - breeders_toolbox/drone_imagery templates, part 2 of 3: the text is shown in the user's language

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
    '/breeders_toolbox/drone_imagery/generate_plot_polygons_standard_process_section.mas',
    'View and edit template parameters. These parameters can be filled using the above button clicks',
    '(A) Draw Plot Polygon Template (Does not save. Apply multiple templates if needed.)',
    'View and use previous plot polygon templates used on this field trial',
    'Previously Used Plot Polygon Templates For This Field Trial:',
    'Either (A) click the four corners of the area of interest:',
    '(B) Draw Plot Polygon Template (Does not save)',
);

page_texts_ok(
    '/breeders_toolbox/drone_imagery/standard_process_raw_images.mas',
    'The process will be applied to each imaging pass at a time. An imaging pass corresponds to the camera moving in one direction over the field experiment, such as an aerial vehicle flying a pass over the field. The passes are automatically separated from the images you uploaded using GPS.',
    'Please select one drone run band to take through the process. The NIR band is currently implemented and provides best contrast.',
    'Here you can apply the same actions you did for the previous steps 1 to 6, to additional drone run bands in this drone run.',
    '(3) Assign plot numbers to the generated plot polygons, either automatically or manually. Click blue button to go to next.',
    '(2) Use the templating tools below to generate plot polygons. There are three templating tools to choose from:',
    'This workflow will guide you through applying a standard process to your aerial imaging bands interactively',
);

done_testing;
