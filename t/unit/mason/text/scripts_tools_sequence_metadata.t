=head1 NAME

t/unit/mason/text/scripts_tools_sequence_metadata.t - scripts in the tools/sequence_metadata templates: the script text is shown in the user's language

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
    '/tools/sequence_metadata/protocols_sequence_metadata.mas',
    'ERROR: Could not load types!',
    'ERROR: Could not load types',
);

page_script_texts_ok(
    '/tools/sequence_metadata/query_sequence_metadata.mas',
    'ERROR: Could not load reference genomes!',
    'ERROR: Could not perform marker search',
    'ERROR: Could not load protocols!',
    'ERROR: Could not load features!',
    'ERROR: Could not load protocols',
    'ERROR: Could not load features',
);

component_compiles_ok('/tools/sequence_metadata/quick_query_sequence_metadata.mas');

page_script_texts_ok(
    '/tools/sequence_metadata/upload_sequence_metadata_workflow.mas',
    'ERROR: Could not upload and verify gff file due to server error!',
    'ERROR: Could not store sequence metadata due to server error!',
    'Please enter a description for the new protocol',
    'ERROR: Could not load reference genomes!',
    'Please enter a name for the new protocol',
    'ERROR: Could not load reference genomes',
);

done_testing;
