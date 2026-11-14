=head1 NAME

t/unit/js/text/js_legacy_CXGN_BreedersToolbox_2.t - scripts in legacy/CXGN/BreedersToolbox, group 2: the messages go through gettext

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
    [ 'js/source/legacy/CXGN/BreedersToolbox/GenotypingSubmission.js',
        'gettext("An error occurred trying to log into the sequencing facility server. Please try again later.")',
        'gettext(\'An error occurred trying to submit the order.\')',
        'gettext("Genotyping server credentials are not available. Stop.")',
        'gettext("Successfully!. Plate submitted to facility.")',
        'gettext("An error occurred trying to submit your plate to the facility.")',
        'gettext(\'Order stored successfully.\')',
        'gettext(\'An error occurred trying to store the order.\')',
        'gettext("An error occurred trying to get the order status.")',
        'gettext("Something went wrong! Could not get order from submission.")',
        'gettext(\'Something went wrong!. Complete your order clicking the link.\')',
        'gettext("A plate id, client facility id and service are required. Please try again.")',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/GenotypingTrial.js',
        'gettext("A name is required and it should be unique in the database. Please try again.")',
        'gettext(\'The list contains elements that are not accessions or plots or subplots or plants or tissue_samples.\')',
        'gettext("There are no elements in the list provided.")',
        'gettext("The list needs to have less than 96 or 384 elements depending on the plate format you selected")',
        'gettext("An error occurred trying to log into the sequencing facility server. Please try again later.")',
        'gettext("Genotyping server credentials are not available. Stop.")',
        'gettext("Sending genotyping experiment entry to genotyping facility...")',
        'gettext("Successfully submitted the plate to GDF.")',
        'gettext(\'An error occurred trying the create the layout.\')',
        'gettext("BrAPI vendor specifications call to IGD did not work.")',
        'gettext(\'The genotyping plate has been deleted.\')',
        'gettext("An error occurred.")',
        'gettext(\'An error occurred replacing plot accession\')',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/HTMLSelect.js',
        'gettext("An error occurred")',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/MarkerSet.js',
        'gettext("List name is required")',
        'gettext("Genotyping protocol is required")',
        'gettext("Genotyping data type is required")',
        'gettext("Marker name is required")',
        'gettext("Please indicate a dosage")',
        'gettext("Please indicate SNP alleles")',
        'gettext("List Name")',
        'gettext("Number of Markers")',
        'gettext("Description")',
        'gettext("Are you sure you want to delete this markerset? This cannot be undone")',
        'gettext(\'An error occurred deleting markerset\')',
        'gettext("Item")',
        'gettext("Remove")',
        'gettext(\'An error occurred getting markerset detail\')',
        'gettext("Are you sure you want remove this item from the marker set?")',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/UploadGrafts.js',
        'gettext("No file selected")',
        'gettext("Please select a file")',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/UploadPedigrees.js',
        'gettext("No file selected")',
        'gettext("Please select a file")',
        'gettext(\'An error occurred storing the pedigrees. None were uploaded.\')',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/UploadPhenotype.js',
        'gettext("Please select a file")',
        'gettext("An error occurred while trying to verify this file. Please check the formatting and try again")',
        'gettext("An error occurred while trying to store this file. Please check the formatting and try again")',
        'gettext(\'Deleted successfully.\')',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/UploadRenameAccessions.js',
        'gettext("No file selected")',
        'gettext("Please select a file")',
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
