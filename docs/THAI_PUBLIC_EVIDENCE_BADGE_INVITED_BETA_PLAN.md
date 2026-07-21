# Thai Public Evidence Badge Invited Beta Plan

**Phase:** Controlled Beta Activation — Invited Beta Plan  
**Status:** **DRAFTED** (plan only — not implemented)  
**Date:** July 2026  
**Prerequisite commit:** `83ca191` — Public Evidence Badge Internal Only Activation Freeze  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)  
**Freeze source:** [`THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION_FREEZE.md`](THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION_FREEZE.md)

---

## 1. Plan declaration

**This is a plan only.**

**Invited beta is not active yet.**

This document defines how to extend the frozen internal-only activation to a **limited invited beta audience** on Thai Beta Research Result — without public rollout, without new surfaces, and without changing Canon, engine, or consumer copy.

No feature flag change is authorized by this document.

---

## 2. Current state

| Item | State |
|------|-------|
| Feature flag active value | `internal_only` |
| `invited_beta` | **inactive** |
| Public release | **inactive** |
| Active audience | research admins only |
| Active surface | `ThaiBetaReportPage` (`/beta/thai`) |
| Normal / anonymous / invited-beta-only users | badge **hidden** |
| Rollback drill | **PASS** (`1e01fee`) |
| Internal-only activation freeze | **FROZEN** (`83ca191`) |
| Thai validation suite | **857 / 857 pass** |
| Public Thai output | **unchanged** for non-admin users |

---

## 3. Invited beta audience

### Who qualifies

| Criterion | Required |
|-----------|----------|
| Explicitly invited | yes — on allow-list only |
| Authenticated (signed in) | yes |
| On invited-beta registry | yes (`ThaiBetaInvitedTesterRegistry` / future Firestore-backed list) |
| Research admin | no — admins already covered under `internal_only` |

### Who is excluded

| Audience | Invited beta badge |
|----------|-------------------|
| Anonymous users | **no** |
| Normal signed-in public users | **no** |
| Users not on invite list | **no** |
| All-user / premium rollout | **forbidden** |

### Audience model rules (frozen gate design)

| Flag state | Internal tester (admin) | Invited beta tester | Anonymous / normal |
|------------|-------------------------|---------------------|---------------------|
| `internal_only` (current) | yes | **no** | no |
| `invited_beta` (future) | **no** | yes | no |

**Note:** Under `invited_beta`, research admins do **not** receive the badge unless they are also on the invited-beta allow-list. Internal admin access remains available by switching flag back to `internal_only` or running parallel internal cohort separately.

Invites must be **identifiable and revocable** (remove uid from allow-list → badge disappears on next session).

---

## 4. Feature flag plan

**Flag name:** `thai_public_evidence_badge_beta`

| State | Current | Future invited phase |
|-------|---------|----------------------|
| `off` | rollback | rollback (unchanged) |
| `internal_only` | **active now** | inactive when invited beta starts |
| `invited_beta` | **inactive** | active for invited phase only |
| missing / invalid | `off` | `off` (unchanged) |

### Activation sequence (future — not this commit)

1. Complete implementation gates (Section 12)
2. Run invited-beta QA on deterministic fixtures
3. Set `ThaiEvidenceBadgeActivation.configuredState` to `invited_beta` **or** deploy with `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=invited_beta`
4. Monitor safety metrics (Section 8)
5. Stop immediately if any stop criterion triggers (Section 10)

### Configuration layers (unchanged from internal-only)

1. `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=<state>`
2. `ThaiEvidenceBadgeActivation.configuredState`
3. Parse fallback → `off`

---

## 5. Allowed surface

### Allowed (exactly one)

| Surface | Route | Condition |
|---------|-------|-----------|
| `ThaiBetaReportPage` | `/beta/thai` | flag `invited_beta` + invited audience |

### Forbidden (unchanged from freeze)

| Surface | Status |
|---------|--------|
| `ThaiMirrorResultPage` | forbidden |
| Home | forbidden |
| Daily Mirror | forbidden |
| Public profile/result routes | forbidden |
| Other astrology result pages | forbidden |
| All non-beta routes | forbidden |

Public route imports must not pull beta badge UI into consumer surfaces.

---

## 6. Badge content

### Allowed (LEVEL 1 — frozen from policy)

| Element | Content |
|---------|---------|
| Badge label | **มีแหล่งอ้างอิงใน Canon** |
| Caution copy | ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์ |

### Eligible evidence (unchanged)

- `CANON_SUPPORTED` only
- `mahabhutPosition` or `planetSignification` only

---

## 7. Hidden / forbidden content

Must **not** display during invited beta:

| Category | Status |
|----------|--------|
| Source page | forbidden |
| Source prose / OCR text | forbidden |
| Raw Canon unit id | forbidden |
| Raw ontology id | forbidden |
| Confidence score / % | forbidden |
| Evidence count | forbidden |
| Remedies | forbidden |
| Taksa | forbidden |
| Khumsap | forbidden |
| Rise/fall (ดวงขึ้น / ดวงตก) | forbidden |
| Lookup table cells | forbidden |
| Conflict / ambiguity detail | forbidden |

### Forbidden certainty wording (badge labels)

แม่นแน่นอน, ยืนยันว่าแม่น, ฟันธง, พิสูจน์แล้ว, 100%, การันตี, แน่นอน (except negated `ไม่ใช่การการันตีผลลัพธ์` in caution copy)

---

## 8. Safety metrics

Measure after invited beta activation (qualitative + counts only — no Canon ids, no birth data in logs):

| Metric | What we measure | Success signal |
|--------|-----------------|----------------|
| Traceability understanding | “badge = ที่มาของการวิเคราะห์” vs “แม่นแน่นอน” | Majority traceability, minority guarantee |
| Overconfidence | Users associate badge with certainty | Low “การันตี / ฟันธง” interpretation |
| Remedy demand | Users ask for remedy / ritual advice after seeing badge | No increase vs pre-badge baseline |
| Source prose demand | Users ask for book page / full Canon text | No increase |
| Felt over-determinism | “ผลดูฟันธงเกินไป” | Low confusion reports |
| Confusion reports | Misunderstanding of badge purpose | Near zero; actionable if any |
| Technical leakage | QA fixture violations | **0** |
| Audience leakage | Normal user sees badge | **0** |
| Rollback readiness | Flag `off` hides badge within one deploy | Verified in drill |

Telemetry (if enabled): existing stub events only — `thai_evidence_badge_rendered`, `thai_evidence_badge_seen`, `thai_evidence_badge_feedback_started` with `sectionId` only.

---

## 9. Feedback questions

Thai-language questions for invited beta feedback (via existing Thai Beta feedback flow or dedicated prompt):

1. คุณเข้าใจ badge นี้ว่าอย่างไร?
2. คุณคิดว่า badge นี้หมายถึง “แม่นแน่นอน” หรือไม่?
3. badge นี้ช่วยให้คุณไว้ใจที่มาของการวิเคราะห์มากขึ้นไหม?
4. badge นี้ทำให้ผลดูฟันธงเกินไปไหม?
5. มีส่วนไหนที่ทำให้คุณเข้าใจผิดไหม?

Optional follow-ups (internal review only):

- คุณคาดหวังให้เห็นข้อความจากตำราเพิ่มเติมไหม?
- คุณคาดหวังให้เห็นคำแนะนำแก้ดวงไหม?

---

## 10. Stop criteria

**Stop invited beta immediately** (set flag to `off`) if any occur:

| Trigger | Action |
|---------|--------|
| Badge appears on `ThaiMirrorResultPage`, Home, Daily Mirror, or public routes | **stop + incident review** |
| Remedy content visible to invited users | **stop** |
| Source prose or page reference visible | **stop** |
| Raw Canon / ontology id visible | **stop** |
| Majority interpret badge as “การันตีความแม่น” | **stop + copy review** |
| Forbidden certainty wording in badge UI | **stop** |
| `flutter test test/validation/thai/` regression fail | **stop** |
| Public fingerprint regression | **stop** |
| Normal (non-invited) user sees badge | **stop** |
| Taksa / Khumsap / rise-fall content leaks | **stop** |

---

## 11. Rollback plan

**Rollback = set `thai_public_evidence_badge_beta` to `off`**

Proven by rollback drill (`1e01fee`):

| After `off` | Result |
|-------------|--------|
| Research admin | badge hidden |
| Invited beta tester | badge hidden |
| Normal / anonymous user | badge hidden |
| Canon rollback | **not required** |
| Engine rollback | **not required** |
| Mirror / prediction copy rollback | **not required** |
| Public UI rollback | **not required** |
| Validation suite | must remain green |

Methods: `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`, or set `ThaiEvidenceBadgeActivation.configuredState` to `null` and redeploy.

Re-enable internal-only cohort: set flag to `internal_only` (proven in rollback drill).

---

## 12. Required implementation gates

Before activating `invited_beta`, all gates must pass:

| Gate | Requirement |
|------|-------------|
| Invited allow-list | Registry populated; revocable uids; tests for add/remove |
| Feature flag | `invited_beta` renders only for `ThaiBetaEvidenceBadgeAudience.invitedBetaTester()` |
| Public isolation | Normal / anonymous / admin-without-invite blocked |
| Surface isolation | Badge only on `ThaiBetaReportPage`; import audits green |
| No leakage | 9-fixture QA; 0 eligibility/copy/leakage violations |
| Rollback | `off` hides badge for all audiences; re-enable tested |
| Feedback logging | Plan for Thai feedback questions; no Canon ids in logs |
| Full Thai validation | `flutter test test/validation/thai/` green |

**Do not implement invited beta in this plan commit.**

---

## 13. Recommended next phase

**Controlled Beta Activation — Invited Beta Implementation**

**Rationale:** This plan defines audience, flag, surface, safety, and stop criteria. The next step is to implement invited-beta registry wiring, tests, and QA infrastructure — still without enabling the flag until a dedicated activation commit.

**Do not implement in this commit.**

---

## References

- [`THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION_FREEZE.md`](THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION_FREEZE.md)
- [`THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION_QA.md`](THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION_QA.md)
- [`THAI_PUBLIC_EVIDENCE_BADGE_ROLLBACK_DRILL.md`](THAI_PUBLIC_EVIDENCE_BADGE_ROLLBACK_DRILL.md)
- [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)

---

**Invited beta not active. Public release not authorized. Internal-only activation remains frozen baseline.**
