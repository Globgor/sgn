=head1 NAME

t/unit/mason/text/sentences_genomes_1.t - genomes templates, part 1 of 3: sentences appear in the user's language

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

component_compiles_ok('/genomes/Capsicum_annuum.mas');

page_sentences_ok(
    '/genomes/Nicotiana_benthamiana.mas',
    'It is particularly useful because it is related to tomato and potato and is amenable to virus-induced gene silencing (VIGS) which facilitates the efficient functional study of plant genes.',
    'A new draft sequence of the {species} genome has been released by researchers from the {link}Boyce Thompson Institute for Plant Research (BTI){end_link}.',
    'Sequencing was performed using a full run with 4 lanes of the paired end library and 1 lane each of the mate pair libraries.',
    'It is accessible through the SGN BLAST tool and JBrowse, and can be downloaded from the SGN ftp site.',
    'More information about this project can be found at the {link}BTI {species} Project site{end_link}',
    'Seedlings were grown in the greenhouse and nuclear DNA was extracted from etiolated leaves.',
);

done_testing;
