# Office Time Tracker

A flexible time tracker for small administrative offices. Built with Supabase (shared project) and GitHub Pages (vanilla HTML/JS). No build step, no bundler.

## Live Site

> URL will be added after GitHub Pages is configured.

## What It Does

- **User management** — add employees, edit info, flag active/inactive
- **Time entries** — clock in/out, editable by admin
- **Breaks** — tracked per time entry, customizable rules per org
- **Time off** — vacation and PTO requests, tracked against policy
- **Org policies** — break lengths, PTO accrual rules, configurable per organization

## Auth Model

Adaptive based on team size:

- **≤ 5 users** — admin-managed. One admin account. Employees do not need logins.
- **> 5 users** — hybrid. Employees get Supabase Auth accounts and can log their own time. Admin can edit any record.

The schema supports both modes from the start. The `ott.users` table has an optional `auth_user_id` column that links to `auth.users` when an employee account is created.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Database | Supabase (PostgreSQL), `ott` schema |
| Auth | Supabase Auth (admin + optional employee logins) |
| Backend logic | Supabase Edge Functions (Deno/TypeScript) |
| Frontend | Vanilla HTML/CSS/JS, GitHub Pages |

## Supabase Project

Shares the existing project. All tables live in the `ott` schema to avoid collisions with other projects on the same instance.

## Repository Structure

```
office-time-tracker/
├── database/
│   ├── 001_ott_schema.sql          # CREATE SCHEMA
│   ├── 002_ott_tables.sql          # All core tables
│   ├── 003_ott_rls_policies.sql    # RLS enable + policies
│   ├── 004_ott_grant_access.sql    # GRANT USAGE + SELECT/INSERT/UPDATE
│   └── 005_ott_seed.sql            # Sample org + policies for dev
├── functions/
│   └── .gitkeep                    # Edge Functions go here
├── frontend/
│   └── .gitkeep                    # HTML/CSS/JS go here
├── docs/
│   └── .gitkeep                    # Internal docs go here
├── PROGRESS.md
└── README.md
```

## Pages

| File | Purpose |
|------|---------|
| `index.html` | Dashboard — today's summary, who's clocked in |
| `admin.html` | User management, edit any record |
| `timeclock.html` | Clock in/out |
| `timeoff.html` | Vacation/PTO view and requests |
| `policies.html` | Org policy settings (admin only) |

## Setup

### 1. Database
Run migrations in order in the Supabase SQL editor:

```
database/001_ott_schema.sql
database/002_ott_tables.sql
database/003_ott_rls_policies.sql
database/004_ott_grant_access.sql
database/005_ott_seed.sql   ← dev only
```

### 2. GitHub Pages
Repo → Settings → Pages → Source: `main` branch, `/` (root) folder.

### 3. Supabase Keys
Add your `SUPABASE_URL` and anon key to `app.js` when frontend is built. The anon key is intentionally public — RLS is the security layer.

## PROGRESS

See [PROGRESS.md](PROGRESS.md) for detailed milestone log.
