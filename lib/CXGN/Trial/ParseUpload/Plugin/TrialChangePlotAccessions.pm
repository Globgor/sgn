package CXGN::Trial::ParseUpload::Plugin::TrialChangePlotAccessions;

use Moose::Role;
use CXGN::Stock::StockLookup;
use CXGN::File::Parse;
use SGN::Model::Cvterm;
use Data::Dumper;
use CXGN::List::Validate;
use CXGN::List::Transform;
use CXGN::Trial;
use CXGN::Stock::RelatedStocks;

my @REQUIRED_COLUMNS = qw|plot_name accession_name|;
my @OPTIONAL_COLUMNS = qw|new_plot_name not_planted|;
my $parsed_accession_ids = {};

sub _validate_with_plugin {
    my $self = shift;
    my $filename = $self->get_filename();
    my $schema = $self->get_chado_schema();
    my $trial_id = $self->get_trial_id();
    my @error_messages;
    my %errors;

    my $parser = CXGN::File::Parse->new(
        file => $filename,
        required_columns => \@REQUIRED_COLUMNS,
        optional_columns => \@OPTIONAL_COLUMNS,
        column_aliases => {
            'plot_name' => ['plot name'],
            'new_plot_name' => ['new plot name'],
            'not_planted' => ['not planted'],
            'accession_name' => ['accession name', 'accession', 'cross_unique_id', 'cross unique id', 'family_name', 'family name']
        },
        unique_only_columns => ['plot_name', 'new_plot_name']
    );

    my $parsed = $parser->parse();
    my $parsed_errors = $parsed->{'errors'};
    my $parsed_data = $parsed->{'data'};
    my $parsed_values = $parsed->{'values'};

    # A planting order file (Download Plot Order) can be uploaded as it is: its
    # rows of other types than plot (borders, gaps, subplots, plants) are skipped.
    my %skip_row = map { $_->{_row} => 1 } grep { defined($_->{type}) && $_->{type} =~ /\S/ && lc($_->{type}) ne 'plot' } @{ $parsed_data || [] };
    if (%skip_row) {
        $parsed_errors = [ grep {
            my $error = $_;
            if ($error =~ /does not have a value in row (\d+)$/) {
                !$skip_row{$1};
            } elsif ($error =~ /appears more than once in rows ([\d,]+)$/) {
                scalar(grep { !$skip_row{$_} } split(/,/, $1)) > 1;
            } else {
                1;
            }
        } @$parsed_errors ];
        $parsed_data = [ grep { !$skip_row{ $_->{_row} } } @$parsed_data ];
    }

    if (@$parsed_errors) {
        push @error_messages, join (". ", @$parsed_errors);
    }

    my @old_plot_names = @{$parsed_values->{'plot_name'}};
    my @accessions = @{$parsed_values->{'accession_name'}};
    my @new_plot_names;
    if ($parsed_values->{'new_plot_name'}) {
        @new_plot_names = @{$parsed_values->{'new_plot_name'}};
    }
    my $validator = CXGN::List::Validate->new();

    my $trial = CXGN::Trial->new({
        bcs_schema => $schema,
        trial_id => $trial_id
    });

    my %trial_plots = map {$_->[1] => 1} @{$trial->get_observation_units_direct('plot')};
    foreach my $old_plot_name (@old_plot_names) {
        if (!exists($trial_plots{$old_plot_name})) {
            push @error_messages, "Plot $old_plot_name does not exist in this trial.";
        }
    }

    my $transform = CXGN::List::Transform->new();
    my $validate_plots = $transform->transform($schema, 'plots_2_plot_ids', \@old_plot_names);
    if (scalar(@{$validate_plots->{'missing'}}) > 0) {
        push @error_messages, "The following plots were not found in the database: ".join(";",@{$validate_plots->{'missing'}});
    }

    my @plot_ids = @{$validate_plots->{'transform'}};
    if (scalar @plot_ids > 0) {
        my $related_seedlots = CXGN::Stock::RelatedStocks->new({dbic_schema => $schema, stock_ids =>\@plot_ids});
        my $seedlots = $related_seedlots->get_plots_related_seedlots();
        if (scalar @$seedlots > 0) {
            foreach my $seedlot (@$seedlots) {
                push @error_messages, "Plot: $seedlot->[4] is associated with seedlot: $seedlot->[2]. Please delete seedlot transaction linked to the plot first.";
            }
        }
    }

    my $validate_stocks = $transform->transform($schema, 'stocks_2_stock_ids', \@accessions);
    if (scalar(@{$validate_stocks->{'missing'}}) > 0) {
        push @error_messages, "The following accessions were not found in the database: ".join(", ", @{$validate_stocks->{'missing'}});
    } else {
        foreach my $accession_id (@{$validate_stocks->{'transform'}}) {
            my $accession_name = shift(@accessions);
            $parsed_accession_ids->{$accession_name} = $accession_id;
        }
    }

    # not_planted: 1 (or yes, true, x) marks the plot as not planted, 0 (or no,
    # false) as planted; an empty cell leaves it as it is
    foreach my $row (@$parsed_data) {
        my $value = $row->{'not_planted'};
        next if !defined($value) || $value !~ /\S/;
        if (_not_planted_value($value) eq '') {
            push @error_messages, "Plot $row->{'plot_name'}: not_planted must be 1 (not planted) or 0 (planted), not $value.";
        }
    }

    if (scalar(@new_plot_names) > 0) {
        my $validate_new_stocks = $validator->validate($schema, 'new_stocks', \@new_plot_names);
        foreach my $new_name (@{$validate_new_stocks->{invalid}}) { #new name is invalid if any stock, obsolete or not, is found in the db
            push @error_messages, "New plot name $new_name already exists as a stock in the database. ";
        }
    }

    if (scalar(@error_messages) > 0) {
        $self->_set_parse_errors({
            'error_messages' => \@error_messages
        });
        return 0;
    }

    $self->_set_parsed_data({
        parsed => $parsed_data
    });

    return 1; #returns true if validation passed

}


sub _parse_with_plugin {
    my $self = shift;
    my $filename = $self->get_filename();
    my $schema = $self->get_chado_schema();
    my $trial_id = $self->get_trial_id();

    my $parsed_entries = {};

    my $parsed_data = $self->_parsed_data()->{parsed};

    foreach my $row (@$parsed_data) {
        $parsed_entries->{$row->{'plot_name'}} = {
            'old_plot_name' => $row->{'plot_name'},
            'new_plot_name' => $row->{'new_plot_name'} ? $row->{'new_plot_name'} : '',
            'new_accession_name' => $row->{'accession_name'},
            'new_accession_id' => $parsed_accession_ids->{$row->{'accession_name'}},
            'not_planted' => _not_planted_value($row->{'not_planted'}),
        };
    }

    $self->_set_parsed_data($parsed_entries);
    return 1;
}

# 1, 0, '' for anything else (an empty cell included)
sub _not_planted_value {
    my $value = shift;
    return '' if !defined($value);
    $value =~ s/^\s+|\s+$//g;
    return 1 if $value =~ /^(1|yes|y|true|x)$/i;
    return 0 if $value =~ /^(0|no|n|false)$/i;
    return '';
}

1;
