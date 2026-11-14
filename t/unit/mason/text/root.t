=head1 NAME

t/unit/mason/text/root.t - top-level pages templates: the text is shown in the user's language

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
    '/bulk_download.mas',
    'Your query was successful.',
    'Feature Download Summary',
);

page_texts_ok(
    '/captcha.mas',
    'Javascript is required for bot detection...',
    'Verifying your request...',
    'Verification Failed',
);

page_texts_ok(
    '/cookie_popup.mas',
    'This site uses cookies to provide logins and other features. Please accept the use of cookies by clicking Accept.',
    'Accept',
);

component_compiles_ok('/system_message.mas');

page_texts_ok(
    '/test.mas',
    'This is a test',
);

page_texts_ok(
    '/usage_policy.mas',
    'Informing data users about the data being generated, data standards and quality, planned analyses, timelines, and relevant contact information, ideally through publication of a citable marker paper near the start of the project or by provision of a citable URL at the project or funding-agency website',
    'Providing relevant metadata (e.g., questionnaires, phenotypes, environmental conditions, and laboratory methods) that will assist other researchers in reproducing and/or independently analysing the data, while protecting interests of individuals enrolled in studies focusing on humans',
    'Scientific journal editors should engage the research community about issues related to prepublication data release and provide guidance to authors and reviewers on the third-party use of prepublication data in manuscripts',
    'Creating databases designed to archive all data (including underlying raw data) in an easily retrievable form and facilitate usage of both pre-processed and processed data',
    'Helping to develop appropriate consent, security, access and governance mechanisms that protect research participants while encouraging prepublication data release',
    'Being aware that released prepublication data may be associated with quality issues that will be later rectified by the data producers',
);

done_testing;
