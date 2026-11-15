=head1 NAME

t/unit/mason/text/sentences_about_outreach.t - about/outreach templates: sentences appear in the user's language

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
    '/about/outreach/index.mas',
    'Resources: {link}Activity Book{end_link} | {link2}List of materials needed{end_link2} | {link3}Images of Sol family members{end_link3} [pdf]',
    'Resources: {link}Student worksheet{end_link} [doc] | {link2}Teacher worksheet{end_link2} [doc] | {link3}Methods{end_link3} [ppt]',
    '{link}Recommendation form{end_link} (pdf)',
    'Resources: {link}SGN tutorial{end_link}',
    '{link}Application form{end_link} (pdf)',
    '{link}Flyer{end_link} (pdf)',
);

done_testing;
