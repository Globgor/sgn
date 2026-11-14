=head1 NAME

t/unit/mason/site/login.t - the login dialogs are shown in the user's language

=head1 DESCRIPTION

Renders mason/site/login_dialog.mas with HTML::Mason, the way SGN::View::Mason
sets it up (same preamble), once in English and once with a Ukrainian catalog.
The fake Catalyst context answers only the configuration keys the component
reads. The script of the component is rendered but not run.

=cut

use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Entities qw( decode_entities );
use HTML::Mason::Interp;
use Locale::Messages qw( bindtextdomain bind_textdomain_codeset bind_textdomain_filter );
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

sub Local::Context::config { return { require_login => 0 } }
sub Local::Context::get_conf { return 0 }

# The preamble that SGN::View::Mason gives to every component.
open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
my ($preamble) = join( '', <$view> ) =~ /preamble\s*=>\s*"([^"]*)"/;
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
);
$interp->set_global( '$c' => bless( {}, 'Local::Context' ) );

sub render {
    $html = '';
    $interp->exec($_) for @_;
    return decode_entities($html);
}

my @components = qw( /site/login_dialog.mas );

setlocale( LC_MESSAGES, 'C' );
my $english = render(@components);
like( $english, qr{tabindex="3">Login</button>},                                    'English Login button of the dialog' );
like( $english, qr{placeholder="Username"},                                         'English username placeholder' );
like( $english, qr{id="show_password"> Show Password},                              'English Show Password' );
like( $english, qr{>Forgot Username</h3>},                                          'English dialog title' );
like( $english, qr{<p style="padding-top: 7px">What is \d+ \+ \d+\?</p>},           'English question with a number' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render(@components);
like( $ukrainian, qr{tabindex="3">Увійти</button>},                                  'Ukrainian Login button of the dialog' );
like( $ukrainian, qr{placeholder="Ім'я користувача"},                                'Ukrainian username placeholder' );
like( $ukrainian, qr{id="show_password"> Показати пароль},                           'Ukrainian Show Password' );
like( $ukrainian, qr{>Забули ім'я користувача</h3>},                                 'Ukrainian dialog title' );
like( $ukrainian, qr{aria-label="Закрити"},                                          'Ukrainian close label' );
like( $ukrainian, qr{<p style="padding-top: 7px">Скільки буде \d+ \+ \d+\?</p>},     'Ukrainian question with a number' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
