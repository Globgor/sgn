package main;

use strict;
use warnings;
use lib 't/lib';
use Test::More;
use SGN::Test::Fixture;
use CXGN::BrAPI::v1::Germplasm;
use CXGN::BrAPI::v2::Germplasm;
use CXGN::BrAPI::v2::Pedigree;

my $fixture = SGN::Test::Fixture->new();
my %args = (
    bcs_schema => $fixture->bcs_schema(),
    people_schema => $fixture->people_schema(),
    phenome_schema => $fixture->phenome_schema(),
    metadata_schema => $fixture->metadata_schema(),
    context => undef, page_size => 10, page => 0, status => [],
);

for my $version (qw(v1 v2)) {
    my $class = "CXGN::BrAPI::${version}::Germplasm";
    my $api = $class->new(\%args);
    my $without_parents = $api->germplasm_pedigree({stock_id => 38840})->{result};
    is_deeply($without_parents->{siblings}, [], "$version: no parents means no siblings");
    if ($version eq 'v2') {
        is_deeply($without_parents->{parents}, [], "$version: no parents");
    }
    else {
        is_deeply([$without_parents->{parent1DbId}, $without_parents->{parent2DbId}],
            [undef, undef], "$version: no parents");
        # Parentless pedigree fields must not come from unrelated sibling rows.
        is_deeply([@{$without_parents}{qw(parent1Name parent2Name pedigree crossingPlan)}],
            [undef, undef, '/', undef], 'v1: parentless pedigree fields');
    }

    my $with_parents = $api->germplasm_pedigree({stock_id => 38876})->{result};
    my $parent_ids = $version eq 'v2'
        ? [map { $_->{germplasmDbId} } @{$with_parents->{parents}}]
        : [map { "$with_parents->{$_}" } qw(parent1DbId parent2DbId)];
    is_deeply($parent_ids, ['38843', '38844'], "$version: parents remain unchanged");
    is_deeply([sort map { $_->{germplasmDbId} } @{$with_parents->{siblings}}],
        [qw(38846 38847 38848 38849 38850 38851 38852 38853 38854 38855 38873 38874 38875 38877)],
        "$version: sibling membership remains unchanged");

    my $female_only = $api->germplasm_pedigree({stock_id => 38844})->{result};
    my $female_parent_ids = $version eq 'v2'
        ? [map { $_->{germplasmDbId} } @{$female_only->{parents}}]
        : [map { defined $_ ? "$_" : () } @{$female_only}{qw(parent1DbId parent2DbId)}];
    is_deeply($female_parent_ids, ['38842'], "$version: female-only parent");
    is_deeply([sort map { $_->{germplasmDbId} } @{$female_only->{siblings}}],
        [], "$version: female-only sibling membership");
}

my $pedigree_api = CXGN::BrAPI::v2::Pedigree->new(\%args);
my $dbh = $fixture->bcs_schema()->storage->dbh();
my $old_callbacks = $dbh->{Callbacks};
my %callbacks = %{$old_callbacks || {}};
my %child_callbacks = %{$callbacks{ChildCallbacks} || {}};
my $sibling_queries = 0;
my $old_execute = $child_callbacks{execute};
$child_callbacks{execute} = sub {
    $sibling_queries++ if ($_[0]->{Statement} || '') =~ /SELECT DISTINCT female_parent\.stock_id, female_parent\.uniquename/i;
    return $old_execute->(@_) if $old_execute;
    return;
};
$callbacks{ChildCallbacks} = \%child_callbacks;
$dbh->{Callbacks} = \%callbacks;
my ($parentless, $parented, $female_only, $error, $parentless_queries, $parented_queries);
eval {
    my %params = (
        pedigreeDepth => [1], progenyDepth => [1], includeFullTree => ['false'],
        includeSiblings => ['true'], includeParents => ['true'], includeProgeny => ['false'],
    );
    $parentless = $pedigree_api->search({%params, germplasmDbId => [38840]})->{result}->{data}->[0];
    $parentless_queries = $sibling_queries;
    $parented = $pedigree_api->search({%params, germplasmDbId => [38876]})->{result}->{data}->[0];
    $parented_queries = $sibling_queries - $parentless_queries;
    $female_only = $pedigree_api->search({%params, germplasmDbId => [38844]})->{result}->{data}->[0];
    1;
} or $error = $@ || 'Pedigree search failed';
$dbh->{Callbacks} = $old_callbacks;
die $error if $error;

is_deeply($parentless->{siblings}, [], 'pedigree: no parents means no siblings');
is_deeply($parentless->{parents}, [], 'pedigree: no parents');
is($parentless_queries, 0, 'pedigree: no sibling query without parents');
cmp_ok($parented_queries, '>', 0, 'pedigree: sibling query counter sees the parented case');
is_deeply([sort map { $_->{germplasmDbId} } @{$parented->{siblings}}],
    [qw(38846 38847 38848 38849 38850 38851 38852 38853 38854 38855 38873 38874 38875 38877)],
    'pedigree: sibling membership remains unchanged');
is_deeply([map { $_->{germplasmDbId} } @{$female_only->{parents}}],
    ['38842'], 'pedigree: female-only parent');
is_deeply([sort map { $_->{germplasmDbId} } @{$female_only->{siblings}}],
    [], 'pedigree: female-only sibling membership');

done_testing();
