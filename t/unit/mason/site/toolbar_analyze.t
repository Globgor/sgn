=head1 NAME

t/unit/mason/site/toolbar_analyze.t - the Analyze menu is shown in the user's language

=head1 DESCRIPTION

Renders mason/site/toolbar/analyze.mas
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

my @components = qw( /site/toolbar/analyze.mas );

setlocale( LC_MESSAGES, 'C' );
my $english = render(@components);
like( $english, qr{>Analyze</a>}, "English Analyze menu" );
like( $english, qr{dropdown-header">Breeder Tools</li>}, "English Breeder Tools heading" );
like( $english, qr{href="/kinship/analysis">Kinship & Inbreeding</a>}, "English Kinship item" );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render(@components);
like( $ukrainian, qr{>Аналіз</a>}, "Ukrainian Analyze menu" );
like( $ukrainian, qr{dropdown-header">Інструменти селекціонера</li>}, "Ukrainian Breeder Tools heading" );
like( $ukrainian, qr{href="/kinship/analysis">Спорідненість та інбридинг</a>}, "Ukrainian Kinship item" );
setlocale( LC_MESSAGES, 'C' );

done_testing;
