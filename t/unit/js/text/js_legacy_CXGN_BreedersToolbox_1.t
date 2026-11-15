=head1 NAME

t/unit/js/text/js_legacy_CXGN_BreedersToolbox_1.t - scripts in legacy/CXGN/BreedersToolbox, group 1: the messages go through gettext

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
    [ 'js/source/legacy/CXGN/BreedersToolbox/Accessions.js',
        'gettext("Population name is required")',
        'gettext("Member type is required")',
        'gettext("A list of accessions is required")',
        'gettext("The accession list did not pass validation. Names in the list must be uniquenames with accession stock type in the database")',
        'gettext("A list of plots is required")',
        'gettext("The plot list did not pass validation. Names in the list must be uniquenames with plot stock type in the database")',
        'gettext("A list of plants is required")',
        'gettext("The plant list did not pass validation. Names in the list must be uniquenames with plant stock type in the database")',
        'gettext(\'An error occurred retrieving population data.\')',
        'gettext("Member Name")',
        'gettext("Member Type")',
        'gettext("Description")',
        'gettext("Synonyms")',
        'gettext("Remove From Population")',
        'gettext("The accession list did not pass validation. Names in the list must be  in the database")',
        'gettext(\'An error occurred in adding members to population. sorry\')',
        'gettext(\'An error occurred in deleting population. sorry\')',
        'gettext("Are you sure?")',
        'gettext(\'An error occurred in removing accession from population. sorry\')',
        'gettext(\'You will receive an email when the process is complete. Do you want to continue ?\')',
        'gettext(\'An error occurred. The site may not be available right now.\')',
        'gettext("Species name required")',
        'gettext("No accessions to add")',
        'gettext(\'ERROR! Try again later.\')',
        'gettext("Please select a file")',
        'gettext("An unknown error occurred.  Please try again later or contact us for help.")',
        'gettext(\'All accessions in your list already exist in the database. (3)\')',
        'gettext(\'All accessions in your list now exist in the database. 2\')',
        'gettext(\'An error occurred checking your fuzzy options! Do not try to add a synonym to a synonym! Also do not use any special characters!\')',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/AddTrial.js',
        'gettext("You need to specify the number of rows and columns to give plant coordinates within plots.")',
        'gettext("Only one plant per (row, column) coordinate is allowed. You must specify fewer plants per plot, or add rows and columns.")',
        'gettext("Please supply a trial name")',
        'gettext("Please select a breeding program")',
        'gettext("Please select at least one location")',
        'gettext("Please select a trial year")',
        'gettext("Please check the plot width")',
        'gettext("Please check the plot width is too high")',
        'gettext("Please check the plot length")',
        'gettext("Please check the plot length is too high")',
        'gettext("Please no more than 500 plants per plot.")',
        'gettext("Please supply a description!")',
        'gettext("Please select a design type")',
        'gettext("Please select a stock type")',
        'gettext(\'An error occurred checking trial name\')',
        'gettext(\'Please make sure to select an accession list above!\')',
        'gettext(\'Please first select a list of accessions above!\')',
        'gettext(\'An error occurred. sorry\')',
        'gettext(\'Number of seeds per plot is required if you have selected a seedlot list!\')',
        'gettext("You must supply the number of plants per treatment.")',
        'gettext("You specified in-plot coordinates, but the number of plants per plot is greater than the number of positions available in each plot. Please decrease the number of plants per plot or increase the number of available positions. If this is a greenhouse trial, make sure no accession is specified to have more plants than the number of allowed spaces. If this is a splitplot design, please make sure that the number of plants per plot specified in section (2) matches the number of plants per treatment.")',
        'gettext("Row and column numbers were generated on the fly for displaying the physical layout or map. The plots are displayed in zigzag format. These row and column numbers will not be saved in the database. Click \'ok\' to continue...")',
        'gettext(\'An error occurred. sorry.\')',
        'gettext(\'Trial name required\')',
        'gettext(\'Year and description are required.\')',
        'gettext(\'Description is required.\')',
        'gettext(\'Accession list, seedlot list, cross list or family name list is not valid!\')',
        'gettext("Unsupported design method")',
        'gettext("Please select a breeding program first")',
        'gettext(\'An error occurred saving the trial.\')',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/CrossDetailPage.js',
        'gettext("Cancel")',
        'gettext(\'Add more progeny\')',
        'gettext("Done")',
        'gettext(\'Edit Field Crossing Data\')',
        'gettext("Saving it.")',
        'gettext("Not saving.")',
        'gettext("The request for checking the parameters failed. Please try again.")',
        'gettext("The property was successfully saved.")',
        'gettext(\'Edit Additional Parent Info\')',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/Crosses.js',
        'gettext("Crossing Experiment name is required")',
        'gettext("Breeding program is required")',
        'gettext("Location is required")',
        'gettext("Year is required")',
        'gettext("Description is required")',
        'gettext("A cross unique id is required")',
        'gettext("A crossing experiment is required")',
        'gettext("No file selected")',
        'gettext("Please select your breeding program")',
        'gettext("Please select a file")',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/DerivedAccessions.js',
        'gettext("Please select a file")',
    ],
    [ 'js/source/legacy/CXGN/BreedersToolbox/FieldBook.js',
        'gettext(\'Layout deleted successfully.\')',
        'gettext("Traits, from a list or selected individually, are required.")',
        'gettext("A trait file name is required.")',
        'gettext(\'An error occurred creating the trait file.\')',
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
