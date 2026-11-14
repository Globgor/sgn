=head1 NAME

t/unit/mason/text/sentences_solgs_search.t - solgs/search templates: sentences appear in the user's language

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

component_compiles_ok('/solgs/search/result/populations.mas');

component_compiles_ok('/solgs/search/result/traits.mas');

done_testing;
