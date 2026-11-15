=head1 NAME

t/unit/mason/text/tracking_activities_2.t - tracking_activities templates, part 2 of 2: the text is shown in the user's language

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
    '/tracking_activities/update_status_usage_info_dialog.mas',
    'Deleting a process/experiment removes its identifier from the database. Marking a process/experiment as completed/terminated inactivates that process/experiment, but its related information is still kept in the database.',
    'You can still access the details page but the page is marked as "COMPLETED" or "TERMINATED". You can no longer add additional info to that page.',
    'Completed or Terminated status can be reversed by using UNDO option. Deleting a process/experiment cannot be undone',
    'Only curators can update status to completed/terminated or undo the update status.',
    'Terminating a process/experiment is different from deleting a process/experiment.',
    'You can delete a process/experiment only if there is no associated data',
);

done_testing;
