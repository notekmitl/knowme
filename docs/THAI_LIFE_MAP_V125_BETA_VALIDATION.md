# Thai Life Map V1.2.5 — Invited Beta User Validation

**Status:** **Ready for Invited Beta Validation**  
**Not:** Validation Passed (real invited-user Life Map Feedback count = **0**)  
**Merge:** PR #23 → `b5d1243`  
**Production deploy:** Firebase `knowme-app-694e1` from `main` @ `b5d1243` (2026-07-23)  
**Public URL:** https://knowme-app-694e1.web.app/beta/thai?v=b5d1243

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

## Validation phase (post-deploy)

| Metric | Value |
|--------|------:|
| Real invited users with Life Map Feedback | **0** |
| Phase | **Ready for Invited Beta Validation** |
| QA feedback written this round | **None** (nothing to clean) |

## Production deploy evidence

| Item | Result |
|------|--------|
| Pre-deploy | `scripts/deploy_web.ps1` — flutter web release + localhost guard + bundle validate PASS |
| Cache-bust | `main.dart.js?v=b5d1243`, `flutter_bootstrap.js?v=b5d1243` |
| Firestore rules | Released to `knowme-app-694e1` (includes `invited_beta_testers` + `thai_life_map_beta_feedback`) |
| Hosting | Released to https://knowme-app-694e1.web.app |
| Bundle markers | Contains `invited_beta`, `thai_life_map_beta_feedback`, `thai_life_map_beta_feedback_panel`, `Ready for Invited Beta Validation` |

## Production QA (2026-07-23)

| Check | Result |
|-------|--------|
| Anonymous `/beta/thai?v=b5d1243` desktop | Landing loads (Thai research landing); **no** Evidence Badge chrome; **no** Life Map invited feedback panel |
| Anonymous mobile (390×844) | Landing layout OK; same gating (no badge / no invited panel) |
| Hosted JS `?v=b5d1243` | HTTP 200, `cache-control: no-cache, must-revalidate` |
| Signed-in normal / invited / admin interactive | **Not executed** — no invite UIDs seeded this round (allow-list not auto-expanded); AuthGate paths not automated |
| Submit / duplicate / admin summary live | **Not executed** (requires invited UID + admin session) |
| QA Firestore feedback | **None created** |

## Ops: invite a tester

Create Firestore doc (console/CLI, never from app client):

```text
invited_beta_testers/{firebaseAuthUid}
  (empty map or { invitedAt: <timestamp> } is fine)
```

## Rollback

- UI: redeploy prior hosting SHA
- Rules: redeploy prior `firestore.rules` (non-destructive; new collections unused)
- No destructive migration

## Confirmed

- Feedback system merged + hosted @ `b5d1243`
- Badge stays `invited_beta`
- Frozen Canon / Mahabhut formulas untouched in this change set
- Anonymous Production landing does not expose invited feedback UI

## Not confirmed / not claimed

- Validation Passed
- Interactive invited-user submit on Production
- ≥5 real invited users meeting score bars
