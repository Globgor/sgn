=head1 NAME

t/unit/mason/text/secretom_detail.t - secretom/detail templates: the text is shown in the user's language

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
    '/secretom/detail/cell_wall.mas',
    'About Plant Cell Walls',
);

page_texts_ok(
    '/secretom/detail/cuticle.mas',
    'A 3-D rendering of the tomato fruit (cv. M8) cuticle.',
    'The Tomato Fruit Cuticular Cell Wall Proteome',
);

page_texts_ok(
    '/secretom/detail/functional_screens.mas',
    'Sucrose plate showing yeast colonies transformed with the YST vector library.',
    'Sucrose plate with no yeast colonies growing (negative control).',
    'Necrosis Inducing Protein (NIP) Secretion Trap Screen',
    'Functional Screens to Identify Secreted Proteins',
    'Yeast Secretion Trap (YST) Screen',
    'Objectives',
);

page_texts_ok(
    '/secretom/detail/glycoproteome.mas',
    'The Tomato Fruit Glycoproteome',
);

page_texts_ok(
    '/secretom/detail/phytophthora_interaction.mas',
    'The Secretome of Phytophthora / Tomato Interactions',
    'Data Sets',
    'Files',
);

page_texts_ok(
    '/secretom/detail/prediction.mas',
    'Other computational tools for prediction of ER-targeting signal peptides',
    'Search SecreTary, SignalP, TargetP results for secreted proteins',
    'Computational prediction of secreted proteins',
    'SecreTary, SignalP, TargetP results',
    'New predictor: Secretary',
    'temporarily unavailable',
);

page_texts_ok(
    '/secretom/detail/proteomics.mas',
    'Comparative proteomic analysis of tomato fruit ripening',
    'Tomato Comparative and Quantitative Proteomics',
);

page_texts_ok(
    '/secretom/detail/secretion_path.mas',
    'About Secretory Pathways',
);

page_texts_ok(
    '/secretom/detail/spinoffs.mas',
    'The Evolutionary Origins of the Plant Cell Wall and Associated Secretome',
    'Spin-off Projects and Collaborations',
);

done_testing;
