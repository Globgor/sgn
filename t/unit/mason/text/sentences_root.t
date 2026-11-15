=head1 NAME

t/unit/mason/text/sentences_root.t - top-level pages templates: sentences appear in the user's language

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
    '/usage_policy.mas',
    'The data on this database is shared according to the Toronto agreement (see below).',
    'Datasets that are currently released but have not yet been published include:',
);

done_testing;
