=head1 NAME

t/unit/js/text/js_legacy_solGS_2.t - scripts in legacy/solGS, group 2: the messages go through gettext

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
    [ 'js/source/legacy/solGS/gebvsSave.js',
        'gettext("Please wait...saving the GEBVs may take a few minutes.")',
        'gettext("Please wait...saving the genetic values (adjusted means) may take a few minutes.")',
    ],
    [ 'js/source/legacy/solGS/geneticGain.js',
        'gettext("Please wait... plotting genetic gain")',
        'gettext("There is no GEBV data for the training population.")',
        'gettext("Error occured checking for GEBV data for the training population.")',
        'gettext("Please wait... plotting gebvs")',
        'gettext("There is no GEBV data for the selection population.")',
        'gettext("Error occured checking for GEBV data for the selection population.")',
        'gettext("This selection population has no predicted traits.")',
    ],
    [ 'js/source/legacy/solGS/heatMap.js',
        'gettext("The heatmap canvas div element is missing.")',
    ],
    [ 'js/source/legacy/solGS/kinship.js',
        'gettext("Running kinship... please wait...it may take minutes.")',
        'gettext("Generating heatmap... please wait...")',
        'gettext("Kinship job submission")',
        'gettext("Yes")',
        'gettext("No, I will wait till it completes.")',
        'gettext("This population has no kinship output data.")',
        'gettext("Error occured running the kinship.")',
        'gettext("Cancel")',
    ],
    [ 'js/source/legacy/solGS/listTypeSelectionPopulation.js',
        'gettext("Error occured checking if the selection population has predicted output.")',
    ],
    [ 'js/source/legacy/solGS/listTypeTrainingPopulation.js',
        'gettext("Error occured querying for trials ids")',
    ],
    [ 'js/source/legacy/solGS/loadAcronyms.js',
        'gettext(\'Error occurred loading acronyms\')',
    ],
    [ 'js/source/legacy/solGS/pca.js',
        'gettext("Run PCA")',
        'gettext("Done")',
        'gettext("pca job submission")',
        'gettext("Yes")',
        'gettext("No, I will wait till it completes.")',
        'gettext("Running pca... please wait...")',
        'gettext("Cancel")',
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
