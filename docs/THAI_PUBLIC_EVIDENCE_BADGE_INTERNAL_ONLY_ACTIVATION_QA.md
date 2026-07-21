# Thai Public Evidence Badge Internal Only Activation QA

**Phase:** Public Evidence Badge Internal Only Activation QA  
**Status:** **COMPLETE**  
**Date:** July 2026  
**Prerequisite commit:** `07eb72d` — Public Evidence Badge Internal Only Activation  
**Activation source:** [`THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION.md`](THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION.md)  
**Validation artifact:** `tool/output/thai_public_evidence_badge_internal_only_activation_qa_summary.json`

---

## 1. QA scope

Formal QA pass verifying the **activated** `internal_only` badge does not leak beyond research admins on Thai Beta Research Result.

- Active flag: `thai_public_evidence_badge_beta` = **`internal_only`**
- Not public rollout
- Not invited beta
- Deterministic fixtures only — no Firestore, network, or current-date dependency

---

## 2. Activation state QA result

**Passed**

| Check | Result |
|-------|--------|
| `ThaiEvidenceBadgeActivation.configuredState` | `internal_only` |
| `applyConfiguredState()` resolves to `internalOnly` | pass |
| `invited_beta` not active | pass |

---

## 3. Audience isolation QA result

**Passed**

| Audience | Badge visible under `internal_only` |
|----------|-------------------------------------|
| Research admin / internal tester | **yes** (ThaiBetaReportPage only) |
| Anonymous user | **no** |
| Normal signed-in user | **no** |
| Invited-beta-only user | **no** |

---

## 4. Surface isolation QA result

**Passed**

| Surface | Badge renders |
|---------|---------------|
| `ThaiBetaReportPage` (admin + flag) | yes |
| `ThaiMirrorResultPage` | no |
| Home | no |
| Daily Mirror | no |
| `thai_mirror_routes.dart` | no import |
| `thai_beta_routes.dart` | no panel import on public path |
| Other non-beta routes | no |

---

## 5. Data leakage QA result

**Passed — 0 violations across 9 fixtures**

Beta badge output does not contain:

- Source page references
- Source prose
- Raw Canon unit ids
- Raw ontology ids
- Confidence percentages
- Remedy, Taksa, Khumsap, rise/fall, or lookup table content

---

## 6. Rollback QA result

**Passed**

| Step | Result |
|------|--------|
| Set flag to `off` | badge hidden for internal tester |
| Canon rollback required | no |
| Engine rollback required | no |
| Copy rollback required | no |
| Validation suite | green |

---

## 7. Public output regression result

**Passed**

| Check | Result |
|-------|--------|
| Public Thai fingerprint unchanged | pass |
| Consumer Mirror copy unchanged (non-internal path) | pass |
| Remedies hidden/internal | pass |
| All evidence `userFacingAllowed = false` | pass |

---

## 8. Fixtures audited

| Fixture | Eligible beta badges | QA passed |
|---------|---------------------:|-----------|
| qa_sample | 19 | yes |
| harness_a | 12 | yes |
| harness_b | 12 | yes |
| harness_c | 7 | yes |
| harness_d | 13 | yes |
| harness_e | 8 | yes |
| harness_f | 8 | yes |
| harness_g | 8 | yes |
| harness_h | 4 | yes |
| **Aggregate** | **91** | **yes** |

---

## 9. Validation summary

| Metric | Value |
|--------|------:|
| Thai validation suite | **836 / 836 pass** |
| Overall activation QA | **PASS** |
| Eligibility violations | **0** |
| Copy safety violations | **0** |
| Data leakage violations | **0** |

---

## 10. Remaining risks

| Risk | Severity |
|------|----------|
| Accidental flag set to `invited_beta` or global on | medium |
| Admin misclassified in `admins/{uid}` registry | low |
| Future surface expansion without re-QA | medium |
| Deploy rollback not applied during incident | low |

---

## 11. Recommended next phase

**Rollback Drill**

Rationale: Activation QA passed with zero leakage violations. The next safest operational step is to validate the documented rollback path (`off` via config or dart-define) under controlled conditions before any invited-beta expansion.

---

**Public Thai output unchanged for non-admin users. Internal-only activation verified. Not public release.**
