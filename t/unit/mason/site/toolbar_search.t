=head1 NAME

t/unit/mason/site/toolbar_search.t - the quick search box is shown in the user's language

=head1 DESCRIPTION

Renders mason/site/toolbar/search.mas with HTML::Mason, the way SGN::View::Mason
sets it up (same preamble), once in English and once with a Ukrainian catalog.
No database or Catalyst context is needed.

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

sub Local::Context::config { return { enable_quick_search => 1 } }
sub Local::Context::user { return 1 }

# The preamble that SGN::View::Mason gives to every component.
open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
my ($preamble) = join( '', <$view> ) =~ /preamble\s*=>\s*"([^"]*)"/;
close $view;

my $locale_dir = tempdir( CLEANUP => 1 );
make_path("$locale_dir/uk/LC_MESSAGES");
is( system( 'msgfmt', '-o', "$locale_dir/uk/LC_MESSAGES/sgn.mo", 't/data/i18n/uk.po' ), 0, 'test catalog compiled' );

# A catalog that Locale::TextDomain would find by itself (LocaleData in @INC) must not win
# over the configured directory.
my $stray_dir = tempdir( CLEANUP => 1 );
make_path("$stray_dir/LocaleData/uk/LC_MESSAGES");
open( my $stray, '>:encoding(UTF-8)', "$stray_dir/stray.po" ) or die "Can't write the stray catalog: $!";
print {$stray} qq{msgid ""\nmsgstr "Content-Type: text/plain; charset=UTF-8\\n"\n\nmsgid "Advanced"\nmsgstr "STRAY"\n};
close $stray;
is( system( 'msgfmt', '-o', "$stray_dir/LocaleData/uk/LC_MESSAGES/sgn.mo", "$stray_dir/stray.po" ), 0, 'stray catalog compiled' );
unshift @INC, $stray_dir;

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
    $interp->exec('/site/toolbar/search.mas');
    return decode_entities($html);
}

setlocale( LC_MESSAGES, 'C' );
my $english = render();
like( $english, qr{>Advanced</span>},  'English label' );
like( $english, qr{title="Search"},    'English tooltip' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render();
like( $ukrainian, qr{>Розширений</span>}, 'Ukrainian label' );
like( $ukrainian, qr{title="Пошук"},      'Ukrainian tooltip' );
unlike( $ukrainian, qr{STRAY}, 'only the configured catalog directory is used' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
