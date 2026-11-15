=head1 NAME

t/unit/mason/text/qtl_search.t - qtl/search templates: the text is shown in the user's language

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
    '/qtl/search/help/index.mas',
    '7. The QTL detail page (shown above) presents cross-references from the QTL to other relevant genetic and genomic data and bioinformatic tools. Forexample, to view the genetic location of the QTL of a trait of interest and compare it to other genetic maps using the Comparative Map Viewer, click the linkage group link under the \'QTL markers\' genetic positions and Comparative Map Viewer\' subection.',
    '4. Visually determine which linkage group contains a QTL, see the LOD threshold in the legend. For example, chromosome 7 has a QTL. Click the linkage group of interest and on the new window, follow the link "Go to the QTL page...".',
    '6. Clicking the "Go to the QTL page" generates the QTL detail page where among others the QTL confidence interval, links to the genome positions of the markers, marker detail pages, and SGN\'s Comparative Map Viewer are displayed.',
    '2. Follow the link for the trait of your interest.',
    'QTL genetic location:',
    'QTL Search Page',
);

component_compiles_ok('/qtl/search/results.mas');

done_testing;
