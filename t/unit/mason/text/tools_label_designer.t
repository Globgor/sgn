=head1 NAME

t/unit/mason/text/tools_label_designer.t - tools/label_designer templates: the text is shown in the user's language

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
    '/tools/label_designer/design_label.mas',
    'Add, drag, customize, resize, and delete as many elements as you like. A barcode containing your unique identifier (plot_name, plant_name, etc) is strongly recommended.',
    'Time to design! Start by selecting a type and field. Then click \'Add\' to generate your new label element in the draw area.',
    'Center-align text elements',
    'Left-align text elements',
    'Create Custom Field',
    'Add Elements:',
);

page_texts_ok(
    '/tools/label_designer/index.mas',
    'Set Page and Label Size',
    'Intro and Data Source',
    'Label Designer',
    'Next',
);

page_texts_ok(
    '/tools/label_designer/label_designer_modals.mas',
    'Set the column and row number of where to print the first label, if using a sheet that has already been partially used',
    'Position of First Label:',
    'Additional Settings:',
    'Total # to download:',
    'Add Custom Number:',
    'Number of Columns:',
);

page_texts_ok(
    '/tools/label_designer/save_and_download.mas',
    'When you are ready, click \'Download pdf\' to generate your labels. If you are trying to download a very large set, you will be given the option to download your labels in batches.',
    'Last step! Here you can edit additional layout settings and/or save your design.',
    'Set margins, # of rows/cols, etc:',
    'Edit Additional Settings',
    'By Column: Serpentine',
    'By Row: Serpentine',
);

page_texts_ok(
    '/tools/label_designer/select_datasource.mas',
    'To start, select a data source and a data level. The data source can be a list, crossing experiment, trial, or genotyping plate. When you are finished, click \'Next\'.',
    'Welcome to the Label Designer',
    'Label For Every:',
    'Data Source:',
    'Datatype:',
);

page_texts_ok(
    '/tools/label_designer/select_layout.mas',
    'Now, define your layout. You may retrieve these settings from a saved design, or you can start a new design by selecting a page and label format.',
    'Imperial (inches)',
    'Label Format:',
    'Label Height:',
    'New or Saved:',
    'Label Width:',
);

done_testing;
