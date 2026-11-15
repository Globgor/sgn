=head1 NAME

t/unit/mason/search/search_tabs.t - the tabs of the search pages are shown in the user's language

=head1 DESCRIPTION

Renders a stand-in search page through mason/search/autohandler with
HTML::Mason, the way SGN::View::Mason sets it up (same preamble), once in
English and once with a Ukrainian catalog. The tabs come from the real
/page/mode_buttons.mas, which prints each label as HTML: the label must be
escaped where the autohandler passes it. The site frame is a stub.

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
use URI;

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
make_path("$stub_root/search");
my %stubs = (
    'autohandler'          => '<% $m->call_next %>',
    'search/tabs_test.mas' => '[search page]',
);
for my $part ( keys %stubs ) {
    open( my $stub, '>', "$stub_root/$part" ) or die "Can't write the $part stub: $!";
    print {$stub} $stubs{$part};
    close $stub;
}

# The request of the page: the Field Trials tab is the selected one.
sub Local::SearchTabs::Context::req { return bless {}, 'Local::SearchTabs::Request' }
sub Local::SearchTabs::Request::uri { return URI->new('/search/trials') }

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root        => [ [ stubs => $stub_root ], [ main => abs_path('mason') ] ],
    data_dir         => tempdir( CLEANUP => 1 ),
    out_method       => \$html,
    autohandler_name => 'autohandler',
    allow_globals    => ['$c'],
    preamble         => $preamble,
);
$interp->set_global( '$c' => bless {}, 'Local::SearchTabs::Context' );

sub render {
    $html = '';
    $interp->exec('/search/tabs_test.mas');
    return $html;
}

setlocale( LC_MESSAGES, 'C' );
my $english = render();
like( $english, qr{\[search page\]},                                 'the page is inside the tabs' );
like( $english, qr{location.href='/breeders/search';">Wizard</button>}, 'English Wizard tab' );
like( $english, qr{">Accessions and plots</button>},                  'English accession tab' );
like( $english, qr{">Progenies, Parents, Crosses</button>},           'English cross tab' );
like( $english, qr{">Genotyping Protocols</button>},                  'English genotyping protocol tab' );
like( $english, qr{<h3 id="pagetitle_h3">Search</h3>},                'English page title' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $raw       = render();
my $ukrainian = decode_entities($raw);
like( $ukrainian, qr{location.href='/breeders/search';">Майстер</button>},        'Ukrainian Wizard tab' );
like( $ukrainian, qr{">Зразки та ділянки</button>},                   'Ukrainian accession tab' );
like( $ukrainian, qr{">Нащадки, батьки, схрещування</button>},        'Ukrainian cross tab' );
like( $ukrainian, qr{">Протоколи генотипування</button>},             'Ukrainian genotyping protocol tab' );
like( $raw, qr{'/search/people';">[^<>]*&amp; &lt;[^<>]*&gt;</button>}, 'a tab label is HTML-escaped' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
