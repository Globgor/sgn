=head1 NAME

t/unit/mason/text/sentences_tools_genefamily.t - tools/genefamily templates: sentences appear in the user's language

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
    '/tools/genefamily/details.mas',
    'Family detail for family {family}',
    'Family: {bold}{family}{end_bold}',
    'Member count: {count}',
    'Note: {errors}',
);

done_testing;
