=head1 NAME

t/unit/mason/text/sentences_image.t - image templates: sentences appear in the user's language

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

component_compiles_ok('/image/add_image.mas');

page_sentences_ok(
    '/image/display_image.mas',
    '{bold}Note:{end_bold} The above image may be subject to copyright. Please contact the submitter about permissions to use the image.',
);

page_sentences_ok(
    '/image/plot_images.mas',
    'No collections contain images from this trial yet. To add images to a collection, select them in {link}image search{end_link} and use {bold}Add selected to collection{end_bold}.',
);

done_testing;
