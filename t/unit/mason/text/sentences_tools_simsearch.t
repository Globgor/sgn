=head1 NAME

t/unit/mason/text/sentences_tools_simsearch.t - tools/simsearch templates: sentences appear in the user's language

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
    '/tools/simsearch/index.mas',
    'Upload format is either {link}{vcf}{end_link} or {link2}{dosage}{end_link2} format.',
);

page_sentences_ok(
    '/tools/simsearch/upload_file.mas',
    '(working file name {filename})',
);

done_testing;
