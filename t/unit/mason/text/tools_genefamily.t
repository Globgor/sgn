=head1 NAME

t/unit/mason/text/tools_genefamily.t - tools/genefamily templates: the text is shown in the user's language

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
    '/tools/genefamily/details.mas',
    'Gene family members',
    'Sequences in fasta:',
    'Alignment',
    'Align',
    'Tree',
    'View',
);

page_texts_ok(
    '/tools/genefamily/index.mas',
    'Here you can search in different gene family builds, both for a specific family, and for a gene family member. You can then view the fasta, alignments, and trees, if available.',
    'Genefamily Annotation',
    'Search gene families',
);

page_texts_ok(
    '/tools/genefamily/search.mas',
    'Browse Genefamilies',
    'Gene family search',
    'Genefamily ID',
    'Member Count',
    'Alignments',
    'Sequences',
);

page_texts_ok(
    '/tools/genefamily/sequence.mas',
    'Sequence Details',
    'Viewing Build',
    'Description',
    'Identifier',
    'Sequence',
    'Family',
);

page_texts_ok(
    '/tools/genefamily/submit.mas',
    'Submit a Genefamily',
    'submit genefamily',
    'Description',
    'Members:',
    'Name:',
);

done_testing;
