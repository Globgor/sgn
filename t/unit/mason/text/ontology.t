=head1 NAME

t/unit/mason/text/ontology.t - ontology templates: the text is shown in the user's language

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
    '/ontology/associate_ontology.mas',
    'Show complete details',
    '[loading...]',
);

page_texts_ok(
    '/ontology/browser.mas',
    'ontology browser input form',
    'show results',
    'loading...',
);

component_compiles_ok('/ontology/compose_trait.mas');

component_compiles_ok('/ontology/compose_treatment.mas');

page_texts_ok(
    '/ontology/parentage.mas',
    'show results',
);

page_texts_ok(
    '/ontology/standalone.mas',
    'Search and browse ontologies',
    'Ontology browser',
);

done_testing;
