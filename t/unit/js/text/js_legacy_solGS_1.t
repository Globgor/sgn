=head1 NAME

t/unit/js/text/js_legacy_solGS_1.t - scripts in legacy/solGS, group 1: the messages go through gettext

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
    [ 'js/source/legacy/solGS/analysisSelect.js',
        'gettext("Error retrieving tool compatibility.")',
        'gettext("Please select an analysis type.")',
        'gettext("Please select an analysis population.")',
        'gettext("Running correlation... please wait...")',
        'gettext("There is no correlation output for this dataset.")',
        'gettext("Error occured running the correlation analysis.")',
    ],
    [ 'js/source/legacy/solGS/analysisStatus.js',
        'gettext("Jobs cleared from recent activity.")',
    ],
    [ 'js/source/legacy/solGS/anova.js',
        'gettext("Alert")',
    ],
    [ 'js/source/legacy/solGS/clearCache.js',
        'gettext(\'Error occurred while clearing cache\')',
    ],
    [ 'js/source/legacy/solGS/cluster.js',
        'gettext("Running cluster... please wait...it may take minutes.")',
        'gettext("cluster job submission")',
        'gettext("Yes")',
        'gettext("No, I will wait till it completes.")',
        'gettext("Cancel")',
    ],
    [ 'js/source/legacy/solGS/combineTrials.js',
        'gettext(\'Error occured getting combined trials unique id\')',
        'gettext(\'combined Trials id missing.\')',
    ],
    [ 'js/source/legacy/solGS/correlation.js',
        'gettext("Running correlation... please wait...")',
    ],
    [ 'js/source/legacy/solGS/gebvPhenoRegression.js',
        'gettext(\'There is no GEBVs vs observed phenotypes regression data.\')',
        'gettext(\'Error occured requesting for theGEBVs vs observed phenotypes regression data.\')',
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
