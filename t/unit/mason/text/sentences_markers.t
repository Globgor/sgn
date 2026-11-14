=head1 NAME

t/unit/mason/text/sentences_markers.t - markers templates: sentences appear in the user's language

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
    '/markers/genotyped_markers.mas',
    '{bold}Related Genotyped Markers:{end_bold} These markers have been genotyped and share a name with this marker',
);

component_compiles_ok('/markers/view_rflp.mas');

done_testing;
