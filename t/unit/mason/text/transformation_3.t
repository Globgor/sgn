=head1 NAME

t/unit/mason/text/transformation_3.t - transformation templates, part 3 of 3: the text is shown in the user's language

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
    '/transformation/transformation_update_status_section.mas',
    'You need to be logged in or you do not have sufficient privileges to update status of this tracking identifier.',
);

page_texts_ok(
    '/transformation/transformations_in_project.mas',
    'No of Transformants (Accessions)',
    'Transformation ID',
    'Vector Construct',
    'Plant Material',
    'Control',
    'Notes',
);

component_compiles_ok('/transformation/transgenic_line_details_section.mas');

page_texts_ok(
    '/transformation/upload_qPCR_data_dialog.mas',
    'Upload Template Information For qPCR Data (Cq values)',
    'The first row (header) should contain the following:',
    'The qPCR data were saved successfully.',
    'Upload qPCR Data (Cq values)',
    'Upload File (Cq values):',
    'File format information',
);

page_texts_ok(
    '/transformation/upload_transformation_ids_dialog.mas',
    'Upload Template Information For Transformation Identifiers',
    'The transformation identifiers were saved successfully.',
    'The first row (header) should contain the following:',
    'Upload Transformation Identifiers Error',
    'Upload Transformation IDs',
    'File format information',
);

page_texts_ok(
    '/transformation/upload_transgenic_historical_data_dialog.mas',
    'Upload Template Information For Transgenic Historical Data',
    'The first row (header) should contain the following:',
    'The transgenic data were saved successfully.',
    'Upload Transgenic Data Error',
    'File format information',
    'Upload Transgenic Data',
);

page_texts_ok(
    '/transformation/upload_transgenic_lines_dialog.mas',
    'The first row (header) should contain the following:',
    'Upload Template Information For Transgenic Lines',
    'The transgenic lines were saved successfully.',
    'Upload Transgenic Lines Error',
    'File format information',
    'Upload Transgenic Lines',
);

done_testing;
