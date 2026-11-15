=head1 NAME

t/unit/mason/text/sentences_dataset.t - dataset templates: sentences appear in the user's language

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
    '/dataset/publish.mas',
    '{bold}IMPORTANT!{end_bold} Once you make the external dataset public, all of the uploaded files and metadata become {em}permanently available{end_em} and cannot be removed or modified from this version of the dataset. If you need to make updates, changes can be made and new files can be uploaded and a new version of the external dataset will need to be published (the original version will still be accessible).',
    '{bold}IMPORTANT!{end_bold} By continuing to upload these files, you acknowledge that this data is allowed to be shared on {span}the external service{end_span} and can be made publicly available (once the dataset on {span}the external service{end_span} is published).',
    'Once the external dataset has been published (made public), the uploaded files and metadata are {em}permanently available{end_em}. Any changes you make will need to be republished to a new version of the external dataset.',
    '{bold}Generate the archived files{end_bold} - this creates a static snapshot of the data within the dataset at the time when the files are generated',
    '{bold}Reserve a DOI{end_bold} - generate a Digital Object Identifier (DOI) for the external dataset that can be used as a reference in publications.',
    '{bold}Upload the files to an external service{end_bold} - this will upload the archived files to a new or existing dataset on the external service',
);

done_testing;
