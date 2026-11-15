=head1 NAME

t/unit/mason/site/pilot_scripts.t - Pilot script messages: the script text is shown in the user's language

=head1 DESCRIPTION

Renders the components with HTML::Mason through SGN::Test::MasonText, without a
database or a Catalyst context. Each text must be on the page in English and,
with a test catalog, in its translated form, as a JSON string inside a script. A component that needs real data
to run is only compiled.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_script_texts_ok component_compiles_ok );

page_script_texts_ok(
    '/breeders_toolbox/folder/folder.mas',
    'Are you sure you want to delete this folder?',
    'An error occurred trying to delete folder.',
    'Folder successfully deleted.',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_protocol/delete_genotype_data.mas',
    'Are you sure you want to delete this genotyping protocol? This cannot be undone!',
    'Error deleting genotyping protocol!',
    'Genotyping protocol deleted!',
);

page_script_texts_ok(
    '/search/stocks_using_genotypes.mas',
    'Please choose a list of marker alleles',
    'Please choose a list of accessions',
    'Accession Name',
    'Sample Name',
    'Sample Type',
    'Genotypes',
);

done_testing;
