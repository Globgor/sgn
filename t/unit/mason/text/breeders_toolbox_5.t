=head1 NAME

t/unit/mason/text/breeders_toolbox_5.t - breeders_toolbox templates, part 5 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/manage_drone_imagery.mas',
    'Here you can take one of the imaging event bands you uploaded all the way through the process to plot image saving. This will require manual steps such as image rotation, cropping, and plot polygon templating. After you have completed this process for one imaging event band, you can apply it to all other imaging event bands and other calculated vegetative indices.',
    'If a previous imaging event on this field experiment has already completed the standard process, then that imaging event can be used to automate the rest of the standard process on this new imaging event.',
    'Here you can view the plot polygon templates on the imagery over the course of the field trial. All of the image bands are visible here (e.g. blue, green, RGB, etc).',
    'Select the population(s) you are specifically interested in predicting. Leave blank if you want to train on images from all germplasm in the selected field trial(s).',
    'If ground control points (GCPs) were defined for a previous imaging event, then GCPs can automate the standard process for this new imaging event.',
    'Please select one imaging event band to take through the process. It is recommended to select a band that has high contrast, such as a NIR band.',
);

done_testing;
