=head1 NAME

t/unit/SGN/Controller/text/controllers_ajax_4.t - SGN::Controller::AJAX controllers, group 4

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
    [ 'lib/SGN/Controller/AJAX/Pedigrees.pm', 'SGN::Controller::AJAX::Pedigrees', [ '__(\'You must be logged in to upload pedigrees!\')', '__(\'You must be logged in to upload pedigrees!\')', '__(\'Only a submitter or a curator can upload pedigrees\')', '__("Could not get parsing errors")' ] ],
    [ 'lib/SGN/Controller/AJAX/PhenotypesUpload.pm', 'SGN::Controller::AJAX::PhenotypesUpload', [ '__("You need to be logged in to record phenotype.")', '__("You have insufficient privileges to record phenotype.")', '__("Used only for Plot Phenotyping.")', '__("You need to be logged in to record a phenotype.")', '__("This observation can only be edited in relation to a trial.")', '__("You must supply an observation ID!")', '__("This function can edit existing phenotype entries, but not delete them. Please enter a value.")', '__("You do not have permission to make edits on this trial - only curators and trial owners can modify raw phenotype values.")' ] ],
    [ 'lib/SGN/Controller/AJAX/SamplingTrial.pm', 'SGN::Controller::AJAX::SamplingTrial', [ '__(\'You do not have the required privileges to create a sampling trial.\')', '__("Please provide all parameters in the basic sampling trial information section")', '__("Please provide number of replicates")', '__("Unknown location")', '__("Unknown breeding program")', '__("You must upload a sampling trial file!")', '__(\'Sampling trial name must be given!\')', '__("Uploaded file name must not contain spaces or slashes.")', '__(\'You must be logged in to upload sampling trial!\')', '__(\'You must be logged in to upload sampling trial!\')', '__("You have insufficient privileges to upload a sampling trial. Please contact us.")', '__(\'You must be logged in to upload sampling trial!\')', '__(\'You must be logged in to upload a sampling trial!\')', '__("You have insufficient privileges to upload a sampling trial.")', '__("Please provide all parameters in the sampling trial information section")', '__("Unknown location")', '__("Unknown breeding program")', '__("Successfully stored the sampling trial.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Seedlot.pm', 'SGN::Controller::AJAX::Seedlot', [ '__("You must be logged in to edit seedlot details")', '__("You do not have the correct role to edit seedlot detail. Please contact us.")', '__(\'The given seedlot uniquename has been taken. Please use another name or use the existing seedlot.\')', '__(\'The given accession name is not in the database! Seedlots can only be added onto existing accessions.\')', '__(\'The given cross name is not in the database! Seedlots can only be added onto existing crosses.\')', '__(\'A seedlot must have either an accession OR a cross as contents. Not both.\')', '__(\'A seedlot must have either an accession or a cross as contents.\')', '__("You must be logged in the delete seedlots")', '__("You do not have the correct role to delete seedlots. Please contact us.")', '__("You must be logged in the delete seedlots")', '__("You do not have the correct role to delete seedlots. Please contact us.")', '__("You must be logged in the delete seedlots")', '__("You do not have the correct role to delete seedlots. Please contact us.")', '__(\'You must be logged in to add a seedlot transaction!\')', '__("You do not have the correct submitter or curator role to add seedlots. Please contact us.")', '__(\'The given seedlot uniquename has been taken. Please use another name or use the existing seedlot.\')', '__(\'The accession name you provided does not match to a unique accession. Please make sure you are using the correct name or contact us.\')', '__(\'The cross name you provided does not match an existing cross name in the database.  Please make sure you are using the correct name or contact us.\')', '__(\'The given seedlot source name does not match an existing entry in the database. Seedlot sources must be an existing seedlot, plot, subplot, or plant name.\')', '__("Could not check seedlot source due to undefined source stock type")', '__(\'Unsupported seedlot source type\')', '__(\'The given accession name is not in the database! Seedlots can only be added onto existing accessions.\')', '__(\'The given cross name is not in the database! Seedlots can only be added onto existing crosses.\')', '__(\'A seedlot must have either an accession OR a cross as contents. Not both.\')', '__(\'A seedlot must have either an accession or a cross as contents.\')', '__(\'A seedlot must have a timestamp for the transaction.\')', '__(\'A seedlot must have a breeding program.\')', '__(\'You must be logged in to upload seedlots!\')', '__(\'You must be logged in to upload seedlots!\')', '__(\'Only a submitter or a curator can upload seedlots\')', '__(\'You must upload a seedlot file!\')', '__(\'You must be logged in to upload seedlot inventory!\')', '__(\'You must be logged in to upload seedlot inventory!\')', '__(\'Only a submitter or a curator can upload seedlot inventory\')', '__("You must be logged in to edit seedlot transactions")', '__("You do not have the correct role to edit seedlot transactions. Please contact us.")', '__("Something went wrong with the transaction update")', '__(\'You must be logged in to add a seedlot transaction!\')', '__(\'Only a submitter or a curator can add seedlot transaction\')', '__(\'The given seedlot uniquename has been taken. Please use another name or use the existing seedlot.\')', '__(\'The given accession name is not in the database! Seedlots can only be added onto existing accessions.\')', '__(\'The given cross name is not in the database! Seedlots can only be added onto existing crosses.\')', '__(\'A seedlot must have either an accession OR a cross as contents. Not both.\')', '__(\'A seedlot must have either an accession or a cross as contents.\')', '__("You must be logged in to delete seedlot transactions")', '__("You do not have the correct role to delete seedlot transactions. Please contact us.")', '__("An error occurred deleting the seedlot transaction")', '__(\'Seedlot Maintenance Events are not enabled on this server!\')', '__(\'You must be logged in to add a seedlot transaction!\')', '__(\'You do not have the required privileges to seedlot maintenance events.\')', '__(\'Event parameters not provided!\')', '__(\'You must be logged in to do this!\')', '__(\'You do not have permission in the database to do this! Please contact us.\')', '__(\'You must provide the upload file!\')', '__("An unknown error occurred")', '__("You must be logged in to discard seedlot")', '__("You do not have the correct role to discard seedlot. Please contact us.")', '__("Error discarding seedlot")', '__("You must be logged in to undo discading this seedlot")', '__("You do not have the correct role to undo discarding this seedlot. Please contact us.")', '__(\'You must be logged in to upload seedlots!\')', '__(\'You must be logged in to upload seedlots!\')', '__(\'Only a submitter or a curator can upload seedlot transactions\')', '__(\'You must upload a transaction file!\')', '__(\'You must be logged in to add seedlot transactions!\')', '__(\'Only a submitter or a curator can add seedlot transactions\')' ] ],
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
