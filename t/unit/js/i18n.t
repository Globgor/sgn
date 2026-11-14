use strict;
use warnings;
use Test::More;
use JSAN::ServerSide;

plan skip_all => 'Node.js is not installed' unless grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // '';

is( system( 'node', 't/unit/js/i18n.js' ), 0, 'browser translation, plurals, context and English fallback' );
my $jsan = JSAN::ServerSide->new( js_dir => 'js/source/legacy', uri_prefix => '/js/legacy' );
$jsan->add('CXGN/I18N');
is_deeply( [ $jsan->uris ], [ '/js/legacy/tannin_min.js', '/js/legacy/CXGN/I18N.js' ], 'legacy resolver loads Tannin before the glue' );
done_testing;
