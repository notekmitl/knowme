# Thai Taksa Rotation Model

**Phase:** Taksa Rotation Model (internal metadata only)  
**Baseline:** `5591ab6` — Taksa Runtime Mapping  
**Feasibility result:** `READY_TO_IMPLEMENT_TUESDAY_ONLY`

---

## Feasibility audit

### Canon Taksa rotation units (`planet.* --located_in--> taksaRole.*`)

| Source | Weekday context | Assignments | Status |
|--------|-----------------|-------------|--------|
| p38 | `คนเกิดวันอังคาร` (Tuesday) | 8 | **Imported** — clean OCR prose |
| p38 | `คนเกิดวันอาทิตย์` / `คนเกิดวันจันทร์` | 0 | **OCR-blocked** — planet↔role grid corrupted (Phase C) |
| p38 | Wed–Sat rotation tables | 0 | **Not in Canon** — not extracted |
| p39 | — | 0 rotation | Role meanings only (`taksaRole --owns--> domain.*`) |
| p40–41 | — | 0 rotation | Prediction rules (Phase E) — not role rotation |
| Per-chart pages | `archetype_chart` / `life_period` | 83 | **Not weekday rotation** — chart-scoped assignments |

### Runtime data

| Field | Status |
|-------|--------|
| `ThaiBirthData.thaiWeekdayNumber` | Present (อาทิตย์=1 … เสาร์=7) |
| Birth weekday label | Derivable from Canon context tokens |
| Taksa chart key | **Missing** |
| Planet → role assignment (engine) | **Missing** — added via rotation resolver only |
| Role order / rotation index | **Missing** |

### Weekday coverage

| Weekday | Thai | Support |
|---------|------|---------|
| 1 | อาทิตย์ | OCR-blocked (`TAKSA_ROTATION_SOURCE_BLOCKED`) |
| 2 | จันทร์ | OCR-blocked (`TAKSA_ROTATION_SOURCE_BLOCKED`) |
| 3 | อังคาร | **Supported** — 8 assignments |
| 4 | พุธ | Unsupported (`TAKSA_ROTATION_UNSUPPORTED_WEEKDAY`) |
| 5 | พฤหัส | Unsupported |
| 6 | ศุกร์ | Unsupported |
| 7 | เสาร์ | Unsupported |

No Rahu / Wednesday-night distinction in frozen Canon rotation evidence.

**Classification:** `READY_TO_IMPLEMENT_TUESDAY_ONLY`

---

## Tuesday planet → Taksa role mapping (p38)

| Planet | Taksa role | Canon unit |
|--------|------------|------------|
| `planet.mars` | `taksaRole.boriwan` | `mahabhut.p38.mars_located_in_boriwan_tuesday_birth` |
| `planet.mercury` | `taksaRole.ayu` | `mahabhut.p38.mercury_located_in_ayu_tuesday_birth` |
| `planet.saturn` | `taksaRole.det` | `mahabhut.p38.saturn_located_in_det_tuesday_birth` |
| `planet.jupiter` | `taksaRole.sri` | `mahabhut.p38.jupiter_located_in_sri_tuesday_birth` |
| `planet.rahu` | `taksaRole.mula` | `mahabhut.p38.rahu_located_in_mula_tuesday_birth` |
| `planet.venus` | `taksaRole.utsaha` | `mahabhut.p38.venus_located_in_utsaha_tuesday_birth` |
| `planet.sun` | `taksaRole.montri` | `mahabhut.p38.sun_located_in_montri_tuesday_birth` |
| `planet.moon` | `taksaRole.kalakini` | `mahabhut.p38.moon_located_in_kalakini_tuesday_birth` |

Source: `canon_structural`, confidence: `deterministic`, page: `38`.

---

## Evidence attachment / trace behavior

| Profile weekday | Rotation metadata | Evidence attached | Trace-only remainder | Blocker |
|-----------------|-------------------|-------------------|----------------------|---------|
| Tuesday (3) | 8 assignments | 8 p38 units | ~89 non-rotation Taksa units | — |
| Sunday / Monday | 0 | 0 | all Taksa units | `TAKSA_ROTATION_SOURCE_BLOCKED` |
| Wed–Sat | 0 | 0 | all Taksa units | `TAKSA_ROTATION_UNSUPPORTED_WEEKDAY` |

All Taksa attachments: `userFacingAllowed = false`, section `taksaInternal` only.

Remedies remain internal/hidden (unchanged).

---

## Safety boundary

This phase does **not**:

- Edit frozen Canon (`foundation_v1.knowme.json`)
- Infer Sun–Sat rotations from Tuesday pattern
- Complete missing roles by planet order or external Taksa knowledge
- Change Thai engine calculations
- Change prediction, Mirror, or Daily Mirror copy
- Expose Taksa publicly

Per-chart Taksa assignments (`archetype_chart` / `life_period` context) are **not** weekday rotations and are not attached by this resolver.

---

## Public output unchanged

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint()` unchanged before/after enrichment
- No Taksa rotation imports in public Thai pages
- Mirror consumer copy unchanged
- Full Thai validation suite green after phase

---

## Recommended next phase

**Taksa Source Forensics OCR Recovery**

Sunday and Monday p38 rotation tables are documented OCR blocks. Recovering them via controlled source forensics would enable `READY_TO_IMPLEMENT_PARTIAL_ROTATION` before broader weekday coverage.
