=head1 NAME

t/unit/mason/homepage/home_page.t - the text of the home page is shown in the user's language

=head1 DESCRIPTION

Renders the home page for a visitor (mason/index.mas, with the list of
uploaded phenotype files) and for a logged-in user
(mason/index_logged_in_user.mas) with HTML::Mason, the way SGN::View::Mason
sets it up (same preamble), once in English and once with a Ukrainian
catalog. The section frame (page/info_section.mas) is replaced by a stub that
prints its content, so no database or Catalyst context is needed.

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
make_path("$stub_root/page");
open( my $stub, '>', "$stub_root/page/info_section.mas" ) or die "Can't write the info_section stub: $!";
print {$stub} '[page/info_section.mas]<% $m->content %>';
close $stub;

my $html;
my $interp = HTML::Mason::Interp->new(
    comp_root        => [ [ stubs => $stub_root ], [ main => abs_path('mason') ] ],
    data_dir         => tempdir( CLEANUP => 1 ),
    out_method       => \$html,
    autohandler_name => '',
    allow_globals    => ['$c'],
    preamble         => $preamble,
);

my @uploads = ( { metadata => [ 7, '2026-11-14', 3, 'jdoe', 'yield.xlsx', '/tmp', 'spreadsheet', 11 ], project_ids => { 11 => 'Trial A' } } );

sub render {
    $html = '';
    $interp->exec( '/index.mas', schema => undef, phenotype_files => \@uploads );
    $interp->exec( '/index_logged_in_user.mas',
        map( { $_ => '' } qw( schema static_content_path username first_name last_name sp_person_id timestamp ) ),
        role => 'curator' );
    return decode_entities($html);
}

setlocale( LC_MESSAGES, 'C' );
my $english = render();
like( $english, qr{<h3>What is Breedbase\?</h3>},                'English heading of the visitor page' );
like( $english, qr{<div class="panel-heading">Phenotype Files Uploaded</div>}, 'English title of the uploaded files' );
like( $english, qr{\nInterval:\x{a0}\n},                         'English interval label' );
like( $english, qr{<th>Trial Type</th>},                         'English column of the recent trials' );
like( $english, qr{\[page/info_section\.mas\]},                  'the section frame is the stub' );

ok( set_locale( LC_MESSAGES, 'uk', undef, 'utf-8' ), 'Ukrainian locale' );
my $ukrainian = render();
like( $ukrainian, qr{<h3>Що таке Breedbase\?</h3>},              'Ukrainian heading of the visitor page' );
like( $ukrainian, qr{<div class="panel-heading">Завантажені файли фенотипів</div>}, 'Ukrainian title of the uploaded files' );
like( $ukrainian, qr{\nІнтервал:\x{a0}\n},                       'Ukrainian interval label' );
like( $ukrainian, qr{<th>Тип досліду</th>},                      'Ukrainian column of the recent trials' );
setlocale( LC_MESSAGES, 'C' );

done_testing;
