=head1 NAME

t/unit/mason/text/sentences_help_workflow_guided.t - help/workflow_guided templates: sentences appear in the user's language

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
    '/help/workflow_guided/begin.mas',
    'What are you interested in? {link}For General Help{end_link}',
);

page_sentences_ok(
    '/help/workflow_guided/phenotype_upload_modal.mas',
    'Please refer to the {link}Documentation{end_link}',
);

page_sentences_ok(
    '/help/workflow_guided/trial_barcoding_modal.mas',
    'Please refer to the {link}Documentation{end_link}',
);

page_sentences_ok(
    '/help/workflow_guided/trial_comparison_modal.mas',
    'Please refer to the {link}Documentation{end_link}',
);

done_testing;
