use strict;
use warnings;

use lib 't/lib';
use SGN::Test::Fixture;
use Test::More;
use Test::WWW::Mechanize;
use LWP::UserAgent;
use JSON;

my $f = SGN::Test::Fixture->new();
my $schema = $f->bcs_schema;
my $mech = Test::WWW::Mechanize->new;
my $response;

$mech->post_ok('http://localhost:3010/brapi/v2/token', [ "username"=> "janedoe", "password"=> "secretpw", "grant_type"=> "password" ]);
$response = decode_json $mech->content;
my $access_token = $response->{access_token};
ok($access_token, 'logged in');

# Keep going when a call fails, so every case below is reported
sub get_json {
    my ($url, $name) = @_;
    $mech->get($url);
    is($mech->status, 200, $name || "GET $url");
    return eval { decode_json($mech->content) } || {};
}

sub names {
    my $response = shift;
    return [ map { $_->{variantDbId} } @{$response->{result}->{data} || []} ];
}

# Upload the 18-variant VCF the same way as MarkersetAndSearch.t
my $location_id = $schema->resultset('NaturalDiversity::NdGeolocation')->search({description => 'Cornell Biotech'})->first->nd_geolocation_id;
my $breeding_program_id = $schema->resultset('Project::Project')->search({name => 'test'})->first->project_id;

sub upload_vcf {
    my ($file_name, $project_name, $protocol_name) = @_;
    my $ua = LWP::UserAgent->new;
    my $upload = $ua->post(
        'http://localhost:3010/ajax/genotype/upload',
        Content_Type => 'form-data',
        Content => [
            upload_genotype_vcf_file_input => [ $f->config->{basepath}."/t/data/genotype_data/$file_name", 'genotype_vcf_data_upload' ],
            "sgn_session_id"=>$access_token,
            "upload_genotypes_species_name_input"=>"Manihot esculenta",
            "upload_genotype_vcf_project_name"=>$project_name,
            "upload_genotype_location_select"=>$location_id,
            "upload_genotype_year_select"=>"2015",
            "upload_genotype_breeding_program_select"=>$breeding_program_id,
            "upload_genotype_vcf_observation_type"=>"accession",
            "upload_genotype_vcf_facility_select"=>"IGD",
            "upload_genotype_vcf_project_description"=>"Test uploading",
            "upload_genotype_vcf_protocol_name"=>$protocol_name,
            "upload_genotype_vcf_include_igd_numbers"=>0,
            "upload_genotype_vcf_reference_genome_name"=>"Mesculenta_511_v7",
            "upload_genotype_add_new_accessions"=>0,
            "upload_genotype_accept_warnings"=>1,
        ]
    );
    ok($upload->is_success, "upload $file_name");
    my $result = eval { decode_json($upload->decoded_content) } || {};
    is($result->{success}, 1, "upload $file_name succeeded");
    return ($result->{project_id}, $result->{nd_protocol_id});
}

my ($project_id, $protocol_id) = upload_vcf('test_genotype_upload.vcf', 'test_variants_paging_project', 'variants_paging_protocol');
my $variantset_id = $project_id.'p'.$protocol_id;

$mech->default_header("Content-Type" => "application/json");
$mech->default_header('Authorization'=> 'Bearer ' . $access_token);

# All variants of the set on one page
$response = get_json("http://localhost:3010/brapi/v2/variants?variantSetDbId=$variantset_id&pageSize=100");
my $all = names($response);
is(scalar(@$all), 18, 'variants: one big page returns all 18 variants');
is($response->{metadata}->{pagination}->{totalCount}, 18, 'variants: totalCount 18');

# /variants pages 0 and 1
$response = get_json("http://localhost:3010/brapi/v2/variants?variantSetDbId=$variantset_id&pageSize=5&page=0");
is_deeply(names($response), [ @$all[0..4] ], 'variants page 0 returns variants 1-5');
is_deeply($response->{metadata}->{pagination}, { totalCount => 18, totalPages => 4, pageSize => 5, currentPage => 0 }, 'variants page 0 pagination');

$response = get_json("http://localhost:3010/brapi/v2/variants?variantSetDbId=$variantset_id&pageSize=5&page=1");
is_deeply(names($response), [ @$all[5..9] ], 'variants page 1 returns variants 6-10');
is_deeply($response->{metadata}->{pagination}, { totalCount => 18, totalPages => 4, pageSize => 5, currentPage => 1 }, 'variants page 1 pagination');
like($mech->content, qr/"totalCount":18[,}]/, 'variants totalCount is a JSON number');

$response = get_json("http://localhost:3010/brapi/v2/variants?variantSetDbId=$variantset_id&pageSize=5&page=3");
is_deeply(names($response), [ @$all[15..17] ], 'variants last page returns variants 16-18');

# /variantsets/{id}/variants pages 0 and 1
$response = get_json("http://localhost:3010/brapi/v2/variantsets/$variantset_id/variants?pageSize=5&page=0");
is_deeply(names($response), [ @$all[0..4] ], 'variantsets/{id}/variants page 0 returns variants 1-5');
is_deeply($response->{metadata}->{pagination}, { totalCount => 18, totalPages => 4, pageSize => 5, currentPage => 0 }, 'variantsets/{id}/variants page 0 pagination');

$response = get_json("http://localhost:3010/brapi/v2/variantsets/$variantset_id/variants?pageSize=5&page=1");
is_deeply(names($response), [ @$all[5..9] ], 'variantsets/{id}/variants page 1 returns variants 6-10');
is_deeply($response->{metadata}->{pagination}, { totalCount => 18, totalPages => 4, pageSize => 5, currentPage => 1 }, 'variantsets/{id}/variants page 1 pagination');

# POST /search/variants with page 1 keeps variants 6-10
$mech->post('http://localhost:3010/brapi/v2/search/variants', Content => encode_json({ variantSetDbIds => [ $variantset_id ], pageSize => 5, page => 1 }));
like($mech->status, qr/^20[02]$/, 'POST search/variants');
$response = eval { decode_json($mech->content) } || {};
my $search_id = $response->{result}->{searchResultsDbId};
$response = get_json("http://localhost:3010/brapi/v2/search/variants/$search_id");
is_deeply(names($response), [ @$all[5..9] ], 'search/variants with page 1 returns variants 6-10');

# Variant fields follow the BrAPI Variant schema
my ($sv_project_id, $sv_protocol_id) = upload_vcf('test_genotype_upload_variant_fields.vcf', 'test_variant_fields_project', 'variant_fields_protocol');
my $sv_variantset_id = $sv_project_id.'p'.$sv_protocol_id;

foreach my $url ("http://localhost:3010/brapi/v2/variants?variantSetDbId=$sv_variantset_id", "http://localhost:3010/brapi/v2/variantsets/$sv_variantset_id/variants") {
    $response = get_json($url);
    my %variants = map { $_->{variantDbId} => $_ } @{$response->{result}->{data} || []};
    is_deeply([ sort keys %variants ], [ 'S1_91594', 'S1_91597', 'S1_96576' ], "$url: all three variants");

    my $sv = $variants{S1_91594} || {};
    is_deeply($sv->{alternateBases}, [ 'A', 'T' ], "$url: alternateBases");
    is_deeply($sv->{alternate_bases}, [ 'A', 'T' ], "$url: alternate_bases");
    is_deeply($sv->{variantNames}, [ 'S1_91594' ], "$url: variantNames");
    is_deeply($sv->{filtersFailed}, [ 'q10', 's50' ], "$url: filtersFailed");
    is($sv->{svlen}, -5, "$url: svlen");
    is_deeply($sv->{cipos}, [ -2, 3 ], "$url: cipos");
    is_deeply($sv->{ciend}, [ -1, 4 ], "$url: ciend");
    is($sv->{referenceName}, '1', "$url: referenceName");
    is($sv->{start}, 91593, "$url: start is 0-based");
    is($sv->{end}, 91594, "$url: end");

    my $snp = $variants{S1_91597} || {};
    is_deeply($snp->{alternateBases}, [ 'A' ], "$url: one alternate base");
    is($snp->{svlen}, undef, "$url: svlen null without SVLEN");
    is_deeply($snp->{cipos}, [], "$url: cipos empty without CIPOS");
    is_deeply($snp->{ciend}, [], "$url: ciend empty without CIEND");
    is($snp->{filtersFailed}, undef, "$url: filtersFailed null for PASS");
}

# Clean up
$mech->get("http://localhost:3010/ajax/genotyping_protocol/delete/$protocol_id");
$response = eval { decode_json($mech->content) } || {};
is($response->{success}, 1, 'genotyping protocol deleted');
$schema->resultset("Project::Project")->find({project_id=>$project_id})->delete();
$mech->get("http://localhost:3010/ajax/genotyping_protocol/delete/$sv_protocol_id");
$response = eval { decode_json($mech->content) } || {};
is($response->{success}, 1, 'second genotyping protocol deleted');
$schema->resultset("Project::Project")->find({project_id=>$sv_project_id})->delete();

$f->clean_up_db();

done_testing();
