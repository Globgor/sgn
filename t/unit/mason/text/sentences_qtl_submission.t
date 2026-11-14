=head1 NAME

t/unit/mason/text/sentences_qtl_submission.t - qtl/submission templates: sentences appear in the user's language

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
    '/qtl/submission/guide/contact.mas',
    'If you have any questions or feedback, please contact the {link}development team{end_link}.',
);

page_sentences_ok(
    '/qtl/submission/guide/genotype_dataset.mas',
    '{strong}Third row{end_strong}: first column is empty. The rest of the columns are marker positions in their respective chromosomes.',
    '{strong}Second row{end_strong}: first column is empty. The rest of the columns are chromosome names for the corresponding markers.',
    '{strong}The rest of the rows{end_strong}: first column is the genotype name and the rest are the genotype values for each marker.',
    '{strong}First row{end_strong}: first column refers to the label of the rows of lines. The rest of the columns are marker names.',
);

page_sentences_ok(
    '/qtl/submission/guide/index.mas',
    'This document guides QTL data submitters on the process of loading the data, setting statistical parameters and finally the QTL mapping.',
);

page_sentences_ok(
    '/qtl/submission/guide/population_details.mas',
    '{strong} Select organism:{end_strong} fill in the common name of the species the population belongs to. Press the \'associate organism\' button. Then proceed with the rest of the form.',
    '{strong} Cross type:{end_strong} at this stage only inter cross (F2), backcross, RIL (from both sibling mating and selfing) diploid populations are supported.',
    '{strong} Do you want to make the data public:{end_strong} Choose \'Yes\' or \'No\' depending on whether you want to share the QTL data with the community or not.',
    '{strong} Population name:{end_strong} provide a concise and precise name for the population. This will also serve as the genetic map name of the population.',
    '{strong} Recurrent and donor parents:{end_strong} In the same format as the female and male parents but required only in case of backcross population.',
    '{strong} Population description:{end_strong} provide an abstract style characterization of the population including experimental design highlights.',
);

page_sentences_ok(
    '/qtl/submission/guide/qtl_analysis.mas',
    'On the population page, click the graph icon under the \'QTL(s)\' column and in a couple of minutes you will be taken to a page with the genome wide QTL mapping output.',
    'Now that the QTL data is uploaded to the database, you can proceed to perform the on-the-fly QTL analysis for one trait at a time.',
    'Further help can be found {link}here{end_link}.',
);

page_sentences_ok(
    '/qtl/submission/guide/statistics.mas',
    '{strong}QTL genotype probability method:{end_strong} Select \'Calculate\' if you want the QTL genotype to be estimated based the observed marker data. This method must be selected if you selected \'Maximum Likelihood\' or \'Haley-Knot Regression\'. If you selected \'Multiple Imputation\' then choose the \'Simulate\' method.',
    '{strong}QTL mapping method:{end_strong} You can select  \'Single Marker Analysis\'  or \'Maximum Likelihood\' for standard interval mapping or for an approximation of it \'Haley-Knot Regression\' or \'Multiple Imputation\'. Use \'Multiple Imputation\' only if you want to estimate the QTL genotype based on random imputation.',
    '{strong}No. of permutations and significance level:{end_strong} select the number of permutations to perform and the error rate for the calculation of the LOD threshold.',
    '{strong}No. of imputations:{end_strong} applicable only for \'Multiple Imputation\' mapping method and \'Simulate\' QTL genotype probability method.',
    '{strong}QTL model:{end_strong} Select the one dimension single QTL genome scan  (the two-dimension two genome QTL scan is under development)',
    '{strong}Genome scan size (cM):{end_strong} select the genome size (interval) you want the QTL genotype probabilities to be calculated.',
);

done_testing;
