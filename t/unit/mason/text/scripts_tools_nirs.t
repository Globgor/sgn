=head1 NAME

t/unit/mason/text/scripts_tools_nirs.t - scripts in the tools/nirs templates: the script text is shown in the user's language

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
    '/tools/nirs/nirs_analysis_plot_spectra_dialogs.mas',
    'Error plotting spectra from NIRS!',
    'Please select one dataset!',
);

page_script_texts_ok(
    '/tools/nirs/nirs_analysis_predict_dialogs.mas',
    'Error predicting phenotypes from NIRS!',
    'Please select one dataset!',
    'Please select one model!',
);

page_script_texts_ok(
    '/tools/nirs/nirs_analysis_train_dialogs.mas',
    'Please select one dataset!',
    'Error training NIRS!',
);

done_testing;
