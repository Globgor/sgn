
# Runs R/mixed_models_sommer.R and R/mixed_models_spl2D.R on a small
# phenotype file, with the model strings and parameter file that
# CXGN::MixedModels writes, and checks the result files that
# SGN::Controller::AJAX::MixedModels reads.

use strict;
use warnings;

use Test::More;
use File::Temp qw | tempdir |;
use File::Slurp qw | read_file |;
use CXGN::MixedModels;

if (system("Rscript -e 'library(sommer)' >/dev/null 2>&1") != 0) {
    plan skip_all => "Rscript with the R package sommer is not available";
}

my $trait = "dry matter content percentage|CO_334:0000092";
my @accessions = map { sprintf("acc_%02d", $_) } 1..12;

my @metadata_headers = ( 'studyYear', 'programDbId', 'programName', 'programDescription', 'studyDbId', 'studyName', 'studyDescription', 'studyDesign', 'plotWidth', 'plotLength', 'fieldSize', 'fieldTrialIsPlannedToBeGenotyped', 'fieldTrialIsPlannedToCross', 'plantingDate', 'harvestDate', 'locationDbId', 'locationName', 'germplasmDbId', 'germplasmName', 'germplasmSynonyms', 'observationLevel', 'observationUnitDbId', 'observationUnitName', 'replicate', 'blockNumber', 'plotNumber', 'rowNumber', 'colNumber', 'entryType', 'plantNumber', 'plantedSeedlotStockDbId', 'plantedSeedlotStockUniquename', 'plantedSeedlotCurrentCount', 'plantedSeedlotCurrentWeightGram', 'plantedSeedlotBoxName', 'plantedSeedlotTransactionCount', 'plantedSeedlotTransactionWeight', 'plantedSeedlotTransactionDescription', 'availableGermplasmSeedlotUniquenames' );

my $dir = tempdir( CLEANUP => 1 );

# two trials in two locations, 12 accessions in 2 replicates on a 6 x 4 grid,
# some plots without a value
#
sub write_phenotype_file {
    my $file = shift;

    open(my $F, ">", $file) || die "Can't open $file";
    print $F join("\t", @metadata_headers, $trait)."\n";
    my $plot = 0;
    foreach my $trial (0..1) {
	foreach my $rep (1..2) {
	    foreach my $a (1..@accessions) {
		$plot++;
		my $position = ($rep - 1) * @accessions + $a - 1;
		my $row = int($position / 4) + 1;
		my $col = $position % 4 + 1;
		my $value = 30 + 2 * $trial + 0.5 * ($rep - 1) + (($a * 37) % 11 - 5) + 0.3 * $row - 0.2 * $col + ((($plot * 7919) % 17) - 8) / 4;
		my %plot_data = (
		    studyYear => 2014 + $trial, programDbId => 134, programName => 'test', studyDbId => 200 + $trial,
		    studyName => "trial_$trial", studyDesign => 'RCBD', locationDbId => 23 + $trial, locationName => "location_$trial",
		    germplasmDbId => 1000 + $a, germplasmName => $accessions[$a-1], observationLevel => 'plot',
		    observationUnitDbId => 5000 + $plot, observationUnitName => "trial_${trial}_plot_$plot", replicate => $rep,
		    blockNumber => $rep, plotNumber => $plot, rowNumber => $row, colNumber => $col, entryType => 'test' );
		my @fields = map { defined($plot_data{$_}) ? $plot_data{$_} : "" } @metadata_headers;
		push @fields, ($plot % 7 == 3) ? "" : sprintf("%.2f", $value);
		print $F join("\t", @fields)."\n";
	    }
	}
    }
    close($F);
}

# write the parameter file and run the R script like CXGN::MixedModels::run_model()
# does, then convert the result headers back to the trait names
#
sub run_engine {
    my ($engine, $fixed_factors, $random_factors) = @_;

    my $file = "$dir/$engine.".join("_", @$fixed_factors).".phenotype.txt";
    write_phenotype_file($file);

    my $mm = CXGN::MixedModels->new( { tempfile => $file } );
    $mm->engine($engine);
    $mm->dependent_variables( [ $trait ] );
    $mm->fixed_factors($fixed_factors);
    $mm->random_factors($random_factors);

    my ($model, $error) = $engine eq "spl2D" ? $mm->generate_model_spl2D() : $mm->generate_model_sommer();
    ok(!$error, "$engine model generated");

    open(my $P, ">", "$file.params") || die "Can't open $file.params";
    print $P "dependent_variables <- c(\"".CXGN::MixedModels::make_R_variable_name($trait)."\")\n";
    print $P "random_factors <- c(\"".join('","', map { $_ // "" } @$random_factors)."\")\n";
    print $P "fixed_factors <- c(\"".join('","', @$fixed_factors)."\")\n";
    print $P "fixed_model <- \"$model->[0]\"\n";
    print $P "random_model <- \"$model->[1]\"\n";
    close($P);

    $mm->clean_file($file);

    my $script = $engine eq "spl2D" ? "R/mixed_models_spl2D.R" : "R/mixed_models_sommer.R";
    system("R CMD BATCH '--args datafile=\"$file\" paramfile=\"$file.params\"' $script $file.out");

    my $conversion_matrix = $mm->read_conversion_matrix("$file.traits");
    foreach my $f (map { "$file.$_" } qw | BLUPs adjustedBLUPs BLUEs adjustedBLUEs |) {
	$mm->convert_file_headers_back_to_breedbase_traits($f, $conversion_matrix) if -e $f;
    }

    return $file;
}

# check a result file the way SGN::Controller::AJAX::MixedModels::result_file_to_hash() reads it:
# the header, the accessions in the first column and numbers in the other columns
#
sub check_result_file {
    my ($file, $header, $first_column, $name) = @_;

    if (! ok(-e $file, "$name exists")) {
	# show the error from the R output file
	(my $r_output = $file) =~ s/\.\w+$/.out/;
	my $r_text = -e $r_output ? read_file($r_output) : "no R output file $r_output";
	return diag($r_text =~ /^(Error.*)/ms ? $1 : $r_text);
    }

    my @lines = read_file($file);
    chomp(@lines);
    is(shift(@lines), join("\t", @$header), "$name header");

    my @first = map { (split /\t/)[0] } @lines;
    is_deeply([ sort @first ], [ sort @$first_column ], "$name first column");

    my @not_numeric = grep { $_ !~ /^-?\d+(\.\d+)?(e[-+]?\d+)?$/i } map { my @f = split /\t/; @f[ ($header->[0] eq "Trait" ? 2 : 1) .. $#f ] } @lines;
    is_deeply(\@not_numeric, [], "$name values are numbers");

    return \@lines;
}

# sommer, accessions as random effect
#
my $file = run_engine("sommer", [ "replicate", "studyName" ], [ "germplasmName" ]);
check_result_file("$file.BLUPs", [ "accession name", $trait ], \@accessions, "sommer BLUPs");
my $lines = check_result_file("$file.adjustedBLUPs", [ "germplasmName", "predicted.value", "std.error" ], \@accessions, "sommer adjusted BLUPs");
my @out_of_range = grep { my $v = (split /\t/)[1]; $v < 20 || $v > 45 } @{$lines || []};
is_deeply(\@out_of_range, [], "sommer adjusted BLUPs are in the range of the data");

# sommer, accessions as fixed effect
#
$file = run_engine("sommer", [ "germplasmName", "replicate" ], [ "studyName" ]);
check_result_file("$file.BLUEs", [ "Trait", "Effect", "Estimate", "Std.Error", "t.value" ], [ (CXGN::MixedModels::make_R_variable_name($trait)) x 13 ], "sommer BLUEs");
$lines = check_result_file("$file.adjustedBLUEs", [ "germplasmName", "predicted.value", "std.error" ], \@accessions, "sommer adjusted BLUEs");
@out_of_range = grep { my $v = (split /\t/)[1]; $v < 20 || $v > 45 } @{$lines || []};
is_deeply(\@out_of_range, [], "sommer adjusted BLUEs are in the range of the data");

# spl2D, accessions as random effect
#
$file = run_engine("spl2D", [ "replicate" ], [ "germplasmName" ]);
check_result_file("$file.BLUPs", [ "germplasmName", $trait ], \@accessions, "spl2D BLUPs");
check_result_file("$file.adjustedBLUPs", [ "germplasmName", $trait ], \@accessions, "spl2D adjusted BLUPs");

# spl2D, accessions as fixed effect (the second fixed factor stays in the files)
#
$file = run_engine("spl2D", [ "germplasmName", "replicate" ], [ undef ]);
check_result_file("$file.BLUEs", [ "accession name", "Estimate", "Std.Error", "t.value" ], [ @accessions, "replicate" ], "spl2D BLUEs");
check_result_file("$file.adjustedBLUEs", [ "accession name", "predicted value", "std.Error" ], [ @accessions, "replicate" ], "spl2D adjusted BLUEs");

done_testing();
