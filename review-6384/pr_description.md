Description
-----------

Builds on #6384 (and #6353). Changing the accession of plots was done in four
copies of the same code, each a bit different, and some of it was wrong for
most designs. This moves it into one module, `CXGN::Trial::AccessionChange`,
and uses that everywhere: Replace Accession, one plot (field map, heatmap,
trial coordinates), the Change Accessions upload, Substitute, genotyping
plate wells and BrAPI `PUT /observationunits`.

**What a change does.** A plot is a place in the field; changing its accession
corrects what grows there and does not move it.

- The plot, and its plants, subplots and tissue samples in the trial, get the
  new stock. Samples of the plot in other trials (plate wells) keep the old
  one, with a warning.
- Plot number, block, row and column stay the same. The replicate stays the
  same in blocked designs (RCBD, Alpha, Lattice, split plot, RRC, URDD), where
  the design stores it as the block. Only in a CRD, where it counts the plots
  of an accession, are the replicates of the accessions involved numbered
  again (as #6384 does for every design). Plots without a replicate keep none.
- Plot names: the template name when the trial has a plot name template;
  otherwise the old stock name is replaced where it is a whole part of the
  name, as in #6353 (a name with it more than once is left as it is and
  reported). Plants, subplots and tissue samples are renamed with their plot.
  Renames run in two passes, so names can move between plots, and new names
  are checked against every stock. Replace Accession can keep all names
  (`rename_plots=0`).
- The new stock must exist, not be obsolete, and be of the trial's stock type
  (trial property, or the types the plots have).
- Entry numbers move from the old stock to the new one when it replaces it
  completely.
- Everything happens in one transaction, and the cached layout is
  regenerated. The plots are read from the database, not from the cache.

**Fixed**, each with a test:

| | before |
|---|---|
| RCBD with 3 blocks, Replace Accession into an accession already in the trial | replicates 4, 5 and 6; untouched plots got new replicates |
| plots without replicate (`rep_number` is optional on upload) | `Can't call method "update" on an undefined value` |
| template `trialName_accessionName_repNumber` | the same request failed or worked depending on hash order |
| accession name inside the trial name (`trial2` in `test_trial23`) | renamed to `test_test_accession33` |
| stale layout cache (trials where Replace Accession was used before #6384) | changes computed from old data |
| one plot, new name already taken | error shown, but the accession was already changed (no transaction) |
| Substitute | swapped every relationship of the two plots by position, plants included |
| `replace_well_accessions`, BrAPI germplasm change | broken since `replace_plot_accession_fieldMap` got a fourth argument (1423e6b4) |
| upload | no check of the user's privileges on the trial; any stock type accepted; only the stockprop matview refreshed |

**Replace Accession dialog**: it now shows what will change (plots, renames,
replicates, notes) and changes nothing until the user confirms. "Update plot
names" can be unchecked. The success message lists what changed.

**Endpoints** keep their parameters and `success` / `error` / `warning`
responses; `success` responses now also carry a summary (`changed`,
`renamed`, `not_renamed`, `replicates_changed`, `entry_numbers`,
`warnings`). `replace_stock` takes `rename_plots` and `preview`. The FieldMap
methods that changed accessions call the new module and keep the plot names,
as they did.

**Tests**

- `t/unit_fixture/CXGN/Trial/AccessionChange.t` (new): CRD and RCBD trials,
  plants, subplots and tissue samples, templates, explicit names and name
  swaps, conflicts, stale cache, missing replicates, entry numbers, crosses
  and family names, intercropping, concurrent changes, genotyping plates.
  Every scenario runs in a transaction that is rolled back.
- `t/unit_mech/AJAX/BreedersToolbox/TrialChangeAccessions.t` (new): every
  endpoint through the web server, including privileges and BrAPI.
- `t/unit_mech/AJAX/BreedersToolbox/TrialMetadata.t`: a name with the
  accession name twice is kept and reported again (as in #6353).
- Run locally in `breedbase/breedbase:latest` with the patched fixture:
  the two new files, `TrialMetadata.t`, `EditFieldMap.t`,
  `_BrAPIv2_phenotyping.t`, and all of `t/unit_fixture/CXGN/Trial/`
  (17 files, 1217 tests) pass. The dialog was checked in Chromium.

Closes #4642. Supersedes #6384 and #6353 (or can be merged into #6384).

Checklist
---------
- [ ] Refactoring only
- [ ] Documentation only
- [ ] Fixture update only
- [x] Bug fix
  - [ ] The relevant issue has been closed.
  - [ ] Further work is required.
- [x] New feature
  - [x] Relevant tests have been created and run.
  - [ ] Data was added to the fixture
    - [ ] Data was added via a patch in `/t/data/fixture/patches/`.
  - [x] User-Facing Change
    - [x] The user manual in `/docs` has been updated.
  - [x] Any new Perl has been documented using **perldoc**.
  - [ ] Any new JavaScript has been documented using **JSDoc**.
  - [ ] Any new _legacy_ JavaScript has been moved from `/js` to `/js/source/legacy`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_01HkB7TKJzpN9q6SpSnX84js
