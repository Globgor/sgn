=head1 NAME

t/unit/mason/text/breeders_toolbox_program_2.t - breeders_toolbox/program templates, part 2 of 2: the text is shown in the user's language

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
    '/breeders_toolbox/program/program_propagation_identifiers.mas',
    'Propagation Identifier',
    'Propagation Group',
    'Rootstock',
    'Material',
);

page_texts_ok(
    '/breeders_toolbox/program/program_seedlots.mas',
    'Content Type',
    'Seedlot Name',
    'Content',
);

page_texts_ok(
    '/breeders_toolbox/program/program_stock_section.mas',
    'Go To Manage Accessions',
    'Propagation Identifiers',
    'Go To Manage Seedlots',
    'Accessions',
    'Seedlots',
    'Crosses',
);

page_texts_ok(
    '/breeders_toolbox/program/traits.mas',
    'Raw Data Statistics',
    'Raw Data Histogram',
    'Histogram',
    'Select:',
    'Std Dev',
    'Count',
);

page_texts_ok(
    '/breeders_toolbox/program/trials.mas',
    'Description',
    'Trial name',
);

page_texts_ok(
    '/breeders_toolbox/program/upload_profile_dialog.mas',
    'You can find the link for creating the template in the product profile section, simply provide a file name and a list of traits.',
    'Product profiles can be stored in the database for downstream variety selection process for each breeding program.',
    'To facilitate data curation, targeted trait names and trait IDs can be retrieved directly from the database.',
    'Please use the product profile template generated from our database to fill out product profile details.',
    'After filling out the product profile details, please also save the spreadsheet in the .xls format',
    'The profile was saved to the database with no errors! Congrats Click Here',
);

done_testing;
