=head1 NAME

t/unit/mason/text/tools_expression.t - tools/expression templates: the text is shown in the user's language

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
    '/tools/expression/expression_atlas.mas',
    'Export Data to Expression Atlas',
);

page_texts_ok(
    '/tools/expression/input.mas',
    'Experiment Expression Data',
    'Interactive Control Panel',
    'Experiment Sample Info',
    'Choose a experiment:',
    'Run Expression Tool',
    'Experiment Info',
);

done_testing;
