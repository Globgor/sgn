use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use JSON qw( encode_json );

BEGIN { sub SGN::path_to { shift; return join '/', '.', @_; } }
use SGN::Controller::JavaScript;
sub Local::TableContext::stash { return $_[0]->{stash}; }
my $dir = tempdir( CLEANUP => 1 );
open( my $mapping, '>', "$dir/mapping.json" ) or die $!;
print {$mapping} encode_json({ table_entry => {
    files => ['table_entry.min.js'], legacy => ['jquery.dataTables']
} });
close $mapping;
my $controller = SGN::Controller::JavaScript->new({
    js_path => $dir, js_legacy_path => 'js/source/legacy',
    dependency_json_path => "$dir/mapping.json",
});
for my $class ( 'jquery/dataTables', 'jquery/dataTables-min', 'CXGN/List' ) {
    my @uris = $controller->_resolve_jsan_dependencies([$class]);
    my @defaults = grep { /CXGN\/TableLanguage\.js$/ } @uris;
    is( scalar @defaults, $class eq 'CXGN/List' ? 0 : 1, "$class gets table defaults only if needed" );
    if (@defaults) {
        is( $uris[-1], $defaults[0], 'defaults follow both plugin and translation dependencies' );
    }
}
my $context = bless { stash => { jsan_classes => [], js_modules => ['table_entry'] } }, 'Local::TableContext';
$controller->resolve_javascript_classes($context);
my @uris = @{ $context->stash->{js_uris} };
is( $uris[-1], '/js/build/table_entry.min.js', 'entry runs after legacy dependencies' );
ok( scalar( grep { /CXGN\/TableLanguage\.js$/ } @uris ), 'entry-only page receives table translations' );
done_testing;
