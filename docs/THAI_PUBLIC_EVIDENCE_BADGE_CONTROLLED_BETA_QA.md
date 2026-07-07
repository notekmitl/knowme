# Thai Public Evidence Badge Controlled Beta QA

**Phase:** Public Evidence Badge Controlled Beta QA  
**Status:** **COMPLETE**  
**Date:** July 2026  
**Prerequisite commit:** `7968504` — Public Evidence Badge Controlled Beta Implementation  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)  
**Validation artifact:** `tool/output/thai_public_evidence_badge_controlled_beta_qa_summary.json`

---

## 1. QA scope

Formal QA and safety validation pass for the controlled beta implementation **before any flag is enabled for testers**.

- Feature flag: `thai_public_evidence_badge_beta` — default **off**
- Allowed states: `off`, `internal_only`, `invited_beta`
- Surface: **ThaiBetaReportPage** (Thai Beta Research Result) only
- Policy level: **LEVEL 1 — PUBLIC_SUMMARY_BADGE** only
- No public release, no global rollout, no default flag change
- Deterministic fixtures only — no Firestore, network, or current-date dependency

**Not in scope for this QA:**

- Enabling the flag for testers
- Adding badges to ThaiMirrorResultPage, Home, or Daily Mirror
- Canon data changes, engine changes, or copy changes

---

## 2. Feature flag QA result

**Passed — 10/10 checks**

| Check | Result |
|-------|--------|
| Missing flag → off | pass |
| Invalid flag → off | pass |
| `off` → no badges anywhere | pass |
| `internal_only` → badge only for internal tester on Thai Beta Research Result | pass |
| `invited_beta` → badge only for invited beta on Thai Beta Research Result | pass |
| `internal_only` does not render for normal users | pass |
| `invited_beta` does not render for normal users | pass |
| `invited_beta` does not render for internal-only audience | pass |
| Flag can be turned off and badge disappears | pass |
| Default state remains off | pass |

---

## 3. Audience gating QA result

**Passed**

| Audience | `internal_only` | `invited_beta` |
|----------|-----------------|----------------|
| Anonymous / normal user | blocked | blocked |
| Internal tester | allowed | blocked |
| Invited beta tester | blocked | allowed |

Audience model enforces strict separation — internal testers do not receive invited-beta badges unless explicitly in the invited-beta audience.

---

## 4. Surface isolation QA result

**Passed**

| Surface | Badge renders |
|---------|---------------|
| ThaiBetaReportPage (when flag + audience allow) | yes |
| ThaiMirrorResultPage | no |
| Home (`home_page.dart`) | no |
| Daily Mirror (`daily_mirror_section.dart`) | no |
| Public profile/result routes | no |
| Other astrology result pages | no |

Static import audit confirms public routes do not import `ThaiBetaEvidenceBadgePanel` or `ThaiPublicEvidenceBadgeBeta*`.

---

## 5. Badge eligibility QA result

**Passed — 0 violations across 9 fixtures**

Only `CANON_SUPPORTED` + `mahabhutPosition` / `planetSignification` produce beta badges (91 total across fixtures).

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
| Lookup table evidence | blocked |

Beta badge label is fixed: **มีแหล่งอ้างอิงใน Canon**

---

## 6. Copy safety QA result

**Passed — 0 violations**

- Required badge label: `มีแหล่งอ้างอิงใน Canon`
- Required caution copy on every badge panel:
  > ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์
- Forbidden certainty wording absent from **badge labels**
- Negated `การันตี` in caution copy is policy-approved (not a violation)

---

## 7. Data leakage QA result

**Passed — 0 violations**

Beta badge output does not contain:

- Source page references
- Source prose / OCR text
- Raw Canon unit ids
- Raw ontology ids
- Raw evidence refs
- Confidence scores / percentages
- Remedy, Taksa, Khumsap, rise/fall, or lookup table content
- Conflict or ambiguity detail

---

## 8. Telemetry safety QA result

**Passed — local/stub only**

Allowed event names only:

- `thai_evidence_badge_rendered`
- `thai_evidence_badge_seen`
- `thai_evidence_badge_feedback_started`

Telemetry props limited to `sectionId` — no Canon ids, source pages, remedy data, birth data, or prediction content.

**Production analytics:** not enabled (`ThaiEvidenceBadgeBetaTelemetry.onEvent` defaults to null).

---

## 9. Rollback QA result

**Passed**

1. Set flag to `off` → badge disappears from Thai Beta Research Result
2. No Canon rollback required
3. No engine rollback required
4. No copy rollback required
5. Thai validation suite remains green (791/791)
6. Public fingerprint unchanged

---

## 10. Public output regression result

**Passed**

| Check | Result |
|-------|--------|
| ThaiMirrorPipeline user-facing fingerprint unchanged when flag is off | pass |
| Consumer Mirror copy unchanged | pass |
| ThaiBetaReportPage without flag unchanged | pass |
| ThaiMirrorResultPage unchanged | pass |
| Remedies remain hidden/internal | pass |
| All evidence `userFacingAllowed = false` internally | pass |
| No public page shows source/evidence details | pass |

---

## 11. Remaining risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Flag accidentally enabled globally before freeze | medium | Default remains `off`; QA documents gate matrix; freeze phase next |
| Invited tester registry misconfiguration | low | Registry is explicit; anonymous always blocked |
| Future surface expansion without re-QA | medium | Surface isolation tests + import audits in CI |
| Telemetry hook wired to production without review | low | Stub-only default; production flag documented as false |
| Badge panel layout with many eligible sections | low | Constrained scroll panel (maxHeight 240) on ThaiBetaReportPage |

---

## 12. Recommended next phase

**Public Evidence Badge Controlled Beta Freeze**

Rationale: QA passed with 0 violations across flag, audience, surface, eligibility, copy, leakage, telemetry, rollback, and regression dimensions. The implementation is ready to be frozen as the controlled-beta baseline before any tester flag enablement.

---

## Fixtures audited

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

## Test coverage

Formal QA test file: `test/validation/thai/thai_public_evidence_badge_controlled_beta_qa_test.dart`

QA infrastructure:

- `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_validator.dart`
- `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_runner.dart`
- `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_report.dart`

Thai validation suite: **791 / 791 pass**

---

**Public Thai output unchanged when flag is off. Public evidence badge is NOT released to all users.**
