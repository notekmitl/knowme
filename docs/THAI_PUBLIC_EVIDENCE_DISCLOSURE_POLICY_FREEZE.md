# Thai Public Evidence Disclosure Policy Freeze

**Phase:** Public Evidence Disclosure Policy Freeze  
**Status:** **FROZEN**  
**Freeze date:** July 2026  
**Prerequisite commit:** `6675ae2` — Public Evidence Badge QA  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md)  
**QA artifact:** `tool/output/thai_public_evidence_badge_qa_summary.json`

---

## 1. Freeze declaration

**Public Evidence Disclosure Policy is frozen.**

This freeze ratifies the official rule set governing **any future** public Canon evidence display in KnowMe Thai surfaces.

**No public evidence display is implemented or authorized by this freeze.**

Current state remains:

- All evidence rows: `userFacingAllowed = false`
- Internal preview only: `/internal/thai-public-evidence-preview` (admin-guarded, beta only)
- Public Thai report fingerprint: unchanged
- LEVEL 1 is **not** public — internal beta prototype only
- LEVEL 2 and LEVEL 3: policy-defined, **not implementation-authorized**

---

## 2. Final QA record

Verified by `flutter test test/validation/thai/` and `ThaiPublicEvidenceBadgeQaRunner` on freeze date:

| Metric | Value | Source |
|--------|------:|--------|
| Thai validation suite | **716 / 716 pass** | `test/validation/thai/` |
| Fixtures audited | **9** | `qa_sample`, `harness_a` … `harness_h` |
| Eligibility QA violations | **0** | QA JSON `totalEligibilityViolations` |
| Copy safety QA violations | **0** | QA JSON `totalCopySafetyViolations` |
| Data leakage QA violations | **0** | QA JSON `totalDataLeakageViolations` |
| Route isolation QA | **pass** | Internal route + no public imports |
| Public output regression | **pass** | Fingerprint + Mirror copy unchanged |
| Eligible LEVEL 1 previews (aggregate) | **91** | QA JSON `totalEligiblePreviews` |
| Remedies hidden per fixture | **87** | QA hidden summary |
| Remedy report attachments | **0** | Integration freeze baseline |
| Overall QA audit | **passed** | QA JSON `overallPassed: true` |

---

## 3. Frozen disclosure levels

| Level | Name | Status after freeze |
|-------|------|---------------------|
| **0** | INTERNAL_ONLY | **Current default** — all evidence, remedies, blockers, Taksa, Khumsap, rise/fall |
| **1** | PUBLIC_SUMMARY_BADGE | **Only level eligible** for a future controlled implementation phase |
| **2** | PUBLIC_SOURCE_PAGE_REFERENCE | Policy-defined — **not implementation-authorized** |
| **3** | PUBLIC_EXPLANATION_WITH_EVIDENCE | Policy-defined — **not implementation-authorized** |

**Only LEVEL 1 may be considered** for a later controlled prototype or beta rollout.

**LEVEL 2 / LEVEL 3 require separate approved phases** with additional gates beyond this freeze.

---

## 4. Frozen allowed LEVEL 1 wording

### Allowed badge style (soft traceability)

- มีแหล่งอ้างอิงใน Canon
- อ้างอิงจากฐานความรู้ที่ตรวจแล้ว
- ตรวจสอบกับ Canon แล้ว
- มีหลักฐานอ้างอิงภายในระบบ

### Required caution copy (every LEVEL 1 badge)

> ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์

LEVEL 1 must **not** include page references, source prose, raw ids, or confidence scores.

---

## 5. Frozen forbidden wording

Public evidence UI must **not** use:

| Forbidden | Reason |
|-----------|--------|
| แม่นแน่นอน | Implies certainty |
| ยืนยันว่าแม่น | Implies accuracy guarantee |
| ฟันธง | Implies certainty |
| พิสูจน์แล้ว | Implies proof |
| 100% | Implies certainty |
| ต้องทำ | Implies instruction |
| ห้ามทำ | High-stakes prohibition |
| โชคร้ายแน่นอน | Implies certainty |
| แก้แล้วดีขึ้นแน่นอน | Implies outcome guarantee |
| การันตี | Implies guarantee (standalone) |
| แน่นอน | Implies certainty |

### Exception (frozen)

The required caution copy may contain a **negated** form such as:

> ไม่ใช่การการันตีผลลัพธ์

This is policy-approved disclaimer wording — not a violation.

---

## 6. Frozen eligibility matrix

Maps internal badge categories to public eligibility under this frozen policy:

| Internal badge | Public eligibility | Notes |
|----------------|-------------------|-------|
| `CANON_SUPPORTED` | **Eligible for future LEVEL 1 only** | Mahabhut position / planet signification only; no Khumsap, Taksa, rise/fall, remedy, lookup |
| `RUNTIME_METADATA_SUPPORTED` | **Restricted / internal-only** | Rise/fall metadata not public-ready |
| `CANON_DERIVED_INTERNAL` | **Internal-only** | Derived inference |
| `PARTIAL_CANON_SUPPORT` | **Restricted / internal-only** | Must not imply full support |
| `OUT_OF_CANON_SCOPE` | **Internal-only** | Includes `mahabhuta_thaya` |
| `BLOCKED_AMBIGUOUS` | **Internal-only** | Never public advice |
| `BLOCKED_SOURCE_CONFLICT` | **Internal-only** | Never public resolution claims |
| `INTERNAL_ONLY` | **Internal-only** | Includes Taksa trace metadata |
| `REMEDY_HIDDEN` | **Never public** | Requires Remedy Safety / Presentation Policy |
| `NO_CANON_EVIDENCE` | **Internal-only** | Absence is not a negative public claim |

**Current state:** All badges remain LEVEL 0. Internal beta preview validates LEVEL 1 eligibility rules only on `/internal/thai-public-evidence-preview`.

---

## 7. Never-public items

The following must **never** appear on public consumer surfaces without a separate approved policy phase:

| Category | Examples |
|----------|----------|
| Remedy content | Procedure text, ritual instructions, prayer text / คำอธิษฐาน |
| Source material | Source prose, OCR recovery text, scanned pages |
| Internal artifacts | Raw Canon JSON, raw evidence unit ids, raw ontology ids, source-forensics artifacts |
| Blocker details | Ambiguous placement as advice, source conflict resolution as advice |
| False certainty | Confidence percentages, certainty language |
| High-stakes advice | Medical / financial / legal claims |
| Taksa | Rotation output (all weekdays) |
| Khumsap | Public display (`mahabhuta_thaya` ≠ Khumsap) |
| Rise/fall | ดวงขึ้น / ดวงตก public display |
| Lookup tables | Reference-only Canon — not public evidence badges |

---

## 8. Frozen safety boundaries

Mandatory boundaries for all work after this freeze:

- **Canon evidence means traceability, not guaranteed truth.**
- Badge is **not** a confidence score.
- Badge is **not** prediction certainty.
- Evidence is **not** advice.
- Remedy Canon must **never** become public advice without **Remedy Safety / Presentation Policy**.
- **Public page references are not authorized yet** (LEVEL 2 frozen as policy-only).
- **Source prose is not authorized** on any public surface.
- Internal beta preview at `/internal/thai-public-evidence-preview` is **not** a public release.

---

## 9. Post-freeze rules

Future work must use an **explicit approved phase**. Silent changes are forbidden.

| Approved future phase | Scope |
|-----------------------|-------|
| Public Evidence Badge Prototype Freeze | Freeze internal beta prototype baseline |
| Public Evidence Badge Controlled Beta | Controlled rollout evaluation (if approved) |
| Public Source Page Reference Policy | LEVEL 2 governance |
| Remedy Safety / Presentation Policy | Remedy exposure rules |
| Taksa Public Presentation Policy | Taksa display rules |
| Public Evidence Disclosure Policy V2 | Major policy revision |

**No public display without implementation approval.**

**No silent changes** to eligibility rules, forbidden wording, or public surfaces.

---

## 10. Recommended next phase

**Public Evidence Badge Prototype Freeze**

**Rationale:** The LEVEL 1 internal beta preview and formal QA are complete. The next safe step is to freeze the prototype state before deciding whether to run a controlled beta rollout.

**Do not implement rollout in this commit.**

---

## Related

- [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md) — frozen policy text
- [`THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_INTERNAL_BETA.md`](THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_INTERNAL_BETA.md) — internal beta prototype
- [`THAI_PUBLIC_EVIDENCE_BADGE_QA.md`](THAI_PUBLIC_EVIDENCE_BADGE_QA.md) — formal QA record
- [`THAI_CANON_INTEGRATION_FREEZE.md`](THAI_CANON_INTEGRATION_FREEZE.md) — internal integration baseline
