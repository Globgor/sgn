package CXGN::Phenotypes::RejectedUnits;

=head1 NAME

CXGN::Phenotypes::RejectedUnits - the observation units whose values are left out because their plot is rejected

=head1 DESCRIPTION

A rejected plot (stock property C<rejected> = 1, set with
L<CXGN::Trial::AccessionChange>) is a planted plot whose data must not be
used. Its values and those of its plants, subplots and tissue samples stay in
the database, but the phenotype searches (L<CXGN::Phenotypes::Search::Native>,
L<CXGN::Phenotypes::Search::MaterializedViewTable>,
L<CXGN::Phenotypes::HighDimensionalPhenotypesSearch>) leave them out unless
asked otherwise (C<exclude_rejected =E<gt> 0>), and so do the downloads,
datasets and analyses that read through them.

=head2 sql($schema)

The SQL of a subquery C<(SELECT stock_id ...)> of the rejected units: the
rejected plots, their plants and subplots, and the tissue samples of any of
them, in whatever trial. On a database without the C<rejected> property it
selects nothing. No bind values.

=head2 ids($schema, \@stock_ids)

A hashref of those of the stock ids that are rejected units.

=cut

use strict;
use warnings;
use SGN::Model::Cvterm;

sub sql {
    my $class = shift;
    my $schema = shift;
    my $cvterm = sub { my $row = SGN::Model::Cvterm->get_cvterm_row($schema, @_); return $row ? $row->cvterm_id : undef; };
    my $rejected = $cvterm->('rejected', 'stock_property');
    return "(SELECT NULL::integer AS stock_id WHERE false)" if !$rejected;   # the patch has not run: nothing is rejected
    my ($plant_of, $subplot_of, $tissue_sample_of) = map { $cvterm->($_, 'stock_relationship') // 0 } qw(plant_of subplot_of tissue_sample_of);
    my ($plant, $subplot, $tissue_sample) = map { $cvterm->($_, 'stock_type') // 0 } qw(plant subplot tissue_sample);
    # downwards from the plot: plant_of and subplot_of have subject = plot and object = child,
    # tissue_sample_of has subject = sample and object = parent; the type of the child keeps
    # accessions out (a plant and a sample are linked to their accession the same way)
    return "(WITH RECURSIVE rejected_units(stock_id) AS (
            SELECT stock_id FROM stockprop WHERE type_id = $rejected AND value = '1'
          UNION
            SELECT child.stock_id FROM rejected_units ru
            JOIN stock_relationship r ON (r.type_id IN ($plant_of, $subplot_of) AND r.subject_id = ru.stock_id) OR (r.type_id = $tissue_sample_of AND r.object_id = ru.stock_id)
            JOIN stock child ON child.stock_id = CASE WHEN r.type_id = $tissue_sample_of THEN r.subject_id ELSE r.object_id END AND child.type_id IN ($plant, $subplot, $tissue_sample)
        ) SELECT stock_id FROM rejected_units)";
}

sub ids {
    my $class = shift;
    my $schema = shift;
    my $stock_ids = shift;
    return {} if !$stock_ids || !@$stock_ids;
    my $h = $schema->storage->dbh->prepare("SELECT r.stock_id FROM ".$class->sql($schema)." r WHERE r.stock_id = ANY(?)");
    $h->execute($stock_ids);
    my %ids;
    while (my ($id) = $h->fetchrow_array()) { $ids{$id} = 1; }
    return \%ids;
}

1;
