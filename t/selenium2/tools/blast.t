
use strict;

use lib 't/lib';

use Test::More;
use SGN::Test::WWW::WebDriver;

my $t = SGN::Test::WWW::WebDriver->new();

$t->get_ok('/tools/blast');
$t->wait_for_element('sequence', 'id');

#my $example = $t->find_element_ok('input_example', 'id', 'find input example link');
#$example->click();

my $test_sequence = <<SEQ;
>test_sequence
aattcggcaccagtaaattttcccaaaggtttcaaaaatgaaaattttgattttcctaat
aatgtttcttgctatgttgctagtaacaagtgggaataataatctagtagagacaacatg
caagaacacaccaaattataatttgtgtgtgaaaactttgtctttagaca
SEQ

my $input_box = $t->find_element_ok('sequence', 'id', 'find the seq input box');

$input_box->send_keys($test_sequence);

my $submit = $t->find_element_ok('submit_blast_button', 'id', 'find blast submit button');
$submit->click();

$t->wait_until(sub { lc($t->driver->find_element('SGN_output', 'id')->get_attribute('innerHTML')) =~ m/query[:\s]*1[\s]*aattcggcaccagtaaattttcccaaaggtttcaaaaatgaaaatttt/ }, 150);

my $elem = $t->driver->find_element('SGN_output', 'id')->get_attribute('innerHTML');
ok(lc($elem) =~ m/query[:\s]*1[\s]*aattcggcaccagtaaattttcccaaaggtttcaaaaatgaaaatttt/, "find aligned seq");

$t->driver->close();
done_testing();



