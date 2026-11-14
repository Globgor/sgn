=head1 NAME

t/unit/SGN/Controller/text/controllers_ajax_1.t - SGN::Controller::AJAX controllers, group 1

=head1 DESCRIPTION

Each controller is required in a fresh Perl interpreter without an application
or database. A successful load must provide the __ translation function. If
loading fails, the test tries a separate Perl syntax check and reports the
load error. A syntax-only pass does not check that the module runs, loads in
the application, or has the function at runtime. The import and the original
translation calls per module are also checked in the source. A class that uses
namespace::autoclean removes the imported __ from its methods after it is
compiled, while the calls in its code keep working. These checks fail
when the translation change is reverted. This test does not test translations
or HTTP responses.

=cut

use strict;
use warnings;
use File::Temp qw( tempfile );
use IPC::Open3 qw( open3 );
use Test::More;

# Capture compiler and loader diagnostics without sending them into TAP.
sub run_perl {
    my (@args) = @_;
    my ( $log, $name ) = tempfile( UNLINK => 1 );
    my $pid = open3( undef, '>&' . fileno($log), '>&' . fileno($log), $^X, '-Ilib', @args );
    waitpid $pid, 0;
    my $status = $?;
    seek $log, 0, 0 or die "Cannot seek temporary log: $!";
    local $/;
    my $output = <$log>;
    return ( $status, defined $output ? $output : '' );
}

my @modules = (
    [ 'lib/SGN/Controller/AJAX/Accessions.pm', 'SGN::Controller::AJAX::Accessions', [ '__(\'You must be logged in to upload this info!\')', '__(\'You must be logged in to upload this info!\')', '__("You need to be logged in to add accessions.")', '__("You have insufficient privileges to add accessions.")', '__(\'You must be logged in to upload this seedlot info!\')', '__(\'You must be logged in to upload this seedlot info!\')', '__(\'Only a curator, submitter or sequencer can upload a file\')', '__("Could not get parsing errors")', '__("You need to be logged in to submit accessions.")', '__("You have insufficient privileges to submit accessions.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Analysis.pm', 'SGN::Controller::AJAX::Analysis', [ '__("You are trying to save an analysis, but no name was given.")', '__("Analysis result type not accepted!")', '__(\'This model still has analyses associated! Please delete the analyses before deleting this model!\')', '__(\'You must be logged in to do this!\')', '__(\'You must be logged in to do this!\')', '__(\'You must have permission to do this! Please contact us!\')' ] ],
    [ 'lib/SGN/Controller/AJAX/Analytics.pm', 'SGN::Controller::AJAX::Analytics', [ '__("No ID given!")', '__(\'You must be logged in to do this!\')', '__(\'You must be logged in to do this!\')', '__(\'You must have permission to do this! Please contact us!\')' ] ],
    [ 'lib/SGN/Controller/AJAX/BreederSearch.pm', 'SGN::Controller::AJAX::BreederSearch', [ '__(\'Over 10,000 matches. Speeds may be affected, consider narrowing your search\')' ] ],
    [ 'lib/SGN/Controller/AJAX/BreedersToolbox.pm', 'SGN::Controller::AJAX::BreedersToolbox', [ '__("You need to be logged in with curator privileges to delete a breeding program.")', '__(\'You need to be logged in to add a data agreement\')', '__(\'You do not have the required privileges to add a data agreement to this trial.\')', '__(\'Updated data agreement.\')', '__(\'Inserted new data agreement.\')', '__("No data agreements have been added yet.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Captcha.pm', 'SGN::Controller::AJAX::Captcha', [ '__(\'Missing server captcha config\')' ] ],
    [ 'lib/SGN/Controller/AJAX/Catalog.pm', 'SGN::Controller::AJAX::Catalog', [ '__("You must be logged in to add a catalog item.")', '__("Item name is not in the database or not unique in the database!")', '__("Contact person has no record in the database!")', '__("Breeding program is not in the database!")', '__("Error saving catalog item")', '__(\'You must be logged in to upload!\')', '__(\'You must be logged in to upload catalog items!\')', '__("Item name is not unique in the database!")', '__("Error saving catalog items")', '__("You must be logged in to add a catalog image.")', '__("Item name is not in the database!")', '__("Error saving catalog image")', '__("An error occurred attempting to delete a catalog item.")', '__("You must be logged in to add catalog items.")', '__("Contact person has no record in the database!")', '__("Item name is not unique in the database!")', '__("Error saving catalog items")' ] ],
    [ 'lib/SGN/Controller/AJAX/Collection.pm', 'SGN::Controller::AJAX::Collection', [ '__("You must be logged in to do this.")', '__("collection was not found.")', '__("Only the collection\'s creator or a curator can modify it.")', '__("No valid ids were supplied.")', '__("item_type must be \'image\' or \'file\'.")', '__("project_id must be numeric.")', '__("collection was not found.")', '__("Collection created, but breeding_program_id must be numeric.")', '__("A valid item_id is required.")', '__("A valid trial_id is required.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Contact.pm', 'SGN::Controller::AJAX::Contact', [ '__("You must be a clever bot")', '__(\'The message was not posted to github correctly. Please try again.\')', '__("There was an error submitting the message. Please try again.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Dataset.pm', 'SGN::Controller::AJAX::Dataset', [ '__("Login required to perform requested action.")', '__("No logged in user to display dataset information for.")', '__("No logged in user error.")', '__("Only the owner can change a dataset")', '__("No logged in user error.")', '__("Only the owner can change a dataset")', '__("No logged in user error.")', '__("Only the owner can change a dataset")', '__("Deleting datasets requires login")', '__("Only the owner can delete a dataset")', '__(\'The selected service does not exist in the server configuration\')', '__(\'The selected service does not exist in the server configuration\')', '__(\'The selected service does not exist in the server configuration\')', '__("Login required to perform requested action.")', '__("Only the owner can publish a dataset")', '__(\'The selected service does not exist in the server configuration\')', '__("Could not generate archive file")', '__(\'The selected service does not exist in the server configuration\')', '__(\'The specified file does not exist\')', '__(\'The specified published metadata does not exist\')', '__(\'The selected service does not exist in the server configuration\')', '__(\'The specified file does not exist\')', '__(\'The specified published metadata does not exist\')', '__(\'The selected service does not exist in the server configuration\')', '__(\'The specified published metadata does not exist\')', '__(\'The selected service does not exist in the server configuration\')', '__(\'Could not publish the selected article\')', '__(\'The specified published metadata does not exist\')', '__(\'The selected service does not exist in the server configuration\')', '__(\'Could not get a DOI for the selected article\')' ] ],
);

for my $module (@modules) {
    my ( $path, $package, $examples ) = @$module;
    open my $source, '<:raw', $path or die "Cannot read $path: $!";
    local $/;
    my $text = <$source>;
    close $source or die "Cannot close $path: $!";
    like( $text, qr/^\s*use Locale::TextDomain \( 'sgn', undef \);\s*$/m, "$package imports translations" );
    my %expected;
    $expected{$_}++ for @$examples;
    my @missing;
    for my $example ( sort keys %expected ) {
        my ( $count, $offset ) = ( 0, 0 );
        while ( ( my $position = index( $text, $example, $offset ) ) >= 0 ) {
            $count++;
            $offset = $position + length($example);
        }
        push @missing, $example if $count < $expected{$example};
    }
    ok( !@missing, "$package retains its translation calls" );
    diag( 'Missing translation calls: ', join( ', ', @missing ) ) if @missing;

    ( my $require_path = $path ) =~ s{^lib/}{};
    my ( $status, $diagnostic ) = run_perl(
        '-e',
        'my ($file, $class) = @ARGV; require $file; exit($class->can("__") ? 0 : 42);',
        $require_path, $package
    );
    if ( $status == 0 ) {
        pass("$package loads and provides __");
    }
    elsif ( $status == 42 << 8 && $text =~ /^\s*use namespace::(?:auto)?clean\b/m ) {
        # The class cleans its imports: __ is no method of the class, the calls in its code stay bound.
        pass("$package loads; namespace::autoclean keeps __ out of its methods");
    }
    elsif ( $status == 42 << 8 ) {
        fail("$package loads and provides __");
        diag("The class loaded but does not provide __.\n$diagnostic");
    }
    else {
        my ( $syntax_status, $syntax_diagnostic ) = run_perl( '-c', $path );
        diag("$package could not be required; checking syntax instead:\n$diagnostic");
        if ( $syntax_status == 0 ) {
            pass("$package syntax check (runtime load not checked)");
        }
        else {
            fail("$package syntax check");
            diag($syntax_diagnostic);
        }
    }
}

done_testing;
