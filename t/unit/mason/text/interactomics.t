=head1 NAME

t/unit/mason/text/interactomics.t - interactomics templates: the text is shown in the user's language

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
    '/interactomics/index.mas',
    'This is a CytoScape Java Web Start app designed to preload with the coffee interactome data.  In order to use this app, please click the Launch Cytoscape button below, which will download the configuration file and load the java app from your browser.  The application itself will not be installed on your computer, but you should get full Cytoscape functionality, and be able to view, process, edit, and save the network shown.',
    'CytoScape Interactome Viewer',
    'Launch CytoScape',
);

done_testing;
