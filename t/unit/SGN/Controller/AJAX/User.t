=head1 NAME

t/unit/SGN/Controller/AJAX/User.t - the Login button and the buttons of a logged-in user are shown in the user's language

=head1 DESCRIPTION

Calls the action behind /ajax/user/login_button_html with a fake Catalyst
context, once in English and once with a Ukrainian catalog. The controller
class loads without the application or a database, and the action does not
use the controller object; the fake context answers only what the action reads.

=cut

use strict;
use warnings;
use utf8;

use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Entities qw( decode_entities );
use Locale::Messages qw( bindtextdomain bind_textdomain_codeset bind_textdomain_filter );
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

use SGN::Controller::AJAX::User;

# A context with only what the action reads.
sub Local::Context::config        { return {} }
sub Local::Context::stash         { return $_[0]{stash} }
sub Local::Context::req           { return bless { path_query => $_[0]{path_query} }, 'Local::Request' }
sub Local::Context::user_exists   { return defined $_[0]{user} }
sub Local::Context::user          { return $_[0]{user} }
sub Local::Request::uri           { return $_[0] }
sub Local::Request::path_query    { return $_[0]{path_query} }
sub Local::User::get_object       { return $_[0] }
sub Local::User::get_sp_person_id { return 41 }
sub Local::User::get_username     { return 'jane' }

my $locale_dir = tempdir( CLEANUP => 1 );
make_path("$locale_dir/uk/LC_MESSAGES");
is( system( 'msgfmt', '-o', "$locale_dir/uk/LC_MESSAGES/sgn.mo", 't/data/i18n/uk.po' ), 0, 'test catalog compiled' );

Locale::Messages->select_package('gettext_pp');
delete $ENV{LANGUAGE};
bindtextdomain( sgn => $locale_dir );
bind_textdomain_codeset( sgn => 'utf-8' );
bind_textdomain_filter( sgn => \&Locale::Messages::turn_utf_8_on );

# The HTML the action returns, as sent and with the entities decoded.
sub buttons {
    my %request = ( path_query => '/breeders/trials', @_ );
    my $c = bless { stash => {}, %request }, 'Local::Context';
    SGN::Controller::AJAX::User->get_login_button_html($c);
    my $html = $c->stash->{rest}{html};
    return ( decode_entities($html), $html );
}

my $user = bless {}, 'Local::User';

setlocale( LC_MESSAGES, 'C' );
like( ( buttons() )[0],                               qr{position-absolute: 10,10,100,10">Login</button>}, 'English Login button' );
like( ( buttons( path_query => '/?logout=yes' ) )[0], qr{0px 0px">Login</button>\s*</a>},                    'English Login button after logout' );
my $english = ( buttons( user => $user ) )[0];
like( $english, qr{title="My Profile">jane</button>},                    'English profile title' );
like( $english, qr{title="Lists" onClick=.*>Lists</span>}s,               'English Lists' );
like( $english, qr{title="Datasets" onClick=.*>Datasets</span>}s,         'English Datasets' );
like( $english, qr{title="Your Calendar">\s*Calendar\x{a0}<span}s,        'English Calendar' );
like( $english, qr{title="Logout"></button>},                             'English Logout title' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
like( ( buttons() )[0],                               qr{position-absolute: 10,10,100,10">Увійти</button>}, 'Ukrainian Login button' );
like( ( buttons( path_query => '/?logout=yes' ) )[0], qr{0px 0px">Увійти</button>\s*</a>},                    'Ukrainian Login button after logout' );
my ( $ukrainian, $sent ) = buttons( user => $user );
like( $ukrainian, qr{title="Мій профіль">jane</button>},                  'Ukrainian profile title' );
like( $ukrainian, qr{title="Списки" onClick=.*>Списки</span>}s,           'Ukrainian Lists' );
like( $ukrainian, qr{title="Набори даних" onClick=.*>Набори даних</span>}s, 'Ukrainian Datasets' );
like( $ukrainian, qr{title="Ваш календар">\s*Календар\x{a0}<span}s,       'Ukrainian Calendar' );
like( $ukrainian, qr{title="Вийти"></button>},                            'Ukrainian Logout title' );
unlike( $sent, qr{[^\x00-\x7f]}, 'the translated texts are sent HTML-escaped' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
