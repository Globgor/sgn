=head1 NAME

t/unit/mason/text/itag.t - itag templates: the text is shown in the user's language

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
    '/itag/list_release_files.mas',
    'To download ITAG pre-publication annotation data, please provide your contact information.',
    'Access agreement and contact information',
    'Data access agreement',
    'Organization',
    'Email',
    'Name',
);

page_texts_ok(
    '/itag/list_releases.mas',
    'ITAG Releases Available for Bulk Download',
    'temporarily unavailable',
);

page_texts_ok(
    '/itag/not_enabled.mas',
    'ITAG feature not enabled.',
);

done_testing;
