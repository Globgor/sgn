=head1 NAME

t/unit/mason/text/scripts_transformation_2.t - scripts in the transformation templates, part 2 of 2: the script text is shown in the user's language

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
    '/transformation/transformants_section.mas',
    'Obsolete Accession',
    'Accession',
);

page_script_texts_ok(
    '/transformation/transformation_project_deletion.mas',
    'Are you sure you want to delete this transformation project? The deletion cannot be undone.',
    'An error occurred during deletion',
    'Deletion was successful',
    'Number of Transformants',
    'Transformation ID',
    'Delete',
);

page_script_texts_ok(
    '/transformation/transformation_project_tree.mas',
    'An error occurred while loading the transformation project data.',
);

component_compiles_ok('/transformation/transgenic_line_details_section.mas');

page_script_texts_ok(
    '/transformation/upload_qPCR_data_dialog.mas',
    'Please select a normalization method',
    'Please select an endogenous control',
    'Please select a tissue type',
    'Please provide assay date',
    'Please select a file',
);

page_script_texts_ok(
    '/transformation/upload_transformation_ids_dialog.mas',
    'Please select a file',
);

page_script_texts_ok(
    '/transformation/upload_transgenic_historical_data_dialog.mas',
    'Please set a default plant material for this project before uploading your data.',
    'Please select a file',
);

page_script_texts_ok(
    '/transformation/upload_transgenic_lines_dialog.mas',
    'Please select a file',
);

done_testing;
