=head1 NAME

t/unit/mason/text/analytics_protocols.t - analytics_protocols templates: the text is shown in the user's language

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
    '/analytics_protocols/analytics_protocols_details.mas',
    'Analytics Protocol Name',
    'Result Summary',
    'Description',
    'Properties',
    'Created',
    'Type',
);

page_texts_ok(
    '/analytics_protocols/analytics_protocols_result_files.mas',
    'File Name',
    'File Type',
    'Download',
);

page_texts_ok(
    '/analytics_protocols/detail.mas',
    'View basic information about the analytics protocol.',
    'Result files and figures.',
);

page_texts_ok(
    '/analytics_protocols/index.mas',
    'Your Analytics Protocols',
    'Analytics Protocol Name',
    'Drone Imagery Analytics',
    'Create Date',
    'Description',
    'Type',
);

done_testing;
