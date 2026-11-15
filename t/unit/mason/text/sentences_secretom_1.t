=head1 NAME

t/unit/mason/text/sentences_secretom_1.t - secretom templates, part 1 of 2: sentences appear in the user's language

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
    '/secretom/index.mas',
    '{strong}Why study the "secretome"?{end_strong} Proteomic analysis of cellular compartments reveals the subcellular locations of a specific protein, or protein complex, which in turn can be a valuable step towards understanding protein function. Localization information also helps in the identification of protein interactions and targeting pathways, and peptide motifs and structural signatures that can direct proteins to various cellular locations. In addition the analysis of a subcellular proteome has the advantage of requiring "biological pre-fractionation," which can substantially enhance the detection of lower-abundance proteins.',
    '{strong}What is the "secretome"?{end_strong} The term "secretome" is generally used to refer to the population of proteins that are secreted outside the plasma membrane of a cell, but can also be used to describe the subset of the proteome that enter the {link}secretory pathway{end_link}.',
    '{strong}The purpose of this NSF-funded project{end_strong} is to catalog and study the dynamic properties of the cell wall proteome, or secretome, using tomato ({species}) as a model system.',
    '{link}Education and training opportunities{end_link} in plant proteomics and cell wall biology are available as part of {span}Secretom{end_span}.',
    'For questions and comments regarding the SecreTom project, please contact {person} at {address}.',
    'This project and database are funded by National Science Foundation Grant {grant}.',
);

page_sentences_ok(
    '/secretom/outreach.mas',
    'The Plant Genome Research Program summer {link}interns{end_link} participate in various genomics-associated activities on campus, including the cell wall proteomics project. This included practical lab-based training of students and classroom lectures.',
    '{link}Workshops{end_link} on proteomics technologies and techniques are given at the {link2}Cornell Proteomics and Mass Spectrometry Core Facility{end_link2}. An example of the handouts from the workshop are available online. ({link3}pdf{end_link3})',
);

page_sentences_ok(
    '/secretom/signalp_search_result.mas',
    'No results found matching "{query}".',
);

done_testing;
