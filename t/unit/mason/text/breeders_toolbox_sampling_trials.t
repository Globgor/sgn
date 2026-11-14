=head1 NAME

t/unit/mason/text/breeders_toolbox_sampling_trials.t - breeders_toolbox/sampling_trials templates: the text is shown in the user's language

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
    '/breeders_toolbox/sampling_trials/create_sampling_trials_dialogs.mas',
    'The "contents" of each sample can be either a tissue sample, plant name, plot name, or accession name. This "source" name must be in the database already. This is useful if you provide a field trial entity (such as a plot or plant or tissue sample name), so that phenotypes and genotypes can be directly compared.',
    'If you provided us with information about where the sample originated (e.g. it came from a plot name or plant name or tissue sample name in a field trial), we will automatically create linkage between the field trial(s) and this sampling trial.',
    'Is your sampling trial linked with field trials in the database? This information can also be added from the sampling trial detail page once the trial is saved in the database.',
    'Note: From the most desirable to least desirable source observation unit you can choose: tissue samples, plants, plots, or accessions',
    'Select a list for the source material of each tissue sample. Then indicate how many replicates are required.',
    'Sampling trials can represent 96 or 384 well plates, or more generically any sampling scheme.',
);

page_texts_ok(
    '/breeders_toolbox/sampling_trials/detail.mas',
    'Breeding Program',
    'Download Layout',
);

done_testing;
