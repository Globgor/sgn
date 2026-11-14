=head1 NAME

t/unit/js/text/js_entries_trialallocation.t - scripts in entries/trialallocation: the messages go through gettext

=head1 DESCRIPTION

Each script must call gettext() for the messages listed here, and each legacy
script must be valid JavaScript (checked with Node.js when it is installed; a
webpack entry is a module, which the build checks). gettext() comes from
CXGN/I18N.js; t/unit/js/i18n_dependencies.t checks that it is loaded first.
This test does not run the scripts.

=cut

use strict;
use warnings;

use Test::More;

my @scripts = (
    [ 'js/source/entries/trialallocation/app.js',
        'gettext(\'Year must be in YYYY format, greater than 1960 and smaller than 2100.\')',
        'gettext(\'This plot already contains a trial, filler, or border.\')',
        'gettext(\'Borders cannot be placed on trial or filler plots.\')',
        'gettext(\'Select a trial plot to place a filler inside the trial.\')',
        'gettext(\'Select an existing trial first.\')',
        'gettext(\'This existing trial is already included in the layout.\')',
        'gettext(\'Could not add the selected existing trial.\')',
        'gettext(\'Place this trial in the grid before rotating it.\')',
        'gettext(\'This trial is part of a saved layout and cannot be rotated.\')',
        'gettext("Could not load Accessions List")',
        'gettext("Error loading Accessions List.")',
        'gettext("Could not load Controls List")',
        'gettext("Error loading Controls List.")',
        'gettext(\'Generate Design is not available for existing saved trials.\')',
        'gettext(\'This trial is part of a saved layout and cannot be moved.\')',
        'gettext(\'Grid is still loading. Please wait.\')',
        'gettext("Please click \'Generate Design\' before placing the trial.")',
        'gettext(\'Error generating design.\')',
        'gettext(\'This trial is part of a saved layout and cannot be changed.\')',
        'gettext(\'Could not place trial: starting plot is outside the field.\')',
        'gettext(\'Could not place trial: the selected path contains another trial, border, or filler plot.\')',
        'gettext(\'Could not place trial: not enough available plots from this starting position.\')',
        'gettext(\'Cannot rotate - no free space at current position.\')',
        'gettext(\'This trial is part of a saved layout. Remove it from the saved layout view on the grid instead.\')',
        'gettext(\'Only curators can remove saved trials from a layout.\')',
        'gettext(\'Select location and year before removing a saved trial.\')',
        'gettext(\'Trial removed from the saved layout view.\')',
        'gettext(\'Could not remove trial from the saved layout view.\')',
        'gettext(\'Only curators can delete a saved layout view.\')',
        'gettext(\'Select location and year before deleting the layout view.\')',
        'gettext(\'Saved layout view deleted.\')',
        'gettext(\'Could not delete the saved layout view.\')',
        'gettext(\'Select location and year before saving the layout.\')',
        'gettext(\'Layout saved.\')',
        'gettext(\'Could not save layout.\')',
        'gettext(\'Select location and year before saving the trials.\')',
        'gettext(\'Select a breeding program before saving the trials.\')',
        'gettext(\'There are no new trials or existing-trial coordinate updates to save in the database.\')',
        'gettext(\'Could not save trials in the database.\')',
        'gettext("It is not possible to turn entire row or column unutilized because there is a trial or border already placed.")',
    ],
    [ 'js/source/entries/trialallocation/downloads.js',
        'gettext(\'The XLSX export library is not available on this page.\')',
        'gettext(\'Place trials, borders, or fillers before downloading the planting map.\')',
        'gettext("Set the field rows and columns before exporting the full grid.")',
        'gettext("Could not export the full field grid.")',
    ],
);

my $node = grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // q{};

for my $script (@scripts) {
    my ( $file, @calls ) = @$script;
    open( my $in, '<:raw', $file ) or die "Cannot read $file: $!";
    my $source = do { local $/ = undef; <$in> };
    close $in;
    my @missing = grep { index( $source, $_ ) < 0 } @calls;
    ok( !@missing, "$file calls gettext for its messages" ) or diag( 'Missing: ', join( ', ', @missing ) );
  SKIP: {
        skip 'Node.js is not installed', 1 if !$node;
        skip 'a webpack entry, checked by the build', 1 if $file !~ m{/legacy/};
        is( system( 'node', '--check', $file ), 0, "$file is valid JavaScript" );
    }
}

done_testing;
