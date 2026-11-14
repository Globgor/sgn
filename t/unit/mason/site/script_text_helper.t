use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/lib';
use SGN::Test::MasonText qw( page_script_texts_ok );
use SGN::I18N::Browser ();

page_script_texts_ok( '/site/toolbar/login.mas', 'An error occurred', 'Are you sure you want to log out?' );
for my $text ( q{It's "quoted"}, 'a & b > c', "line\x{2028}separator", '«Translated»' ) {
    my $json = $text;
    SGN::I18N::Browser::escape_js(\$json);
    ok( SGN::Test::MasonText::_script_has_text( "<script>alert($json)</script>", $text ), 'finds JSON string inside script' );
    ok( !SGN::Test::MasonText::_script_has_text( "<p>$json</p><script>alert(0)</script>", $text ), 'HTML text does not satisfy script assertion' );
}
done_testing;
