=head1 NAME

t/unit/mason/text/sentences_order.t - order templates: sentences appear in the user's language

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
    '/order/manage_catalog_usage_info.mas',
    '{bold}Add Multiple Items using List{end_bold}: For adding many items with the same stock type and the same catalog info, using "Add Multiple Items Using List" dialog is the most convenient method.',
    '{bold}Upload Multiple Items{end_bold}: For adding many items with different stock types and each item may have different catalog info, you can use "Upload Multiple Items" dialog.',
    '{bold}Add Single Item{end_bold}: If you would like to add only one item to the catalog, you can use "Add Single Item" dialog',
);

done_testing;
