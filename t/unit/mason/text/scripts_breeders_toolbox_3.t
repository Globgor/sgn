=head1 NAME

t/unit/mason/text/scripts_breeders_toolbox_3.t - scripts in the breeders_toolbox templates, part 3 of 4: the script text is shown in the user's language

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
    '/breeders_toolbox/manage_trial_phenotyping.mas',
    'An error occurred retrieving trial information',
    'An error occurred retrieving trait value',
    'An error occurred saving trait value',
);

component_compiles_ok('/breeders_toolbox/trial.mas');

page_script_texts_ok(
    '/breeders_toolbox/trialtree.mas',
    'No leaf nodes selected for download.',
    'An error occurred',
);

page_script_texts_ok(
    '/breeders_toolbox/trialtreefolders.mas',
    'An error occurred while loading the trial data.',
);

done_testing;
