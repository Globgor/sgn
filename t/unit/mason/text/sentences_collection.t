=head1 NAME

t/unit/mason/text/sentences_collection.t - collection templates: sentences appear in the user's language

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

component_compiles_ok('/collection/add_to_collection_modal.mas');

component_compiles_ok('/collection/collections_tree.mas');

done_testing;
