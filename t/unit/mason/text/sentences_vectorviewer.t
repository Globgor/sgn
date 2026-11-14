=head1 NAME

t/unit/mason/text/sentences_vectorviewer.t - vectorviewer templates: sentences appear in the user's language

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
    '/vectorviewer/vectorviewer.mas',
    '{bold}To edit the vector annotations{end_bold} you can add, edit or remove features from the vector using the feature and restriction enzyme tables below the vector diagram. To remove an element, click on the "delete" button in the corresponding row. To edit an element, click on the "edit" button in the corresponding row. To add new feature elements, click on the "Add Feature" button below the table. To add a new restriction enzyme, click on the "Add Restriction Enzyme" button below the restriction enzyme table.',
);

done_testing;
