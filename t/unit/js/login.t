use strict;
use warnings;
use Test::More;
use JSAN::ServerSide;

plan skip_all => 'Node.js is not installed' unless grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // '';

is( system( 'node', 't/unit/js/login.js' ), 0, 'login dialogs and errors use translated text without changing callbacks' );
my $jsan = JSAN::ServerSide->new( js_dir => 'js/source/legacy', uri_prefix => '/js/legacy' );
$jsan->add('CXGN/Login');
is_deeply( [ $jsan->uris ], [ '/js/legacy/tannin_min.js', '/js/legacy/CXGN/I18N.js', '/js/legacy/CXGN/Login.js' ], 'login declares its translation dependency for pages without head.mas' );
done_testing;
