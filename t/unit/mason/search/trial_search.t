=head1 NAME

t/unit/mason/search/trial_search.t - the field trial search page is shown in the user's language

=head1 DESCRIPTION

Renders mason/search/trials.mas with HTML::Mason, the way SGN::View::Mason
sets it up (same preamble), once in English and once with a Ukrainian
catalog. The shared frame components are replaced by stubs that print their
title and content, so no database or Catalyst context is needed. The script
of the page is rendered but not run.

=cut

use strict;
use warnings;
use utf8;

use Cwd qw( abs_path );
use File::Path qw( make_path );
use File::Temp qw( tempdir );
use HTML::Entities qw( decode_entities );
use HTML::Mason::Interp;
use Locale::Messages qw( bindtextdomain bind_textdomain_codeset bind_textdomain_filter );
use Locale::Util qw( set_locale );
use POSIX qw( setlocale LC_MESSAGES );
use Test::More;

# The preamble that SGN::View::Mason gives to every component.
open( my $view, '<', 'lib/SGN/View/Mason.pm' ) or die "Can't read the Mason view: $!";
my ($preamble) = join( '', <$view> ) =~ /preamble\s*=>\s*"([^"]*)"/;
close $view;

my $locale_dir = tempdir( CLEANUP => 1 );
make_path("$locale_dir/uk/LC_MESSAGES");
is( system( 'msgfmt', '-o', "$locale_dir/uk/LC_MESSAGES/sgn.mo", 't/data/i18n/uk.po' ), 0, 'test catalog compiled' );

Locale::Messages->select_package('gettext_pp');
delete $ENV{LANGUAGE};
bindtextdomain( sgn => $locale_dir );
bind_textdomain_codeset( sgn => 'utf-8' );
bind_textdomain_filter( sgn => \&Locale::Messages::turn_utf_8_on );

my $stub_root = tempdir( CLEANUP => 1 );
make_path("$stub_root/util", "$stub_root/page");
my %stubs = (
    'util/import_javascript.mas' => '',
    'page/info_section.mas'      => '[section: <% $ARGS{title} %>]<% $m->content %>',
);
for my $part ( keys %stubs ) {
    open( my $stub, '>', "$stub_root/$part" ) or die "Can't write the $part stub: $!";
    print {$stub} $stubs{$part};
    close $stub;
}

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root        => [ [ stubs => $stub_root ], [ main => abs_path('mason') ] ],
    data_dir         => tempdir( CLEANUP => 1 ),
    out_method       => \$html,
    autohandler_name => '',
    preamble         => $preamble,
);

sub render {
    $html = '';
    $interp->exec( '/search/trials.mas', location_id => 'not_provided' );
    return decode_entities($html);
}

setlocale( LC_MESSAGES, 'C' );
my $english = render();
like( $english, qr{<h3 id="pagetitle_h3">Trial Search</h3>},          'English page title' );
like( $english, qr{<th>Breeding program</th>},                        'English column of the results' );
like( $english, qr{<th>Planting Date</th>},                           'English date column' );
like( $english, qr{\[section: Copy Results to a List\]},              'English section title' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render();
like( $ukrainian, qr{<h3 id="pagetitle_h3">Пошук дослідів</h3>},     'Ukrainian page title' );
like( $ukrainian, qr{<th>Селекційна програма</th>},                   'Ukrainian column of the results' );
like( $ukrainian, qr{<th>Дата посіву</th>},                           'Ukrainian date column' );
like( $ukrainian, qr{\[section: Копіювати результати до списку\]},   'Ukrainian section title' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
