=head1 NAME

t/unit/mason/text/search_2.t - search templates, part 2 of 2: the text is shown in the user's language

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

component_compiles_ok('/search/loci.mas');

page_texts_ok(
    '/search/organisms.mas',
    'Organism/Taxon Search',
    'Popular Species',
    'Search Results',
    'Search',
);

page_texts_ok(
    '/search/people.mas',
    'Organization:',
    'Search People',
    'Organization',
    'First Name:',
    'First name',
    'Last Name:',
);

component_compiles_ok('/search/quick_search.mas');

page_texts_ok(
    '/search/sequence_metadata.mas',
    'Search Sequence Metadata',
);

page_texts_ok(
    '/search/stocks_using_genotypes.mas',
    'Search Accessions Containing Specific Genotypes',
    'Need to create a list of marker alleles.',
    'Select a list of marker alleles:',
    'Select a list of marker alleles',
    'Select a list of accessions:',
    'Select a list of accessions',
);

page_texts_ok(
    '/search/traits.mas',
    'Search any trait synonym or part of a synonym',
    'Is the trait you are looking for not here?',
    'Search any trait name or piece of name',
    'Search any word or piece of definition',
    'Search any trait ID or part of an ID',
    'Copy Selected Results to a List',
);

page_texts_ok(
    '/search/treatments.mas',
    'Search any trait synonym or part of a synonym',
    'Search any treatment name or piece of name',
    'Search any word or piece of definition',
    'Search any trait ID or part of an ID',
    'Copy Selected Results to a List',
    'Search Treatment Synonym:',
);

page_texts_ok(
    '/search/vectors.mas',
    'View Another Property:',
    'Type to Autocomplete',
    'Type search here...',
    'Advanced Search',
    'Search Results',
    'Search Vectors',
);

done_testing;
