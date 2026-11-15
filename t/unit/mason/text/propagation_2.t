=head1 NAME

t/unit/mason/text/propagation_2.t - propagation templates, part 2 of 2: the text is shown in the user's language

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
    '/propagation/upload_propagation_group_ids_dialog.mas',
    'Upload Template Information For Propagation Group Identifiers',
    'The propagation group ids were saved successfully.',
    'Upload Propagation Group Identifiers Error',
    'Upload Propagation Group Identifiers',
    'File format information',
    'Spreadsheet Format',
);

page_texts_ok(
    '/propagation/upload_propagation_id_status_dialog.mas',
    'The propagation identifier statuses were updated successfully.',
    'Upload Template Information For Propagation Identifier Status',
    'Upload Propagation Identifier Status Error',
    'Upload Propagation Identifier Status',
    'File format information',
    'Spreadsheet Format',
);

page_texts_ok(
    '/propagation/upload_propagation_ids_dialog.mas',
    'Upload Template Information For Propagation Identifiers',
    'The propagation ids were saved successfully.',
    'Upload Propagation Identifiers Error',
    'File format information',
    'Upload Propagation IDs',
    'Spreadsheet Format',
);

done_testing;
