=head1 NAME

t/unit/mason/text/breeders_toolbox_markers.t - breeders_toolbox/markers templates: the text is shown in the user's language

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
    '/breeders_toolbox/markers/manage_markers.mas',
    'To add more than one marker, separate marker names using a new line.',
    'Use marker alleles to search for accessions with specific genotype.',
    'Add alleles for multiple markers by allele names',
    'Add alleles for a single marker by marker name',
    'How to Create and Use Lists of Marker Alleles',
    'Create New Marker Allele List',
);

done_testing;
