=head1 NAME

t/unit/mason/site/header_head.t - the search engine name the browser offers is in the user's language

=head1 DESCRIPTION

Renders mason/site/header/head.mas with HTML::Mason, the way SGN::View::Mason
sets it up (same preamble), once in English and once with a Ukrainian catalog.
The components that head.mas includes are replaced by stubs, so no database or
Catalyst context is needed.

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

my $stub_root = tempdir( CLEANUP => 1 );
make_path( "$stub_root/util", "$stub_root/site/header" );
for my $part (qw( util/import_css util/import_javascript site/header/local_head site/header/analytics )) {
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
    $interp->exec('/site/header/head.mas');
    return decode_entities($html);
}

setlocale( LC_MESSAGES, 'C' );
my $english = render();
like( $english, qr{\[util/import_css\].*\[site/header/analytics\]}s,                       'the included components are the stubs' );
like( $english, qr{opensearchdescription\+xml" title="Search Database" href=},             'English search engine name' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
like( render(), qr{opensearchdescription\+xml" title="Пошук у базі даних" href=},           'Ukrainian search engine name' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
