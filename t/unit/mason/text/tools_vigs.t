=head1 NAME

t/unit/mason/text/tools_vigs.t - tools/vigs templates: the text is shown in the user's language

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
    '/tools/vigs/input.mas',
    'Insert a expression file in a tab-delimited format',
    'Number of mismatches allowed in Bowtie alignment',
    'Your browser does not support the HTML5 canvas',
    'Select plant species to host VIGS experiment',
    'Description of genes with matches of n-mers',
    'Desired VIGS construct length',
);

done_testing;
