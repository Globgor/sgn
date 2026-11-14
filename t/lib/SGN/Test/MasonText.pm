package SGN::Test::MasonText;

=head1 NAME

SGN::Test::MasonText - test that a Mason component shows its text in the user's language

=head1 SYNOPSIS

    use lib 't/lib';
    use SGN::Test::MasonText qw( page_texts_ok component_compiles_ok );

    page_texts_ok( '/search/trials.mas', 'Search Trials', 'Trial name' );
    component_compiles_ok('/breeders_toolbox/trial.mas');

=head1 DESCRIPTION

Renders components with HTML::Mason the way SGN::View::Mason sets it up (same
preamble), without a database or a Catalyst context: the context C<$c> and
every required argument are L<SGN::Test::Anything> objects.

C<page_texts_ok> renders the component twice. In English each text must be on
the page as it is. Then, with a catalog made for the test in which the
translation of C<Text> is C<«Text»>, each text must be there in that form. A
text that is not wrapped in C<__()> fails the second check.

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
use Locale::Messages qw( bindtextdomain bind_textdomain_codeset bind_textdomain_filter );
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

use SGN::Test::Anything;

our @EXPORT_OK = qw( page_texts_ok component_compiles_ok render );

my $LANGUAGE = 'uk';    # any language with a system locale; the test catalog is made here
my $TIMEOUT  = 20;      # seconds; a component that loops on an Anything must not hang the test
my ( $interp, $html );

sub _interp {
    return $interp if $interp;
    open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
    my ($preamble) = join( q{}, <$view> ) =~ /preamble\s*=>\s*"([^"]*)"/;
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

=head2 render( $component )

The page of the component as text, with HTML entities decoded. Dies if the
component dies or does not finish in time.

=cut

sub render {
    my $component = shift;
    my %arguments = _arguments($component);
    $html = q{};
    local $SIG{ALRM} = sub { die "$component did not finish in $TIMEOUT seconds\n" };
    alarm $TIMEOUT;
    my $finished = eval { _interp()->exec( $component, %arguments ); 1 };
    alarm 0;
    die $@ if !$finished;
    return scalar decode_entities($html);
}

# A catalog in which the translation of Text is «Text», compiled with msgfmt. Each call
# makes its own catalog directory: gettext keeps a catalog it has read once.
sub _use_catalog {
    my @texts = @_;
    _interp();
    my $locale_dir = tempdir( CLEANUP => 1 );
    make_path("$locale_dir/$LANGUAGE/LC_MESSAGES");
    open( my $po, '>:encoding(UTF-8)', "$locale_dir/test.po" ) or die "Can't write the test catalog: $!";
    print {$po} qq{msgid ""\nmsgstr "Content-Type: text/plain; charset=UTF-8\\n"\n};
    for my $text (@texts) {
        ( my $quoted = $text ) =~ s/(["\\])/\\$1/g;
        print {$po} qq{\nmsgid "$quoted"\nmsgstr "«$quoted»"\n};
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
