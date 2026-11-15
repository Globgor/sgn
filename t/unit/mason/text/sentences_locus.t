=head1 NAME

t/unit/mason/text/sentences_locus.t - locus templates: sentences appear in the user's language

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
    '/locus/merge_locus.mas',
    'Warning: Merged locus will be set to obsolete! Unobsoleting is possible only directly via the database!',
    '[Merge locus]',
);

page_sentences_ok(
    '/locus/registry.mas',
    'Click {link}here{end_link} to add a new registry name to our database',
    'Click {link}here{end_link} to go back to the registry search',
    'This locus is associated with registry name: {registry}',
);

done_testing;
