=head1 NAME

t/unit/mason/text/sentences_site_header.t - site/header templates: sentences appear in the user's language

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

component_compiles_ok('/site/header/body.mas');

page_sentences_ok(
    '/site/header/browser_alert.mas',
    'Please upgrade your browser',
);

done_testing;
