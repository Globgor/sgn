=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_1.t - scripts in the breeders_toolbox templates, part 1 of 4: the script text is shown in the user's language

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
    '/breeders_toolbox/add_data_agreement_dialogs.mas',
    'An error occurred fetching the data agreement data.',
    'Successfully added a data agreement to this trial.',
    'An error occurred storing the data agreement.',
);

page_script_texts_ok(
    '/breeders_toolbox/add_derived_accessions_using_list_dialog.mas',
    'The list did not pass validation. Names in the list must be uniquenames in the database',
    'An error occurred storing new accessions.',
);

page_script_texts_ok(
    '/breeders_toolbox/add_new_trait_dialogs.mas',
    'Please select an existing method or give a new method name, and not both!',
    'Please select an existing scale or give a new scale name, and not both!',
    'Please select an existing trait or give a new trait name, and not both!',
    'Please select an existing method or give a new method name!',
    'Please select an existing scale or give a new scale name!',
    'Please select an existing trait or give a new trait name!',
);

page_script_texts_ok(
    '/breeders_toolbox/add_seedlot_dialogs.mas',
    'Please provide an accession name OR a cross unique id as the content of the seedlot. Not both.',
    'Please provide an accession name or a cross unique id as the content of the seedlot.',
    'If inputting a seed count amount, it must be a numeric value.',
    'Please provide a seed count amount or a weight in grams!',
    'If inputting a weight, it must be a numeric value.',
    'An error occurred creating seed lot',
);

page_script_texts_ok(
    '/breeders_toolbox/add_transactions_using_list.mas',
    'This seedlot list did not pass validation. Names in the list must exist in the database and are not marked as discarded.',
    'An error occurred storing new transactions.',
    'Please select a unit type',
);

page_script_texts_ok(
    '/breeders_toolbox/breeder_search_page_dataset_overlay.mas',
    'Are you sure you want to close the dataset creation help?',
    'Return',
    'Next',
);

page_script_texts_ok(
    '/breeders_toolbox/breeding_programs.mas',
    'Please enter a name and a description.',
    'An error occurred.',
);

page_script_texts_ok(
    '/breeders_toolbox/create_seedlots_from_trial_dialogs.mas',
    'The seedlot name cannot be the same as the plot name, please add a prefix or suffix to make the name unique',
    'ERROR: unknown seedlot stock type!',
    'Enter a trial name to continue',
    'Breeding Program is required',
    'Material type is required',
    'Box Name is required',
);

page_script_texts_ok(
    '/breeders_toolbox/create_tissue_samples_dialogs.mas',
    'An error occurred creating tissue sample entries',
    'An error occurred checking trial for plants.',
    'Successfully created tissue sample entries.',
    'An error occurred saving plant entries',
    'Successfully created plant entries.',
    'Only select one trial!',
);

page_script_texts_ok(
    '/breeders_toolbox/crossing_experiment_tree.mas',
    'An error occurred while loading the trial data.',
);

page_script_texts_ok(
    '/breeders_toolbox/data_agreement.mas',
    'An error occurred fetching the data agreement data.',
);

component_compiles_ok('/breeders_toolbox/db_stats.mas');

done_testing;
