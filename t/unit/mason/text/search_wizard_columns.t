=head1 NAME

t/unit/mason/text/search_wizard_columns.t - The columns of the search wizard: the text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_texts_ok );

page_texts_ok(
    '/breeders_toolbox/breeder_search_page.mas',
    'Create New List...',
    'Select Column Type',
    'Add to List...',
    'Contains',
    'Select All',
    'ANY',
);

done_testing;
