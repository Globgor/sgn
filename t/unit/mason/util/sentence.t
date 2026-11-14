=head1 NAME

t/unit/mason/util/sentence.t - translated sentences preserve markup and values

=cut

use strict;
use warnings;
use utf8;
use lib 't/lib';
use Test::More;
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use Locale::Messages qw( bindtextdomain );
use Locale::TextDomain 'sgn';
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use SGN::Test::MasonText qw( render );

setlocale( LC_MESSAGES, 'C' );
is( render( '/util/sentence.mas', text => 'Hello {name}.', name => 'Alex' ), 'Hello Alex.', 'explicit value wins over generated arguments' );
is( render( '/util/sentence.mas', text => '{link}Help{end_link}', link => '<a href="/help">', end_link => '</a>' ), '<a href="/help">Help</a>', 'markup arguments remain markup' );
is( render( '/util/sentence.mas', text => 'Value: {value}.', value => undef ), 'Value: .', 'undefined value becomes empty' );
is( render( '/util/sentence.mas', text => 'Unknown {missing}.' ), 'Unknown {missing}.', 'missing argument remains visible' );
is( render( '/util/sentence.mas', text => '{value}', value => '{missing}' ), '{missing}', 'substitution is not recursive' );

# Use a real test catalog, as MasonText::_use_catalog does, with a reordered translation.
my $interp = SGN::Test::MasonText::_interp();
my $locale_dir = tempdir( CLEANUP => 1 );
make_path("$locale_dir/uk/LC_MESSAGES");
open( my $po, '>:encoding(UTF-8)', "$locale_dir/test.po" ) or die "Cannot write catalog: $!";
print {$po} <<'PO';
msgid ""
msgstr "Content-Type: text/plain; charset=UTF-8\n"

msgid "Read {link}help{end_link} for {name}: {count}."
msgstr "{name}: {count}. Read {link}translated help{end_link} < &."
PO
close $po;
system( 'msgfmt', '-o', "$locale_dir/uk/LC_MESSAGES/sgn.mo", "$locale_dir/test.po" ) == 0 or die "msgfmt failed\n";
bindtextdomain( sgn => $locale_dir );
set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ) or die "No uk locale\n";
my $raw = SGN::Test::MasonText::_render_raw(
    '/util/sentence.mas',
    text => __x('Read {link}help{end_link} for {name}: {count}.'),
    link => '<a href="/help">', end_link => '</a>', name => 'Alex', count => 3,
);
is( $raw, 'Alex: 3. Read <a href="/help">translated help</a> &lt; &amp;.', 'translation reorders placeholders, escapes text and preserves markup and value' );
setlocale( LC_MESSAGES, 'C' );
is( SGN::Test::MasonText::_render_raw( '/util/sentence.mas', text => '{value}', value => '<b>&</b>' ), '<b>&</b>', 'raw values keep their original escaping' );
is( SGN::Test::MasonText::_render_raw( '/util/sentence.mas', text => '{value}', value => $interp->apply_escapes( '<b>&</b>', 'h' ) ), '&lt;b&gt;&amp;&lt;/b&gt;', 'caller can preserve an HTML-escaped value' );
done_testing;
