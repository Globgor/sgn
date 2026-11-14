=head1 NAME

t/unit/mason/text/scripts_analyses.t - scripts in the analyses templates: the script text is shown in the user's language

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
    '/analyses/analysis_calculate_statistics.mas',
    'Saving spatial BLUPs currently only implemented for a single trial, so only select one field trial in your analysis',
    'Please give an analysis template description',
    'Please select one observation variable!',
    'Please give an analysis template name',
    'Please give an analysis template year',
    'Please select a field trial first!',
);

page_script_texts_ok(
    '/analyses/model_deletion.mas',
    'Error deleting analysis model!',
    'DELETED MODEL!',
);

page_script_texts_ok(
    '/analyses/model_details.mas',
    'Error getting analysis details!',
);

page_script_texts_ok(
    '/analyses/store_new_analysis_values_and_model.mas',
    'If Model ID is given, then you should not give a new model description!',
    'If Model ID is given, then you should not give a new model name!',
    'Please give a model properties JSON object',
    'Please give analysis result summary info',
    'Please give a model application version',
    'Please give a statistical ontology term',
);

page_script_texts_ok(
    '/analyses/upload_analysis_dialogs.mas',
    'If you give a new model aux file 1, please give a new model aux file 1 type also',
    'If you give a new model aux file 2, please give a new model aux file 2 type also',
    'If you give a new model aux file 3, please give a new model aux file 3 type also',
    'If you give a new model file, please give a new model file type also',
    'Please give a new model properties. At least one key:value!',
    'Please give an analysis name and description',
);

done_testing;
