use strict;
use warnings;
use utf8;

use Digest::SHA qw( sha256_hex );
use File::Spec;
use File::Copy qw( copy );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use Locale::TextDomain ( 'sgn', undef );
use Moose::Meta::Class;
use Moose::Util qw( apply_all_roles );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

# A request and a response with only what the role reads and writes.
sub Local::Cookie::value     { return $_[0]{value} }
sub Local::Request::param    { return $_[0]{param}{ $_[1] } }
sub Local::Request::header   { return $_[0]{header}{ $_[1] } }
sub Local::Request::cookie   { my $value = $_[0]{cookie}{ $_[1] }; return defined $value ? bless( { value => $value }, 'Local::Cookie' ) : undef }
sub Local::Response::cookies { return $_[0]{cookies} }

# The smallest application the role can be applied to.
our %config;
sub Local::App::new            { my ( $class, %args ) = @_; return bless { res => bless( { cookies => {} }, 'Local::Response' ), stash => {}, %args }, $class }
sub Local::App::req            { return $_[0]{req} }
sub Local::App::res            { return $_[0]{res} }
sub Local::App::stash          { return $_[0]{stash} }
sub Local::App::config         { return \%config }
sub Local::App::path_to        { shift; return join '/', 'nowhere', @_ }
sub Local::App::setup_finalize { return }
sub Local::App::prepare        { return }
sub Local::App::finalize       { return }
sub Local::App::dispatch       { my $c = shift; return $c->stash->{page} = join ' | ', __('Search'), __p( 'verb', 'Search' ), __nx( '{count} trial', '{count} trials', 5, count => 5 ) }
apply_all_roles( Moose::Meta::Class->initialize('Local::App'), 'SGN::Role::Site::I18N' );

# One whole request, as Catalyst runs it: prepare, dispatch, finalize.
sub request {
    my %args = @_;
    Local::App->prepare;
    my $c = Local::App->new( req => bless( { param => { lang => $args{lang} }, cookie => { lang => $args{cookie} }, header => { 'Accept-Language' => $args{accept} } }, 'Local::Request' ) );
    $c->dispatch;
    my $locale_in_request = setlocale(LC_MESSAGES);
    $c->finalize;
    return ( $c->stash->{page}, $c->res->cookies->{lang}{value}, $c->stash->{language}, $locale_in_request );
}

my $english   = 'Search | Search | 5 trials';
my $ukrainian = 'Пошук | Шукати | 5 дослідів';

my $dir = tempdir( CLEANUP => 1 );
make_path("$dir/uk/LC_MESSAGES");
is( system( 'msgfmt', '-o', "$dir/uk/LC_MESSAGES/sgn.mo", 't/data/i18n/uk.po' ), 0, 'test catalog compiled' );

subtest 'off by default' => sub {
    my $locale = setlocale(LC_MESSAGES);
    local $ENV{LANGUAGE} = 'en_US.UTF-8';
    Local::App->setup_finalize;
    my ( $page, $cookie, $language ) = request( lang => 'uk', accept => 'uk' );
    is( $page,                 $english,      'English' );
    is( $cookie,               undef,         'no cookie' );
    is( $language,             undef,         'no language in the stash' );
    is( setlocale(LC_MESSAGES), $locale,      'process locale untouched' );
    is( $ENV{LANGUAGE},        'en_US.UTF-8', 'environment untouched' );
};

subtest 'a wrong setup stops the application' => sub {
    local %config = ( i18n_languages => 'uk, es', i18n_locale_dir => $dir );
    eval { Local::App->setup_finalize };
    like( $@, qr{no gettext catalog \Q$dir\E/es/LC_MESSAGES/sgn\.mo}, 'a missing catalog is reported' );

    make_path("$dir/es/LC_MESSAGES");
    open( my $not_a_catalog, '>', "$dir/es/LC_MESSAGES/sgn.mo" ) or die "Can't write the file: $!";
    print {$not_a_catalog} "not a gettext catalog\n";
    close $not_a_catalog;
    eval { Local::App->setup_finalize };
    like( $@, qr{no gettext catalog \Q$dir\E/es/LC_MESSAGES/sgn\.mo}, 'a file that is not a catalog is reported' );

    %config = ( i18n_languages => 'xx', i18n_locale_dir => $dir );
    eval { Local::App->setup_finalize };
    like( $@, qr/no system locale for 'xx'/, 'a language without a system locale is reported' );
};

subtest 'browser catalogs are optional until the first browser build' => sub {
    local %config = ( i18n_languages => 'uk', i18n_locale_dir => $dir );
    Local::App->setup_finalize;
    is_deeply( $config{i18n_js_version}, {}, 'server-only installation still starts' );
    make_path("$dir/ar");
    open( my $js, '>', "$dir/ar/sgn.js" ) or die $!;
    print {$js} "var sgn_locale_data = {};\n";
    close $js;
    eval { Local::App->setup_finalize };
    like( $@, qr{no browser catalog \Q$dir\E/uk/sgn\.js}, 'any browser build requires every configured browser catalog' );
    rename "$dir/ar/sgn.js", "$dir/uk/sgn.js" or die $!;
    Local::App->setup_finalize;
    is( $config{i18n_locale_dir}, $dir, 'resolved directory is shared through configuration' );
    is( $config{i18n_js_version}{uk}, substr( sha256_hex("var sgn_locale_data = {};\n"), 0, 12 ), 'cache version is the catalog content digest' );
    my $before = $config{i18n_js_version}{uk};
    my $mtime = ( stat "$dir/uk/sgn.js" )[9];
    open( my $changed, '>', "$dir/uk/sgn.js" ) or die $!;
    print {$changed} "var sgn_locale_data = {changed: true};\n";
    close $changed;
    utime $mtime, $mtime, "$dir/uk/sgn.js";
    Local::App->setup_finalize;
    isnt( $config{i18n_js_version}{uk}, $before, 'changed content has a new version even with the same mtime' );
};

subtest 'locale directory uses application home and literal path characters' => sub {
    my $home = tempdir( CLEANUP => 1 );
    my $relative = 'locale[review]{test}';
    my $locale = "$home/$relative";
    make_path("$locale/uk/LC_MESSAGES", "$locale/ar");
    copy( "$dir/uk/LC_MESSAGES/sgn.mo", "$locale/uk/LC_MESSAGES/sgn.mo" ) or die $!;
    open( my $js, '>', "$locale/ar/sgn.js" ) or die $!;
    print {$js} "var sgn_locale_data = {};\n";
    close $js;
    local %config = ( home => $home, i18n_languages => 'uk', i18n_locale_dir => $relative );
    eval { Local::App->setup_finalize };
    like( $@, qr{no browser catalog \Q$locale\E/uk/sgn\.js}, 'brackets and braces do not bypass startup validation' );
    is( $config{i18n_locale_dir}, $locale, 'relative locale path is resolved against application home' );
    rename "$locale/ar/sgn.js", "$locale/uk/sgn.js" or die $!;
    Local::App->setup_finalize;
    like( $config{i18n_js_version}{uk}, qr/\A[0-9a-f]{12}\z/, 'literal-path catalog gets its digest version' );
};

%config = ( i18n_languages => 'uk', i18n_locale_dir => $dir );
$ENV{LANGUAGE} = 'en_US.UTF-8';    # as in the Breedbase image
Local::App->setup_finalize;
is( Locale::Messages->select_package(''), 'gettext_pp', 'the pure-Perl catalog reader is used even when the XS one is installed' );

subtest 'language from the browser' => sub {
    is( ( request( accept => 'uk-UA' ) )[0],                   $ukrainian, 'regional tag' );
    is( ( request( accept => 'de, uk;q=0.8, en;q=0.5' ) )[0],  $ukrainian, 'first enabled language' );
    is( ( request( accept => 'en-US, uk;q=0.5' ) )[0],         $english,   'English preferred' );
    is( ( request( accept => 'uk;q=0, en' ) )[0],              $english,   'refused language' );
    is( ( request( accept => 'de' ) )[0],                      $english,   'not enabled' );
    is( ( request() )[0],                                      $english,   'no header' );
};

subtest 'explicit choice' => sub {
    my ( $page, $cookie, $language ) = request( lang => 'UK', accept => 'en' );
    is_deeply( [ $page, $cookie, $language ], [ $ukrainian, 'uk', 'uk' ], '?lang= wins and is remembered' );
    ( $page, $cookie ) = request( lang => 'en', cookie => 'uk', accept => 'uk' );
    is_deeply( [ $page, $cookie ], [ $english, 'en' ], 'back to English' );
    ( $page, $cookie ) = request( cookie => 'uk', accept => 'en' );
    is_deeply( [ $page, $cookie ], [ $ukrainian, undef ], 'cookie wins over the browser' );
    ( $page, $cookie ) = request( lang => 'bogus', cookie => 'xx', accept => 'uk' );
    is_deeply( [ $page, $cookie ], [ $ukrainian, undef ], 'unknown values are skipped and not saved' );
};

subtest 'nothing leaks between requests' => sub {
    my $locale_in_request = ( request( accept => 'uk' ) )[3];
    like( $locale_in_request, qr/^uk/, 'Ukrainian during the request' );
    is( setlocale(LC_MESSAGES), 'C', 'reset after the request' );
    is( ( request( accept => 'de' ) )[0], $english, 'next request is English' );
    is( $ENV{LANGUAGE}, undef, 'LANGUAGE does not override the locale' );

    # A request that dies before finalize must not decide the language of the next one.
    Local::App->new( req => bless( { header => { 'Accept-Language' => 'uk' } }, 'Local::Request' ) )->dispatch;
    like( setlocale(LC_MESSAGES), qr/^uk/, 'an unfinished request leaves its language behind' );
    Local::App->prepare;
    is( setlocale(LC_MESSAGES), 'C', 'the next request starts in English' );
};

done_testing;
