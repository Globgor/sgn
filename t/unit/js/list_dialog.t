use strict;
use warnings;
use Test::More;

plan skip_all => 'Node.js is not installed' unless grep { -x "$_/node" && !-d "$_/node" } split /:/, $ENV{PATH} // '';
is( system( 'node', 't/unit/js/list_dialog.js' ), 0, 'the lists dialog shows its texts in the page language' );
done_testing;
