=head1 NAME

t/unit/js/text/js_legacy_qualityControl.t - scripts in legacy/qualityControl: the messages go through gettext

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
    [ 'js/source/legacy/qualityControl/qualityControl.js',
        'gettext("This population has no valid traits to qclate.")',
        'gettext("Error 3 occured preparing the additive genetic data for qualityControl analysis.")',
        'gettext("Running qualityControl... please wait...")',
        'gettext("This population has no phenotype data.")',
        'gettext("Error 1 occured preparing the phenotype data for qualityControl analysis.")',
        'gettext("There is no qualityControl output for this dataset.")',
        'gettext("Error 2 occured running the qualityControl analysis.")',
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
