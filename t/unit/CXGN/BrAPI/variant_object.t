use strict;
use warnings;

use Test::More;
use JSON;
use CXGN::BrAPI::v2::Variants;

# One marker row as CXGN::Marker::SearchBrAPI::search returns it (VCF columns)
my $structural = {
    marker_name => 'S1_91594',
    nd_protocol_id => 4,
    project_id => [ 167 ],
    chrom => '1',
    pos => '91594',
    ref => 'G',
    alt => 'A,T',
    filter => 'q10;s50',
    info => 'SVTYPE=DEL;SVLEN=-5;CIPOS=-2,3;CIEND=-1,4;AF=0.375',
};

my $variant = CXGN::BrAPI::v2::Variants->variant_from_marker($structural);
is_deeply($variant->{alternateBases}, [ 'A', 'T' ], 'alternateBases is the ALT split on commas');
is_deeply($variant->{alternate_bases}, [ 'A', 'T' ], 'deprecated alternate_bases is the same array');
is_deeply($variant->{variantNames}, [ 'S1_91594' ], 'variantNames is an array');
is($variant->{variantDbId}, 'S1_91594', 'variantDbId');
is_deeply($variant->{filtersFailed}, [ 'q10', 's50' ], 'filtersFailed is the FILTER split on semicolons');
ok($variant->{filtersApplied}, 'filtersApplied');
ok(!$variant->{filtersPassed}, 'filtersPassed is false');
is($variant->{svlen}, -5, 'svlen is an integer');
is_deeply($variant->{cipos}, [ -2, 3 ], 'cipos');
is_deeply($variant->{ciend}, [ -1, 4 ], 'ciend');
is($variant->{variantType}, 'DEL', 'variantType');
is($variant->{referenceName}, '1', 'referenceName is the VCF CHROM');
is($variant->{start}, 91593, 'start is 0-based (VCF POS - 1)');
is($variant->{end}, 91594, 'end is start + length of the reference bases');
is_deeply($variant->{variantSetDbId}, [ '167p4' ], 'variantSetDbId');

my $snp = {
    marker_name => 'S1_21594',
    nd_protocol_id => 3,
    project_id => [ 166 ],
    chrom => '1',
    pos => '21594',
    ref => 'GA',
    alt => 'A',
    filter => 'PASS',
    info => 'AR2=0.29;DR2=0.342;AF=0.375',
};

$variant = CXGN::BrAPI::v2::Variants->variant_from_marker($snp);
is_deeply($variant->{alternateBases}, [ 'A' ], 'single ALT is a one-element array');
is($variant->{svlen}, undef, 'svlen is null without SVLEN');
is_deeply($variant->{cipos}, [], 'cipos is empty without CIPOS');
is_deeply($variant->{ciend}, [], 'ciend is empty without CIEND');
is($variant->{filtersFailed}, undef, 'filtersFailed is null for PASS');
ok($variant->{filtersPassed}, 'filtersPassed for PASS');
is($variant->{start}, 21593, 'start of the SNP');
is($variant->{end}, 21595, 'end covers both reference bases');

# The JSON types a BrAPI client sees
my $json = JSON->new->canonical->encode($variant);
like($json, qr/"start":21593[,}]/, 'start is a JSON number');
like($json, qr/"end":21595[,}]/, 'end is a JSON number');
like($json, qr/"svlen":null/, 'svlen is JSON null');
like($json, qr/"cipos":\[\]/, 'cipos is a JSON empty array');

$variant = CXGN::BrAPI::v2::Variants->variant_from_marker({ %$snp, filter => '.', alt => '.' });
is_deeply($variant->{alternateBases}, [], 'ALT "." gives no alternate bases');
is($variant->{filtersFailed}, undef, 'filtersFailed is null when no filter was applied');
ok(!$variant->{filtersApplied}, 'filtersApplied is false for "."');

done_testing();
