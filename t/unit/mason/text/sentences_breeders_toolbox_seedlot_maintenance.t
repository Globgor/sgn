=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_seedlot_maintenance.t - breeders_toolbox/seedlot_maintenance templates: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

page_sentences_ok(
    '/breeders_toolbox/seedlot_maintenance/main.mas',
    'You can view the maintenance events for a single Seedlot on the Seedlot detail page by going to the {link}{strong}Manage > Seedlots{end_strong}{end_link} page, searching for the Seedlot, and clicking its name in the results table. You can also filter through all of the stored maintenance events using the search below. The events can then be downloaded from the table displaying the results or downloaded in bulk from the {link2}{strong}Manage > Download{end_strong}{end_link2} page using a list of Seedlots.',
    'To record a new maintenance event for a particular Seedlot, use the {strong}Record Maintenance{end_strong} button below to enter the event information directly on the website. You can also bulk upload maintenance events for one or more Seedlots using the {strong}Upload Maintenance{end_strong} button.',
    'Seedlot Maintenance allows you to record and document certain actions and/or observations taken for the proper maintenance of your Seedlots. The actions and observations are timestamped so you can clearly track the maintenance and state of your Seedlots over time.',
);

page_sentences_ok(
    '/breeders_toolbox/seedlot_maintenance/table.mas',
    'Add one or more filters to apply to the table of displayed maintenance events. To add a filter, enter the properties for a filter type and click the add button to add the filter to the list. Once you\'re done adding filters, click the Filter button to display the results.',
);

page_sentences_ok(
    '/breeders_toolbox/seedlot_maintenance/tools/overdue_events.mas',
    'This search will return any Seedlots from the selected list that have not had the specified event performed on or after the selected date.',
);

page_sentences_ok(
    '/breeders_toolbox/seedlot_maintenance/upload_dialog.mas',
    'The Maintenance Events are associated with Seedlots, so the name of the Seedlot in the file must match an existing Seedlot in the database. If a Seedlot is not yet in the database, go to the {link}Manage Seedlots{end_link} page to create it first.',
);

done_testing;
