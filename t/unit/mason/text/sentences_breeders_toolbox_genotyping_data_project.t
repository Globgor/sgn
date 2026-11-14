=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_genotyping_data_project.t - breeders_toolbox/genotyping_data_project templates: sentences appear in the user's language

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

component_compiles_ok('/breeders_toolbox/genotyping_data_project/genotyping_project_tree.mas');

component_compiles_ok('/breeders_toolbox/genotyping_data_project/manage_genotyping_projects.mas');

done_testing;
