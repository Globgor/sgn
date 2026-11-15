=head1 NAME

t/unit/mason/text/qtl_qtl.t - qtl/qtl templates: the text is shown in the user's language

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
    '/qtl/qtl/genome_positions.mas',
    'QTL markers\' genomic matches',
);

page_texts_ok(
    '/qtl/qtl/index.mas',
    'QTL markers\' genetic positions and Comparative Map Viewer',
    'QTL 95% Confidence Interval',
    'Browse QTL region',
);

done_testing;
