use strict;
use warnings;
use Test::More;
use JSAN::ServerSide;

plan skip_all => 'Node.js is not installed' unless grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // '';
is( system( 'node', 't/unit/js/pilot_messages.js', '.', 'trial' ), 0, 'Trial messages follow the page language and preserve data' );
my $jsan = JSAN::ServerSide->new( js_dir => 'js/source/legacy', uri_prefix => '/js/legacy' );
$jsan->add('CXGN/Trial');
my @uris = $jsan->uris;
is( $uris[0], '/js/legacy/tannin_min.js', 'Trial loads Tannin' );
is( $uris[1], '/js/legacy/CXGN/I18N.js', 'Trial loads gettext before messages' );
done_testing;
