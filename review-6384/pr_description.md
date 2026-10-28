# Correct a trial to what was planted: one file, not planted plots, seed that follows the packets

Supersedes #6384 (and #6353). Builds on #6384 and fixes its replicate handling. The
goal: when the planting went wrong, the trial in the database is made to match the
field, and everything that depends on it (analyses, files, labels, seed inventory)
stays right.

## Why one file and no buttons

The ways a planting goes wrong are many: a place skipped and the rest of the column
shifted, a packet planted into a border, two packets swapped, a column planted the
other way, a place left empty, the right accession from the wrong seedlot, and
corrections found at different times of the season. A button for each case would
never cover them all, and each would act on the trial as it is, so running one twice
corrects twice. A file of what was planted covers all of them and is a state, not an
action: download the trial, write what was planted, upload. Plots that already match
are left as they are, so the same file changes nothing the second time. (Earlier
versions of this PR had Shift Accessions and Not Planted Plots buttons; they were
removed for this reason.)

## The rule

A plot is a place in the field. Its plot number, block, replicate, row and column
describe that place and are part of the design; the accession is what grows there.
A correction changes what grows there and never moves the plot. Blocks and
replicates stay (in a CRD, where the replicate is the n-th plot of an accession, the
accessions that gain or lose plots are numbered again), and phenotypes stay with the
plot they were measured on.

## How to correct a trial

1. Download the trial: "Download the current layout" in the Change Accessions window
   (plot_name, accession_name, not_planted, plot number, block, replicate, row,
   column, seedlot), or Download Plot Order (planting order with the border rows).
2. Write what was planted: change accession_name where another accession grows; put 1
   in not_planted where no seed was sown. A shift is a cut and paste of accession_name
   one row down in the planting order file.
3. Upload it with Change Accessions. The preview lists every change; nothing is
   changed until the user confirms, and then exactly that is changed.

Plot names are kept by default (labels are in the field). The file is kept with the
trial. The result lists the changed plots, ready to be saved as a list for the Label
Designer.

## Problems, and how each is handled

Explained = where a user reads about it (Docs: `managing_field_trials.Rmd`; Dialog:
the Change Accessions window). Tests: `AC` = `t/unit_fixture/CXGN/Trial/AccessionChange.t`,
`TCA` = `t/unit_mech/AJAX/BreedersToolbox/TrialChangeAccessions.t`, `JS` =
`js/test/trial_accession_change.test.js`.

### Fixed from #6384

| Problem | What was done | Explained | Test |
|---|---|---|---|
| Replicates in blocked designs were numbered per accession (an RCBD accession got replicates 1 to 8 in 4 blocks) | Blocked designs keep the replicate; only a CRD is numbered again | Docs, PR | AC "RCBD: replicates and blocks are kept…", TCA "replace_stock in an RCBD…" |
| A plot without a replicate stockprop crashed Replace Accession | Plots without replicate keep none | PR | AC "CRD: a plot without replicate keeps none" |
| Renames in hash order failed at random with a name template | All renames in two passes | PR | AC "CRD with the template…" |
| Names changed by substring (`A1` inside `A10`, inside the trial name) | Only whole name parts | Docs | AC "no template: …" (2 scenarios) |
| Layout read from the stale cache (#4642) | Read from the database | PR | AC "the trial is read from the database…" |
| One plot not one transaction (a refused name left the new accession) | One transaction | PR | TCA "replace_plot_accessions: one plot" |
| Errors with `{UNKNOWN}:` and server paths | Cleaned | PR | TCA "replace_plot_accessions: one plot" |
| `trial_stock_type` from the client could widen the allowed types | The trial decides | PR | TCA "replace_stock: errors" |

### Correcting a planting

| Problem | What was done | Explained | Test |
|---|---|---|---|
| Too many kinds of planting errors for buttons | One file round trip; layout and planting order downloads upload as they are (border rows, other trials' rows skipped) | Docs, Dialog | TCA "a planting order file, corrected and uploaded again", AC "a shifted planting…" |
| Uploading the same file twice must not correct twice | Plots that match are left; "nothing to change" | Docs, Dialog | TCA "…uploaded again", JS "a plan that changes nothing…" |
| The user must see what will change | Preview of every change, then confirm | Docs, Dialog | JS "preview, confirm, change", "the preview lists every change" |
| Someone changes the trial between preview and confirm (another upload, Field Book sync) | The apply carries the digest of the preview and is refused if the plan differs | Docs | AC "apply carries out only the plan of the preview", JS "the change is the one of the preview" |
| An old file would undo later corrections | Every change is listed (no "and N more"); docs say to start from a new download | Docs | JS "the preview lists every change" |
| Labels are in the field | "Keep the plot names" on by default; a warning when a rename gives a plot another plot's name | Docs, Dialog | TCA "keeping the plot names", AC "CRD with the template…" |
| New labels for the changed plots | The result lists them and saves them as a list | Docs, Dialog | JS "changedPlots" |
| Check plots after a change | A plot with a check accession becomes a check plot (and its plants) | Docs | AC "check plots…" (3), "RCBD: a plot that becomes a check plot marks its plants too" |
| Plants, subplots, tissue samples | Follow their plot; samples in other trials (plates) warned | Docs | AC "RCBD: … plants and tissue samples follow…", "subplots…", "samples … in other trials" |
| Entry numbers | Move to a new accession that takes the place of an old one | PR | AC "entry numbers" |
| Phenotypes already collected | Stay with the plot (they count for what grew there); curators only, after a warning | Docs | TCA "at the end of the season" |
| Crosses that used a plot as a parent | Warning | Preview | AC "phenotypes and crosses…", "not planted: treatments…" |
| Cross and family-name trials with accession checks | Accessions allowed as checks; unchanged rows never refused | Dialog | AC "crosses and family names" |
| No record that a trial was corrected | The applied file is kept with the trial (Uploaded Additional Files) | Docs, Dialog | TCA "Change Accessions upload" |
| Names from the file in error messages (XSS) | Escaped; shown as text | — | TCA "what the parser reads", JS "plainText" |
| Excel turns `397073.10` or `0101` into numbers | The layout xlsx writes names as text | — | TCA (xlsx uploaded as it is) |

### Places that were not planted

| Problem | What was done | Explained | Test |
|---|---|---|---|
| No way to record an empty place; zeros would bias the analyses | Stockprop `not_planted`; the plot keeps its planned accession and its place in the design | Docs, Dialog | AC "not planted: the plot keeps its accession…" |
| "Not planted" vs "lost after planting" | Only for places where no seed was sown; a lost plot stays planted and gets its stand count | Docs, Dialog | — |
| Field Book files and spreadsheets would list it | Left out (all data levels, Associated Images too) | Docs | AC "not planted: spreadsheets…", "…layout and downloads leave it out" |
| Phenotypes could be stored for it, or for its plants | Refused in verify; never stored by store() (BrAPI v1, drone imagery, derived traits) | Docs | AC "not planted: phenotype files" |
| Spreadsheets made before the mark would be refused | Only rows with a value count | Docs | AC "not planted: phenotype files" |
| Values it already has | Deleted only when the user confirms, also NIRS data; never values shared with other plots | Docs, Dialog | AC "…deleted only when asked", "…stored together…", "…high-dimensional data goes", TCA "…deleted after confirmation" |
| Treatments and notes are design, not growth | Kept and allowed; a trial with treatments only has no "traits assayed" | Docs | AC "…treatments stay…" |
| CRD replicate numbering | The plot keeps its place (no renumbering of its neighbours) | Docs | AC "not planted: …", TCA "the not_planted column" |
| Maps | Field map: empty with a dashed border, legend, plot dialog; field map spreadsheet: "(not planted)" | Docs | AC "not planted: spreadsheets…" |
| New plants, subplots, tissue samples | Not created in it | Docs | AC "not planted: spreadsheets…" |
| BrAPI | `additionalInfo.notPlanted` (read only) | Docs | TCA "the not_planted column" |

### Seedlots

| Problem | What was done | Explained | Test |
|---|---|---|---|
| The upload refused every plot planted from a seedlot, even for curators | Seed transactions follow the packets: a plot takes over the transaction of the plot whose packet it got (nearest by plot number); seedlots are no reason to ask a curator | Docs, Dialog | AC "seedlots: the seed transactions follow the packets", TCA "a trial planted from seedlots" |
| A packet planted into a border, in no plot | Stays taken from its seedlot (inventory unchanged); returned seed is added on the seedlot page | Docs, Dialog | AC "seedlots: … follow the packets" |
| The right accession from the wrong seedlot | Optional `seedlot_name`; both seedlots recounted | Docs, Dialog | AC "seedlots: another seedlot of the same accession" |
| Family-name plots are planted from seedlots of their crosses | Counted as holding the family | Docs | AC "seedlots: plots of family names…" |
| The same file uploaded again: its seedlot cells are those of before the packets moved | A seedlot_name that does not hold the plot's accession is not used | Docs | AC, TCA "…the same file again" |
| Seedlots harvested from a corrected plot | Warning | Docs | AC "not planted: plants, seedlots and plates" |

### After a change

| Problem | What was done | Explained | Test |
|---|---|---|---|
| Phenotype search, datasets | Materialized views refreshed | Docs ("run the analyses again") | — (checked end to end on a trial with phenotypes; the refresh runs in the background) |
| solGS results of the trial | Cache cleared | PR | — |
| Layout cache | Regenerated in the transaction | PR | AC "cached layout" assertions |

## Statistics

Simulated with the models Breedbase uses (heritability tool
`lmer(y ~ (1|germplasmName) + replicate)`; Mixed Models with replicate random), RCBD
of 20 accessions x 4 blocks, a skipped place shifting the rest, a place left empty, a
plot lost; 500 simulations:

| data | accuracy (cor with true values) | H2 |
|---|---|---|
| as it grew | 0.893 | 0.393 |
| corrected with the file (shift + not planted) | 0.893, identical in all 500 | 0.393 |
| not corrected | 0.000 (63% of fits singular) | 0.000 |
| corrected, replicates renumbered as in #6384 | 0.889 | 0.391 |
| corrected, empty places recorded as 0 | 0.648 | 0.086 |

Not corrected, a shift of 14 plots already lowers the accuracy from 0.90 to 0.83.
Shifts within columns of a 10 x 8 RCBD (serpentine after a border column, 300
simulations): corrected 0.873 = truth; not corrected 0.791; corrected along the wrong
direction 0.700, worse than not correcting, which is why the planting order file
(with its borders) is the one to edit.

## Review

Two review passes by independent critics (data integrity, analyses, files/labels/Field
Book, APIs/permissions/UI, field scenarios; then a code review and a scenario re-check
of the fixes). Every finding was verified against the code; the tables above include
what they found. The last bug (the same file uploaded again in a trial planted from
seedlots) was found by running the round trip in the browser.

## Not changed, and why

- Rejecting a planted plot as a whole (damaged, trampled) is not part of this PR; the
  existing Suppress (one value) and Quality Control (outliers) remain the tools.
- BrAPI v2 `POST /observations` answers every refused request with a generic 500
  (predates this PR).
- BrAPI `PUT /observationunits` does not refresh the materialized views (predates).
- The trial phenotype summary counts not planted plots as missing values.
- The planned accession of a not planted plot still counts as "in the trial" (the
  plan stays visible on purpose).
- Mixed seed in one plot, extra plots outside the design, borders measured later.
- A packet that became "seed taken" is not linked back if a later correction puts
  it in a plot again; that is done on the seedlot page.

## Tests

- `AC`: 43 scenarios, 391 assertions. `TCA`: 17 subtests through the web server, 173
  assertions. `JS`: 65 assertions (the whole JS suite passes).
- Regression after merging current master: trial, Field Book, data collector, field
  map spreadsheet, phenotype uploads (plots, plants, repeated measurements,
  high-dimensional), seedlots (29 files, 1941 tests); TrialMetadata, BrAPI v2,
  Fieldbook through the web server (261); t/unit (1495). Four assertions of `t/unit_fixture/CXGN/Trial.t` (1-2, 71-72)
  fail on the base as well (order dependent).

## Deploy

Run the db patch `AddNotPlantedStockprop` (db/00209) and build the JS.
