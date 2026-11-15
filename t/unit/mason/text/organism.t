=head1 NAME

t/unit/mason/text/organism.t - organism templates: the text is shown in the user's language

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
    '/organism/accessions.mas',
    'External Links',
);

page_texts_ok(
    '/organism/project_metadata.mas',
    'SOL-100 Genome sequencing project data',
);

page_texts_ok(
    '/organism/taxonomy.mas',
    'Taxonomic information',
);

page_texts_ok(
    '/organism/tree.mas',
    'temporarily unavailable',
);

page_texts_ok(
    '/organism/view_organism.mas',
    'Basic information',
    'Images',
);

done_testing;
