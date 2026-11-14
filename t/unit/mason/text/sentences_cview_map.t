=head1 NAME

t/unit/mason/text/sentences_cview_map.t - cview/map templates: sentences appear in the user's language

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
    '/cview/map/comparison.mas',
    'Select maps to compare using the control below, then press the \'set\' button to update the display.',
);

component_compiles_ok('/cview/map/index.mas');

page_sentences_ok(
    '/cview/map/missing.mas',
    'All available maps on SGN are listed on the {link}map index page{end_link}.',
    'Please contact {link}SGN{end_link} if you think there is a problem.',
);

component_compiles_ok('/cview/map/overlay_form.mas');

done_testing;
