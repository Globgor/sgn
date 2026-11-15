=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_sampling_trials.t - scripts in the breeders_toolbox/sampling_trials templates: the script text is shown in the user's language

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
    '/breeders_toolbox/sampling_trials/create_sampling_trials_dialogs.mas',
    'A sampling trial name is required and it should be unique in the database. Please try again.',
    'The list contains elements that are not accessions or plots or plants or tissue_samples.',
    'An error occurred trying the create the sampling trial layout.',
    'A sampling trial description is required. Please try again.',
    'A sampling trial type is required. Please try again.',
    'A breeding program is required. Please try again.',
);

done_testing;
