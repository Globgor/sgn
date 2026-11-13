use strict;
use warnings;

use Test::More;
use SGN::Controller::solGS::solGS;
use SGN::Controller::solGS::Utils;

# format_phenotype_dataset_headers renames every trait column of a trial
# phenotype file to the trait's acronym; solGS analyses read the column by that
# acronym. Trait names with regex metacharacters must be renamed too.

my @meta = qw(studyYear germplasmName observationUnitName replicate);
my @traits = ('dry matter content percentage',
              'plant height (cm)',
              'leaf area [cm2]',
              'ear count + tillers',
              'fresh root weight');
my $line = join("\t", @meta, @traits);

my $formatted = SGN::Controller::solGS::solGS->format_phenotype_dataset_headers($line, \@meta, undef);
my @headers = split(/\t/, $formatted, -1);
is(scalar(@headers), scalar(@meta) + scalar(@traits), 'one header per column');
is_deeply([@headers[0 .. $#meta]], \@meta, 'metadata headers are unchanged');

my @cleaned = split(/\t/, SGN::Controller::solGS::Utils->clean_traits(join("\t", @traits)));
my $acronyms = SGN::Controller::solGS::Utils->acronymize_traits([@cleaned])->{acronym_table};
for my $i (0 .. $#traits) {
    my $header = $headers[@meta + $i];
    ok(exists $acronyms->{$header}, "column '$traits[$i]' is renamed to its acronym ($header)");
    is($acronyms->{$header}, $cleaned[$i], "acronym $header stands for '$traits[$i]'");
}

done_testing();
