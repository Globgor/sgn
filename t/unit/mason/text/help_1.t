=head1 NAME

t/unit/mason/text/help_1.t - help templates, part 1 of 2: the text is shown in the user's language

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
    '/help/blast.mas',
    'You can choose different output options. The "Overview graph" option will show a graphic represenations of the hits in the database. The "Coverage graph" displays a graphical representation how the matches line up on the query sequence. The "Bioperl" parser displays a formatted version of the BLAST report with embedded links to other pages on the site. The "Basic" version shows the raw output of the BLAST report. Note that if the query contains several sequences (such as multi-fasta), the output will always default to the "Basic" parse option.',
    'Enter the sequence in the Query textarea and choose the appropriate format from the format selector (for example, nucleotide fasta). Choose the appropriate blast program (for example, blastn for running a nucleotide query against a nucleotide database). The default is autodetect, which should detect the format you entered and convert it to the correct sequence format to run blast automatically.',
    'The Results section will show the ouput (depending on your chosen Output options) when a BLAST analysis has been run. When the analysis is finished, the Input parameters sections will be collapsed and the Results section opened. To re-run a query, simply click on the + sign in the Input parameter section header to view that section again and adjust the parameters.',
    'To make finding the right BLAST database faster, the databases are organized into different categories, which can be selected using the "Categories" pull-down menu. Each category contains a number of BLAST databases which can be selected in the "Database" pull down menu.',
    'You can extract sequences from the BLAST databases using identifiers or key words in the annotation of the sequences. Click on the "Extract sequences from BLAST databases" section and enter the search string. It will search in the database selected above.',
    'If you would like to filter the query for low-complexity sequence, leave the Filter checkbox selected. This is the recommended setting.',
);

page_texts_ok(
    '/help/clone_policy.mas',
    'Tomato Genome Project - clone distribution policy',
    'Clones 1 - 150 in any twelve month period:',
    'Clone Request Charges',
    'Acknowledgements',
    'Cost Basis',
);

page_texts_ok(
    '/help/contact.mas',
    'Use this contact form instead.',
    'Mailing Address',
    'Contact Form',
    'Contact Us',
    'Body* :',
    'Submit',
);

page_texts_ok(
    '/help/cos_markers.mas',
    'Conserved Ortholog Set (COS) markers',
    'Functional annotation of COS markers',
);

page_texts_ok(
    '/help/cosii_markers.mas',
    'Conserved Ortholog Set (COS) markers',
    'Functional annotation of COS markers',
);

page_texts_ok(
    '/help/cview.mas',
    'Clicking on one of the chromosome glyphs on the overview page will bring up the chromosome view. In this view, a chromosome is displayed in its entirety, but most of the marker names will be hidden because on most maps there are too many markers to be displayed. To see all the markers, the map can be zoomed into by clicking on a point of interest. This will bring up a zoomed-in view alongside the chromosome. The chromosome can also be compared to another chromosome of another map by choosing a comparison chromosome from the list.',
    'When choosing a map from the map menu, the map overview page will be displayed. It shows some overview information about the map and allows the map to be queried with marker names. The basic elements on this page are:',
    'Clicking on the "view entire map" link in the chromosome view displays the map comparison view. In total, three maps can be compared at the same time. Below is a screenshot of a comparison of tomato and potato.',
    'A small overview graph with all the chromosomes in the map that illustrates the marker density of each linkage group. The glyphs are clickable and will open the clicked chromosome in chromosome detail view.',
    'A text box that can be used to locate markers on the map - you can highlight multiple markers by entering marker names separated by spaces.',
    'User comments. Any logged in user can leave a comment about the map displayed. The comment feature is not available on all maps.',
);

page_texts_ok(
    '/help/datasets.mas',
    'Working with Datasets',
    'Retrieving Datasets',
    'Searching Datasets',
    'Creating Datasets',
    'Dataset Help',
);

page_texts_ok(
    '/help/downloading.mas',
    'Data Download Options',
);

page_texts_ok(
    '/help/faq.mas',
    'SGN: Frequently Asked Questions (FAQ)',
    'Answer:',
);

page_texts_ok(
    '/help/file_upload_type.mas',
    'Optional columns may be left out, if not used in your data.',
);

page_texts_ok(
    '/help/fish_submission.mas',
    'When submitting spreads, the preferred folder layout looks like this:',
    'FISH Data Submission Help',
);

page_texts_ok(
    '/help/gene_search_help.mas',
    'In this drop-down menu you will see a list of the common names of species that make up the collection of genes. You can use this optionfor limiting your search results to loci of only the organism you selected.',
    'The following search options can be combined with the generic locus/allele search option. These are visible by clicking the \\\'Advanced search options\\\' button:',
    'Use this box for searching genes annotated to a specific GenBank ID. You may search using either a GI number or a GenBank accession.',
    'Use these checkboxes for narrowing your search to only genes with one or more of the following features:',
    'Choose a chromosome from this menu to limit results to loci mapped on that chromosome or linkage group.',
    'Sequence: genes that have sequence annotation (GenBank ID and/or SGN unigene ID)',
);

done_testing;
