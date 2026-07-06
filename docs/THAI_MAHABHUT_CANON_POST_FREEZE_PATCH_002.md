# Thai Mahabhut Canon — Post-Freeze Patch 002

**Patch id:** Post-Freeze Patch 002  
**Date:** July 2026  
**Prerequisite:** Mahabhut Canon Complete (Phase I freeze) + Post-Freeze Patch 001 (826 atomic units)  
**Source forensics:** `96f57d2` — Taksa Source Forensics OCR Recovery

---

## Why this patch is allowed after freeze

Frozen Phase G Canon included Tuesday Taksa rotation only (`mahabhut.p38.*_tuesday_birth`, Phase C). Source forensics on p38 OCR (`96f57d2`) recovered a **complete** Monday rotation grid (`RECOVERED_COMPLETE`, 8/8, patch-ready). This is a post-freeze source-forensics patch — same policy as Patch 001 — adding only recovered atomic assignments with full provenance. No inference, no role meanings, no public output change.

**Classification before patch:** `READY_FOR_POST_FREEZE_PATCH_TAKSA_ROTATION`

---

## Source artifacts used

| Artifact | Role |
| --- | --- |
| `docs/THAI_TAKSA_SOURCE_FORENSICS_OCR_RECOVERY.md` | Human review record |
| `tool/output/taksa_source_forensics_rotation_candidates.json` | Monday `patchReady: true` |
| `tool/output/taksa_source_forensics_recovered_lines.json` | Grid cell provenance |
| `tool/output/taksa_source_forensics_blockers.json` | Excluded weekday blockers |

Only Monday candidates with `classification: RECOVERED_COMPLETE` and `patchReady: true` were imported.

---

## Monday planet → Taksa role assignments (p38)

| Planet | Taksa role | Unit id | Locator |
| --- | --- | --- | --- |
| sun | kalakini | `taksa.p38.monday.sun_kalakini` | `p38.monday.grid.1` |
| moon | boriwan | `taksa.p38.monday.moon_boriwan` | `p38.monday.grid.2` |
| mars | ayu | `taksa.p38.monday.mars_ayu` | `p38.monday.grid.3` |
| mercury | det | `taksa.p38.monday.mercury_det` | `p38.monday.grid.4` |
| jupiter | mula | `taksa.p38.monday.jupiter_mula` | `p38.monday.grid.5` |
| venus | montri | `taksa.p38.monday.venus_montri` | `p38.monday.grid.6` |
| saturn | sri | `taksa.p38.monday.saturn_sri` | `p38.monday.grid.7` |
| rahu | utsaha | `taksa.p38.monday.rahu_utsaha` | `p38.monday.grid.8` |

**Context:** `{ "type": "taksa_chart", "value": "คนเกิดวันจันทร์" }`  
**Relation:** `planet.*` → `located_in` → `taksaRole.*`

---

## Weekdays NOT patched (confirmed)

| Weekday case | Status | Action |
| --- | --- | --- |
| Sunday (`คนเกิดวันอาทิตย์`) | `RECOVERED_PARTIAL` (7/8) | **Not patched** — Moon→อายุ slot missing |
| Wednesday daytime (`คนเกิดวันพุธกลางวัน`) | `NOT_IN_SOURCE` | **Not patched** |
| Wednesday night / Rahu (`คนเกิดวันพุธกลางคืน`) | `NOT_IN_SOURCE` | **Not patched** |
| Thursday | `NOT_IN_SOURCE` | **Not patched** |
| Friday | `NOT_IN_SOURCE` | **Not patched** |
| Saturday | `NOT_IN_SOURCE` | **Not patched** |

Existing Tuesday units (`mahabhut.p38.*_tuesday_birth`) are **unchanged**.

---

## Count delta

| Metric | Before | After |
| --- | ---: | ---: |
| Atomic units | 826 | **834** |
| Monday rotation units added | — | **+8** |
| Tuesday rotation units | 8 | 8 (unchanged) |

---

## Patch rules observed

- Post-freeze source-forensics patch only
- No existing unit ids or meanings changed
- No Sunday partial import
- No Wed–Sat import or inference
- No source prose, polarity, prediction, or role meaning
- Full provenance on every added unit (`bookId`, `page`, `locator`)
- Deterministic, reviewable unit ids: `taksa.p38.monday.<planet>_<role>`

---

## Validation

- `test/validation/thai/thai_taksa_monday_patch_test.dart` — Patch 002 import guards
- `test/validation/thai/thai_canon_evidence_mapping_test.dart` — atomic count 834
- `test/validation/thai/thai_canon_production_sprint2_test.dart` — batch reconciles 834
- Full Thai validation suite green

---

## Related

- [`THAI_TAKSA_SOURCE_FORENSICS_OCR_RECOVERY.md`](THAI_TAKSA_SOURCE_FORENSICS_OCR_RECOVERY.md)
- [`THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_001.md`](THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_001.md)
- [`THAI_TAKSA_ROTATION_MODEL.md`](THAI_TAKSA_ROTATION_MODEL.md)
