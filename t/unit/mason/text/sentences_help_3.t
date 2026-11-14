=head1 NAME

t/unit/mason/text/sentences_help_3.t - help templates, part 3 of 3: sentences appear in the user's language

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
    '/help/gene_search_help.mas',
    'Each locus in the genes database has an owner (either an SGN curator or a submitter). the owner also has certain edit privileges. You can search for loci owned by a specific {link}SGN user{end_link} by typing a first or a last name. Anyone interested in obtaining an SGN user account may do so by {link2}signing up for a new account{end_link2}. After obtaining an SGN user account you may upload new loci to SGN\\\'s database. If you are interested in obtaining editor privileges to a specific locus, please follow the link in the locus details page.',
    'Some genes may have a phenotype description, either as an associated allele, or an associated phenotyped accession. This option will narrow the search results for only genes with a phenotype description containing the word or string you typed in. For searching phenotypes of accessions not necessarily associated with a gene, you should use SGN\\\'s {link}phenotype search{end_link} page.',
    'Use this option for searching the database for genes with a locus or allele name/symbol/synonym/description containing what you typed in. You can search these fields for an exact match, begin with or end with your input, by selecting the desired option from the drop-down menu. The search is case-insensitive.',
    'Use this box for searching for genes that are annotated to specific {link}Gene Ontology{end_link} or {link2}Plant Ontology{end_link2} terms. You may search for ontology annotations by typing any part of the ontology term ID, term name, term synonym, or term definition.',
    'The {link}gene search{end_link} is a tool for searching genes in SGN\'s database. These genes originate from various sources, including GenBank, PubMed literature mining, historic collections of gene names, and SGN user-contributed data.',
    'GO/PO annotation: genes that are annotated to at least one {link}Gene Ontology{end_link} or {link2}Plant Ontology{end_link2} term',
);

page_sentences_ok(
    '/help/index.mas',
    'Breedbase is a comprehensive breeding management and analysis software. It can be used to design field layouts, collect {link}phenotypic and other information using Phenoapps software{end_link}, support the collection of genotyping samples in a field, store large amounts of high density genotypic information, and provide Genomic Selection related analyses and predictions. Breedbase supports the {link2}BrAPI standard{end_link2}.',
    'The complete Breedbase help is available from the {link}Breedbase and SGN manual{end_link}.',
    'A guide for {link}developers is also available{end_link}.',
    'Video Tutorials are available on {link}YouTube{end_link}.',
);

page_sentences_ok(
    '/help/marker_search_help.mas',
    'Some markers have been associated with BACS from the {link}tomato sequencing project{end_link}. Most of these associations come from the {link2}overgo plating process{end_link2} in which markers were hybridized to BAC DNA. Other associations are computational, meaning they were made by BLAST comparisons. Still others are "manual" associations, meaning they were associated in some other way and then entered into our database.',
    'If you know the name of your marker, type it in. By default, the database will be searched for all markers with a name that {i}starts with{end_i} what you type in.',
    'This multiple-select box shows a list of our available maps. For more information on these maps, see the {link}map overview page{end_link}.',
    'The {link}marker search{end_link} is a tool for locating markers in SGN\'s database.',
);

page_sentences_ok(
    '/help/microsats.mas',
    'While microsatellites or simple sequence repeats (SSRs) normally occur in non-coding regions of the genome, they can also occur in either 3\' or 5\' UTRs of ESTs or even in coding regions (usually triplet repeats). For this reason, the tomato and potato EST sequences contained in SGN were screened for microsatellite sequence motifs in May 2001 using analytical tools developed by Genomics Edge Technologies, Inc; St. Louis, Missouri. The purpose was to identify SSRs that might be useful a polymorphic molecular markers genetic and breeding studies in tomato. The search parameters were for all possible repeat motifs 2 bp to 6 bp with repeat blocks > 20 bp. The search algorithms allowed for imperfect repeats as well as complex repeats.',
    'For those wishing to test SSRs for mapping/polymorphism studies, it is recommended (based on empirical testing) to start with:',
);

page_sentences_ok(
    '/help/ordering.mas',
    '{link}Purchase tomato EST or BAC clones{end_link} from {link2}TED BTI{end_link2} at Cornell University.',
    '{link}Purchase potato clones{end_link} from {link2}Arizona Genome Initiative{end_link2}.',
);

page_sentences_ok(
    '/help/phenotype_search_help.mas',
    'Each individual accession in the database is associated to a population. The phenotype search can be limited to only accessions from a specific population. Currently the following phenotyped populations are included in the searchable database:',
    'If you know the accession name of your individual, type it in. By default, the database will be searched for all individuals with an accession name that starts with what you type in.',
    'The {link}phenotype search{end_link} is a tool for searching SGN\'s database for accessions from phenotyped populations.',
    'The search is case-insensitive.',
);

page_sentences_ok(
    '/help/quick_search.mas',
    'The annotation searches search the manual and automatic annotation that are available for unigenes. They report the number of annotations and the number of corresponding unigenes that were found. If there are more than 5000 annotation matches, the number of unigenes is not reported to save on querying time.',
    'The quick search functionality is part of the {link}toolbar{end_link} on top of almost every SGN web page. To use it, simply enter a search term in the text input box and click on the quick search button. The search can take a while depending on the actual word you search.',
    'Quick search performs a series of searches in the database and displays a summary page of the matches. For each of the searches, a line is displayed with information how many entities were matched in the database.',
    'If entities were found in the database, a link is provided to complete the actual search. Click on that link to see the search results.',
    'Identifier searches perform exact match searches on clone, est, unigene and marker identifiers in the database',
    'Searches the libraries on name, tissue, development stage, authors, and other fields as a substring search.',
);

done_testing;
