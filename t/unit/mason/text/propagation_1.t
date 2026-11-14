=head1 NAME

t/unit/mason/text/propagation_1.t - propagation templates, part 1 of 2: the text is shown in the user's language

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
    '/propagation/add_propagation_group_id_dialog.mas',
    'The propagation group identifier was saved successfully.',
    'optional (source name must be in the database)',
    'Please select a type (optional)',
    'Must be unique in the database',
    'Propagation Group Identifier:',
    'Add New Propagation Group ID',
);

page_texts_ok(
    '/propagation/add_propagation_id_dialog.mas',
    'The propagation identifier was saved successfully.',
    'Must not exist in the database.',
    'Must exist in the database',
    'Propagation Identifier:',
    'Add New Propagation ID',
    'Rootstock Name:',
);

page_texts_ok(
    '/propagation/add_propagation_project.mas',
    'Each project page may be used to group propagation processes having the same propagation type, objective or done in the same year.',
    'Propagation Project page acts as a centralized page for different propagation processes .',
    'Please click on \'Refresh\' button to view your newly created project on the manage page.',
    'Finished! Your propagation project is now in the database',
    'Enter basic information about the propagation project',
    'What are Propagation Projects?',
);

page_texts_ok(
    '/propagation/edit_propagation_project_details_dialog.mas',
    'Error Saving Crossing Experiment Details',
    'Edit Propagation Project Details',
    'Propagation Project Name:',
    'Indicates pending change',
    'Breeding Program:',
    'Close & Reload',
);

page_texts_ok(
    '/propagation/inactive_propagation_id_section.mas',
    'Inactive Propagation IDs',
);

component_compiles_ok('/propagation/manage_propagation.mas');

page_texts_ok(
    '/propagation/propagation_group.mas',
    'Add New Propagation ID',
    'Material Type',
    'Sub-Location',
    'Description',
    'Source Name',
    'Source Type',
);

page_texts_ok(
    '/propagation/propagation_groups_in_project.mas',
    'Number of Propagation IDs',
    'Propagation Group ID',
    'Material Type',
    'Sub-Location',
    'Description',
    'Source Name',
);

page_texts_ok(
    '/propagation/propagation_id_section.mas',
    'The propagation status has been updated.',
    'Active Propagation IDs',
    'Update Status',
    'Success',
    'Update',
    'Close',
);

page_texts_ok(
    '/propagation/propagation_project.mas',
    'View information about propagation details in this project.',
    'View and edit basic information about the project.',
);

page_texts_ok(
    '/propagation/propagation_project_details.mas',
    'Upload New Propagation Group IDs',
    'Add New Propagation Group ID',
    'Upload Propagation ID Status',
    'Upload New Propagation IDs',
    'Propagation Project Name',
    'Breeding Program',
);

page_texts_ok(
    '/propagation/propagation_project_tree.mas',
    'Breeding Programs -- Folders -- Propagation Projects',
    'Select multiple folders by holding \'Ctrl\'.',
    'Move propagation project(s) to folder',
    'First Select Folder(s) to Edit',
    'Create new folder',
    'Edit Folder(s)',
);

done_testing;
