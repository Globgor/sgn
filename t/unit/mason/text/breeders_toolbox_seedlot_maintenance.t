=head1 NAME

t/unit/mason/text/breeders_toolbox_seedlot_maintenance.t - breeders_toolbox/seedlot_maintenance templates: the text is shown in the user's language

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
    '/breeders_toolbox/seedlot_maintenance/main.mas',
    'Seedlot Maintenance Events',
    'About Seedlot Maintenance',
    'Seedlot Maintenance Tools',
    'Seedlot Maintenance',
);

component_compiles_ok('/breeders_toolbox/seedlot_maintenance/record.mas');

page_texts_ok(
    '/breeders_toolbox/seedlot_maintenance/table.mas',
    'Are you sure you want to remove this Seedlot Maintenance Event?',
    'Filter maintenance events based on date, type, and/or value',
    'Applied Filters:',
    'Filter Events',
    'Remove Event?',
    'Remove Event',
);

page_texts_ok(
    '/breeders_toolbox/seedlot_maintenance/tools/overdue_events.mas',
    'Not Overdue Seedlots',
    'Last Recorded Event',
    'Overdue Seedlots',
    'Overdue Events',
    'Find Seedlots',
    'Loading...',
);

page_texts_ok(
    '/breeders_toolbox/seedlot_maintenance/tools/split_seedlot.mas',
    'This tool will split an existing Seedlot - keeping the existing Seedlot and creating a new one with the same Accession as the contents.',
    'Subtract initial contents of new seedlot from original seedlot:',
    'Required, must be an existing Accession name',
    'Required, must be a unique Seedlot name',
    'Original Seedlot Weight (g)',
    'New Seedlot Contents Value',
);

page_texts_ok(
    '/breeders_toolbox/seedlot_maintenance/upload_dialog.mas',
    'The name of the Maintenance Event must be a valid event type.  Valid event types include:',
    'Upload Seedlot Maintenance Event Template Information',
    'The first row (header) should contain the following:',
    'Upload Seedlot Maintenance Events',
    'File format information',
    'Spreadsheet Format',
);

done_testing;
