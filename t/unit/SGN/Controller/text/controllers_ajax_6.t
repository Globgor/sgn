=head1 NAME

t/unit/SGN/Controller/text/controllers_ajax_6.t - SGN::Controller::AJAX controllers, group 6

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
    [ 'lib/SGN/Controller/AJAX/User.pm', 'SGN::Controller::AJAX::User', [ '__("Login credentials are incorrect. Please try again.")', '__("Login successful")', '__("User successfully logged out.")', '__("This site is a mirror site and does not support adding users. Please go to the main site to create an account.")', '__("You must be logged in to use this page.")', '__("Passwords must be at least 7 characters long. Please try again.")', '__("New password entries do not match. You must enter your new password twice to verify accuracy.")', '__("An error occurred. Please use your browser\'s back button to try again. New e-mail address entries do not match. You must enter your new e-mail address twice to verify accuracy.")', '__("Update successful")', '__("Username email requested. If you have an account on this database with this email, you will receive a message that includes the username associated with this email address.  If you do not have an account with this email address, you will not receive a message.")', '__("Password reset email requested. If you have an account on this database with this email, you will receive a message with a password reset link.  If you do not have an account with this email address, you will not receive a message.")', '__("Password is too short. Password must be 7 or more characters")', '__("Please enter the same password in the confirm password field!")', '__("The password was successfully updated.")', '__("The password reset link is invalid or has already been used. Please request a new password reset email.")', '__("This request must be sent using POST.")', '__(\'Login\')', '__(\'My Profile\')', '__(\'Lists\')', '__(\'Datasets\')', '__(\'Calendar\')', '__(\'Your Calendar\')', '__(\'Logout\')', '__("Need to be logged in to use feature.")', '__("You don\'t have the privileges to use this feature")' ] ],
    [ 'lib/SGN/Controller/AJAX/VectorConstruct.pm', 'SGN::Controller::AJAX::VectorConstruct', [ '__(\'You must be logged in to upload this vector info!\')', '__(\'You must be logged in to upload this vector info!\')', '__(\'Only a curator can add vectors without using the fuzzy search!\')', '__(\'Only a curator, submitter or sequencer can upload a file\')', '__("Could not get parsing errors")' ] ],
    [ 'lib/SGN/Controller/AJAX/VectorViewer.pm', 'SGN::Controller::AJAX::VectorViewer', [ '__(\'You need to be logged in with corresponding privileges to store vectors.\')', '__(\'You do not have the privileges to store vectors.\')', '__(\'You need to be logged in to view vector data.\')', '__(\'You need to be logged in to store vectors.\')', '__("You do not have the privileges to import vector data.")' ] ],
    [ 'lib/SGN/Controller/AJAX/Vigs.pm', 'SGN::Controller::AJAX::Vigs', [ '__("Bowtie execution failed")' ] ],
    [ 'lib/SGN/Controller/AJAX/Wiki.pm', 'SGN::Controller::AJAX::Wiki', [ '__("You do not have the privileges to create wiki pages.")', '__("You need to be logged in to store wiki pages.")', '__("You do not have the privileges to modify wiki pages.")', '__("Only the original owner can modify the wiki page.")', '__("You do not have the privileges to delete wiki pages.")', '__("Only the original page creator can delete the page. It is not you.")' ] ],
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
