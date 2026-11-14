use strict;
use warnings;
use JSON::PP ();
use File::Temp qw( tempdir );
use Test::More;
use lib 't/lib';
use SGN::Test::Anything;
use SGN::I18N::Browser ();

for my $input ( SGN::Test::Anything->new, 42, undef ) {
    my $value = $input;
    my $expected = defined $value ? "$value" : '';
    SGN::I18N::Browser::escape_js(\$value);
    like( $value, qr/\A".*"\z/s, 'the escape always emits a quoted string' );
    is( JSON::PP->new->decode($value), $expected, 'the escape stringifies the original value' );
}

my $empty_path = tempdir( CLEANUP => 1 );
for my $test (qw( t/unit/js/i18n.t t/unit/js/login.t t/unit/mason/site/login_script.t )) {
    local $ENV{PATH} = $empty_path;
    open( my $child, '-|', $^X, '-Ilib', $test ) or die $!;
    my $output = do { local $/; <$child> };
    close $child;
    is( $?, 0, "$test exits successfully without Node.js" );
    like( $output, qr/1\.\.0 # SKIP Node\.js is not installed/, "$test explains the skipped Node.js test" );
}
done_testing;
