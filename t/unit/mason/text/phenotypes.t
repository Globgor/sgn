=head1 NAME

t/unit/mason/text/phenotypes.t - phenotypes templates: the text is shown in the user's language

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
    '/phenotypes/submission_guide.mas',
    'Provide a name for the population in this experiment. Your population may or may not have a known structure, and its name can be arbitrary. If you are adding accessions to an existing population, start typing its name and select the appropriate one from the autocomplete list.',
    'Second column should be names of the plant accessions - this will be loaded literally into the database. If the accession already exists in SGN, please make sure to use exactly the same name (case insensitive, but spaces, hyphens, and other special characters are important).',
    'If you have multiple repeats, the loading software will automatically increment the repeat number each time it sees a row of data for a plot or accession. If you provide repeat number (or fruit/plant/leaf number etc.) it will be used instead.',
    'Save your data file in tab-delimited format. Make sure there is only one column header row. Both row and column headers should be unique. You can save your spreadsheet as text, and choose tab-delimited format (tab-delimited text in MS Excel).',
    'provide a name for your project which reflects the scope of your phenotyping experiments. For adding experiments to an existing projects, start typing and select the appropriate project name for the autocomplete list.',
    'If you have more than one row of data for each accession (e.g. several repeats or plots of the same accession) then row headers could be just incremented row numbers.',
);

done_testing;
