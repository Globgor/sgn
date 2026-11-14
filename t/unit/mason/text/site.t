=head1 NAME

t/unit/mason/text/site.t - site templates: the text is shown in the user's language

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
    '/site/dataset.mas',
    'Dataset Validation Failed',
    'View Public Datasets',
    'Elements not found:',
    'Dataset Contents',
    'Public Datasets',
    'Your Datasets',
);

page_texts_ok(
    '/site/list.mas',
    'Items listed here have mulitple case mismatches and must be fixed manually. If accessions need to be merged, contact the database directly.',
    'Multiple synonym matches have to be resolved manually. Contact database administrators if necessary.',
    'Click the Adjust Case button to align the case in the list with what is in the database.',
    'Replace synonyms with corresponding DB name',
    'Optional: Add Missing Accessions to A List',
    'Create a New List from Selected Seedlots:',
);

page_texts_ok(
    '/site/status.mas',
    'Site Status',
    'Logins',
);

done_testing;
