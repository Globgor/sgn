=head1 NAME

t/unit/mason/text/calendar.t - calendar templates: the text is shown in the user's language

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
    '/calendar/events_by_user_role.mas',
    'Are you associated with the breeding program you are interested in viewing?',
    'Having trouble viewing events on the calendar?',
    'Leave Blank if Not Applicable',
    'Calendar Permissions',
    'Event Description:',
    'Event Web URL:',
);

done_testing;
