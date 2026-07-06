-- ============================================================
-- Migration: 003_ott_rls_policies.sql
-- Description: Enable RLS and define access policies for ott schema
-- Run order: 3 of 5
-- Depends on: 002_ott_tables.sql
--
-- Access model:
--   service_role  → full read/write (admin UI, Edge Functions)
--   authenticated → own rows only via auth_user_id = auth.uid()
--                   (hybrid mode, >5 users)
--   anon          → no access
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE ott.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ott.users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE ott.time_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ott.breaks       ENABLE ROW LEVEL SECURITY;
ALTER TABLE ott.time_off     ENABLE ROW LEVEL SECURITY;
ALTER TABLE ott.policies     ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- service_role: full access to everything
-- Used by: admin UI (via Edge Functions), pg_cron, triggers
-- ------------------------------------------------------------
CREATE POLICY "service_role_all_organizations"
  ON ott.organizations FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "service_role_all_users"
  ON ott.users FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "service_role_all_time_entries"
  ON ott.time_entries FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "service_role_all_breaks"
  ON ott.breaks FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "service_role_all_time_off"
  ON ott.time_off FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "service_role_all_policies"
  ON ott.policies FOR ALL
  USING (auth.role() = 'service_role');

-- ------------------------------------------------------------
-- authenticated (hybrid mode): employees read/write own rows
-- These policies activate when an employee has a Supabase
-- Auth account and their auth_user_id is set in ott.users.
-- In admin-managed mode (≤5 users) these are never triggered
-- because no employee auth accounts exist.
-- ------------------------------------------------------------

-- Employees can read their own user record
CREATE POLICY "authenticated_read_own_user"
  ON ott.users FOR SELECT
  TO authenticated
  USING (auth_user_id = auth.uid());

-- Employees can read their own time entries
CREATE POLICY "authenticated_read_own_time_entries"
  ON ott.time_entries FOR SELECT
  TO authenticated
  USING (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can insert their own time entries (clock in)
CREATE POLICY "authenticated_insert_own_time_entries"
  ON ott.time_entries FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can update their own time entries (clock out)
CREATE POLICY "authenticated_update_own_time_entries"
  ON ott.time_entries FOR UPDATE
  TO authenticated
  USING (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can read their own breaks
CREATE POLICY "authenticated_read_own_breaks"
  ON ott.breaks FOR SELECT
  TO authenticated
  USING (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can insert their own breaks
CREATE POLICY "authenticated_insert_own_breaks"
  ON ott.breaks FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can update their own breaks (end a break)
CREATE POLICY "authenticated_update_own_breaks"
  ON ott.breaks FOR UPDATE
  TO authenticated
  USING (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can read their own time off records
CREATE POLICY "authenticated_read_own_time_off"
  ON ott.time_off FOR SELECT
  TO authenticated
  USING (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can submit time off requests
CREATE POLICY "authenticated_insert_own_time_off"
  ON ott.time_off FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id IN (
      SELECT user_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can read org policies (to know their own rules)
CREATE POLICY "authenticated_read_policies"
  ON ott.policies FOR SELECT
  TO authenticated
  USING (
    org_id IN (
      SELECT org_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );

-- Employees can read their own org record
CREATE POLICY "authenticated_read_own_org"
  ON ott.organizations FOR SELECT
  TO authenticated
  USING (
    org_id IN (
      SELECT org_id FROM ott.users
      WHERE auth_user_id = auth.uid()
    )
  );
