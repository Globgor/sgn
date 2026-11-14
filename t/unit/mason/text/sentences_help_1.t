=head1 NAME

t/unit/mason/text/sentences_help_1.t - help templates, part 1 of 3: sentences appear in the user's language

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
    '/help/blast.mas',
    'BLAST on this site is based on NCBI BLAST and is accessible on {link}{address}{end_link}.',
);

page_sentences_ok(
    '/help/clone_policy.mas',
    'We realize the need for access by the research community to EST clones prior to completion of this project and thus have instituted a policy whereby up to 150 clones per laboratory per year can be requested on a subsidized re-charge basis through the Clemson University Genomics Institute (CUGI) which handles maintenance and distribution of the tomato ESTs and receives funding through this project to offset some of the associated costs.',
    'This collection is currently estimated to range from 25,000 - 40,000 cDNA clones which will be condensed, quality confirmed, and re-arrayed into a collection that can be distributed in whole - or can much more efficiently be searched for individual clones than is currently the case with over 25 libraries each containing 4000 - 15,000 ordered clones.',
    'These funds have been used for a) purchase of 3 -80 freezers and service contracts to insure their operation b) support a half-time tech position, c) annual replication of all EST libraries to insure against loss of clone viability, and d) software upgrades used in clone request tracking and eventual public dissemination of all clone requests.',
    'It is important to realize that with 22 ordered EST libraries (each containing 4,000 - 15,000 ordered clones) tracking, localizing, and picking each clone represents a significant effort.',
    'This later price is in line with other clone distribution centers, such as the American Type Culture Collection (ATCC), which recover total costs through re-charge fees.',
    'For example, when clones are found through additional sequencing to be chimeric, or when a new EST sequence "links" two clones previously thought to be unique.',
);

component_compiles_ok('/help/contact.mas');

page_sentences_ok(
    '/help/cos_markers.mas',
    'We have used a computational method to screen the tomato EST database against the arabidopsis genome sequence in order to find a set of highly conserved, single copy genes which can be used as markers for comparative mapping between the tomato and arabidopsis genomes.',
    'As the functional role descriptions are subject to continued changes, a copy of the role categories and the COS-marker annotations as used in the analysis can be found below:',
    'Most of the COS markers have only one map position, if the COS marker has a second or third map position, then there were two or three alleles that could be mapped.',
    'In this section of SGN, you will find sequence and clone information for each of these COS markers as well as their matching counterpart in the arabidopsis genome.',
    'We have surveyed these COS markers and mapped some of these COS markers on the tomato genome to provide a tomato: arabidopsis comparative map.',
    'ESTs that pass all these criteria are classified as conserved orthologs, all others are considered potentially paralogous and eliminated.',
);

page_sentences_ok(
    '/help/cosii_markers.mas',
    'We have used a computational method to screen the tomato EST database against the arabidopsis genome sequence in order to find a set of highly conserved, single copy genes which can be used as markers for comparative mapping between the tomato and arabidopsis genomes.',
    'As the functional role descriptions are subject to continued changes, a copy of the role categories and the COS-marker annotations as used in the analysis can be found below:',
    'Most of the COS markers have only one map position, if the COS marker has a second or third map position, then there were two or three alleles that could be mapped.',
    'In this section of SGN, you will find sequence and clone information for each of these COS markers as well as their matching counterpart in the arabidopsis genome.',
    'We have surveyed these COS markers and mapped some of these COS markers on the tomato genome to provide a tomato: arabidopsis comparative map.',
    'ESTs that pass all these criteria are classified as conserved orthologs, all others are considered potentially paralogous and eliminated.',
);

page_sentences_ok(
    '/help/cview.mas',
    'They can be viewed by clicking anywhere in the chromosome reference chromosome, which brings up the zoomed-in map (2), in which all markers are displayed in the given interval.',
    'If the physical button is clicked in the toolbar (7), the physical map is displayed, which shows how many BACs have been anchored to the genetic map using the overgo process.',
    'A typical image from a chromosome view is shown in the figure above (the exact rendering of the buttons will depend on the platform and browser used).',
    'For certain maps, the reference chromosome can have additional information displayed, such as IL line information, a ruler, and physical map.',
    'The chromosome number is given on the top and approximately a dozen selected markers are drawn according to their map position.',
    'Only markers that are on the reference map are displayed with their names, the other markers are shown by a tick mark only.',
);

page_sentences_ok(
    '/help/datasets.mas',
    'After creating the dataset, you can make it public for others to use by first selecting the dataset using the “Load Dataset” list then selecting the “Make Public” button.',
    'SGN databases use Datasets in analysis tools on the website such as Wizard, GWAS, GS, Heritability, and Stability tools.',
    'Datasets are attached to the individual user’s account, and can only be created and seen by the user while logged in.',
    'To retrieve a dataset in the Wizard, select the dataset in the “Load Dataset” input then select the “Load” button.',
    'This will populate the columns in the Wizard and then allow you to download and analyze the dataset.',
    'To search for a dataset, select the “Datasets” link in the toolbar at the top right of the website.',
);

page_sentences_ok(
    '/help/downloading.mas',
    'From other FTP clients, when prompted for a username enter {em}{username}{end_em} and when prompted for password enter your email address.',
    'For keeping a set of files up to date with the files we make available, {link}rsync{end_link} is a useful tool.',
    'For manually downloading a few files once in a while, anonymous FTP is particularly convenient.',
    'For example, to retrieve all our map and marker data on a Unix/Linux shell use the command:',
    'To retrieve files from our anonymous rsync server, use the URL {em}{address}{end_em}.',
    'SGN provides various data files for download via anonymous FTP and anonymous rsync.',
);

done_testing;
