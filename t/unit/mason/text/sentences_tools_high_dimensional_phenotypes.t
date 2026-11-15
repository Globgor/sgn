=head1 NAME

t/unit/mason/text/sentences_tools_high_dimensional_phenotypes.t - tools/high_dimensional_phenotypes templates: sentences appear in the user's language

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
    '/tools/high_dimensional_phenotypes/upload_high_dim_spreadsheet_dialogs.mas',
    '{strong}{column}{end_strong}: This should be a sample name that exists in the database. The sample can come from a sampling trial or a field trial or a genotyping plate.',
    '{strong}{column} (optional){end_strong}: The International Chemical Identifier (shortened version of {referenced_column}) for the metabolite.',
    '{strong}{column}{end_strong}: Optional comments for any information to include. Can include specific sample preparation for measurement.',
    'All other columns are {strong}metabolite names{end_strong}. You can add as many columns as you want to upload, there isn\'t a limit.',
    '{strong}{column} (required){end_strong}: This should be the same name as present in a column in your metabolomics data matrix file.',
    'All other columns are {strong}gene ids{end_strong}. You can add as many columns as you want to upload, there isn\'t a limit.',
);

done_testing;
