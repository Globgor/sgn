=head1 NAME

t/unit/mason/text/scripts_propagation.t - scripts in the propagation templates: the script text is shown in the user's language

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
    '/propagation/add_propagation_group_id_dialog.mas',
    'An error occurred adding propagation group identifier',
    'Please provide a propagation group identifier',
    'Please provide accession name',
    'Please provide material type',
    'Please provide operator name',
    'Please provide description',
);

page_script_texts_ok(
    '/propagation/add_propagation_id_dialog.mas',
    'An error occurred adding propagation identifier',
    'Please provide a propagation identifier',
);

page_script_texts_ok(
    '/propagation/add_propagation_project.mas',
    'Breeding program is required',
    'Propagation Type is required',
    'Project name is required',
    'Description is required',
    'Location is required',
    'Year is required',
);

page_script_texts_ok(
    '/propagation/inactive_propagation_id_section.mas',
    'Propagation ID',
    'Updated Date',
    'Updated by',
    'Accession',
    'Rootstock',
    'Status',
);

page_script_texts_ok(
    '/propagation/propagation_id_section.mas',
    'An error occurred updating the propagation status',
    'Please provide Inventory Identifier',
    'Propagation ID',
    'Update Status',
    'Updated Date',
    'Updated by',
);

page_script_texts_ok(
    '/propagation/propagation_project_tree.mas',
    'An error occurred while loading the propagation project data.',
);

page_script_texts_ok(
    '/propagation/upload_propagation_group_ids_dialog.mas',
    'Please select a file',
);

page_script_texts_ok(
    '/propagation/upload_propagation_id_status_dialog.mas',
    'Please select a file',
);

page_script_texts_ok(
    '/propagation/upload_propagation_ids_dialog.mas',
    'Please select a file',
);

done_testing;
