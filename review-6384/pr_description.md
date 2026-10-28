# Correct what was planted: Replace, Shift and Not Planted, in one service

Supersedes #6384 (and #6353). Builds on #6384, fixes its replicate handling and
adds the two corrections breeders ask for most: a planting that shifted along
the planting order, and places where nothing was planted.

## The rule

A plot is a place in the field. Its plot number, block, replicate, row and
column describe that place and are part of the design; the accession is what
grows there. A correction changes what grows there and never moves the plot.
So blocks and replicates stay (except in a CRD, where the replicate is the
n-th plot of an accession and is numbered again), and phenotypes stay with the
plot they were measured on.

## What changes

**One service, `CXGN::Trial::AccessionChange`.** Every way to change the
accession of plots goes through it: Replace Accession, the plot dialog of the
field map, the Change Accessions upload, Substitute, genotyping plate wells
and BrAPI `PUT /observationunits`. `plan()` returns what would change
without changing anything; `apply()` does it in one transaction and refuses
plots that were changed by someone else in the meantime. It reads the layout
from the database, not from the cache.

- Plants, subplots and tissue samples of the plot in this trial follow it;
  samples in other trials (genotyping plates) keep their accession, with a warning.
- Plot names: replaced where the old name is a whole part of the name, or from
  the trial's plot name template; optional. Plants and samples are renamed with
  their plot.
- Check plots follow the check accession (`is a control`).
- Entry numbers move to a new accession that takes the place of an old one.
- Warnings for plots with phenotypes and for plots used as cross parents.

**Shift Accessions** (Edit Field Layout). For a planting that shifted: from a
plot on, every place got the packet planned for the place before it (or after
it), usually to the end of the column, where the packet left over goes into a
border and the next column is planted as planned. The path is the one of
Download Plot Order: by column or row, serpentine or zigzag, from any corner,
with the borders planted on the way (set from the borders saved with the
field map). This matters: in a serpentine order a border column is a turn of
its own, so with a left border column 1 goes down and column 2 up, and a path
built without the border runs the wrong way in every column. The stretch ends
at the end of the column or row of the first plot (the default), at a chosen
plot, or at the last plot. The preview shows the path column by column with
its direction ("Column 2, rows 2 to 5"). The places that stay empty are
marked as not planted; places already marked are skipped. Plot names are kept
by default, because the labels in the field carry them.

**Not planted plots.** New stock property `not_planted` (db patch
`AddNotPlantedStockprop`). The plot keeps its planned accession, so the plan
stays visible, and:

- the field map shows it empty (white, dashed border), with a legend entry, a
  tooltip, and Mark as Not Planted / Planted in the plot dialog;
- it is left out of Field Book files and the phenotyping spreadsheets;
- phenotypes cannot be stored for it (`StorePhenotypes::verify`);
- it is flagged in the plot layout download (`not_planted` column) and in BrAPI
  (`additionalInfo.notPlanted`, read only);
- it is left out of the replicate numbering of a CRD;
- phenotypes it already has are deleted only when the user confirms it
  (`delete_phenotypes`); otherwise nothing is changed.

Endpoint: `POST /ajax/breeders/trial/<id>/not_planted` (`plot_names` or
`plot_ids`, `not_planted`, `delete_phenotypes`, `preview`). The Change
Accessions upload takes an optional `not_planted` column.

**Preview first.** Every dialog shows the plan in a dialog and changes nothing
until the user confirms it. The front end is a webpack entry,
`js/source/entries/trial_accession_change.js` (`summaryLines`, `showSummary`,
`confirmDialog`, `changeWithPreview`), with tests in `js/test`.

**Also**: the solGS analysis cache of the trial is cleared after a change; the
plot, plant, subplot and tissue sample layout downloads with a plot order no
longer add empty rows for plots that are left out.

## Fixed from #6384

- Replicates in blocked designs: #6384 numbers the replicate per accession
  after a change. In an RCBD the replicate is the block, so replacing an
  accession by one already in the trial gives it replicates 1 to 8 in a
  4-block trial, and a shift across blocks gives plots a replicate other than
  their block. The replicate is kept now (in a CRD it is numbered again).
- A plot without a replicate stockprop made `rebuild_trial_plot_replicates`
  call `update` on undef, so Replace Accession failed on such trials.
- Renames ran in hash order, one at a time, so with a plot name template the
  same request sometimes failed (`... already exists in the database`). All
  renames now happen in two passes.
- Plot names were changed by substring, also inside the trial name or a longer
  accession name (`A1` in `A10`). Only whole name parts are replaced now.
- The layout was read from the cached layout, which is stale exactly in the
  trials that need the fix (#4642). It is read from the database now.
- Changing one plot was not one transaction: a refused new name left the new
  accession in place.
- Errors sent to the browser carried `{UNKNOWN}:` and server file paths.
- The `trial_stock_type` sent by the client could widen the stock types a
  trial accepts; the trial decides now.

## Statistics

Simulated with the models Breedbase uses (heritability tool:
`lmer(y ~ (1|germplasmName) + replicate)`; Mixed Models with replicate random),
RCBD with 20 accessions x 4 blocks, a skip at plot 26 shifting the rest, one
place left empty on purpose, one plot lost; 500 simulations:

| data | accuracy (cor with true values) | H2 (heritability tool) |
|---|---|---|
| as it grew | 0.893 | 0.393 |
| after Shift Accessions + not planted | 0.893 (identical in all 500) | 0.393 |
| not corrected | 0.000 | 0.000 (63% of fits singular) |
| corrected, replicates renumbered as in #6384 | 0.889 | 0.391 |
| corrected, empty places recorded as 0 | 0.648 | 0.086 |

Not corrected, a shift of 14 plots already lowers the accuracy from 0.90 to
0.83. Empty places must be missing values, not zeros, which is why not planted
plots cannot get phenotypes.

Shifts inside columns (column serpentine after a left border, a skip in three
columns of a 10 x 8 RCBD, each shifted to the end of its column; Mixed Models;
300 simulations): Shift Accessions with the border gives the accuracy of the
true data (0.873, identical in all 300); not corrected 0.791; a shift built
without the border, so the wrong way in each column, 0.700, worse than no
correction.

## Tests

- `t/unit_fixture/CXGN/Trial/AccessionChange.t`: 51 scenarios, 382 assertions.
- `t/unit_mech/AJAX/BreedersToolbox/TrialChangeAccessions.t`: 19 scenarios
  through the web server, 170 assertions, including the path of a shift against
  the planting order download, with and without a border.
- `js/test/trial_accession_change.test.js`: 36 assertions (all 42 JS tests pass).
- Regression: trial, Field Book, data collector, phenotype upload, BrAPI v2,
  TrialMetadata and `t/unit` (Mason compile) tests. Four assertions of
  `t/unit_fixture/CXGN/Trial.t` (1-2, 71-72) fail in the same run on the base
  of #6384 as well; they depend on the order of the tests.
- Docs: `docs/r_markdown_docs/managing_field_trials.Rmd`.

## Deploy

Run the db patches (`AddNotPlantedStockprop`) and build the JS.
