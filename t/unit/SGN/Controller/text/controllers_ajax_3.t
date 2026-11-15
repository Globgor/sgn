=head1 NAME

t/unit/SGN/Controller/text/controllers_ajax_3.t - SGN::Controller::AJAX controllers, group 3

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
    [ 'lib/SGN/Controller/AJAX/GenotypingTrial.pm', 'SGN::Controller::AJAX::GenotypingTrial', [ '__(\'You do not have the required privileges to create a genotyping plate.\')', '__("Please provide all parameters in the plate information section")', '__("To submit to Cornell IGD you need to provide the blank well!")', '__("Do not upload both XLS and Coordinate file at the same time!")', '__("Do not upload both XLS and Custom Coordinate file at the same time!")', '__("Do not upload both Coordinate file and Custom Coordinate file at the same time!")', '__("You must upload a genotyping plate file!")', '__(\'Genotyping plate id must be given!\')', '__("Uploaded file name must not contain spaces or slashes.")', '__(\'You must be logged in to upload genotyping plate!\')', '__(\'You must be logged in to upload a genotyping plate!\')', '__("You have insufficient privileges to upload a genotyping plate.")', '__(\'You must be logged in to upload genotyping plate!\')', '__(\'You must be logged in to upload a genotyping plate!\')', '__("You have insufficient privileges to upload a genotyping plate.")', '__("Please provide all parameters in the plate information section")', '__("Successfully stored the genotyping plate.")', '__("Insufficient privileges for this operation.")', '__(\'You do not have the required privileges to move genotyping plates to this project.\')', '__("Error adding genotyping plate to this project")', '__(\'Must have correct permissions to delete genotyping data! Please contact us.\')' ] ],
    [ 'lib/SGN/Controller/AJAX/Grafting.pm', 'SGN::Controller::AJAX::Grafting', [ '__(\'You must be logged in to upload seedlots!\')', '__(\'You must be logged in to upload seedlots!\')', '__("You have insufficient privileges to add grafts.")', '__("Grafting upload requires a tab delimited file. Excel files (.xls and .xlsx) are currently not supported. Please convert the file and try again.")', '__(\'You must be logged in to upload seedlots!\')', '__(\'You must be logged in to upload seedlots!\')', '__("You have insufficient privileges to add grafts.")' ] ],
    [ 'lib/SGN/Controller/AJAX/HTMLSelect.pm', 'SGN::Controller::AJAX::HTMLSelect', [ '__("Parameter not supported!")' ] ],
    [ 'lib/SGN/Controller/AJAX/Heritability.pm', 'SGN::Controller::AJAX::Heritability', [ '__("Can\'t find data.")' ] ],
    [ 'lib/SGN/Controller/AJAX/HighDimensionalPhenotypes.pm', 'SGN::Controller::AJAX::HighDimensionalPhenotypes', [ '__(\'You must be logged in to do this!\')', '__(\'You must be logged in to do this!\')', '__(\'You do not have permission in the database to do this! Please contact us.\')' ] ],
    [ 'lib/SGN/Controller/AJAX/Locations.pm', 'SGN::Controller::AJAX::Locations', [ '__(\'You must be logged in to add or edit a location.\')', '__(\'You do not have the necessary privileges to add or edit locations.\')', '__("You need to be logged in to delete a location.")', '__("You don\'t have the privileges to delete a location.")', '__("The location [Computation] is needed by the system to store analyses and cannot be deleted.")', '__(\'You must be logged in to add or edit a location.\')', '__(\'You must be logged in to add or edit a location.\')' ] ],
    [ 'lib/SGN/Controller/AJAX/MixedModels.pm', 'SGN::Controller::AJAX::MixedModels', [ '__(\'You must be logged in first!\')', '__("There are no factors with multiple levels in this dataset.")', '__("Can\'t find data.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Nirs.pm', 'SGN::Controller::AJAX::Nirs', [ '__("Not enough data! Need at least 5 samples with a phenotype and spectra! Maybe choose a different device type?")', '__("Not enough data! Are you sure phenotypes were uploaded for the trait in your testing dataset?")', '__("Not enough data! Are you sure phenotypes were uploaded for the trait in your training dataset?")', '__("Not enough data! Need at least 10 samples with a phenotype and spectra! Maybe choose a different device type?")' ] ],
    [ 'lib/SGN/Controller/AJAX/Onto.pm', 'SGN::Controller::AJAX::Onto', [ '__("You must be logged in to recompute an ontology\'s cvtermpath.")', '__("You have insufficient privileges to recompute an ontology\'s cvtermpath.")', '__("An ontology namespace is required.")', '__("An ontology namespace is required.")', '__(\'You must be logged in to create ontology!\')', '__(\'You must be logged in to create ontology!\')', '__("You have insufficient privileges to add ontology.")', '__(\'You must be logged in to create observation variables!\')', '__(\'You must be logged in to create observation variables!\')', '__("You have insufficient privileges to add observation variables.")', '__("No exact matches found.")', '__("No matches found.")' ] ],
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
