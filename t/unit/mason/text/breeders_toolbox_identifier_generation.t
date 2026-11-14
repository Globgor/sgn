=head1 NAME

t/unit/mason/text/breeders_toolbox_identifier_generation.t - breeders_toolbox/identifier_generation templates: the text is shown in the user's language

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
    '/breeders_toolbox/identifier_generation/list_identifier_generation.mas',
    'Identifier Generation History',
    'Download Next Identifiers',
    'Number of Digits',
    'Next Identifier',
    'Current Number',
    'Description',
);

page_texts_ok(
    '/breeders_toolbox/identifier_generation/manage_identifier_generation.mas',
    'It is often necessary to pre-create identifiers. This is used in ACAI and the Banana Agronomy project for pre-printing barcode identifiers that are later assigned to trials in the field. This can also be used for pre-printing barcode identifiers that are later assigned to samples in the lab.',
    'A description of what the identifier is used for',
    'View, add, and download identifiers.',
    'Manage Identifier Generation',
    'Current Identifier Number:',
    'Add New Identifier',
);

done_testing;
