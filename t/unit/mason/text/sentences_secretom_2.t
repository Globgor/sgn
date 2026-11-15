=head1 NAME

t/unit/mason/text/sentences_secretom_2.t - secretom templates, part 2 of 2: sentences appear in the user's language

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
    '/secretom/training.mas',
    '{strong}Experimental 1:{end_strong} Protein denaturing, reduction and alkylation of crude cell extract samples for shotgun proteomics analysis. (Attendees divided into 4 groups)',
    '{strong}Lecture 3 Presentation:{end_strong} Introduction to Mascot-based MS database search and data interpretation by Professor {person1}',
    '{strong}Experimental 5:{end_strong} Database searching and file conversion for overnight LC-MS/MS files',
    '{strong}Program introduction{end_strong} by Professor {person1}',
    '{link}Handouts from the workshop{end_link} {format}',
    'Supported by {program}',
);

done_testing;
