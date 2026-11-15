=head1 NAME

t/unit/mason/text/sentences_cview.t - cview templates: sentences appear in the user's language

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
    '/cview/index.mas',
    '{link}{bold}Compare entire maps{end_bold}{end_link}: To get a better view how two (or three) maps relate to each other, take a zoomed out view of the entire map. A maximum of 3 maps can be shown together at one time. The maps to be displayed can be selected on the top of the display.',
    '{link}{bold}Interactive comparative map viewer{end_bold}{end_link}: View two chromosomes from two different maps at the same time; it displays the relationships between the chromosomes and additional information such as associated physical map, inbred lines, and rulers.',
    'For more on the comparative map viewer, read the {link}help page{end_link}.',
);

done_testing;
