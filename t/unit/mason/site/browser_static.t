use strict;
use warnings;

use File::Path qw( make_path );
use File::Temp qw( tempdir );
use Path::Class qw( dir );
use Test::More;
use lib 't/lib';
use SGN::Test::BrowserStatic;

use SGN::I18N::Browser ();
my $include_path = [ \&SGN::I18N::Browser::static_include_path ];
sub SGN::Test::BrowserStatic::i18n_languages { return shift->config->{i18n_languages} }
my $temp = tempdir( CLEANUP => 1 );
make_path( "$temp/static/css", "$temp/translations/locale/uk/LC_MESSAGES", "$temp/translations/po" );
for my $file (qw( static/css/site.css translations/locale/uk/sgn.js translations/locale/uk/LC_MESSAGES/sgn.mo translations/po/uk.po )) {
    open( my $fh, '>', "$temp/$file" ) or die $!;
    print {$fh} $file;
    close $fh;
}
SGN::Test::BrowserStatic->config(
    i18n_languages => 'uk',
    name => 'BrowserStatic', root => dir("$temp/static"),
    i18n_locale_dir => "$temp/translations/locale",
    'Plugin::Static::Simple' => {
        dirs => ['css'], include_path => $include_path,
        ignore_extensions => SGN::I18N::Browser::static_ignore_extensions(),
    },
);
SGN::Test::BrowserStatic->setup;
require Catalyst::Test;
Catalyst::Test->import('SGN::Test::BrowserStatic');
is( request('/css/site.css')->code, 200, 'the application static root still works' );
my $js = request('/uk/sgn.js');
is( $js->code, 200, 'the external locale directory serves the browser catalog' );
is( $js->content_type, 'application/javascript', 'the browser catalog has JavaScript MIME type' );
is( request('/po/uk.po')->code, 404, 'the translations source directory is not exposed' );
is( request('/uk/LC_MESSAGES/sgn.mo')->code, 404, 'the server catalog next to the browser catalog is not served' );
is( request('/es/sgn.js')->code, 404, 'a missing catalog is not served' );
SGN::Test::BrowserStatic->config->{i18n_languages} = '';
is_deeply( SGN::I18N::Browser::static_include_path('SGN::Test::BrowserStatic'),
    [ dir("$temp/static") ], 'off searches exactly the original application static root' );
is( request('/uk/sgn.js')->code, 404, 'off does not expose the configured locale directory' );
done_testing;
