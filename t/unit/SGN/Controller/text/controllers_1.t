=head1 NAME

t/unit/SGN/Controller/text/controllers_1.t - SGN::Controller controllers, group 1

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
    [ 'lib/SGN/Controller/Analytics.pm', 'SGN::Controller::Analytics', [ '__(\'The requested analytics protocol ID does not exist in the database.\')' ] ],
    [ 'lib/SGN/Controller/Barcode.pm', 'SGN::Controller::Barcode', [ '__(\'You must be logged in to use the unique barcode tool.\')' ] ],
    [ 'lib/SGN/Controller/BreedingProgram.pm', 'SGN::Controller::BreedingProgram', [ '__("The requested breeding program does not exist or has been deleted.")' ] ],
    [ 'lib/SGN/Controller/Bulk.pm', 'SGN::Controller::Bulk', [ '__(\'Invalid data type chosen\')', '__(\'At least one identifier must be given\')', '__(\'Invalid data type\')', '__(\'At least one identifier must be given\')' ] ],
    [ 'lib/SGN/Controller/Catalog.pm', 'SGN::Controller::Catalog', [ '__(\'The requested catalog item does not exist.\')' ] ],
    [ 'lib/SGN/Controller/Cross.pm', 'SGN::Controller::Cross', [ '__(\'The requested cross does not exist.\')', '__(\'The requested family name does not exist.\')' ] ],
    [ 'lib/SGN/Controller/Dataset.pm', 'SGN::Controller::Dataset', [ '__("The requested dataset does not exist or has been deleted.")', '__("The selected service does not exist in the server configuration")' ] ],
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
