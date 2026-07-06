# Office Time Tracker — Progress

## Status: In Progress

---

## Milestones

### Milestone 1 — Repo + Schema Foundation ✅
- Created `office-time-tracker` repository
- Defined adaptive auth model (admin-managed ≤5, hybrid >5)
- Sharing existing Supabase project; schema prefix `ott`
- Written migrations 001–005 (schema, tables, RLS, grants, seed)
- Repository structure established

---

## Pending

- [ ] Apply migrations in Supabase SQL editor
- [ ] Build frontend: index.html (dashboard)
- [ ] Build frontend: admin.html (user management)
- [ ] Build frontend: timeclock.html (clock in/out)
- [ ] Build frontend: timeoff.html (vacation/PTO)
- [ ] Build frontend: policies.html (org settings)
- [ ] Edge Function: clock-in-out (handles time entry writes)
- [ ] Edge Function: submit-timeoff (handles PTO requests)
- [ ] Configure GitHub Pages
- [ ] Add live URL to README
