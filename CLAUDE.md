# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This is the code behind **Breedbase / SGN (Sol Genomics Network)** — the web platform powering breeding databases such as Cassavabase, Musabase, Sweetpotatobase, Yambase, and the SGN website (solgenomics.net). It is a large **Perl / Catalyst** web application backed by a **Chado (PostgreSQL)** schema, with an HTML::Mason view layer and a Webpack-bundled JavaScript frontend.

The system is normally run via Docker (see the [breedbase_site](https://github.com/solgenomics/breedbase_site) repo and the `breedbase/breedbase` DockerHub image), not built from source. You generally do not build this repo directly; you run it inside the breedbase Docker container, which already has all CPAN dependencies installed.

## Architecture

The request flow is: **HTTP → Catalyst controller → CXGN backend object → DBIx::Class (Chado schema) → PostgreSQL**, with HTML rendered by Mason templates and interactivity driven by JavaScript that calls AJAX/BrAPI endpoints.

### Two top-level Perl namespaces (the key distinction)

- **`lib/SGN/`** — the Catalyst web layer. `lib/SGN.pm` is the Catalyst application class; it composes a set of `SGN::Role::Site::*` roles (Config, DBConnector, DBIC, Exceptions, Files, Mason, SiteFeatures, TestMode) rather than configuring much inline. Controllers live in `lib/SGN/Controller/`:
  - `lib/SGN/Controller/*.pm` — page controllers (render Mason views).
  - `lib/SGN/Controller/AJAX/*.pm` — `Catalyst::Controller::REST` endpoints returning JSON (~100 modules). This is the primary backend API the frontend talks to.
- **`lib/CXGN/`** — the business-logic / backend layer. These are mostly Moose objects (e.g. `CXGN::Trial`, `CXGN::Genotype`, `CXGN::Pedigree`, `CXGN::BreederSearch`, `CXGN::List`). **Controllers should be thin and delegate domain logic to CXGN modules.** When adding functionality, put the real logic in a `CXGN::*` module and call it from the controller.

Also present: `lib/Bio/` (BioPerl-style sequence/secretary tools), `lib/solGS/` (statistical genomics / GWAS), `lib/PDF/`.

### Configuration

- `sgn.conf` — main production-style config (Catalyst `ConfigLoader` format). The `name` is `SGN`, default view is `Mason`, static root is `static/`.
- `sgn_test.conf` — config used by the test harness. The single docker-vs-local difference is `dbhost`: set `dbhost localhost` to run tests outside the Docker container.
- `sgn_fixture_template.conf` — template for fixture-based test config.
- Database connection points at a **Chado** schema (`Bio::Chado::Schema` / DBIx::Class); see `lib/CXGN/DB/Schemas.pm`.

### View / frontend layers

- **Mason** (`mason/`) — server-side HTML templates. `mason/autohandler` and `mason/dhandler` wrap pages. Controllers select a Mason component as the view.
- **CGI-bin** (`cgi-bin/`) — legacy Perl CGI pages, dispatched through `Catalyst::Controller::CGIBin`. Prefer adding new pages as Catalyst controllers + Mason rather than new CGI scripts.
- **JavaScript** (`js/`) — Webpack + Node/NPM. **Read `js/README.md` before touching JS — there are three distinct categories with different rules:**
  - **On-page JS** (inside `<script>` in Mason): NOT transpiled/minified. Must be plain ES2015 — no arrow functions, no ES6 classes.
  - **Legacy JS** (`js/source/legacy/`): the old `JSAN.use("")` global-scope system. Runs in global scope, not transpiled. **Avoid adding to it.** Included in Mason via `<& /util/import_javascript, legacy => [ "CXGN.Effects", ... ] &>`.
  - **Modern JS** (`js/source/entries/` and `js/source/modules/`): transpiled/bundled by Webpack. `entries` are exposed on the global `jsMod['<name>']` object and included via `<& /import_javascript, entries => ["example.js"] &>`; `modules` are shared imports bundled into entries, not exposed on `jsMod`.

### Database patches (`db/`)

Schema/data migrations are versioned **Perl modules**, one numbered directory per patch (~200 patches, `db/00001/` … `db/00205/`). Each patch is a Moose module subclassing the db-patch base; see `db/template/SampleDbpatchMoose.pm` for the pattern and `db/README`. Apply patches with:

```bash
db/run_all_patches.pl -u <dbuser> -p <dbpass> -h <dbhost> -d <dbname> -e <editinguser> [-s <startfrom>] [--test]
```

`--test` runs without making permanent changes. `-s` starts from a given patch number.

### Maintenance scripts (`bin/`)

`bin/` holds standalone loader/admin scripts (loading phenotypes, genotypes/VCF, accessions, images, deleting/renaming stocks, etc.). `bin/sgn_server.pl` starts the Catalyst dev server.

## Running the dev server

```bash
./bin/sgn_server.pl -r --fork     # -r = restart on file change, --fork = one process per request
```

Defaults to port 3000 (`-p` to change). `run_cassava_production_server.sh` is the production init-style launcher (sets `PERL5LIB` and starts the server in `screen`).

## Testing

Tests run through `t/test_fixture.pl`, which spins up a test Catalyst server and loads/uses the **fixture database**, against `sgn_test.conf`. Read `t/README.md` for the full breakdown. Run from the `sgn/` directory:

```bash
# Run an entire test directory
perl t/test_fixture.pl --logfile logfile.testserver.txt t/unit_mech/ 2>test.results.txt

# Run a single test file
perl t/test_fixture.pl --logfile logfile.testserver.txt t/unit_mech/AJAX/BrAPI_v2.t 2>test.results.txt
```

- `--logfile` is where **server logs** go; `2>...` captures the **test results**. To find failures, look in the logfile for errors with line numbers.
- Inside the Docker container, CI invokes tests via `/entrypoint.sh --nopatch <dir>` (the entrypoint starts slurm; `--nopatch` skips re-running fixture/db patches). Pure unit tests can run with plain `prove --recurse t/unit`.

### Test directory layout (`t/`)

- `t/unit/` — no database required (`Bio::*`, `CXGN::*` pure logic, POD checks).
- `t/unit_fixture/` — run against the fixture DB. Subdivided into `CXGN/` and `SGN/` (backend Moose objects), `Controller/` (page controllers via URL requests), `AJAX/` (REST controllers via URL requests), `Static/` (static-file accessibility).
- `t/unit_mech/` — mechanized HTTP request tests.
- `t/selenium2/` — Selenium browser integration tests (slow; used for client-side JS).
- `t/live/` — tests against live websites.
- `t/lib/` — test support libraries (e.g. `SGN::Test::Data`); `t/data/` — fixture SQL (`t/data/fixture/cxgn_fixture.sql`) and test assets.

The CI test pipeline (`.github/workflows/test.yml`) runs, in order: `t/unit`, loads/dumps the fixture DB, then `t/unit_fixture`, `t/unit_mech`, and each `t/selenium2/*` suite — inside the `breedbase/breedbase:latest` container with postgres, selenium, and keycloak services.

## Building JavaScript

From `js/` (requires Node/NPM; `./install_node.sh` installs them as root):

```bash
npm run build         # production build via build.webpack.config.js
npm run build-watch   # rebuild on change
npm run build-test    # test build via test.webpack.config.js
```

## Linting / CI

- PRs to `master` run **super-linter** (`.github/workflows/linter.yml`). Several validators are intentionally disabled (CSS, JS-ES, JS-Prettier, SQLFluff, JSCPD, etc.); HTML is checked via htmlhint (`.github/linters/.htmlhintrc`). The `docs/` tree and `t/unit_mech/AJAX/_BrAPIv2_germplasm.t` are excluded.
- Docs in `docs/` deploy to GitHub Pages on push to `master`; the R-markdown manual in `docs/r_markdown_docs/` is built by `test_static.yml`.

## Conventions

- Keep controllers thin; put domain logic in `CXGN::*` modules (most are Moose).
- New backend logic should be unit-testable against the fixture DB under `t/unit_fixture/`.
- New JSON endpoints belong under `lib/SGN/Controller/AJAX/` as REST controllers; the BrAPI implementation lives in `lib/CXGN/BrAPI/` (versioned `v1`/`v2`) with controllers in `lib/SGN/Controller/AJAX/BrAPI*.pm`.
- Schema changes must be added as a new numbered `db/` patch, not applied ad hoc.
- For JS, choose the right tier (on-page vs legacy vs modern) and respect its transpilation constraints described above.
