=head1 NAME

t/unit/mason/text/scripts_tools.t - scripts in the tools templates: the script text is shown in the user's language

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
    '/tools/available_seedlots.mas',
    'Something went wrong in the available-seedlots AJAX call. See console for more information.',
);

component_compiles_ok('/tools/boxplotter.mas');

page_script_texts_ok(
    '/tools/document_browser.mas',
    'Please select a file',
);

component_compiles_ok('/tools/environment_stratification.mas');

component_compiles_ok('/tools/fieldmap.mas');

component_compiles_ok('/tools/image_analysis.mas');

page_script_texts_ok(
    '/tools/trait_designer.mas',
    'Please select a CV before rebuilding its cvterm paths.',
    'Assign an ordinal value to the new category.',
    'An error occurred, check console.',
    'Please select an ontology.',
    'No special characters.',
    'Default category:',
);

page_script_texts_ok(
    '/tools/treatment_designer.mas',
    'Please select a CV before rebuilding its cvterm paths.',
    'Assign an ordinal value to the new category.',
    'An error occurred, check console.',
    'No special characters.',
    'New treatment saved.',
    'Default category:',
);

done_testing;
