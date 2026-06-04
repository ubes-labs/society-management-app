# Society Management System

> **Enterprise-grade, multi-tenant SaaS platform for residential society management**
> Built on Angular 21 · Supabase (PostgreSQL 17) · GitHub Pages · GitHub Actions CI/CD
> Supports **English · বাংলা (Bengali) · हिन्दी (Hindi)**

[![Live App](https://img.shields.io/badge/Live%20App-GitHub%20Pages-blue?style=flat-square)](https://akashneelghoshdev.github.io/society-management-app/)
[![GitHub Repo](https://img.shields.io/badge/Source-GitHub-black?style=flat-square)](https://github.com/akashneelGhoshDev/society-management-app)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Live:** [https://akashneelghoshdev.github.io/society-management-app/](https://akashneelghoshdev.github.io/society-management-app/)

---

## Table of Contents

1. [Product Vision](#1-product-vision)
2. [Business Use Case](#2-business-use-case)
3. [SaaS Multi-Tenant Architecture](#3-saas-multi-tenant-architecture)
4. [System Architecture Overview](#4-system-architecture-overview)
5. [Technology Stack](#5-technology-stack)
6. [Repository Structure](#6-repository-structure)
7. [Sub-Module Documentation](#7-sub-module-documentation)
8. [Deployment Architecture](#8-deployment-architecture)
9. [CI/CD Pipelines](#9-cicd-pipelines)
10. [Security Model](#10-security-model)
11. [Internationalization](#11-internationalization)
12. [Roadmap](#12-roadmap)
13. [Contributing](#13-contributing)
14. [License & Contact](#14-license--contact)

---

## 1. Product Vision

The **Society Management System** is a cloud-native, multi-tenant SaaS web application designed to digitize and streamline the administration of residential housing societies. It serves as a single pane of glass for society administrators, residents, and management committees — eliminating paper-based workflows, fragmented communication, and manual financial tracking.

The platform is architected from the ground up to support **multiple societies as independent tenants** on a shared infrastructure, with full data isolation between tenants enforced via PostgreSQL Row Level Security (RLS). Each society (tenant) operates within its own scoped data environment on a shared Supabase backend.

The application is fully **internationalized** and available in three UI languages — **English**, **Bengali (বাংলা)**, and **Hindi (हिन्दी)** — targeting the primary demographics of residential societies across India and the Bengali-speaking diaspora.

### Core Value Propositions

| Stakeholder | Value Delivered |
|---|---|
| **Residents** | Self-service access to notices, payment history, maintenance requests |
| **Society Admins** | Centralized management of residents, dues, and communications |
| **Management Committee** | Real-time dashboards, financial reports, compliance tracking |
| **Platform Owner** | Scalable SaaS revenue model with per-society subscription |

---

## 2. Business Use Case

### 2.1 Problem Statement

Residential housing societies across South Asia manage hundreds to thousands of residents across multiple blocks. The current state of management is typically:

- **Manual maintenance fee collection** with no digital audit trail
- **WhatsApp/verbal communication** for notices and announcements
- **Excel-based resident registers** with no access control
- **No self-service portal** for residents to raise complaints or view dues
- **Fragmented tooling** — separate tools for accounting, communication, and visitor management

### 2.2 Target Market

| Segment | Description |
|---|---|
| **Primary** | Mid-to-large residential societies (50–2000 units) in India |
| **Secondary** | Gated communities, apartment complexes, cooperative housing societies |
| **Tertiary** | Society management companies overseeing multiple properties |

### 2.3 Core Business Workflows

#### Resident Lifecycle
```
Registration → Unit Assignment → Onboarding → Active Resident → Exit
```

#### Financial Workflow
```
Maintenance Schedule Creation → Invoice Generation → Resident Notification →
Payment Collection (Online/Offline) → Receipt Issuance → Ledger Update → Reports
```

#### Communication Workflow
```
Admin Creates Notice → Localised Delivery (EN/BN/HI) → Resident Acknowledgement → Archive
```

#### Maintenance Request Workflow
```
Resident Raises Ticket → Category Assignment → Staff Dispatch →
Resolution Update → Closure → Resident Feedback
```

### 2.4 Current Implementation Status

| Module | Status | Notes |
|---|---|---|
| Authentication (Google OAuth) | ✅ Live | PKCE flow, session management |
| Navigation & Layout | ✅ Live | Responsive, Material Design 3 |
| Multi-language UI (EN / BN / HI) | ✅ Live | Separate locale builds per language |
| Dashboard Shell | 🔄 In Progress | Placeholder for data widgets |
| Resident Management | 🔲 Planned | Roadmap Q3 2026 |
| Maintenance Fee Collection | 🔲 Planned | Roadmap Q3 2026 |
| Notice Board | 🔲 Planned | Roadmap Q4 2026 |
| Complaint Management | 🔲 Planned | Roadmap Q4 2026 |
| Visitor Management | 🔲 Planned | Roadmap 2027 |
| Multi-tenant Onboarding Portal | 🔲 Planned | Roadmap 2027 |

---

## 3. SaaS Multi-Tenant Architecture

The platform is designed as a **shared infrastructure, row-level isolated** multi-tenant system. Each society is an independent **tenant** identified by a unique `society_id` (UUID). Supabase Row Level Security (RLS) policies ensure strict data isolation — no tenant can access another tenant's data, by design at the database layer.

### 3.1 Tenancy Model

```
Platform (Single Deployment — akashneelghoshdev.github.io/society-management-app)
│
├── Tenant: Sunshine Residency, Mumbai         [society_id: <uuid>]
│   ├── Block A  (12 floors · 144 units)
│   ├── Block B  (10 floors · 120 units)
│   └── Common Areas
│
├── Tenant: Green Valley Apartments, Pune      [society_id: <uuid>]
│   └── Tower 1  (20 floors · 200 units)
│
└── Tenant: Lakeside Enclave, Kolkata          [society_id: <uuid>]
    ├── Row Houses  (50 units)
    └── High-Rise   (15 floors · 150 units)
```

### 3.2 Data Isolation Strategy

- Every tenant-scoped table carries a `society_id` (UUID) foreign key column
- Supabase **Row Level Security (RLS)** policies enforce that authenticated users can only read/write rows where `society_id` matches their own profile
- A **platform super-admin role** (service-level) can bypass RLS for support and operations — this role is never exposed to the frontend
- Authentication is centralized; authorization is always tenant-scoped at the database layer

### 3.3 Tenant Onboarding Flow (Planned)

```
Society Admin Sign-Up → Society Profile Creation → society_id Generated →
RLS Seed Data Applied → First Admin User Linked → Member Invite Sent → Go Live
```

---

## 4. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CLIENT LAYER                                      │
│                                                                             │
│   Angular 21 SPA · Static Build · Hosted on GitHub Pages CDN               │
│                                                                             │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌──────────────┐  │
│   │  /en-US/    │   │    /bn/     │   │    /hi/     │   │ Hash Router  │  │
│   │  English    │   │  Bengali    │   │   Hindi     │   │ (SPA compat) │  │
│   └─────────────┘   └─────────────┘   └─────────────┘   └──────────────┘  │
│                                                                             │
│   ┌───────────────────────────┐   ┌───────────────────────────────────┐    │
│   │  Angular Signals          │   │  Angular Material 3 UI            │    │
│   │  (Reactive State Mgmt)    │   │  (Component Library + SCSS Theme) │    │
│   └───────────────────────────┘   └───────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                │  HTTPS · JWT Bearer Token
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       BACKEND LAYER  (Supabase BaaS)                         │
│                                                                             │
│  ┌──────────────────┐  ┌─────────────────┐  ┌──────────────────────────┐   │
│  │  Supabase Auth   │  │  PostgREST API  │  │  Realtime (WebSocket)    │   │
│  │  Google OAuth    │  │  (Auto-gen REST │  │  (Planned — live feeds)  │   │
│  │  PKCE Flow       │  │   from schema)  │  │                          │   │
│  └──────────────────┘  └─────────────────┘  └──────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                  PostgreSQL 17 Database                              │    │
│  │   ┌─────────────────────────────────────────────────────────────┐   │    │
│  │   │   Row Level Security (RLS) — Per-society data isolation      │   │    │
│  │   └─────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌───────────────────┐  ┌──────────────────┐  ┌───────────────────────┐    │
│  │  Storage (S3)     │  │  Edge Functions  │  │  DB Migrations        │    │
│  │  (Files, Docs)    │  │  (Deno v2)       │  │  (Supabase CLI)       │    │
│  └───────────────────┘  └──────────────────┘  └───────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       CI/CD LAYER  (GitHub Actions)                          │
│                                                                             │
│  ┌──────────────────────────────┐   ┌────────────────────────────────────┐  │
│  │  deploy-pages.yml            │   │  deploy-db.yml                     │  │
│  │  Push → Build (3 locales) →  │   │  Push / Manual →                   │  │
│  │  Test → Deploy GitHub Pages  │   │  supabase db push (migrations)     │  │
│  └──────────────────────────────┘   └────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Technology Stack

### 5.1 Frontend

| Technology | Version | Purpose |
|---|---|---|
| Angular | 21.2.0 | SPA framework — standalone components, no NgModules |
| Angular Material | 21.2.13 | Material Design 3 UI component library |
| Angular CDK | 21.2.13 | Breakpoint observer, layout utilities |
| Angular Signals | Built-in | Reactive state management (replaces NgRx for current scope) |
| Angular i18n | Built-in | Multi-language compile-time localization |
| RxJS | 7.8.0 | Reactive programming, observable streams |
| TypeScript | 5.9.2 | Strict-mode static typing |
| SCSS | — | Component and global styling, Material theming |

### 5.2 Backend / BaaS

| Technology | Purpose |
|---|---|
| Supabase | Backend-as-a-Service — Auth, Database, Storage, Realtime |
| PostgreSQL 17 | Primary relational database with RLS |
| Supabase Auth | Google OAuth 2.0 + PKCE, JWT session management |
| PostgREST | Auto-generated REST API from PostgreSQL schema |
| Supabase Storage | S3-compatible file storage (50 MiB limit per file) |
| Supabase Edge Functions | Deno v2 serverless functions for custom business logic |
| Supabase Realtime | WebSocket-based live data subscriptions (planned) |
| `@supabase/supabase-js` v2.106.2 | TypeScript client SDK |

### 5.3 Build & Tooling

| Technology | Version | Purpose |
|---|---|---|
| Angular CLI | 21.2.13 | Scaffolding, build, serve, i18n extraction |
| `@angular/build` | 21.2.13 | Vite-based application builder (replaces Webpack) |
| Vitest | 4.0.8 | Unit test runner |
| jsdom | 28.0.0 | DOM emulation for headless unit tests |
| Prettier | 3.8.1 | Enforced code formatting |
| npm | 11.13.0 | Package management |

### 5.4 Infrastructure & Deployment

| Technology | Purpose |
|---|---|
| GitHub Pages | Frontend CDN hosting (static multi-locale build) |
| GitHub Actions | CI/CD — frontend build/test/deploy + database migrations |
| Supabase Cloud | Managed PostgreSQL + Auth + Storage + Edge Functions |
| Supabase CLI | Database migration management via `supabase db push` |

---

## 6. Repository Structure

```
society-management-app/                    ← Monorepo root
│
├── .github/
│   └── workflows/
│       ├── deploy-pages.yml               ← Frontend CI/CD pipeline
│       └── deploy-db.yml                  ← Database migration pipeline
│
├── society-management-ui/                 ← Angular 21 frontend application
│   ├── src/
│   │   ├── app/
│   │   │   ├── core/                      ← Layout, services, guards, constants, utils
│   │   │   └── features/                  ← Feature components (login, dashboard, …)
│   │   ├── environments/                  ← Environment config (secrets injected at build)
│   │   ├── locales/                       ← XLF2 translation files (en-US, bn, hi)
│   │   └── styles.scss                    ← Global styles + Material 3 theme
│   ├── public/
│   │   ├── images/                        ← Static assets (company logo)
│   │   └── html/
│   │       └── index.redirect.html        ← Browser-language-based locale redirect
│   ├── angular.json                       ← Angular CLI workspace & build configuration
│   ├── package.json                       ← Dependencies and npm scripts
│   └── README.md                          ← Frontend technical documentation ↗
│
├── supabase/
│   ├── config.toml                        ← Supabase project configuration
│   ├── migrations/                        ← Ordered SQL migration files
│   └── README.md                          ← Backend & database documentation ↗
│
└── README.md                              ← This file — product & architecture overview
```

---

## 7. Sub-Module Documentation

Each major layer has its own dedicated README with full technical depth:

| Module | README | What It Covers |
|---|---|---|
| **Angular Frontend** | [society-management-ui/README.md](./society-management-ui/README.md) | Components, services, guards, routing, i18n, state management, testing, build commands, environment setup |
| **Supabase Backend** | [supabase/README.md](./supabase/README.md) | Database schema, auth configuration, migration strategy, RLS policies, local dev setup, secrets management |
| **CI/CD Pipelines** | [.github/workflows/README.md](./.github/workflows/README.md) | Both GitHub Actions workflows line-by-line, secrets reference, concurrency design, trigger matrix, troubleshooting |

---

## 8. Deployment Architecture

### 8.1 Frontend — GitHub Pages

The Angular application is compiled into a **static multi-locale SPA** and served from GitHub Pages. Key design decisions for static hosting compatibility:

| Decision | Reason |
|---|---|
| **Hash-based routing** (`/#/dashboard`) | GitHub Pages has no server-side routing; hash routing works with static files |
| **Locale subdirectories** (`/en-US/`, `/bn/`, `/hi/`) | Each language is a separate static build; Angular i18n requires this at compile time |
| **Language redirect page** | Auto-redirects first-time visitors to their browser's preferred language |

**Production URL structure:**
```
https://akashneelghoshdev.github.io/society-management-app/
│
├── index.html          ← Redirects to preferred language
├── en-US/              ← English build (default fallback)
│   └── index.html
├── bn/                 ← Bengali build
│   └── index.html
└── hi/                 ← Hindi build
    └── index.html
```

### 8.2 Backend — Supabase Cloud

- Supabase project hosted on Supabase's managed cloud infrastructure
- Database migrations are applied automatically via the `deploy-db.yml` pipeline using Supabase CLI
- Authentication is fully managed by Supabase Auth — no custom auth server required
- OAuth redirect URIs are registered in the Supabase project dashboard per environment (localhost + production)

### 8.3 Environment Variable Management

All sensitive configuration is managed as **GitHub Actions Secrets** and injected at build time. Nothing sensitive is ever committed to source control.

| Secret Name | Used By | Purpose |
|---|---|---|
| `SUPABASE_URL` | Frontend build | Supabase project API endpoint |
| `SUPABASE_ANON_KEY` | Frontend build | Public JWT key for client-side SDK |
| `SUPABASE_ACCESS_TOKEN` | DB pipeline only | Supabase CLI authentication |
| `SUPABASE_PROJECT_ID` | DB pipeline only | Target project for `supabase link` |
| `SUPABASE_DB_PASSWORD` | DB pipeline only | Direct DB connection for migrations |

> ⚠️ **Security Note:** The `SUPABASE_ANON_KEY` is a *public* key designed to be used in frontend code — it only permits operations allowed by Row Level Security policies. The service role key (which bypasses RLS) is **never** used in frontend code and is not stored in this repository.

---

## 9. CI/CD Pipelines

> For full line-by-line technical documentation of both workflows, see [.github/workflows/README.md](./.github/workflows/README.md).

### 9.1 Frontend Pipeline (`deploy-pages.yml`)

**Trigger:** Push to `main` when `society-management-ui/**` or the workflow file itself changes.

```
Push to main
     │
     ▼
Checkout (actions/checkout@v4)
     │
     ▼
Setup Node.js 22 + npm cache
     │
     ▼
npm ci  (clean, reproducible install)
     │
     ▼
Inject SUPABASE_URL + SUPABASE_ANON_KEY → environment.ts
     │
     ▼
npm run build:prod
(Compiles 3 locale bundles: en-US · bn · hi)
(Base href: /society-management-app/)
     │
     ▼
Run unit tests (Vitest + ChromeHeadless, no watch)
     │
     ▼
Copy en-US/index.html → dist root index.html
     │
     ▼
Upload artifact (actions/upload-pages-artifact@v3)
     │
     ▼
Deploy to GitHub Pages (actions/deploy-pages@v4)
     │
     ▼
Live at akashneelghoshdev.github.io/society-management-app/
```

### 9.2 Database Pipeline (`deploy-db.yml`)

**Trigger:** Push to `main` when `supabase/**` changes, **or** manual `workflow_dispatch`.

```
Push to main / Manual trigger
     │
     ▼
Checkout (actions/checkout@v4)
     │
     ▼
Setup Supabase CLI (supabase/setup-cli@v1)
     │
     ▼
supabase link --project-ref $SUPABASE_PROJECT_ID
     │
     ▼
Check migration status (pre-deploy audit log)
     │
     ▼
supabase db push --yes  (applies all pending migrations)
     │
     ▼
Check migration status (post-deploy verification)
```

> **Note:** This pipeline uses `concurrency: cancel-in-progress: false` — a running migration is **never** cancelled mid-flight to prevent partial schema states.

---

## 10. Security Model

### 10.1 Authentication

| Aspect | Implementation |
|---|---|
| Provider | Google OAuth 2.0 via Supabase Auth |
| Flow | PKCE (Proof Key for Code Exchange) — prevents auth code interception |
| Session | JWT issued by Supabase, 1-hour expiry with automatic refresh |
| Anonymous sign-ins | Disabled |
| Manual account linking | Disabled |
| Password minimum length | 6 characters (for future email/password auth) |

### 10.2 Route Protection

- Angular `authGuard` (functional guard pattern) protects all authenticated routes
- Guard reads the reactive `user` signal from `AuthService` — no async calls on every navigation
- Unauthenticated users are immediately redirected to `/login`
- The wildcard route (`**`) redirects to `/dashboard`, which is itself guard-protected

### 10.3 Data Access Control

- All frontend requests use the **Supabase anonymous key** — this is safe to embed in frontend code
- The anonymous key only allows operations explicitly permitted by **Row Level Security policies**
- The **service role key** (which bypasses RLS) is never present in frontend code or this repository
- `society_id`-scoped RLS ensures tenant data isolation at the database engine level

### 10.4 Secret Hygiene

| What | Rule |
|---|---|
| `environment.ts` | Generated at build time from GitHub Secrets; never committed with real values |
| `environment.template.ts` | Shape-only file committed to source; all values are empty strings |
| Service role key | Never referenced in frontend code; used only by Supabase CLI in CI/CD |
| `.gitignore` | `environment.ts` is excluded from version control |

---

## 11. Internationalization

The application is fully internationalized and ships three independent locale builds. Language is selected at the URL path level — each locale is a completely self-contained static build.

| Locale Code | Language | Script | Live URL |
|---|---|---|---|
| `en-US` | English | Latin | [/en-US/](https://akashneelghoshdev.github.io/society-management-app/en-US/) |
| `bn` | Bengali (বাংলা) | Bengali | [/bn/](https://akashneelghoshdev.github.io/society-management-app/bn/) |
| `hi` | Hindi (हिन्दी) | Devanagari | [/hi/](https://akashneelghoshdev.github.io/society-management-app/hi/) |

### How Language Switching Works

1. On first visit, `index.redirect.html` reads `navigator.language` and redirects to the matching locale path
2. Inside the app, the **NavPanel language switcher** lets users manually switch language
3. Switching language navigates to the equivalent path in the selected locale build
4. All 13 UI string units are translated: navigation labels, footer, page titles, ARIA labels, and button text

### Covered Translation Units

| String | English | Bengali | Hindi |
|---|---|---|---|
| App Title | Society Management System | সোসাইটি ম্যানেজমেন্ট সিস্টেম | सोसाइटी प्रबंधन प्रणाली |
| Dashboard | Dashboard | ড্যাশবোর্ড | डैशबोर्ड |
| Log In | Log In | লগ ইন | लॉग इन |
| Log Out | Log Out | লগ আউট | लॉग आउट |
| Login with Google | Login with Google | গুগল দিয়ে লগইন করুন | Google से लॉगिन करें |

### Adding a New Language

1. Run `npm run extract-i18n` — regenerates `src/locales/messages.xlf`
2. Copy to `src/locales/messages.<locale>.xlf` and translate all `<target>` elements
3. Add locale to `angular.json` under `i18n.locales` with build configuration
4. Add language entry to `src/app/core/const/lang-const/lang.const.ts`
5. Add option to the NavPanel language switcher

See [Angular Frontend README → Internationalization](./society-management-ui/README.md#internationalization) for full detail.

---

## 12. Roadmap

### Phase 1 — Foundation ✅ (Current — Live)
- [x] Google OAuth 2.0 authentication (PKCE)
- [x] Responsive layout — Material Design 3, sidenav + topbar
- [x] Multi-language UI — English, Bengali, Hindi
- [x] GitHub Pages deployment with locale routing
- [x] Automated CI/CD — frontend build/test/deploy + database migrations
- [x] Hash-based routing for static hosting compatibility

### Phase 2 — Core Society Features (Q3–Q4 2026)
- [ ] Society profile — name, logo, address, block/floor/unit hierarchy
- [ ] Resident registration and unit assignment
- [ ] Maintenance fee schedules and invoice generation
- [ ] Digital notice board with read receipts
- [ ] Complaint and maintenance request ticketing

### Phase 3 — Financial & Reporting (Q1 2027)
- [ ] Online payment integration (Razorpay / Stripe)
- [ ] Financial ledger and full audit trail
- [ ] Monthly / annual financial reports (PDF export)
- [ ] Arrears tracking, overdue reminders

### Phase 4 — Multi-Tenant Self-Service (Q2 2027)
- [ ] Society self-onboarding portal
- [ ] Tenant isolation fully enforced via RLS `society_id`
- [ ] Subscription billing per society (per-unit pricing model)
- [ ] Platform admin super-panel

### Phase 5 — Advanced Features (2027+)
- [ ] Visitor management and gate entry log
- [ ] Staff and vendor management
- [ ] Document vault (agreements, NOCs, certificates)
- [ ] Progressive Web App (PWA) — installable on mobile
- [ ] Supabase Realtime — live notification feeds

---

## 13. Contributing

### Prerequisites

| Tool | Minimum Version | Install |
|---|---|---|
| Node.js | 22.x | [nodejs.org](https://nodejs.org) |
| npm | 11.x | Bundled with Node.js |
| Angular CLI | 21.x | `npm install -g @angular/cli` |
| Supabase CLI | Latest | `npm install -g supabase` |

### Local Development Setup

```bash
# 1. Clone the repository
git clone https://github.com/akashneelGhoshDev/society-management-app.git
cd society-management-app

# 2. Install frontend dependencies
cd society-management-ui
npm ci

# 3. Configure environment (never commit real values)
cp src/environments/environment.template.ts src/environments/environment.ts
# Open environment.ts and fill in your Supabase project URL and anon key

# 4. Start development server — English (default)
npm start
# → http://localhost:4200

# 5. Start with Bengali locale
npm run start-bn

# 6. Start with Hindi locale
npm run start-hi
```

### Branch & Commit Strategy

```
main                          ← Protected production branch
 ├── feature/<feature-name>   ← New features
 ├── fix/<bug-description>    ← Bug fixes
 └── chore/<task-name>        ← Maintenance, deps, docs
```

All merges to `main` automatically trigger the relevant CI/CD pipeline.

### Code Standards

| Standard | Rule |
|---|---|
| TypeScript | Strict mode — no `any`, no implicit overrides |
| Components | Standalone only — no NgModules |
| State | Angular Signals — avoid raw subscriptions in components |
| i18n | All user-facing strings use `i18n` attribute — no hardcoded English |
| Formatting | Prettier enforced — `npx prettier --write .` before committing |
| Indentation | 2 spaces, single quotes, 100-character line width |

---

## 14. License & Contact

This project is licensed under the **MIT License** — free to use, modify, and distribute with attribution.

```
MIT License — Copyright (c) 2026 Akashneel Ghosh
```

**Designed and developed by Akashneel Ghosh**
📧 [akashneel.ghosh.enterprises@gmail.com](mailto:akashneel.ghosh.enterprises@gmail.com)
🌐 [Live App](https://akashneelghoshdev.github.io/society-management-app/) · [GitHub Repo](https://github.com/akashneelGhoshDev/society-management-app) · [GitHub Profile](https://github.com/akashneelGhoshDev) · [LinkedIn](https://www.linkedin.com/in/akashneel-ghosh-124976109/)

---

> *This README serves as the primary product and architecture reference for all stakeholders — developers, end users, society administrators, and potential contributors. For layer-specific technical detail, refer to the sub-module READMEs linked in [Section 7](#7-sub-module-documentation).*
