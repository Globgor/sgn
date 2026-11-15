=head1 NAME

t/unit/mason/site/toolbar_login.t - the Login button shown while the page loads is in the user's language

=head1 DESCRIPTION

Renders mason/site/toolbar/login.mas with HTML::Mason, the way SGN::View::Mason
sets it up (same preamble), once in English and once with a Ukrainian catalog.
The script of the component is rendered but not run.

=cut

use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Entities qw( decode_entities );
use HTML::Mason::Interp;
use SGN::I18N::Browser ();
use Locale::Messages qw( bindtextdomain bind_textdomain_codeset bind_textdomain_filter );
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

sub Local::Context::config { return { require_login => 0 } }

# The preamble that SGN::View::Mason gives to every component.
open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
my $source = join q{}, <$view>;
my ($preamble) = $source =~ /preamble\s*=>\s*"([^"]*)"/;
close $view;

my $locale_dir = tempdir( CLEANUP => 1 );
make_path("$locale_dir/uk/LC_MESSAGES");
is( system( 'msgfmt', '-o', "$locale_dir/uk/LC_MESSAGES/sgn.mo", 't/data/i18n/uk.po' ), 0, 'test catalog compiled' );

Locale::Messages->select_package('gettext_pp');
delete $ENV{LANGUAGE};
bindtextdomain( sgn => $locale_dir );
bind_textdomain_codeset( sgn => 'utf-8' );
bind_textdomain_filter( sgn => \&Locale::Messages::turn_utf_8_on );

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root        => abs_path('mason'),
    data_dir         => tempdir( CLEANUP => 1 ),
    out_method       => \$html,
    autohandler_name => '',
    allow_globals    => ['$c'],
    preamble         => $preamble,
    escape_flags     => { js => \&SGN::I18N::Browser::escape_js },
);
$interp->set_global( '$c' => bless( {}, 'Local::Context' ) );

sub render {
    $html = '';
    $interp->exec('/site/toolbar/login.mas');
    return decode_entities($html);
}

setlocale( LC_MESSAGES, 'C' );
like( render(), qr{<button class="btn btn-primary disabled" type="button" style="margin: 7px 7px 0px 0px">Login</button></span>}, 'English Login button' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
like( render(), qr{<button class="btn btn-primary disabled" type="button" style="margin: 7px 7px 0px 0px">Увійти</button></span>}, 'Ukrainian Login button' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
