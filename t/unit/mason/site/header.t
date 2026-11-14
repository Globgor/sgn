=head1 NAME

t/unit/mason/site/header.t - the page tells the browser its language and direction

=head1 DESCRIPTION

Renders mason/site/header.mas with HTML::Mason, the way SGN::View::Mason sets
it up (same preamble), with the language that SGN::Role::Site::I18N puts in
the stash. The components that header.mas includes are replaced by stubs, so
no database or Catalyst context is needed.

=cut

use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Mason::Interp;
use Test::More;

sub Local::Context::stash { return { %{ $_[0] } } }

# The preamble that SGN::View::Mason gives to every component.
open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
my ($preamble) = join( '', <$view> ) =~ /preamble\s*=>\s*"([^"]*)"/;
close $view;

my $stub_root = tempdir( CLEANUP => 1 );
make_path("$stub_root/site/header");
for my $part (qw( site/header/head site/header/body cookie_popup )) {
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

# The <html> start tag of the page for a request in that language.
sub html_tag {
    my %stash = @_;
    $html = '';
    $interp->set_global( '$c' => bless( {%stash}, 'Local::Context' ) );
    $interp->exec('/site/header.mas');
    my ($tag) = $html =~ /(<html\b[^>]*>)/;
    return $tag;
}

like( do { html_tag(); $html }, qr{\[site/header/head\].*\[site/header/body\].*\[cookie_popup\]}s, 'the included components are the stubs' );
is( html_tag(),                    '<html>',                                     'no language enabled: no attributes' );
is( html_tag( language => 'en' ),  '<html lang="en" xml:lang="en">',             'English' );
is( html_tag( language => 'uk' ),  '<html lang="uk" xml:lang="uk">',             'Ukrainian, left to right' );
is( html_tag( language => 'ar' ),  '<html lang="ar" xml:lang="ar" dir="rtl">',   'Arabic, right to left' );
is( html_tag( language => 'he' ),  '<html lang="he" xml:lang="he" dir="rtl">',   'Hebrew, right to left' );
is( html_tag( language => 'fa' ),  '<html lang="fa" xml:lang="fa" dir="rtl">',   'Persian, right to left' );
is( html_tag( language => 'ur' ),  '<html lang="ur" xml:lang="ur" dir="rtl">',   'Urdu, right to left' );
is( html_tag( language => 'dv' ),  '<html lang="dv" xml:lang="dv" dir="rtl">',   'Divehi, right to left' );
is( html_tag( language => 'ar-EG' ), '<html lang="ar-EG" xml:lang="ar-EG" dir="rtl">', 'a regional tag follows its language' );
is( html_tag( language => 'tl' ),  '<html lang="tl" xml:lang="tl">',             'any other language stays left to right' );

done_testing;
