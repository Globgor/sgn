=head1 NAME

t/unit/js/text/js_legacy_solGS_3.t - scripts in legacy/solGS, group 3: the messages go through gettext

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
    [ 'js/source/legacy/solGS/pcaSave.js',
        'gettext("Please wait...saving the PCs may take a few minutes.")',
    ],
    [ 'js/source/legacy/solGS/searchTrials.js',
        'gettext("Searching for GS trials..")',
        'gettext("No trials were found.")',
        'gettext("Searching for more GS trials..")',
        'gettext("Error occurred fetching the next set of GS trials.")',
        'gettext("No trials phenotyped for the trait were found.")',
        'gettext("Error occurred fetching the first set of GS trials.")',
        'gettext("Please enter a trial name.")',
    ],
    [ 'js/source/legacy/solGS/selectionIndex.js',
        'gettext("At least two traits must be assigned relative weight.")',
        'gettext("Running correlation... please wait...")',
        'gettext("Error occurred running correlation analysis.")',
    ],
    [ 'js/source/legacy/solGS/selectionPopulations.js',
        'gettext("Please enter trial name.")',
    ],
    [ 'js/source/legacy/solGS/solGS.js',
        'gettext("Error occurred checking for cached output.")',
        'gettext("Job submission")',
        'gettext("Yes")',
        'gettext("To use this feature, you need to log in and start over the process.")',
        'gettext("Login")',
        'gettext("Cancel")',
        'gettext("Info about the analysis")',
        'gettext("Submit")',
        'gettext("Analysis name is blank. Please give a name.")',
        'gettext("The same name exists for another analysis. Please give a new name.")',
        'gettext("Please provide a proper email address.")',
        'gettext("Prediction Modeling Message")',
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
