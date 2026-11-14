=head1 NAME

t/unit/mason/text/tools_motifs_finder.t - tools/motifs_finder templates: the text is shown in the user's language

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
    '/tools/motifs_finder/index.mas',
    'This value is the number of time the sampler is restarted and can be changed to sample over a larger (or smaller) number of separate initial models.',
    'Number of sites expected in each sequence, separated by comma without space(eg. 4,6)',
    'lenght(s) of motif, separated by comma without space(eg. 4,6)',
    'Insert a sequence file in a tab-delimited format',
    'Upload Sequence file:',
    'Advance options help',
);

page_texts_ok(
    '/tools/motifs_finder/motif_output.mas',
    'Download Result',
);

done_testing;
