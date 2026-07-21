# Thai Public Evidence Badge Invited Beta Implementation

**Phase:** Controlled Beta Activation — Invited Beta Implementation  
**Status:** **IMPLEMENTED / CONTROLLED**  
**Implementation date:** July 2026  
**Prerequisite commit:** `8ad96b7` — Public Evidence Badge Invited Beta Plan  
**Plan source:** [`THAI_PUBLIC_EVIDENCE_BADGE_INVITED_BETA_PLAN.md`](THAI_PUBLIC_EVIDENCE_BADGE_INVITED_BETA_PLAN.md)  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)

---

## 1. Implementation status

**LEVEL 1 Public Evidence Badge is ACTIVE for invited beta testers only.**

| Item | State |
|------|-------|
| Invited beta activation | **active** (`invited_beta`) |
| Public rollout | **NOT active** |
| All-user rollout | **NOT active** |
| Anonymous access | **NOT active** |
| Normal signed-in user access | **NOT active** |
| Public evidence release | **NOT authorized** |

Implementation files:

- `lib/features/thai_beta/application/thai_evidence_badge_activation.dart` — checked-in state `invited_beta`
- `lib/features/thai_beta/application/thai_beta_invited_tester_registry.dart` — uid allow-list
- `lib/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart` — auth uid + admin resolution
- `lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart` — audience stream wiring
- `scripts/deploy_web.ps1` — deploy override `invited_beta`

---

## 2. Flag state

| Item | Value |
|------|-------|
| Flag name | `thai_public_evidence_badge_beta` |
| **Current active state** | **`invited_beta`** |
| Rollback state | `off` |
| Internal cohort state | `internal_only` (switch back to re-enable admin-only mode) |
| Invalid / missing | `off` |

### Configuration layers (priority order)

1. **Build-time override:** `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=<state>`
2. **Checked-in activation:** `ThaiEvidenceBadgeActivation.configuredState` = `invited_beta`
3. **Fallback parse:** `off`

### Flag behavior matrix

| State | Badge visible to |
|-------|------------------|
| `off` | nobody |
| `internal_only` | research admin only |
| `invited_beta` | signed-in uid on invited-beta allow-list only |
| missing / invalid | nobody (treated as `off`) |

---

## 3. Invited beta audience rule

| Criterion | Required |
|-----------|----------|
| Feature flag | `invited_beta` |
| Signed in | yes — anonymous blocked |
| On allow-list | yes — `ThaiBetaInvitedTesterRegistry.isInvited(uid)` |
| Research admin (without invite) | **no** — admin does not inherit invited-beta access |

### Admin behavior under `invited_beta`

Research admins **do not** see the badge unless their uid is explicitly on the invited-beta allow-list. `internal_only` and `invited_beta` are separate modes to prevent permission bleed.

To restore admin-only visibility, set flag to `internal_only`.

---

## 4. Allow-list behavior

**Registry:** `ThaiBetaInvitedTesterRegistry`

| Capability | Supported |
|------------|-----------|
| Check by uid | `isInvited(userId)` |
| Signed-in required | yes — `null` uid → not invited |
| Anonymous blocked | yes |
| Normal user not in list blocked | yes |
| Revocable | `revoke(uid)` removes access |
| Test injection | `invite(uid)` / `reset()` |

**Production note:** Current registry is a deterministic in-memory uid set. Firestore-backed registry is **future wiring** — ops must seed uids at startup until Firestore integration lands. Email-based allow-list is not used; uid-only.

---

## 5. Active surface

### Active

| Surface | Route |
|---------|-------|
| `ThaiBetaReportPage` | `/beta/thai` |

### Not active (unchanged)

| Surface | Status |
|---------|--------|
| `ThaiMirrorResultPage` | no badge |
| Home | no badge |
| Daily Mirror | no badge |
| Public profile/result routes | no badge |

---

## 6. Hidden categories

Badge content is LEVEL 1 only:

| Allowed | Forbidden |
|---------|-----------|
| Label: มีแหล่งอ้างอิงใน Canon | Source page reference |
| Caution: ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์ | Source prose |
| | Raw Canon unit id |
| | Ontology id |
| | Evidence count |
| | Confidence % |
| | Remedy |
| | Taksa |
| | Khumsap |
| | ดวงขึ้น / ดวงตก |
| | Lookup table |
| | Conflict / ambiguity detail |

### Eligibility gate (unchanged)

Badge renders only when evidence is `CANON_SUPPORTED` with type `mahabhutPosition` or `planetSignification`, and is not remedy/Taksa/Khumsap/rise-fall/lookup/partial/ambiguous/conflict/internal-only/no-evidence.

---

## 7. Rollback rule

Set `thai_public_evidence_badge_beta = off` via dart-define or clear activation config.

After rollback:

- Invited beta testers → badge hidden
- Admins → badge hidden
- Normal users → badge hidden
- Anonymous → badge hidden

**No rollback required for:** Canon, engine, copy, or public UI.

Re-enable internal admin cohort: set flag to `internal_only`.

---

## 8. Tests / validation result

| Metric | Value |
|--------|------:|
| Thai validation suite | **876 / 876 pass** |
| New invited-beta guard file | `test/validation/thai/thai_public_evidence_badge_invited_beta_implementation_test.dart` |
| Guard coverage | 22 acceptance criteria (audience, surface, copy, leakage, public regression) |

### Guard tests prove

1. Invited beta tester sees badge on `ThaiBetaReportPage`
2. Anonymous blocked
3. Normal signed-in user not on list blocked
4. Admin not on invite list blocked
5. No badge on `ThaiMirrorResultPage`
6. No badge on Home
7. No badge on Daily Mirror
8. `off` hides badge for invited tester
9. `internal_only` still renders for admin only
10. Invalid flag behaves as `off`
11–18. Copy/leakage safety (no page, prose, ids, %, remedy/Taksa/Khumsap/rise-fall, forbidden wording)
19. Public fingerprint unchanged for normal users
20. Consumer Mirror copy unchanged
21. Remedies remain hidden/internal
22. Full Thai validation suite green

---

## 9. Public isolation proof

| Check | Result |
|-------|--------|
| Public Thai fingerprint (normal/anonymous) | **unchanged** |
| Consumer Mirror copy | **unchanged** |
| Remedies | **hidden / internal** |
| Canon | **unchanged** |
| Engine | **unchanged** |
| Prediction copy | **unchanged** |

Badge visibility is gated entirely by flag + audience resolver on `ThaiBetaReportPage`. No badge wiring added to Mirror, Home, or Daily Mirror.

---

## 10. Recommended next phase

**Invited Beta Activation QA**

Run a formal QA pass on the activated `invited_beta` cohort: allow-list seeding verification, real-auth uid checks, copy/leakage audit on production build, and rollback drill under `invited_beta` → `off` → `internal_only`.

**Not authorized in next phase:** public rollout, all-user activation, anonymous access, or badge on additional surfaces.
