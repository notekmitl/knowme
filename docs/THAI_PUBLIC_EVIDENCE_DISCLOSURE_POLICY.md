# Thai Public Evidence Disclosure Policy

**Phase:** Public Evidence Disclosure Policy  
**Status:** **DRAFTED** (policy only — not implemented)  
**Date:** July 2026  
**Prerequisite commit:** `374115a` — Thai Canon Integration Freeze  
**Validation baseline:** `667 / 667` thai tests; Canon integration **FROZEN / INTERNAL-ONLY**

---

## Core principle

**Canon evidence is not proof that a prediction is objectively true.**

Canon evidence means:

> “The statement is traceable to the approved Canon knowledge base.”

It must **not** be presented as:

- guaranteed accuracy
- scientific proof
- certainty score
- medical / financial / legal advice
- instruction to perform rituals
- reason to make high-stakes decisions

---

## 1. Policy declaration

**No public Canon evidence display is authorized until this policy is accepted and a separate implementation phase is approved.**

This document **only defines future rules**. It does not authorize any public UI change, public route, public badge component, or consumer-facing evidence surface.

Current state (unchanged by this policy):

- All evidence rows: `userFacingAllowed = false`
- Internal route only: `/internal/thai-canon-evidence`
- Public Thai report fingerprint: unchanged
- Remedies, Taksa, Khumsap, rise/fall metadata: internal-only

---

## 2. Public-safe disclosure levels

Future public evidence features — if approved — must use one of these levels. Higher levels require stricter gates (see §11).

### LEVEL 0 — INTERNAL_ONLY

Evidence visible **only** to internal/admin reviewers.

**Includes:**

- remedies
- source conflicts
- ambiguous blockers
- raw unit ids
- raw ontology ids
- source-forensics artifacts
- OCR blockers
- modeling gaps
- Taksa rotation metadata
- Khumsap internal keys
- ดวงขึ้น / ดวงตก runtime metadata
- all current evidence attachments (as of integration freeze)

**Current default for the entire Canon evidence stack.**

---

### LEVEL 1 — PUBLIC_SUMMARY_BADGE

Future public UI **may** show a soft summary badge such as:

- “มีแหล่งอ้างอิงใน Canon”
- “อ้างอิงจากฐานความรู้ที่ตรวจแล้ว”
- “ตรวจสอบกับ Canon แล้ว”

**Requirements:**

- Must **not** imply accuracy, certainty, or proof
- Must **not** show raw unit ids, ontology ids, or badge category names
- Must **not** appear on remedy, Taksa, Khumsap, or rise/fall surfaces
- Must include or link to user-education disclaimer (see §9)
- Requires separate **Public Evidence Badge Prototype** implementation phase

---

### LEVEL 2 — PUBLIC_SOURCE_PAGE_REFERENCE

Future public UI **may** show page references only, such as:

- “อ้างอิง: หลักมหาภูต หน้า 38”

**Requirements:**

- **No** source prose
- **No** long quotes
- **No** scanned image
- **No** ritual instruction
- **No** remedy-related pages
- Book title + page number only
- Requires LEVEL 1 gates **plus** UX copy review and public route isolation test

---

### LEVEL 3 — PUBLIC_EXPLANATION_WITH_EVIDENCE

Future public UI **may** explain why a report section is supported by Canon, using **presentation copy written separately** for public consumption.

**Requirements:**

- Must **not** copy source prose
- Must **not** generate new claims beyond the report section
- Must **not** present blockers, conflicts, or partial support as certainty
- Requires separate approved implementation phase with full approval gates (§11)

---

## 3. Always forbidden for public display

The following must **never** be shown on public consumer surfaces, regardless of disclosure level:

| Category | Examples |
|----------|----------|
| Remedy content | Procedure text, ritual instructions, prayer text / คำอธิษฐาน |
| Source material | Source prose from the book, OCR recovery text, scanned pages |
| Internal artifacts | Source-forensics artifacts, raw Canon JSON, raw evidence unit ids |
| Blocker details | Ambiguous placement details presented as advice, source conflict resolution claims |
| False certainty | Public confidence percentages, “แม่นแน่นอน”, “ถูกต้อง 100%” |
| High-stakes advice | Medical / financial / legal claims |
| Ritual direction | User-facing instruction to perform remedies, “ควรสะเดาะเคราะห์” |

---

## 4. Remedy policy

**Remedy Canon is internal-only.**

No remedy evidence, remedy item, ritual target, ritual instruction, or procedure may be shown to public users without a separate **Remedy Safety / Presentation Policy**.

| Rule | Status |
|------|--------|
| Remedy units in Canon | 87 per fixture — counted internally only |
| Remedy report attachments | **0** (frozen baseline) |
| Remedy `userFacingAllowed` rows | **0** |
| Public remedy advice | **Forbidden** |

Remedies may be counted internally for QA but must **not** be converted into user-facing advice.

---

## 5. Taksa policy

**Taksa is not ready for public display.**

| Weekday | Internal status | Public display |
|---------|-----------------|----------------|
| Monday | Source-backed | **Not authorized** |
| Tuesday | Source-backed | **Not authorized** |
| Sunday | Partial / human review required | **Not authorized** |
| Wednesday daytime | NOT_IN_SOURCE | **Not authorized** |
| Wednesday night / Rahu | NOT_IN_SOURCE (separate case) | **Not authorized** |
| Thursday–Saturday | NOT_IN_SOURCE | **Not authorized** |

**No public Taksa rotation output is authorized.**

Wednesday daytime and Wednesday night / Rahu remain separate cases. No unsupported weekday may be inferred for public presentation.

A separate **Taksa Public Presentation Policy** is required before any Taksa surface is considered.

---

## 6. Khumsap policy

**Khumsap is mapped internally only.**

| Item | Policy |
|------|--------|
| `mahabhutPosition.khumsap` ↔ `mahabhuta_khumsap` | Internal mapping only |
| `mahabhuta_thaya` | Must **not** be presented as Khumsap |
| ทายะ ≠ ขุมทรัพย์ | Explicitly retained |

**No public Khumsap display is authorized yet.**

---

## 7. Rise/Fall policy

**ดวงขึ้น / ดวงตก metadata is internal-only.**

| Metric | Value (frozen baseline) |
|--------|------------------------:|
| Life periods with runtime status | 65 |
| Life periods without runtime status | 21 |
| Ambiguous archetype+planet blockers | 18 |
| Source-conflict blockers | 3 |

**No public display of ดวงขึ้น / ดวงตก is authorized yet.**

Reason: incomplete runtime coverage and unresolved blockers make public presentation misleading.

---

## 8. Badge wording policy

### Allowed future public wording style

- cautious
- evidence-traceable
- non-certainty
- educational

### Forbidden public wording

| Forbidden | Reason |
|-----------|--------|
| “พิสูจน์แล้ว” | Implies proof |
| “ยืนยันว่าแม่น” | Implies accuracy guarantee |
| “ฟันธง” | Implies certainty |
| “100%” | Implies certainty |
| “ต้องทำ” | Implies instruction |
| “ควรสะเดาะเคราะห์” | Remedy-adjacent advice |
| “ห้ามทำ” | High-stakes prohibition |
| “โชคร้ายแน่นอน” | Implies certainty |
| “แก้แล้วดีขึ้นแน่นอน” | Implies outcome guarantee |

Public badges must describe **traceability to Canon**, not **truth of prediction**.

---

## 9. User education copy (policy-approved draft)

The following copy is approved as **draft policy language** for future public evidence UI. **Do not implement without an approved implementation phase.**

### Primary disclaimer (Thai)

> ส่วนนี้มีข้อมูลอ้างอิงจากฐานความรู้ Canon ของ KnowMe ซึ่งใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ได้หมายความว่าเป็นการการันตีผลลัพธ์

### Secondary disclaimer (Thai)

> การอ้างอิง Canon แสดงว่าข้อความนี้สามารถตรวจสอบย้อนกลับไปยังแหล่งความรู้ที่อนุมัติแล้ว ไม่ใช่การยืนยันความแม่นยำหรือคำแนะนำทางการแพทย์ การเงิน หรือกฎหมาย

### Tooltip expansion (Thai)

> KnowMe ใช้ฐานความรู้ Canon เพื่อช่วยตรวจสอบที่มาของการวิเคราะห์เท่านั้น ผลลัพธ์ยังคงเป็นการตีความเชิงโหราศาสตร์ ไม่ใช่ข้อเท็จจริงที่พิสูจน์แล้ว

---

## 10. Internal vs public badge mapping

Maps internal badge categories (frozen prototype) to future public eligibility.

| Internal badge | Public eligibility | Notes |
|----------------|-------------------|-------|
| `CANON_SUPPORTED` | **Public eligible** (LEVEL 1) | May show soft summary badge only; no certainty language |
| `RUNTIME_METADATA_SUPPORTED` | **Public restricted** | Internal until public rise/fall policy and coverage gaps resolved |
| `CANON_DERIVED_INTERNAL` | **Internal only** | Derived inference — not direct Canon trace |
| `PARTIAL_CANON_SUPPORT` | **Public restricted** | May not imply full support; default internal only |
| `OUT_OF_CANON_SCOPE` | **Internal only** | Includes `mahabhuta_thaya`, Myanmar seven, etc. |
| `BLOCKED_AMBIGUOUS` | **Internal only** | 18 ambiguous placements — never public advice |
| `BLOCKED_SOURCE_CONFLICT` | **Internal only** | 3 conflict anchors — never public resolution claims |
| `INTERNAL_ONLY` | **Internal only** | Includes Taksa trace metadata |
| `REMEDY_HIDDEN` | **Never public** | Requires Remedy Safety / Presentation Policy |
| `NO_CANON_EVIDENCE` | **Internal only** | No public badge; absence is not a negative claim |

**Current state:** All badges are LEVEL 0 (internal only). `userFacingAllowed = false` on all evidence rows.

---

## 11. Approval gates before public implementation

All of the following gates must pass before **any** public evidence feature ships:

| Gate | Requirement |
|------|-------------|
| Thai validation suite | **Green** (`flutter test test/validation/thai/`) |
| Public fingerprint regression | `userFacingFingerprint` unchanged vs pre-enrichment baseline |
| Remedy exposure | **0** remedy attachments on public surfaces |
| Source prose exposure | **0** source prose on public surfaces |
| Policy accepted | This policy reviewed and explicitly approved |
| Implementation phase approved | Separate phase doc (e.g. Badge Prototype) approved |
| UX copy reviewed | All public wording reviewed against §8 forbidden list |
| Public route isolation | Public routes do not import internal review/badge UI |
| Rollback path documented | Feature flag or route guard to disable public evidence |

**No gate may be skipped.**

---

## 12. Recommended next phase

**Public Evidence Badge Prototype — Internal Beta Only**

**Rationale:** A limited beta-only prototype can test LEVEL 1 public-safe summary badges without showing source prose, remedies, or raw evidence. It validates UX copy, disclaimer placement, and route isolation before any consumer rollout.

**Do not implement in this commit.**

---

## Related

- [`THAI_CANON_INTEGRATION_FREEZE.md`](THAI_CANON_INTEGRATION_FREEZE.md) — frozen internal integration baseline
- [`THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md`](THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md) — internal evidence stack freeze
- [`THAI_INTERNAL_EVIDENCE_BADGE_PROTOTYPE.md`](THAI_INTERNAL_EVIDENCE_BADGE_PROTOTYPE.md) — internal badge categories
- [`THAI_TAKSA_ROTATION_MAPPING_FREEZE.md`](THAI_TAKSA_ROTATION_MAPPING_FREEZE.md) — Taksa not public-ready
- [`THAI_KHUMSAP_RUNTIME_MAPPING.md`](THAI_KHUMSAP_RUNTIME_MAPPING.md) — Khumsap internal mapping
