# Thai Life Map V1.2.5 — Invited Beta User Validation

**Status:** **Ready for Invited Beta Validation**  
**Not:** Validation Passed (no real invited-user Feedback yet)  
**Base:** `cb33a3d` (V1.2.4 audit on main)  
**Production tip (pre-deploy):** `07d0eb9` runtime; this change adds application + rules

## Scope decision

| Choice | Reason |
|--------|--------|
| New collection `thai_life_map_beta_feedback` | Keep public research `thai_beta_feedback` unchanged; invite-only writes |
| New allow-list `invited_beta_testers/{uid}` | Same trust model as `admins/{uid}`; enforceable in `firestore.rules` |
| Wire Evidence Badge audience to Firestore invites | Client registry alone is not trusted enforcement |
| Non-blocking `ExpansionTile` on `ThaiBetaReportPage` | After Life Map content; no interrupting modal |
| Admin summary on existing `ThaiBetaAdminPage` | No new admin product |

## Security model

- **UI gate:** panel only when `audience.isInvitedBetaTester && userId != null`
- **Trusted gate:** `firestore.rules` requires `exists(invited_beta_testers/{uid})` and `docId == auth.uid`
- Invite docs: client **read own** only; **write false** (ops/console)
- Anonymous / non-invite / admin-without-invite: cannot create feedback docs
- Own read/update only for invited; admins read all for summary
- No birth PII in feedback — `lifeMapRef` (report hash) only
- Evidence Badge activation remains `invited_beta`

## Data model

`thai_life_map_beta_feedback/{uid}` — overall scores (lifeFit, clarity, trust, usefulness), UX chips, optional comment, viewport, buildVersion, sourcePath, isQaTest, timestamps  
`…/period_feedback/p{0-7}` — periodIndex + category + optional comment

## Validation phase (at close of implementation)

| Metric | Value |
|--------|------:|
| Real invited users with Feedback | **0** |
| Phase | **Ready for Invited Beta Validation** |

QA/test rows must set `isQaTest: true` and are excluded from real-user counts.

## Ops: invite a tester

Create Firestore doc (console/CLI, never from app client):

```text
invited_beta_testers/{firebaseAuthUid}
  (empty map or { invitedAt: <timestamp> } is fine)
```

## Rollback

- UI: remove/hide panel or redeploy previous hosting SHA
- Rules: redeploy prior `firestore.rules` (non-destructive; new collections unused)
- No destructive migration

## Confirmed

- Focused V1.2.5 tests cover gating, validation, idempotent upsert, summary phase, rules contract text
- Frozen Canon / Mahabhut formulas untouched
- Badge stays `invited_beta`

## Not confirmed / not claimed

- Real-user Validation Passed
- Interactive Production QA with live invited UIDs (requires ops to seed invite docs)
- ≥5 real users scoring thresholds
