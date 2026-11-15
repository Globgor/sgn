=head1 NAME

t/unit/mason/text/sentences_tools_label_designer.t - tools/label_designer templates: sentences appear in the user's language

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
    '/tools/label_designer/design_label.mas',
    '{strong}NOTE:{end_strong} The property values displayed here in the design tool may not be from the same plot, list item, etc. The longest value is displayed here to aid in the positioning and sizing of the element. The values will be correctly associated when all of the labels are printed in the next step.',
);

page_sentences_ok(
    '/tools/label_designer/index.mas',
    '{bold}Note:{end_bold} Do not print the labels directly from the browser as the browser adds headers and footers that will distort the alignment of the labels. Instead, download the pdf file and print it from a PDF reader app.',
);

page_sentences_ok(
    '/tools/label_designer/save_and_download.mas',
    '...Then by:{span}Optional{end_span}',
);

page_sentences_ok(
    '/tools/label_designer/select_datasource.mas',
    'This workflow will guide you through each step of the design process. For detailed explanations of each step please refer to the {link}label designer section of the manual{end_link}.',
);

done_testing;
