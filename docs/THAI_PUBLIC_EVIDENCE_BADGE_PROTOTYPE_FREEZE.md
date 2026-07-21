# Thai Public Evidence Badge Prototype Freeze

**Phase:** Public Evidence Badge Prototype Freeze  
**Status:** **FROZEN / INTERNAL BETA ONLY**  
**Freeze date:** July 2026  
**Prerequisite commit:** `96c7f67` — Public Evidence Disclosure Policy Freeze  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)  
**QA artifact:** `tool/output/thai_public_evidence_badge_qa_summary.json`

---

## 1. Freeze declaration

**Public Evidence Badge Prototype is frozen as INTERNAL BETA ONLY.**

This freeze ratifies the official LEVEL 1 preview baseline — model, mapper, internal page, route, policy compliance checks, and QA validator — as completed internal beta infrastructure.

**No public release is authorized.**

Public evidence display on consumer Thai surfaces remains forbidden. Controlled beta rollout has not started.

---

## 2. Final validation state

Verified from repository data (`tool/output/thai_public_evidence_badge_qa_summary.json`) and `flutter test test/validation/thai/` on freeze date:

| Metric | Value | Source |
|--------|------:|--------|
| Thai validation suite | **716 / 716 pass** | `test/validation/thai/` |
| Fixtures audited | **9** | `qa_sample`, `harness_a` … `harness_h` |
| Eligible internal previews (aggregate) | **91** | QA JSON `totalEligiblePreviews` |
| Eligibility violations | **0** | QA JSON `totalEligibilityViolations` |
| Copy safety violations | **0** | QA JSON `totalCopySafetyViolations` |
| Data leakage violations | **0** | QA JSON `totalDataLeakageViolations` |
| Route isolation | **passed** | QA tests + public page import checks |
| Public output regression | **passed** | QA JSON `publicFingerprintUnchanged: true` |
| Remedies hidden per fixture | **87** | QA hidden summary |
| Remedy report attachments | **0** | Integration freeze baseline |
| Remedies hidden flag | **true** | QA JSON `remediesHidden` |
| Overall QA audit | **passed** | QA JSON `overallPassed: true` |

---

## 3. Frozen preview route

| Item | Value |
|------|-------|
| Route | `/internal/thai-public-evidence-preview` |
| Guard | `ThaiResearchAdminGuard` |
| Linked from | `/internal/thai-canon-evidence` (preview icon only) |
| Public Thai result pages | **No import** |
| `ThaiBetaReportPage` | **No import** |
| `ThaiMirrorResultPage` | **No import** |
| Home | **No import** |
| Daily Mirror | **No import** |

---

## 4. Frozen eligibility rule

**Only LEVEL 1 preview badges are supported.**

### May produce preview badge

| Requirement | Rule |
|-------------|------|
| Internal badge | `CANON_SUPPORTED` only |
| Evidence domain | `mahabhutPosition` or `planetSignification` |
| Disclosure level | `LEVEL_1_PUBLIC_SUMMARY_BADGE` |
| Preview flag | `internalOnlyPreview = true` |

### Explicitly excluded (never produce preview badge)

| Category | Block reason |
|----------|--------------|
| Khumsap | `khumsap_hidden` |
| Taksa | `taksa_hidden` |
| Rise/fall (ดวงขึ้น / ดวงตก) | `rise_fall_hidden` |
| Remedies | `remedy_hidden` |
| Lookup tables | `lookup_table_hidden` |
| `RUNTIME_METADATA_SUPPORTED` | internal badge block |
| `CANON_DERIVED_INTERNAL` | internal badge block |
| `PARTIAL_CANON_SUPPORT` | internal badge block |
| `OUT_OF_CANON_SCOPE` | internal badge block |
| `BLOCKED_AMBIGUOUS` | internal badge block |
| `BLOCKED_SOURCE_CONFLICT` | internal badge block |
| `INTERNAL_ONLY` | internal badge block |
| `REMEDY_HIDDEN` | never public |
| `NO_CANON_EVIDENCE` | internal badge block |

---

## 5. Frozen safe wording

### Allowed badge labels

- มีแหล่งอ้างอิงใน Canon
- อ้างอิงจากฐานความรู้ที่ตรวจแล้ว
- ตรวจสอบกับ Canon แล้ว
- มีหลักฐานอ้างอิงภายในระบบ

### Required caution copy (every eligible badge)

> ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์

Negated `การันตี` in caution copy is policy-approved.

---

## 6. Frozen forbidden display

The prototype does **not** show:

| Forbidden | Status |
|-----------|--------|
| Page references | not shown |
| Source prose | not shown |
| OCR recovery text | not shown |
| Scanned images | not shown |
| Raw Canon unit ids | not shown |
| Raw ontology ids | not shown |
| Confidence percentages | not shown |
| Remedy text | not shown |
| Taksa output | not shown |
| Khumsap output | not shown |
| ดวงขึ้น / ดวงตก | not shown |
| Conflict details as advice | not shown |
| Ambiguity details as advice | not shown |

Hidden category summary shows **counts only** — no unsafe detail.

---

## 7. Frozen boundaries

Mandatory boundaries for all work after this freeze:

- Badge is **traceability indicator only**
- Badge is **not** an accuracy guarantee
- Badge is **not** a confidence score
- Badge is **not** prediction certainty
- Badge is **not** advice
- Prototype is **internal beta only**
- Public implementation requires a **separate approved phase** (Controlled Beta Plan or later)

---

## 8. Frozen stack (10 components)

| # | Component | Path |
|---|-----------|------|
| 1 | Public Evidence Badge Preview model | `thai_public_evidence_badge_preview.dart` |
| 2 | Public Evidence Badge Preview mapper | `thai_public_evidence_badge_preview_mapper.dart` |
| 3 | Internal preview page | `thai_public_evidence_badge_preview_page.dart` |
| 4 | Internal preview route | `thai_canon_evidence_routes.dart` |
| 5 | Policy compliance checks | Mapper + `ThaiPublicEvidenceBadgeCopy` |
| 6 | Badge QA validator | `thai_public_evidence_badge_qa_validator.dart` |
| 7 | Badge QA report | `thai_public_evidence_badge_qa_report.dart` |
| 8 | Public route isolation | QA tests + route guard |
| 9 | Public fingerprint regression | `ThaiReportCanonEvidenceEnricher.userFacingFingerprint` |
| 10 | Hidden category summary | `ThaiPublicEvidenceBadgeHiddenSummary` |

---

## 9. Retained risks

| Risk | Status |
|------|--------|
| Public release | **Not authorized** |
| LEVEL 2 / LEVEL 3 | **Not implemented** |
| Taksa / Khumsap / rise-fall public display | **Forbidden** |
| Remedies | **Hidden** (87/fixture) |
| Sunday Taksa partial | Internal only |
| `planet.ketu` unmapped | Internal only |
| Public copy UX review | **Required before any rollout** |

---

## 10. Post-freeze rules

Future work must use an **explicit approved phase**. Silent changes are forbidden.

| Approved future phase | Scope |
|-----------------------|-------|
| Public Evidence Badge Controlled Beta Plan | Rollout audience, gating, rollback, metrics |
| Public Evidence Badge UX Review | Consumer-facing copy review |
| Public Evidence Badge Rollback Plan | Feature-flag disable path |
| Public Source Page Reference Policy | LEVEL 2 governance |
| Remedy Safety / Presentation Policy | Remedy exposure rules |
| Public Evidence Badge Prototype V2 | Major prototype revision |

**No silent changes** to eligibility rules, safe wording, or public surfaces.

**No controlled beta rollout without approved plan.**

---

## 11. Recommended next phase

**Public Evidence Badge Controlled Beta Plan**

**Rationale:** The policy and prototype are now frozen. Before implementation on any user-visible beta surface, a controlled rollout plan is required to define audience, gating, rollback, metrics, and safety checks.

**Do not implement rollout in this commit.**

---

## Related

- [`THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_INTERNAL_BETA.md`](THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_INTERNAL_BETA.md) — prototype implementation record
- [`THAI_PUBLIC_EVIDENCE_BADGE_QA.md`](THAI_PUBLIC_EVIDENCE_BADGE_QA.md) — formal QA record
- [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md) — frozen disclosure policy
- [`THAI_CANON_INTEGRATION_FREEZE.md`](THAI_CANON_INTEGRATION_FREEZE.md) — internal integration baseline
