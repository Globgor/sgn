=head1 NAME

t/unit/mason/site/toolbar_search_menu_about.t - the Search and About menus are shown in the user's language

=head1 DESCRIPTION

Renders mason/site/toolbar/search_menu.mas and mason/site/toolbar/about.mas
with HTML::Mason, the way SGN::View::Mason sets it up (same preamble), once in
English and once with a Ukrainian catalog. No database or Catalyst context is
needed.

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

sub Local::Context::config { return {} }

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

my @components = qw( /site/toolbar/search_menu.mas /site/toolbar/about.mas );

setlocale( LC_MESSAGES, 'C' );
my $english = render(@components);
like( $english, qr{>Search</a>},                                    'English Search menu' );
like( $english, qr{href="/breeders/search">Wizard</a>},             'English Wizard item' );
like( $english, qr{href="/search/bulk">Bulk Search</a>},            'English Bulk Search item' );
like( $english, qr{href="/contact/form">Contact</a>},               'English Contact item' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render(@components);
like( $ukrainian, qr{>Пошук</a>},                                   'Ukrainian Search menu' );
like( $ukrainian, qr{href="/breeders/search">Майстер</a>},          'Ukrainian Wizard item' );
like( $ukrainian, qr{href="/search/bulk">Пакетний пошук</a>},       'Ukrainian Bulk Search item' );
like( $ukrainian, qr{href="/contact/form">Контакти</a>},            'Ukrainian Contact item' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
