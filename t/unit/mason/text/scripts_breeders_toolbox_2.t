=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_2.t - scripts in the breeders_toolbox templates, part 2 of 4: the script text is shown in the user's language

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
    '/breeders_toolbox/manage_odk_data_collection.mas',
    'Error retrieving available ODK crossing forms',
    'Error scheduling import of ODK crossing data.',
    'Error retrieving available ODK cross summary',
    'Error retrieving ODK phenotyping data.',
    'Error retrieving saved ODK ONA forms',
    'Error retrieving ODK crossing data.',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_phenotyping.mas',
    'Are you sure you want to delete all phenotype values related to this file from the database and make this file obsolete?',
    'Made phenotype file obsolete and deleted all related phenotype values in the database!',
    'Error deleting file and phenotypes!',
);

page_script_texts_ok(
    '/breeders_toolbox/manage_plot_phenotyping.mas',
    'An error occurred retrieving trait value',
    'An error occurred saving trait value',
);

done_testing;
