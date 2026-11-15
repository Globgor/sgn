=head1 NAME

t/unit/mason/text/links.t - links templates: the text is shown in the user's language

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

component_compiles_ok('/links/afri_sol.mas');

page_texts_ok(
    '/links/related_sites.mas',
    'The Experimental Garden and Genebank of the Radboud University of Nijmegen pays special attention to the family of Solanaceae and maintains the most extensive ex situ plant collection of non-tuberous Solanaceae species in the world.',
    'The official website of the USDA sponsored Solanaceae Coordinated Agricultural Project (SolCAP), which will phenotype and genotype large panels of tomato and potato accessions. Results will also be made available on SGN.',
    'The Phenom Network engine by Dani Zamir and Yaniv Semel represents knowledge of complex traits and has tomato ILs, barley and rose traits with more organisms being added soon.',
    'The Canadian Potato Genome Project (CPGP) was launched in 2002 to develop resources in gene discovery in potatoes, for use by Canadian researchers and their partners.',
    'The National BioResource Project (NBRP) is a national project that aims to collect, preserve, and provide bioresources for life sciences research.',
    'An NSF funded project to study signaling networks that are involved in the induction of tuber formation.',
);

page_texts_ok(
    '/links/seed_companies.mas',
    'List of Solanaceae Seed companies',
    'Company Name',
    'Species',
    'Website',
);

done_testing;
