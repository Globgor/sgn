=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_genotyping_trials.t - scripts in the breeders_toolbox/genotyping_trials templates: the script text is shown in the user's language

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
    '/breeders_toolbox/genotyping_trials/delete_genotyping_plate.mas',
    'Are you sure you want to delete all genotyping data derived from this genotyping plate? This action cannot be undone.',
    'Are you sure you want to delete this genotyping protocol? This action cannot be undone.',
    'The genotyping protocol was deleted successfully.',
    'An error occurred during deletion',
);

component_compiles_ok('/breeders_toolbox/genotyping_trials/detail.mas');

component_compiles_ok('/breeders_toolbox/genotyping_trials/download_genotyping_trial_layouts_dialogs.mas');

page_script_texts_ok(
    '/breeders_toolbox/genotyping_trials/format/as_table.mas',
    'Error retrieving plate layout.',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_trials/genotyping_trial_tree.mas',
    'An error occurred while loading the trial data.',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_trials/layout.mas',
    'Error retrieving plate layout.',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_trials/layout_as_list.mas',
    'Error retrieving plate layout.',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_trials/upload_genotyping_data_dialogs.mas',
    'If you selected a protocol, do not try to make a new one at the same time!',
    'If you selected a project, do not try to make a new one at the same time!',
    'Select a genotyping protocol or create a new one!',
    'Select a genotyping project or create a new one!',
    'Please go back and select a Genotyping Protocol',
    'Please select an Intertek SNP Information File.',
);

done_testing;
