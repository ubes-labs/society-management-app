# Society Management UI — Angular Frontend

> Angular 21 · Standalone Components · Signals · Material Design 3 · i18n (EN / BN / HI)
> Part of the [Society Management System](../README.md)

[![Live App](https://img.shields.io/badge/Live%20App-GitHub%20Pages-blue?style=flat-square)](https://akashneelghoshdev.github.io/society-management-app/)
[![Angular](https://img.shields.io/badge/Angular-21.2.0-red?style=flat-square)](https://angular.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.9.2-blue?style=flat-square)](https://www.typescriptlang.org)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Project Architecture](#2-project-architecture)
3. [Directory Structure](#3-directory-structure)
4. [Component Architecture](#4-component-architecture)
5. [Services](#5-services)
6. [Guards](#6-guards)
7. [Routing](#7-routing)
8. [State Management](#8-state-management)
9. [Internationalization](#9-internationalization)
10. [Styling & Theming](#10-styling--theming)
11. [Environment Configuration](#11-environment-configuration)
12. [Build System](#12-build-system)
13. [Testing](#13-testing)
14. [Development Workflow](#14-development-workflow)
15. [Code Standards](#15-code-standards)
16. [Dependencies Reference](#16-dependencies-reference)

---

## 1. Overview

`society-management-ui` is the Angular 21 single-page application (SPA) frontend for the Society Management System. It is a **standalone-component, signal-based** Angular application with no NgModules, built against a Supabase backend.

**Key architectural characteristics:**
- All components use Angular's **standalone API** — no `NgModule` declarations
- Reactive state is managed exclusively through **Angular Signals** and `toSignal()` interop
- UI is built on **Angular Material 3** with a custom SCSS theme
- The app compiles into **three separate static locale builds** (en-US, bn, hi) for GitHub Pages deployment
- Routing uses **hash-based strategy** (`/#/route`) for compatibility with static file hosting

---

## 2. Project Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                        Angular Application                          │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  app.ts  (Root Component)                                   │   │
│  │  └── <app-layout>  (Core Layout Shell)                      │   │
│  │       ├── <app-top-nav-bar>  (Header + Menu Toggle)         │   │
│  │       ├── <mat-sidenav>                                      │   │
│  │       │    └── <app-nav-panel>  (Sidebar Navigation)        │   │
│  │       ├── <router-outlet>  (Feature Component Slot)         │   │
│  │       └── <app-footer>                                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                    │
│  Features (Lazy-loaded via Router)                                 │
│  ├── LoginComponent        /login                                  │
│  └── DashboardComponent    /dashboard  [authGuard protected]       │
│                                                                    │
│  Core Services                                                     │
│  ├── AuthService           (Supabase auth, user signal)           │
│  └── BreakpointObserver    (CDK responsive breakpoint signal)     │
│                                                                    │
│  Guards                                                            │
│  └── authGuard             (Functional guard — signal-based)      │
└────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

| Decision | Rationale |
|---|---|
| Standalone components | Angular 21 best practice; eliminates NgModule boilerplate |
| Angular Signals for state | Lightweight, synchronous, no subscription management overhead |
| Hash-based routing | Required for GitHub Pages (no server-side routing support) |
| Compile-time i18n | Each locale is a fully optimized static build — no runtime translation overhead |
| Lazy-loaded feature routes | Reduces initial bundle size; features load on demand |
| Vitest (not Karma/Jasmine) | Modern, fast test runner with native ESM support |

---

## 3. Directory Structure

```
society-management-ui/
│
├── src/
│   ├── app/
│   │   │
│   │   ├── app.ts                          ← Root component (renders <app-layout>)
│   │   ├── app.html                        ← Root template
│   │   ├── app.scss                        ← Root styles
│   │   ├── app.config.ts                   ← App-level providers (router, init, error)
│   │   ├── app.routes.ts                   ← Top-level route definitions
│   │   ├── app.spec.ts                     ← Root component unit test
│   │   │
│   │   ├── core/                           ← Shared infrastructure
│   │   │   ├── index.ts                    ← Barrel export for core
│   │   │   │
│   │   │   ├── components/
│   │   │   │   ├── layout/
│   │   │   │   │   ├── layout.ts           ← Main layout shell (sidenav, toolbar, outlet)
│   │   │   │   │   ├── layout.html
│   │   │   │   │   └── layout.scss
│   │   │   │   ├── top-nav-bar/
│   │   │   │   │   ├── top-nav-bar.ts      ← Header with menu toggle button + logo
│   │   │   │   │   ├── top-nav-bar.html
│   │   │   │   │   └── top-nav-bar.scss
│   │   │   │   ├── nav-panel/
│   │   │   │   │   ├── nav-panel.ts        ← Sidebar: profile, language switcher, nav links
│   │   │   │   │   ├── nav-panel.html
│   │   │   │   │   └── nav-panel.scss
│   │   │   │   └── footer/
│   │   │   │       ├── footer.ts           ← Footer with credits and contact
│   │   │   │       ├── footer.html
│   │   │   │       └── footer.scss
│   │   │   │
│   │   │   ├── services/
│   │   │   │   ├── auth/
│   │   │   │   │   └── auth.service.ts     ← Supabase auth, Google OAuth, user signal
│   │   │   │   └── breakpoint-observer/
│   │   │   │       └── breakpoint-observer.ts  ← CDK breakpoint → isHandset signal
│   │   │   │
│   │   │   ├── guards/
│   │   │   │   └── auth-guard/
│   │   │   │       └── auth-guard.ts       ← Functional CanActivateFn
│   │   │   │
│   │   │   ├── const/
│   │   │   │   ├── app-const/
│   │   │   │   │   └── app.const.ts        ← App-wide i18n string constants
│   │   │   │   ├── nav-const/
│   │   │   │   │   └── nav.const.ts        ← Navigation menu item definitions
│   │   │   │   └── lang-const/
│   │   │   │       └── lang.const.ts       ← Supported language definitions
│   │   │   │
│   │   │   └── utils/
│   │   │       └── url-resolver/
│   │   │           └── url-resolver.util.ts ← OAuth redirect URI resolver
│   │   │
│   │   ├── features/
│   │   │   ├── index.ts                    ← Barrel export for features
│   │   │   ├── login/
│   │   │   │   ├── login.ts                ← Login page component
│   │   │   │   ├── login.html
│   │   │   │   └── login.scss
│   │   │   └── dashboard/
│   │   │       ├── dashboard.ts            ← Protected dashboard component
│   │   │       ├── dashboard.html
│   │   │       └── dashboard.scss
│   │   │
│   │   └── styles/
│   │       └── mat-toolbar.theme.scss      ← Custom Material toolbar theme override
│   │
│   ├── environments/
│   │   ├── environment.ts                  ← Development config (gitignored — never commit with real values)
│   │   └── environment.template.ts         ← Shape template — safe to commit (no secrets)
│   │
│   ├── locales/
│   │   ├── messages.xlf                    ← Source strings (English, XLF2 format)
│   │   ├── messages.bn.xlf                 ← Bengali translations (13 units)
│   │   └── messages.hi.xlf                 ← Hindi translations (13 units)
│   │
│   ├── styles.scss                         ← Global stylesheet + Material 3 theme
│   ├── index.html                          ← HTML entry point
│   └── main.ts                             ← Bootstrap entry point
│
├── public/
│   ├── favicon.ico
│   ├── images/
│   │   └── company_logo.png                ← Application logo
│   └── html/
│       └── index.redirect.html             ← Language detection + locale redirect
│
├── angular.json                            ← CLI workspace config (build, serve, i18n)
├── package.json                            ← Dependencies + npm scripts
├── tsconfig.json                           ← Base TypeScript config (strict mode)
├── tsconfig.app.json                       ← App-specific TS config
├── tsconfig.spec.json                      ← Test-specific TS config
└── .prettierrc                             ← Prettier formatting rules
```

---

## 4. Component Architecture

### 4.1 Component Tree

```
AppComponent  (app.ts)
└── LayoutComponent  (core/components/layout)
    ├── TopNavBarComponent  (core/components/top-nav-bar)
    │   Output: toggleSidenav → EventEmitter<void>
    ├── NavPanelComponent   (core/components/nav-panel)
    │   Output: menuItemsClicked → EventEmitter<void>
    ├── <router-outlet>     (Feature slot)
    │   ├── LoginComponent      (features/login)        [/login]
    │   └── DashboardComponent  (features/dashboard)    [/dashboard]
    └── FooterComponent     (core/components/footer)
```

### 4.2 AppComponent

**File:** `src/app/app.ts`

| Property | Value |
|---|---|
| Selector | `app-root` |
| Type | Standalone component |
| Template | `<app-layout></app-layout>` — single layout shell |
| Imports | `LayoutComponent` |
| Purpose | Application entry point; delegates all layout to LayoutComponent |

---

### 4.3 LayoutComponent

**File:** `src/app/core/components/layout/layout.ts`

| Property | Value |
|---|---|
| Selector | `app-layout` |
| Type | Standalone component |
| Services | `BreakpointObserver` |

**Responsibilities:**
- Hosts the full application shell: `MatSidenav`, `MatToolbar`, `<router-outlet>`, `Footer`
- Subscribes to `isHandset` signal to drive responsive sidenav behaviour
- On mobile (`isHandset = true`): sidenav is `over` mode, 50% width, closed by default
- On desktop (`isHandset = false`): sidenav is `side` mode, `auto` width, open by default
- Listens to `toggleSidenav` from `TopNavBar` and `menuItemsClicked` from `NavPanel` to open/close the drawer

**Material Imports:** `MatSidenavModule`, `MatToolbarModule`, `MatButtonModule`, `MatIconModule`, `MatDividerModule`

---

### 4.4 TopNavBarComponent

**File:** `src/app/core/components/top-nav-bar/top-nav-bar.ts`

| Property | Value |
|---|---|
| Selector | `app-top-nav-bar` |
| Type | Standalone component |
| Outputs | `toggleSidenav: EventEmitter<void>` |

**Template Elements:**
- Hamburger menu button (`mat-mini-fab`) — emits `toggleSidenav` on click
- Company logo image (45px width, ARIA-labelled, i18n `alt` text)
- Application title — hidden on handset breakpoint via `@if(!isHandset())`

---

### 4.5 NavPanelComponent

**File:** `src/app/core/components/nav-panel/nav-panel.ts`

| Property | Value |
|---|---|
| Selector | `app-nav-panel` |
| Type | Standalone component |
| Services | `AuthService` |
| Outputs | `menuItemsClicked: EventEmitter<void>` |

**Responsibilities:**
- Displays the logged-in user's name and email via `authService.user()` signal
- **Logout** — calls `authService.logout()`, emits `menuItemsClicked` to close panel
- **Language Switcher** — `MatMenu` dropdown with 3 options (English, বাংলা, हिन्दी)
  - In development: navigates to `http://localhost:4200/<locale>/`
  - In production: navigates to `/society-management-app/<locale>/` preserving hash route
- **Navigation Links** — Dashboard link with active state class binding
- Emits `menuItemsClicked` on any navigation action to auto-close the sidenav on mobile

**Language Constants (`lang.const.ts`):**
```typescript
{ en: { label: 'English', value: 'en-US' },
  bn: { label: 'বাংলা',   value: 'bn'   },
  hi: { label: 'हिन्दी',  value: 'hi'   } }
```

---

### 4.6 FooterComponent

**File:** `src/app/core/components/footer/footer.ts`

| Property | Value |
|---|---|
| Selector | `app-footer` |
| Type | Standalone component |

**Template Elements (all i18n):**
- Developer credit: "Designed and developed by Akashneel Ghosh"
- Copyright: "2026 Society Management System App"
- MIT License statement
- Contact email button with `mat-icon-button` and tooltip

---

### 4.7 LoginComponent

**File:** `src/app/features/login/login.ts`

| Property | Value |
|---|---|
| Route | `/login` |
| Guard | None (public route) |
| Services | `AuthService` |

**Behaviour:** Single "Login with Google" button. On click, calls `authService.loginWithGoogle()` which initiates a Supabase OAuth redirect with PKCE flow. The redirect URI is resolved by `url-resolver.util.ts` to handle both localhost and production environments.

---

### 4.8 DashboardComponent

**File:** `src/app/features/dashboard/dashboard.ts`

| Property | Value |
|---|---|
| Route | `/dashboard` |
| Guard | `authGuard` |
| Services | `AuthService` |

**Behaviour:** Displays a personalised welcome header using `authService.user()?.user_metadata?.['full_name']`. Contains a `MatCard` placeholder shell ready for dashboard widgets in future phases.

---

## 5. Services

### 5.1 AuthService

**File:** `src/app/core/services/auth/auth.service.ts`
**Scope:** `providedIn: 'root'`

#### Responsibilities
- Initialises and manages the Supabase client instance
- Exposes the current authenticated user as a reactive Angular Signal
- Handles Google OAuth login and logout flows
- Subscribes to Supabase's `onAuthStateChange` to keep the user signal in sync

#### API

| Member | Type | Description |
|---|---|---|
| `user` | `Signal<User \| null>` | Reactive current user. `null` when unauthenticated |
| `loginWithGoogle()` | `Promise<void>` | Initiates Google OAuth redirect (PKCE) |
| `logout()` | `Promise<void>` | Signs out the current session |
| `initialize()` | `Promise<void>` | Called on app startup via `provideAppInitializer()` |

#### Internal Implementation

```
App Startup
    └── initialize()
         └── supabase.auth.initialize()
              └── _setUserOnAuth()
                   └── onAuthStateChange(event, session)
                        └── user.set(session?.user ?? null)  ← Signal updated
```

#### OAuth Flow

```
loginWithGoogle() called
     │
     ▼
supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: supabaseRedirectToUriResolver()  ← localhost or production URL
  }
})
     │
     ▼
Browser redirects to Google consent screen
     │
     ▼
Google redirects back with auth code
     │
     ▼
Supabase exchanges code for JWT (PKCE)
     │
     ▼
onAuthStateChange fires → user signal updated
     │
     ▼
authGuard allows navigation to /dashboard
```

#### Supabase Client Configuration

```typescript
createClient(environment.supabaseUrl, environment.supabaseAnonKey, {
  auth: { flowType: 'pkce' }
})
```

---

### 5.2 BreakpointObserver

**File:** `src/app/core/services/breakpoint-observer/breakpoint-observer.ts`
**Scope:** `providedIn: 'root'`

#### Responsibilities
- Wraps Angular CDK's `BreakpointObserver` to expose a signal-based API
- Drives responsive layout behaviour in `LayoutComponent` and `TopNavBarComponent`

#### API

| Member | Type | Description |
|---|---|---|
| `isHandset` | `Signal<boolean>` | `true` when viewport width ≤ 600px |

#### Implementation Detail

```typescript
isHandset = toSignal(
  this.breakpointObserver.observe('(max-width: 600px)').pipe(
    map(result => result.matches)
  ),
  { initialValue: false }
)
```

Uses `toSignal()` from `@angular/core/rxjs-interop` to convert the CDK observable into an Angular signal, with a safe `false` initial value to prevent layout flash on load.

---

## 6. Guards

### AuthGuard

**File:** `src/app/core/guards/auth-guard/auth-guard.ts`
**Type:** `CanActivateFn` (functional guard — no class required)

```typescript
export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (!authService.user()) {
    router.navigate(['/login']);
    return false;
  }
  return true;
};
```

**Behaviour:**
- Reads `authService.user()` signal synchronously — no async calls, no observable subscriptions
- Unauthenticated users are redirected to `/login` immediately
- Returns `true` (allows navigation) only when a valid user session exists
- Applied to the `/dashboard` route (and will be applied to all future protected routes)

---

## 7. Routing

**File:** `src/app/app.routes.ts`

### Route Table

| Path | Component | Guard | Title | Load Strategy |
|---|---|---|---|---|
| `login` | `LoginComponent` | None | "Log In \| Society Management System" | Lazy (`import()`) |
| `dashboard` | `DashboardComponent` | `authGuard` | "Dashboard \| Society Management System" | Lazy (`import()`) |
| `**` | — | — | — | Redirects to `dashboard` |

### Router Configuration

**File:** `src/app/app.config.ts`

```typescript
provideRouter(routes, withHashLocation())
```

`withHashLocation()` configures Angular to use `HashLocationStrategy` — URLs take the form `https://akashneelghoshdev.github.io/society-management-app/#/dashboard`. This is essential because GitHub Pages serves static files and cannot handle HTML5 pushState routing.

### App Initializer

```typescript
provideAppInitializer(() => inject(AuthService).initialize())
```

`AuthService.initialize()` is called before the first route is resolved, ensuring the `user` signal is populated from an existing session before any guard runs.

---

## 8. State Management

The application uses **Angular Signals** exclusively for reactive state. There is no NgRx, no BehaviorSubject, and no component-level `subscribe()` calls.

### Signal Inventory

| Signal | Owner | Type | Description |
|---|---|---|---|
| `user` | `AuthService` | `Signal<User \| null>` | Current authenticated Supabase user |
| `isHandset` | `BreakpointObserver` | `Signal<boolean>` | Viewport breakpoint state |

### Signal Data Flow

```
Supabase onAuthStateChange (external event)
         │
         ▼
authService.user.set(session?.user ?? null)    ← WritableSignal updated
         │
         ├──► authGuard reads user()            ← Synchronous guard check
         ├──► DashboardComponent reads user()   ← Template binding
         └──► NavPanelComponent reads user()    ← Profile display
```

```
CDK BreakpointObserver (RxJS Observable)
         │
         ▼
toSignal(observable, { initialValue: false })  ← Converted to Signal
         │
         ├──► LayoutComponent reads isHandset() ← Sidenav mode & width
         └──► TopNavBarComponent reads isHandset() ← Title visibility
```

### Why Signals (not NgRx)

At the current application scale, Angular Signals provide:
- No boilerplate (no actions, reducers, effects, selectors)
- Synchronous reads — safe in guards and template expressions
- Fine-grained reactivity — only components that read a signal re-render when it changes
- Full integration with Angular's change detection and the `async` pipe replacement pattern

NgRx will be evaluated when the state graph grows to require cross-feature coordination (e.g. resident data, payment state, notification feeds).

---

## 9. Internationalization

### Architecture

Angular's **compile-time i18n** system is used. At build time, the Angular compiler produces **three separate optimized bundles**, one per locale. There is no runtime translation overhead — each locale build contains only its own strings.

### Translation Files

All translation files use **XLF2 (XLIFF 2.0)** format, located in `src/locales/`:

| File | Locale | Language | Units |
|---|---|---|---|
| `messages.xlf` | `en-US` | English (source) | 13 |
| `messages.bn.xlf` | `bn` | Bengali (বাংলা) | 13 |
| `messages.hi.xlf` | `hi` | Hindi (हिन्दी) | 13 |

### Translated String Units

| Unit ID | English | Bengali | Hindi |
|---|---|---|---|
| `appTitle` | Society Management System | সোসাইটি ম্যানেজমেন্ট সিস্টেম | सोसाइटी प्रबंधन प्रणाली |
| `loginWithGoogle` | Login with Google | গুগল দিয়ে লগইন করুন | Google से लॉगिन करें |
| `dashboard` | Dashboard | ড্যাশবোর্ড | डैशबोर्ड |
| `logIn` | Log In | লগ ইন | लॉग इन |
| `logOut` | Log Out | লগ আউট | लॉग आउट |
| `changeLanguage` | Change Language | ভাষা পরিবর্তন করুন | भाषा बदलें |
| `userProfile` | User Profile | ব্যবহারকারীর প্রোফাইল | उपयोगकर्ता प्रोफ़ाइल |
| `designedBy` | Designed and developed by Akashneel Ghosh | আকাশনীল ঘোষ দ্বারা ডিজাইন এবং উন্নত | अकाशनील घोष द्वारा डिजाइन और विकसित |
| `copyright` | 2026 Society Management System App | ২০২৬ সোসাইটি ম্যানেজমেন্ট সিস্টেম অ্যাপ | 2026 सोसाइटी प्रबंधन प्रणाली ऐप |
| `menuAriaLabel` | Open navigation menu | নেভিগেশন মেনু খুলুন | नेविगेशन मेनू खोलें |
| `logoAlt` | Company logo | কোম্পানির লোগো | कंपनी लोगो |
| `contactUs` | Contact us | আমাদের সাথে যোগাযোগ করুন | हमसे संपर्क करें |
| `welcomeHeader` | Welcome, {name} | স্বাগতম, {name} | स्वागत है, {name} |

### i18n in Templates

```html
<!-- Static text -->
<span i18n="@@dashboard">Dashboard</span>

<!-- Attribute translation -->
<img i18n-alt="@@logoAlt" alt="Company logo" />
<button i18n-aria-label="@@menuAriaLabel" aria-label="Open navigation menu">

<!-- Interpolation -->
<h1 i18n="@@welcomeHeader">Welcome, {{ user()?.user_metadata?.['full_name'] }}</h1>
```

### Language Switching

The `NavPanel` language switcher handles switching by navigating the browser to the appropriate locale subdirectory:

```typescript
switchLanguage(locale: string): void {
  const isLocalhost = window.location.hostname === 'localhost';
  const baseUrl = isLocalhost
    ? `http://localhost:4200/${locale}/`
    : `/society-management-app/${locale}/`;
  window.location.href = baseUrl;
}
```

### Extracting / Updating Translations

```bash
# Re-extract all translatable strings from source templates
npm run extract-i18n
# Output: src/locales/messages.xlf (updated)

# Then update each translation file with new units from messages.xlf
# using an XLF-aware translation tool or manually adding <target> elements
```

### Build Configuration (angular.json excerpt)

```json
"i18n": {
  "sourceLocale": "en-US",
  "locales": {
    "bn": { "translation": "src/locales/messages.bn.xlf" },
    "hi": { "translation": "src/locales/messages.hi.xlf" }
  }
}
```

---

## 10. Styling & Theming

### CSS Framework & Preprocessor

| Technology | Usage |
|---|---|
| Angular Material 3 | Component library with CSS variable-based design tokens |
| SCSS | Styling language for all component and global styles |
| Google Fonts | Roboto (body), Material Icons |

### Global Theme (`src/styles.scss`)

```scss
@use '@angular/material' as mat;

$theme: mat.define-theme((
  color: (
    theme-type: light,
    primary: mat.$azure-palette,
    tertiary: mat.$blue-palette,
  ),
  typography: (
    use-system-variables: false,
    plain-family: Roboto,
  ),
  density: (scale: 0),
));

html { @include mat.all-component-themes($theme); }
```

**Material system CSS variables** (`--mat-sys-*`) are available globally for custom component styling.

### Custom Toolbar Theme (`src/app/styles/mat-toolbar.theme.scss`)

Applies `inverse-primary` background to the Material toolbar, giving the app header a brand-consistent colour derived from the primary palette.

### Component-Level Styles

| Component | File | Key Styles |
|---|---|---|
| Layout | `layout.scss` | `height: calc(100vh - 64px)` sidenav container; responsive sidenav width |
| TopNavBar | `top-nav-bar.scss` | Flex row toolbar; logo `width: 45px` |
| NavPanel | `nav-panel.scss` | Flex column, centred content |
| Footer | `footer.scss` | Flex column, centred; contact row flex |
| Login | `login.scss` | Full-height flex centred container |
| Dashboard | `dashboard.scss` | Flex column, `1rem` gap |

### Responsive Breakpoints

| Breakpoint | Value | Applied By |
|---|---|---|
| Handset | `max-width: 600px` | `BreakpointObserver` service |
| Desktop | `> 600px` | Default layout state |

---

## 11. Environment Configuration

### Files

| File | Committed | Contains Secrets | Purpose |
|---|---|---|---|
| `environment.template.ts` | ✅ Yes | ❌ No | Shape definition only — all values empty strings |
| `environment.ts` | ❌ No (gitignored) | ✅ Yes (local dev) | Developer's local configuration |

### Shape

```typescript
// environment.template.ts — safe to commit, never contains real values
export const environment = {
  production: false,
  supabaseUrl: '',
  supabaseAnonKey: '',
};
```

### Local Setup

```bash
cp src/environments/environment.template.ts src/environments/environment.ts
# Fill in your Supabase project URL and anon key from your Supabase project dashboard
# Never commit environment.ts — it is in .gitignore
```

### CI/CD Injection

The `deploy-pages.yml` pipeline generates `environment.ts` at build time from GitHub Actions Secrets:

```yaml
- name: Generate environment.ts
  run: |
    cat > society-management-ui/src/environments/environment.ts << EOF
    export const environment = {
      production: true,
      supabaseUrl: '${{ secrets.SUPABASE_URL }}',
      supabaseAnonKey: '${{ secrets.SUPABASE_ANON_KEY }}',
    };
    EOF
```

---

## 12. Build System

### Builder

The project uses Angular's **`@angular/build:application`** builder (Vite-based), replacing the legacy Webpack builder. This delivers significantly faster builds and native ESM output.

### npm Scripts

| Script | Command | Description |
|---|---|---|
| `npm start` | `ng serve` | Dev server on `localhost:4200` — English locale |
| `npm run start-bn` | `ng serve -c development-bn` | Dev server with Bengali locale |
| `npm run start-hi` | `ng serve -c development-hi` | Dev server with Hindi locale |
| `npm run build` | `ng build` | Development build |
| `npm run build:prod` | `ng build -c production` | Production build — all 3 locales, optimized |
| `npm run extract-i18n` | `ng extract-i18n ...` | Extract i18n strings to `messages.xlf` |
| `npm run watch` | `ng build --watch -c development` | Watch mode |
| `npm run test` | `ng test` | Run unit tests with Vitest (watch mode) |

### Production Build Configuration (`angular.json`)

```json
{
  "optimization": true,
  "outputHashing": "all",
  "localize": true,
  "baseHref": "/society-management-app/",
  "budgets": [
    { "type": "initial", "maximumWarning": "500kB", "maximumError": "1MB" },
    { "type": "anyComponentStyle", "maximumWarning": "4kB", "maximumError": "8kB" }
  ]
}
```

- `localize: true` — compiles all three locale bundles in one pass
- `outputHashing: all` — all assets (JS, CSS, images) get content hashes for cache-busting
- `baseHref: /society-management-app/` — sets the correct base path for GitHub Pages subdirectory hosting

### Output Structure

```
dist/society-management-ui/browser/
├── en-US/
│   ├── index.html
│   ├── main.<hash>.js
│   └── styles.<hash>.css
├── bn/
│   ├── index.html
│   └── ...
└── hi/
    ├── index.html
    └── ...
```

---

## 13. Testing

### Framework

| Tool | Version | Purpose |
|---|---|---|
| Vitest | 4.0.8 | Test runner (replaces Karma/Jasmine) |
| jsdom | 28.0.0 | DOM emulation for headless test execution |
| `@angular/core/testing` | 21.2.0 | `TestBed`, component harnesses |

### Running Tests

```bash
# Interactive watch mode (development)
npm run test

# Single run, no watch (CI)
ng test --watch=false --browsers=ChromeHeadless
```

### TypeScript Configuration (`tsconfig.spec.json`)

```json
{
  "types": ["vitest/globals", "@angular/localize"],
  "include": ["src/**/*.spec.ts", "src/**/*.d.ts"]
}
```

### Current Test Coverage

| File | Suite | Tests |
|---|---|---|
| `src/app/app.spec.ts` | App (root) | 1 — component instantiation |

### Test Patterns

```typescript
// Component instantiation test pattern
describe('App', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App],
      providers: [provideRouter([])],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(App);
    expect(fixture.componentInstance).toBeTruthy();
  });
});
```

---

## 14. Development Workflow

### Prerequisites

| Tool | Version |
|---|---|
| Node.js | 22.x |
| npm | 11.x |
| Angular CLI | 21.x (`npm install -g @angular/cli`) |

### Setup

```bash
# Clone and navigate to the UI project
git clone https://github.com/akashneelGhoshDev/society-management-app.git
cd society-management-app/society-management-ui

# Install dependencies (clean install — respects package-lock.json)
npm ci

# Set up local environment (never commit environment.ts)
cp src/environments/environment.template.ts src/environments/environment.ts
# → Fill in Supabase URL and anon key

# Start the development server
npm start
# → http://localhost:4200
```

### Locale-Specific Development

```bash
# Bengali locale
npm run start-bn
# → http://localhost:4200/bn/

# Hindi locale
npm run start-hi
# → http://localhost:4200/hi/
```

### Adding a New Feature

```bash
# Generate a new standalone component inside features/
ng generate component features/my-feature --standalone

# Add a lazy-loaded route in app.routes.ts
{
  path: 'my-feature',
  loadComponent: () => import('./features/my-feature/my-feature').then(m => m.MyFeatureComponent),
  canActivate: [authGuard],
  title: 'My Feature | Society Management System'
}
```

### Adding a New Language

```bash
# 1. Extract current strings
npm run extract-i18n

# 2. Create translation file
cp src/locales/messages.xlf src/locales/messages.<locale>.xlf
# Translate all <target> elements

# 3. Register in angular.json → i18n.locales
# 4. Add build configuration for the locale
# 5. Add language to lang.const.ts and NavPanel switcher
```

---

## 15. Code Standards

### TypeScript

| Rule | Detail |
|---|---|
| Strict mode | `strict: true` — all strict flags enabled |
| No implicit override | `noImplicitOverride: true` |
| No property access from index signature | `noPropertyAccessFromIndexSignature: true` |
| Strict templates | `strictTemplates: true` |
| Strict injection | `strictInjectionParameters: true` |
| No `any` | Use explicit types or `unknown` |

### Angular Conventions

| Convention | Detail |
|---|---|
| Standalone only | No `NgModule` — all components are standalone |
| Signals for state | No direct observable subscriptions in component classes |
| Functional guards | Use `CanActivateFn` — no class-based guards |
| Lazy loading | All feature components loaded via `loadComponent` |
| Barrel exports | `index.ts` in `core/` and `features/` |
| i18n | All user-visible strings use `i18n` attribute — no hardcoded English |

### Formatting

Enforced by Prettier (`.prettierrc`):

```json
{
  "printWidth": 100,
  "singleQuote": true,
  "overrides": [{ "files": "*.html", "options": { "parser": "angular" } }]
}
```

```bash
# Format all files
npx prettier --write .

# Check formatting (CI)
npx prettier --check .
```

---

## 16. Dependencies Reference

### Production Dependencies

| Package | Version | Purpose |
|---|---|---|
| `@angular/core` | 21.2.0 | Core Angular framework |
| `@angular/common` | 21.2.0 | Common directives (`@if`, `@for`, pipes) |
| `@angular/router` | 21.2.0 | Client-side routing |
| `@angular/forms` | 21.2.0 | Reactive and template-driven forms |
| `@angular/platform-browser` | 21.2.0 | Browser platform bootstrap |
| `@angular/cdk` | 21.2.13 | Component Dev Kit (breakpoint, a11y) |
| `@angular/material` | 21.2.13 | Material Design 3 components |
| `@angular/localize` | 21.2.0 | Compile-time i18n support |
| `@supabase/supabase-js` | 2.106.2 | Supabase client SDK |
| `rxjs` | 7.8.0 | Reactive programming |
| `tslib` | 2.8.1 | TypeScript runtime helpers |

### Development Dependencies

| Package | Version | Purpose |
|---|---|---|
| `@angular/cli` | 21.2.13 | CLI toolchain |
| `@angular/build` | 21.2.13 | Vite-based application builder |
| `@angular/compiler-cli` | 21.2.0 | Ahead-of-time compilation |
| `typescript` | 5.9.2 | TypeScript compiler |
| `vitest` | 4.0.8 | Unit test runner |
| `jsdom` | 28.0.0 | DOM emulation for tests |
| `prettier` | 3.8.1 | Code formatter |

---

> Part of the [Society Management System](../README.md) · [Supabase Backend →](../supabase/README.md)
> **Designed and developed by Akashneel Ghosh**
> 📧 [akashneel.ghosh.enterprises@gmail.com](mailto:akashneel.ghosh.enterprises@gmail.com) · [GitHub](https://github.com/akashneelGhoshDev) · [LinkedIn](https://www.linkedin.com/in/akashneel-ghosh-124976109/)
