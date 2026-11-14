=head1 NAME

t/unit/mason/site/footer.t - the page footer and the working and progress windows are shown in the user's language

=head1 DESCRIPTION

Renders mason/site/footer/body.mas and mason/site/footer/common.mas with
HTML::Mason, the way SGN::View::Mason sets it up (same preamble), once in
English and once with a Ukrainian catalog. The components that common.mas
includes are replaced by stubs, so no database or Catalyst context is needed.

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

my $stub_root = tempdir( CLEANUP => 1 );
make_path("$stub_root/site", "$stub_root/calendar");
for my $part (qw( site/list site/dataset calendar/events_by_user_role site/login_dialog )) {
    open( my $stub, '>', "$stub_root/$part.mas" ) or die "Can't write the $part stub: $!";
    print {$stub} "[$part]";
    close $stub;
}

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root        => [ [ stubs => $stub_root ], [ main => abs_path('mason') ] ],
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

my @components = qw( /site/footer/body.mas /site/footer/common.mas );

setlocale( LC_MESSAGES, 'C' );
my $english = render(@components);
like( $english, qr{<strong>Version</strong>},         'English Version label' );
like( $english, qr{id="workingModalDialog">Working</h4>},   'English Working title' );
like( $english, qr{id="progressModalDialog">Progress</h4>}, 'English Progress title' );
like( $english, qr{\[site/login_dialog\]},             'the included components are the stubs' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render(@components);
like( $ukrainian, qr{<strong>Версія</strong>},         'Ukrainian Version label' );
like( $ukrainian, qr{id="workingModalDialog">Обробка</h4>},      'Ukrainian Working title' );
like( $ukrainian, qr{id="progressModalDialog">Хід виконання</h4>}, 'Ukrainian Progress title' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
