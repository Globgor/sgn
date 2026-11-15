=head1 NAME

t/unit/mason/text/sentences_qtl_qtl_form.t - qtl/qtl_form templates: sentences appear in the user's language

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

component_compiles_ok('/qtl/qtl_form/confirm.mas');

page_sentences_ok(
    '/qtl/qtl_form/general_intro.mas',
    'The uploading of QTL data needs to be done in one session. Therefore, prepare your data files in the required format before starting the process.',
    'Markers with their sequences need to be already in SGN. Read {link}here{end_link} on how to submit markers to SGN.',
);

component_compiles_ok('/qtl/qtl_form/pop_form.mas');

done_testing;
