# CI/CD Pipelines — GitHub Actions Workflows

> Automated build · test · deploy for frontend (GitHub Pages) and database (Supabase migrations)
> Part of the [Society Management System](../../README.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Workflow Inventory](#2-workflow-inventory)
3. [Workflow: deploy-pages.yml](#3-workflow-deploy-pagesyml)
4. [Workflow: deploy-db.yml](#4-workflow-deploy-dbyml)
5. [Concurrency & Safety Design](#5-concurrency--safety-design)
6. [Permissions Model](#6-permissions-model)
7. [Secrets Reference](#7-secrets-reference)
8. [GitHub Environment: github-pages](#8-github-environment-github-pages)
9. [Trigger Matrix](#9-trigger-matrix)
10. [How the Two Pipelines Interlock](#10-how-the-two-pipelines-interlock)
11. [Troubleshooting](#11-troubleshooting)
12. [Adding a New Workflow](#12-adding-a-new-workflow)

---

## 1. Overview

This directory contains the two GitHub Actions workflow files that form the complete CI/CD system for the Society Management System. Every merge to `main` is automatically deployed — frontend changes go to GitHub Pages, and schema changes go to Supabase. No manual deployment steps are required under normal operation.

```
.github/workflows/
├── deploy-pages.yml   ← Frontend: build (3 locales) → test → deploy to GitHub Pages
└── deploy-db.yml      ← Database: validate → link → migrate Supabase PostgreSQL
```

### Design Principles

| Principle | Implementation |
|---|---|
| **Path-filtered triggers** | Each pipeline only fires when its own files change — no wasted runs |
| **Secrets never in source** | `environment.ts` generated at build time from GitHub Secrets |
| **Safe migration concurrency** | DB pipeline never cancels in-progress runs to prevent partial schema states |
| **Fast frontend deploys** | Pages pipeline uses `cancel-in-progress: true` — only the latest push matters |
| **Audit trail** | Migration status logged before and after every deployment |
| **Quality gate** | Unit tests must pass before any artifact is deployed |

---

## 2. Workflow Inventory

| File | Name | Trigger | Runner | Environment |
|---|---|---|---|---|
| `deploy-pages.yml` | Deploy to Github pages | Push to `main` (path-filtered) | `ubuntu-latest` | `github-pages` |
| `deploy-db.yml` | Deploy database changes to supabase | Push to `main` (path-filtered) + manual | `ubuntu-latest` | `github-pages` |

---

## 3. Workflow: `deploy-pages.yml`

### Purpose

Builds the Angular application for all three locales (English, Bengali, Hindi), runs the unit test suite, and deploys the resulting static bundle to GitHub Pages.

### Full Workflow File

```yaml
name: Deploy to Github pages

on:
  push:
    branches:
      - main
    paths:
      - "society-management-ui/**"
      - ".github/workflows/deploy-pages.yml"

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: github-pages
  cancel-in-progress: true

jobs:
  deploy:
    name: Build and Deploy ng application
    runs-on: ubuntu-latest
    environment:
      name: github-pages
    steps:
      - name: Checkout Source code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22.x
          cache: npm
          cache-dependency-path: society-management-ui/package-lock.json

      - name: Install npm dependencies
        working-directory: ./society-management-ui
        run: npm ci

      - name: Generate environment.ts
        working-directory: ./society-management-ui
        run: |
          mkdir -p src/environments
          cat > src/environments/environment.ts << EOF
          export const environment = {
            production: true,
            supabaseUrl: '${{ secrets.SUPABASE_URL }}',
            supabaseAnonKey: '${{ secrets.SUPABASE_ANON_KEY }}'
          };
          EOF

      - name: Verify environment file exists
        working-directory: ./society-management-ui
        run: |
          ls -la src/environments

      - name: Build ng application
        working-directory: ./society-management-ui
        run: npm run build:prod

      - name: Execute Unit tests
        working-directory: ./society-management-ui
        run: npm run test --watch=false --browsers=ChromeHeadless

      - name: Configure Language landing page
        working-directory: ./society-management-ui
        run: |
          cp dist/society-management-ui/browser/en-US/html/index.redirect.html \
          dist/society-management-ui/browser/index.html

      - name: Setup Github pages
        uses: actions/configure-pages@v5

      - name: Upload Build Artifacts
        uses: actions/upload-pages-artifact@v3
        with:
          path: society-management-ui/dist/society-management-ui/browser

      - name: Deploy to Github pages
        uses: actions/deploy-pages@v4
```

### Step-by-Step Breakdown

#### Trigger

```yaml
on:
  push:
    branches: [main]
    paths:
      - "society-management-ui/**"
      - ".github/workflows/deploy-pages.yml"
```

Only fires when a push to `main` touches files inside `society-management-ui/` or the workflow file itself. Changes to `supabase/` or documentation files do not trigger a frontend rebuild.

---

#### Permissions

```yaml
permissions:
  contents: read    # Read repository files
  pages: write      # Write to GitHub Pages deployment
  id-token: write   # Required for OIDC — GitHub Pages deployment authentication
```

`id-token: write` is required by the `actions/deploy-pages@v4` action to authenticate the deployment via OpenID Connect (OIDC) without needing a personal access token.

---

#### Concurrency

```yaml
concurrency:
  group: github-pages
  cancel-in-progress: true
```

If two pushes arrive in quick succession, the first deployment is cancelled and only the latest runs. This is safe for frontend deploys — the latest commit is always the desired state.

---

#### Step 1 — Checkout Source Code

```yaml
- uses: actions/checkout@v4
```

Checks out the full repository at the commit that triggered the push. Uses `actions/checkout@v4` — the latest major version with improved performance.

---

#### Step 2 — Setup Node.js

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 22.x
    cache: npm
    cache-dependency-path: society-management-ui/package-lock.json
```

- Installs Node.js **22.x** (LTS) to match the minimum requirement
- Enables **npm dependency caching** keyed on `package-lock.json` — subsequent runs with unchanged dependencies skip the download step, cutting 1–2 minutes off build time
- `cache-dependency-path` points to the nested `society-management-ui/` directory since the project is a monorepo

---

#### Step 3 — Install Dependencies

```yaml
- working-directory: ./society-management-ui
  run: npm ci
```

`npm ci` (clean install) is used instead of `npm install`:
- Installs **exactly** what is in `package-lock.json` — reproducible, deterministic builds
- Fails if `package-lock.json` is out of sync with `package.json` — catches drift early
- Deletes `node_modules` before installing — no stale dependency artifacts

---

#### Step 4 — Generate environment.ts

```yaml
- name: Generate environment.ts
  run: |
    mkdir -p src/environments
    cat > src/environments/environment.ts << EOF
    export const environment = {
      production: true,
      supabaseUrl: '${{ secrets.SUPABASE_URL }}',
      supabaseAnonKey: '${{ secrets.SUPABASE_ANON_KEY }}'
    };
    EOF
```

This is the **secret injection step** — the most security-critical step in the pipeline.

- `environment.ts` is **gitignored** — it never exists in the repository
- The file is generated fresh on every CI run from GitHub Secrets
- `production: true` enables Angular's production optimizations
- The secrets are expanded by GitHub Actions at runtime — they are never visible in logs
- `mkdir -p src/environments` ensures the directory exists even on a fresh checkout

> ⚠️ The `SUPABASE_ANON_KEY` is a public-facing key designed for browser use — it is safe to embed in the frontend bundle. It only grants operations permitted by Row Level Security policies.

---

#### Step 5 — Verify Environment File

```yaml
- name: Verify environment file exists
  run: ls -la src/environments
```

A lightweight sanity check that the previous step created the file. Fails fast if the generation step silently produced nothing, preventing a build from proceeding with a missing environment configuration.

---

#### Step 6 — Build Angular Application

```yaml
- run: npm run build:prod
```

Executes `ng build -c production`, which triggers Angular's **multi-locale production build**:

- Compiles **three separate static bundles**: `en-US/`, `bn/`, `hi/`
- Enables full optimization: tree-shaking, minification, dead code elimination
- Applies **output hashing** to all assets for cache-busting
- Sets `baseHref` to `/society-management-app/` for GitHub Pages subdirectory hosting
- Enforces **bundle size budgets** — build fails if any bundle exceeds limits (1 MB initial)

**Output structure:**
```
dist/society-management-ui/browser/
├── en-US/   ← English locale build
├── bn/      ← Bengali locale build
└── hi/      ← Hindi locale build
```

---

#### Step 7 — Execute Unit Tests

```yaml
- run: npm run test --watch=false --browsers=ChromeHeadless
```

Runs the Vitest unit test suite in **CI mode**:

- `--watch=false` — single run, exits after completion (watch mode would hang the pipeline)
- `--browsers=ChromeHeadless` — runs in a headless Chromium instance for DOM-dependent tests
- The pipeline **fails here if any test fails** — no artifact is uploaded and no deployment occurs
- This acts as a **quality gate**: broken code cannot reach production

---

#### Step 8 — Configure Language Landing Page

```yaml
- run: |
    cp dist/society-management-ui/browser/en-US/html/index.redirect.html \
    dist/society-management-ui/browser/index.html
```

Copies the language-detection redirect page to the **root** `index.html` of the deployment. This is necessary because:

- GitHub Pages serves `index.html` at the root URL `/society-management-app/`
- The Angular build puts locale-specific `index.html` files inside `/en-US/`, `/bn/`, `/hi/`
- The root `index.html` must exist and redirect visitors to their preferred language
- `index.redirect.html` contains JavaScript that reads `navigator.language` and redirects accordingly

---

#### Step 9 — Setup GitHub Pages

```yaml
- uses: actions/configure-pages@v5
```

Configures the GitHub Pages deployment environment. This action:
- Reads the repository's Pages configuration
- Sets up the correct base URL for the deployment
- Required before the upload artifact step

---

#### Step 10 — Upload Build Artifacts

```yaml
- uses: actions/upload-pages-artifact@v3
  with:
    path: society-management-ui/dist/society-management-ui/browser
```

Packages the entire `browser/` output directory (all three locale bundles + root redirect) as a GitHub Pages artifact. This artifact is what gets deployed in the next step.

---

#### Step 11 — Deploy to GitHub Pages

```yaml
- uses: actions/deploy-pages@v4
```

Deploys the uploaded artifact to GitHub Pages. Uses OIDC token authentication (hence `id-token: write` in permissions). The deployment is atomic — the old version continues serving until the new deployment is fully staged.

**Result:** Live at `https://akashneelghoshdev.github.io/society-management-app/`

---

### Pipeline Execution Time

| Phase | Typical Duration |
|---|---|
| Checkout + Node setup | ~30s (cached) |
| npm ci | ~60s (cached) / ~3min (uncached) |
| Build (3 locales) | ~2–4 min |
| Unit tests | ~30–60s |
| Deploy | ~30s |
| **Total** | **~4–8 min** |

---

## 4. Workflow: `deploy-db.yml`

### Purpose

Validates and applies pending Supabase database migrations to the production PostgreSQL instance. Can be triggered automatically on schema file changes or manually via the GitHub Actions UI.

### Full Workflow File

```yaml
name: Deploy database changes to supabase

on:
  push:
    branches:
      - main
    paths:
      - "supabase/**"
      - ".github/workflows/deploy-db.yml"
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: supabase-migrations
  cancel-in-progress: false

jobs:
  deploy:
    name: Deploy database migrations to supabase
    runs-on: ubuntu-latest
    environment:
      name: github-pages
    steps:
      - name: Checkout Source code
        uses: actions/checkout@v4

      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
        with:
          version: latest

      - name: Verify Supabase CLI installation
        run: supabase --version

      - name: Validate Migration Directory
        run: |
          test -d supabase/migrations
          ls -lah supabase/migrations

      - name: Link Supabase project
        run: |
          supabase link \
            --project-ref ${{ secrets.SUPABASE_PROJECT_ID }} \
            -p ${{ secrets.SUPABASE_DB_PASSWORD }}
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

      - name: Migration Status Before Deployment
        run: supabase migration list
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

      - name: Deploy Migrations to Supabase
        run: supabase db push --yes
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

      - name: Migration Status After Deployment
        run: supabase migration list
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

### Step-by-Step Breakdown

#### Trigger

```yaml
on:
  push:
    branches: [main]
    paths:
      - "supabase/**"
      - ".github/workflows/deploy-db.yml"
  workflow_dispatch:
```

Two trigger modes:

1. **Automatic** — fires on push to `main` when any file under `supabase/` changes (new migration, config update, or workflow file change)
2. **Manual** (`workflow_dispatch`) — can be triggered from GitHub Actions UI with no code change required. Useful for:
   - Re-running a previously failed migration
   - Force-applying migrations after resolving a conflict
   - Verifying migration state on demand

---

#### Permissions

```yaml
permissions:
  contents: read
```

Minimal permissions — only needs to read the repository to access migration files. No write access to Pages or tokens needed.

---

#### Concurrency

```yaml
concurrency:
  group: supabase-migrations
  cancel-in-progress: false
```

**Critical difference from the frontend pipeline.** `cancel-in-progress: false` means:

- If a migration is running and a new push arrives, the **new run waits** in a queue
- The running migration is **never interrupted mid-execution**
- Prevents partial schema states (e.g. a table created but its RLS policy not yet applied)
- Once the in-progress run completes (success or failure), the queued run proceeds

---

#### Step 1 — Checkout Source Code

```yaml
- uses: actions/checkout@v4
```

Same as the frontend pipeline. Checks out the repository at the triggering commit.

---

#### Step 2 — Setup Supabase CLI

```yaml
- uses: supabase/setup-cli@v1
  with:
    version: latest
```

Installs the official Supabase CLI using the `supabase/setup-cli` GitHub Action maintained by Supabase. `version: latest` always pulls the most recent stable release — ensures access to the latest CLI features and bug fixes.

---

#### Step 3 — Verify Supabase CLI Installation

```yaml
- run: supabase --version
```

Confirms the CLI installed correctly and logs the version for the audit trail. Fails fast if the setup step silently failed.

---

#### Step 4 — Validate Migration Directory

```yaml
- run: |
    test -d supabase/migrations
    ls -lah supabase/migrations
```

Two checks in one step:

1. `test -d supabase/migrations` — fails the pipeline if the migrations directory doesn't exist (e.g. accidentally deleted or misnamed)
2. `ls -lah supabase/migrations` — lists all migration files with sizes and timestamps in the run log, providing a human-readable audit record of exactly what files are present

---

#### Step 5 — Link Supabase Project

```yaml
- run: |
    supabase link \
      --project-ref ${{ secrets.SUPABASE_PROJECT_ID }} \
      -p ${{ secrets.SUPABASE_DB_PASSWORD }}
  env:
    SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

Links the local CLI session to the remote Supabase cloud project. This step:

- Authenticates the CLI to the Supabase platform using `SUPABASE_ACCESS_TOKEN`
- Identifies the target project using `SUPABASE_PROJECT_ID` (the project reference ID from the Supabase dashboard)
- Establishes a direct database connection using `SUPABASE_DB_PASSWORD`
- All three credentials are sourced from GitHub Secrets — never hardcoded

The `SUPABASE_ACCESS_TOKEN` is passed as an environment variable rather than a CLI flag to avoid it appearing in process listings.

---

#### Step 6 — Migration Status Before Deployment

```yaml
- run: supabase migration list
  env:
    SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

Lists all migrations and their applied status **before** the deployment runs. Output is logged to the GitHub Actions run for audit purposes. This provides:

- A pre-deployment snapshot of the database state
- Visibility into which migrations are pending vs. already applied
- A reference point if the deployment fails and rollback analysis is needed

---

#### Step 7 — Deploy Migrations

```yaml
- run: supabase db push --yes
  env:
    SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

Applies all pending migrations to the remote Supabase PostgreSQL database.

- `supabase db push` compares the local migration files against the `supabase_migrations` tracking table in the remote database and applies any that have not yet run
- `--yes` suppresses the interactive confirmation prompt (required for non-interactive CI execution)
- Migrations are applied in **chronological order** based on the timestamp in the filename
- If any migration fails, the pipeline stops and subsequent migrations are not applied

---

#### Step 8 — Migration Status After Deployment

```yaml
- run: supabase migration list
  env:
    SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

Re-runs `supabase migration list` **after** the deployment. By comparing the before and after output in the run log, operators can confirm exactly which migrations were applied in this run. This forms the **post-deployment verification** step.

---

### Pipeline Execution Time

| Phase | Typical Duration |
|---|---|
| Checkout + CLI setup | ~30–60s |
| Link + pre-status | ~15s |
| Migration deployment | Depends on migration size (typically 5–30s) |
| Post-status | ~10s |
| **Total** | **~1–2 min** |

---

## 5. Concurrency & Safety Design

The two pipelines have **opposite** concurrency strategies, each chosen deliberately:

| Pipeline | `cancel-in-progress` | Why |
|---|---|---|
| `deploy-pages.yml` | `true` | Frontend is stateless — only the latest build matters; cancelling an old deploy saves time |
| `deploy-db.yml` | `false` | Database migrations are stateful — an interrupted migration leaves the schema in a broken partial state |

### What Happens on Rapid Successive Pushes

**Frontend (pages):**
```
Push A → Deploy starts
Push B arrives → Push A cancelled → Push B runs
Result: Only the latest code is deployed ✅
```

**Database (migrations):**
```
Push A → Migration starts
Push B arrives → Push B queues
Push A completes → Push B runs
Result: Both migrations applied sequentially, in order ✅
```

---

## 6. Permissions Model

GitHub Actions permissions follow the **principle of least privilege** — each workflow only requests the permissions it actually needs.

| Permission | `deploy-pages.yml` | `deploy-db.yml` | Purpose |
|---|---|---|---|
| `contents: read` | ✅ | ✅ | Read repository files |
| `pages: write` | ✅ | ❌ | Write GitHub Pages deployments |
| `id-token: write` | ✅ | ❌ | OIDC token for GitHub Pages auth |

The database pipeline requests only `contents: read` — it has no reason to write to Pages or obtain OIDC tokens. Any compromise of the DB pipeline runner cannot affect the Pages deployment.

---

## 7. Secrets Reference

Both pipelines access secrets stored as **GitHub Actions repository secrets** under the `github-pages` environment.

| Secret | Used By | What It Is | Where to Get It |
|---|---|---|---|
| `SUPABASE_URL` | `deploy-pages.yml` | Supabase project REST API endpoint | Supabase Dashboard → Project Settings → API |
| `SUPABASE_ANON_KEY` | `deploy-pages.yml` | Public anonymous JWT key | Supabase Dashboard → Project Settings → API |
| `SUPABASE_ACCESS_TOKEN` | `deploy-db.yml` | Personal access token for Supabase CLI | Supabase Dashboard → Account → Access Tokens |
| `SUPABASE_PROJECT_ID` | `deploy-db.yml` | Project reference ID (short alphanumeric string) | Supabase Dashboard → Project Settings → General |
| `SUPABASE_DB_PASSWORD` | `deploy-db.yml` | PostgreSQL database password | Set during project creation / reset in Dashboard |

### Adding Secrets to GitHub

1. Go to your repository on GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **Environments** → select `github-pages`
4. Click **Add environment secret**
5. Add each secret with its name and value exactly as listed above

> ⚠️ Secret names are **case-sensitive** — `SUPABASE_URL` and `supabase_url` are different secrets.

### Secret Hygiene Rules

- Never log secrets — GitHub Actions automatically masks known secret values in logs, but avoid `echo $SECRET` patterns
- Never commit secrets — `environment.ts` is gitignored; `environment.template.ts` (empty values only) is what is committed
- If a secret is compromised — revoke it immediately in Supabase dashboard, regenerate, update the GitHub secret, and trigger a fresh deployment
- The `SUPABASE_ANON_KEY` is a **public key** by design — safe to embed in the browser bundle (RLS enforces access control, not key secrecy)
- The `SUPABASE_ACCESS_TOKEN` and `SUPABASE_DB_PASSWORD` are **sensitive** — treat like passwords

---

## 8. GitHub Environment: `github-pages`

Both workflows target the `github-pages` GitHub Environment. This is the environment used by GitHub Pages deployments and is also leveraged by the DB pipeline to gain access to environment-scoped secrets.

### Why the DB Pipeline Uses `github-pages` Environment

GitHub Actions can scope secrets to specific environments. Since the project uses a single environment (`github-pages`), all secrets are stored there. The DB pipeline declares `environment: name: github-pages` to gain access to those secrets even though it doesn't deploy to Pages.

This is noted explicitly in the workflow file:
```yaml
environment:
  name: github-pages  # This is required to access secrets in the environment
```

### Environment Protection Rules (Recommended)

For production hardening, configure the `github-pages` environment with:
- **Required reviewers** — require manual approval for production deployments
- **Deployment branches** — restrict to `main` branch only (already enforced by the `on.push.branches` filter, but defence in depth)
- **Wait timer** — optional delay before deployment proceeds

---

## 9. Trigger Matrix

Summary of what triggers each pipeline:

| Event | `deploy-pages.yml` | `deploy-db.yml` |
|---|---|---|
| Push to `main` — `society-management-ui/**` changed | ✅ Triggers | ❌ No |
| Push to `main` — `supabase/**` changed | ❌ No | ✅ Triggers |
| Push to `main` — `.github/workflows/deploy-pages.yml` changed | ✅ Triggers | ❌ No |
| Push to `main` — `.github/workflows/deploy-db.yml` changed | ❌ No | ✅ Triggers |
| Push to `main` — only `README.md` changed | ❌ No | ❌ No |
| Push to any branch other than `main` | ❌ No | ❌ No |
| Manual `workflow_dispatch` | ❌ No | ✅ Triggers |

This design ensures that:
- Documentation-only changes (`README.md`) never trigger a build or migration
- Feature branches never deploy to production
- The DB pipeline can always be run manually for operational needs

---

## 10. How the Two Pipelines Interlock

The frontend and database pipelines are **independent** — they can run simultaneously. However, they share a common dependency: both rely on the same Supabase project.

### Deployment Order for a Full Release

When a release involves both code changes and schema changes, the recommended merge order is:

```
1. Merge schema changes (supabase/**) to main
   → deploy-db.yml runs → new tables/columns exist in DB

2. Merge frontend changes (society-management-ui/**) to main
   → deploy-pages.yml runs → Angular code that uses the new schema is deployed

Result: DB schema always leads frontend code — no "column not found" errors
```

### Rolling Back

| What Failed | Rollback Action |
|---|---|
| Frontend deploy failed | Fix the code, push again — pipeline re-runs automatically |
| Migration failed mid-run | Create a new migration that reverses the failed change; push to main |
| Bad migration deployed | Create a corrective migration (never edit an applied migration file) |
| Need emergency rollback of frontend | Manually trigger a deployment of a previous commit via `workflow_dispatch` (add this trigger to `deploy-pages.yml` if needed) |

---

## 11. Troubleshooting

### Frontend Pipeline Failures

| Symptom | Likely Cause | Fix |
|---|---|---|
| `environment.ts` not found during build | Secret injection step failed silently | Check that `SUPABASE_URL` and `SUPABASE_ANON_KEY` secrets exist in the `github-pages` environment |
| Bundle size budget exceeded | New dependency added that is too large | Run `npm run build:prod` locally and check the bundle analysis output |
| Unit tests failing | Broken test or broken component | Run `npm run test` locally to reproduce and fix |
| `id-token` permission error on deploy | `id-token: write` permission missing or GitHub Pages not enabled | Ensure Pages is enabled in repository settings and the permission is present |
| Wrong base href | Pages deployed but assets 404 | Confirm `baseHref` is `/society-management-app/` in the `production` build config |

### Database Pipeline Failures

| Symptom | Likely Cause | Fix |
|---|---|---|
| `supabase link` fails with auth error | `SUPABASE_ACCESS_TOKEN` is missing or expired | Regenerate token in Supabase Dashboard → Account → Access Tokens, update GitHub secret |
| `supabase link` fails with project not found | `SUPABASE_PROJECT_ID` is wrong | Verify project ref in Supabase Dashboard → Project Settings → General |
| `supabase db push` fails with SQL error | Migration file has a syntax error or conflicts | Fix the migration file, create a corrective migration if already partially applied |
| Migration directory not found | `supabase/migrations/` doesn't exist or was deleted | Restore the directory; ensure at least one migration file exists |
| Pipeline queued indefinitely | Previous run is still in progress | Wait for it to complete, or cancel it from the GitHub Actions UI if safe to do so |

---

## 12. Adding a New Workflow

To add a new GitHub Actions workflow to this project:

1. Create a new `.yml` file in `.github/workflows/`
2. Follow the naming convention: `<action>-<target>.yml` (e.g. `test-e2e.yml`, `notify-slack.yml`)
3. Always specify:
   - `permissions` — use minimum required permissions only
   - `concurrency` — decide whether in-progress runs should cancel or queue
   - `on.push.paths` — filter to only the files relevant to this workflow
4. Store any new secrets in the `github-pages` environment (or create a new environment for distinct concerns)
5. Document the new workflow in this README and add it to the [CI/CD section](../../README.md#9-cicd-pipelines) of the root README

---

> Part of the [Society Management System](../../README.md)
> [Angular Frontend →](../../society-management-ui/README.md) · [Supabase Backend →](../../supabase/README.md)
>
> **Designed and developed by Akashneel Ghosh**
> 📧 [akashneel.ghosh.enterprises@gmail.com](mailto:akashneel.ghosh.enterprises@gmail.com) · [GitHub](https://github.com/akashneelGhoshDev) · [LinkedIn](https://www.linkedin.com/in/akashneel-ghosh-124976109/)
