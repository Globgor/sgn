=head1 NAME

t/unit/mason/text/phenome.t - phenome templates: the text is shown in the user's language

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

component_compiles_ok('/phenome/assign_owner.mas');

page_texts_ok(
    '/phenome/associate_accession_form.mas',
    'Would you Like to specify an allele?',
    'associate accession',
    'Accession name:',
);

page_texts_ok(
    '/phenome/associate_locus.mas',
    'Loading..',
);

page_texts_ok(
    '/phenome/display_owners.mas',
    'Loading..',
);

done_testing;
