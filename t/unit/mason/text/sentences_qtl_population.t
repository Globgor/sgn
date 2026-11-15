=head1 NAME

t/unit/mason/text/sentences_qtl_population.t - qtl/population templates: sentences appear in the user's language

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
    '/qtl/population/data_access.mas',
    'The QTL data for this population is not public yet. If you are the data owner or SGN curator, login to access the data.',
);

done_testing;
