# Tests the ways to change the accession of plots in a trial, through the web
# server: Replace Accession (replace_stock), one plot (replace_plot_accessions),
# the Change Accessions upload (a file of what was planted, also of plots that
# were not planted), Substitute (substitute_stock), genotyping plate wells
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
use URI::Escape qw(uri_escape);
use SGN::Model::Cvterm;
use CXGN::Trial::TrialLayout;
use CXGN::Trial::AccessionChange;
use CXGN::BreedersToolbox::Projects;
use CXGN::Phenotypes::StorePhenotypes;
use CXGN::Stock::Seedlot::Transaction;

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
    [ row_number => 'row_number', 'stock_property' ],
    [ col_number => 'col_number', 'stock_property' ],
    [ accession => 'accession', 'stock_type' ],
    [ seedlot => 'seedlot', 'stock_type' ],
    [ collection_of => 'collection_of', 'stock_relationship' ],
    [ seed_transaction => 'seed transaction', 'stock_relationship' ],
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
    return { name => $plot->uniquename, accession => $accession->uniquename, accession_id => $accession->stock_id, rep => $rep ? $rep->value : undef, block => $block ? $block->value : undef };
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

# posts a CSV file to the Change Accessions upload of a trial, as a user ($mech by default);
# override => 1 posts to .../override (a curator confirming), otherwise to .../check
sub upload_as {
    my ($user_mech, $trial, $content, %fields) = @_;
    my $arg = delete $fields{override} ? 'override' : 'check';
    my ($fh, $filename) = tempfile(SUFFIX => '.csv', UNLINK => 1);
    print $fh $content;
    close($fh);
    $user_mech->post("$base/ajax/breeders/trial/$trial/change_plot_accessions_using_file/$arg", Content_Type => 'form-data', Content => [ trial_design_change_accessions_file => [ $filename, 'change_accessions.csv', Content_Type => 'text/csv' ], %fields ]);
    return eval { decode_json($user_mech->content) } || { http_status => $user_mech->status, content => substr($user_mech->content, 0, 500) };
}
sub upload_accessions { return upload_as($mech, @_); }

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
    like(post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'cross_test1', trial_stock_type => 'cross' ])->{error}, qr/cross_test1 is not an accession\./, 'trial_stock_type from the browser does not widen what the trial takes');
    like(post_json($replace_stock, [ old_stock_id => $plot{1}, new_stock => 'test_accession1' ])->{error}, qr/No plot of this trial has the stock to replace/, 'old stock not in the trial');
    like(post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => '  ' ])->{error}, qr/Provide new stock name/, 'empty name');
    my $anonymous = Test::WWW::Mechanize->new;
    $anonymous->post("$base$replace_stock", [ old_stock_id => $acc{3}, new_stock => 'test_accession1' ]);
    like(decode_json($anonymous->content)->{error}, qr/insufficient access privileges/, 'not logged in');
    is_deeply(trial_state(), $original, 'nothing changed');
};

subtest 'replace_stock: names are kept by default (labels in the field)' => sub {
    rename_plot($plot{3}, 'test_trial-rep1-test_accession3_3');
    my $r = post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'test_accession2', trial_stock_type => 'accession' ]);
    is($r->{success}, 1, 'success');
    is_deeply($r->{renamed}, [], 'nothing renamed');
    is(plot_state($plot{3})->{name}, 'test_trial-rep1-test_accession3_3', 'name kept');
    is(cached_accession('test_trial-rep1-test_accession3_3'), 'test_accession2', 'cached layout has the new accession');
    restore();
};

subtest 'replace_stock: names are updated when asked to' => sub {
    rename_plot($plot{3}, 'test_trial-rep1-test_accession3_3');
    my $r = post_json($replace_stock, [ old_stock_id => $acc{3}, new_stock => 'test_accession2', trial_stock_type => 'accession', rename_plots => 1 ]);
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
    unlike($r->{error}, qr/\{UNKNOWN\}|line \d+|\.pm/, 'without internal details');
    is(plot_state($plot{10})->{accession}, 'test_accession2', 'and the accession was not changed either');
    $r = post_json("/ajax/breeders/trial/$trial_id/replace_plot_accessions", [ new_accession => 'test_accession1', old_plot_id => 1, override => 'check' ]);
    like($r->{error}, qr/not part of this trial/, 'a stock that is not a plot of this trial');
    restore();
};

subtest 'Change Accessions upload goes through the service: one transaction, the same rules' => sub {
    my $r = upload_accessions($trial_id, "plot_name,accession_name,new_plot_name\ntest_trial210,test_accession1,\ntest_trial23,test_accession2,review_upload_name\n");
    is($r->{success}, 1, 'success') or diag(explain $r);
    is($r->{changed}, 2, 'two plots changed');
    is(plot_state($plot{10})->{accession}, 'test_accession1', 'plot 10');
    is_deeply([ @{plot_state($plot{3})}{'name', 'accession'} ], [ 'review_upload_name', 'test_accession2' ], 'plot 3 renamed');
    is(cached_accession('review_upload_name'), 'test_accession2', 'cached layout');
    restore();

    $r = upload_accessions($trial_id, "plot_name,accession_name\ntest_trial210,test_trial21\n");
    like($r->{error}, qr/test_trial21 is not an accession\./, 'a plot as new accession refused');
    $r = upload_accessions($trial_id, "plot_name,accession_name\n<b>x</b>,test_accession1\n");
    like($r->{error}, qr/Plot &lt;b&gt;x&lt;\/b&gt; does not exist in this trial/, 'names from the file are escaped in errors');
    $r = upload_as(Test::WWW::Mechanize->new, $trial_id, "plot_name,accession_name\ntest_trial210,test_accession1\n");
    like($r->{error}, qr/logged in/, 'not logged in');
    is_deeply(trial_state(), $original, 'nothing changed');
};

subtest 'a submitter of the program corrects a trial; a trial with phenotypes needs a curator' => sub {
    my $submitter = Test::WWW::Mechanize->new;
    $submitter->post_ok("$base/brapi/v1/token", [ username => 'johndoe', password => 'secretpw', grant_type => 'password' ], 'login as johndoe, a submitter of the program');
    $submitter->post("$base$replace_stock", [ old_stock_id => $acc{3}, new_stock => 'test_accession1', trial_stock_type => 'accession', preview => 1 ]);
    my $r = decode_json($submitter->content);
    is($r->{preview}->{changed}, 3, 'the submitter gets the preview for a trial without phenotypes') or diag(explain $r);

    my $phenotyped_trial_id = $schema->resultset('Project::Project')->find({ name => 'CASS_6Genotypes_Sampling_2015' })->project_id;
    my ($cass_plot) = sort { $a->{plot_number} <=> $b->{plot_number} } values %{ CXGN::Trial::AccessionChange->new({ schema => $schema, trial_id => $phenotyped_trial_id })->load_units() };
    $r = upload_as($submitter, $phenotyped_trial_id, "plot_name,accession_name\n$cass_plot->{plot_name},test_accession1\n", preview => 1, override => 1);
    like($r->{error}, qr/traits have been assayed/, 'a trial with phenotypes: the submitter is refused, override or not') or diag(explain $r);
    ok(!$r->{warning}, 'and not asked');
    $submitter->post("$base/ajax/breeders/trial/$phenotyped_trial_id/replace_plot_accessions", [ new_accession => 'test_accession1', old_plot_id => $cass_plot->{plot_id}, old_plot_name => $cass_plot->{plot_name}, new_plot_name => '', override => 'override' ]);
    like(decode_json($submitter->content)->{error}, qr/traits have been assayed/, 'the plot form refuses the submitter too');
    like(post_json("/ajax/breeders/trial/$phenotyped_trial_id/replace_stock", [ old_stock_id => $cass_plot->{stock_id}, new_stock => 'test_accession1', trial_stock_type => 'accession', preview => 1 ])->{error}, qr/traits have been assayed/, 'Replace Accession is refused for a trial with phenotypes, also for a curator');
    my $unchanged = CXGN::Trial::AccessionChange->new({ schema => $schema, trial_id => $phenotyped_trial_id })->load_units()->{ $cass_plot->{plot_id} };
    is($unchanged->{stock_id}, $cass_plot->{stock_id}, 'the plot keeps its accession');
};

subtest 'Change Accessions upload at the end of the season: the trial has phenotypes' => sub {
    my $phenotyped_trial_id = $schema->resultset('Project::Project')->find({ name => 'CASS_6Genotypes_Sampling_2015' })->project_id;
    my $ac = CXGN::Trial::AccessionChange->new({ schema => $schema, trial_id => $phenotyped_trial_id });
    my @plots = sort { $a->{plot_number} <=> $b->{plot_number} } values %{ $ac->load_units() };
    # 202 and 203 have phenotypes and got the packets of 201 and 202
    my ($first) = grep { $plots[$_]->{plot_number} == 201 } 0 .. $#plots;
    my @stretch = @plots[$first .. $first + 2];
    my %saved = map { $_->{plot_id} => [ $_->{stock_id}, $_->{plot_name} ] } @stretch;
    my $phenotypes_h = $schema->storage->dbh->prepare("SELECT count(*) FROM nd_experiment_stock nes JOIN nd_experiment_phenotype nep ON nep.nd_experiment_id = nes.nd_experiment_id WHERE nes.stock_id = ?");
    my $phenotypes = sub { $phenotypes_h->execute($_[0]); return ($phenotypes_h->fetchrow_array())[0]; };
    my %phenotype_count = map { $_->{plot_id} => $phenotypes->($_->{plot_id}) } @stretch;
    ok($phenotype_count{ $stretch[1]->{plot_id} } > 0, 'the plots have phenotypes');

    my $file = "plot_name,accession_name\n".join('', map { "$stretch[$_]->{plot_name},$stretch[$_ - 1]->{stock_name}\n" } 1 .. 2);
    my $r = upload_accessions($phenotyped_trial_id, $file);
    like($r->{warning}, qr/traits have been assayed/, 'curators are warned first, with the reason');
    is_deeply({ map { $_->{plot_id} => $_->{stock_id} } grep { $saved{ $_->{plot_id} } } values %{ $ac->load_units() } }, { map { $_ => $saved{$_}->[0] } keys %saved }, 'and nothing is changed');
    $r = upload_accessions($phenotyped_trial_id, $file, override => 1);
    is($r->{success}, 1, 'changed with override') or diag(explain $r);
    ok($r->{plots_with_phenotypes} > 0, 'the result counts the plots with phenotypes') or diag(explain $r);
    my $after = $ac->load_units();
    is($after->{ $stretch[1]->{plot_id} }->{stock_id}, $stretch[0]->{stock_id}, 'the second plot has the accession planned for the first');
    is_deeply({ map { $_->{plot_id} => $phenotypes->($_->{plot_id}) } @stretch }, \%phenotype_count, 'every plot keeps its phenotypes');
    is_deeply([ map { plot_state($_->{plot_id})->{rep} } @stretch ], [ 1, 1, 1 ], 'RCBD: the replicates stay as planned, they are not numbered again by accession as the upload did before');

    # put the trial back
    foreach my $plot_id (keys %saved) {
        $schema->resultset('Stock::StockRelationship')->search({ subject_id => $plot_id, type_id => $t{plot_of} })->update({ object_id => $saved{$plot_id}->[0] });
    }
    $mech->get_ok("$base/ajax/breeders/trial/$phenotyped_trial_id/refresh_cache");
    is_deeply({ map { $_->{plot_id} => [ $_->{stock_id}, $_->{plot_name} ] } grep { $saved{ $_->{plot_id} } } values %{ $ac->load_units() } }, \%saved, 'restored');
};

subtest 'substitute_stock swaps two plots and keeps their names' => sub {
    rename_plot($plot{1}, "test_trial-$original->{1}->{accession}-1");
    my $r = post_json("/ajax/breeders/trial/$trial_id/substitute_stock", [ plot_1_info => "$plot{1},x", plot_2_info => "$plot{2},y" ]);
    is($r->{success}, 1, 'success');
    is_deeply([ map { plot_state($plot{$_})->{accession} } (1, 2) ], [ $original->{2}->{accession}, $original->{1}->{accession} ], 'accessions swapped');
    is_deeply([ map { plot_state($plot{$_})->{name} } (1, 2) ], [ "test_trial-$original->{1}->{accession}-1", 'test_trial22' ], 'names kept, also one with the old accession name in it (as before)');
    is_deeply($r->{renamed}, [], 'nothing renamed');
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

    # the rights of the trial page: a submitter of the trial's breeding program, not of another one
    my $submitter = Test::WWW::Mechanize->new;
    $submitter->post_ok("$base/brapi/v1/token", [ username => 'johndoe', password => 'secretpw', grant_type => 'password' ], 'login as johndoe, a submitter of the program');
    my $submitter_ua = LWP::UserAgent->new;
    $submitter_ua->default_header('Content-Type' => 'application/json');
    $submitter_ua->default_header('Authorization' => 'Bearer '.decode_json($submitter->content)->{access_token});
    my $dbh = $schema->storage->dbh;
    my ($johndoe_id) = $dbh->selectrow_array("SELECT sp_person_id FROM sgn_people.sp_person WHERE username = 'johndoe'");
    my $program = CXGN::BreedersToolbox::Projects->new({ schema => $schema })->get_breeding_programs_by_trial($trial_id)->[0]->[1];
    my ($program_role_id) = $dbh->selectrow_array("SELECT sp_role_id FROM sgn_people.sp_roles WHERE name = ?", undef, $program);
    my $had_role = $dbh->do("DELETE FROM sgn_people.sp_person_roles WHERE sp_person_id = ? AND sp_role_id = ?", undef, $johndoe_id, $program_role_id);
    ok($had_role > 0, "johndoe had the role of program $program");
    $resp = $submitter_ua->put("$base/brapi/v2/observationunits/$plot{10}", Content => $body);
    is($resp->code, 403, 'a submitter who is not in the program of the trial is refused');
    like($resp->decoded_content, qr/submitter associated with breeding program \Q$program\E/, 'and told why');
    is(plot_state($plot{10})->{accession}, $original->{10}->{accession}, 'the plot keeps its accession');
    $dbh->do("INSERT INTO sgn_people.sp_person_roles (sp_person_id, sp_role_id) VALUES (?, ?)", undef, $johndoe_id, $program_role_id);
    $resp = $submitter_ua->put("$base/brapi/v2/observationunits/$plot{10}", Content => $body);
    ok($resp->is_success, 'a submitter of the program may') or diag($resp->decoded_content);
    is(plot_state($plot{10})->{accession}, 'test_accession1', 'germplasm changed');
    restore();
};

done_testing();
