=head1 NAME

t/unit/mason/text/breeders_toolbox_cross_1.t - breeders_toolbox/cross templates, part 1 of 3: the text is shown in the user's language

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
    '/breeders_toolbox/cross/add_cross_dialogs.mas',
    'For an open pollinated cross, the cross can be defined as between female accession A and male population P1 (populations in the database are defined strictly as groups of accessions). If the male parent is not known, it can be left blank.',
    'Crossing experiments are for grouping crosses together. The grouping is most often done for crosses derived from the same field trial, the same year, or for crosses that have the same breeding objective.',
    'An individual cross can be linked to the specific female plot or plant, as well as to the specific male plot or plant.',
    'A cross can have other data associated to it, such as number of flowers, pollination date, etc.',
    'You can add crossing information as it becomes available (e.g. number of seeds, progeny, etc).',
    'If you would like to add auto-generated progeny names for this cross, you can add it here',
);

page_texts_ok(
    '/breeders_toolbox/cross/add_crossing_trial_dialogs.mas',
    'Crossing experiments group crosses. The grouping can reflect crosses done in the same field trial, crosses in a breeding program in a given year, or crosses that have the same breeding objective. This grouping can be used to encapsulate all the crosses done in a crossing block field trial that you have saved in the database (e.g. in Manage Trials your crossing block will appear as a field trial with plots)',
    'You can add crossing information as it becomes available (e.g. number of seeds, progeny, etc).',
    'You can add or upload crosses into your crossing experiment as they become available.',
    'You may want to proceed to the crossing experiment detail page you just created.',
    'Finished! Your crossing experiment is now in the database',
    'Enter basic information about the crossing experiment',
);

page_texts_ok(
    '/breeders_toolbox/cross/add_family_members_using_list_dialog.mas',
    'The new family members were stored successfully.',
    'Select a List of Crosses to Add:',
    'Add Family Members Using a List',
    'Add Family Members Error',
    'Family Name:',
    'Family Type:',
);

page_texts_ok(
    '/breeders_toolbox/cross/add_progenies_dialogs.mas',
    'same parents (the family includes only crosses with the same female parent and the same male parent)',
    'To Overwrite Parents In the Case That An Accession Already Has Male or Female Parents',
    'Family Name of existing crosses may be uploaded in an Excel file (.xls or .xlsx)',
    'Progenies of existing crosses may be uploaded in an Excel file (.xls or .xlsx)',
    'Include only crosses with the same female parent and the same male parent',
    '(All families in the same file must have the same family type.)',
);

page_texts_ok(
    '/breeders_toolbox/cross/all_cross_entries.mas',
    'Download All Cross Entries',
);

page_texts_ok(
    '/breeders_toolbox/cross/cross_additional_info_crossingtrial.mas',
    'Cross Combination',
    'Cross Unique ID',
);

page_texts_ok(
    '/breeders_toolbox/cross/cross_properties_crossingtrial.mas',
    'Cross Combination',
    'Cross Unique ID',
);

page_texts_ok(
    '/breeders_toolbox/cross/cross_wishlist.mas',
    'Cross wishlist may be uploaded in an Excel file (.xls or .xlsx)',
    'Cross plan will be added to the cross wishlist named:',
    'The first row (header) must contain the following:',
    'Available Cross Wishlist(s) for ODK Use',
    'Cross Wishlists Previously Created',
    'Select Plots for Cross Wishlist',
);

page_texts_ok(
    '/breeders_toolbox/cross/crosses_in_crossingtrial.mas',
    'Add Crosses to a List',
);

page_texts_ok(
    '/breeders_toolbox/cross/crosses_in_family.mas',
    'Add Crosses to a List',
);

page_texts_ok(
    '/breeders_toolbox/cross/crossing_experiment_and_trial_linkage.mas',
    'Field trial(s) for evaluating crosses in this experiment',
    'Field trial source(s) of parents used in crossing',
    'Field Trial',
);

page_texts_ok(
    '/breeders_toolbox/cross/crossing_experiment_deletion.mas',
    'Delete all crosses in this experiment',
    'Delete crossing experiment',
    'Delete crosses',
);

done_testing;
