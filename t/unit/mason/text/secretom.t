=head1 NAME

t/unit/mason/text/secretom.t - secretom templates: the text is shown in the user's language

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

component_compiles_ok('/secretom/autohandler');

page_texts_ok(
    '/secretom/index.mas',
    'A project to catalog and study the dynamic properties of the cell wall proteome (the secretome), using tomato as a model system.',
    'Integrated Proteome/Transcriptome Profiling of Tomato Fruit',
    'The Secretome of Phytophthora/Tomato Interactions',
    'Computational Prediction of the Plant Secretome',
    'Tomato Comparative and Quantitative Proteomics',
    'The Tomato Fruit Cuticular Cell Wall Proteome',
);

page_texts_ok(
    '/secretom/outreach.mas',
    'Education, Training, and Outreach Activities',
);

page_texts_ok(
    '/secretom/publications.mas',
    'Secretom Project Publications',
);

page_texts_ok(
    '/secretom/secretary.mas',
    'Paste one or more protein sequences in FASTA format',
    'And/or upload a FASTA file of protein sequences',
    'Show predicted signal peptides only',
    'Show results in browser.',
    'Show Input Example',
    'Download results.',
);

page_texts_ok(
    '/secretom/signalp_search_result.mas',
    'SecreTary SignalP TargetP Result Search',
    'Results',
);

page_texts_ok(
    '/secretom/training.mas',
    'We had another extremely successful Proteomics Workshop this year that was highly oversubscribed. The workshop comprised both lectures and practical lab-based training in proteomic analysis, using advanced mass spectrometry techniques and bioinformatics and was targeted towards undergraduate and graduate students.  Based on the positive and enthusiastic feedback, a similar course will be offered next year.',
    'Summary of the group results for shotgun analysis in 4000 Q Trap and Synapt HDMS. Summary of the iTRAQ demo results for quantitative proteomics by Sheng Zhang.',
    'PLGS 2.4-Mascot database search and generating PKL file by Yong Yang and Kevin Howe in room 143',
    'Mascot Maemon search and wiff file conversion to TMP file by Dr. Celeste Ptak in room 130',
    'Kevin revealing some of the principles and wizardry of mass spectrometry',
    'MALDI-TOF/TOF analysis for 2D gel-based protein IDs: by Bob Sherwood',
);

done_testing;
