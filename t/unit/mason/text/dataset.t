=head1 NAME

t/unit/mason/text/dataset.t - dataset templates: the text is shown in the user's language

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
    '/dataset/authorize.mas',
    'Connecting account...',
);

page_texts_ok(
    '/dataset/index.mas',
    'Analyses using this dataset',
    'Select Dataset in Wizard',
    'Description',
    'Contents',
    'Update',
    'Owner',
);

page_texts_ok(
    '/dataset/outliers.mas',
    'Rosner\'s test is calculated by the R function rosnerTest{EnvStats} from package EnvStats.',
    'Download Phenotype Table without outliers',
    'Reset outliers for current trait',
    'Add selection to outliers',
    'Make Rosner outlier test',
    'Reset all outliers',
);

page_texts_ok(
    '/dataset/publish.mas',
    'Dataset publishing allows the owner of a dataset to take a snapshot of the data contained within the dataset and publish it to an external service (such as FigShare), where it can be made publicly available and have a DOI assigned to it.',
    'Select the external service to upload this dataset to:',
    'Make sure everything is correct before publishing!',
    'Only the dataset owner can generate archive files',
    'You will automatically be added as an Author',
    'Information about Publishing Datasets',
);

page_texts_ok(
    '/dataset/tool_compatibility.mas',
    'Predicted tool compatibility based on dataset definition. The table details the traits and types of analyses that can be performed. If database elements are updated, such as phenotypes added to field trials or accessions, you may wish to recalculate tool compatibility for more accurate results. Warning symbols indicate compatibility, but with low sample sizes.',
    'Calculate Tool Compatibility',
);

done_testing;
