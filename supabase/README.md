# Supabase Backend — Society Management System

> PostgreSQL 17 · Supabase Auth · Row Level Security · Supabase CLI Migrations
> Part of the [Society Management System](../README.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Supabase Services Used](#2-supabase-services-used)
3. [Project Configuration](#3-project-configuration)
4. [Authentication](#4-authentication)
5. [Database Architecture](#5-database-architecture)
6. [Row Level Security (RLS)](#6-row-level-security-rls)
7. [Database Migrations](#7-database-migrations)
8. [CI/CD — Database Pipeline](#8-cicd--database-pipeline)
9. [Storage](#9-storage)
10. [Edge Functions](#10-edge-functions)
11. [Realtime](#11-realtime)
12. [Local Development Setup](#12-local-development-setup)
13. [Secrets & Credentials Management](#13-secrets--credentials-management)
14. [Planned Schema Design](#14-planned-schema-design)

---

## 1. Overview

The Society Management System uses **Supabase** as its Backend-as-a-Service (BaaS) platform. Supabase provides:

- **Authentication** — Google OAuth 2.0 with PKCE, JWT session management
- **Database** — Managed PostgreSQL 17 with PostgREST auto-generated REST API
- **Row Level Security** — Tenant data isolation enforced at the database engine level
- **Storage** — S3-compatible file storage for society documents, receipts, images
- **Edge Functions** — Deno v2 serverless functions for custom business logic
- **Realtime** — WebSocket-based live subscriptions (planned for notifications)

The Supabase client in the Angular frontend uses only the **anonymous key** — all data access is constrained by RLS policies. No backend server sits between the frontend and Supabase.

### Architecture Position

```
Angular SPA (GitHub Pages)
        │
        │  HTTPS + JWT (anonymous key)
        ▼
┌──────────────────────────────────────────────────────┐
│                  Supabase Cloud                       │
│                                                      │
│  Auth Service ──────────────────────────────────┐    │
│  (Google OAuth, PKCE, JWT)                      │    │
│                                                 ▼    │
│  PostgREST API ────────────────► PostgreSQL 17       │
│  (Auto REST from schema)        (RLS enforced)       │
│                                                      │
│  Storage (S3)                                        │
│  Edge Functions (Deno v2)                            │
│  Realtime (WebSocket) [planned]                      │
└──────────────────────────────────────────────────────┘
        ▲
        │  supabase db push (migrations)
        │
GitHub Actions (deploy-db.yml)
```

---

## 2. Supabase Services Used

| Service | Status | Purpose |
|---|---|---|
| **Auth** | ✅ Live | Google OAuth 2.0 + PKCE, JWT session management |
| **Database (PostgreSQL 17)** | ✅ Live | Primary data store, RLS policies |
| **PostgREST API** | ✅ Live | Auto-generated REST API consumed by Angular SDK |
| **Storage** | ✅ Configured | Document and image storage (to be used in Phase 2+) |
| **Edge Functions** | ✅ Configured | Deno v2 serverless (to be implemented in Phase 2+) |
| **Realtime** | 🔲 Planned | Live notification feeds for residents and admins |

---

## 3. Project Configuration

**File:** `supabase/config.toml`

This file configures both the **local Supabase development environment** (via Supabase CLI) and documents the settings aligned with the cloud project.

### Database

```toml
[db]
major_version = 17

[api]
port = 54321         # Local API port (PostgREST)
max_rows = 1000      # Maximum rows returned per request
```

### Auth

```toml
[auth]
site_url = "http://localhost:4200"
jwt_expiry = 3600            # 1 hour
enable_signup = true
enable_manual_linking = false
minimum_password_length = 6

[auth.external.google]
# Google OAuth credentials configured via environment variables / Supabase dashboard
# Never hardcoded in config.toml
```

### Local Dev Ports

| Service | Local Port |
|---|---|
| PostgREST API | 54321 |
| PostgreSQL Database | 54322 |
| Supabase Studio | 54323 |

### Storage

```toml
[storage]
enabled = true
file_size_limit = "50MiB"
```

### Edge Functions

```toml
[edge_runtime]
enabled = true
# Deno v2 runtime
```

### Realtime

```toml
[realtime]
enabled = true
# WebSocket subscriptions for live data feeds
```

---

## 4. Authentication

### OAuth Provider: Google

The application uses **Google OAuth 2.0** via Supabase Auth. The flow is PKCE (Proof Key for Code Exchange) — a security enhancement that prevents authorization code interception attacks.

### PKCE Flow

```
1. User clicks "Login with Google"
         │
         ▼
2. Angular calls supabase.auth.signInWithOAuth({
     provider: 'google',
     options: { redirectTo: <resolved URI> }
   })
         │
         ▼
3. Supabase generates code_verifier + code_challenge
         │
         ▼
4. Browser redirects to Google consent screen
         │
         ▼
5. Google redirects back to redirectTo URI with auth code
         │
         ▼
6. Supabase exchanges code + code_verifier for JWT
   (PKCE ensures only the original client can exchange)
         │
         ▼
7. Supabase sets session (access_token + refresh_token)
         │
         ▼
8. onAuthStateChange fires in Angular
         │
         ▼
9. authService.user signal updated → guard allows /dashboard
```

### Redirect URI Configuration

| Environment | Redirect URI |
|---|---|
| Local development | `http://localhost:4200` |
| Production (GitHub Pages) | `https://akashneelghoshdev.github.io/society-management-app` |

Both URIs must be registered in the **Supabase project dashboard** under Authentication → URL Configuration → Redirect URLs.

The Angular `url-resolver.util.ts` utility selects the correct URI at runtime based on `window.location.hostname`.

### Session Management

| Property | Value |
|---|---|
| JWT expiry | 3600 seconds (1 hour) |
| Refresh token | Automatic silent refresh |
| Storage | Supabase client manages session in `localStorage` |
| Anonymous sign-ins | Disabled |
| Manual account linking | Disabled |

### User Object Structure

On successful authentication, the `session.user` object contains:

```typescript
{
  id: string,                    // UUID — Supabase auth user ID
  email: string,
  user_metadata: {
    full_name: string,           // From Google profile
    avatar_url: string,          // Google profile picture URL
    email: string,
    email_verified: boolean,
    provider_id: string,
  },
  app_metadata: {
    provider: 'google',
    providers: ['google']
  }
}
```

The `full_name` from `user_metadata` is displayed in the Dashboard welcome header.

---

## 5. Database Architecture

### PostgreSQL Version

PostgreSQL **17** — the latest major version, providing:
- Improved query performance
- Enhanced JSON support
- Better logical replication
- Strengthened security features

### Schema Strategy

The application uses the **`public` schema** for all application tables. All tenant-scoped tables will carry a `society_id` UUID column with an RLS policy ensuring users can only access their own society's data.

### Planned Table Structure (Phase 2+)

```sql
-- Tenant/Society table (root entity)
public.societies
├── id                UUID PRIMARY KEY
├── name              TEXT NOT NULL
├── address           TEXT
├── city              TEXT
├── state             TEXT
├── registration_no   TEXT UNIQUE
├── logo_url          TEXT
├── created_at        TIMESTAMPTZ DEFAULT now()
└── updated_at        TIMESTAMPTZ DEFAULT now()

-- Blocks within a society
public.blocks
├── id                UUID PRIMARY KEY
├── society_id        UUID REFERENCES societies(id) ON DELETE CASCADE
├── name              TEXT NOT NULL    -- e.g. "Block A", "Tower 1"
└── created_at        TIMESTAMPTZ DEFAULT now()

-- Floors within a block
public.floors
├── id                UUID PRIMARY KEY
├── block_id          UUID REFERENCES blocks(id) ON DELETE CASCADE
├── society_id        UUID REFERENCES societies(id)   -- denormalised for RLS
└── floor_number      INTEGER NOT NULL

-- Units (flats/apartments)
public.units
├── id                UUID PRIMARY KEY
├── floor_id          UUID REFERENCES floors(id)
├── society_id        UUID REFERENCES societies(id)
├── unit_number       TEXT NOT NULL    -- e.g. "101", "A-204"
├── unit_type         TEXT             -- 1BHK, 2BHK, 3BHK, Villa, etc.
└── area_sqft         NUMERIC

-- Residents
public.residents
├── id                UUID PRIMARY KEY
├── auth_user_id      UUID REFERENCES auth.users(id)  -- links to Supabase Auth
├── society_id        UUID REFERENCES societies(id)
├── unit_id           UUID REFERENCES units(id)
├── full_name         TEXT NOT NULL
├── email             TEXT NOT NULL
├── phone             TEXT
├── move_in_date      DATE
└── move_out_date     DATE

-- Society admin roles
public.society_admins
├── id                UUID PRIMARY KEY
├── auth_user_id      UUID REFERENCES auth.users(id)
├── society_id        UUID REFERENCES societies(id)
├── role              TEXT  -- 'admin', 'treasurer', 'secretary'
└── created_at        TIMESTAMPTZ DEFAULT now()
```

---

## 6. Row Level Security (RLS)

Row Level Security is the **core tenant isolation mechanism**. Every table that contains society-specific data has RLS enabled, and policies enforce that users can only access rows belonging to their own society.

### RLS Design Pattern

```sql
-- Enable RLS on every tenant-scoped table
ALTER TABLE public.units ENABLE ROW LEVEL SECURITY;

-- SELECT policy: users can only read their society's data
CREATE POLICY "residents_select_own_society"
  ON public.units
  FOR SELECT
  USING (
    society_id = (
      SELECT society_id FROM public.residents
      WHERE auth_user_id = auth.uid()
      LIMIT 1
    )
  );

-- Admins can read all data in their society
CREATE POLICY "admins_select_own_society"
  ON public.units
  FOR ALL
  USING (
    society_id IN (
      SELECT society_id FROM public.society_admins
      WHERE auth_user_id = auth.uid()
    )
  );
```

### RLS Policy Principles

| Principle | Implementation |
|---|---|
| Default deny | All tables have RLS enabled; no access unless a policy explicitly grants it |
| Tenant scope | Every policy filters by `society_id` matched to the authenticated user |
| Auth function | `auth.uid()` returns the current user's UUID from the JWT — never spoofable |
| Service role bypass | The service role key bypasses RLS — **never used in frontend code** |
| Anon key safety | The anonymous key cannot bypass RLS — safe to use in frontend |

---

## 7. Database Migrations

### Migration Strategy

The project uses **Supabase CLI migrations** — ordered, version-controlled SQL files that describe every schema change from the beginning of the project. Migrations are applied sequentially and tracked in a `supabase_migrations` schema table.

### Migration Naming Convention

```
YYYYMMDDHHMMSS_descriptive_name.sql
```

Example: `20260601083711_create_residents_table.sql`

### Migration Files

| File | Date | Description | Status |
|---|---|---|---|
| `20260601083711_test_github_pipeline.sql` | 2026-06-01 | Creates `test_github_pipeline` table — CI/CD pipeline validation | Applied & rolled back |
| `20260601092710_rollback_test_table.sql` | 2026-06-01 | Drops `test_github_pipeline` table | Applied |

### Migration File Anatomy

```sql
-- 20260601083711_test_github_pipeline.sql
-- Purpose: Validate that the GitHub Actions DB pipeline can apply migrations

CREATE TABLE public.test_github_pipeline (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Seed data for pipeline verification
INSERT INTO public.test_github_pipeline (name) VALUES ('pipeline_test_record');
```

### Working with Migrations

```bash
# Create a new migration file
supabase migration new create_residents_table

# Apply all pending migrations to local DB
supabase db push

# Apply all pending migrations to remote/cloud project
supabase db push --linked

# Check migration status
supabase migration list

# Reset local database to clean state
supabase db reset
```

### Migration Best Practices

| Practice | Reason |
|---|---|
| **Never edit an applied migration** | Applied migrations are immutable history — create a new migration to fix |
| **One concern per migration** | Easier to review, roll back, and understand in git history |
| **Include rollback comments** | Document how to reverse each change for operational safety |
| **Test locally first** | Run `supabase db push` locally before merging to `main` |
| **RLS with schema changes** | Always add RLS policies in the same migration as the table creation |

---

## 8. CI/CD — Database Pipeline

**Workflow file:** `.github/workflows/deploy-db.yml`

### Trigger Conditions

| Trigger | Condition |
|---|---|
| Push to `main` | Changes in `supabase/**` or the workflow file itself |
| Manual dispatch | `workflow_dispatch` — can be triggered from GitHub Actions UI |

### Pipeline Steps

```
Trigger (push or manual)
        │
        ▼
actions/checkout@v4
        │
        ▼
supabase/setup-cli@v1
(Installs Supabase CLI — latest version)
        │
        ▼
Verify CLI installation
(supabase --version)
        │
        ▼
Validate migration directory
(Check supabase/migrations/ exists and is not empty)
        │
        ▼
supabase link --project-ref $SUPABASE_PROJECT_ID
(Authenticates and links to cloud project)
        │
        ▼
Check migration status — PRE-DEPLOY AUDIT
(supabase migration list — logged for audit trail)
        │
        ▼
supabase db push --yes
(Applies all pending migrations — non-interactive)
        │
        ▼
Check migration status — POST-DEPLOY VERIFICATION
(Confirms applied migrations match expected state)
```

### Concurrency Configuration

```yaml
concurrency:
  group: deploy-db
  cancel-in-progress: false   # ← CRITICAL: never cancel a running migration
```

A migration that is interrupted mid-execution can leave the database in a partial state. `cancel-in-progress: false` ensures that if a new push arrives while a migration is running, the new pipeline **waits** rather than killing the in-progress deployment.

### Required GitHub Secrets

| Secret | Used In Step | Purpose |
|---|---|---|
| `SUPABASE_ACCESS_TOKEN` | `supabase link` | Authenticates Supabase CLI to your account |
| `SUPABASE_PROJECT_ID` | `supabase link` | Identifies the target cloud project |
| `SUPABASE_DB_PASSWORD` | `supabase db push` | Direct database connection for migration execution |

> ⚠️ These secrets are CI/CD infrastructure credentials. They are **never** referenced in frontend code and should only exist as GitHub Actions repository secrets.

### Adding These Secrets to GitHub

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add each secret listed above with the values from your Supabase project dashboard

---

## 9. Storage

Supabase Storage provides S3-compatible object storage. The service is **enabled and configured** but not yet actively used in the current phase.

### Configuration

```toml
[storage]
enabled = true
file_size_limit = "50MiB"    # Maximum size per uploaded file
```

### Planned Usage (Phase 2+)

| Bucket | Contents | Access |
|---|---|---|
| `society-documents` | HOA agreements, bylaws, NOCs | Authenticated residents of the society |
| `receipts` | Payment receipt PDFs | Uploader + society admins |
| `notices` | Notice attachments, images | All authenticated residents of the society |
| `profile-images` | Resident profile pictures | Public (signed URLs with expiry) |

### Storage Security Model

- All buckets will be **private by default** — no public access
- Access controlled via **Storage RLS policies** aligned with `society_id`
- File uploads from the frontend use the anonymous key — storage policies enforce ownership
- Signed URLs with short expiry used for temporary public access where needed

---

## 10. Edge Functions

Supabase Edge Functions are serverless Deno v2 functions deployed to Supabase's global edge network. The service is **configured** but no functions have been implemented yet.

### Configuration

```toml
[edge_runtime]
enabled = true
```

### Planned Edge Functions (Phase 2+)

| Function | Trigger | Purpose |
|---|---|---|
| `send-notice` | HTTP POST | Send notice to all society residents with push notification |
| `generate-invoice` | Scheduled / HTTP | Generate monthly maintenance invoices for all units |
| `payment-webhook` | HTTP POST (Razorpay webhook) | Reconcile payment gateway callbacks and update ledger |
| `onboard-society` | HTTP POST | Tenant onboarding — creates society record, seeds RLS, invites admin |

### Edge Function Structure (Template)

```
supabase/functions/
└── send-notice/
    └── index.ts    ← Deno TypeScript handler
```

```typescript
// Template structure for an edge function
import { serve } from 'https://deno.land/std/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // Service role — only in Edge Functions
  )
  // Business logic here
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

> **Note:** Edge Functions are the only context where the **service role key** is used — they run server-side and are not accessible from the browser.

---

## 11. Realtime

Supabase Realtime provides WebSocket-based live data subscriptions on top of PostgreSQL's logical replication.

### Configuration

```toml
[realtime]
enabled = true
```

### Planned Usage (Phase 2+)

| Use Case | Table | Event |
|---|---|---|
| Live notice feed | `notices` | `INSERT` |
| Maintenance request status updates | `maintenance_requests` | `UPDATE` |
| Payment confirmation | `payments` | `INSERT` |
| Admin dashboard live counters | `residents`, `units` | `INSERT`, `UPDATE` |

### Realtime Security

Realtime subscriptions respect RLS policies — a user can only subscribe to changes on rows they are authorized to read. The `society_id` filter on RLS ensures cross-tenant data leakage is impossible even via WebSocket.

---

## 12. Local Development Setup

### Prerequisites

| Tool | Version | Install |
|---|---|---|
| Supabase CLI | Latest | `npm install -g supabase` |
| Docker Desktop | Latest | Required for local Supabase stack |
| Node.js | 22.x | For running the Angular frontend |

### Start Local Supabase Stack

```bash
# From the repository root
cd supabase

# Start all Supabase services locally (requires Docker)
supabase start

# Output includes local credentials:
# API URL:      http://127.0.0.1:54321
# DB URL:       postgresql://postgres:postgres@127.0.0.1:54322/postgres
# Studio URL:   http://127.0.0.1:54323
# Anon Key:     eyJ...  (safe for local use)
# Service Role: eyJ...  (keep private — never commit)
```

### Apply Migrations Locally

```bash
# Apply all pending migrations to the local database
supabase db push

# Or reset to clean state and re-apply all migrations from scratch
supabase db reset
```

### Access Local Supabase Studio

Navigate to [http://localhost:54323](http://localhost:54323) to access the local Supabase Studio — a full-featured database GUI for running queries, inspecting tables, and managing auth users during development.

### Link to Cloud Project (for remote operations)

```bash
supabase link --project-ref <YOUR_PROJECT_ID>
# Prompted for DB password

# After linking, push migrations to cloud
supabase db push --linked
```

### Stop Local Stack

```bash
supabase stop
# Preserves local database state

supabase stop --no-backup
# Stops and discards local database (clean slate on next start)
```

---

## 13. Secrets & Credentials Management

### Credential Types

| Credential | Who Uses It | Where Stored | Safe to Commit? |
|---|---|---|---|
| `SUPABASE_URL` | Angular frontend, CI/CD | GitHub Actions Secret | URL is not a secret (project endpoint), but keep consistent with pattern |
| `SUPABASE_ANON_KEY` | Angular frontend | GitHub Actions Secret → `environment.ts` at build | No — injected at build time only |
| `SUPABASE_ACCESS_TOKEN` | Supabase CLI (CI/CD) | GitHub Actions Secret | No |
| `SUPABASE_PROJECT_ID` | Supabase CLI (CI/CD) | GitHub Actions Secret | No |
| `SUPABASE_DB_PASSWORD` | Supabase CLI (CI/CD) | GitHub Actions Secret | No |
| Service Role Key | Edge Functions only | Supabase dashboard / Edge Function env | Never in frontend, never committed |
| Google OAuth Client ID & Secret | Supabase Auth config | Supabase project dashboard | No — configured in Supabase dashboard only |

### Rules

1. **Never commit any key, password, or token** to source control — not even in comments
2. `environment.template.ts` is the only environment file committed — it contains empty strings only
3. All secrets live exclusively in **GitHub Actions repository secrets**
4. The service role key never appears in frontend code — it bypasses RLS and grants full database access
5. Google OAuth credentials are configured in the **Supabase project dashboard** — never in `config.toml`

### Rotating Credentials

If a key is accidentally exposed:

1. Immediately revoke/regenerate it in the Supabase dashboard or Google Cloud Console
2. Update the GitHub Actions secret with the new value
3. Trigger a new deployment to ensure the latest value is embedded in the build
4. Review git history to confirm no other secrets were exposed in the same commit

---

## 14. Planned Schema Design

The following is the target relational schema for the full multi-tenant platform (Phases 2–4). It is documented here to inform architectural decisions in current development.

### Entity Relationship Overview

```
societies (1)
   ├──< blocks (many)
   │      └──< floors (many)
   │              └──< units (many)
   ├──< society_admins (many)
   ├──< residents (many) >── units
   ├──< notices (many)
   ├──< maintenance_requests (many)
   ├──< maintenance_fee_schedules (many)
   │      └──< invoices (many) >── residents
   │              └──< payments (many)
   └──< visitor_logs (many) >── units
```

### Multi-Tenant Isolation

Every table in this schema carries `society_id` and has an RLS policy that filters by the authenticated user's `society_id`. The database enforces this — it is not application-level logic.

### Conventions

| Convention | Standard |
|---|---|
| Primary keys | `UUID DEFAULT gen_random_uuid()` |
| Timestamps | `TIMESTAMPTZ DEFAULT now()` on `created_at` and `updated_at` |
| Foreign keys | `ON DELETE CASCADE` for child records within a society |
| Soft deletes | `deleted_at TIMESTAMPTZ` where data must be auditable |
| Indexes | On all `society_id` columns and high-frequency filter columns |
| Naming | `snake_case` for all identifiers |

---

> Part of the [Society Management System](../README.md) · [Angular Frontend →](../society-management-ui/README.md)
> **Designed and developed by Akashneel Ghosh**
> 📧 [akashneel.ghosh.enterprises@gmail.com](mailto:akashneel.ghosh.enterprises@gmail.com) · [GitHub](https://github.com/akashneelGhoshDev) · [LinkedIn](https://www.linkedin.com/in/akashneel-ghosh-124976109/)
