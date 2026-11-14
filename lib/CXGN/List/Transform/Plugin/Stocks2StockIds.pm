package CXGN::List::Transform::Plugin::Stocks2StockIds;

use Moose;

sub name {
    return "stocks_2_stock_ids";
}

sub display_name {
    return "stocks to stock IDs";
}

sub can_transform {
    my $self = shift;
    my $type1 = shift;
    my $type2 = shift;

    if (($type1 eq "stocks") and ($type2 eq "stock_ids")) {
        return 1;
    }
    else {  return 0; }
}


sub transform {
    my $self = shift;
    my $schema = shift;
    my $list = shift;

    my @transform = ();

    my @missing = ();

    if (ref($list) eq "ARRAY" ) {
        my %ids;
        my %names = map { $_ => 1 } grep { defined $_ } @$list;
        my @names = keys %names;
        while (@names) {
            my @batch = splice(@names, 0, 1000);
            my $rs = $schema->resultset("Stock::Stock")->search(
                { uniquename => { -in => \@batch } },
                { columns => [qw/stock_id uniquename/] }
            );
            while (my $row = $rs->next()) {
                push @{$ids{$row->uniquename}}, $row->stock_id;
            }
        }
        foreach my $l (@$list) {
            if (!defined($l) || !exists($ids{$l})) {
                push @missing, $l;
            } elsif (@{$ids{$l}} > 1) {
                die "Found more than one id ".$ids{$l}[0]." for stock $l\n";
            } else {
                push @transform, $ids{$l}[0];
            }
        }
    }
    return {
        transform => \@transform,
        missing => \@missing,
    };
}

1;
