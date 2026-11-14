package SGN::Test::MasonText;

=head1 NAME

SGN::Test::MasonText - test that a Mason component shows its text in the user's language

=head1 SYNOPSIS

    use lib 't/lib';
    use SGN::Test::MasonText qw( page_texts_ok page_script_texts_ok component_compiles_ok );

    page_texts_ok( '/search/trials.mas', 'Search Trials', 'Trial name' );
    page_script_texts_ok( '/site/toolbar/login.mas', 'An error occurred' );
    component_compiles_ok('/breeders_toolbox/trial.mas');

=head1 DESCRIPTION

Renders components with HTML::Mason the way SGN::View::Mason sets it up (same
preamble), without a database or a Catalyst context: the context C<$c> and
every required argument are L<SGN::Test::Anything> objects.

C<page_texts_ok> renders the component twice. In English each text must be on
the page as it is. Then, with a catalog made for the test in which the
translation of C<Text> is C<«Text»>, each text must be there in that form. A
text that is not wrapped in C<__()> fails the second check.

C<page_script_texts_ok> checks JSON strings in rendered script blocks in both
languages. It checks the output of the Mason C<|js> escape, including the
escaping of characters that are unsafe in an HTML script block.

=cut

use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use Exporter qw( import );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Entities qw( decode_entities );
use HTML::Mason::Interp;
use JSON::PP ();
use SGN::I18N::Browser ();
use Locale::Messages qw( bindtextdomain bind_textdomain_codeset bind_textdomain_filter );
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

use SGN::Test::Anything;

our @EXPORT_OK = qw( page_texts_ok page_script_texts_ok page_sentences_ok component_compiles_ok render );

my $LANGUAGE = 'uk';    # any language with a system locale; the test catalog is made here
my $TIMEOUT  = 20;      # seconds; a component that loops on an Anything must not hang the test
my ( $interp, $html );

sub _interp {
    return $interp if $interp;
    open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
    my $source = join q{}, <$view>;
    my ($preamble) = $source =~ /preamble\s*=>\s*"([^"]*)"/;
    close $view;
    Locale::Messages->select_package('gettext_pp');
    delete $ENV{LANGUAGE};
    bind_textdomain_codeset( sgn => 'utf-8' );
    bind_textdomain_filter( sgn => \&Locale::Messages::turn_utf_8_on );
    $interp = HTML::Mason::Interp->new(
        comp_root        => abs_path('mason'),
        data_dir         => tempdir( CLEANUP => 1 ),
        out_method       => \$html,
        autohandler_name => q{},
        allow_globals    => ['$c'],
        preamble         => $preamble,
        escape_flags     => { js => \&SGN::I18N::Browser::escape_js },
    );
    $interp->set_global( '$c' => SGN::Test::Anything->new );
    return $interp;
}

# An Anything for every argument the component requires or leaves undefined: a list for @x,
# a hash for %x.
sub _arguments {
    my $component = shift;
    my $declared  = _interp()->load($component)->declared_args;
    my %arguments;
    for my $name ( keys %{$declared} ) {
        my $default = $declared->{$name}{default};
        next if defined $default && $default !~ /\A\s*undef\s*\z/;
        my ( $sigil, $key ) = $name =~ /\A(.)(.*)\z/;
        $arguments{$key} = $sigil eq q{@} ? [] : $sigil eq q{%} ? {} : SGN::Test::Anything->new;
    }
    return %arguments;
}

=head2 render( $component, %arguments )

The page of the component as text, with HTML entities decoded. Dies if the
component dies or does not finish in time.

=cut

sub _render_raw {
    my $component = shift;
    my %arguments = ( _arguments($component), @_ );
    $html = q{};
    local $SIG{ALRM} = sub { die "$component did not finish in $TIMEOUT seconds\n" };
    alarm $TIMEOUT;
    my $finished = eval { _interp()->exec( $component, %arguments ); 1 };
    alarm 0;
    die $@ if !$finished;
    return $html;
}

sub render {
    return scalar decode_entities( _render_raw(@_) );
}

# A catalog in which the translation of Text is «Text», compiled with msgfmt. Each call
# makes its own catalog directory: gettext keeps a catalog it has read once.
sub _use_catalog {
    my @texts = @_;
    my $translate = ref $texts[0] eq 'CODE' ? shift @texts : sub { return "«$_[0]»" };
    _interp();
    my $locale_dir = tempdir( CLEANUP => 1 );
    make_path("$locale_dir/$LANGUAGE/LC_MESSAGES");
    open( my $po, '>:encoding(UTF-8)', "$locale_dir/test.po" ) or die "Can't write the test catalog: $!";
    print {$po} qq{msgid ""\nmsgstr "Content-Type: text/plain; charset=UTF-8\\n"\n};
    for my $text (@texts) {
        my ( $quoted, $translation ) = map { s/(["\\])/\\$1/gr } $text, $translate->($text);
        print {$po} qq{\nmsgid "$quoted"\nmsgstr "$translation"\n};
    }
    close $po;
    system( 'msgfmt', '-o', "$locale_dir/$LANGUAGE/LC_MESSAGES/sgn.mo", "$locale_dir/test.po" ) == 0 or die "msgfmt failed\n";
    bindtextdomain( sgn => $locale_dir );
    return;
}

=head2 page_texts_ok( $component, @texts )

One test: the component shows every text in English, and every text in its
translated form when the language is not English.

=cut

sub page_texts_ok {
    my ( $component, @texts ) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    _use_catalog(@texts);
    setlocale( LC_MESSAGES, 'C' );
    my $english = eval { render($component) };
    my @problems = defined $english ? map { "English text is missing: $_" } grep { index( $english, $_ ) < 0 } @texts : ("does not render: $@");
    if ( !@problems ) {
        set_locale( LC_MESSAGES, $LANGUAGE, undef, 'utf-8' ) or push @problems, "no system locale for $LANGUAGE";
        my $translated = eval { render($component) } // q{};
        push @problems, map { "translated text is missing: $_" } grep { index( $translated, "«$_»" ) < 0 } @texts;
        setlocale( LC_MESSAGES, 'C' );
    }
    return ok( !@problems, "$component shows its text in the user's language" ) || diag( join "\n", @problems );
}

=head2 page_script_texts_ok( $component, @texts )

One test: each text appears as a JSON string in a rendered script block in
English and, with the test catalog, as its translated JSON string. A text
that is absent from the rendered page cannot be checked this way.

=cut

sub _script_has_text {
    my ( $page, $text ) = @_;
    my $json = JSON::PP->new->allow_nonref->encode($text);
    $json =~ s/([<>&\x{2028}\x{2029}])/sprintf '\\u%04x', ord $1/ge;
    while ( $page =~ m{<script\b[^>]*>(.*?)</script\s*>}sig ) {
        return 1 if index( $1, $json ) >= 0;
    }
    return 0;
}

sub page_script_texts_ok {
    my ( $component, @texts ) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    _use_catalog(@texts);
    setlocale( LC_MESSAGES, 'C' );
    my $english = eval { render($component) };
    my @problems = defined $english ? map { "English script text is missing: $_" } grep { !_script_has_text( $english, $_ ) } @texts : ("does not render: $@");
    if ( !@problems ) {
        set_locale( LC_MESSAGES, $LANGUAGE, undef, 'utf-8' ) or push @problems, "no system locale for $LANGUAGE";
        my $translated = eval { render($component) } // q{};
        push @problems, map { "translated script text is missing: $_" } grep { !_script_has_text( $translated, "«$_»" ) } @texts;
        setlocale( LC_MESSAGES, 'C' );
    }
    return ok( !@problems, "$component shows its script text in the user's language" ) || diag( join "\n", @problems );
}

# Remove actual tags before decoding entities, so escaped text such as &lt;x&gt;
# remains visible text rather than being mistaken for a tag.
sub _sentence_page {
    my ($page) = @_;
    $page =~ s/<[^>]*>//g;
    $page = decode_entities($page);
    $page =~ s/\s+/ /g;
    return $page;
}

# The test translation of a sentence: «Message», with every placeholder between ‹ and ›,
# so that a check sees where each value begins and ends.
sub _use_sentence_catalog {
    my @messages = @_;
    return _use_catalog( sub { my $message = shift; $message =~ s/(\{\w+\})/‹$1›/g; return "«$message»" }, @messages );
}

sub _sentence_shown {
    my ( $page, $message, $translated ) = @_;
    my @pieces = split /\{\w+\}/, $message, -1;
    s/\s+/ /g for @pieces;
    if ($translated) {
        my $pattern = '«' . join( '‹[^«»‹›]*›', map { quotemeta($_) } @pieces ) . '»';
        return $page =~ /$pattern/;
    }
    # In English a value may be empty: the spaces around it then collapse into one.
    for my $i ( 0 .. $#pieces ) {
        $pieces[$i] =~ s/\A // if $i > 0;
        $pieces[$i] =~ s/ \z// if $i < $#pieces;
    }
    my $pattern = join '.*?', map { quotemeta($_) } @pieces;
    return $page =~ /$pattern/s;
}

=head2 page_sentences_ok( $component, @messages )

One test: the page contains each message's literal pieces in order in English,
and the whole test translation of each message, with a value in each placeholder.

=cut

sub page_sentences_ok {
    my ( $component, @messages ) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    _use_sentence_catalog(@messages);
    setlocale( LC_MESSAGES, 'C' );
    my $english = eval { _sentence_page( _render_raw($component) ) };
    my @problems = defined $english
        ? map { "English sentence is missing: $_" } grep { !_sentence_shown( $english, $_, 0 ) } @messages
        : ("does not render: $@");
    if ( !@problems ) {
        set_locale( LC_MESSAGES, $LANGUAGE, undef, 'utf-8' ) or push @problems, "no system locale for $LANGUAGE";
        my $translated = eval { _sentence_page( _render_raw($component) ) };
        if ( defined $translated ) {
            push @problems, map { "translated sentence is missing: $_" }
                grep { !_sentence_shown( $translated, $_, 1 ) } @messages;
        }
        else {
            push @problems, "translated page does not render: $@";
        }
        setlocale( LC_MESSAGES, 'C' );
    }
    return ok( !@problems, "$component shows its sentences in the user's language" ) || diag( join "\n", @problems );
}

=head2 component_compiles_ok( $component )

One test: Mason can compile the component. For components that need real data to run.

=cut

sub component_compiles_ok {
    my $component = shift;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $compiled = eval { _interp()->load($component) };
    return ok( $compiled, "$component compiles" ) || diag($@);
}

1;
