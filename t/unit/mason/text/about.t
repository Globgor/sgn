=head1 NAME

t/unit/mason/text/about.t - about templates: the text is shown in the user's language

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
    '/about/audit.mas',
    'Select a database table to see audits:',
    'Database Audit Tables',
    'Audit table',
    'View audits',
);

page_texts_ok(
    '/about/recent_activity.mas',
    'Filter by date of addition to database',
    '[loading recent phentoyping activity]',
    '[loading recent accessions activity]',
    '[loading recent plots activity]',
    '[loading recent trial activity]',
    'include items without a date',
);

done_testing;
