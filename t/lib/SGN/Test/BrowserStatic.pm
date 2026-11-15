package SGN::Test::BrowserStatic;
use strict;
use warnings;
use Catalyst qw( Static::Simple );

# A real Static::Simple application without the SGN database or startup work.
sub default :Path {
    my ( $self, $c ) = @_;
    $c->res->status(404);
    $c->res->body('not found');
    return;
}

1;
