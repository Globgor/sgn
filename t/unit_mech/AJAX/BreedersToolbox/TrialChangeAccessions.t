# Tests the ways to change the accession of plots in a trial, through the web
# server: Replace Accession (replace_stock), one plot (replace_plot_accessions),
# the Change Accessions upload, Shift Accessions (shift_accessions), Not Planted
# Plots (not_planted), Substitute (substitute_stock), genotyping plate wells
# (replace_well_accessions) and BrAPI PUT /observationunits.
# CXGN::Trial::AccessionChange, which they all use, is tested in
# t/unit_fixture/CXGN/Trial/AccessionChange.t.
#
# Every scenario changes test_trial and puts it back as it was.

use strict;
use warnings;

use lib 't/lib';
use SGN::Test::Fixture;
use Test::More;
use Test::WWW::Mechanize;
use LWP::UserAgent;
use JSON::XS;
use File::Temp qw(tempfile);
use SGN::Model::Cvterm;
use CXGN::Trial::TrialLayout;
use CXGN::Trial::AccessionChange;
use CXGN::Phenotypes::StorePhenotypes;

my $f = SGN::Test::Fixture->new();
my $schema = $f->bcs_schema;
my $base = 'http://localhost:3010';

my $mech = Test::WWW::Mechanize->new;
$mech->post_ok("$base/brapi/v1/token", [ username => 'janedoe', password => 'secretpw', grant_type => 'password' ], 'login');
my $access_token = decode_json($mech->content)->{access_token};

my $trial_id = $schema->resultset('Project::Project')->find({ name => 'test_trial' })->project_id();
my %t = map { $_->[0] => SGN::Model::Cvterm->get_cvterm_row($schema, $_->[1], $_->[2])->cvterm_id() } (
    [ plot_of => 'plot_of', 'stock_relationship' ],
    [ replicate => 'replicate', 'stock_property' ],
    [ block => 'block', 'stock_property' ],
    [ not_planted => 'not_planted', 'stock_property' ],
    [ accession => 'accession', 'stock_type' ],
    [ design => 'design', 'project_property' ],
);
my %acc = map { $_ => $schema->resultset('Stock::Stock')->find({ uniquename => "test_accession$_" })->stock_id } 1 .. 5;
my %plot = map { $_ => $schema->resultset('Stock::Stock')->find({ uniquename => "test_trial2$_" })->stock_id } 1 .. 15;
my $organism_id = $schema->resultset('Stock::Stock')->find({ stock_id => $acc{1} })->organism_id;

sub plot_state {
    my $plot_id = shift;
    my $plot = $schema->resultset('Stock::Stock')->find({ stock_id => $plot_id });
    my $accession = $schema->resultset('Stock::StockRelationship')->find({ subject_id => $plot_id, type_id => $t{plot_of} })->object;
    my $rep = $schema->resultset('Stock::Stockprop')->find({ stock_id => $plot_id, type_id => $t{replicate} });
    my $block = $schema->resultset('Stock::Stockprop')->find({ stock_id => $plot_id, type_id => $t{block} });
    my $not_planted = $schema->resultset('Stock::Stockprop')->find({ stock_id => $plot_id, type_id => $t{not_planted} });
    return { name => $plot->uniquename, accession => $accession->uniquename, accession_id => $accession->stock_id, rep => $rep ? $rep->value : undef, block => $block ? $block->value : undef, not_planted => $not_planted ? $not_planted->value : undef };
}
sub trial_state { return { map { $_ => plot_state($plot{$_}) } keys %plot }; }
my $original = trial_state();
my $original_design = $schema->resultset('Project::Projectprop')->find({ project_id => $trial_id, type_id => $t{design} })->value;

sub set_prop {
    my ($stock_id, $type, $value) = @_;
    $schema->resultset('Stock::Stockprop')->search({ stock_id => $stock_id, type_id => $t{$type} })->delete;
    $schema->resultset('Stock::Stockprop')->create({ stock_id => $stock_id, type_id => $t{$type}, value => $value, rank => 0 }) if defined $value;
}
sub rename_plot { my ($id, $name) = @_; $schema->resultset('Stock::Stock')->find({ stock_id => $id })->update({ uniquename => $name, name => $name }); }

sub restore {
    rename_plot($plot{$_}, "review_restore_$_") for keys %plot;
    foreach my $n (keys %plot) {
        my $o = $original->{$n};
        rename_plot($plot{$n}, $o->{name});
        $schema->resultset('Stock::StockRelationship')->search({ subject_id => $plot{$n}, type_id => $t{plot_of} })->update({ object_id => $o->{accession_id} });
        set_prop($plot{$n}, 'replicate', $o->{rep});
        set_prop($plot{$n}, 'block', $o->{block});
        set_prop($plot{$n}, 'not_planted', $o->{not_planted});
    }
    $schema->resultset('Project::Projectprop')->search({ project_id => $trial_id, type_id => $t{design} })->update({ value => $original_design });
    $mech->get_ok("$base/ajax/breeders/trial/$trial_id/refresh_cache", 'refresh cache after restore');
    is_deeply(trial_state(), $original, 'test_trial restored');
}

sub post_json {
    my ($path, $params) = @_;
    $mech->post("$base$path", $params);
    my $r = eval { decode_json($mech->content) } || { http_status => $mech->status };
    return $r;
}

sub cached_accession {
    my $plot_name = shift;
    my $design = CXGN::Trial::TrialLayout->new({ schema => $schema, trial_id => $trial_id, experiment_type => 'field_layout' })->get_design();
    my ($p) = grep { $_->{plot_name} eq $plot_name } values %$design;
    return $p ? $p->{accession_name} : undef;
}

my $replace_stock = "/ajax/breeders/trial/$trial_id/replace_stock";
$mech->get_ok("$base/ajax/breeders/trial/$trial_id/refresh_cache");

subtest 'replace_stock: preview changes nothing' => sub {
    my $r = post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'test_accession1', trial_stock_type => 'accession', preview => 1 ]);
    is($r->{preview}->{changed}, 3, 'three plots would change');
    is($r->{preview}->{replicates_changed}, 4, 'four replicates would change (CRD)');
    ok(!$r->{success}, 'no success flag');
    is_deeply(trial_state(), $original, 'nothing changed');
};

subtest 'replace_stock: errors' => sub {
    like(post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'test_trial21', trial_stock_type => 'accession' ])->{error}, qr/test_trial21 is not an accession\./, 'a plot name as new stock');
    like(post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'no_such_stock_xyz' ])->{error}, qr/Could not find no_such_stock_xyz/, 'unknown stock');
    like(post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'cross_test1' ])->{error}, qr/cross_test1 is not an accession\./, 'a cross in a trial of accessions, without trial_stock_type');
    like(post_json($replace_stock, [ old_stock_id => $plot{1}, new_stock => 'test_accession1' ])->{error}, qr/No plot of this trial has the stock to replace/, 'old stock not in the trial');
    like(post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => '  ' ])->{error}, qr/Provide new stock name/, 'empty name');
    my $anonymous = Test::WWW::Mechanize->new;
    $anonymous->post("$base$replace_stock", [ old_stock_id => $acc{3}, new_stock => 'test_accession1' ]);
    like(decode_json($anonymous->content)->{error}, qr/insufficient access privileges/, 'not logged in');
    is_deeply(trial_state(), $original, 'nothing changed');
};

subtest 'replace_stock: names are kept when asked to' => sub {
    rename_plot($plot{3}, 'test_trial-rep1-test_accession3_3');
    my $r = post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'test_accession2', trial_stock_type => 'accession', rename_plots => 0 ]);
    is($r->{success}, 1, 'success');
    is_deeply($r->{renamed}, [], 'nothing renamed');
    is(plot_state($plot{3})->{name}, 'test_trial-rep1-test_accession3_3', 'name kept');
    is(cached_accession('test_trial-rep1-test_accession3_3'), 'test_accession2', 'cached layout has the new accession');
    restore();
};

subtest 'replace_stock: names are updated by default' => sub {
    rename_plot($plot{3}, 'test_trial-rep1-test_accession3_3');
    my $r = post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'test_accession2', trial_stock_type => 'accession' ]);
    is_deeply($r->{renamed}, [ { old_name => 'test_trial-rep1-test_accession3_3', new_name => 'test_trial-rep1-test_accession2_3' } ], 'renamed');
    is(plot_state($plot{3})->{name}, 'test_trial-rep1-test_accession2_3', 'in the database');
    restore();
};

subtest 'replace_stock in an RCBD keeps replicates and blocks' => sub {
    $schema->resultset('Project::Projectprop')->search({ project_id => $trial_id, type_id => $t{design} })->update({ value => 'RCBD' });
    foreach my $n (keys %plot) {
        my $b = int(($n - 1) / 5) + 1;
        set_prop($plot{$n}, 'block', $b);
        set_prop($plot{$n}, 'replicate', $b);
    }
    my $before = trial_state();
    my $r = post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'test_accession1', trial_stock_type => 'accession' ]);
    is($r->{success}, 1, 'success');
    is($r->{replicates_changed}, 0, 'no replicate changed');
    my $after = trial_state();
    is_deeply({ map { $_ => [ $after->{$_}->{rep}, $after->{$_}->{block} ] } keys %$after }, { map { $_ => [ $before->{$_}->{rep}, $before->{$_}->{block} ] } keys %$before }, 'replicates and blocks unchanged');
    is($after->{10}->{accession}, 'test_accession1', 'accession changed');
    restore();
};

subtest 'replace_plot_accessions: one plot' => sub {
    my $r = post_json("/ajax/breeders/trial/$trial_id/replace_plot_accessions", [ old_accession => '<a href="/stock/1/view">ignored</a>', new_accession => 'test_accession2', old_plot_id => $plot{10}, old_plot_name => 'test_trial210', new_plot_name => '', override => 'check' ]);
    is($r->{success}, 1, 'success');
    is(plot_state($plot{10})->{accession}, 'test_accession2', 'changed');
    is(cached_accession('test_trial210'), 'test_accession2', 'cached layout');
    $r = post_json("/ajax/breeders/trial/$trial_id/replace_plot_accessions", [ new_accession => 'test_accession1', old_plot_id => $plot{10}, new_plot_name => 'test_trial21', override => 'check' ]);
    like($r->{error}, qr/Nothing was changed: Plot name test_trial21 already exists/, 'taken name refused');
    is(plot_state($plot{10})->{accession}, 'test_accession2', 'and the accession was not changed either');
    $r = post_json("/ajax/breeders/trial/$trial_id/replace_plot_accessions", [ new_accession => 'test_accession1', old_plot_id => 1, override => 'check' ]);
    like($r->{error}, qr/not part of this trial/, 'a stock that is not a plot of this trial');
    restore();
};

subtest 'Change Accessions upload' => sub {
    my $upload = sub {
        my ($content, $user_mech) = @_;
        my ($fh, $filename) = tempfile(SUFFIX => '.csv');
        print $fh $content;
        close($fh);
        $user_mech //= $mech;
        $user_mech->post("$base/ajax/breeders/trial/$trial_id/change_plot_accessions_using_file/check", Content_Type => 'form-data', Content => [ trial_design_change_accessions_file => [ $filename, 'change_accessions.csv', Content_Type => 'text/csv' ] ]);
        return decode_json($user_mech->content);
    };
    my $r = $upload->("plot_name,accession_name,new_plot_name\ntest_trial210,test_accession1,\ntest_trial23,test_accession2,review_upload_name\n");
    is($r->{success}, 1, 'success') or diag(explain $r);
    is($r->{changed}, 2, 'two plots changed');
    is(plot_state($plot{10})->{accession}, 'test_accession1', 'plot 10');
    is_deeply([ @{plot_state($plot{3})}{'name', 'accession'} ], [ 'review_upload_name', 'test_accession2' ], 'plot 3 renamed');
    is(cached_accession('review_upload_name'), 'test_accession2', 'cached layout');
    restore();

    my $obsolete = $schema->resultset('Stock::Stock')->create({ uniquename => 'review_obsolete_<b>accession</b>', name => 'review_obsolete', type_id => $t{accession}, organism_id => $organism_id, is_obsolete => 1 });
    $r = $upload->("plot_name,accession_name\ntest_trial210,review_obsolete_<b>accession</b>\n");
    like($r->{error}, qr/review_obsolete_&lt;b&gt;accession&lt;\/b&gt; is obsolete/, 'obsolete accession refused, escaped for HTML');
    $obsolete->delete;
    is(plot_state($plot{10})->{accession}, 'test_accession3', 'nothing changed');

    $r = $upload->("plot_name,accession_name\ntest_trial210,test_trial21\n");
    like($r->{error}, qr/test_trial21 is not an accession\./, 'a plot as new accession refused');

    $r = $upload->("plot_name,accession_name\ntest_trial210,test_accession1\n", Test::WWW::Mechanize->new);
    like($r->{error}, qr/logged in/, 'not logged in');
    is_deeply(trial_state(), $original, 'nothing changed');
};

subtest 'Change Accessions upload: keeping the plot names' => sub {
    my $upload = sub {
        my ($content, @fields) = @_;
        my ($fh, $filename) = tempfile(SUFFIX => '.csv');
        print $fh $content;
        close($fh);
        $mech->post("$base/ajax/breeders/trial/$trial_id/change_plot_accessions_using_file/check", Content_Type => 'form-data', Content => [ trial_design_change_accessions_file => [ $filename, 'change_accessions.csv', Content_Type => 'text/csv' ], @fields ]);
        return decode_json($mech->content);
    };
    rename_plot($plot{3}, 'test_trial-rep1-test_accession3_3');
    rename_plot($plot{4}, 'test_trial-rep2-test_accession3_4');
    my $r = $upload->("plot_name,accession_name\ntest_trial-rep1-test_accession3_3,test_accession2\n", keep_plot_names => 1);
    is($r->{success}, 1, 'success') or diag(explain $r);
    is(plot_state($plot{3})->{name}, 'test_trial-rep1-test_accession3_3', 'keep_plot_names keeps the name');
    is(plot_state($plot{3})->{accession}, 'test_accession2', 'accession changed');
    $r = $upload->("plot_name,accession_name,new_plot_name\ntest_trial-rep2-test_accession3_4,test_accession2,test_trial-rep2-test_accession3_4\n");
    is(plot_state($plot{4})->{name}, 'test_trial-rep2-test_accession3_4', 'a new_plot_name that is the current name keeps it');
    $r = $upload->("plot_name,accession_name\ntest_trial210,test_accession2\n");
    is(plot_state($plot{10})->{accession}, 'test_accession2', 'without the option: changed too');
    restore();
};

subtest 'shift_accessions' => sub {
    my $not_planted = $schema->resultset('Stock::Stock')->create({ uniquename => 'NOT_PLANTED', name => 'NOT_PLANTED', type_id => $t{accession}, organism_id => $organism_id });
    my $shift = "/ajax/breeders/trial/$trial_id/shift_accessions";
    my %params = (from_plot_id => $plot{4}, to_plot_id => $plot{6}, positions => 1, empty_stock => 'NOT_PLANTED', order => 'plot_number');

    my $r = post_json($shift, [ %{{ %params, preview => 1 }} ]);
    is($r->{preview}->{changed}, 3, 'preview: three plots change');
    is_deeply($r->{preview}->{pushed_out}, [ { stock_id => $original->{6}->{accession_id}, stock_name => $original->{6}->{accession}, plot_name => 'test_trial26' } ], 'preview: the accession planned for plot 6 is pushed out');
    is_deeply([ @{$r->{preview}}{'first_plot', 'last_plot', 'plots_in_stretch'} ], [ 'test_trial24', 'test_trial26', 3 ], 'preview: the stretch');
    is_deeply(trial_state(), $original, 'preview changes nothing');

    $r = post_json($shift, [ %params ]);
    is($r->{success}, 1, 'shift succeeds') or diag(explain $r);
    is_deeply([ map { plot_state($plot{$_})->{accession} } (4, 5, 6) ], [ 'NOT_PLANTED', $original->{4}->{accession}, $original->{5}->{accession} ], 'shifted');
    is_deeply([ map { plot_state($plot{$_})->{name} } (4, 5, 6) ], [ 'test_trial24', 'test_trial25', 'test_trial26' ], 'names kept by default');
    is(cached_accession('test_trial24'), 'NOT_PLANTED', 'cached layout');
    is(plot_state($plot{4})->{not_planted}, '1', 'plot 4 is not planted');
    restore();

    $r = post_json($shift, [ %{{ %params, empty_stock => '' }} ]);
    is($r->{success}, 1, 'without an accession for the empty places') or diag(explain $r);
    is_deeply([ map { plot_state($plot{$_})->{accession} } (4, 5, 6) ], [ map { $original->{$_}->{accession} } (4, 4, 5) ], 'plot 4 keeps its planned accession');
    is_deeply([ map { plot_state($plot{$_})->{not_planted} } (4, 5, 6) ], [ '1', undef, undef ], 'and is not planted');
    is_deeply($r->{planting}, [ { plot_name => 'test_trial24', not_planted => 1 } ], 'the summary says so');
    restore();
    like(post_json($shift, [ %{{ %params, positions => 5 }} ])->{error}, qr/not shorter than the 3 plot/, 'too many positions');
    like(post_json($shift, [ %{{ %params, order => 'by_row_serpentine' }} ])->{error}, qr/row and\/or column/, 'no rows and columns for the serpentine order');
    my $anonymous = Test::WWW::Mechanize->new;
    $anonymous->post("$base$shift", [ %params ]);
    like(decode_json($anonymous->content)->{error}, qr/insufficient access privileges/, 'not logged in');
    is_deeply(trial_state(), $original, 'nothing changed');
    $not_planted->delete;
};

subtest 'shift_accessions at the end of the season: the trial has phenotypes' => sub {
    my $phenotyped_trial_id = $schema->resultset('Project::Project')->find({ name => 'CASS_6Genotypes_Sampling_2015' })->project_id;
    my $ac = CXGN::Trial::AccessionChange->new({ schema => $schema, trial_id => $phenotyped_trial_id });
    my @plots = sort { $a->{plot_number} <=> $b->{plot_number} } values %{ $ac->load_units() };
    # plot 201 has no phenotypes: it stays empty (not planted), 202 and 203 have phenotypes
    my ($first) = grep { $plots[$_]->{plot_number} == 201 } 0 .. $#plots;
    my @stretch = @plots[$first .. $first + 2];
    my %saved = map { $_->{plot_id} => [ $_->{stock_id}, $_->{plot_name} ] } @stretch;
    my $not_planted = $schema->resultset('Stock::Stock')->create({ uniquename => 'NOT_PLANTED', name => 'NOT_PLANTED', type_id => $t{accession}, organism_id => $organism_id });
    my $phenotypes_h = $schema->storage->dbh->prepare("SELECT count(*) FROM nd_experiment_stock nes JOIN nd_experiment_phenotype nep ON nep.nd_experiment_id = nes.nd_experiment_id WHERE nes.stock_id = ?");
    my $phenotypes = sub { $phenotypes_h->execute($_[0]); return ($phenotypes_h->fetchrow_array())[0]; };
    my %phenotype_count = map { $_->{plot_id} => $phenotypes->($_->{plot_id}) } @stretch;
    is($phenotype_count{ $stretch[0]->{plot_id} }, 0, 'the first plot has no phenotypes');
    ok($phenotype_count{ $stretch[1]->{plot_id} } > 0, 'the others have');

    my $shift = "/ajax/breeders/trial/$phenotyped_trial_id/shift_accessions";
    my %params = (from_plot_id => $stretch[0]->{plot_id}, to_plot_id => $stretch[2]->{plot_id}, positions => 1, empty_stock => 'NOT_PLANTED', order => 'plot_number');
    my $r = post_json($shift, [ %{{ %params, preview => 1 }} ]);
    like($r->{warning}, qr/traits have been assayed/, 'curators are warned first');
    $r = post_json($shift, [ %{{ %params, preview => 1, override => 1 }} ]);
    ok($r->{preview}->{plots_with_phenotypes} > 0, 'the preview counts the plots with phenotypes');
    ok((grep { /already have phenotypes/ } @{ $r->{preview}->{warnings} }), 'and warns that the values count for the new accessions');
    $r = post_json($shift, [ %{{ %params, override => 1 }} ]);
    is($r->{success}, 1, 'shift succeeds with override') or diag(explain $r);
    my $after = $ac->load_units();
    is($after->{ $stretch[1]->{plot_id} }->{stock_id}, $stretch[0]->{stock_id}, 'the second plot has the accession planned for the first');
    is_deeply({ map { $_->{plot_id} => $phenotypes->($_->{plot_id}) } @stretch }, \%phenotype_count, 'every plot keeps its phenotypes');
    is($after->{ $stretch[0]->{plot_id} }->{not_planted}, '1', 'the first plot is not planted');

    # a place that stays empty but has phenotypes: they would be deleted, so the user is asked
    $r = post_json($shift, [ %{{ %params, from_plot_id => $stretch[1]->{plot_id}, preview => 1, override => 1 }} ]);
    like($r->{error}, qr/phenotype value\(s\) were stored for plots that are marked as not planted \(\Q$stretch[1]->{plot_name}\E\)/, 'shifting from a plot with phenotypes needs delete_phenotypes');
    ok($r->{not_planted_phenotypes} > 0, 'and the page can ask');

    # put the trial back
    foreach my $plot_id (keys %saved) {
        $schema->resultset('Stock::StockRelationship')->search({ subject_id => $plot_id, type_id => $t{plot_of} })->update({ object_id => $saved{$plot_id}->[0] });
        set_prop($plot_id, 'not_planted', undef);
    }
    $mech->get_ok("$base/ajax/breeders/trial/$phenotyped_trial_id/refresh_cache");
    is_deeply({ map { $_->{plot_id} => [ $_->{stock_id}, $_->{plot_name} ] } grep { $saved{ $_->{plot_id} } } values %{ $ac->load_units() } }, \%saved, 'restored');
    $not_planted->delete;
};

subtest 'Change Accessions upload: the not_planted column' => sub {
    my $upload = sub {
        my ($content, @fields) = @_;
        my ($fh, $filename) = tempfile(SUFFIX => '.csv');
        print $fh $content;
        close($fh);
        $mech->post("$base/ajax/breeders/trial/$trial_id/change_plot_accessions_using_file/check", Content_Type => 'form-data', Content => [ trial_design_change_accessions_file => [ $filename, 'change_accessions.csv', Content_Type => 'text/csv' ], @fields ]);
        return decode_json($mech->content);
    };
    my $r = $upload->("plot_name,accession_name,not_planted\ntest_trial24,$original->{4}->{accession},1\ntest_trial25,test_accession2,\ntest_trial26,$original->{6}->{accession},0\n");
    is($r->{success}, 1, 'success') or diag(explain $r);
    is_deeply($r->{planting}, [ { plot_name => 'test_trial24', not_planted => 1 } ], 'plot 4 marked as not planted');
    is_deeply([ map { plot_state($plot{$_})->{not_planted} } (4, 5, 6) ], [ '1', undef, undef ], 'stored');
    is(plot_state($plot{5})->{accession}, 'test_accession2', 'and plot 5 changed in the same file');
    $r = $upload->("plot_name,accession_name,not planted\ntest_trial24,$original->{4}->{accession},no\n");
    is_deeply($r->{planting}, [ { plot_name => 'test_trial24', not_planted => 0 } ], "'not planted' with 'no' plants it again");
    $r = $upload->("plot_name,accession_name,not_planted\ntest_trial24,$original->{4}->{accession},maybe\n");
    like($r->{error}, qr/Plot test_trial24: not_planted must be 1 \(not planted\) or 0 \(planted\), not maybe\./, 'an unknown value is refused');
    restore();
};

subtest 'not_planted: Not Planted Plots and the plot dialog' => sub {
    my $url = "/ajax/breeders/trial/$trial_id/not_planted";
    my $r = post_json($url, [ plot_names => "test_trial25\r\ntest_trial28\n", preview => 1 ]);
    is_deeply($r->{preview}->{planting}, [ { plot_name => 'test_trial25', not_planted => 1 }, { plot_name => 'test_trial28', not_planted => 1 } ], 'preview by plot names');
    is_deeply(trial_state(), $original, 'preview changes nothing');

    $r = post_json($url, [ plot_ids => $plot{5} ]);
    is($r->{success}, 1, 'by plot id') or diag(explain $r);
    is(plot_state($plot{5})->{not_planted}, '1', 'plot 5 is not planted');
    is(plot_state($plot{5})->{accession}, $original->{5}->{accession}, 'and keeps its accession');
    is_deeply([ map { plot_state($plot{$_})->{rep} } (8, 11) ], [ 1, 2 ], 'CRD: test_accession1 is numbered without plot 5');

    my $ua = LWP::UserAgent->new;
    $ua->default_header('Authorization' => 'Bearer '.$access_token);
    my $unit = sub { return decode_json($ua->get("$base/brapi/v2/observationunits/$_[0]")->decoded_content)->{result}; };
    ok($unit->($plot{5})->{additionalInfo}->{notPlanted}, 'BrAPI: additionalInfo.notPlanted');
    ok(!exists(($unit->($plot{8})->{additionalInfo} || {})->{notPlanted}), 'BrAPI: not for a planted plot');

    $r = post_json($url, [ plot_ids => $plot{5}, not_planted => 0 ]);
    is_deeply($r->{planting}, [ { plot_name => 'test_trial25', not_planted => 0 } ], 'planted again');
    is_deeply(trial_state(), $original, 'as before');

    like(post_json($url, [ plot_names => "test_trial25\nno_such_plot" ])->{error}, qr/These plots are not part of this trial: no_such_plot/, 'unknown plot');
    like(post_json($url, [])->{error}, qr/Choose the plots/, 'no plots');
    my $anonymous = Test::WWW::Mechanize->new;
    $anonymous->post("$base$url", [ plot_ids => $plot{5} ]);
    like(decode_json($anonymous->content)->{error}, qr/insufficient access privileges/, 'not logged in');
    is_deeply(trial_state(), $original, 'nothing changed');
};

subtest 'not_planted: phenotypes of the plot are deleted after confirmation' => sub {
    my $temp_file = $f->config->{cluster_shared_tempdir}."/test_temp_nd_experiment_id_delete";
    my $store = CXGN::Phenotypes::StorePhenotypes->new(
        basepath => $f->config->{basepath}, dbhost => $f->config->{dbhost}, dbname => $f->config->{dbname}, dbuser => $f->config->{dbuser}, dbpass => $f->config->{dbpass},
        temp_file_nd_experiment_id => $temp_file, bcs_schema => $schema, metadata_schema => $f->metadata_schema, phenome_schema => $f->phenome_schema, user_id => 41,
        stock_list => [ 'test_trial210' ], trait_list => [ 'dry yield|CO_334:0000014' ], values_hash => { test_trial210 => { 'dry yield|CO_334:0000014' => [ 30, '' ] } },
        has_timestamps => 0, overwrite_values => 0, metadata_hash => { operator => 'janedoe', date => '20260901' },
        composable_validation_check_name => $f->config->{composable_validation_check_name},
    );
    $store->store();
    my $values_h = $schema->storage->dbh->prepare("SELECT count(*) FROM nd_experiment_stock nes JOIN nd_experiment_phenotype nep USING (nd_experiment_id) WHERE nes.stock_id = ?");
    my $values = sub { $values_h->execute($_[0]); return ($values_h->fetchrow_array())[0]; };
    is($values->($plot{10}), 1, 'plot 10 has a phenotype');

    my $url = "/ajax/breeders/trial/$trial_id/not_planted";
    my $r = post_json($url, [ plot_ids => $plot{10}, preview => 1 ]);
    like($r->{error}, qr/1 phenotype value\(s\) were stored for plots that are marked as not planted \(test_trial210\)/, 'the preview refuses');
    is($r->{not_planted_phenotypes}, 1, 'and counts the values, so that the page can ask');
    $r = post_json($url, [ plot_ids => $plot{10}, preview => 1, delete_phenotypes => 1 ]);
    ok((grep { /are deleted/ } @{ $r->{preview}->{warnings} }), 'with delete_phenotypes the preview warns');
    is($values->($plot{10}), 1, 'and deletes nothing');
    $r = post_json($url, [ plot_ids => $plot{10}, delete_phenotypes => 1 ]);
    is($r->{success}, 1, 'marked') or diag(explain $r);
    is($r->{phenotypes_deleted}, 1, 'one value deleted');
    is($values->($plot{10}), 0, 'plot 10 has no phenotypes');
    restore();
};

subtest 'substitute_stock swaps two plots' => sub {
    my $r = post_json("/ajax/breeders/trial/$trial_id/substitute_stock", [ plot_1_info => "$plot{1},x", plot_2_info => "$plot{2},y" ]);
    is($r->{success}, 1, 'success');
    is_deeply([ map { plot_state($plot{$_})->{accession} } (1, 2) ], [ $original->{2}->{accession}, $original->{1}->{accession} ], 'accessions swapped');
    is_deeply([ map { plot_state($plot{$_})->{name} } (1, 2) ], [ 'test_trial21', 'test_trial22' ], 'names kept (they do not contain the accession names)');
    like(post_json("/ajax/breeders/trial/$trial_id/substitute_stock", [ plot_1_info => "$plot{1},x", plot_2_info => "$plot{1},x" ])->{error}, qr/Choose a different plot/, 'the same plot twice');
    restore();
};

subtest 'replace_well_accessions only for genotyping plates' => sub {
    like(post_json("/ajax/breeders/trial/$trial_id/replace_well_accessions", [ old_plot_id => $plot{1}, new_accession => 'test_accession1' ])->{error}, qr/not a genotyping plate/, 'refused for a field trial');
};

subtest 'BrAPI PUT observationunits changes the germplasm of a plot' => sub {
    my $ua = LWP::UserAgent->new;
    $ua->default_header('Content-Type' => 'application/json');
    $ua->default_header('Authorization' => 'Bearer '.$access_token);
    my $body = encode_json({ germplasmDbId => "$acc{1}", germplasmName => 'test_accession1', studyDbId => "$trial_id", observationUnitPosition => { observationLevel => { levelName => 'plot' } } });
    my $resp = $ua->put("$base/brapi/v2/observationunits/$plot{10}", Content => $body);
    ok($resp->is_success, 'PUT succeeds') or diag($resp->decoded_content);
    is(plot_state($plot{10})->{accession}, 'test_accession1', 'germplasm changed');
    is(plot_state($plot{10})->{name}, 'test_trial210', 'name kept');
    is(cached_accession('test_trial210'), 'test_accession1', 'cached layout');
    restore();
};

done_testing();
