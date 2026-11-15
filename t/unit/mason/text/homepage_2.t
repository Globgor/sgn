=head1 NAME

t/unit/mason/text/homepage_2.t - homepage templates, part 2 of 2: the text is shown in the user's language

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
    '/homepage/news.mas',
    'See all news...',
);

page_texts_ok(
    '/homepage/oldevents.mas',
    'Past and Present Events',
);

page_texts_ok(
    '/homepage/oldhighlights.mas',
    'All past SGN news items',
);

page_texts_ok(
    '/homepage/oldloci.mas',
    'All Loci of the Week',
);

component_compiles_ok('/homepage/oldpublications.mas');

page_texts_ok(
    '/homepage/phenotypes.mas',
    'Browse Solanaceae phenotypes',
    'Phenotypes',
);

page_texts_ok(
    '/homepage/popular_species.mas',
    'Search other species...',
);

page_texts_ok(
    '/homepage/publication_of_the_week.mas',
    'See all publications...',
    'Featured Publication',
);

page_texts_ok(
    '/homepage/sgn_events.mas',
    'SGN Presentations',
);

page_texts_ok(
    '/homepage/tomato_genome_info.mas',
    'Tomato genome information temporarily unavailable',
);

page_texts_ok(
    '/homepage/tomato_genome_publication.mas',
    'Tomato Genome Published',
);

page_texts_ok(
    '/homepage/tomato_genome_publication_small.mas',
    'Tomato Genome Published',
);

done_testing;
