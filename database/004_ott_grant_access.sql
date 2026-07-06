-- ============================================================
-- Migration: 004_ott_grant_access.sql
-- Description: Grant schema and table access for ott
-- Run order: 4 of 5
-- Depends on: 003_ott_rls_policies.sql
--
-- Notes:
--   anon gets NO access — this tracker is not public.
--   authenticated gets SELECT/INSERT/UPDATE on relevant tables
--   for hybrid mode (employee self-service).
--   service_role bypasses RLS entirely — no grants needed.
-- ============================================================

-- Grant schema usage to authenticated (hybrid mode employees)
GRANT USAGE ON SCHEMA ott TO authenticated;

-- organizations: employees can read their own org
GRANT SELECT ON ott.organizations TO authenticated;

-- users: employees can read their own record
GRANT SELECT ON ott.users TO authenticated;

-- time_entries: employees can read, insert, and update their own
GRANT SELECT, INSERT, UPDATE ON ott.time_entries TO authenticated;

-- breaks: employees can read, insert, and update their own
GRANT SELECT, INSERT, UPDATE ON ott.breaks TO authenticated;

-- time_off: employees can read and insert their own requests
GRANT SELECT, INSERT ON ott.time_off TO authenticated;

-- policies: employees can read org policy rules
GRANT SELECT ON ott.policies TO authenticated;

-- Sequence access for INSERT operations (SERIAL columns)
GRANT USAGE ON SEQUENCE ott.time_entries_entry_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE ott.breaks_break_id_seq       TO authenticated;
GRANT USAGE ON SEQUENCE ott.time_off_time_off_id_seq  TO authenticated;
