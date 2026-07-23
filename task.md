# Task: Thai Life Map V1.2.5 — Invited Beta User Validation

## Goal
Ship a production-safe Feedback collection + UI for invited-beta signed-in users on Thai Life Map, with Firestore rules enforcement, admin summary, and status **Ready for Invited Beta Validation** (do not claim Validation Passed without real users).

## Scope choice
- New collection `thai_life_map_beta_feedback` (invite-only writes) — keep public `thai_beta_feedback` research path unchanged
- New allow-list `invited_beta_testers/{uid}` (same trust model as `admins/{uid}`)
- Wire Evidence Badge audience to Firestore invite docs (in-memory registry remains for tests)
- Non-blocking panel on `ThaiBetaReportPage` for invited users only
- Admin summary card on existing `ThaiBetaAdminPage`

## Non-goals
- Do not modify Frozen Canon / Mahabhut formulas
- Do not open Evidence Badge to the public
- Do not auto-expand allow-list
- Do not seed fake user validation scores
- Do not claim Validation Passed without ≥5 real users
