=head1 NAME

t/unit/mason/text/fieldbook.t - fieldbook templates: the text is shown in the user's language

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
    '/fieldbook/create_trait_file_dialog.mas',
    'Create a Trait File for the Android Fieldbook App',
    'The trait file was created successfully.',
    'Or select traits directly:',
    'Select a list of traits:',
    'Include Notes Trait',
    'Trait File Created',
);

page_texts_ok(
    '/fieldbook/home.mas',
    'Once you have created and downloaded your Field Layout and Trait files, move them onto your mobile device into the Field Book directories (generally /fieldbook/import_field/ for your Field Layout Files and /fieldbook/traits/ for your trait files.)',
    'By using Field Book with the Field Layout and Trait Files created here, you can be sure that your traits are properly defined and your experimental units, whether they are plots or plants or tissue samples, are also properly defined.',
    'To use Field Book you need a Field Layout File and a Trait File; both can be created on this page.',
    'Scan the QRCode with Field Book to configure the app for this database for BrAPI access',
    'This should then direct you to login to the database with your username and password',
    'To connect Field Book to this database via BrAPI, from within the Field Book app:',
);

page_texts_ok(
    '/fieldbook/upload_phenotype_fieldbook.mas',
    'When exporting a Phenotype File from Fieldbook, the file should already be in this format. Please check to make sure your file was exported correctly',
    'Upload Exported Fieldbook Phenotype File in Database Format for Plots or Plants',
    'Fieldbook files can be uploaded in .xlsx or .csv format',
    'Optional: Images ZipFile (.zip):',
    'File format information',
    'First Verify Your File',
);

done_testing;
