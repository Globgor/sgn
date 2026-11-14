=head1 NAME

t/unit/mason/text/search_1.t - search templates, part 1 of 2: the text is shown in the user's language

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
    '/search/advanced_search.mas',
    'Search',
);

component_compiles_ok('/search/autohandler');

page_texts_ok(
    '/search/bulk.mas',
    'The Bulk Search will check a list of data items if they exist in the database for the specified data type.',
    'Enter the names of the data items (one per line)',
    'Copy Existing Items to a List',
    'Copy Missing Items to a List',
    'Back to Search',
    'Existing Items',
);

page_texts_ok(
    '/search/cross.mas',
    'Search common parents by using a list of accessions.',
    'Search cross details of female or male parents.',
    'Search progenies of female or male parents.',
    'Search Progenies, Parents and Crosses',
    'All cross entries in the database',
);

page_texts_ok(
    '/search/datasets.mas',
    'Dataset name',
    'Description',
    'Published',
    'Public',
    'Owner',
);

component_compiles_ok('/search/features.mas');

page_texts_ok(
    '/search/genotyping_data_projects.mas',
    'Filter Projects by Accessions',
    'Total Number of Accessions',
    'Genotyping Project Search',
    'Genotyping Project Name',
    'Copy Results to a List',
    'Genotyping Facility',
);

page_texts_ok(
    '/search/genotyping_projects_accession_filter.mas',
    'Starting with a list of Accessions, this tool will identify the genotyping projects that contain the highest number of your accessions.',
    'Filter Genotyping Projects by Accessions:',
    'Best Genotyping Projects',
    'Accession Usage Details',
    'Copy Results to a List',
    'Accession',
);

page_texts_ok(
    '/search/genotyping_protocols.mas',
    'Filter Protocols by Accessions',
    'Genotyping Protocol Search',
    'Protocol Description',
    'Header Description',
    'Number of Markers',
    'Reference Genome',
);

page_texts_ok(
    '/search/genotyping_protocols_accession_filter.mas',
    'Starting with a list of Accessions, this tool will identify the genotyping protocols that contain the highest number of your accessions.',
    'Filter Protocols by Accessions:',
    'Best Genotyping Protocols',
    'Accession Usage Details',
    'Copy Results to a List',
    'Accession',
);

page_texts_ok(
    '/search/genotyping_trials.mas',
    'Genotyping Plate Search',
    'Copy Results to a List',
    'Genotyping Facility',
    'Breeding program',
    'Description',
    'Sample Type',
);

page_texts_ok(
    '/search/images.mas',
    'All images may not have names, descriptions, or tags associated with them.',
    'Image descriptors (name, description, or filename):',
    'e.g. Accession/Plot/TissueSample',
    'e.g. DroneProject 01/01/2019',
    'Image Search Criteria',
    'Image Search Results',
);

done_testing;
