use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use File::Temp qw( tempdir );
use HTML::Mason::Interp;
use JSON::PP ();
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES HUGE_VAL );
use Test::More;
use lib 't/lib';
use SGN::Test::MasonText qw( page_texts_ok );

use SGN::I18N::Browser ();

plan skip_all => 'Node.js is not installed' unless grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // '';
my $escape_flags = { js => \&SGN::I18N::Browser::escape_js };

my $dir = tempdir( CLEANUP => 1 );
my $html = '';
my $interp = HTML::Mason::Interp->new(
    comp_root => abs_path('mason'), data_dir => $dir, out_method => \$html,
    autohandler_name => '', escape_flags => $escape_flags,
    allow_globals => ['$c'], preamble => "use utf8; use Locale::TextDomain ( 'sgn', undef ); ",
);
sub Local::ScriptContext::config { return { require_login => 0 } }
$interp->set_global( '$c' => bless {}, 'Local::ScriptContext' );
$interp->exec('/site/toolbar/login.mas');
like( $html, qr/confirm\("Are you sure you want to log out\?"\)/, 'English confirmation keeps double quotes' );
is( scalar( () = $html =~ /alert\("An error occurred"\)/g ), 2, 'both English error callbacks use JSON strings' );

my @values = (q{It's "quoted"}, q{back\slash \n}, "real\nnewline", q{</script><script>window.pwned=1</script>}, q{<!-- <script> -->}, "line\x{2028}separator", "line\x{2029}separator", 'Ви впевнені?', 'a & b > c');
# Use a real overloaded object without declaring a package in the test.
use lib 't/lib';
use SGN::Test::Anything;
push @values, SGN::Test::Anything->new, 42, undef, HUGE_VAL();
my @expected = map { defined $_ ? "$_" : '' } @values;
my $component = $interp->make_component( comp_source => '<%args>$value</%args><script>values.push(<% $value |js %>);</script>' );
$html = '';
$interp->exec( $component, value => $_ ) for @values;
unlike( $html, qr{</script><script>window\.pwned|[\x{2028}\x{2029}]}, 'script terminators and line separators are escaped' );
my @scripts = $html =~ m{<script>(.*?)</script>}sg;
is( scalar @scripts, scalar @values, 'one script per value, no injected script' );
open( my $node, '>:encoding(UTF-8)', "$dir/check.js" ) or die $!;
print {$node} "const assert = require('node:assert/strict'); const values = [];\n", join("\n", @scripts), "\nassert.deepEqual(values, ", JSON::PP->new->encode(\@expected), ");\n";
close $node;
is( system( 'node', "$dir/check.js" ), 0, 'JavaScript receives every original value unchanged' );

page_texts_ok( '/site/toolbar/login.mas', 'Are you sure you want to log out?', 'An error occurred' );
ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'translated script locale' );
my $translated = SGN::Test::MasonText::render('/site/toolbar/login.mas');
like( $translated, qr/confirm\("«Are you sure you want to log out\?»"\)/, 'translated confirmation is inside the script' );
is( scalar( () = $translated =~ /alert\("«An error occurred»"\)/g ), 2, 'both error callbacks are translated inside the script' );
setlocale( LC_MESSAGES, 'C' );
done_testing;
