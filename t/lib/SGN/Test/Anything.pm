package SGN::Test::Anything;

=head1 NAME

SGN::Test::Anything - a stand-in for any object, list or value in a test

=head1 DESCRIPTION

A Mason component asks its context for many things: C<< $c->config->{x} >>,
C<< $c->user->check_roles('curator') >>, a list of rows. To test only the text
of a component, a test does not need real answers. An object of this class
accepts every method call and answers with another such object. It is true,
prints as an empty string, counts as 0, and is an empty list, an empty hash
and a subroutine that returns such an object.

    my $c = SGN::Test::Anything->new;
    $c->user->get_object->get_username;    # no error, prints as ''

=cut

use strict;
use warnings;

our $AUTOLOAD;

use overload
    q{""}    => sub { return q{} },
    q{0+}    => sub { return 0 },
    q{bool}  => sub { return 1 },
    q{@{}}   => sub { return [] },
    q{%{}}   => sub { return {} },
    q{&{}}   => sub { my $self = shift; return sub { return $self } },
    fallback => 1;

sub new {
    my $class = shift;
    my $self  = \my $anything;
    return bless $self, ref $class || $class;
}

# In list context a method gives no rows, so loops over its result do not run.
sub AUTOLOAD {    ## no critic (ClassHierarchies::ProhibitAutoloading)
    my $self = shift;
    return if $AUTOLOAD =~ /::DESTROY\z/;
    return wantarray ? () : $self;
}

sub can { return 1 }

1;
