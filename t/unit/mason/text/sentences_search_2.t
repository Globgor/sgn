=head1 NAME

t/unit/mason/text/sentences_search_2.t - search templates, part 2 of 2: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

page_sentences_ok(
    '/search/traits.mas',
    'To speed up addition of your trait into the database please contact us using the {link}Contact Form{end_link}.',
    'Please submit your new trait {link}using the trait submission form{end_link}.',
    '{span}{count}{end_span} trait(s) selected.',
    'Trait Usage',
);

page_sentences_ok(
    '/search/treatments.mas',
    '{span}{count}{end_span} treatment(s) selected.',
    'Treatment Usage',
);

done_testing;
