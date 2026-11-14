=head1 NAME

t/unit/mason/text/genomes_Solanum_lycopersicoides.t - genomes/Solanum_lycopersicoides templates: the text is shown in the user's language

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
    '/genomes/Solanum_lycopersicoides/usage_popup.mas',
    'Please Note: S.lycopersicoides Data Access Agreement',
    'Don\'t Agree',
    'Agree',
);

done_testing;
