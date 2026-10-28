# Review pass 1: five critics, triage

Critics: data integrity, analyses/statistics, files/labels/Field Book, APIs/permissions/UI,
field scenarios. Read-only, each finding traced from a real caller.

| # | Finding (critics) | Severity | Resolution |
|---|---|---|---|
| 1 | The parser refuses every plot with a seed transaction, so the round trip fails on any trial planted from seedlots, also for curators (all 4 that looked) | blocker | Parser check removed. Seed transactions follow the packets (`_plan_seedlots`); optional `seedlot_name`; leftover packet = seed taken from the seedlot (inventory unchanged); harvested seedlots warned |
| 2 | Phenotyping spreadsheets made before a plot was marked are refused as a whole (empty rows count) (3) | should fix | verify checks only units with a value (not empty / `.` / NA) |
| 3 | Plants, subplots, tissue samples of a not planted plot can still get phenotypes (4) | should fix | verify refuses them (recursive CTE up to the plot); "Add plants/subplots/tissue samples" skip not planted plots |
| 4 | BrAPI v1, drone imagery, derived traits store without verify (1) | should fix | store() skips values of not planted units |
| 5 | CRD: marking a plot renumbers its neighbours; with a template the change fails; heritability script drops the accession (2) | should fix | Not planted plots keep their place in the CRD numbering |
| 6 | Treatments counted and deleted as phenotypes of not planted plots (2) | should fix | Treatments (`*_TREATMENT`) and notes stay |
| 7 | High-dimensional data (NIRS…) of not planted plots neither counted nor deleted (1) | should fix | Counted and deleted with `delete_phenotypes` |
| 8 | Parse errors with names from the file rendered as HTML (XSS) (2) | should fix | Escaped on the server; shown as text (DOMParser) in a dialog |
| 9 | "Keep the plot names" off by default: renames labels in the field, breaks re-upload (3) | should fix | On by default; help says when to uncheck |
| 10 | An auto rename can give a plot the name another plot has (old labels/files hit the wrong plot) (1) | should fix | Warning in the preview |
| 11 | Stale file / someone else's change between preview and apply silently reverts or deletes more (2) | should fix | Preview returns `plan_digest`; apply refuses a different plan |
| 12 | No record on the trial that it was corrected (1) | should fix | Applied file kept in Uploaded Additional Files |
| 13 | xlsx layout writes `397073.10` as a number, `0101` loses its zero (1) | should fix | `*_name` columns written as text |
| 14 | Associated Images spreadsheet lists not planted plots (1) | should fix | Planted design |
| 15 | Field map spreadsheet shows the planned accession of an empty place (1) | should fix | "(not planted)" |
| 16 | Empty accession cell on a not planted row is an error; no not_planted column in a planting order file (2) | nice | Allowed; help says to add the column |
| 17 | Rows of other trials (planting order with "same field") give errors (1) | nice | Skipped by `trial_name` |
| 18 | Error modal over the long upload dialog breaks scrolling; result reloads only via Close (1) | nice | Errors in the stacked dialog; reload on hide |
| 19 | New check plot: its plants keep entryType test (1) | nice | Children marked too |
| 20 | Cross parents not warned when a plot is only marked not planted (1) | nice | Warning |
| 21 | "Not planted" vs "lost after planting" wording (2) | should fix | Dialog and docs: lost plots stay planted, record stand count |
| 22 | DB patch in db/00208, upstream already has db/00209 (1) | should fix | Merge upstream master, move to 00209 |
| 23 | 500 on a file without plot_name column (`@{undef}`) (1) | nice | Guarded |

Not changed (out of scope, predates this change, noted in the description):
- BrAPI v2 POST /observations returns a generic 500 for every verify error.
- BrAPI PUT /observationunits: no materialized view refresh / solGS cache clear, may write back rep and entryType.
- Trial phenotype summary counts not planted plots as missing.
- Planned accession of a not planted plot still counts as "in the trial" (by design: the plan stays visible).
- Mixed seed in one plot, extra plots outside the design, border plots measured later.
