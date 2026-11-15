=head1 NAME

t/unit/mason/text/sentences_tools_expression.t - tools/expression templates: sentences appear in the user's language

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
    '/tools/expression/input.mas',
    '1. Select a {bold}Gene name{end_bold} an push the \'Get Expression\' button to see its expression in the different tissues of the plant',
);

done_testing;
