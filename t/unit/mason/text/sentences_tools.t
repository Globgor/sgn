=head1 NAME

t/unit/mason/text/sentences_tools.t - tools templates: sentences appear in the user's language

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

component_compiles_ok('/tools/fieldmap.mas');

page_sentences_ok(
    '/tools/trait_designer.mas',
    'Check the {link}trait search page{end_link} to see if your trait has already been made before designing new traits.',
);

done_testing;
