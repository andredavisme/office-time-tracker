-- ============================================================
-- Migration: 002_ott_tables.sql
-- Description: Core tables for office-time-tracker
-- Run order: 2 of 5
-- Depends on: 001_ott_schema.sql
-- ============================================================

-- ------------------------------------------------------------
-- organizations
-- The office or company using this tracker.
-- A single deployment will typically have one org.
-- Multiple orgs are supported for future multi-tenant use.
-- ------------------------------------------------------------
CREATE TABLE ott.organizations (
  org_id          SERIAL PRIMARY KEY,
  name            TEXT        NOT NULL,
  timezone        TEXT        NOT NULL DEFAULT 'America/New_York',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- users
-- Employees managed by admin. Not the same as auth.users.
-- auth_user_id is NULL for admin-managed mode (≤5 users).
-- auth_user_id is set when an employee gets a Supabase Auth
-- account (hybrid mode, >5 users).
-- ------------------------------------------------------------
CREATE TABLE ott.users (
  user_id         SERIAL PRIMARY KEY,
  org_id          INTEGER     NOT NULL REFERENCES ott.organizations(org_id),
  full_name       TEXT        NOT NULL,
  email           TEXT,
  role            TEXT        NOT NULL DEFAULT 'employee',  -- 'admin' | 'employee'
  is_active       BOOLEAN     NOT NULL DEFAULT true,
  auth_user_id    UUID        REFERENCES auth.users(id),    -- NULL in admin-managed mode
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- time_entries
-- Each row is one work session: clock-in to clock-out.
-- clock_out is NULL while the employee is still clocked in.
-- total_minutes is computed on clock-out and stored for
-- reporting performance (avoids recomputing on every query).
-- ------------------------------------------------------------
CREATE TABLE ott.time_entries (
  entry_id        SERIAL PRIMARY KEY,
  user_id         INTEGER     NOT NULL REFERENCES ott.users(user_id),
  org_id          INTEGER     NOT NULL REFERENCES ott.organizations(org_id),
  clock_in        TIMESTAMPTZ NOT NULL,
  clock_out       TIMESTAMPTZ,
  total_minutes   INTEGER,                                  -- set on clock-out
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- breaks
-- Break periods within a time entry.
-- break_end is NULL while the break is in progress.
-- break_type: 'paid' | 'unpaid' | 'lunch'
-- ------------------------------------------------------------
CREATE TABLE ott.breaks (
  break_id        SERIAL PRIMARY KEY,
  entry_id        INTEGER     NOT NULL REFERENCES ott.time_entries(entry_id),
  user_id         INTEGER     NOT NULL REFERENCES ott.users(user_id),
  break_start     TIMESTAMPTZ NOT NULL,
  break_end       TIMESTAMPTZ,
  break_type      TEXT        NOT NULL DEFAULT 'unpaid',    -- 'paid' | 'unpaid' | 'lunch'
  total_minutes   INTEGER,                                  -- set on break_end
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- time_off
-- Vacation, PTO, sick leave, and other absence records.
-- status: 'pending' | 'approved' | 'denied' | 'cancelled'
-- time_off_type references ott.policies.policy_key for
-- flexibility — the org defines what types exist.
-- ------------------------------------------------------------
CREATE TABLE ott.time_off (
  time_off_id     SERIAL PRIMARY KEY,
  user_id         INTEGER     NOT NULL REFERENCES ott.users(user_id),
  org_id          INTEGER     NOT NULL REFERENCES ott.organizations(org_id),
  time_off_type   TEXT        NOT NULL,                     -- e.g. 'vacation', 'sick', 'personal'
  start_date      DATE        NOT NULL,
  end_date        DATE        NOT NULL,
  total_days      NUMERIC(5,2),                             -- supports half-days
  status          TEXT        NOT NULL DEFAULT 'pending',
  requested_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_by     INTEGER     REFERENCES ott.users(user_id),
  reviewed_at     TIMESTAMPTZ,
  notes           TEXT
);

-- ------------------------------------------------------------
-- policies
-- Org-level configuration. One row per policy key per org.
-- Examples:
--   policy_key: 'paid_break_minutes'  value: '15'
--   policy_key: 'lunch_break_minutes' value: '30'
--   policy_key: 'pto_days_per_year'   value: '10'
--   policy_key: 'sick_days_per_year'  value: '5'
--   policy_key: 'overtime_threshold_hours' value: '40'
-- Admin can add/edit rows freely. Frontend reads these at
-- runtime to enforce rules.
-- ------------------------------------------------------------
CREATE TABLE ott.policies (
  policy_id       SERIAL PRIMARY KEY,
  org_id          INTEGER     NOT NULL REFERENCES ott.organizations(org_id),
  policy_key      TEXT        NOT NULL,
  policy_value    TEXT        NOT NULL,
  description     TEXT,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (org_id, policy_key)
);
