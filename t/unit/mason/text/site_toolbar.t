=head1 NAME

t/unit/mason/text/site_toolbar.t - site/toolbar templates: the text is shown in the user's language

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
    '/site/toolbar/dataset.mas',
    'Dataset',
);

page_texts_ok(
    '/site/toolbar/genomes.mas',
    'Tomato - Apollo genome annotation editor',
    '150 Tomato Genome Resequencing Project',
    'BGI Tomato 360 genomes',
    'Resequencing projects',
    'Sequenced Accessions',
    'Completed Genomes',
);

page_texts_ok(
    '/site/toolbar/logout_externally.mas',
    'Logging out...',
);

page_texts_ok(
    '/site/toolbar/maps.mas',
    'The New Comparative Viewer',
    'Tomato FPC contig map',
    'Tomato physical map',
    'Comparative Viewer',
    'Eggplant COSII map',
    'Pepper COSII map',
);

page_texts_ok(
    '/site/toolbar/projects.mas',
    'International Tomato Sequencing Project',
    'U.S. tomato sequencing project',
    'Solanaceae project (SOL)',
    'Previous Projects',
    'Varitome project',
    'SOL-100 Project',
);

page_texts_ok(
    '/site/toolbar/resources.mas',
    'Resources',
    'Page 1-1',
    'Page 1-2',
    'Page 1-3',
);

page_texts_ok(
    '/site/toolbar/tools.mas',
    'Clones, Arrays, Unigenes and BACs',
    'Tomato Expression Database (TED)',
    'Tomato Expression Atlas (TEA)',
    'SolCyc Biochemical Pathways',
    'Coffee Interactomic Data',
    'Genome Browser (Jbrowse)',
);

done_testing;
