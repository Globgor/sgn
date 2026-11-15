=head1 NAME

t/unit/js/text/js_legacy_tools.t - scripts in legacy/tools: the messages go through gettext

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
    [ 'js/source/legacy/tools/LabelDesigner.js',
        'gettext(\'There was a problem checking the data levels available for your field trial. Please contact us.\')',
        'gettext("A valid type must be selected.")',
        'gettext("A valid field must be selected.")',
        'gettext("No elements in the design. Please add design elements before downloading")',
        'gettext("No data source selected. Please select a data source before downloading")',
        'gettext("No design. Please define a design before downloading")',
        'gettext("Error. Unable to download labels.")',
        'gettext("Unable to retrieve design elements of this trial. Please confirm this trial has a design, or try again with a different trial. Please contact us!")',
        'gettext("No page format select. Please select a page format")',
        'gettext("No label format select. Please select a label format")',
        'gettext("No elements in the design. Please add design elements before saving")',
    ],
    [ 'js/source/legacy/tools/vigs.js',
        'gettext("Gene Functional annotation")',
        'gettext("Parameters used")',
        'gettext("Modify parameters help")',
        'gettext("Distribution of n-mers help")',
        'gettext("Best region help")',
        'gettext("Sequence overview help")',
        'gettext("Description of genes mapped help")',
        'gettext("An error occurred. The service may not be available right now. Bowtie2 could not be executed")',
        'gettext("Note: The score value is very low!. Increasing the number of targets or the n-mer length, or decreasing the mismatches the score value will increase")',
        'gettext("Expand Graph")',
        'gettext("Zoom In")',
        'gettext("An error occurred. The service may not be available right now.")',
        'gettext("Collapse Graph")',
        'gettext("Zoom Out")',
        'gettext("there are no parameters to change")',
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
