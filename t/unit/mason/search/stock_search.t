=head1 NAME

t/unit/mason/search/stock_search.t - the accession and plot search page is shown in the user's language

=head1 DESCRIPTION

Renders mason/search/stocks.mas and the graphical filter it includes
(mason/search/stocks_graphicalfiltering.mas) with HTML::Mason, the way
SGN::View::Mason sets it up (same preamble), once in English and once with a
Ukrainian catalog. The shared frame components are replaced by stubs that
print their title and content, so no database or Catalyst context is needed.
The script of the page is rendered but not run.

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

sub Local::Context::user     { return }
sub Local::Context::config   { return {} }
sub Local::Context::get_conf { return 0 }
sub Local::Context::dbc      { return $_[0] }
sub Local::Context::dbh      { return }
sub CXGN::Login::new              { return bless( {}, 'CXGN::Login' ) }
sub CXGN::Login::get_login_cookie { return '' }

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
make_path("$stub_root/util", "$stub_root/page");
my %stubs = (
    'util/import_javascript.mas'          => '',
    'util/import_css.mas'                 => '',
    'page/info_section.mas'               => '[section: <% $ARGS{title} %>]<% $m->content %>',
    'page/detail_page_2_col_section.mas'  => '[two columns: <% $ARGS{info_section_subtitle} %>]',
);
for my $part ( keys %stubs ) {
    open( my $stub, '>', "$stub_root/$part" ) or die "Can't write the $part stub: $!";
    print {$stub} $stubs{$part};
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
    escape_flags     => { js => \&SGN::I18N::Browser::escape_js },
);
$interp->set_global( '$c' => bless( {}, 'Local::Context' ) );

sub render {
    $html = '';
    $interp->exec( '/search/stocks.mas',
        stock_types          => [ [ 1, 'accession' ], [ 2, 'plot' ] ],
        organisms            => [ [ 3, 'Zea mays' ] ],
        breeding_programs    => [ [ 4, 'Maize' ] ],
        editable_stock_props => [ 'organization' ] );
    $interp->exec('/search/stocks_graphicalfiltering.mas');
    return decode_entities($html);
}

setlocale( LC_MESSAGES, 'C' );
my $english = render();
like( $english, qr{<h3 id="pagetitle_h3">Search Accessions and Plots</h3>},  'English page title' );
like( $english, qr{\[section: Advanced Search\]},                            'English section title' );
like( $english, qr{placeholder="Type to Autocomplete"},                      'English placeholder' );
like( $english, qr{<th>Stock Name</th>},                                     'English column of the results' );
like( $english, qr{id="submit_stock_search" />Search</button>},              'English Search button' );
like( $english, qr{\[section: Copy Filtered Accessions to a List\]},         'English section of the graphical filter' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render();
like( $ukrainian, qr{<h3 id="pagetitle_h3">Пошук зразків і ділянок</h3>},   'Ukrainian page title' );
like( $ukrainian, qr{\[section: Розширений пошук\]},                         'Ukrainian section title' );
like( $ukrainian, qr{placeholder="Почніть вводити для підказки"},            'Ukrainian placeholder' );
like( $ukrainian, qr{<th>Назва зразка</th>},                                 'Ukrainian column of the results' );
like( $ukrainian, qr{id="submit_stock_search" />Пошук</button>},             'Ukrainian Search button' );
like( $ukrainian, qr{\[section: Копіювати відібрані зразки до списку\]},     'Ukrainian section of the graphical filter' );
setlocale( LC_MESSAGES, 'C' );

# The page title and the section titles are component arguments that are printed as HTML:
# a translation must reach the page escaped.
make_path("$locale_dir/es/LC_MESSAGES");
open( my $markup, '>:encoding(UTF-8)', "$locale_dir/markup.po" ) or die "Can't write the catalog: $!";
print {$markup} qq{msgid ""\nmsgstr "Content-Type: text/plain; charset=UTF-8\\n"\n\n},
    qq{msgid "Search Accessions and Plots"\nmsgstr "<b>A & B</b>"\n\nmsgid "Advanced Search"\nmsgstr "<i>C</i>"\n};
close $markup;
is( system( 'msgfmt', '-o', "$locale_dir/es/LC_MESSAGES/sgn.mo", "$locale_dir/markup.po" ), 0, 'catalog with markup compiled' );
ok( set_locale( LC_MESSAGES, 'es', undef, 'utf-8' ), 'second locale' );
my $shown   = render();
my $escaped = $html;    # the raw output, before the entities are decoded
like( $escaped, qr{<h3 id="pagetitle_h3">&lt;b&gt;A &amp; B&lt;/b&gt;</h3>}, 'markup in a translated page title is escaped' );
like( $escaped, qr{\[section: &lt;i&gt;C&lt;/i&gt;\]},                     'markup in a translated section title is escaped' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
