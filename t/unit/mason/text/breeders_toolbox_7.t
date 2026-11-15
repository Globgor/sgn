=head1 NAME

t/unit/mason/text/breeders_toolbox_7.t - breeders_toolbox templates, part 7 of 10: the text is shown in the user's language

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
    '/breeders_toolbox/manage_trial_phenotyping.mas',
    'Enter a List of Trait Names:',
    'Or Paste From a List:',
    'Stored trait value:',
    'Enter trait value:',
    'Or Use Trait List:',
    'Traits assayed',
);

page_texts_ok(
    '/breeders_toolbox/manage_upload.mas',
    'Upload progeny names that already EXIST in database',
    'Upload progeny names that are NOT in database',
    'Upload Cross Info of Existing Crosses',
    'Create An IGD Genotyping Plate',
    'Create Phenotyping Spreadsheet',
    'Go To Manage Genotyping Plates',
);

page_texts_ok(
    '/breeders_toolbox/management_factor.mas',
    'View and edit the public data agreement on this experiment.',
    'View experimental design information for this treatment.',
    'View and edit basic information about the treatment.',
);

done_testing;
