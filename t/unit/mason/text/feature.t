=head1 NAME

t/unit/mason/text/feature.t - feature templates: the text is shown in the user's language

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

component_compiles_ok('/feature/cvterms.mas');

page_texts_ok(
    '/feature/gene_group_export_to_alignment_viewer.mas',
    '(may take a long time for large gene groups)',
    'Export sequences to alignment viewer',
);

page_texts_ok(
    '/feature/jbrowse_exact_match.mas',
    'Your browser does not support iframes.',
);

component_compiles_ok('/feature/region_sequence.mas');

component_compiles_ok('/feature/residues.mas');

done_testing;
