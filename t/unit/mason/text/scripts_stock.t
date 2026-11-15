=head1 NAME

t/unit/mason/text/scripts_stock.t - scripts in the stock templates: the script text is shown in the user's language

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
    '/stock/accession_related_transformation_info.mas',
    'Accession',
);

page_script_texts_ok(
    '/stock/add_phenotype.mas',
    'Must choose a trait name!',
);

component_compiles_ok('/stock/add_vector.mas');

page_script_texts_ok(
    '/stock/audit.mas',
    'Transaction Code',
    'Logged in User',
    'Primary Key',
    'Operation',
    'Timestamp',
    'Username',
);

page_script_texts_ok(
    '/stock/obsolete_accessions_using_list_dialog.mas',
    'Error obsoleting accessions.',
    'Please select a list',
);

page_script_texts_ok(
    '/stock/population_members.mas',
    'Remove From Population',
    'Description',
    'Member Name',
    'Member Type',
    'Synonyms',
);

page_script_texts_ok(
    '/stock/population_seedlots.mas',
    'Current Weight (g) ',
    'Current Count',
    'Seedlot Name',
    'Member Name',
    'Member Type',
    'Box Name',
);

page_script_texts_ok(
    '/stock/stockprops.mas',
    'An error occurred. Please try again later.',
    'Please fill in the field.',
    'an error occurred',
);

page_script_texts_ok(
    '/stock/upload_additional_accessions_file.mas',
    'Are you sure you want to obsolete this file? This operation cannot be undone.',
    'Error retrieving additional uploaded files.',
    'The file has been obsoleted.',
    'File uploaded successfully',
    'Please select a file',
    'An error occurred!',
);

page_script_texts_ok(
    '/stock/vector_related_accessions.mas',
    'Obsolete Accession',
    'Transformation ID',
    'Plant Material',
    'Accession',
);

done_testing;
