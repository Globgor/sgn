=head1 NAME

t/unit/mason/text/tools_1.t - tools templates, part 1 of 2: the text is shown in the user's language

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
    '/tools/available_seedlots.mas',
    'Select/Deselect All',
    'Breeding Program',
    'Seedlot Location',
    'Seedlot Name',
    'Accessions',
    'Weight(g)',
);

component_compiles_ok('/tools/fieldmap.mas');

page_texts_ok(
    '/tools/trait_designer.mas',
    'The ontology that the new term will belong to. This is separate from the parent term(s) that the new term is chained to.',
    'Make it descriptive. Be sure to describe category meanings if using categorical data.',
    'Alternate names for the new term. Synonyms must not already exist in the database.',
    'Pipes (|)  will be removed from name.',
    'Optional. Pipes (|) will be removed.',
    'Optional. No special characters.',
);

done_testing;
