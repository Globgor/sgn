=head1 NAME

t/unit/mason/text/brapiclient_1.t - brapiclient templates, part 1 of 3: the text is shown in the user's language

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
    '/brapiclient/authentication.mas',
    'Your Username',
    'Password',
    'Logout',
    'Login',
);

page_texts_ok(
    '/brapiclient/calls.mas',
    'Show Calls',
    'Calls',
);

page_texts_ok(
    '/brapiclient/comparegenotypes.mas',
    'Compare genotypes using BrAPI',
    'Genotype 1 name:',
    'Genotype 2 name:',
    'Server:',
    'Submit',
);

page_texts_ok(
    '/brapiclient/crops.mas',
    'Show Crops',
    'Crops',
);

page_texts_ok(
    '/brapiclient/germplasm_attributes.mas',
    'Get Attributes for Germplasm',
    'Germplasm Attributes Detail',
    'Germplasm Attributes List',
    'Get Attributes',
);

page_texts_ok(
    '/brapiclient/germplasm_detail.mas',
    'Germplasm Details',
    'Get Details',
);

page_texts_ok(
    '/brapiclient/germplasm_search.mas',
    'Wildcard. Wildcard allows % or * for multiple characters and ? for single characters.',
    'Germplasm Search and Exchange',
    'BrAPI Germplasm Exchange',
    'Germplasm Search',
    'Database Select',
    'Search',
);

page_texts_ok(
    '/brapiclient/home.mas',
    'Germplasm Search and Exchange',
    'Phenotyping Handhelds',
    'Phenotype Retrieval',
    'Genotype Retrieval',
    'Calls Testing',
    'URL Select',
);

page_texts_ok(
    '/brapiclient/locations.mas',
    'Get Locations',
    'Locations',
);

page_texts_ok(
    '/brapiclient/maps.mas',
    'Genome Maps',
    'Get Maps',
);

page_texts_ok(
    '/brapiclient/maps_detail.mas',
    'Maximum Position e.g. 200000',
    'Minimum Position e.g. 10000',
    'Genome Map Details',
    'Get Map Details',
);

page_texts_ok(
    '/brapiclient/markerprofile_allelematrix.mas',
    'JSON (transformed to HTML table)',
    'MarkerProfile Details',
    'Genotype Retrieval',
    'Get AlleleMatrix',
    'Database Select',
    'local',
);

done_testing;
