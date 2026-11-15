=head1 NAME

t/unit/mason/text/breeders_toolbox_3.t - breeders_toolbox templates, part 3 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/derived_accession_usage_info_dialog.mas',
    'In some cases, you may want to add new accession names that have special relationships to other stock types in the database. For example, after preliminary phenotypic screening of progenies derived from different crosses in a trial, you may want to add new accession names for some plants in that trial.',
    'Relationship between each derived accession and its source is displayed on the accession detail page and its source detail page (accession/plant/tissue sample)',
    'The derived accession (stored as accession stock type) can be linked to another accession, or plant or tissue sample in the database.',
    'Linkage between derived accession, direct source and original source:',
    'How to add derived accessions:',
    'What are derived accessions:',
);

done_testing;
