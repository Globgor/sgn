=head1 NAME

t/unit/mason/text/sentences_fieldbook.t - fieldbook templates: sentences appear in the user's language

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
    '/fieldbook/home.mas',
    '{em}{bold}Field Book{end_bold}{end_em} is an app for collecting phenotypic data on field research plots using an android tablet computer.',
    'Check to use this database as the default {strong}Import Source{end_strong} and {strong}Export Source{end_strong}',
    'Select {strong}Authorize Access{end_strong} to allow Field Book to use your account',
    'Choose the {strong}Import new settings{end_strong} action',
    'Make sure {strong}Enable BrAPI{end_strong} is checked',
    'Go to the Field Book {strong}Settings{end_strong}',
);

page_sentences_ok(
    '/fieldbook/upload_phenotype_fieldbook.mas',
    '{column1} or {column2} or {column3} or {column4}: This should be one of these stock IDs that already exist in the database.',
    '{column}: Corresponding value for the observed trait.',
    '{column}: A trait that exists in the database.',
    '{column}: Observation collector\'s name.',
    '{column}: Timestamp of the observation.',
);

done_testing;
