=head1 NAME

t/unit/SGN/Controller/text/controllers_ajax_5.t - SGN::Controller::AJAX controllers, group 5

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
    [ 'lib/SGN/Controller/AJAX/SequencedAccessions.pm', 'SGN::Controller::AJAX::SequencedAccessions', [ '__("You need to be logged in to add sequencing information")', '__("You need to be logged in as a curator to submit this information")', '__("You don\'t own this entry so it cannot be deleted.")', '__("An error occurred during deletion.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Solgwas.pm', 'SGN::Controller::AJAX::Solgwas', [ '__("Can\'t find data.")' ] ],
    [ 'lib/SGN/Controller/AJAX/SpatialModel.pm', 'SGN::Controller::AJAX::SpatialModel', [ '__("Can\'t find data.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Stability.pm', 'SGN::Controller::AJAX::Stability', [ '__("Can\'t find data.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Stock.pm', 'SGN::Controller::AJAX::Stock', [ '__("Log in required for adding stock properties.")', '__("Synonym not added: The synonym you are adding is already stored as its own unique stock or as a synonym.")', '__(\'user does not have a curator/sequencer/submitter account\')', '__(\'Log in required for deletion of stock properties.\')', '__(\'The specified prop does not exist\')', '__("The element was removed from the database.")', '__("Nothing here, it\'s a POST..")', '__(\'Must be logged in for associating loci! \')', '__(\'need both valid stock_id and allele_id for adding the stockprop! \')', '__("Nothing here, it\'s a GET..")', '__(\'Must be logged in for associating ontology terms! \')', '__("Annotation exists with these evidence codes! ")', '__(\'need both valid stock_id and cvterm_id for adding an ontology term to this stock! \')', '__("No stock and parent specified")', '__("Log in is required, or insufficient privileges, for removing parents")', '__("You need to be logged in to add pedigree information.")', '__("you have insufficient privileges to add pedigree information.")', '__("Nothing here, it\'s a GET..")', '__(\'user does not have a curator/sequencer/submitter account\')', '__("Log in required for making stock obsolete.")', '__(\'Cannot obsolete stock! You do not have a curator, sequencer or submitter account\')', '__(\'You must be logged in to upload additional trials to a file!\')', '__(\'You must be logged in to upload additional files to a trial!\')', '__(\'You must be logged in to see uploaded additional files!\')', '__("You must be logged in to obsolete additional files!")', '__(\'Missing stock_id\')', '__(\'Missing image_id\')', '__(\'Stock not found\')', '__(\'Error setting display image\')', '__("Log in required for adding derived accessions.")', '__(\'Cannot add new accessions! You do not have a curator account\')', '__(\'You must be logged in to upload derived accessions!\')', '__(\'You must be logged in to upload derived accessions!\')', '__(\'Only a submitter or a curator can upload derived accessions\')', '__("You must be logged in to obsolete stocks")', '__("You need to be a curator or a submitter to obsolete stocks.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Transformation.pm', 'SGN::Controller::AJAX::Transformation', [ '__("you have insufficient privileges to add a transformation project.")', '__("Location not found")', '__("Error saving project")', '__("Error saving project")', '__("you have insufficient privileges to add a transformation ID.")', '__("Transformation ID already exists. Please use another name")', '__("Plant material does not exist or does not exist as accession uniquename.")', '__("vector construct does not exist or does not exist as vector construct uniquename.")', '__("Error generating tracking identifier")', '__(\'You must be logged in to upload transformation identifiers!\')', '__(\'You must be logged in to upload transformation identifiers!\')', '__(\'Only a submitter or a curator can upload transformation identifiers\')', '__("you have insufficient privileges to add new transformants.")', '__("Error generating transformant names")', '__("Error saving tracking information")', '__("You do not have sufficient privileges to add new transformants.")', '__("you have insufficient privileges to set autogenerated name format for this project.")', '__("you have insufficient privileges to set default plant material for this project.")', '__("Plant material does not exist or does not exist as accession uniquename.")', '__("You do not have the correct role to delete transformation ID. Please contact us.")', '__("you have insufficient privileges to set a control for this transformation ID.")', '__("you have insufficient privileges to set this transformation ID as a control.")', '__(\'You must be logged in to upload transgenic historical data!\')', '__(\'Only a submitter or a curator can upload transgenic historical data\')', '__(\'You must be logged in to upload transgenic historical data!\')', '__("Error! All accessions in the same file should have the same accession type (either an existing accession in the database or new accession).")', '__(\'You must be logged in to upload relative expression data!\')', '__(\'You must be logged in to upload relative expression data!\')', '__(\'Only a submitter or a curator can upload relative expression data\')', '__("you have insufficient privileges to edit this transformation metadata.")', '__(\'You must be logged in to upload transgenic lines!\')', '__(\'Only a submitter or a curator can upload transgenic lines\')', '__(\'You must be logged in to upload transgenic lines!\')' ] ],
    [ 'lib/SGN/Controller/AJAX/Trials.pm', 'SGN::Controller::AJAX::Trials', [ '__("Trial name required")', '__("Trial not found")' ] ],
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
