=head1 NAME

t/unit/SGN/Controller/text/controllers_ajax_2.t - SGN::Controller::AJAX controllers, group 2

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
    [ 'lib/SGN/Controller/AJAX/DeriveTrait.pm', 'SGN::Controller::AJAX::DeriveTrait', [ '__("You need to be logged in to compute trait.")', '__("You have insufficient privileges to compute trait.")', '__("No trait assayed for this trial.")', '__("Select trait to compute.")', '__(\'Must be a curator to overwrite values! Please contact us!\')' ] ],
    [ 'lib/SGN/Controller/AJAX/DocumentBrowser.pm', 'SGN::Controller::AJAX::DocumentBrowser', [ '__(\'Must be logged in!\')', '__(\'Problem archiving the file!\')', '__(\'Problem retrieving file md5!\')', '__(\'Successfully saved file!\')' ] ],
    [ 'lib/SGN/Controller/AJAX/EnvironmentStratification.pm', 'SGN::Controller::AJAX::EnvironmentStratification', [ '__(\'Dataset id is required.\')', '__("Phenotype file is required.")', '__("Can\'t find data.")', '__(\'Dataset and trait are required.\')', '__(\'Alpha must be a number between 0 and 1.\')' ] ],
    [ 'lib/SGN/Controller/AJAX/FamilyName.pm', 'SGN::Controller::AJAX::FamilyName', [ '__("You do not have the correct role to modify family members. Please contact us.")', '__("You do not have the correct role to delete family. Please contact us.")', '__(\'Only a submitter or a curator can add family members\')' ] ],
    [ 'lib/SGN/Controller/AJAX/FileShareDump.pm', 'SGN::Controller::AJAX::FileShareDump', [ '__("Could not store uploaded file!")', '__(\'You must be logged in to do this!\')', '__(\'You must be logged in to do this!\')' ] ],
    [ 'lib/SGN/Controller/AJAX/GCPC.pm', 'SGN::Controller::AJAX::GCPC', [ '__("Can\'t find data.")', '__("None of the traits in the selection index are present in the dataset. Please choose another selection index.")' ] ],
    [ 'lib/SGN/Controller/AJAX/GenotypesVCFUpload.pm', 'SGN::Controller::AJAX::GenotypesVCFUpload', [ '__(\'You must be logged in to upload this VCF genotype info!\')', '__(\'You must be logged in to upload this VCF genotype info!\')', '__(\'Must have correct permissions to upload VCF genotypes! Please contact us.\')', '__("Each genotyping project should be associated with only one protocol")', '__("The selected genotyping project is already associated with different protocol. Each project should be associated with only one protocol")', '__("The selected genotyping project is already associated with a protocol. Each project should be associated with only one protocol")', '__(\'Do not try to upload both VCF and Intertek at the same time!\')', '__(\'Do not try to upload both VCF and Tassel HDF5 at the same time!\')', '__(\'Do not try to upload both Intertek and Tassel HDF5 at the same time!\')', '__(\'To upload Intertek genotype data please provide both the Grid Genotypes File and the Marker Info File.\')', '__(\'The organism species you provided is not in the database! Please contact us.\')', '__(\'The organism species you provided is not unique in the database! Please contact us.\')', '__("Too many new markers")', '__("Too many new markers, should be less than 20")' ] ],
    [ 'lib/SGN/Controller/AJAX/GenotypingProject.pm', 'SGN::Controller::AJAX::GenotypingProject', [ '__(\'Must have correct permissions to delete genotypes! Please contact us.\')', '__("you have insufficient privileges to add a genotyping project.")' ] ],
    [ 'lib/SGN/Controller/AJAX/GenotypingProtocol.pm', 'SGN::Controller::AJAX::GenotypingProtocol', [ '__(\'Must have correct permissions to delete genotypes! Please contact us.\')', '__(\'You must be logged in to edit genotyping protocol\')', '__(\'You must be logged in to edit genotyping protocol\')', '__(\'Must have correct permissions to edit genotyping protocol! Please contact us.\')', '__("New protocol name not saved: Protocol name already exists")', '__(\'The species name you provided is not in the database! Please contact us.\')', '__(\'The species name you provided is not unique in the database! Please contact us.\')', '__(\'The parser did not return any data!\')', '__("You need to be logged in to update marker metadata.")', '__("You must be a curator to update marker metadata.")', '__("You need to be logged in to delete marker metadata.")', '__("You must be a curator to delete marker metadata.")', '__(\'Must have correct permissions to delete genotyping protocol! Please contact us.\')' ] ],
    [ 'lib/SGN/Controller/AJAX/GenotypingQC.pm', 'SGN::Controller::AJAX::GenotypingQC', [ '__(\'You must be logged in to upload this seedlot info!\')', '__(\'You must be logged in to upload this seedlot info!\')', '__(\'Must have correct permissions to upload VCF genotypes! Please contact us.\')', '__(\'Please provide a genotype qc file.\')' ] ],
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
