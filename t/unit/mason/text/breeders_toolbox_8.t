=head1 NAME

t/unit/mason/text/breeders_toolbox_8.t - breeders_toolbox templates, part 8 of 10: the text is shown in the user's language

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

component_compiles_ok('/breeders_toolbox/trial.mas');

component_compiles_ok('/breeders_toolbox/trial_trait.mas');

page_texts_ok(
    '/breeders_toolbox/trialtree.mas',
    'Breeding Programs -- -- Trials',
    'Download Trial',
    '[loading...]',
    'Information',
);

page_texts_ok(
    '/breeders_toolbox/trialtreefolders.mas',
    'Select multiple folders by holding \'Ctrl\'.',
    'Select multiple trials by holding \'Ctrl\'.',
    'Breeding Programs -- Folders -- Trials',
    'First Select Trial(s) to Download',
    'First Select Folder(s) to Edit',
    'Download Trial Phenotypes',
);

done_testing;
