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
it). Along the plot numbers or the planting order (row/column, serpentine or
zigzag, from any corner, as in Download Plot Order). The places that stay empty
are marked as not planted; places already marked are skipped. Plot names are
kept by default, because the labels in the field carry them.

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

## Tests

- `t/unit_fixture/CXGN/Trial/AccessionChange.t`: 49 scenarios, 357 assertions.
- `t/unit_mech/AJAX/BreedersToolbox/TrialChangeAccessions.t`: 18 scenarios
  through the web server, 151 assertions.
- `js/test/trial_accession_change.test.js` (run with the other JS tests: 39 pass).
- Regression: trial, Field Book, data collector, phenotype upload, BrAPI v2
  and TrialMetadata tests.
- Docs: `docs/r_markdown_docs/managing_field_trials.Rmd`.

## Deploy

Run the db patches (`AddNotPlantedStockprop`) and build the JS.
