=head1 NAME

t/unit/mason/text/genomes_Solanum_lycopersicum.t - genomes/Solanum_lycopersicum templates: the text is shown in the user's language

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
    '/genomes/Solanum_lycopersicum/announcements/prerelease_20091201.mas',
    'Prerelease of Tomato Genome Shotgun Sequence',
    'Data Agreement and Disclaimer',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicum/announcements/prerelease_20100104.mas',
    'Prerelease of Tomato Genome Shotgun Sequence',
    'Tomato Whole Genome Shotgun data',
    'Data Agreement and Disclaimer',
    'BAC by BAC progress overview',
    'BLAST tomato BAC contigs',
    'BLAST WGS scaffolds',
);

component_compiles_ok('/genomes/Solanum_lycopersicum/clone_sequencing.mas');

page_texts_ok(
    '/genomes/Solanum_lycopersicum/inbreds.mas',
    'Fla630 genome',
    'BTI87 genome',
    'Gh13 genome',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicum/itag_releases.mas',
    'annotation data temporarily unavailable',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicum/publications.mas',
    'Tomato Genome Publications',
    'Publications',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicum/sequencing/view_contig/input.mas',
    'Input Tomato BAC Contig Name',
    'Contig name:',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicum/tomato150.mas',
    'Wageningen UR 150 Tomato Genome Resequencing Project',
    '150 Tomato Genomes',
);

page_texts_ok(
    '/genomes/Solanum_lycopersicum/tomato360.mas',
    'Genomic analysis of 360 tomato accessions by the Agricultural Genomic Institute at Shenzhen.',
    'AGIS Tomato 360 Resequencing Project',
    '360 Tomato Genomes',
);

done_testing;
