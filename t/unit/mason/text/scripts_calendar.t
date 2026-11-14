=head1 NAME

t/unit/mason/text/scripts_calendar.t - scripts in the calendar templates: the script text is shown in the user's language

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
    '/calendar/events_by_user_role.mas',
    'You do not have the permissions to delete an event.',
    'You do not have the permissions to edit thie event.',
    'You do not have the permissions to edit this event.',
    'You do not have the permissions to add an event.',
    'Event Already Existed! Your Edit Was Not Saved!',
    'Are you sure you want to delete this event?',
);

done_testing;
