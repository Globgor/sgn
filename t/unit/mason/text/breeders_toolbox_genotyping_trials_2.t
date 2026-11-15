=head1 NAME

t/unit/mason/text/breeders_toolbox_genotyping_trials_2.t - breeders_toolbox/genotyping_trials templates, part 2 of 4: the text is shown in the user's language

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
    '/breeders_toolbox/genotyping_trials/submit_plates_dialog.mas',
    'You may want to proceed to the genotyping plate detail page to check order status.',
    'I want to automatically submit to the Genotyping Facility:',
    'After order has been complete click continue.',
    'Genotyping plates was submit successfully...',
    'Submit genotyping plates to facility',
    'Submit your genotyping plate',
);

done_testing;
