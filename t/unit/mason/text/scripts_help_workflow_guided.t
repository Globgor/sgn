=head1 NAME

t/unit/mason/text/scripts_help_workflow_guided.t - scripts in the help/workflow_guided templates: the script text is shown in the user's language

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
    '/help/workflow_guided/tissue_sample_help.mas',
    'You selected to sample on the accession level, meaning that you wil not sample from a field trial. In this case there is no field layout to download!',
    'An error occurred checking trial for tissue samples.',
    'An error occurred creating tissue sample entries',
    'An error occurred checking trial for plants.',
    'Successfully created tissue sample entries.',
    'An error occurred saving plant entries',
);

done_testing;
