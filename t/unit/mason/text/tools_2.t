=head1 NAME

t/unit/mason/text/tools_2.t - tools templates, part 2 of 2: the text is shown in the user's language

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
    '/tools/treatment_designer.mas',
    'Experimental treatments are applied to the stocks of a trial. Subplots, plants, and tissue samples inherit treatments from their parent stocks.',
    'Make it descriptive. Be sure to describe category meanings if using categorical data.',
    'Alternate names for the new term. Synonyms must not already exist in the database.',
    'Pipes (|)  will be removed from name.',
    'Optional. Pipes (|) will be removed.',
    'Design new experimental treatments',
);

page_texts_ok(
    '/tools/trialallocation.mas',
    'Open Planting Tool, define planter settings such as rows per plot, plants per plot, spacing, and planting direction, then download the planting map Excel file or generate layout graphics.',
    'Drag each trial box from the Trials panel into the field grid. Use the direction and rotate controls beside each trial to adjust plot order before placement.',
    'Define the trials to allocate: create new trial designs in Trial Settings or add an existing experimental trial for the selected location and year.',
    'Build the grid, then mark unused rows or columns before placing trials so plots are not allocated in unavailable field space.',
    'Click a placed trial to select it, then use the cursor keys to move it. Use Shift + cursor key to move five plots at a time.',
    'Use the grid tools to place borders, define border accessions, and review plot details by moving the cursor over each plot.',
);

page_texts_ok(
    '/tools/vectorviewer.mas',
    'Vector Viewer',
    'Update/Reset',
    'Load Vector',
    'Orientation',
    'Save Vector',
    'Start Coord',
);

done_testing;
