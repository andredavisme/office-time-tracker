-- ============================================================
-- Migration: 005_ott_seed.sql
-- Description: Sample data for development and testing
-- Run order: 5 of 5 (DEV ONLY — do not run in production)
-- Depends on: 002_ott_tables.sql
-- ============================================================

-- Sample organization
INSERT INTO ott.organizations (name, timezone)
VALUES ('Demo Office', 'America/New_York');

-- Sample employees (admin-managed mode — no auth_user_id)
INSERT INTO ott.users (org_id, full_name, email, role, is_active)
VALUES
  (1, 'Admin User',   'admin@demo.com',   'admin',    true),
  (1, 'Alice Smith',  'alice@demo.com',   'employee', true),
  (1, 'Bob Jones',    'bob@demo.com',     'employee', true),
  (1, 'Carol White',  'carol@demo.com',   'employee', true);

-- Default org policies
INSERT INTO ott.policies (org_id, policy_key, policy_value, description)
VALUES
  (1, 'paid_break_minutes',        '15',  'Length of paid break in minutes'),
  (1, 'lunch_break_minutes',       '30',  'Standard unpaid lunch break in minutes'),
  (1, 'overtime_threshold_hours',  '40',  'Weekly hours before overtime applies'),
  (1, 'pto_days_per_year',         '10',  'Paid time off days accrued per year'),
  (1, 'sick_days_per_year',        '5',   'Sick days per year'),
  (1, 'personal_days_per_year',    '3',   'Personal days per year'),
  (1, 'max_break_count_per_shift', '2',   'Maximum number of breaks allowed per shift');
