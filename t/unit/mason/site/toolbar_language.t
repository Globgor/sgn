=head1 NAME

t/unit/mason/site/toolbar_language.t - the navigation bar offers the enabled languages

=head1 DESCRIPTION

Renders mason/site/toolbar.mas with HTML::Mason. The language menu
(mason/site/toolbar/language.mas) comes from the real component root; the
other parts of the bar are replaced by stubs, so no database or Catalyst
context is needed.

=cut

use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Entities qw( decode_entities );
use HTML::Mason::Interp;
use Test::More;

sub Local::Request::uri_with { return '/breeders/trials?lang=' . $_[1]{lang} }
sub Local::Context::i18n_languages { return @{ $_[0]{languages} } }
sub Local::Context::stash { return { language => $_[0]{language} } }
sub Local::Context::req { return bless {}, 'Local::Request' }

my $stub_root = tempdir( CLEANUP => 1 );
make_path("$stub_root/site/toolbar");
for my $part (qw( logo_and_name search_menu manage analyze about search login )) {
    open( my $stub, '>', "$stub_root/site/toolbar/$part.mas" ) or die "Can't write the $part stub: $!";
    print {$stub} "[$part]";
    close $stub;
}

open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
my ($preamble) = join( '', <$view> ) =~ /preamble\s*=>\s*"([^"]*)"/;
close $view;

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root        => [ [ stubs => $stub_root ], [ main => abs_path('mason') ] ],
    data_dir         => tempdir( CLEANUP => 1 ),
    out_method       => \$html,
    autohandler_name => '',
    allow_globals    => ['$c'],
    preamble         => $preamble,
);

sub render {
    my %context = @_;
    $html = '';
    $interp->set_global( '$c' => bless( {%context}, 'Local::Context' ) );
    $interp->exec('/site/toolbar.mas');
    return decode_entities($html);
}

my $bar = render( languages => [ 'uk', 'es' ], language => 'uk' );
like( $bar, qr{\[search\].*lang=uk.*\[login\]}s, 'the menu is between the search box and Login' );
like( $bar, qr{href="/breeders/trials\?lang=$_"}, "link to $_ keeps the current page" ) for qw( en uk es );
like( $bar, qr{lang="$_->[0]">\Q$_->[1]\E</a>}, "$_->[0]: the language's own name" ) for [ en => 'English' ], [ uk => 'українська' ], [ es => 'español' ];
like( $bar, qr{</span> українська <span}, 'current language is shown' );

$bar = render( languages => [ 'ar', 'tl' ], language => 'ar' );
like( $bar, qr{lang="ar">العربية</a>}, 'a right-to-left name' );
like( $bar, qr{</span> العربية <span}, 'current right-to-left language is shown' );
like( $bar, qr{lang="tl">Tagalog</a>}, 'English name of a language CLDR does not name' );

unlike( render( languages => [], language => undef ), qr{lang=|glyphicon-globe}, 'no menu when no language is enabled' );

done_testing;
