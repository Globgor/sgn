=head1 NAME

t/unit/mason/text/scripts_tools_high_dimensional_phenotypes.t - scripts in the tools/high_dimensional_phenotypes templates: the script text is shown in the user's language

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
    '/tools/high_dimensional_phenotypes/download_high_dim_phenotypes_dialogs.mas',
    'Error downloading high dim phenotype file!',
    'Please select one dataset!',
);

page_script_texts_ok(
    '/tools/high_dimensional_phenotypes/download_high_dim_phenotypes_relationship_matrix_dialogs.mas',
    'Error downloading high dim phenotype relationship matrix file!',
    'Please select one dataset!',
);

page_script_texts_ok(
    '/tools/high_dimensional_phenotypes/upload_high_dim_spreadsheet_dialogs.mas',
    'Please select a protocol or create a new one with a description!',
    'Please select a protocol or give a name for a new one! Not both!',
    'Please select a protocol or create a new one!',
    'Verifying Transcriptomics File and Data',
    'Storing Transcriptomics File and Data',
    'Verifying Metabolomics File and Data',
);

done_testing;
