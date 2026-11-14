=head1 NAME

t/unit/mason/text/sentences_help_2.t - help templates, part 2 of 3: sentences appear in the user's language

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
    '/help/faq.mas',
    '{bold}Answer: {end_bold}Use this {link}file{end_link}, and read this {link2}key{end_link2}. {bold2}Caveat{end_bold2}: a unigene may be split or merged with other unigene(s) in different builds. For unigenes of non-tomato species, look for similarly named files higher up in the ftp directory.',
    '{bold}Answer:{end_bold} Please send us a message using the {link}contact form{end_link} with a description of the data you would like to submit. We will then work with you to integrate your data into the database and/or add it to the FTP server.',
    '{bold}Answer:{end_bold} As an alternative to Gbrowse\'s download function, you can use this {link}tool{end_link} to select your region of interest and download the features using the download options at the top right of the page.',
    '{bold}Answer:{end_bold} You are working with an old browser that does not support style sheets, such as the browsers of the Netscape 4.x series. SGN pages require style sheets and javascript to be turned on.',
    'This page contains questions that SGN users ask and are useful to the larger SGN user community. Please {link}let us know{end_link} if you have a question that you think should be added.',
    'For all other libraries, please contact the library submitters given on the library detail pages (use the {link}Library Search{end_link} page to find the library in question).',
);

page_sentences_ok(
    '/help/fish_submission.mas',
    'This document describes what we at SGN are prepared to accept for FISH experiment data. Please {link}contact us{end_link} if you have any questions about these guidelines.',
    'For each upload of several spreads, a single spreadsheet with at least the following columns (columns of other data will be ignored):',
    'For example, a single spread for a BAC on chromosome 11\'s long arm would be:',
);

done_testing;
