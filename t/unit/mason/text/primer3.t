=head1 NAME

t/unit/mason/text/primer3.t - primer3 templates: the text is shown in the user's language

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
    '/primer3/primer3form.mas',
    'Copyright Notice and Disclaimer',
);

page_texts_ok(
    '/primer3/primer3results.mas',
    'The statistics below should indicate why no acceptable primers were found. Try relaxing various parameters, including the self-complementarity parameters and max and min oligo melting temperatures. For example, for very A-T-rich regions you might have to increase maximum primer size or decrease minimum melting temperature.',
    'No hyb oligo mishyb library specified.',
    'No Acceptable Primers Were Found',
    'No mispriming library specified.',
    'Statistics',
    'Results',
);

done_testing;
