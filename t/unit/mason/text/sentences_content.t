=head1 NAME

t/unit/mason/text/sentences_content.t - content templates: sentences appear in the user's language

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
    '/content/sgn_data.mas',
    'This page presents a summary of all currently available data on SGN sorted by species. Click a species name for details about available its available maps, loci, libraries, ESTs, metabolic annotation and phenotyped accessions.',
);

done_testing;
