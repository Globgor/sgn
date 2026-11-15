=head1 NAME

t/unit/mason/text/sentences_interactomics.t - interactomics templates: sentences appear in the user's language

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
    '/interactomics/index.mas',
    'Funding for Cytoscape is provided by a federal grant from the U.S. {link}National Institute of General Medical Sciences (NIGMS){end_link} of the {link2}National Institutes of Health (NIH){end_link2} under award number {award} and the U.S. {link3}National Science Foundation (NSF) {end_link3}.',
    'Corporate funding is provided through a contract from {link}Unilever PLC{end_link}.',
    'Cytoscape home',
);

done_testing;
