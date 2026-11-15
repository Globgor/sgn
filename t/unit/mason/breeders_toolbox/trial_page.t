=head1 NAME

t/unit/mason/breeders_toolbox/trial_page.t - the trial detail page is shown in the user's language

=head1 DESCRIPTION

Renders mason/breeders_toolbox/trial.mas with HTML::Mason, the way
SGN::View::Mason sets it up (same preamble), once in English and once with a
Ukrainian catalog. Every component that the page calls is a stub that prints
its title and HTML arguments, except the page title, the sentence component
and the barcode block, which run as they are. No database or Catalyst context
is needed.

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
use SGN::Test::Anything;

my $page = '/breeders_toolbox/trial.mas';
my %real = map { $_ => 1 } qw( /page/page_title.mas /util/sentence.mas /page/detail_page_3_col_section.mas );

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
% for my $key ( grep { /title|subtitle|_html\z/ } sort keys %ARGS ) {
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

# Every argument without a default is a stand-in; the trial has a name.
my $declared = $interp->load($page)->declared_args;
my %arguments = map { substr( $_, 1 ) => SGN::Test::Anything->new }
    grep { !defined $declared->{$_}{default} && /\A\$/ } keys %{$declared};

sub render {
    $html = q{};
    $interp->exec( $page, %arguments, trial_name => 'Field 7', trial_stock_type => 'accession' );
    return $html;
}

setlocale( LC_MESSAGES, 'C' );
my $english = decode_entities( render() );
like( $english, qr{<h3 id="pagetitle_h3">Trial detail for Field 7</h3>},                      'English page title' );
like( $english, qr{info_section_title=<h4 style='display:inline'>Trial Details</h4>;},           'English section title' );
like( $english, qr{id="edit_trial_details" style="margin:3px">Edit Trial Details</button>},     'English header button' );
like( $english, qr{<h4>Generate barcode labels for plots or plants or accessions in this trial.</h4>}, 'English barcode title' );
like( $english, qr{>Label Designer \(Recommended\)</button>},                                  'English barcode button' );
like( $english, qr{info_section_subtitle=View and edit the spatial layout of the experiment\.},  'English layout subtitle' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $raw       = render();
my $ukrainian = decode_entities($raw);
like( $ukrainian, qr{<h3 id="pagetitle_h3">Дослід Field 7: відомості</h3>},                    'Ukrainian page title' );
like( $ukrainian, qr{info_section_title=<h4 style='display:inline'>Відомості про дослід</h4>;}, 'Ukrainian section title' );
like( $ukrainian, qr{id="edit_trial_details" style="margin:3px">Редагувати дані досліду</button>}, 'Ukrainian header button' );
like( $ukrainian, qr{<h4>Створити етикетки зі штрихкодом для ділянок, рослин або зразків цього досліду.</h4>}, 'Ukrainian barcode title' );
like( $ukrainian, qr{>Дизайнер етикеток \(рекомендовано\)</button>},                           'Ukrainian barcode button' );
like( $raw, qr{info_section_title=<h4 style='display:inline'>[^<>]*&lt;[^<>]*&gt;</h4>;},       'a section title is HTML-escaped' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
