=head1 NAME

t/unit/js/text/js_legacy_CXGN_BreedersToolbox_1.t - scripts in legacy/CXGN/BreedersToolbox, group 1: the messages go through gettext

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
    [ 'js/source/legacy/CXGN/BreedersToolbox/AddTrial.js',
        'gettext("You need to specify the number of rows and columns to give plant coordinates within plots.")',
        'gettext("Only one plant per (row, column) coordinate is allowed. You must specify fewer plants per plot, or add rows and columns.")',
        'gettext("Please supply a trial name")',
        'gettext("Please select a breeding program")',
        'gettext("Please select at least one location")',
        'gettext("Please select a trial year")',
        'gettext("Please check the plot width")',
        'gettext("Please check the plot width is too high")',
        'gettext("Please check the plot length")',
        'gettext("Please check the plot length is too high")',
        'gettext("Please no more than 500 plants per plot.")',
        'gettext("Please supply a description!")',
        'gettext("Please select a design type")',
        'gettext("Please select a stock type")',
        'gettext(\'An error occurred checking trial name\')',
        'gettext(\'Please make sure to select an accession list above!\')',
        'gettext(\'Please first select a list of accessions above!\')',
        'gettext(\'An error occurred. sorry\')',
        'gettext(\'Number of seeds per plot is required if you have selected a seedlot list!\')',
        'gettext("You must supply the number of plants per treatment.")',
        'gettext("You specified in-plot coordinates, but the number of plants per plot is greater than the number of positions available in each plot. Please decrease the number of plants per plot or increase the number of available positions. If this is a greenhouse trial, make sure no accession is specified to have more plants than the number of allowed spaces. If this is a splitplot design, please make sure that the number of plants per plot specified in section (2) matches the number of plants per treatment.")',
        'gettext("Row and column numbers were generated on the fly for displaying the physical layout or map. The plots are displayed in zigzag format. These row and column numbers will not be saved in the database. Click \'ok\' to continue...")',
        'gettext(\'An error occurred. sorry.\')',
        'gettext(\'Trial name required\')',
        'gettext(\'Year and description are required.\')',
        'gettext(\'Description is required.\')',
        'gettext(\'Accession list, seedlot list, cross list or family name list is not valid!\')',
        'gettext("Unsupported design method")',
        'gettext("Please select a breeding program first")',
        'gettext(\'An error occurred saving the trial.\')',
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
