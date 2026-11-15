=head1 NAME

t/unit/SGN/Controller/text/pilot.t - Translate controller messages for lists, trials and analysis pages

=head1 DESCRIPTION

Each controller is required in a fresh Perl interpreter without an application
or database. A successful load must provide the __ translation function. If
loading fails, the test tries a separate Perl syntax check and reports the
load error. A syntax-only pass does not check that the module runs, loads in
the application, or has the function at runtime. The import and the original
translation calls per module are also checked in the source. These checks fail
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
    [ 'lib/SGN/Controller/AJAX/List.pm', 'SGN::Controller::AJAX::List', [ '__(\'You must be logged in to use lists.\')', '__("Only the list owner can change the type of a list")', '__("You must be logged in to use lists")', '__("You must be logged in to use lists.")', '__("You must be logged in to use lists.")', '__("You must provide an element to add to the list")', '__("Please specify a list_id.")', '__(\'You must be logged in to use lists and list must be public!\')', '__("You must provide one or more elements to add to the list")', '__(\'You need to be logged in to use lists.\')', '__("You have insufficient privileges to manipulate this list.")', '__(\'You must be logged in to use lists.\')', '__("You must be logged in to use marker alleles.")', '__(\'You must be logged in to delete marker alleles.\')', '__(\'You must be logged in to use marker alleles.\')', '__(\'You must be logged in to use marker alleles.\')', '__("You must be logged in to use lists.")', '__("You don\'t own this list and you cannot modify it.")', '__("Only lists with type \'accessions\' can be adjusted for case in the database.")', '__("No data!")', '__("You must be logged in to use lists.")', '__("You don\'t own this list and you cannot modify it.")', '__("Only lists with type \'accessions\' can be adjusted for synonyms in the database.")', '__("No data!")' ] ],
    [ 'lib/SGN/Controller/AJAX/Trial.pm', 'SGN::Controller::AJAX::Trial', [ '__("You need to select the starting plot number.")', '__("You need to provide name of check 1 for westcott design.")', '__("You need to provide name of check 2 for westcott design.")', '__("You need to provide number of columns for westcott design.")', '__("You need to provide at least one treatment for a splitplot design.")', '__("You need to provide number of plants per treatment for a splitplot design.")', '__("You need to provide number of plants per treatment for a splitplot design.")', '__("You need to provide number of rows for a resolvable row-column design.")', '__("You need to provide number of rows and cols for a unreplicated diagonal design.")', '__("You need to be logged in to add a trial")', '__("You have insufficient privileges to add a trial.")', '__("Treatment repeats do not equal number of plots in design")', '__("Trial location not found")', '__("No list of stocks supplied.")', '__("No design type supplied.")', '__("Design type not supported.")', '__("Could not generate design")', '__("You need to be logged in to add a trial")', '__("You have insufficient privileges to add a trial.")', '__("A folder or trial with that name already exists in the database. Please select another name.")', '__("Error saving trial activity info")', '__("No trial name supplied")', '__("No stock names supplied")', '__("No stock names supplied")', '__("No stock names supplied")', '__("Invalid plot name template.")', '__("Breeding program not found.")', '__("Uploaded file name must not contain spaces or slashes.")', '__("You need to be logged in to upload a trial.")', '__("You have insufficient privileges to upload a trial.")', '__(\'You must be logged in to upload soil data!\')', '__(\'You must be logged in to upload soil data!\')', '__(\'Only a submitter or a curator can upload soil data\')', '__("Could not get parsing errors")' ] ],
    [ 'lib/SGN/Controller/Analysis.pm', 'SGN::Controller::Analysis', [ '__(\'The requested analysis ID does not exist in the database or has been deleted.\')', '__(\'The requested model ID does not exist in the database.\')' ] ],
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
