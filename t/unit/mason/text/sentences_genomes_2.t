=head1 NAME

t/unit/mason/text/sentences_genomes_2.t - genomes templates, part 2 of 3: sentences appear in the user's language

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
    '/genomes/Nicotiana_tabacum.mas',
    'Tobacco stands out as a complex allotetraploid with a large 4.5 Gb genome with significant proportion (>70%) of repeats.',
);

page_sentences_ok(
    '/genomes/Solanum_lycopersicum.mas',
    'The official annotation for the tomato genome is provided by the {link}International Tomato Annotation Group (ITAG){end_link}, a multinational consortium, funded in part by the {link2}EU-SOL project{end_link2}.',
    'The {link}Tomato Genome Annotation pages{end_link} at the {link2}computational biology group{end_link2} of the {link3}University of Naples{end_link3}, Italy.',
    'All data is openly and freely available on {link}SGN{end_link}, {link2}MIPS{end_link2}, and Genbank.',
    '{link}Tomato FPC pages{end_link} at University of Arizona, USA.',
);

done_testing;
