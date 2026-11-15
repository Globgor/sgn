=head1 NAME

t/unit/mason/text/sentences_root.t - top-level pages templates: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

page_sentences_ok(
    '/bulk_download.mas',
    'Download as {link}Fasta{end_link}',
);

page_sentences_ok(
    '/index.mas',
    'There are a number of instances running for diverse crops, including Cassava ({cassava}), sweet potato ({sweet_potato}), banana ({banana}), rice ({rice}), tomato and other Solanaceae ({solanaceae}) and many others.',
    'You can watch the Breedbase workshops on {link}Youtube{end_link}, covering topics such as ontologies, trial design, data collection using fieldbook, data analysis, and genomic selection.',
    'Breedbase is a web application that only requires a browser. To get your Breedbase instance, contact the {link}Breedbase development team{end_link}.',
);

page_sentences_ok(
    '/index_logged_in_user.mas',
    'Your status is currently "{role}".',
    'Welcome back {name}!',
);

page_sentences_ok(
    '/usage_policy.mas',
    'The data on this database is shared according to the Toronto agreement (see below).',
    'Datasets that are currently released but have not yet been published include:',
);

done_testing;
