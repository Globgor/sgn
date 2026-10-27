# End-to-end check of what the analyses read after a correction, on a copy of
# the fixture: the phenotype matrix (native tables and the materialized views
# that datasets and downloads use) and the files to collect data in.
# Trial CASS_6Genotypes_Sampling_2015 (phenotyped): a shift of one place from
# plot 201 to 203 (201 stayed empty) and plot 307 not planted.
use strict;
use warnings;
use lib 'lib';
use Bio::Chado::Schema;
use CXGN::Phenotypes::PhenotypeMatrix;
use CXGN::Trial::AccessionChange;
use CXGN::Trial::TrialLayoutDownload;

my $db = shift or die "usage: e2e_check.pl dbname\n";
my $schema = Bio::Chado::Schema->connect("dbi:Pg:dbname=$db;host=breedbase_db", 'postgres', 'postgres', { on_connect_do => [ 'SET search_path TO public,sgn,phenome,metadata' ] });
my $trial_id = $schema->resultset('Project::Project')->find({ name => 'CASS_6Genotypes_Sampling_2015' })->project_id;

sub refresh { system("perl bin/refresh_matviews.pl -H breedbase_db -D $db -U postgres -P postgres -m phenotypes > /dev/null 2>&1") == 0 or die "refresh failed\n"; }
sub matrix {
    my $type = shift;
    my @data = CXGN::Phenotypes::PhenotypeMatrix->new(bcs_schema => $schema, search_type => $type, data_level => 'plot', trial_list => [ $trial_id ])->get_phenotype_matrix();
    my $header = shift @data;
    my %col = map { $header->[$_] => $_ } 0 .. $#$header;
    my @traits = grep { /\|/ } @$header;
    my %rows;
    foreach my $r (@data) {
        $rows{ $r->[ $col{observationUnitName} ] } = {
            germplasm => $r->[ $col{germplasmName} ], block => $r->[ $col{blockNumber} ], rep => $r->[ $col{replicate} ], plot_number => $r->[ $col{plotNumber} ],
            values => join(',', map { $r->[ $col{$_} ] // 'NA' } @traits),
            n_values => scalar(grep { defined($r->[ $col{$_} ]) && $r->[ $col{$_} ] ne '' } @traits),
        };
    }
    return \%rows;
}
sub collect_rows {
    my $output = CXGN::Trial::TrialLayoutDownload->new({ schema => $schema, trial_id => $trial_id, data_level => 'plots', selected_columns => { plot_name => 1, accession_name => 1 }, @_ })->get_layout_output();
    my ($header, @rows) = @{ $output->{output} };
    return ($header, \@rows);
}

refresh();
my %before = (Native => matrix('Native'), MaterializedViewTable => matrix('MaterializedViewTable'));
my (undef, $collect_before) = collect_rows(exclude_not_planted => 1);

my $ac = CXGN::Trial::AccessionChange->new({ schema => $schema, trial_id => $trial_id });
my %by_number = map { $_->{plot_number} => $_ } values %{ $ac->load_units() };
my $shift = $ac->changes_for_shift({ from_plot_id => $by_number{201}->{plot_id}, to_plot_id => $by_number{203}->{plot_id}, positions => 1 });
die $shift->{error} if $shift->{error};
$ac->apply($shift->{changes}, { rename_plots => 'none' });
my $plan = $ac->apply([ { plot_id => $by_number{307}->{plot_id}, not_planted => 1 } ], { delete_phenotypes => 1 });
print "deleted phenotype values of plot 307: ", scalar(@{ $plan->{phenotypes_to_delete}->{phenotype_ids} }), "\n";
refresh();
my %after = (Native => matrix('Native'), MaterializedViewTable => matrix('MaterializedViewTable'));
my ($layout_header, $layout_rows) = collect_rows(selected_columns => { plot_name => 1, accession_name => 1, block_number => 1, rep_number => 1 });
my (undef, $collect_after) = collect_rows(exclude_not_planted => 1);

my %name = map { $_ => $by_number{$_}->{plot_name} } (201, 202, 203, 307, 205);
foreach my $type ('Native', 'MaterializedViewTable') {
    print "\n== phenotype matrix, $type search ==\n";
    printf "%-6s %-20s %-22s %-22s %-10s %-10s %s\n", 'plot', 'name', 'accession before', 'accession after', 'block b/a', 'rep b/a', 'values';
    foreach my $n (201, 202, 203, 307, 205) {
        my ($b, $a) = ($before{$type}->{ $name{$n} }, $after{$type}->{ $name{$n} });
        printf "%-6s %-20s %-22s %-22s %-10s %-10s %s\n", $n, $name{$n}, $b ? $b->{germplasm} : '(no row)', $a ? $a->{germplasm} : '(no row)',
            ($b ? $b->{block} : '-').'/'.($a ? $a->{block} : '-'), ($b ? $b->{rep} : '-').'/'.($a ? $a->{rep} : '-'),
            ($b ? $b->{n_values} : 0).' -> '.($a ? $a->{n_values} : 0).(($b && $a) ? ($b->{values} eq $a->{values} ? ' (same values)' : ' (VALUES DIFFER)') : '');
    }
    my @others = grep { my $p = $_; !grep { $_ eq $p } values %name } keys %{ $before{$type} };
    my @changed = grep { !$after{$type}->{$_} || join('|', @{ $before{$type}->{$_} }{qw(germplasm block rep values)}) ne join('|', @{ $after{$type}->{$_} }{qw(germplasm block rep values)}) } @others;
    print scalar(@others), " other plots: ", (@changed ? "CHANGED: @changed" : "unchanged"), "\n";
    print "rows: ", scalar(keys %{ $before{$type} }), " -> ", scalar(keys %{ $after{$type} }), "\n";
}
my %col = map { $layout_header->[$_] => $_ } 0 .. $#$layout_header;
print "\n== plot layout download ==\ncolumns: @$layout_header\n";
foreach my $row (grep { my $r = $_; grep { $_ eq $r->[ $col{plot_name} ] } values %name } @$layout_rows) {
    print join("\t", @$row), "\n";
}
print "\n== files to collect data in (Field Book, spreadsheets) ==\nplots: ", scalar(@$collect_before), " -> ", scalar(@$collect_after), "\n";
my %in_collect = map { $_->[0] => 1 } @$collect_after;
print "left out: ", join(', ', grep { !$in_collect{$_} } map { $_->{plot_name} } values %by_number), "\n";
