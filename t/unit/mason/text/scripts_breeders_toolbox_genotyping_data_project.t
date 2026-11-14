=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_genotyping_data_project.t - scripts in the breeders_toolbox/genotyping_data_project templates: the script text is shown in the user's language

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
    '/breeders_toolbox/genotyping_data_project/add_existing_genotyping_plate_dialog.mas',
    'An error occurred adding genotyping plate(s) to this project',
    'Please select at least one genotyping plate',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_data_project/create_genotyping_project_dialog.mas',
    'An error occurred saving genotyping project.',
    'Genotyping project name is required',
    'Breeding program is required',
    'Description is required',
    'Data type is required',
    'Year is required',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotype_archived_vcf.mas',
    'An error occurred',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotyping_project_deletion.mas',
    'Are you sure you want to delete all genotyping plates in this genotyping project? The deletion cannot be undone.',
    'Are you sure you want to delete this genotyping protocol and all data? The deletion cannot be undone.',
    'Are you sure you want to delete this genotyping project? The deletion cannot be undone.',
    'Are you sure you want to delete this genotyping plate? The deletion cannot be undone.',
    'Are you sure you want to delete this genotyping data? The deletion cannot be undone.',
    'The genotyping plate has been deleted.',
);

page_script_texts_ok(
    '/breeders_toolbox/genotyping_data_project/genotyping_project_tree.mas',
    'An error occurred while loading the genotyping projects.',
);

done_testing;
