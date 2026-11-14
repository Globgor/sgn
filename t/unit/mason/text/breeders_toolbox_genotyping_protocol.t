=head1 NAME

t/unit/mason/text/breeders_toolbox_genotyping_protocol.t - breeders_toolbox/genotyping_protocol templates: the text is shown in the user's language

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
    '/breeders_toolbox/genotyping_protocol/delete_genotype_data.mas',
    'Delete Genotyping Data For this Protocol',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/details.mas',
    'Header Information Description',
    'Genotyping Protocol Name',
    'Protocol Description',
    'Number of Markers',
    'Reference Genome',
    'Species Name',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/edit_genotyping_protocol_details_dialog.mas',
    'Error Saving Genotyping Protocol Details',
    'Edit Genotyping Protocol Details',
    'Genotyping Protocol Name:',
    'Indicates pending change',
    'Reference Genome Name:',
    'Close & Reload',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/genotype_data.mas',
    'Number of Marker Scores',
    'Refresh results',
    'Accession Name',
    'Description',
    'Sample Name',
    'Sample Type',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/index.mas',
    'Delete genotyping protocol and all data from this protocol.',
    'View information about the markers used in this protocol.',
    'View metadata assigned to markers used in this protocol.',
    'View and download genotyping data from this protocol.',
    'View basic information about the genotyping protocol.',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/marker_metadata.mas',
    'Delete All Marker Metadata',
    'References (one per line):',
    'Alleles (one per line):',
    'Edit Marker Metadata',
    'Description:',
    'Marker Name:',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/markers.mas',
    'Marker name(s) (comma separated)',
    'Marker Name(s):',
    'Search',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/pcr_genotype_data.mas',
    'Download SSR Genotype Data',
    'Sample Name',
    'Sample Type',
    'Ploidy',
    'Close',
);

page_texts_ok(
    '/breeders_toolbox/genotyping_protocol/pcr_markers.mas',
    'Annealing Temperature',
    'Sequence Source',
    'Forword Primer',
    'Reverse Primer',
    'Sequence Motif',
    'Linkage Group',
);

done_testing;
