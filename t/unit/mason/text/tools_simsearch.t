=head1 NAME

t/unit/mason/text/tools_simsearch.t - tools/simsearch templates: the text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_texts_ok component_compiles_ok );

page_texts_ok(
    '/tools/simsearch/index.mas',
    'Upload a genotyping file to identify matches within the file or with other genotypic data in the database. To compare with data in the database, the upload must correspond precisely to the genotyping protocols available in the database.',
    'Upload',
);

page_texts_ok(
    '/tools/simsearch/results.mas',
    'The following genotypes are exceedingly similar and are suspected duplicates:',
    'Simsearch Results',
);

page_texts_ok(
    '/tools/simsearch/upload_file.mas',
    'Optional: Select reference genotyping file:',
    'Average score',
    'Group members',
    'Run SimSearch',
    'Member count',
    'Max score',
);

done_testing;
