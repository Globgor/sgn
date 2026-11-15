use strict;
use warnings;

use Cwd qw( abs_path );
use HTML::Mason::Interp;
use File::Temp qw( tempdir );
use Test::More;

sub Local::BrowserContext::config { return $_[0]{config} }
sub Local::BrowserContext::stash { return $_[0]{stash} }
sub Local::BrowserContext::get_conf { return 0 }

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root => abs_path('mason'), data_dir => tempdir( CLEANUP => 1 ),
    out_method => \$html, autohandler_name => '', allow_globals => ['$c'],
    preamble => "use utf8; use Locale::TextDomain ( 'sgn', undef ); ",
);
sub render {
    my ( $language, $versions ) = @_;
    my $c = bless { config => { i18n_js_version => $versions }, stash => { language => $language } }, 'Local::BrowserContext';
    $interp->set_global( '$c' => $c );
    $html = '';
    $interp->exec('/site/header/head.mas');
    is( $c->stash->{jsan_classes}[0], 'CXGN.I18N', 'the glue is the first requested legacy class' );
    return $html;
}
my $uk = render( 'uk', { uk => 'abc123def456' } );
like( $uk, qr{<script type="text/javascript" src="/uk/sgn\.js\?v=abc123def456"></script>}, 'Ukrainian page loads its versioned catalog' );
like( $uk, qr{sgn\.js\?v=abc123def456.*INSERT_HEAD_POST_HTML}s, 'catalog precedes insertion of legacy scripts' );
unlike( render( 'en', { uk => 'abc123def456' } ), qr{/sgn\.js}, 'English has no catalog tag' );
unlike( render( undef, { uk => 'abc123def456' } ), qr{/sgn\.js}, 'off has no catalog tag' );
unlike( render( 'uk', {} ), qr{/sgn\.js}, 'server-only installation has no missing browser script' );
done_testing;
