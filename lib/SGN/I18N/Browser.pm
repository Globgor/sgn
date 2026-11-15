package SGN::I18N::Browser;
use strict;
use warnings;
use JSON::PP ();

=head1 NAME

SGN::I18N::Browser - browser helpers usable without starting the application

=head1 DESCRIPTION

The Mason view and unit tests share these functions.
Keeping them independent of SGN startup allows tests to call production code.

=cut

my $json = JSON::PP->new->allow_nonref;

sub escape_js {
    my ($value) = @_;
    my $text = defined $$value ? "$$value" : '';
    $$value = $json->encode($text)
        =~ s/([<>&\x{2028}\x{2029}])/sprintf '\\u%04x', ord $1/ger;
    return;
}

1;
