=head1 NAME

t/unit/mason/text/util.t - util templates: the text is shown in the user's language

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
    '/util/styleguide.mas',
    'This section is used from trial detail page and stock detail page, but ideally it would be used on all detail pages. The info_section_id specifies what to show in the main section. Buttons can be passed into the buttons_html.',
    'HTML Muliple Selects (get_select_box has many options e.g. search for trials in breeding_program_name)',
    'Genotyping Plate Symbol(96 or 384 well plate)[Manage Genotyping Plates]',
    'There is still a pending step. Complete it to see the final endscreen.',
    'The relative path to the CSS file from the /static/css folder.',
    'Genotyping Plate Symbol(96 or 384 well plate)[Folder Detail]',
);

done_testing;
