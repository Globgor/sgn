=head1 NAME

t/unit/js/text/js_legacy_CXGN_1.t - scripts in legacy/CXGN, group 1: the messages go through gettext

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
    [ 'js/source/legacy/CXGN/Blast.js',
        'gettext("Please enter a sequence :-)")',
        'gettext("The BLAST program does not match the selected database and query.")',
        'gettext("An error occurred. The service may not be available right now.")',
        'gettext("An  error occurred. ")',
        'gettext("Multiple sequences were detected. The output will be shown in the tabular and basic format")',
    ],
    [ 'js/source/legacy/CXGN/BreederSearch.js',
        'gettext("No filters selected for download.")',
        'gettext(\'Please enter a name for the selection.\')',
        'gettext("Successfully stored the dataset!")',
        'gettext("An error occurred.")',
        'gettext(\'No trials selected\')',
        'gettext(\'No accessions selected\')',
        'gettext(\'No genotyping protocols selected. Default will be used.\')',
        'gettext(\'No Selection\')',
    ],
    [ 'js/source/legacy/CXGN/Dataset.js',
        'gettext(\'An error occurred. Please try again.\')',
        'gettext(\'The dataset has been deleted.\')',
        'gettext(\'The dataset is now public.\')',
        'gettext(\'The dataset is now private.\')',
        'gettext(\'The dataset description has been updated.\')',
        'gettext("This dataset does not contain any selections.")',
        'gettext(\'A processing error occurred.\')',
    ],
    [ 'js/source/legacy/CXGN/Hotlist.js',
        'gettext("buttonId not sent!")',
        'gettext(\'invalid request\')',
    ],
    [ 'js/source/legacy/CXGN/Locations.js',
        'gettext("An error occurred")',
        'gettext("Could not find matching location")',
    ],
    [ 'js/source/legacy/CXGN/SelectionIndex.js',
        'gettext(\'Add another trait\')',
        'gettext("An error occurred while retrieving average phenotypes")',
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
