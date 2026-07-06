# Thai Taksa Rotation Mapping Freeze

**Phase:** Taksa Rotation Mapping Freeze  
**Status:** **FROZEN / PARTIAL SOURCE-BACKED**  
**Freeze date:** July 2026  
**Prerequisite commits:**

| Commit | Milestone |
|--------|-----------|
| `5591ab6` | Taksa Runtime Mapping |
| `5a337cc` | Taksa Rotation Model (Tuesday-only) |
| `96f57d2` | Taksa Source Forensics OCR Recovery |
| `1d49ca5` | Mahabhut Canon Post-Freeze Patch 002 — Monday rotation |
| `2b0705d` | Taksa Rotation Model Monday Expansion |

**Canon baseline:** `foundation_v1.knowme.json` — **834 atomic units** (post Patch 002)

---

## 1. Freeze declaration

**Taksa Rotation Mapping is frozen as internal-only partial source-backed support.**

This freeze documents the current integration state. It is **documentation / QA baseline only** — no new Canon units, no ontology changes, no resolver behavior changes, and no public exposure.

Supported scope: **Monday + Tuesday weekday-born Taksa rotation** only, backed by frozen Canon p38 assignments. All other weekdays are explicitly blocked with trace-only internal metadata.

**No public Taksa display is authorized.**

---

## 2. Supported weekdays

### Monday — `คนเกิดวันจันทร์` (birth weekday 2)

**Source:** Post-Freeze Patch 002 (`1d49ca5`), forensics `96f57d2`  
**Context:** `{ "type": "taksa_chart", "value": "คนเกิดวันจันทร์" }`  
**Assignment source:** `source_forensics_patch`

| Planet | Taksa role | Canon unit id |
|--------|------------|---------------|
| `planet.sun` | `taksaRole.kalakini` | `taksa.p38.monday.sun_kalakini` |
| `planet.moon` | `taksaRole.boriwan` | `taksa.p38.monday.moon_boriwan` |
| `planet.mars` | `taksaRole.ayu` | `taksa.p38.monday.mars_ayu` |
| `planet.mercury` | `taksaRole.det` | `taksa.p38.monday.mercury_det` |
| `planet.jupiter` | `taksaRole.mula` | `taksa.p38.monday.jupiter_mula` |
| `planet.venus` | `taksaRole.montri` | `taksa.p38.monday.venus_montri` |
| `planet.saturn` | `taksaRole.sri` | `taksa.p38.monday.saturn_sri` |
| `planet.rahu` | `taksaRole.utsaha` | `taksa.p38.monday.rahu_utsaha` |

### Tuesday — `คนเกิดวันอังคาร` (birth weekday 3)

**Source:** Phase C Canon (unchanged by Patch 002)  
**Context:** `{ "type": "other", "value": "คนเกิดวันอังคาร" }`  
**Assignment source:** `canon_structural`

| Planet | Taksa role | Canon unit id |
|--------|------------|---------------|
| `planet.mars` | `taksaRole.boriwan` | `mahabhut.p38.mars_located_in_boriwan_tuesday_birth` |
| `planet.mercury` | `taksaRole.ayu` | `mahabhut.p38.mercury_located_in_ayu_tuesday_birth` |
| `planet.saturn` | `taksaRole.det` | `mahabhut.p38.saturn_located_in_det_tuesday_birth` |
| `planet.jupiter` | `taksaRole.sri` | `mahabhut.p38.jupiter_located_in_sri_tuesday_birth` |
| `planet.rahu` | `taksaRole.mula` | `mahabhut.p38.rahu_located_in_mula_tuesday_birth` |
| `planet.venus` | `taksaRole.utsaha` | `mahabhut.p38.venus_located_in_utsaha_tuesday_birth` |
| `planet.sun` | `taksaRole.montri` | `mahabhut.p38.sun_located_in_montri_tuesday_birth` |
| `planet.moon` | `taksaRole.kalakini` | `mahabhut.p38.moon_located_in_kalakini_tuesday_birth` |

---

## 3. Blocked / unsupported weekdays

| Weekday | Context token | Blocker | Reason |
|---------|---------------|---------|--------|
| **Sunday** (1) | `คนเกิดวันอาทิตย์` | `TAKSA_ROTATION_PARTIAL_SOURCE_REVIEW_REQUIRED` | p38 partial recovery (7/8); digit-2 cell empty — Moon → อายุ not safely recoverable. **Must not be inferred.** |
| **Wednesday daytime** | `คนเกิดวันพุธกลางวัน` | `TAKSA_ROTATION_NOT_IN_SOURCE` | No rotation table in source. |
| **Wednesday night / Rahu** | `คนเกิดวันพุธกลางคืน / ราหู` | `TAKSA_ROTATION_NOT_IN_SOURCE` | No rotation table in source. **Separate from Wednesday daytime — must not be merged or inferred from Rahu.** |
| **Thursday** (5) | `คนเกิดวันพฤหัส` | `TAKSA_ROTATION_NOT_IN_SOURCE` | No rotation table in source. |
| **Friday** (6) | `คนเกิดวันศุกร์` | `TAKSA_ROTATION_NOT_IN_SOURCE` | No rotation table in source. |
| **Saturday** (7) | `คนเกิดวันเสาร์` | `TAKSA_ROTATION_NOT_IN_SOURCE` | No rotation table in source. |

No standard Taksa rotation pattern may be used to fill missing weekdays.

---

## 4. Evidence safety

| Rule | Status |
|------|--------|
| Taksa evidence is internal only | **Frozen** |
| All Taksa evidence `userFacingAllowed = false` | **Enforced** |
| No public Taksa display authorized | **Frozen** |
| No public prediction copy uses Taksa rotation | **Confirmed** |
| No unsupported weekday inferred | **Frozen** |
| Remedies remain hidden/internal | **Unchanged** (87 skipped per fixture) |
| Public Thai report fingerprint unchanged after enrichment | **Test-guarded** |

---

## 5. Frozen integration scope

| # | Component | Location | Frozen state |
|---|-----------|----------|--------------|
| 1 | Taksa role runtime keys | `thai_taksa_role_runtime_key.dart` | 8 internal `taksaRole.*` keys |
| 2 | Taksa role mapping | `thai_canon_taksa_role_runtime_mapping.dart` | Canon id ↔ runtime key (exact) |
| 3 | Monday rotation assignments | Canon Patch 002 + `thai_taksa_rotation_resolver.dart` | 8 source-backed assignments |
| 4 | Tuesday rotation assignments | Phase C Canon + resolver | 8 source-backed assignments (unchanged) |
| 5 | Unsupported weekday blockers | `thai_taksa_rotation_metadata.dart` | Sunday partial + Wed–Sat not-in-source |
| 6 | Internal Taksa evidence trace | `thai_canon_evidence_trace.dart`, enricher | Attached count / trace-only / blocker per profile |
| 7 | Internal review panel summary | `thai_canon_evidence_review_page.dart` | Supported weekdays, partial review, Wed daytime/night separate, attachment counts |
| 8 | Public isolation | Tests + consumer surfaces | No Taksa resolver on public pages; fingerprint unchanged |

---

## 6. Canon patch record

| Event | Detail |
|-------|--------|
| Patch 002 (`1d49ca5`) | Added **+8** Monday Taksa rotation units (`taksa.p38.monday.*`) |
| Canon count | **826 → 834** atomic units |
| Tuesday | **Unchanged** — 8 Phase C units confirmed |
| Sunday | **Not patched** — `RECOVERED_PARTIAL` only |
| Wednesday daytime | **Not patched** — `NOT_IN_SOURCE` |
| Wednesday night / Rahu | **Not patched** — `NOT_IN_SOURCE` (separate case) |
| Thursday–Saturday | **Not patched** — `NOT_IN_SOURCE` |

Post-freeze Canon edits require an explicit approved patch document (same policy as Patch 001 / 002).

---

## 7. Validation record

Verified by `flutter test test/validation/thai/` on freeze date:

| Metric | Value |
|--------|------:|
| Thai validation suite | **628 / 628 pass** |
| Canon atomic count | **834** |
| Monday rotation resolver | 8 assignments |
| Tuesday rotation resolver | 8 assignments |
| Sunday blocker | `TAKSA_ROTATION_PARTIAL_SOURCE_REVIEW_REQUIRED` |
| Wed–Sat blocker | `TAKSA_ROTATION_NOT_IN_SOURCE` |
| Public fingerprint | unchanged |
| Remedy attachments | 0 (87 skipped) |

Key test files:

- `test/validation/thai/thai_taksa_monday_patch_test.dart`
- `test/validation/thai/thai_taksa_rotation_model_test.dart`
- `test/validation/thai/thai_taksa_runtime_mapping_test.dart`
- `test/validation/thai/thai_canon_evidence_mapping_test.dart`

---

## 8. Future allowed work

Future Taksa rotation changes require an **explicit approved phase**. Allowed phase names:

- **Sunday Human Source Review**
- **Taksa Source Forensics Patch 003** (or later numbered post-freeze patches)
- **Taksa Public Presentation Policy**
- **Taksa Prediction Integration**
- **Mahabhut Canon V2 / new source comparison**

**No silent changes** to frozen Canon, resolver blockers, or public output.

---

## 9. Recommended next phase

**Khumsap Runtime Mapping**

**Rationale:** Mahabhut position `mahabhutPosition.khumsap` remains a Canon entity without runtime mapping. This is a smaller, high-value core mapping gap and safer than forcing more Taksa rotation without source support.

---

## Related

- [`THAI_TAKSA_RUNTIME_MAPPING.md`](THAI_TAKSA_RUNTIME_MAPPING.md)
- [`THAI_TAKSA_ROTATION_MODEL.md`](THAI_TAKSA_ROTATION_MODEL.md)
- [`THAI_TAKSA_SOURCE_FORENSICS_OCR_RECOVERY.md`](THAI_TAKSA_SOURCE_FORENSICS_OCR_RECOVERY.md)
- [`THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_002.md`](THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_002.md)
- [`THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md`](THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md)
