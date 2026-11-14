=head1 NAME

t/unit/mason/text/search_forms.t - search/forms templates: the text is shown in the user's language

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

component_compiles_ok('/search/forms/bac_tab.mas');

component_compiles_ok('/search/forms/directory_tab.mas');

page_texts_ok(
    '/search/forms/expr_experiment.mas',
    'Expression search by experiment',
);

page_texts_ok(
    '/search/forms/expr_platform.mas',
    'Expression search by platform',
);

page_texts_ok(
    '/search/forms/expr_template_tab.mas',
    'Expression search by template',
);

component_compiles_ok('/search/forms/gene_tab.mas');

page_texts_ok(
    '/search/forms/images_tab.mas',
    'Image search',
);

component_compiles_ok('/search/forms/phenotype_tab.mas');

done_testing;
