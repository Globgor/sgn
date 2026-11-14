=head1 NAME

t/unit/mason/text/help_2.t - help templates, part 2 of 2: the text is shown in the user's language

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
    '/help/heritability.mas',
    'Heritability is a tool that utilizes a dataset to run an R script in the backend. The dataset should include trials and traits. To begin the analysis, users must first select the dataset they wish to analyze. Traits can be filtered using the \'outliers\' tool. The R package \'lmerTest\' will adapt to your dataset. For instance, if the dataset includes different years and locations, those factors will be considered as interactions with genotypes.',
    'Results are summarized in a downloadable table in CSV format.',
    'Heritability Help',
    'Input options',
    'Results',
);

page_texts_ok(
    '/help/index.mas',
    'To cite Breedbase, use the following publication:',
    'Breedbase Help',
);

page_texts_ok(
    '/help/marker_search_help.mas',
    'In this multiple-select box you will see a list of the common names of species (or groups of species, such as "tomato") that make up the mapping populations in our collection of maps. Selecting a species here limits your search results to markers that have been mapped in that species.',
    'Some of our markers have been grouped into collections for organizational purposes, or because all markers in that group are part of a particular project. Here are the meanings of the markers in our collections:',
    'This multiple-select box shows a list of experimental protocols. Selecting one or more of these protocols, for example CAPS, will limit the search results to markers that have been mapped with this protocol.',
    'Choose a chromosome from this box to limit results to markers mapped on that chromosome or linkage group.',
    'If you are interested in a particular region of the chromosome, enter the bounds of that region here.',
    'screenshot of marker search form',
);

page_texts_ok(
    '/help/microsats.mas',
    'See all SSR markers in marker search results',
    'Old text version SSR list',
    'SSR Marker Help',
);

page_texts_ok(
    '/help/ordering.mas',
    'Ordering Clones',
);

page_texts_ok(
    '/help/phenotype_search_help.mas',
    'Here a word or a string can be typed. Searches the database for individuals with the word/string in their \'phenotype description\' field.',
    'screenshot of phenotype search form',
    'Phenotype Search Help',
    '2. Population',
    '3. Accession',
    '1. Keyword',
);

component_compiles_ok('/help/publications.mas');

page_texts_ok(
    '/help/quick_search.mas',
    'Pages on the entire web',
    'Annotation searches',
    'Identifier searches',
    'Quick Search Help',
    'SGN Pages search',
    'Library search',
);

page_texts_ok(
    '/help/solgwas.mas',
    'SolGWAS is meant to be used in conjunction with datasets. The dataset must contain a Genotyping protocol and one or more Trials. The user should first select the dataset they wish to analyze. The list of phenotypes available will then be filled. The user can then select a phenotype of interest, as well as selecting whether to include principal components or kinship covariates in the model.',
    'Once the "Run SolGWAS" button is pressed, several plots will be displayed. These include a Manhattan plot and a QQ plot.',
    'Input options',
    'SolGWAS Help',
    'Results',
);

page_texts_ok(
    '/help/toolbar.mas',
    'Toolbar Help',
);

done_testing;
