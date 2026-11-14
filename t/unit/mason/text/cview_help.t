=head1 NAME

t/unit/mason/text/cview_help.t - cview/help templates: the text is shown in the user's language

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
    '/cview/help/map_submission.mas',
    'Marker names should either correspond to SGN marker names, if the markers are identical, or have a new name that is not yet in the SGN database, as the marker correspondences will be established on a name matching basis.',
    'This file gives the location of the markers on the map. When submitting a map, be sure to also provide a marker data file and accession information. These are the columns defined for the mapping file:',
    'Maps can be submitted to SGN for inclusion in the comparative viewer and related tools. File formats are defined for these types of data:',
    'This file has a different format for each marker type. Please provide these columns:',
    'The polymorphism data file should have the following columns:',
    'Submitting maps to SGN',
);

done_testing;
