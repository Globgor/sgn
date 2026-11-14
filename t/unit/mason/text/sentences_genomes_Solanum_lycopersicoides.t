=head1 NAME

t/unit/mason/text/sentences_genomes_Solanum_lycopersicoides.t - genomes/Solanum_lycopersicoides templates: sentences appear in the user's language

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
    '/genomes/Solanum_lycopersicoides/usage_popup.mas',
    'Solanum lycopersicoides genome adheres to the {link}Toronto Agreement{end_link} on prepublication data release.',
);

done_testing;
