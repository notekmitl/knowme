# Thai Public Evidence Badge Prototype — Internal Beta Only

**Phase:** Public Evidence Badge Prototype — Internal Beta Only  
**Status:** **INTERNAL BETA ONLY** (not public release)  
**Date:** July 2026  
**Prerequisite commit:** `a589995` — Public Evidence Disclosure Policy  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md)

---

## Purpose

Prototype **LEVEL 1 — PUBLIC_SUMMARY_BADGE** soft traceability wording on an **internal admin-only surface**. This validates future public badge UX, disclaimer placement, and eligibility rules **without** enabling evidence on consumer Thai report pages.

Canon evidence remains traceability metadata — **not** proof of prediction accuracy.

---

## Internal route / surface

| Surface | Route | Guard |
|---------|-------|-------|
| Public evidence badge preview | `/internal/thai-public-evidence-preview` | `ThaiResearchAdminGuard` |
| Linked from | `/internal/thai-canon-evidence` (preview icon) | Same guard |

**Not linked from:** `ThaiMirrorResultPage`, `ThaiBetaReportPage`, Daily Mirror, Home, or public profile routes.

---

## Policy level used

**LEVEL 1 — PUBLIC_SUMMARY_BADGE** only.

- Soft traceability badges
- Required caution copy
- **No** page references (LEVEL 2)
- **No** explanation-with-evidence copy (LEVEL 3)

---

## Eligible badge categories

Only attachments meeting **all** of:

1. Internal badge = `CANON_SUPPORTED`
2. Evidence domain = `mahabhutPosition` or `planetSignification` (strong Mahabhut / planet-domain)
3. Not Khumsap, Taksa, rise/fall, or remedy signal

**Allowed badge labels (policy-approved):**

- มีแหล่งอ้างอิงใน Canon
- อ้างอิงจากฐานความรู้ที่ตรวจแล้ว
- ตรวจสอบกับ Canon แล้ว
- มีหลักฐานอ้างอิงภายในระบบ

---

## Hidden categories (counts only on preview)

| Category | Shown as |
|----------|----------|
| Remedies | Hidden remedies count |
| Taksa | Hidden Taksa count |
| Khumsap | Hidden Khumsap count |
| Rise/fall | Hidden rise/fall count |
| Ambiguous blockers | Blocked ambiguous count |
| Source conflicts | Blocked source conflict count |
| Out of Canon scope | Out-of-canon scope count |

No raw unit ids, source prose, remedy details, or Taksa/Khumsap labels.

---

## Safety copy

**Required caution (every eligible badge):**

> ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์

**Preview header:**

> Public Evidence Badge Preview — Internal Beta Only

**Policy warning:**

> This preview is not visible to public users.

---

## Forbidden wording

Must not appear in preview output:

แม่นแน่นอน · ยืนยันว่าแม่น · ฟันธง · พิสูจน์แล้ว · 100% · ต้องทำ · ห้ามทำ · โชคร้ายแน่นอน · แก้แล้วดีขึ้นแน่นอน

---

## Implementation

| File | Role |
|------|------|
| `thai_public_evidence_badge_preview.dart` | Model + policy copy constants |
| `thai_public_evidence_badge_preview_mapper.dart` | Eligibility mapper + hidden summary |
| `thai_public_evidence_badge_preview_page.dart` | Internal beta UI |
| `thai_canon_evidence_routes.dart` | Route registration |

Tests: `test/validation/thai/thai_public_evidence_badge_preview_internal_beta_test.dart`

---

## Proof public output did not change

- `userFacingFingerprint` unchanged before/after enrichment
- `ThaiMirrorResultPage` / `ThaiBetaReportPage` do not import preview components
- All evidence `userFacingAllowed = false`
- Consumer Mirror copy has no Canon badge wording
- `flutter test test/validation/thai/` green

---

## Recommended next phase

**Public Evidence Badge QA**

Rationale: The internal beta prototype validates LEVEL 1 eligibility and copy. The next step is a structured QA pass across all 9 fixtures to confirm badge counts, hidden summaries, and public isolation before any policy freeze or consumer rollout consideration.

---

## Related

- [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY.md)
- [`THAI_CANON_INTEGRATION_FREEZE.md`](THAI_CANON_INTEGRATION_FREEZE.md)
- [`THAI_INTERNAL_EVIDENCE_BADGE_PROTOTYPE.md`](THAI_INTERNAL_EVIDENCE_BADGE_PROTOTYPE.md)
