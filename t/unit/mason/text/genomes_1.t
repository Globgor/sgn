=head1 NAME

t/unit/mason/text/genomes_1.t - genomes templates, part 1 of 2: the text is shown in the user's language

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

component_compiles_ok('/genomes/Capsicum_annuum.mas');

page_texts_ok(
    '/genomes/Nicotiana_attenuata.mas',
    'Further detailed description on the process of genome assembly and annotation can be found in this reference:',
    'FTP Site',
);

page_texts_ok(
    '/genomes/Nicotiana_benthamiana.mas',
    'On-line tutorial for VIGS procedure',
    'Shortest sequence (bp)',
    'Longest sequence (bp)',
    'Accession sequenced',
    'Assembly Statistics',
    'Average length (bp)',
);

page_texts_ok(
    '/genomes/Nicotiana_tabacum.mas',
    'The text above was extracted from Sierro, N. et al. 2014',
    'Nicotiana tabacum and related genomes datasets',
    'Genome sequence and Annotation',
    'Genome browser (JBrowse)',
    'SGN VIGS Tool',
    'Genome (Chr)',
);

page_texts_ok(
    '/genomes/Petunia_axillaris.mas',
    'References',
    'VIGS Tool',
    'FTP Site',
);

page_texts_ok(
    '/genomes/Petunia_inflata.mas',
    'References',
    'VIGS Tool',
    'FTP Site',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicoides.mas',
    'Augustus and snap were trained to use as predictors in the Maker pipeline. Sequence data used as input includes: PacBio IsoSeq, RNA-seq from leaves, fruit, and flowers, proteins from S. lycopersicum, S. pennellii, and refseq. A total of 37,938 genes were predicted, 34,240 of these are located on pseudomolecules.',
    'The genome was sequenced at 90X coverage using PacBio technology and was assembled with Canu.  Contigs were error-corrected with Quiver and Pilon and scaffolded with Hi-C.  Gaps were filled with PacBio sequence using PBJelly.',
    'PLEASE READ BEFORE ACCESSING THE PRE-PUBLICATION SEQUENCE OF SOLANUM LYCOPERSICOIDES',
    '89.7% of the assembly is found in 12 scaffolds',
    'Disclaimer and data access agreement',
    'Annotation details',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicum.mas',
    'International Tomato Genome Sequencing Project',
    'browse genome contigs and official annotations',
    'Tomato chloroplast sequence (Genbank)',
    'List of tomato genome publications',
    'Other tomato genome pages on SGN',
    'Tomato genome sequence builds',
);

page_texts_ok(
    '/genomes/Solanum_pennellii.mas',
    'Available Data',
    'Abstract',
);

page_texts_ok(
    '/genomes/Solanum_pimpinellifolium.mas',
    'Disclaimer and data access agreement',
    'Available Data',
);

component_compiles_ok('/genomes/Solanum_tuberosum.mas');

component_compiles_ok('/genomes/default.mas');

done_testing;
