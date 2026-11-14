package CXGN::List::Transform::Plugin::TraitIds2Synonyms;

use Moose;

use Moose::Util::TypeConstraints qw(find_type_constraint);

sub name {
    return "trait_ids_2_synonyms";
}

sub display_name {
    return "Trait IDs to synonyms";
}

sub can_transform {
    my $self = shift;
    my $type1 = shift;
    my $type2 = shift;

    if (($type1 eq "trait_ids") and ($type2 eq "synonyms")) {
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

    find_type_constraint('Int')->assert_valid($_) for @$list;
    my %synonyms;
    if (@$list) {
        my %seen;
        my @ids = grep { !$seen{$_}++ } map { $_ + 0 } @$list;
        # The original LIMIT 1 has no ordering; ties have no defined winner.
        my $query = "SELECT input.cvterm_id, (
            SELECT synonym FROM cvtermsynonym
            WHERE cvterm_id = input.cvterm_id
                AND synonym NOT LIKE '% %' AND synonym NOT LIKE '%\\_%'
            LIMIT 1
        ) FROM unnest(?::integer[]) AS input(cvterm_id)";
        my $sth = $schema->storage->dbh->prepare($query);
        $sth->execute(\@ids);
        while (my ($id, $synonym) = $sth->fetchrow_array()) {
            $synonyms{$id} = $synonym;
        }
    }
    foreach my $l (@$list) {
        my $synonym = $synonyms{$l + 0};

        if ($synonym) {
            push @transform, $synonym
        } else {
            push @missing, $l
        }
    }
    return { transform => \@transform,
	     missing => \@missing,
    };
}

1;
