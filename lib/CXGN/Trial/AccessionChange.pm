package CXGN::Trial::AccessionChange;

=head1 NAME

CXGN::Trial::AccessionChange - change the accession (cross, family name) of plots in a field trial, or of wells in a genotyping plate

=head1 SYNOPSIS

    my $change = CXGN::Trial::AccessionChange->new({
        schema   => $schema,      # Bio::Chado::Schema
        trial_id => $trial_id,
    });

    # what would change, without changing anything
    my $plan = $change->plan([ { plot_id => 38866, new_stock_id => 38840 } ], { rename_plots => 'auto' });
    print join("\n", @{$plan->{errors}}) if @{$plan->{errors}};

    # the same, in one transaction; dies with the errors of the plan
    my $result = $change->apply([ { plot_id => 38866, new_stock_id => 38840 } ]);

    # every plot of one stock
    my $changes = $change->changes_for_stock($old_stock_id, $new_stock_id);

=head1 DESCRIPTION

A plot is a place in the field. Its plot number, block, replicate, row and
column describe that place and are part of the design. The accession is what
grows there. Changing the accession of a plot corrects what was planted (or
will be planted); it does not move the plot. So a change:

=over

=item *

links the plot to the new stock (C<plot_of>), and the plants, subplots and
tissue samples of the plot that belong to this trial (C<plant_of>,
C<subplot_of>, C<tissue_sample_of>). Samples of the plot in other trials, for
example the wells of a genotyping plate, are not changed; the plan warns about
them.

=item *

keeps the plot number, block, row, column and, in blocked designs, the
replicate. Only in a CRD (completely randomized design) is the replicate the
n-th plot of an accession; there the replicates of the accessions that gain or
lose plots are numbered again by plot number. Plots without a replicate are
left without one.

=item *

renames plots if asked to (C<rename_plots =E<gt> 'auto'>, the default). A
trial with a plot name template gets the template name for every plot whose
accession or replicate changes. Otherwise the old stock name is replaced by
the new one where it is a whole part of the plot name (at the start or after
C<-> or C<_>, and at the end or before C<-> or C<_>). A name that contains
the old stock name that way more than once is left as it is and listed in
C<not_renamed>. An explicit C<new_plot_name> in a change is always used.
Plants, subplots and tissue samples whose names start with the plot name are
renamed with it. All renames happen in two passes, so a new name can be one
that another plot in the same change has now.

=item *

gives the new stock the entry number of the old one when the old stock leaves
the trial, the new one is new to the trial, and nothing else claims that entry
number.

=item *

regenerates the cached trial layout.

=back

The layout is always read from the database, never from the cached layout,
which may be out of date.

Genotyping plates (C<experiment_type =E<gt> 'genotyping_layout'>) work the
same way for wells (tissue samples linked to an accession with
C<tissue_sample_of>), but wells are never renamed and have no replicates.

The materialized views are not refreshed here, because that has to happen
after the transaction is committed; callers do it.

=head1 AUTHOR

=cut

use Moose;
use JSON;
use Try::Tiny;
use SGN::Model::Cvterm;
use CXGN::Trial::TrialLayout;
use CXGN::BreedersToolbox::Projects;

has 'schema' => ( isa => 'Bio::Chado::Schema', is => 'ro', required => 1 );

has 'trial_id' => ( isa => 'Int', is => 'ro', required => 1 );

=head2 experiment_type

'field_layout' (default) for plots of a field trial, 'genotyping_layout' for wells of a genotyping plate.

=cut

has 'experiment_type' => ( isa => 'Str', is => 'ro', default => 'field_layout' );

=head2 stock_type

Optional: 'accession', 'cross' or 'family_name'. The new stocks must be of
this type. Without it they must be of the type in the trial_stock_type
property of the trial, or, when the trial has none, of a type that the plots
of the trial have now.

=cut

has 'stock_type' => ( isa => 'Maybe[Str]', is => 'ro' );

has '_cvterm_ids' => ( isa => 'HashRef', is => 'ro', lazy => 1, builder => '_build_cvterm_ids' );

has '_trial_name' => ( isa => 'Str', is => 'ro', lazy => 1, builder => '_build_trial_name' );

has '_breeding_program_name' => ( isa => 'Str', is => 'ro', lazy => 1, builder => '_build_breeding_program_name' );

sub _build_cvterm_ids {
    my $self = shift;
    my $schema = $self->schema;
    my %ids;
    my @terms = (
        [ plot => 'plot', 'stock_type' ],
        [ plant => 'plant', 'stock_type' ],
        [ subplot => 'subplot', 'stock_type' ],
        [ tissue_sample => 'tissue_sample', 'stock_type' ],
        [ accession => 'accession', 'stock_type' ],
        [ cross => 'cross', 'stock_type' ],
        [ family_name => 'family_name', 'stock_type' ],
        [ plot_of => 'plot_of', 'stock_relationship' ],
        [ plant_of => 'plant_of', 'stock_relationship' ],
        [ subplot_of => 'subplot_of', 'stock_relationship' ],
        [ tissue_sample_of => 'tissue_sample_of', 'stock_relationship' ],
        [ intercrop_plot_of => 'intercrop_plot_of', 'stock_relationship' ],
        [ plot_number => 'plot number', 'stock_property' ],
        [ block => 'block', 'stock_property' ],
        [ replicate => 'replicate', 'stock_property' ],
        [ row_number => 'row_number', 'stock_property' ],
        [ col_number => 'col_number', 'stock_property' ],
        [ range => 'range', 'stock_property' ],
        [ is_a_control => 'is a control', 'stock_property' ],
        [ field_layout => 'field_layout', 'experiment_type' ],
        [ genotyping_layout => 'genotyping_layout', 'experiment_type' ],
        [ design => 'design', 'project_property' ],
        [ plot_name_template => 'plot_autogenerated_name_metadata', 'project_property' ],
        [ entry_numbers => 'project_entry_number_map', 'project_property' ],
    );
    foreach my $t (@terms) {
        my $row = SGN::Model::Cvterm->get_cvterm_row($schema, $t->[1], $t->[2]);
        $ids{$t->[0]} = $row ? $row->cvterm_id() : undef;
    }
    return \%ids;
}

sub _is_plate {
    my $self = shift;
    return $self->experiment_type eq 'genotyping_layout';
}

# stock type and relationship of the units that carry the accession
sub _unit_type_id { my $self = shift; return $self->_cvterm_ids->{ $self->_is_plate ? 'tissue_sample' : 'plot' }; }
sub _unit_relationship_id { my $self = shift; return $self->_cvterm_ids->{ $self->_is_plate ? 'tissue_sample_of' : 'plot_of' }; }

# the stock types the new stocks may have, see stock_type
sub _allowed_stock_types {
    my $self = shift;
    my $units = shift;
    my $ids = $self->_cvterm_ids;
    my @names = $self->_is_plate ? ('accession') : ('accession', 'cross', 'family_name');
    my $wanted = $self->stock_type;
    if (!$wanted && !$self->_is_plate) {
        my $type_id = SGN::Model::Cvterm->get_cvterm_row($self->schema, 'trial_stock_type', 'project_property');
        my $row = $type_id ? $self->schema->resultset('Project::Projectprop')->find({ project_id => $self->trial_id, type_id => $type_id->cvterm_id() }) : undef;
        $wanted = $row->value if $row;
    }
    if ($wanted) {
        return [ grep { $_ eq $wanted } @names ];
    }
    my %present = map { $_->{stock_type_id} => 1 } grep { defined $_->{stock_type_id} } values %$units;
    my @present = grep { $ids->{$_} && $present{ $ids->{$_} } } @names;
    return @present ? \@present : \@names;
}

=head2 load_units()

Reads the plots (or wells) of the trial from the database. Returns a hashref
plot_id => { plot_id, plot_name, stock_id, stock_name, plot_number, block,
replicate, row_number, col_number, range, is_a_control }. A plot that is not
linked to exactly one stock has no stock_id, and stock_count instead.

=cut

sub load_units {
    my $self = shift;
    my $dbh = $self->schema->storage->dbh;
    my $ids = $self->_cvterm_ids;
    my $experiment_type_id = $ids->{ $self->experiment_type } or die "Unknown experiment type ".$self->experiment_type."\n";

    my $units_q = "SELECT DISTINCT unit.stock_id, unit.uniquename
        FROM nd_experiment_project nep
        JOIN nd_experiment ne ON ne.nd_experiment_id = nep.nd_experiment_id AND ne.type_id = ?
        JOIN nd_experiment_stock nes ON nes.nd_experiment_id = ne.nd_experiment_id
        JOIN stock unit ON unit.stock_id = nes.stock_id AND unit.type_id = ?
        WHERE nep.project_id = ?";
    my $h = $dbh->prepare($units_q);
    $h->execute($experiment_type_id, $self->_unit_type_id, $self->trial_id);
    my %units;
    while (my ($stock_id, $name) = $h->fetchrow_array()) {
        $units{$stock_id} = { plot_id => $stock_id, plot_name => $name, stocks => [] };
    }
    my @unit_ids = keys %units;
    return {} if !@unit_ids;

    my $stocks_q = "SELECT r.subject_id, r.object_id, s.uniquename, s.type_id
        FROM stock_relationship r
        JOIN stock s ON s.stock_id = r.object_id
        WHERE r.type_id = ? AND r.subject_id = ANY(?) AND s.type_id = ANY(?)";
    $h = $dbh->prepare($stocks_q);
    $h->execute($self->_unit_relationship_id, \@unit_ids, $self->_primary_stock_type_ids());
    while (my ($unit_id, $stock_id, $stock_name, $type_id) = $h->fetchrow_array()) {
        push @{$units{$unit_id}->{stocks}}, { stock_id => $stock_id, stock_name => $stock_name, type_id => $type_id };
    }

    my %prop_names = map { $ids->{$_} => $_ } grep { $ids->{$_} } qw(plot_number block replicate row_number col_number range is_a_control);
    my $props_q = "SELECT stock_id, type_id, value FROM stockprop WHERE stock_id = ANY(?) AND type_id = ANY(?) ORDER BY rank";
    $h = $dbh->prepare($props_q);
    $h->execute(\@unit_ids, [ keys %prop_names ]);
    while (my ($unit_id, $type_id, $value) = $h->fetchrow_array()) {
        $units{$unit_id}->{ $prop_names{$type_id} } //= $value;
    }

    foreach my $unit (values %units) {
        my $stocks = delete $unit->{stocks};
        if (scalar(@$stocks) == 1) {
            $unit->{stock_id} = $stocks->[0]->{stock_id};
            $unit->{stock_name} = $stocks->[0]->{stock_name};
            $unit->{stock_type_id} = $stocks->[0]->{type_id};
        } else {
            $unit->{stock_count} = scalar(@$stocks);
        }
    }
    return \%units;
}

# stock types a unit can be linked to with its relationship: all of them, so
# that a unit linked to a stock of another type is found (and reported)
sub _primary_stock_type_ids {
    my $self = shift;
    my $ids = $self->_cvterm_ids;
    my @names = $self->_is_plate ? ('accession') : ('accession', 'cross', 'family_name');
    return [ map { $ids->{$_} } grep { $ids->{$_} } @names ];
}

=head2 changes_for_stock($old_stock_id, $new_stock_id)

The list of changes that replaces a stock in every plot of the trial, to pass
to plan() or apply(). Empty when the stock is in no plot of the trial.

=cut

sub changes_for_stock {
    my $self = shift;
    my $old_stock_id = shift;
    my $new_stock_id = shift;
    my $units = $self->load_units();
    return [ map { { plot_id => $_->{plot_id}, new_stock_id => $new_stock_id } }
             sort { $a->{plot_id} <=> $b->{plot_id} }
             grep { defined($_->{stock_id}) && $_->{stock_id} == $old_stock_id } values %$units ];
}

=head2 field_trial_of_plot($schema, $plot_id)

Class method: the id of the field trial the plot belongs to, or undef.

=cut

sub field_trial_of_plot {
    my $class = shift;
    my $schema = shift;
    my $plot_id = shift;
    return if !defined($plot_id) || $plot_id !~ /^\d+$/;
    my $field_layout = SGN::Model::Cvterm->get_cvterm_row($schema, 'field_layout', 'experiment_type')->cvterm_id();
    my $h = $schema->storage->dbh->prepare("SELECT nep.project_id FROM nd_experiment_stock nes
        JOIN nd_experiment ne ON ne.nd_experiment_id = nes.nd_experiment_id AND ne.type_id = ?
        JOIN nd_experiment_project nep ON nep.nd_experiment_id = ne.nd_experiment_id
        WHERE nes.stock_id = ? ORDER BY nep.project_id LIMIT 1");
    $h->execute($field_layout, $plot_id);
    my ($trial_id) = $h->fetchrow_array();
    return $trial_id;
}

=head2 plan($changes, $options)

$changes is an arrayref of { plot_id, new_stock_id, new_plot_name (optional) }.
A change whose new stock is the current one only renames the plot (when it has
a new_plot_name) or does nothing.

$options: { rename_plots => 'auto' (default) or 'none' }. With 'none' plots
are only renamed to an explicit new_plot_name.

Returns a hashref:

    errors        => [ messages ]; nothing may be changed when there are any
    warnings      => [ messages ]
    changes       => [ { plot_id, plot_name, old_stock_id, old_stock_name, new_stock_id, new_stock_name } ]
    unchanged     => [ plot names whose stock is already the new one ]
    replicates    => [ { plot_id, plot_name, old, new } ]
    renames       => [ { stock_id, type => 'plot'|'plant'|'subplot'|'tissue_sample', old_name, new_name } ]
    not_renamed   => [ { plot_name, reason } ]
    entry_numbers => [ { stock_id, stock_name, entry_number, from_stock_id } ]

Each error and warning is listed once, also when it concerns many plots.

=cut

sub plan {
    my $self = shift;
    my $plan = $self->_plan(@_);
    foreach my $list ('errors', 'warnings') {
        my %seen;
        @{$plan->{$list}} = grep { !$seen{$_}++ } @{$plan->{$list}};
    }
    return $plan;
}

sub _plan {
    my $self = shift;
    my $changes = shift || [];
    my $options = shift || {};
    my $rename_mode = $options->{rename_plots} // 'auto';
    my $schema = $self->schema;
    my $ids = $self->_cvterm_ids;

    my %plan = ( errors => [], warnings => [], changes => [], unchanged => [], replicates => [], renames => [], not_renamed => [], entry_numbers => [] );
    my $errors = $plan{errors};

    if ($rename_mode ne 'auto' && $rename_mode ne 'none') {
        push @$errors, "Unknown rename_plots option '$rename_mode'.";
        return \%plan;
    }
    if (ref($changes) ne 'ARRAY' || !@$changes) {
        push @$errors, "Nothing to change.";
        return \%plan;
    }

    my $units = $self->load_units();

    # validate the changes
    my %new_stock_by_unit;
    my %explicit_name;
    my %seen_unit;
    my %new_stocks;
    my $allowed_types = $self->_allowed_stock_types($units);
    my %allowed_type = map { $ids->{$_} => 1 } grep { $ids->{$_} } @$allowed_types;
    foreach my $change (@$changes) {
        my $unit_id = $change->{plot_id};
        if (!defined($unit_id) || $unit_id !~ /^\d+$/ || !$units->{$unit_id}) {
            push @$errors, "Plot ".($change->{plot_name} // $unit_id // '(none)')." is not part of this trial.";
            next;
        }
        my $unit = $units->{$unit_id};
        if ($seen_unit{$unit_id}++) {
            push @$errors, "Plot $unit->{plot_name} is listed more than once.";
            next;
        }
        if (!defined($unit->{stock_id})) {
            push @$errors, "Plot $unit->{plot_name} is linked to ".($unit->{stock_count} // 0)." stocks; it must be linked to exactly one.";
            next;
        }
        my $new_stock_id = $change->{new_stock_id};
        my $new_stock = (defined($new_stock_id) && $new_stock_id =~ /^\d+$/) ? ($new_stocks{$new_stock_id} //= $schema->resultset('Stock::Stock')->find({ stock_id => $new_stock_id })) : undef;
        if (!$new_stock) {
            push @$errors, "The new stock for plot $unit->{plot_name} does not exist.";
            next;
        }
        if ($new_stock->is_obsolete) {
            push @$errors, "Stock ".$new_stock->uniquename." is obsolete.";
            next;
        }
        if (!$allowed_type{$new_stock->type_id}) {
            push @$errors, "Stock ".$new_stock->uniquename." is not ".stock_type_description(@$allowed_types).".";
            next;
        }
        if (defined($change->{new_plot_name}) && $change->{new_plot_name} =~ /\S/) {
            if ($self->_is_plate) {
                push @$errors, "Wells of a genotyping plate cannot be renamed here.";
                next;
            }
            (my $name = $change->{new_plot_name}) =~ s/^\s+|\s+$//g;
            $explicit_name{$unit_id} = $name if $name ne $unit->{plot_name};
        }
        if ($new_stock_id == $unit->{stock_id}) {
            push @{$plan{unchanged}}, $unit->{plot_name} if !exists($explicit_name{$unit_id});
            next;
        }
        $new_stock_by_unit{$unit_id} = $new_stock_id;
        push @{$plan{changes}}, {
            plot_id => $unit_id + 0,
            plot_name => $unit->{plot_name},
            old_stock_id => $unit->{stock_id} + 0,
            old_stock_name => $unit->{stock_name},
            new_stock_id => $new_stock_id + 0,
            new_stock_name => $new_stock->uniquename,
        };
    }
    return \%plan if @$errors;

    # the state after the change
    my %after = map { $_ => { %{$units->{$_}} } } keys %$units;
    foreach my $unit_id (keys %new_stock_by_unit) {
        $after{$unit_id}->{stock_id} = $new_stock_by_unit{$unit_id};
        $after{$unit_id}->{stock_name} = $new_stocks{ $new_stock_by_unit{$unit_id} }->uniquename;
    }

    # replicates: only in a CRD, where the replicate is the n-th plot of an accession
    my %new_replicate;
    if (!$self->_is_plate && lc($self->design_type // '') eq 'crd') {
        my %affected_stocks;
        foreach my $c (@{$plan{changes}}) {
            $affected_stocks{ $c->{old_stock_id} } = 1;
            $affected_stocks{ $c->{new_stock_id} } = 1;
        }
        foreach my $stock_id (keys %affected_stocks) {
            my @plots = sort { _compare_plot_numbers($a->{plot_number}, $b->{plot_number}) || $a->{plot_id} <=> $b->{plot_id} }
                grep { $_->{stock_id} == $stock_id && defined($_->{replicate}) } values %after;
            my $n = 1;
            foreach my $p (@plots) {
                if ($p->{replicate} ne $n) {
                    push @{$plan{replicates}}, { plot_id => $p->{plot_id} + 0, plot_name => $p->{plot_name}, old => $p->{replicate}, new => $n };
                    $new_replicate{ $p->{plot_id} } = $n;
                    $p->{replicate} = $n;
                }
                $n++;
            }
        }
        @{$plan{replicates}} = sort { $a->{plot_id} <=> $b->{plot_id} } @{$plan{replicates}};
    }

    # new plot names
    my %new_name = %explicit_name;
    if ($rename_mode eq 'auto' && !$self->_is_plate) {
        my $template = $self->plot_name_template();
        my %touched = (%new_stock_by_unit, %new_replicate);
        foreach my $unit_id (sort { $a <=> $b } keys %touched) {
            next if exists($new_name{$unit_id});
            my $unit = $units->{$unit_id};
            if ($template) {
                my $name = $self->_template_name($template, $after{$unit_id});
                if (!length($name)) {
                    push @{$plan{not_renamed}}, { plot_name => $unit->{plot_name}, reason => "the plot name template gives an empty name" };
                } elsif ($name ne $unit->{plot_name}) {
                    $new_name{$unit_id} = $name;
                }
            } elsif (exists($new_stock_by_unit{$unit_id})) {
                my ($name, $reason) = replace_name_part($unit->{plot_name}, $unit->{stock_name}, $after{$unit_id}->{stock_name});
                if (defined($reason)) {
                    push @{$plan{not_renamed}}, { plot_name => $unit->{plot_name}, reason => $reason };
                } elsif ($name ne $unit->{plot_name}) {
                    $new_name{$unit_id} = $name;
                }
            }
        }
    }

    # the units' own samples, and samples of them in other trials
    my $children = $self->_is_plate ? {} : $self->_children([ keys %new_stock_by_unit, keys %new_name ]);

    # renames of the plots and of their plants, subplots and tissue samples
    foreach my $unit_id (sort { $a <=> $b } keys %new_name) {
        my $old = $units->{$unit_id}->{plot_name};
        my $new = $new_name{$unit_id};
        push @{$plan{renames}}, { stock_id => $unit_id + 0, type => 'plot', old_name => $old, new_name => $new };
        foreach my $child (@{ $children->{$unit_id}->{in_trial} || [] }) {
            next if index($child->{name}, $old) != 0;
            push @{$plan{renames}}, { stock_id => $child->{stock_id} + 0, type => $child->{type}, old_name => $child->{name}, new_name => $new.substr($child->{name}, length($old)) };
        }
    }
    $self->_check_new_names($plan{renames}, $errors);

    # warnings
    foreach my $c (@{$plan{changes}}) {
        my $external = $children->{ $c->{plot_id} }->{external} || [];
        if (@$external) {
            push @{$plan{warnings}}, scalar(@$external)." sample(s) of plot $c->{plot_name} in other trials (for example ".$external->[0]->{name}.") keep $c->{old_stock_name}.";
        }
        if ($units->{ $c->{plot_id} }->{is_a_control}) {
            push @{$plan{warnings}}, "Plot $c->{plot_name} is a check plot; it stays a check plot with $c->{new_stock_name}.";
        }
    }
    if (!$self->_is_plate) {
        my $intercropped = $self->_intercropped([ keys %new_stock_by_unit ]);
        foreach my $unit_id (keys %new_stock_by_unit) {
            if ($intercropped->{$unit_id}->{ $new_stock_by_unit{$unit_id} }) {
                push @$errors, "Plot $units->{$unit_id}->{plot_name} already has ".$after{$unit_id}->{stock_name}." as an intercrop.";
            }
        }
    }

    # entry numbers
    $self->_plan_entry_numbers(\%plan, $units, \%after);

    return \%plan;
}

=head2 apply($changes, $options)

Plans the changes (see plan()) and carries them out in one transaction. Dies
with the errors of the plan, or with a database error; nothing is changed
then. Returns the plan.

=cut

sub apply {
    my $self = shift;
    my $changes = shift;
    my $options = shift;
    my $schema = $self->schema;
    my $plan;
    $schema->txn_do(sub {
        $plan = $self->plan($changes, $options);
        if (@{$plan->{errors}}) {
            die join("\n", @{$plan->{errors}})."\n";
        }
        $self->_execute($plan);
    });
    return $plan;
}

sub _execute {
    my $self = shift;
    my $plan = shift;
    my $dbh = $self->schema->storage->dbh;
    my $ids = $self->_cvterm_ids;

    # stocks of the units, and of their plants, subplots and tissue samples in this trial
    my $children = $self->_is_plate ? {} : $self->_children([ map { $_->{plot_id} } @{$plan->{changes}} ]);
    my $unit_h = $dbh->prepare("UPDATE stock_relationship SET object_id = ? WHERE subject_id = ? AND object_id = ? AND type_id = ?");
    my $child_h = $dbh->prepare("UPDATE stock_relationship SET object_id = ? WHERE subject_id = ANY(?) AND object_id = ? AND type_id = ANY(?)");
    my @child_relationships = grep { defined } map { $ids->{$_} } qw(plant_of subplot_of tissue_sample_of);
    foreach my $c (@{$plan->{changes}}) {
        my $rows = $unit_h->execute($c->{new_stock_id}, $c->{plot_id}, $c->{old_stock_id}, $self->_unit_relationship_id);
        if ($rows != 1) {
            die "Plot $c->{plot_name} was changed by someone else in the meantime; nothing was changed.\n";
        }
        my @child_ids = map { $_->{stock_id} } @{ $children->{ $c->{plot_id} }->{in_trial} || [] };
        if (@child_ids) {
            $child_h->execute($c->{new_stock_id}, \@child_ids, $c->{old_stock_id}, \@child_relationships);
        }
    }

    my $rep_h = $dbh->prepare("UPDATE stockprop SET value = ? WHERE stock_id = ? AND type_id = ?");
    foreach my $r (@{$plan->{replicates}}) {
        $rep_h->execute($r->{new}, $r->{plot_id}, $ids->{replicate});
    }

    # two passes, so that a new name may be one that another renamed stock has now
    my $rename_h = $dbh->prepare("UPDATE stock SET uniquename = ?, name = ? WHERE stock_id = ? AND uniquename = ?");
    foreach my $r (@{$plan->{renames}}) {
        my $temporary = "__accession_change_".$r->{stock_id}."_".$$;
        my $rows = $rename_h->execute($temporary, $temporary, $r->{stock_id}, $r->{old_name});
        if ($rows != 1) {
            die "$r->{old_name} was renamed by someone else in the meantime; nothing was changed.\n";
        }
        $r->{_temporary} = $temporary;
    }
    foreach my $r (@{$plan->{renames}}) {
        $rename_h->execute($r->{new_name}, $r->{new_name}, $r->{stock_id}, delete $r->{_temporary});
    }

    if (@{$plan->{entry_numbers}}) {
        my $map = $self->_entry_number_map() || {};
        foreach my $e (@{$plan->{entry_numbers}}) {
            delete $map->{ $e->{from_stock_id} };
            $map->{ $e->{stock_id} } = $e->{entry_number};
        }
        my $row = $self->schema->resultset('Project::Projectprop')->find({ project_id => $self->trial_id, type_id => $ids->{entry_numbers} });
        $row->update({ value => encode_json($map) });
    }

    if (@{$plan->{changes}} || @{$plan->{replicates}} || @{$plan->{renames}}) {
        my $layout = CXGN::Trial::TrialLayout->new({
            schema => $self->schema,
            trial_id => $self->trial_id,
            experiment_type => $self->experiment_type,
        });
        $layout->generate_and_cache_layout();
    }
}

=head2 stock_type_description(@stock_types)

'an accession', 'a cross or a family name', ...; 'an accession, cross or family name' without types.

=cut

sub stock_type_description {
    my @stock_types = grep { defined && length } @_;
    my %description = ( accession => 'an accession', cross => 'a cross', family_name => 'a family name' );
    my @descriptions = map { $description{$_} // $_ } @stock_types;
    return @descriptions ? join(' or ', @descriptions) : 'an accession, cross or family name';
}

=head2 replace_name_part($name, $old_part, $new_part)

Replaces $old_part by $new_part in $name where it is a whole part of the name:
at the start or after "-" or "_", and at the end or before "-" or "_". Returns
the new name (the same name when it has no such part), or (undef, reason) when
it has that part more than once.

=cut

sub replace_name_part {
    my ($name, $old_part, $new_part) = @_;
    return ($name) if !defined($old_part) || !length($old_part);
    my @positions;
    while ($name =~ /(?:^|(?<=[-_]))\Q$old_part\E(?=[-_]|$)/g) {
        push @positions, $-[0];
        pos($name) = $-[0] + 1;
    }
    return ($name) if !@positions;
    return (undef, "the plot name contains $old_part more than once") if @positions > 1;
    substr($name, $positions[0], length($old_part)) = $new_part;
    return ($name);
}

=head2 design_type()

The design of the trial ('CRD', 'RCBD', ...), or undef.

=cut

sub design_type {
    my $self = shift;
    my $row = $self->schema->resultset('Project::Projectprop')->find({ project_id => $self->trial_id, type_id => $self->_cvterm_ids->{design} });
    return $row ? $row->value : undef;
}

=head2 plot_name_template()

The name attributes of the trial's plot name template, or undef.

=cut

sub plot_name_template {
    my $self = shift;
    my $type_id = $self->_cvterm_ids->{plot_name_template} or return;
    my $row = $self->schema->resultset('Project::Projectprop')->find({ project_id => $self->trial_id, type_id => $type_id });
    return if !$row;
    my $template = try { decode_json($row->value) } catch { undef };
    return if ref($template) ne 'HASH';
    my ($format) = keys %$template;
    return if !$format || ref($template->{$format}) ne 'HASH';
    my $attributes = $template->{$format}->{name_attributes};
    return (ref($attributes) eq 'ARRAY' && @$attributes) ? $attributes : undef;
}

# the same as CXGN::Trial::TrialDesign::_build_plot_names
sub _template_name {
    my $self = shift;
    my $attributes = shift;
    my $unit = shift;
    my %source = (
        breedingProgram => $self->_breeding_program_name(),
        trialName       => $self->_trial_name(),
        accessionName   => $unit->{stock_name} // '',
        plotNumber      => $unit->{plot_number} // '',
        blockNumber     => $unit->{block} // '',
        repNumber       => $unit->{replicate} // '',
        rangeNumber     => $unit->{range} // '',
        rowNumber       => $unit->{row_number} // '',
        colNumber       => $unit->{col_number} // '',
    );
    return join('_', map { ref($_) eq 'HASH' ? ($_->{text} // '') : ($source{$_} // '') } @$attributes);
}

sub _build_trial_name {
    my $self = shift;
    return $self->schema->resultset('Project::Project')->find({ project_id => $self->trial_id })->name;
}

sub _build_breeding_program_name {
    my $self = shift;
    my $programs = CXGN::BreedersToolbox::Projects->new({ schema => $self->schema })->get_breeding_programs_by_trial($self->trial_id);
    return ($programs && $programs->[0]) ? ($programs->[0]->[1] // '') : '';
}

sub _compare_plot_numbers {
    my ($x, $y) = @_;
    $x //= '';
    $y //= '';
    if ($x =~ /^-?\d+(?:\.\d+)?$/ && $y =~ /^-?\d+(?:\.\d+)?$/) {
        return $x <=> $y;
    }
    return $x cmp $y;
}

# plants, subplots and tissue samples of the units; in_trial are those that belong to this trial
sub _children {
    my $self = shift;
    my $unit_ids = shift;
    my %children;
    return \%children if !@$unit_ids;
    my $dbh = $self->schema->storage->dbh;
    my $ids = $self->_cvterm_ids;

    my %parent_unit = map { $_ => $_ } @$unit_ids;
    my %child;   # stock_id => { stock_id, name, type, unit }

    # plants and subplots: plot -> plant (plant_of), plot -> subplot (subplot_of)
    my $h = $dbh->prepare("SELECT r.subject_id, s.stock_id, s.uniquename, s.type_id
        FROM stock_relationship r JOIN stock s ON s.stock_id = r.object_id
        WHERE r.subject_id = ANY(?) AND ((r.type_id = ? AND s.type_id = ?) OR (r.type_id = ? AND s.type_id = ?))");
    $h->execute($unit_ids, $ids->{plant_of}, $ids->{plant}, $ids->{subplot_of}, $ids->{subplot});
    while (my ($unit_id, $stock_id, $name, $type_id) = $h->fetchrow_array()) {
        $child{$stock_id} = { stock_id => $stock_id, name => $name, type => ($type_id == $ids->{plant} ? 'plant' : 'subplot'), unit => $unit_id };
        $parent_unit{$stock_id} = $unit_id;
    }

    # tissue samples of the plots, plants and subplots, and samples of those samples
    my @parents = keys %parent_unit;
    $h = $dbh->prepare("SELECT r.object_id, s.stock_id, s.uniquename
        FROM stock_relationship r JOIN stock s ON s.stock_id = r.subject_id
        WHERE r.object_id = ANY(?) AND r.type_id = ? AND s.type_id = ?");
    while (@parents) {
        $h->execute(\@parents, $ids->{tissue_sample_of}, $ids->{tissue_sample});
        my @next;
        while (my ($parent_id, $stock_id, $name) = $h->fetchrow_array()) {
            next if $child{$stock_id} || $parent_unit{$stock_id};
            $child{$stock_id} = { stock_id => $stock_id, name => $name, type => 'tissue_sample', unit => $parent_unit{$parent_id} };
            $parent_unit{$stock_id} = $parent_unit{$parent_id};
            push @next, $stock_id;
        }
        @parents = @next;
    }
    return \%children if !%child;

    # which of them belong to this trial
    $h = $dbh->prepare("SELECT DISTINCT nes.stock_id FROM nd_experiment_stock nes
        JOIN nd_experiment_project nep ON nep.nd_experiment_id = nes.nd_experiment_id
        WHERE nep.project_id = ? AND nes.stock_id = ANY(?)");
    $h->execute($self->trial_id, [ keys %child ]);
    my %in_trial;
    while (my ($stock_id) = $h->fetchrow_array()) { $in_trial{$stock_id} = 1; }

    foreach my $c (sort { $a->{stock_id} <=> $b->{stock_id} } values %child) {
        push @{ $children{ $c->{unit} }->{ $in_trial{ $c->{stock_id} } ? 'in_trial' : 'external' } }, $c;
    }
    return \%children;
}

sub _intercropped {
    my $self = shift;
    my $unit_ids = shift;
    my %intercropped;
    my $type_id = $self->_cvterm_ids->{intercrop_plot_of};
    return \%intercropped if !@$unit_ids || !$type_id;
    my $h = $self->schema->storage->dbh->prepare("SELECT subject_id, object_id FROM stock_relationship WHERE subject_id = ANY(?) AND type_id = ?");
    $h->execute($unit_ids, $type_id);
    while (my ($unit_id, $stock_id) = $h->fetchrow_array()) { $intercropped{$unit_id}->{$stock_id} = 1; }
    return \%intercropped;
}

# new names must be unique among themselves and in the database, except for
# names that stocks renamed in this change have now
sub _check_new_names {
    my $self = shift;
    my $renames = shift;
    my $errors = shift;
    return if !@$renames;
    my %renamed_ids = map { $_->{stock_id} => 1 } @$renames;
    my %count;
    foreach my $r (@$renames) {
        if (!length($r->{new_name})) {
            push @$errors, "The new name of $r->{old_name} is empty.";
        }
        $count{ $r->{new_name} }++;
    }
    foreach my $name (sort grep { $count{$_} > 1 } keys %count) {
        push @$errors, "$count{$name} stocks would be named $name.";
    }
    my $h = $self->schema->storage->dbh->prepare("SELECT stock_id, uniquename FROM stock WHERE uniquename = ANY(?)");
    $h->execute([ keys %count ]);
    while (my ($stock_id, $name) = $h->fetchrow_array()) {
        next if $renamed_ids{$stock_id};
        push @$errors, "Plot name $name already exists in the database.";
    }
}

sub _entry_number_map {
    my $self = shift;
    my $type_id = $self->_cvterm_ids->{entry_numbers} or return;
    my $row = $self->schema->resultset('Project::Projectprop')->find({ project_id => $self->trial_id, type_id => $type_id });
    return if !$row;
    return try { decode_json($row->value) } catch { undef };
}

# An old stock that leaves the trial hands its entry number to the new stock
# that takes its plots, when that stock is new to the trial and has none.
sub _plan_entry_numbers {
    my $self = shift;
    my $plan = shift;
    my $units = shift;
    my $after = shift;
    return if $self->_is_plate || !@{$plan->{changes}};
    my $map = $self->_entry_number_map();
    return if ref($map) ne 'HASH' || !%$map;

    my %before_stocks = map { $_->{stock_id} => 1 } grep { defined $_->{stock_id} } values %$units;
    my %after_stocks = map { $_->{stock_id} => 1 } grep { defined $_->{stock_id} } values %$after;
    my %takers;   # old stock => { new stock => 1 }
    my %new_name;
    foreach my $c (@{$plan->{changes}}) {
        $takers{ $c->{old_stock_id} }->{ $c->{new_stock_id} } = 1;
        $new_name{ $c->{new_stock_id} } = $c->{new_stock_name};
    }
    my %given;
    foreach my $old (sort { $a <=> $b } keys %takers) {
        my @new = keys %{$takers{$old}};
        next if $after_stocks{$old} || !exists($map->{$old}) || @new != 1;
        my $new = $new[0];
        next if $before_stocks{$new} || exists($map->{$new}) || $given{$new}++;
        push @{$plan->{entry_numbers}}, { stock_id => $new + 0, stock_name => $new_name{$new}, entry_number => $map->{$old}, from_stock_id => $old + 0 };
    }
    foreach my $new (sort keys %new_name) {
        if (!exists($map->{$new}) && !$given{$new}) {
            push @{$plan->{warnings}}, "$new_name{$new} has no entry number in this trial.";
        }
    }
}

=head2 summary($plan)

A short, JSON-safe summary of a plan for AJAX responses.

=cut

sub summary {
    my $self = shift;
    my $plan = shift;
    return {
        changed => scalar(@{$plan->{changes}}),
        unchanged => $plan->{unchanged},
        replicates_changed => scalar(@{$plan->{replicates}}),
        renamed => [ map { { old_name => $_->{old_name}, new_name => $_->{new_name} } } grep { $_->{type} eq 'plot' } @{$plan->{renames}} ],
        not_renamed => $plan->{not_renamed},
        entry_numbers => [ map { { stock_name => $_->{stock_name}, entry_number => $_->{entry_number} } } @{$plan->{entry_numbers}} ],
        warnings => $plan->{warnings},
    };
}

__PACKAGE__->meta->make_immutable;

1;
