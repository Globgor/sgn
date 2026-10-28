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

    # plots that were not planted
    $change->apply([ { plot_id => $plot_id, not_planted => 1 } ], { delete_phenotypes => 1 });

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
C<not_renamed>. An explicit C<new_plot_name> in a change is always used; one
that is the current name keeps it. Plants, subplots and tissue samples whose
names start with the plot name are renamed with it. All renames happen in
two passes, so a new name can be one that another plot in the same change
has now.

=item *

keeps the check plots (C<is a control>) with the check accessions: a plot
becomes a check plot when its new accession is a check in this trial (all of
its plots are check plots) and a test plot when it is not (none are). A new
accession that takes the place of another one everywhere takes over its
check marks; another accession that is new to the trial makes a test plot.
For an accession that is a check on some plots and not on others the mark is
left as it is, with a warning. Plants, subplots and tissue samples that have
a check mark get the one of their plot, and in a CRD the replicate of their
plot.

=item *

warns when plots already have phenotypes (the values stay with the plot, so
they count for the new accession) and when plots or their plants are parents
of crosses (the crosses keep their recorded parents).

=item *

marks plots as not planted, or as planted again (C<not_planted> in a
change). A plot that was not planted keeps the accession that was planned for
it, so the plan stays visible, but it has the stock property C<not_planted>:
the field map shows it as empty, it is left out of Field Book files and
phenotyping spreadsheets, and no phenotypes can be stored for it. Phenotypes
it already has would count for an accession that did not grow there, so they
are only deleted with the option C<delete_phenotypes>; without it the plan
has an error. Like any plot, a plot that was not planted keeps its place in
the design, also in the replicate numbering of a CRD.

=item *

moves the seed transactions (seedlot to plot) with the packets: a plot that
gets another accession takes over the transaction of a plot in the same change
that lost that accession, or of the seedlot in C<seedlot_name>. A transaction
that no plot takes, for example of a packet planted into a border, becomes
seed taken from the seedlot, so the inventory stays as it is.

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
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);
use SGN::Model::Cvterm;
use CXGN::Trial;
use CXGN::Trial::TrialLayout;
use CXGN::BreedersToolbox::Projects;
use CXGN::Stock::Seedlot;
use CXGN::JSONUtils qw(decode_stored_json);

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
        [ seedlot => 'seedlot', 'stock_type' ],
        [ plot_of => 'plot_of', 'stock_relationship' ],
        [ plant_of => 'plant_of', 'stock_relationship' ],
        [ subplot_of => 'subplot_of', 'stock_relationship' ],
        [ tissue_sample_of => 'tissue_sample_of', 'stock_relationship' ],
        [ intercrop_plot_of => 'intercrop_plot_of', 'stock_relationship' ],
        [ female_plot_of => 'female_plot_of', 'stock_relationship' ],
        [ male_plot_of => 'male_plot_of', 'stock_relationship' ],
        [ female_plant_of => 'female_plant_of', 'stock_relationship' ],
        [ male_plant_of => 'male_plant_of', 'stock_relationship' ],
        [ seed_transaction => 'seed transaction', 'stock_relationship' ],
        [ collection_of => 'collection_of', 'stock_relationship' ],
        [ cross_member_of => 'cross_member_of', 'stock_relationship' ],
        [ plot_number => 'plot number', 'stock_property' ],
        [ block => 'block', 'stock_property' ],
        [ replicate => 'replicate', 'stock_property' ],
        [ row_number => 'row_number', 'stock_property' ],
        [ col_number => 'col_number', 'stock_property' ],
        [ range => 'range', 'stock_property' ],
        [ is_a_control => 'is a control', 'stock_property' ],
        [ not_planted => 'not_planted', 'stock_property' ],
        [ phenotyping_experiment => 'phenotyping_experiment', 'experiment_type' ],
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
        # trials of crosses or family names can have accessions as checks
        return [ grep { $_ eq $wanted || $_ eq 'accession' } @names ];
    }
    my %present = map { $_->{stock_type_id} => 1 } grep { defined $_->{stock_type_id} } values %$units;
    my @present = grep { $ids->{$_} && $present{ $ids->{$_} } } @names;
    return @present ? \@present : \@names;
}

=head2 load_units()

Reads the plots (or wells) of the trial from the database. Returns a hashref
plot_id => { plot_id, plot_name, stock_id, stock_name, plot_number, block,
replicate, row_number, col_number, range, is_a_control, not_planted }. A plot that is not
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

    my %prop_names = map { $ids->{$_} => $_ } grep { $ids->{$_} } qw(plot_number block replicate row_number col_number range is_a_control not_planted);
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

A change can also set not_planted (1 or 0): without new_stock_id it only
marks the plot as not planted, or as planted.

$options: { rename_plots => 'auto' (default) or 'none', delete_phenotypes =>
1 to delete the phenotypes of plots that are marked as not planted }. With
'none' plots are only renamed to an explicit new_plot_name.

Returns a hashref:

    errors        => [ messages ]; nothing may be changed when there are any
    warnings      => [ messages ]
    changes       => [ { plot_id, plot_name, old_stock_id, old_stock_name, new_stock_id, new_stock_name } ]
    unchanged     => [ plot names whose stock is already the new one ]
    replicates    => [ { plot_id, plot_name, old, new } ]
    checks        => [ { plot_id, plot_name, old, new } ]; 1 for a check plot, 0 for a test plot
    planting      => [ { plot_id, plot_name, not_planted } ]; plots marked as not planted (1) or planted (0)
    not_planted_phenotypes => number of phenotype values of the plots marked as not planted
    phenotypes_to_delete   => { phenotype_ids => [ ... ], nd_experiment_ids => [ ... ], md_experiment_ids => [ ... ] }
                              of them (md: experiments with high-dimensional data), with delete_phenotypes
    plots_with_phenotypes => the number of changed plots that have phenotypes
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

    my %plan = ( errors => [], warnings => [], changes => [], unchanged => [], replicates => [], renames => [], not_renamed => [], entry_numbers => [], checks => [], plots_with_phenotypes => 0, planting => [], seedlots => [], not_planted_phenotypes => 0, phenotypes_to_delete => { phenotype_ids => [], nd_experiment_ids => [] } );
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
    my %new_not_planted;
    my %seedlot_name;
    my %explicit_name;
    my %keep_name;
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
        my $not_planted = (defined($change->{not_planted}) && $change->{not_planted} =~ /\S/) ? _is_true($change->{not_planted}) : undef;
        if (defined($not_planted)) {
            if ($self->_is_plate) {
                push @$errors, "Wells of a genotyping plate cannot be marked as not planted.";
                next;
            }
            if (!$ids->{not_planted}) {
                push @$errors, "This database does not know the stock property not_planted yet; run the database patches (AddNotPlantedStockprop).";
                next;
            }
            if ($not_planted != _is_true($unit->{not_planted})) {
                $new_not_planted{$unit_id} = $not_planted;
            }
        }
        if (defined($change->{seedlot_name}) && $change->{seedlot_name} =~ /\S/) {
            if ($self->_is_plate) {
                push @$errors, "Wells of a genotyping plate have no seedlots here.";
                next;
            }
            ($seedlot_name{$unit_id} = $change->{seedlot_name}) =~ s/^\s+|\s+$//g;
        }
        my $new_stock_id = $change->{new_stock_id};
        if ((!defined($new_stock_id) || $new_stock_id eq '') && defined($not_planted)) {
            $new_stock_id = $unit->{stock_id};   # only the planting status changes
        }
        my $new_stock = (defined($new_stock_id) && $new_stock_id =~ /^\d+$/) ? ($new_stocks{$new_stock_id} //= $schema->resultset('Stock::Stock')->find({ stock_id => $new_stock_id })) : undef;
        if (!$new_stock) {
            push @$errors, "The new stock for plot $unit->{plot_name} does not exist.";
            next;
        }
        # a plot that keeps its stock keeps it, whatever has become of the stock since
        if ($new_stock_id != $unit->{stock_id}) {
            if ($new_stock->is_obsolete) {
                push @$errors, "Stock ".$new_stock->uniquename." is obsolete.";
                next;
            }
            if (!$allowed_type{$new_stock->type_id}) {
                push @$errors, "Stock ".$new_stock->uniquename." is not ".stock_type_description(@$allowed_types).".";
                next;
            }
        }
        if (defined($change->{new_plot_name}) && $change->{new_plot_name} =~ /\S/) {
            if ($self->_is_plate) {
                push @$errors, "Wells of a genotyping plate cannot be renamed here.";
                next;
            }
            (my $name = $change->{new_plot_name}) =~ s/^\s+|\s+$//g;
            if ($name ne $unit->{plot_name}) {
                $explicit_name{$unit_id} = $name;
            } else {
                $keep_name{$unit_id} = 1;
            }
        }
        if ($new_stock_id == $unit->{stock_id}) {
            push @{$plan{unchanged}}, $unit->{plot_name} if !exists($explicit_name{$unit_id}) && !exists($new_not_planted{$unit_id});
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
    foreach my $unit_id (sort { $a <=> $b } keys %new_not_planted) {
        $after{$unit_id}->{not_planted} = $new_not_planted{$unit_id};
        push @{$plan{planting}}, { plot_id => $unit_id + 0, plot_name => $units->{$unit_id}->{plot_name}, not_planted => $new_not_planted{$unit_id} };
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
            next if exists($new_name{$unit_id}) || $keep_name{$unit_id};
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
    my $children = $self->_is_plate ? {} : $self->_children([ keys %new_stock_by_unit, keys %new_name, keys %new_not_planted ]);

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
    # labels in the field and files with the old names would point to the other plot
    my %plot_named = map { $_->{plot_name} => $_->{plot_id} } values %$units;
    my @taken_names = grep { $_->{type} eq 'plot' && exists($plot_named{ $_->{new_name} }) && $plot_named{ $_->{new_name} } != $_->{stock_id} } @{$plan{renames}};
    if (@taken_names) {
        push @{$plan{warnings}}, scalar(@taken_names)." plot(s) get a name that another plot has now (for example $taken_names[0]->{old_name} gets the name $taken_names[0]->{new_name}): labels and files with the old names would point to the wrong plot. Keep the plot names if labels are in the field or data was collected with them.";
    }

    # warnings
    foreach my $c (@{$plan{changes}}) {
        my $external = $children->{ $c->{plot_id} }->{external} || [];
        if (@$external) {
            push @{$plan{warnings}}, scalar(@$external)." sample(s) of plot $c->{plot_name} in other trials (for example ".$external->[0]->{name}.") keep $c->{old_stock_name}.";
        }
    }
    if (!$self->_is_plate) {
        $self->_plan_checks(\%plan, $units, \%after);
        $self->_plan_phenotype_and_cross_warnings(\%plan, $children, \%after);
        $self->_plan_not_planted(\%plan, $children, $options);
        $self->_plan_seedlots(\%plan, $units, \%after, \%seedlot_name);
        my %seedlot_changed = map { $_->{plot_name} => 1 } @{$plan{seedlots}};
        $plan{unchanged} = [ grep { !$seedlot_changed{$_} } @{$plan{unchanged}} ];
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
then. With the option plan_digest (from the summary of a preview) it also
dies when the plan is not the one of the preview any more, for example
because someone changed the trial in between. Returns the plan.

=cut

sub apply {
    my $self = shift;
    my $changes = shift;
    my $options = shift || {};
    my $schema = $self->schema;
    my $plan;
    $schema->txn_do(sub {
        $plan = $self->plan($changes, $options);
        if (@{$plan->{errors}}) {
            die join("\n", @{$plan->{errors}})."\n";
        }
        if (defined($options->{plan_digest}) && length($options->{plan_digest}) && $options->{plan_digest} ne $self->plan_digest($plan)) {
            die "The trial changed after the preview, so the changes are not the ones you saw; check them again.\n";
        }
        $self->_execute($plan);
    });
    return $plan;
}

=head2 plan_digest($plan)

A digest of what a plan changes, to make sure that apply() carries out the
plan the user saw in a preview.

=cut

sub plan_digest {
    my $self = shift;
    my $plan = shift;
    my $to_delete = $plan->{phenotypes_to_delete} || {};
    my @parts = (
        (map { "change $_->{plot_id} $_->{new_stock_id}" } @{$plan->{changes}}),
        (map { "planting $_->{plot_id} $_->{not_planted}" } @{$plan->{planting}}),
        (map { "replicate $_->{plot_id} $_->{new}" } @{$plan->{replicates}}),
        (map { "rename $_->{stock_id} $_->{new_name}" } @{$plan->{renames}}),
        (map { "check $_->{plot_id} $_->{new}" } @{$plan->{checks}}),
        (map { "entry $_->{stock_id} $_->{entry_number}" } @{$plan->{entry_numbers}}),
        (map { "seedlot $_->{type} $_->{transaction_id} $_->{plot_id} $_->{seedlot_id}" } @{$plan->{seedlots}}),
        (map { "delete phenotype $_" } @{ $to_delete->{phenotype_ids} || [] }),
        (map { "delete experiment $_" } @{ $to_delete->{nd_experiment_ids} || [] }),
    );
    return md5_hex(encode_utf8(join("\n", sort @parts)));
}

sub _execute {
    my $self = shift;
    my $plan = shift;
    my $dbh = $self->schema->storage->dbh;
    my $ids = $self->_cvterm_ids;

    # stocks of the units, and of their plants, subplots and tissue samples in this trial
    my $children = $self->_is_plate ? {} : $self->_children([ map { $_->{plot_id} } @{$plan->{changes}}, @{$plan->{replicates}} ]);
    my $children_of = sub { return [ map { $_->{stock_id} } @{ $children->{ $_[0] }->{in_trial} || [] } ]; };
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

    # seed transactions follow the packets (see _plan_seedlots)
    if (@{$plan->{seedlots}}) {
        my $seed_transaction = $ids->{seed_transaction};
        my $rank_h = $dbh->prepare("SELECT COALESCE(MAX(rank), -1) + 1 FROM stock_relationship WHERE subject_id = ? AND object_id = ? AND type_id = ?");
        my $next_rank = sub { $rank_h->execute(@_, $seed_transaction); return ($rank_h->fetchrow_array())[0]; };
        my $value_h = $dbh->prepare("SELECT value FROM stock_relationship WHERE stock_relationship_id = ?");
        my $update_h = $dbh->prepare("UPDATE stock_relationship SET subject_id = ?, object_id = ?, rank = ?, value = COALESCE(?, value)
            WHERE stock_relationship_id = ? AND subject_id = ? AND object_id = ? AND type_id = ?");
        my %recount;
        foreach my $s (@{$plan->{seedlots}}) {
            my ($subject, $object, $value) = ($s->{plot_id}, $s->{seedlot_id}, undef);
            my ($old_subject, $old_object) = ($s->{plot_id}, $s->{seedlot_id});
            if ($s->{type} eq 'move') {
                $old_subject = $s->{from_plot_id};
            } elsif ($s->{type} eq 'seedlot') {
                $old_object = $s->{old_seedlot_id};
                $recount{$old_object} = $recount{$object} = 1;
            } else {
                # seed taken from the seedlot: a transaction from the seedlot to itself
                $subject = $s->{seedlot_id};
                $value_h->execute($s->{transaction_id});
                my ($json) = $value_h->fetchrow_array();
                # the amount must stay, or the inventory would change
                my $v = decode_stored_json($json // '{}');
                $v->{factor} = -1;
                $v->{description} = join(' ', grep { defined($_) && length($_) } $v->{description}, "(Correction of trial ".$self->_trial_name.": no plot has this packet; it was linked to plot $s->{plot_name}.)");
                $value = encode_json($v);
            }
            my $rows = $update_h->execute($subject, $object, $next_rank->($subject, $object), $value, $s->{transaction_id}, $old_subject, $old_object, $seed_transaction);
            if ($rows != 1) {
                die "The seed transaction of plot ".($s->{from_plot_name} // $s->{plot_name})." was changed by someone else in the meantime; nothing was changed.\n";
            }
        }
        foreach my $seedlot_id (sort { $a <=> $b } keys %recount) {
            my $seedlot = CXGN::Stock::Seedlot->new(schema => $self->schema, seedlot_id => $seedlot_id);
            $seedlot->set_current_count_property();
            $seedlot->set_current_weight_property();
        }
    }

    # replicates of the plots, and of their plants, subplots and tissue samples that have one
    my $rep_h = $dbh->prepare("UPDATE stockprop SET value = ? WHERE stock_id = ANY(?) AND type_id = ?");
    foreach my $r (@{$plan->{replicates}}) {
        $rep_h->execute($r->{new}, [ $r->{plot_id}, @{ $children_of->($r->{plot_id}) } ], $ids->{replicate});
    }

    # check marks of the plots, and of their plants, subplots and tissue samples
    my $uncheck_h = $dbh->prepare("DELETE FROM stockprop WHERE stock_id = ANY(?) AND type_id = ?");
    foreach my $k (@{$plan->{checks}}) {
        my @stock_ids = ($k->{plot_id}, @{ $children_of->($k->{plot_id}) });
        $uncheck_h->execute(\@stock_ids, $ids->{is_a_control});
        if ($k->{new}) {
            $self->schema->resultset('Stock::Stockprop')->create({ stock_id => $_, type_id => $ids->{is_a_control}, value => '1', rank => 0 }) for @stock_ids;
        }
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

    # planting status, and the phenotypes of plots that were not planted
    my $planting_h = $dbh->prepare("DELETE FROM stockprop WHERE stock_id = ? AND type_id = ?");
    foreach my $p (@{$plan->{planting}}) {
        $planting_h->execute($p->{plot_id}, $ids->{not_planted});
        if ($p->{not_planted}) {
            $self->schema->resultset('Stock::Stockprop')->create({ stock_id => $p->{plot_id}, type_id => $ids->{not_planted}, value => '1', rank => 0 });
        }
    }
    my $to_delete = $plan->{phenotypes_to_delete};
    if (@{ $to_delete->{nd_experiment_ids} }) {
        $dbh->prepare("DELETE FROM phenotype WHERE phenotype_id = ANY(?)")->execute($to_delete->{phenotype_ids});
        $dbh->prepare("DELETE FROM phenome.nd_experiment_md_json WHERE nd_experiment_id = ANY(?)")->execute($to_delete->{md_experiment_ids} || []);
        # the experiments that have no phenotypes left, as CXGN::Project::delete_phenotype_values_and_nd_experiment_md_values does
        my $empty_h = $dbh->prepare("SELECT ne.nd_experiment_id FROM nd_experiment ne LEFT JOIN nd_experiment_phenotype nep ON nep.nd_experiment_id = ne.nd_experiment_id
            WHERE ne.nd_experiment_id = ANY(?) AND nep.phenotype_id IS NULL");
        $empty_h->execute($to_delete->{nd_experiment_ids});
        my @empty;
        while (my ($nd_experiment_id) = $empty_h->fetchrow_array()) { push @empty, $nd_experiment_id; }
        if (@empty) {
            foreach my $table ('phenome.nd_experiment_md_files', 'phenome.nd_experiment_md_json', 'phenome.nd_experiment_md_images') {
                $dbh->prepare("DELETE FROM $table WHERE nd_experiment_id = ANY(?)")->execute(\@empty);
            }
            $dbh->prepare("DELETE FROM nd_experiment WHERE nd_experiment_id = ANY(?)")->execute(\@empty);
        }
    }

    if (@{$plan->{changes}} || @{$plan->{replicates}} || @{$plan->{renames}} || @{$plan->{checks}} || @{$plan->{planting}} || @{$plan->{seedlots}}) {
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

sub _is_true {
    my $value = shift;
    return (defined($value) && $value =~ /^\s*(1|true|yes|t|y)\s*$/i) ? 1 : 0;
}

# check marks: a plot is a check plot when its accession is a check accession of this trial
sub _plan_checks {
    my $self = shift;
    my $plan = shift;
    my $units = shift;
    my $after = shift;
    return if !@{$plan->{changes}};

    my (%total, %checked);
    foreach my $u (values %$units) {
        next if !defined($u->{stock_id});
        $total{ $u->{stock_id} }++;
        $checked{ $u->{stock_id} }++ if _is_true($u->{is_a_control});
    }
    my %after_stocks = map { $_->{stock_id} => 1 } grep { defined $_->{stock_id} } values %$after;
    my %takers;
    foreach my $c (@{$plan->{changes}}) {
        $takers{ $c->{old_stock_id} }->{ $c->{new_stock_id} } = 1;
    }
    my %mixed_warned;
    foreach my $c (@{$plan->{changes}}) {
        my $is_check = _is_true($units->{ $c->{plot_id} }->{is_a_control});
        my $new = $c->{new_stock_id};
        my $should_be_check;
        if ($total{$new}) {
            if (($checked{$new} // 0) == $total{$new}) {
                $should_be_check = 1;
            } elsif (!$checked{$new}) {
                $should_be_check = 0;
            } else {
                push @{$plan->{warnings}}, "$c->{new_stock_name} is a check on some plots of this trial and not on others, so the check marks of its new plots are left as they are." if !$mixed_warned{$new}++;
                next;
            }
        } elsif (!$after_stocks{ $c->{old_stock_id} } && scalar(keys %{ $takers{ $c->{old_stock_id} } }) == 1) {
            # the new accession takes the place of the old one everywhere
            $should_be_check = $is_check;
        } else {
            $should_be_check = 0;
        }
        if ($should_be_check != $is_check) {
            push @{$plan->{checks}}, { plot_id => $c->{plot_id}, plot_name => $c->{plot_name}, old => $is_check, new => $should_be_check };
        }
    }
}

# phenotypes and crosses of the changed plots and of their plants, subplots and tissue samples
sub _plan_phenotype_and_cross_warnings {
    my $self = shift;
    my $plan = shift;
    my $children = shift;
    my $after = shift;
    my @plot_ids = map { $_->{plot_id} } grep { !_is_true($after->{ $_->{plot_id} }->{not_planted}) } @{$plan->{changes}};
    return if !@plot_ids;
    my $dbh = $self->schema->storage->dbh;
    my $ids = $self->_cvterm_ids;

    my %plot_of = map { $_ => $_ } @plot_ids;
    foreach my $plot_id (@plot_ids) {
        $plot_of{ $_->{stock_id} } = $plot_id for @{ $children->{$plot_id}->{in_trial} || [] };
    }
    my @stock_ids = keys %plot_of;
    my %plot_name = map { $_->{plot_id} => $_->{plot_name} } @{$plan->{changes}};
    my %old_stock = map { $_->{plot_id} => $_->{old_stock_name} } @{$plan->{changes}};

    # phenotypes other than treatments, or high-dimensional data
    my $h = $dbh->prepare("SELECT DISTINCT nes.stock_id FROM nd_experiment_stock nes
        WHERE nes.stock_id = ANY(?) AND (
            EXISTS (SELECT 1 FROM nd_experiment_phenotype nep JOIN phenotype p ON p.phenotype_id = nep.phenotype_id
                LEFT JOIN cvterm trait ON trait.cvterm_id = p.cvalue_id
                LEFT JOIN dbxref x ON x.dbxref_id = trait.dbxref_id
                LEFT JOIN db ON db.db_id = x.db_id
                WHERE nep.nd_experiment_id = nes.nd_experiment_id AND COALESCE(right(db.name, 10), '') <> '_TREATMENT')
            OR EXISTS (SELECT 1 FROM phenome.nd_experiment_md_json j WHERE j.nd_experiment_id = nes.nd_experiment_id))");
    $h->execute(\@stock_ids);
    my %phenotyped_plots;
    while (my ($stock_id) = $h->fetchrow_array()) { $phenotyped_plots{ $plot_of{$stock_id} } = 1; }
    $plan->{plots_with_phenotypes} = scalar(keys %phenotyped_plots);
    if (%phenotyped_plots) {
        push @{$plan->{warnings}}, scalar(keys %phenotyped_plots)." plot(s) already have phenotypes. The values stay with their plot, so they count for the new accession; run the analyses of this trial again.";
        if (grep { $_->{type} eq 'plot' && $phenotyped_plots{ $_->{stock_id} } } @{$plan->{renames}}) {
            push @{$plan->{warnings}}, "Phenotype files and Field Book files with the old plot names will not match the renamed plots. Keep the plot names to avoid that.";
        }
    }

    my %role = map { ($ids->{$_} // -1) => ($_ =~ /^female/ ? 'female' : 'male') } qw(female_plot_of female_plant_of male_plot_of male_plant_of);
    my @cross_types = grep { defined } map { $ids->{$_} } qw(female_plot_of female_plant_of male_plot_of male_plant_of);
    return if !@cross_types;
    $h = $dbh->prepare("SELECT r.subject_id, r.type_id, c.uniquename FROM stock_relationship r
        JOIN stock c ON c.stock_id = r.object_id
        WHERE r.subject_id = ANY(?) AND r.type_id = ANY(?) ORDER BY c.uniquename");
    $h->execute(\@stock_ids, \@cross_types);
    while (my ($stock_id, $type_id, $cross_name) = $h->fetchrow_array()) {
        my $plot_id = $plot_of{$stock_id};
        push @{$plan->{warnings}}, "Cross $cross_name used plot $plot_name{$plot_id} as $role{$type_id} parent. The cross keeps its recorded $role{$type_id} parent ($old_stock{$plot_id} when it was made from this plot); correct the cross if needed.";
    }
}

# Plots marked as not planted: their phenotypes and high-dimensional data (and
# those of their plants, subplots and tissue samples) are deleted with the
# option delete_phenotypes, or are an error. Treatments are part of the design
# and stay; crosses that used the plots as parents get a warning.
sub _plan_not_planted {
    my $self = shift;
    my $plan = shift;
    my $children = shift;
    my $options = shift || {};
    my @plot_ids = map { $_->{plot_id} } grep { $_->{not_planted} } @{$plan->{planting}};
    return if !@plot_ids;
    my %plot_name = map { $_->{plot_id} => $_->{plot_name} } @{$plan->{planting}};

    my %plot_of = map { $_ => $_ } @plot_ids;
    foreach my $plot_id (@plot_ids) {
        my @in_trial = @{ $children->{$plot_id}->{in_trial} || [] };
        $plot_of{ $_->{stock_id} } = $plot_id for @in_trial;
        if (@in_trial) {
            push @{$plan->{warnings}}, "Plot $plot_name{$plot_id} is marked as not planted but has ".scalar(@in_trial)." plant(s), subplot(s) or tissue sample(s); they are kept.";
        }
    }
    my $dbh = $self->schema->storage->dbh;
    my $ids = $self->_cvterm_ids;
    my @cross_types = grep { defined } map { $ids->{$_} } qw(female_plot_of female_plant_of male_plot_of male_plant_of);
    if (@cross_types) {
        my $cross_h = $dbh->prepare("SELECT DISTINCT r.subject_id, c.uniquename FROM stock_relationship r JOIN stock c ON c.stock_id = r.object_id
            WHERE r.subject_id = ANY(?) AND r.type_id = ANY(?) ORDER BY c.uniquename");
        $cross_h->execute([ keys %plot_of ], \@cross_types);
        while (my ($stock_id, $cross_name) = $cross_h->fetchrow_array()) {
            push @{$plan->{warnings}}, "Cross $cross_name used plot $plot_name{ $plot_of{$stock_id} } (or a plant of it) as a parent, but the plot is marked as not planted; correct the cross if needed.";
        }
    }

    # phenotypes other than treatments (traits of an ontology *_TREATMENT), and experiments with high-dimensional data
    my $h = $dbh->prepare("SELECT DISTINCT nes.stock_id, nep.phenotype_id, nes.nd_experiment_id FROM nd_experiment_stock nes
        JOIN nd_experiment_phenotype nep ON nep.nd_experiment_id = nes.nd_experiment_id
        JOIN phenotype p ON p.phenotype_id = nep.phenotype_id
        LEFT JOIN cvterm trait ON trait.cvterm_id = p.cvalue_id
        LEFT JOIN dbxref x ON x.dbxref_id = trait.dbxref_id
        LEFT JOIN db ON db.db_id = x.db_id
        WHERE nes.stock_id = ANY(?) AND COALESCE(right(db.name, 10), '') <> '_TREATMENT'");
    $h->execute([ keys %plot_of ]);
    my (%phenotypes, %experiments, %plots_with);
    while (my ($stock_id, $phenotype_id, $nd_experiment_id) = $h->fetchrow_array()) {
        $phenotypes{$phenotype_id} = 1;
        $experiments{$nd_experiment_id} = 1;
        $plots_with{ $plot_of{$stock_id} } = 1;
    }
    my $md_h = $dbh->prepare("SELECT DISTINCT nes.stock_id, nes.nd_experiment_id FROM nd_experiment_stock nes
        JOIN phenome.nd_experiment_md_json j ON j.nd_experiment_id = nes.nd_experiment_id
        WHERE nes.stock_id = ANY(?)");
    $md_h->execute([ keys %plot_of ]);
    my %md_experiments;
    while (my ($stock_id, $nd_experiment_id) = $md_h->fetchrow_array()) {
        $md_experiments{$nd_experiment_id} = 1;
        $experiments{$nd_experiment_id} = 1;
        $plots_with{ $plot_of{$stock_id} } = 1;
    }
    return if !%phenotypes && !%md_experiments;
    $plan->{not_planted_phenotypes} = scalar(keys %phenotypes) + scalar(keys %md_experiments);
    my $what = scalar(keys %phenotypes)." phenotype value(s)".(%md_experiments ? " and ".scalar(keys %md_experiments)." set(s) of high-dimensional data" : "");
    my @names = map { $plot_name{$_} } sort { $a <=> $b } keys %plots_with;
    my $which = scalar(@names) > 3 ? join(', ', @names[0 .. 2]).' and '.(scalar(@names) - 3).' more' : join(', ', @names);
    if ($options->{delete_phenotypes}) {
        # only experiments of these plots alone, so that no value of another plot goes with them
        my $shared_h = $dbh->prepare("SELECT DISTINCT nd_experiment_id FROM nd_experiment_stock WHERE nd_experiment_id = ANY(?) AND NOT (stock_id = ANY(?))");
        $shared_h->execute([ keys %experiments ], [ keys %plot_of ]);
        if ($shared_h->fetchrow_array()) {
            push @{$plan->{errors}}, "Phenotypes of the plots marked as not planted ($which) were stored together with those of other plots; delete those values on the field map heatmap first.";
            return;
        }
        $plan->{phenotypes_to_delete} = { phenotype_ids => [ sort { $a <=> $b } keys %phenotypes ], nd_experiment_ids => [ sort { $a <=> $b } keys %experiments ], md_experiment_ids => [ sort { $a <=> $b } keys %md_experiments ] };
        push @{$plan->{warnings}}, "$what of the plots marked as not planted ($which) are deleted.";
    } else {
        push @{$plan->{errors}}, "$what were stored for plots that are marked as not planted ($which). They would count for an accession that did not grow there: delete them with this change, or keep the plots planted.";
    }
}

# Seed transactions (seedlot -> plot) follow the packets. A plot that gets
# another accession takes over the transaction of a plot in this change that
# lost that accession, the nearest one by plot number (a shift moves packets a
# few places), or the transaction from the seedlot in its seedlot_name. A
# seedlot_name of another seedlot of the same accession moves the plot's own
# transaction to that seedlot. So a plot keeps at most one seedlot, and it holds
# the accession of the plot. A transaction that no plot takes, for example of a
# packet planted into a border or of a place left empty, becomes seed taken from
# the seedlot, so the inventory does not change. Seedlots harvested from the
# changed plots get a warning.
sub _plan_seedlots {
    my $self = shift;
    my $plan = shift;
    my $units = shift;
    my $after = shift;
    my $seedlot_name = shift || {};
    my $ids = $self->_cvterm_ids;
    return if !$ids->{seed_transaction} || !$ids->{seedlot} || !$ids->{collection_of};
    my $dbh = $self->schema->storage->dbh;

    my %changed = map { $_->{plot_id} => 1 } @{$plan->{changes}};
    my %planting = map { $_->{plot_id} => 1 } @{$plan->{planting}};
    my %plot_ids = map { $_ => 1 } (keys %changed, keys %planting, keys %$seedlot_name);
    return if !%plot_ids;

    # the planting transactions of these plots, with the stock their seedlot holds
    my $h = $dbh->prepare("SELECT r.stock_relationship_id, r.subject_id, s.stock_id, s.uniquename, MIN(c.subject_id)
        FROM stock_relationship r
        JOIN stock s ON s.stock_id = r.object_id AND s.type_id = ?
        LEFT JOIN stock_relationship c ON c.object_id = s.stock_id AND c.type_id = ?
        WHERE r.type_id = ? AND r.subject_id = ANY(?)
        GROUP BY r.stock_relationship_id, r.subject_id, s.stock_id, s.uniquename ORDER BY r.stock_relationship_id");
    $h->execute($ids->{seedlot}, $ids->{collection_of}, $ids->{seed_transaction}, [ keys %plot_ids ]);
    my %own;
    while (my ($transaction_id, $plot_id, $seedlot_id, $name, $content_id) = $h->fetchrow_array()) {
        push @{ $own{$plot_id} }, { transaction_id => $transaction_id, plot_id => $plot_id, seedlot_id => $seedlot_id, seedlot_name => $name, content_id => $content_id };
    }

    # the seedlots named in the change
    my %seedlot;
    if (%$seedlot_name) {
        my $seedlot_h = $dbh->prepare("SELECT s.stock_id, s.uniquename, MIN(c.subject_id) FROM stock s
            LEFT JOIN stock_relationship c ON c.object_id = s.stock_id AND c.type_id = ?
            WHERE s.uniquename = ANY(?) AND s.type_id = ? GROUP BY s.stock_id, s.uniquename");
        $seedlot_h->execute($ids->{collection_of}, [ values %$seedlot_name ], $ids->{seedlot});
        while (my ($seedlot_id, $name, $content_id) = $seedlot_h->fetchrow_array()) {
            $seedlot{$name} = { seedlot_id => $seedlot_id, content_id => $content_id };
        }
    }

    # what a seedlot holds counts for its stock and, for a cross, for the families the cross is a member of
    # (plots of a family name are planted from seedlots of its crosses)
    my %holds;
    my @contents = grep { defined } map { $_->{content_id} } (values %seedlot, map { @$_ } values %own);
    $holds{$_}->{$_} = 1 for @contents;
    if (@contents && $ids->{cross_member_of}) {
        my $family_h = $dbh->prepare("SELECT subject_id, object_id FROM stock_relationship WHERE type_id = ? AND subject_id = ANY(?)");
        $family_h->execute($ids->{cross_member_of}, \@contents);
        while (my ($cross_id, $family_id) = $family_h->fetchrow_array()) { $holds{$cross_id}->{$family_id} = 1; }
    }
    my $holds = sub { my ($content_id, $stock_id) = @_; return defined($content_id) && $holds{$content_id}->{$stock_id}; };

    # what each plot needs now: no seedlot (not planted), a given seedlot, or one of its accession
    my $by_number = sub { _compare_plot_numbers($units->{ $_[0] }->{plot_number}, $units->{ $_[1] }->{plot_number}) || $_[0] <=> $_[1] };
    my %want;
    foreach my $plot_id (sort { $by_number->($a, $b) } keys %plot_ids) {
        my $state = $after->{$plot_id};
        if (_is_true($state->{not_planted})) {
            $want{$plot_id} = undef;
            next;
        }
        my $name = $seedlot_name->{$plot_id};
        # the seedlot the plot has now is no change (a cell left as it was)
        if (defined($name) && !grep { $_->{seedlot_name} eq $name } @{ $own{$plot_id} || [] }) {
            my $s = $seedlot{$name};
            if (!$s) {
                push @{$plan->{errors}}, "Seedlot $name (plot $state->{plot_name}) does not exist.";
            } elsif (!$holds->($s->{content_id}, $state->{stock_id})) {
                push @{$plan->{errors}}, "Seedlot $name does not hold $state->{stock_name}, the accession of plot $state->{plot_name}.";
            } else {
                $want{$plot_id} = { seedlot_id => $s->{seedlot_id}, seedlot_name => $name };
            }
        } elsif ($changed{$plot_id} || $planting{$plot_id}) {
            $want{$plot_id} = { content_id => $state->{stock_id} };
        }
    }
    return if @{$plan->{errors}};
    my $fits = sub {
        my ($t, $want) = @_;
        return 0 if !$want;
        return $t->{seedlot_id} == $want->{seedlot_id} if $want->{seedlot_id};
        return $holds->($t->{content_id}, $want->{content_id});
    };

    # transactions that do not fit their plot any more are free for the plots that need one
    my (@free, @need);
    foreach my $plot_id (sort { $by_number->($a, $b) } keys %want) {
        my $own = $own{$plot_id} || [];
        next if grep { $fits->($_, $want{$plot_id}) } @$own;
        push @free, @$own;
        push @need, $plot_id if $want{$plot_id};
    }
    my $distance = sub {
        my ($m, $n) = map { $units->{$_}->{plot_number} } @_;
        return (defined($m) && defined($n) && $m =~ /^\d+$/ && $n =~ /^\d+$/) ? abs($m - $n) : 0;
    };
    # the plots with a given seedlot first, so that the others do not take their transactions
    @need = ((grep { $want{$_}->{seedlot_id} } @need), (grep { !$want{$_}->{seedlot_id} } @need));
    foreach my $plot_id (@need) {
        my $want = $want{$plot_id};
        my ($t) = sort { $distance->($a->{plot_id}, $plot_id) <=> $distance->($b->{plot_id}, $plot_id) || $a->{transaction_id} <=> $b->{transaction_id} } grep { $fits->($_, $want) } @free;
        if ($t) {
            @free = grep { $_ != $t } @free;
            push @{$plan->{seedlots}}, { %$t, type => 'move', from_plot_id => $t->{plot_id}, from_plot_name => $units->{ $t->{plot_id} }->{plot_name}, plot_id => $plot_id, plot_name => $units->{$plot_id}->{plot_name} };
            next;
        }
        if (!$want->{seedlot_id}) {
            push @{$plan->{warnings}}, "Plot $units->{$plot_id}->{plot_name} is planted again but has no seedlot; if it was planted from one, record it with Upload Used Seedlots in Trial." if $planting{$plot_id} && !@{ $own{$plot_id} || [] };
            next;
        }
        # another seedlot of the plot's accession: the plot's own transaction gets it
        ($t) = grep { $_->{plot_id} == $plot_id } @free;
        if ($t) {
            @free = grep { $_ != $t } @free;
            push @{$plan->{seedlots}}, { %$t, type => 'seedlot', plot_name => $units->{$plot_id}->{plot_name}, old_seedlot_id => $t->{seedlot_id}, old_seedlot_name => $t->{seedlot_name}, seedlot_id => $want->{seedlot_id}, seedlot_name => $want->{seedlot_name} };
        } else {
            push @{$plan->{warnings}}, "Plot $units->{$plot_id}->{plot_name} has no seed transaction, so seedlot $want->{seedlot_name} is not recorded for it; record it with Upload Used Seedlots in Trial.";
        }
    }
    foreach my $t (sort { $a->{transaction_id} <=> $b->{transaction_id} } @free) {
        push @{$plan->{seedlots}}, { %$t, type => 'taken', plot_name => $units->{ $t->{plot_id} }->{plot_name} };
    }

    my @harvested_from = grep { $changed{$_} || ($planting{$_} && _is_true($after->{$_}->{not_planted})) } keys %plot_ids;
    if (@harvested_from) {
        my $harvest_h = $dbh->prepare("SELECT r.object_id, s.uniquename FROM stock_relationship r
            JOIN stock s ON s.stock_id = r.subject_id AND s.type_id = ?
            WHERE r.type_id = ? AND r.object_id = ANY(?) ORDER BY s.uniquename");
        $harvest_h->execute($ids->{seedlot}, $ids->{seed_transaction}, \@harvested_from);
        while (my ($plot_id, $name) = $harvest_h->fetchrow_array()) {
            my $state = $after->{$plot_id};
            push @{$plan->{warnings}}, "Seedlot $name was harvested from plot $state->{plot_name}, which ".(_is_true($state->{not_planted}) ? "is marked as not planted" : "has $state->{stock_name} now")."; correct the seedlot if needed.";
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
        changes => [ map { { plot_name => $_->{plot_name}, old_stock_name => $_->{old_stock_name}, new_stock_name => $_->{new_stock_name} } } @{$plan->{changes}} ],
        unchanged => $plan->{unchanged},
        replicates_changed => scalar(@{$plan->{replicates}}),
        renamed => [ map { { old_name => $_->{old_name}, new_name => $_->{new_name} } } grep { $_->{type} eq 'plot' } @{$plan->{renames}} ],
        not_renamed => $plan->{not_renamed},
        entry_numbers => [ map { { stock_name => $_->{stock_name}, entry_number => $_->{entry_number} } } @{$plan->{entry_numbers}} ],
        checks => [ map { { plot_name => $_->{plot_name}, check => $_->{new} } } @{$plan->{checks}} ],
        planting => [ map { { plot_name => $_->{plot_name}, not_planted => $_->{not_planted} } } @{$plan->{planting}} ],
        seedlots => [ map { my $s = $_; +{ map { $_ => $s->{$_} } grep { defined($s->{$_}) } qw(type seedlot_name plot_name from_plot_name old_seedlot_name) } } @{$plan->{seedlots}} ],
        phenotypes_deleted => scalar(@{ $plan->{phenotypes_to_delete}->{phenotype_ids} }) + scalar(@{ $plan->{phenotypes_to_delete}->{md_experiment_ids} || [] }),
        plots_with_phenotypes => $plan->{plots_with_phenotypes},
        warnings => $plan->{warnings},
        plan_digest => $self->plan_digest($plan),
    };
}

__PACKAGE__->meta->make_immutable;

1;
