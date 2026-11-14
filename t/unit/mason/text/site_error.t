=head1 NAME

t/unit/mason/text/site_error.t - site/error templates: the text is shown in the user's language

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
    '/site/error/404.mas',
    '404 - not found',
);

page_texts_ok(
    '/site/error/dhandler',
    'Server Error',
);

component_compiles_ok('/site/error/exception.mas');

page_texts_ok(
    '/site/error/permission_denied.mas',
    'You do not have sufficient permissions to view this page. This could be due to your user status or server configuration. Contact a server administrator for more details.',
    'Access denied',
);

done_testing;
