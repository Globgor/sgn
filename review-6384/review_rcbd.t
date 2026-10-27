# S6: RCBD trial (rep = block). What do replace_stock and replace_plot_accessions do to reps and default names?
use strict; use warnings;
use lib 't/lib';
use SGN::Test::Fixture; use Test::More; use Test::WWW::Mechanize; use JSON::XS; use SGN::Model::Cvterm;
my $f = SGN::Test::Fixture->new(); my $schema = $f->bcs_schema;
my $mech = Test::WWW::Mechanize->new; my $base = 'http://localhost:3010';
$mech->post_ok("$base/brapi/v1/token", [ username => 'janedoe', password => 'secretpw', grant_type => 'password' ]);
my $trial_id = $schema->resultset('Project::Project')->find({ name => 'test_trial' })->project_id();
my %t = map { $_->[0] => SGN::Model::Cvterm->get_cvterm_row($schema, $_->[1], $_->[2])->cvterm_id() } (['plot_of','plot_of','stock_relationship'], ['rep','replicate','stock_property'], ['block','block','stock_property'], ['pn','plot number','stock_property'], ['design','design','project_property']);
my @plots = (38857..38871);
sub prop { my ($pid, $type, $val) = @_; my $rs = $schema->resultset('Stock::Stockprop')->search({ stock_id => $pid, type_id => $t{$type} }); if (defined $val) { $rs->delete; $schema->resultset('Stock::Stockprop')->create({ stock_id => $pid, type_id => $t{$type}, value => $val, rank => 0 }); } my $r = $rs->first; return $r ? $r->value : undef; }
sub acc { my $pid = shift; my $rel = $schema->resultset('Stock::StockRelationship')->find({ subject_id => $pid, type_id => $t{plot_of} }); return $schema->resultset('Stock::Stock')->find({ stock_id => $rel->object_id })->uniquename; }
sub name { $schema->resultset('Stock::Stock')->find({ stock_id => shift })->uniquename }
# make it an RCBD: plots 1-5 block/rep 1, 6-10 block/rep 2, 11-15 block/rep 3, default RCBD names TRIAL-rep{rep}-{ACC}_{n}
$schema->resultset('Project::Projectprop')->search({ project_id => $trial_id, type_id => $t{design} })->update({ value => 'RCBD' });
foreach my $pid (@plots) {
    my $pn = prop($pid, 'pn'); my $b = int(($pn - 1) / 5) + 1; my $n = ($pn - 1) % 5 + 1;
    prop($pid, 'block', $b); prop($pid, 'rep', $b);
    my $nm = "test_trial-rep$b-".acc($pid)."_$n";
    $schema->resultset('Stock::Stock')->find({ stock_id => $pid })->update({ uniquename => $nm, name => $nm });
}
$mech->get_ok("$base/ajax/breeders/trial/$trial_id/refresh_cache");
sub table { my $title = shift; diag($title); my $bad = 0; foreach my $pid (sort { prop($a,'pn') <=> prop($b,'pn') } @plots) { my ($b, $r, $nm) = (prop($pid,'block'), prop($pid,'rep'), name($pid)); my ($nr) = $nm =~ /-rep(\d+)-/; my $flag = ($b != $r ? ' <-- rep != block' : '').(defined $nr && $nr != $r ? ' <-- name says rep'.$nr : ''); $bad++ if $flag; diag(sprintf("  plot %2s block %s rep %s %-16s %s%s", prop($pid,'pn'), $b, $r, acc($pid), $nm, $flag)); } return $bad; }
table('before');
my $acc3 = $schema->resultset('Stock::Stock')->find({ uniquename => 'test_accession3' })->stock_id;
$mech->post("$base/ajax/breeders/trial/$trial_id/replace_stock", [ old_stock_id => $acc3, new_stock => 'test_accession1', trial_stock_type => 'accession' ]);
diag('replace_stock test_accession3 -> test_accession1: '.$mech->content);
my $bad = table('after replace_stock');
is($bad, 0, 'RCBD: replicate stays equal to block and to the rep in the plot name');
done_testing();
