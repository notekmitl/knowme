# Thai Public Evidence Badge QA

**Phase:** Public Evidence Badge QA  
**Status:** **COMPLETE**  
**Date:** July 2026  
**Prerequisite commit:** `6de399f` — Public Evidence Badge Prototype Internal Beta  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md)  
**Validation artifact:** `tool/output/thai_public_evidence_badge_qa_summary.json`

---

## 1. QA scope

Formal QA pass for the internal beta LEVEL 1 public evidence badge preview at:

`/internal/thai-public-evidence-preview`

- Policy level validated: **LEVEL 1 — PUBLIC_SUMMARY_BADGE** only
- No LEVEL 2 (page references)
- No LEVEL 3 (explanation with evidence)
- No public release
- Deterministic fixtures only — no Firestore, network, or current-date dependency

---

## 2. Fixtures audited

| Fixture | Eligible previews | QA passed |
|---------|------------------:|-----------|
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

## 3. Eligibility audit result

**Passed — 0 violations**

Only `CANON_SUPPORTED` + `mahabhutPosition` / `planetSignification` produce LEVEL 1 previews.

Verified never eligible:

| Category | Result |
|----------|--------|
| RUNTIME_METADATA_SUPPORTED | blocked |
| CANON_DERIVED_INTERNAL | blocked |
| PARTIAL_CANON_SUPPORT | blocked |
| OUT_OF_CANON_SCOPE | blocked |
| BLOCKED_AMBIGUOUS | blocked |
| BLOCKED_SOURCE_CONFLICT | blocked |
| INTERNAL_ONLY | blocked |
| REMEDY_HIDDEN | blocked |
| NO_CANON_EVIDENCE | blocked |
| Taksa evidence | blocked |
| Khumsap evidence | blocked |
| Rise/Fall evidence | blocked |
| Lookup table evidence | blocked (`lookup_table_hidden`) |

---

## 4. Copy safety audit result

**Passed — 0 violations**

- Every eligible preview includes required caution copy:
  > ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์
- Badge labels use only policy-approved LEVEL 1 wording
- Forbidden certainty wording absent from **badge labels**
- Negated `การันตี` in caution copy is policy-approved (not a violation)

---

## 5. Data leakage audit result

**Passed — 0 violations**

Preview output verified free of:

- source prose
- page references (`pNN`)
- raw Canon unit ids
- raw ontology ids
- confidence percentages
- ดวงขึ้น / ดวงตก labels
- remedy / Taksa / Khumsap public copy

---

## 6. Internal route isolation result

**Passed**

| Check | Result |
|-------|--------|
| Route under `/internal` | yes |
| `ThaiResearchAdminGuard` | yes |
| `ThaiBetaReportPage` imports preview | **no** |
| `ThaiMirrorResultPage` imports preview | **no** |
| `HomePage` imports preview | **no** |
| Daily Mirror imports preview | **no** |

---

## 7. Public output regression result

**Passed**

| Check | Result |
|-------|--------|
| `userFacingFingerprint` unchanged (9 fixtures) | yes |
| Consumer Mirror copy unchanged | yes |
| No public badge text in consumer widgets | yes |
| All evidence `userFacingAllowed = false` | yes |
| Remedies hidden (87 / fixture, 0 report attachments) | yes |
| Thai validation suite | **716 / 716 pass** |

---

## 8. Hidden category summary result

**Passed — counts only, no unsafe detail**

Aggregate hidden counts (9 fixtures):

| Category | Count |
|----------|------:|
| Hidden remedies | 783 |
| Hidden Taksa | 945 |
| Hidden Khumsap | 112 |
| Hidden rise/fall | 140 |
| Blocked ambiguous | 18 |
| Blocked source conflict | 9 |
| Out of Canon scope | 99 |

No remedy text, Taksa rotation output, Khumsap public copy, or source-conflict advice displayed.

---

## 9. Remaining risks

| Risk | Status |
|------|--------|
| Public release without policy freeze | **Blocked** — not authorized |
| LEVEL 2 page references | Not implemented — risk contained |
| Taksa/Khumsap/rise-fall public display | Forbidden by policy |
| Negated `การันตี` in caution copy | Accepted — required disclaimer wording |
| Sunday Taksa partial source | Internal only — not in preview |
| `planet.ketu` unmapped | Internal only — not in preview |

---

## 10. Recommended next phase

**Public Evidence Disclosure Policy Freeze**

Rationale: QA confirms the internal beta prototype complies with the drafted disclosure policy at LEVEL 1. Freezing the policy establishes the governance baseline before any further public-evidence work.

**Do not implement public display without policy freeze and approved implementation phase.**

---

## Implementation

| File | Role |
|------|------|
| `thai_public_evidence_badge_qa_runner.dart` | 9-fixture QA runner |
| `thai_public_evidence_badge_qa_validator.dart` | Eligibility, copy, leakage audits |
| `thai_public_evidence_badge_qa_report.dart` | JSON report serializer |
| `thai_public_evidence_badge_qa_test.dart` | Formal QA test suite |

---

## Related

- [`THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_INTERNAL_BETA.md`](THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_INTERNAL_BETA.md)
- [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md)
- [`THAI_CANON_INTEGRATION_FREEZE.md`](THAI_CANON_INTEGRATION_FREEZE.md)
