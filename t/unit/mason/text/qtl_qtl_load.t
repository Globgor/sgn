=head1 NAME

t/unit/mason/text/qtl_qtl_load.t - qtl/qtl_load templates: the text is shown in the user's language

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
    '/qtl/qtl_load/check_organism.mas',
    'Check parental accession(s)',
);

page_texts_ok(
    '/qtl/qtl_load/compare_file_names.mas',
    'Data files',
);

page_texts_ok(
    '/qtl/qtl_load/missing_data.mas',
    'Missing Data:',
);

page_texts_ok(
    '/qtl/qtl_load/population_exists.mas',
    'QTL population',
);

page_texts_ok(
    '/qtl/qtl_load/trait_columns.mas',
    'Traits file',
);

done_testing;
