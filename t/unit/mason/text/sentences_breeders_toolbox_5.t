=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_5.t - breeders_toolbox templates, part 5 of 6: sentences appear in the user's language

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
    '/breeders_toolbox/trialtree.mas',
    'Double click{break}trial to view',
);

page_sentences_ok(
    '/breeders_toolbox/trialtreefolders.mas',
    'Double click{break}trial ({icon}) or folder ({icon2}){break2}to view detail page.',
    'Breeding programs ({icon})',
    'Sampling trials ({icon})',
    'Analyses ({icon})',
);

done_testing;
