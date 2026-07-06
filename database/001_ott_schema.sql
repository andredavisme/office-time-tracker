-- ============================================================
-- Migration: 001_ott_schema.sql
-- Description: Create the ott (office time tracker) schema
-- Run order: 1 of 5
-- Notes: All OTT tables live in this schema to avoid collisions
--        with other projects on the same Supabase instance.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS ott;
