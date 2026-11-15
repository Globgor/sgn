=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_genotyping_protocol.t - breeders_toolbox/genotyping_protocol templates: sentences appear in the user's language

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
    '/breeders_toolbox/genotyping_protocol/marker_metadata.mas',
    'To upload metadata and alleles for markers in this protocol, go to the {link}Manage Genotyping Projects{end_link} page and select the {strong}Add Marker Metadata{end_strong} button.',
    'The references include the associated trait categories and external database references.',
);

done_testing;
