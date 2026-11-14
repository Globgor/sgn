=head1 NAME

t/unit/mason/text/sentences_qtl_search.t - qtl/search templates: sentences appear in the user's language

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
    '/qtl/search/help/index.mas',
    'If you have questions, please contact us at: {contact}',
    'QTL analysis is performed on the fly.',
);

component_compiles_ok('/qtl/search/results.mas');

done_testing;
