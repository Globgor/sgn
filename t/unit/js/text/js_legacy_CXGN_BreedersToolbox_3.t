=head1 NAME

t/unit/js/text/js_legacy_CXGN_BreedersToolbox_3.t - scripts in legacy/CXGN/BreedersToolbox, group 3: the messages go through gettext

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
    [ 'js/source/legacy/CXGN/BreedersToolbox/UploadTrial.js',
        'gettext("Please select a breeding program first")',
        'gettext("You need to specify the number of rows and columns to give plant coordinates within plots.")',
        'gettext("Only one plant per (row, column) coordinate is allowed. You must specify fewer plants per plot, or add rows and columns.")',
        'gettext("Please give a trial name")',
        'gettext("Please give a breeding program")',
        'gettext("Please give a location")',
        'gettext("Please give a trial year")',
        'gettext("Please check the plot width")',
        'gettext("Please check the plot width is too high")',
        'gettext("Please check the plot length")',
        'gettext("Please check the plot length is too high")',
        'gettext("Please no more than 500 plants per plot.")',
        'gettext("Please give a description")',
        'gettext("Please select stock type being evaluated in trial")',
        'gettext("Please give a design type")',
        'gettext("Please select a file")',
        'gettext(\'An error occurred checking trial name\')',
        'gettext("No file selected")',
        'gettext("There was an error uploading your trial.")',
        'gettext("Success! All trials successfully loaded.")',
        'gettext("Your file has been uploaded.  You will receive an email once the process is complete.")',
        'gettext("An error occurred while trying to upload this file. Please check the formatting and try again")',
        'gettext("Success! All trials successfully updated.")',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/Vector.js',
        'gettext("No vectors to add")',
        'gettext("Please select a file")',
        'gettext("An unknown error occurred.  Please try again later or contact us for help.")',
        'gettext(\'All vectors in your list already exist in the database. (3)\')',
        'gettext(\'All vectors in your list now exist in the database. 2\')',
        'gettext(\'An error occurred checking your fuzzy options! Do not try to add a synonym to a synonym! Also do not use any special characters!\')',
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
