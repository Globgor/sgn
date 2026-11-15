=head1 NAME

t/unit/mason/text/sentences_propagation.t - propagation templates: sentences appear in the user's language

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
    '/propagation/add_propagation_project.mas',
    'Metadata for each propagation process (e.g., accession name, material type, date, operator) is linked to a globally unique {bold}Propagation Group Identifier{end_bold}.',
    'Within each Propagation Group, the progress of each plant produced is tracked by a globally unique {bold}Propagation Identifier{end_bold}.',
);

page_sentences_ok(
    '/propagation/propagation_project_tree.mas',
    'Double click{break}propagation project ({icon}) or folder ({icon2}){break2}to view detail page.',
    'Breeding programs ({icon})',
);

done_testing;
