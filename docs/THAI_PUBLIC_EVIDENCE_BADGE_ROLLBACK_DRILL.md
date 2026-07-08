# Thai Public Evidence Badge Rollback Drill

**Phase:** Public Evidence Badge Rollback Drill  
**Status:** **COMPLETE**  
**Date:** July 2026  
**Prerequisite commit:** `3523e42` — Public Evidence Badge Internal Only Activation QA  
**Activation source:** [`THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION.md`](THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION.md)  
**Validation artifact:** `tool/output/thai_public_evidence_badge_rollback_drill_summary.json`

---

## 1. Drill objective

Verify the activated internal-only Public Evidence Badge can be **safely disabled** by setting `thai_public_evidence_badge_beta = off` and **safely re-enabled** to `internal_only` without rolling back Canon, engine, copy, report data, Firestore, or public UI.

This is a QA / safety drill only — not a production rollback execution.

---

## 2. Initial state

| Item | State |
|------|-------|
| Feature flag | `internal_only` (active) |
| Research admin on ThaiBetaReportPage | badge visible |
| Normal user | blocked |
| Anonymous user | blocked |
| Invited-beta-only user | blocked |
| Public Thai output | unchanged |

---

## 3. Rollback action

| Method | Value |
|--------|-------|
| Flag state | `off` |
| Dart-define override | `THAI_PUBLIC_EVIDENCE_BADGE_BETA=off` |
| Code config rollback | set `ThaiEvidenceBadgeActivation.configuredState` to `null` |

---

## 4. Rollback result

**Passed — badge hidden for all audiences**

| Audience | Badge after `off` |
|----------|-------------------|
| Research admin | hidden |
| Normal user | hidden |
| Anonymous user | hidden |
| Invited-beta-only user | hidden |

| Surface | After rollback |
|---------|----------------|
| ThaiBetaReportPage | no badge panel |
| ThaiMirrorResultPage | unchanged (no badge) |
| Home | unchanged (no badge) |
| Daily Mirror | unchanged (no badge) |

---

## 5. Re-enable test

**Passed — `internal_only` restored without public leakage**

| Check | Result |
|-------|--------|
| Admin sees badge again on ThaiBetaReportPage | pass |
| Normal user still blocked | pass |
| Anonymous still blocked | pass |
| Invited-beta-only still blocked | pass |
| `invited_beta` not activated | pass |
| Checked-in activation config remains `internal_only` | pass |

---

## 6. Systems not rolled back

Rollback required **flag change only**. No rollback needed for:

| System | Rolled back? |
|--------|--------------|
| Canon dataset | no |
| Evidence mapping | no |
| Engine calculations | no |
| Mirror copy | no |
| Prediction copy | no |
| Thai beta report data | no |
| Firestore data | no |
| Public UI surfaces | no |

Verified: enrichment fingerprint unchanged per fixture before and after Canon attach; flag state changes do not alter pipeline fingerprint.

---

## 7. Safety result

**Passed — 0 leakage violations**

No exposure of:

- Source page / source prose
- Raw Canon unit ids / ontology ids
- Confidence scores
- Remedies / Taksa / Khumsap
- Rise/fall (ดวงขึ้น / ดวงตก)
- Lookup tables / conflict / ambiguity detail

---

## 8. Validation result

| Metric | Value |
|--------|------:|
| Thai validation suite | **857 / 857 pass** |
| Fixtures drilled | **9** |
| Rollback off | **PASS** |
| Re-enable internal_only | **PASS** |
| Fingerprint stable across flag states | **PASS** |
| Systems not rolled back | **PASS** |
| Leakage violations | **0** |

Test file: `test/validation/thai/thai_public_evidence_badge_rollback_drill_test.dart`

---

## 9. Recommended next phase

**Internal Only Activation Freeze**

**Rationale:** Rollback drill passed. The internal-only activation baseline should be frozen before considering invited beta or any broader exposure.

---

**Public Thai output unchanged across `internal_only`, `off`, and re-enabled `internal_only`. Not public release.**
