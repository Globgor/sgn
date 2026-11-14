=head1 NAME

t/unit/mason/text/markers.t - markers templates: the text is shown in the user's language

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

component_compiles_ok('/markers/cos.mas');

component_compiles_ok('/markers/cosii_orthologs.mas');

page_texts_ok(
    '/markers/cosii_polymorphisms.mas',
    'Universal primers for Asterid species',
);

page_texts_ok(
    '/markers/genotyped_markers.mas',
    'Related Markers',
    'Loading...',
);

component_compiles_ok('/markers/index.mas');

page_texts_ok(
    '/markers/locations.mas',
    'Mapped locations',
);

component_compiles_ok('/markers/rflp.mas');

component_compiles_ok('/markers/unigene_match.mas');

done_testing;
