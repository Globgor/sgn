=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_seedlot_maintenance.t - scripts in the breeders_toolbox/seedlot_maintenance templates: the script text is shown in the user's language

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

component_compiles_ok('/breeders_toolbox/seedlot_maintenance/record.mas');

page_script_texts_ok(
    '/breeders_toolbox/seedlot_maintenance/table.mas',
    'Incorrect date format - the date must be in the format of YYYY-MM-DD',
    'ERROR: Could not load maintenance events!',
    'ERROR: Could not remove seedlot event!',
    'ERROR: Could not fetch ontology terms',
    'Remove Event',
    'Filter',
);

page_script_texts_ok(
    '/breeders_toolbox/seedlot_maintenance/tools/overdue_events.mas',
    'Incorrect date format - the date must be in the format of YYYY-MM-DD',
    'ERROR: Could not find overdue seedlots!',
    'ERROR: Could not fetch ontology terms',
    'Select a maintenance event',
    'Select a list of seedlots',
    'Select a date',
);

page_script_texts_ok(
    '/breeders_toolbox/seedlot_maintenance/upload_dialog.mas',
    'Uploading Seedlot Maintenance Events File',
    'Please select your upload file',
    'ERROR: Could not upload file!',
);

done_testing;
