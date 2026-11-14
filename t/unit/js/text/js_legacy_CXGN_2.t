=head1 NAME

t/unit/js/text/js_legacy_CXGN_2.t - scripts in legacy/CXGN, group 2: the messages go through gettext

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
    [ 'js/source/legacy/CXGN/Stock.js',
        'gettext(\'Remove a parent\')',
        'gettext("an error occurred.")',
        'gettext("Are you sure you want to remove this parent?")',
        'gettext("The parent has been removed.")',
        'gettext("Error retrieving stock id")',
        'gettext("Error retrieving stock name")',
        'gettext("Error obsoleting stock.")',
    ],
    [ 'js/source/legacy/CXGN/Transformation.js',
        'gettext(\'Are you sure you want to delete this transformation ID? The deletion cannot be undone.\')',
        'gettext(\'Deletion was successful\')',
        'gettext(\'An error occurred during deletion\')',
        'gettext(\'An error occurred setting transformation control\')',
    ],
    [ 'js/source/legacy/CXGN/TrialTreeFolders.js',
        'gettext(\'An error occurred refreshing trial jstree html\')',
        'gettext(\'An error occurred refreshing crosses jstree html\')',
        'gettext(\'An error occurred refreshing genotype trial jstree html\')',
        'gettext(\'An error occurred refreshing genotype project jstree html\')',
        'gettext(\'An error occurred refreshing activity jstree html\')',
        'gettext(\'An error occurred refreshing transformation project jstree html\')',
        'gettext(\'An error occurred refreshing propagation project jstree html\')',
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
