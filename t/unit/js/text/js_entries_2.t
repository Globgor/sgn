=head1 NAME

t/unit/js/text/js_entries_2.t - scripts in entries, group 2: the messages go through gettext

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
    [ 'js/source/entries/sequenced_accessions.js',
        'gettext("The entry has been saved. Thank you!")',
        'gettext("The entry has been deleted.")',
        'gettext("An error occurred. The entry was not deleted.")',
        'gettext("an error occurred")',
    ],
    [ 'js/source/entries/vectorViewer.js',
        'gettext(\'Save current changes?\')',
        'gettext(\'Sequence successfully saved!\')',
        'gettext(\'An error occurred while trying to save the vector data.\')',
        'gettext(\'Add feature\')',
        'gettext(\'Edit feature\')',
        'gettext(\'Are you sure that you would like to delete this row with id ? \')',
        'gettext(\'Feature\')',
        'gettext(\'Start\')',
        'gettext(\'End\')',
        'gettext(\'Color\')',
        'gettext(\'Orientation\')',
        'gettext("Actions")',
    ],
    [ 'js/source/entries/wizard.js',
        'gettext("List is not of an appropriate type.")',
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
