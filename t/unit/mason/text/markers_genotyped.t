=head1 NAME

t/unit/mason/text/markers_genotyped.t - markers/genotyped templates: the text is shown in the user's language

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
    '/markers/genotyped/external_links.mas',
    'Loading...',
);

page_texts_ok(
    '/markers/genotyped/flanking_sequence.mas',
    'View the marker flanking sequence',
);

page_texts_ok(
    '/markers/genotyped/genotype_locations.mas',
    'Chromosome',
    'Reference',
    'Position',
    'Protocol',
    'Species',
    'Marker',
);

page_texts_ok(
    '/markers/genotyped/related_markers.mas',
    'Loading...',
);

page_texts_ok(
    '/markers/genotyped/variant_details.mas',
    'Genotype locations',
    'Sequence Metadata',
    'Related Markers',
    'External Links',
    'Genome Browser',
);

done_testing;
