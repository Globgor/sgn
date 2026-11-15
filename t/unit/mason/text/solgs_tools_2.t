=head1 NAME

t/unit/mason/text/solgs_tools_2.t - solgs/tools templates, part 2 of 2: the text is shown in the user's language

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
    '/solgs/tools/kinship/kinship_options.mas',
    'Run',
);

component_compiles_ok('/solgs/tools/pca/analysis.mas');

page_texts_ok(
    '/solgs/tools/pca/pca_options.mas',
    'Phenotype',
    'Run PCA',
);

page_texts_ok(
    '/solgs/tools/select_menu.mas',
    'Select a population',
    'View',
);

page_texts_ok(
    '/solgs/tools/selection_index/selection_index.mas',
    'And assign relative weights to traits.',
    'Selection index calculator',
);

page_texts_ok(
    '/solgs/tools/selection_index/top_genotypes.mas',
    'Genotype ranking based on multiple traits performance (selection index)',
);

page_texts_ok(
    '/solgs/tools/trials_select.mas',
    'Select a trial',
);

done_testing;
