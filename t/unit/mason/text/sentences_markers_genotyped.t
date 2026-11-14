=head1 NAME

t/unit/mason/text/sentences_markers_genotyped.t - markers/genotyped templates: sentences appear in the user's language

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
    '/markers/genotyped/related_markers.mas',
    '{strong}Related Genotyped Markers:{end_strong} These genotyped markers share either the same {em}name{end_em} as one or more markers at this variant or are located at the same {em}position{end_em} but have different allele values',
    '{strong}Related Mapped Markers:{end_strong} These mapped markers have the same name as a marker at this variant',
);

done_testing;
