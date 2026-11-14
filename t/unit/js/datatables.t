use strict;
use warnings;
use Test::More;
use JSAN::ServerSide;

plan skip_all => 'Node.js is not installed' unless grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // '';
is( system( 'node', 't/unit/js/datatables.js' ), 0, 'DataTables controls follow the page language' );
my $jsan = JSAN::ServerSide->new( js_dir => 'js/source/legacy', uri_prefix => '/js/legacy' );
$jsan->add('jquery/dataTables');
$jsan->add('CXGN/TableLanguage');
my @uris = $jsan->uris;
my %index;
@index{@uris} = ( 0 .. $#uris );
cmp_ok( $index{'/js/legacy/CXGN/I18N.js'}, '<', $index{'/js/legacy/CXGN/TableLanguage.js'}, 'gettext loads before table defaults' );
cmp_ok( $index{'/js/legacy/jquery/dataTables.js'}, '<', $index{'/js/legacy/CXGN/TableLanguage.js'}, 'DataTables loads before table defaults' );
done_testing;
