=head1 NAME

t/unit/mason/text/solgs_tools_1.t - solgs/tools templates, part 1 of 2: the text is shown in the user's language

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
    '/solgs/tools/analysis_select.mas',
    'Pearson Phenotype Correlation',
    'Select an analysis',
);

page_texts_ok(
    '/solgs/tools/anova/analysis.mas',
    'Clear cache',
    'Run ANOVA',
);

page_texts_ok(
    '/solgs/tools/cluster/analysis.mas',
    'Run Cluster',
);

page_texts_ok(
    '/solgs/tools/cluster/cluster_options.mas',
    'selection %?',
    'Run',
);

page_texts_ok(
    '/solgs/tools/correlation/analysis.mas',
    'Run correlation',
);

page_texts_ok(
    '/solgs/tools/correlation/genetic_correlation.mas',
    'Genetic correlation analysis',
    'Run correlation',
);

page_texts_ok(
    '/solgs/tools/dataset_trials_analysis.mas',
    'Run Analysis',
);

page_texts_ok(
    '/solgs/tools/datatable_display.mas',
    'Retrieving lists and datasets...please wait...it may take minutes.',
    'Private datasets',
    'Public datasets',
    'Private lists',
    'Public lists',
);

page_texts_ok(
    '/solgs/tools/genetic_gain/genetic_gain.mas',
    'Expected genetic gain analysis',
);

page_texts_ok(
    '/solgs/tools/genetic_gain/multi_traits_genetic_gain.mas',
    'Check Genetic Gain',
);

page_texts_ok(
    '/solgs/tools/genetic_gain/single_trait_genetic_gain.mas',
    'Check Genetic Gain',
);

component_compiles_ok('/solgs/tools/kinship/analysis.mas');

done_testing;
