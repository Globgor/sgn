=head1 NAME

t/unit/mason/text/breeders_toolbox_4.t - breeders_toolbox templates, part 4 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/location_edit.mas',
    'Program: (One or More)',
    'Store Location Details',
    'Location Details',
    'Abbreviation:',
    'Altitude (m):',
    'Screenhouse',
);

page_texts_ok(
    '/breeders_toolbox/location_map.mas',
    'Add a new location by clicking on the map. Or select an existing location to view details and options.',
);

page_texts_ok(
    '/breeders_toolbox/location_table.mas',
    'Filter Locations by List:',
    'Nearest NOAA Station ID',
    'Abbreviation',
    'Altitude(m)',
    'Country',
    'Program',
);

page_texts_ok(
    '/breeders_toolbox/manage_accessions.mas',
    'Download All Accessions and Pedigree Info',
    'Accessions Missing Pedigree Information',
    'Add Accessions Or Upload Accession Info',
    'Accessions with Pedigree Information',
    'Obsolete Accessions Using a List',
    'Copy accessions to a List',
);

component_compiles_ok('/breeders_toolbox/manage_crosses.mas');

done_testing;
