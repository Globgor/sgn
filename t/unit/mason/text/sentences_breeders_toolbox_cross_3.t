=head1 NAME

t/unit/mason/text/sentences_breeders_toolbox_cross_3.t - breeders_toolbox/cross templates, part 3 of 3: sentences appear in the user's language

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
    '/breeders_toolbox/cross/upload_crosses_confirm_spreadsheet.mas',
    'Return to breeders tools',
);

page_sentences_ok(
    '/breeders_toolbox/cross/upload_crosses_dialogs.mas',
    '{label} A group of plants (usually a related family) that are pollinated by another group of plants or open pollinated (between a female population and a male population or unknown male parent).',
    '{bold}Optional columns (additional parent info):{end_bold} You can add additional parent info after {column} column by using one or more of these column headers.',
    '{label} A group of plants (usually a related family) pollinated by an individual plant (between a female population and a male accession).',
    '{label} An individual plant pollinated by a group of plants or open pollinated (pollen may be from a group with known or unknown members).',
    '{label} Mating between individuals that have at least one parent in common. Generally between two individuals within the same plot.',
    '{label} Female parent names must exist as {unique_names} in the database, can be accession, plot, plant or population stock type.',
);

page_sentences_ok(
    '/breeders_toolbox/cross/upload_update_crosses.mas',
    '{bold}At least one of the following columns:{end_bold} You can upload different types of parent info by selecting corresponding column headers. All of parent info of the same cross unique id must be in a single row. Each field can have several values by using comma-delimited list (e.g. {example})',
    '{bold}At least one of the following columns:{end_bold} You can upload different types of cross info by selecting corresponding column headers. All of cross info of the same cross unique id must be in a single row. Dates must be in the {date_format} format.',
    '{label} Must exist in the database, must not have duplicate cross unique id in the same upload file.',
);

done_testing;
