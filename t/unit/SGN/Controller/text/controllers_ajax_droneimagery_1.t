=head1 NAME

t/unit/SGN/Controller/text/controllers_ajax_droneimagery_1.t - SGN::Controller::AJAX::DroneImagery controllers, group 1

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
    [ 'lib/SGN/Controller/AJAX/DroneImagery/DroneImageryUpload.pm', 'SGN::Controller::AJAX::DroneImagery::DroneImageryUpload', [ '__("Please use a globally unique drone run name! The name you specified has already ben used.")', '__("Please select a field trial!")', '__("Please give an imaging event vehicle id!")', '__("Please select an imaging event or create a new imaging event!")', '__("Please give a new imaging event type!")', '__("Please give a new imaging event date!")', '__("Please give a new imaging event date in the format YYYY/MM/DD HH:mm:ss!")', '__("Please give a new imaging event base date in the format YYYY/MM/DD HH:mm:ss!")', '__("Please give a new imaging event description!")', '__("Please indicate the type of camera!")', '__("Please give the number of new imaging event bands!")', '__("Please indicate if the images are stitched!")', '__("Please provide a zipfile of raw images!")', '__("Please provide a zipfile of images of the Micasense radiometric calibration panels!")', '__("There are already the maximum number of OpenDroneMap processes running on this machine! Please check back later when those processes are complete.")', '__("An imaging event has already occured on this field trial at the same date and time! Please give a unique date/time for each imaging event!")', '__("Please give a new imaging event band name!")', '__("Please give a new imaging event band description!")', '__("Please give a new imaging event band type!")', '__("Please provide a zipfile OR a stitched ortho image!")', '__("Please give a new imaging event band description!")', '__("Please give a new imaging event band type!")', '__("Please provide a zipfile OR a stitched ortho image!")', '__("Please provide a drone image zipfile of raw images to stitch!")', '__("Please provide a zipfile of images of the Micasense radiometric calibration panels!")', '__("Please provide a drone image zipfile of raw images to stitch!")', '__("Please provide a zipfile of images of the Micasense radiometric calibration panels!")', '__("Please provide a drone image zipfile of raw images!")', '__("Please provide a zipfile of images of the Micasense radiometric calibration panels!")', '__(\'You must be logged in to do this!\')', '__(\'You must be logged in to do this!\')' ] ],
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
