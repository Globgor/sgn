=head1 NAME

t/unit/mason/text/first_pages.t - home page and search pages: the text is shown in the user's language

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
    '/homepage/phenotype_uploads.mas',
    'Phenotype Files Uploaded',
    'Date Uploaded',
    'Uploaded By',
    'File Type',
    'Filename',
    'Options',
);

page_texts_ok(
    '/index.mas',
    'Breedbase is a comprehensive breeding management and analysis software. It can be used to design field layouts, collect phenotypic information using tablets, support the collection of genotyping samples in a field, store large amounts of high density genotypic information, and provide Genomic Selection related analyses and predictions. Breedbase supports the BrAPI standard.',
    'How can I learn more about Breedbase?',
    'What crops are using Breedbase?',
    'How can I use Breedbase?',
    'What is Breedbase?',
);

page_texts_ok(
    '/index_logged_in_user.mas',
    '10 most recently added accessions:',
    '10 most recently modified trials:',
    '10 most recently created trials:',
    'Continue where you left off:',
    'Last phenotype added',
    'Breeding Program',
);

component_compiles_ok('/search/stocks.mas');

component_compiles_ok('/search/stocks_graphicalfiltering.mas');

page_texts_ok(
    '/search/trials.mas',
    'Copy Results to a List',
    'Breeding program',
    'Planting Date',
    'Harvest Date',
    'Trial Search',
    'Description',
);

done_testing;
