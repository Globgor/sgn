=head1 NAME

t/unit/mason/stock/stock_page.t - the stock detail page is shown in the user's language

=head1 DESCRIPTION

Renders mason/stock/index.mas for an accession with HTML::Mason, the way
SGN::View::Mason sets it up (same preamble), once in English and once with a
Ukrainian catalog. Every component that the page calls is a stub that prints
its title and HTML arguments, except the page title, which runs as it is.
The stock has no editors or relations and its image is a stand-in, so no
database or Catalyst context is needed. The page script is rendered but not run.

=cut

use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use File::Basename qw( dirname );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Entities qw( decode_entities );
use HTML::Mason::Interp;
use Locale::Messages qw( bindtextdomain bind_textdomain_codeset bind_textdomain_filter );
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

use lib 't/lib';
use SGN::I18N::Browser ();
use SGN::Image ();
use SGN::Test::Anything;

my $page = '/stock/index.mas';
my %real = map { $_ => 1 } qw( /page/page_title.mas );

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

# A stub for each component that the page calls: it prints the arguments that hold text.
open( my $in, '<', "mason$page" ) or die "Can't read the page: $!";
my $source = join q{}, <$in>;
close $in;
my %called = map { $_ => 1 } $source =~ m{<&\|?\s*(/[\w/.]+?\.mas)}g;
my $stub_root = tempdir( CLEANUP => 1 );
my $stub = <<'STUB';
[<% $m->current_comp->path %>:
% for my $key ( grep { /title|subtitle|_html\z|_link\z/ } sort keys %ARGS ) {
 <% $key %>=<% $ARGS{$key} %>;
% }
]<% $m->has_content ? $m->content : '' %>
<%method step><% $m->content %></%method>
STUB
for my $component ( grep { !$real{$_} } keys %called ) {
    make_path( dirname("$stub_root$component") );
    open( my $out, '>', "$stub_root$component" ) or die "Can't write the $component stub: $!";
    print {$out} $stub;
    close $out;
}

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root        => [ [ stubs => $stub_root ], [ main => abs_path('mason') ] ],
    data_dir         => tempdir( CLEANUP => 1 ),
    out_method       => \$html,
    autohandler_name => q{},
    allow_globals    => ['$c'],
    preamble         => $preamble,
    escape_flags     => { js => \&SGN::I18N::Browser::escape_js },
);
$interp->set_global( '$c' => SGN::Test::Anything->new );

# An accession without editors or relations, seen by a curator.
sub Local::StockPage::Row::type  { return bless {}, 'Local::StockPage::Type' }
sub Local::StockPage::Type::name { return 'accession' }
# A schema whose database handle is one value also in list context.
sub Local::StockPage::Schema::storage   { return bless {}, 'Local::StockPage::Storage' }
sub Local::StockPage::Schema::resultset { return SGN::Test::Anything->new }
sub Local::StockPage::Storage::dbh      { return SGN::Test::Anything->new }
my %stockref = ( stock => SGN::Test::Anything->new, stock_id => 42, schema => bless( {}, 'Local::StockPage::Schema' ),
    dbh => SGN::Test::Anything->new, curator => 1, editable_stock_props => q{}, props => {}, editor_info => [], owners => [] );

sub render {
    $html = q{};
    # The image of the stock comes from the database: a stand-in here.
    no warnings 'redefine';
    local *SGN::Image::new = sub { return SGN::Test::Anything->new };
    $interp->exec( $page, stock_row => bless( {}, 'Local::StockPage::Row' ), stockref => \%stockref );
    return $html;
}

setlocale( LC_MESSAGES, 'C' );
my $english = decode_entities( render() );
like( $english, qr{info_section_title=<h4 style='display:inline'>Experiment Usage</h4>;},                'English section title' );
like( $english, qr{<thead><tr><th>Editor</th><th>Timestamp</th><th>Modification Note</th></tr></thead>}, 'English editor table' );
like( $english, qr{id="stock_add_synonym" >Add Synonym</button>},                                       'English header button' );
like( $english, qr{id="toggle_qr_code" [^>]*>Show QR Code</button>},                                    'English QR code button' );
like( $english, qr{jQuery\(this\).text\("Hide QR Code"\)},                                             'English QR code script' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $raw       = render();
my $ukrainian = decode_entities($raw);
like( $ukrainian, qr{info_section_title=<h4 style='display:inline'>Використання в експериментах</h4>;},   'Ukrainian section title' );
like( $ukrainian, qr{<thead><tr><th>Редактор</th><th>Час</th><th>Примітка до зміни</th></tr></thead>},   'Ukrainian editor table' );
like( $ukrainian, qr{id="stock_add_synonym" >Додати синонім</button>},                                    'Ukrainian header button' );
like( $ukrainian, qr{id="toggle_qr_code" [^>]*>Показати QR-код</button>},                                 'Ukrainian QR code button' );
like( $ukrainian, qr{jQuery\(this\).text\("Приховати QR-код"\)},                                      'Ukrainian QR code script' );
like( $raw, qr{info_section_title=<h4 style='display:inline'>[^<>]*&lt;[^<>]*&gt;</h4>;},                'a section title is HTML-escaped' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
