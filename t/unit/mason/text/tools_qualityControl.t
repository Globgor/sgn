=head1 NAME

t/unit/mason/text/tools_qualityControl.t - tools/qualityControl templates: the text is shown in the user's language

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
    '/tools/qualityControl/dataset_quality_control.mas',
    'This is the validation process. Trials cleaned of outliers can be used in downstream analysis.',
    'This is an option to set selected plots as outliers for other traits as well.',
    'Selecting this box, it will set fixed minimum and maximum for all locations.',
    'Set Plot as Outlier for Other Traits',
    'Choose Dataset and continue',
    'Choose the dataset for QC',
);

page_texts_ok(
    '/tools/qualityControl/qualityControl.mas',
    'Quality Control Tool (st4gi)',
    'Run QC',
);

page_texts_ok(
    '/tools/qualityControl/validated_trials.mas',
    'This table presents all trials that have been thoroughly filtered and validated through the Quality Control Tool.',
    'Calculate Statistics',
    'Project Location',
    'Validated Trials',
    'Items per page:',
    'Show bottom 25%',
);

done_testing;
