=head1 NAME

t/unit/mason/text/scripts_tracking_activities.t - scripts in the tracking_activities templates: the script text is shown in the user's language

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
    '/tracking_activities/activity_info_details.mas',
    'An error occurred saving new information',
    'Please provide an input',
    'Please select a type',
);

page_script_texts_ok(
    '/tracking_activities/activity_project_tree.mas',
    'An error occurred while loading the trial data.',
);

page_script_texts_ok(
    '/tracking_activities/add_new_activity_project.mas',
    'An error occurred saving new tracking activities project',
    'Breeding program is required',
    'Activity type is required',
    'Project name is required',
    'Description is required',
    'Location is required',
);

page_script_texts_ok(
    '/tracking_activities/generate_tracking_identifiers_dialog.mas',
    'This list did not pass validation. Names in the list must exist in the database and are the selected material type.',
    'An error occurred generating identifiers',
    'Material type is required',
    'Please select a list',
);

page_script_texts_ok(
    '/tracking_activities/record_activity.mas',
    'An error occurred saving new information',
    'Please scan an identifier name barcode',
    'Please provide an input',
    'Please select a type',
);

page_script_texts_ok(
    '/tracking_activities/update_status_dialog.mas',
    'An error occurred processing your request',
    'An error occurred updating status',
    'Error retrieving source info',
    'Please select a status type',
);

done_testing;
