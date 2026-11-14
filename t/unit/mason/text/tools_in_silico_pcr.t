=head1 NAME

t/unit/mason/text/tools_in_silico_pcr.t - tools/in_silico_pcr templates: the text is shown in the user's language

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
    '/tools/in_silico_pcr/in_silico_pcr.mas',
    'Paste your primers, the maximum distance between them and the number of missmatches',
    'Select a genomic database and the other BLAST parameters',
    'Product Maximum Length',
    'BLAST Parameters Help',
    'Filter low complexity',
    'PCR Parameters Help',
);

page_texts_ok(
    '/tools/in_silico_pcr/insilicopcr_output.mas',
    'In Silico PCR Results',
    'Amplified Fragments',
    'BLAST Results',
    'In Silico Gel',
);

done_testing;
