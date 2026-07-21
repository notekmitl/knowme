# Thai Taksa Runtime Mapping

**Phase:** Taksa Runtime Mapping (metadata / mapping only)  
**Baseline:** `f1f3e65` — Thai Internal Evidence Review Freeze  
**Feasibility result:** `READY_TO_ADD_INTERNAL_TAKSA_ROLE_KEYS`

---

## Feasibility audit

| Question | Finding |
|----------|---------|
| Does runtime expose Taksa role keys? | **No** — engine/report have no `taksaRole.*` signals today |
| Does runtime expose birth weekday? | **Yes** — `ThaiBirthData.thaiWeekdayNumber` (อาทิตย์=1 … เสาร์=7) |
| Does runtime expose planet → Taksa role assignment? | **No** — `birthRuler` is weekday ruler only |
| Does report copy mention Taksa role labels? | **No** — mirror consumer copy has no บริวาร/ทักษา labels |
| Does Canon contain enough role identity data? | **Yes** — 8 frozen `taksaRole.*` entities with exact Thai aliases |

**Classification:** `READY_TO_ADD_INTERNAL_TAKSA_ROLE_KEYS`

Runtime lacks Taksa role keys, but adding canonical internal role ids as metadata-only mapping is safe. No rotation calculation or role inference was performed.

---

## Runtime Taksa fields

| Field | Status |
|-------|--------|
| `ThaiTaksaRoleRuntimeKey` / `taksaRole.*` internal keys | **Added** (8 roles) |
| `ThaiBirthData.thaiWeekdayNumber` | Present (not used for role inference) |
| Planet → Taksa role assignment | **Missing** |
| Report section Taksa signals | **Missing** |

---

## Exact Taksa role mapping table

| Canon id | Internal runtime key | Thai label (Canon alias) |
|----------|---------------------|--------------------------|
| `taksaRole.boriwan` | `taksaRole.boriwan` | บริวาร |
| `taksaRole.ayu` | `taksaRole.ayu` | อายุ |
| `taksaRole.det` | `taksaRole.det` | เดช |
| `taksaRole.sri` | `taksaRole.sri` | ศรี |
| `taksaRole.mula` | `taksaRole.mula` | มูละ |
| `taksaRole.utsaha` | `taksaRole.utsaha` | อุตสาหะ |
| `taksaRole.montri` | `taksaRole.montri` | มนตรี |
| `taksaRole.kalakini` | `taksaRole.kalakini` | กาฬกิณี |

Mapping is exact id ↔ id. Thai labels resolve via frozen ontology aliases only — no fuzzy matching, no synonyms outside Canon.

---

## Evidence attachment vs trace-only

| Metric | Value |
|--------|-------|
| Taksa roles mapped | 8 |
| Taksa Canon units available | 97 (subject or object references `taksaRole.*`) |
| Taksa evidence attached | 0 |
| Taksa evidence trace-only | 97 |
| Badge | `INTERNAL_ONLY` |
| Skipped reason | `NO_RUNTIME_TAKSA_SIGNAL` |

Taksa Canon evidence is classified internally but **not** attached to mirror report sections. No runtime/report signal exposes Taksa roles yet.

Remedies remain internal/hidden (unchanged).

---

## Safety boundary

This phase does **not**:

- Edit frozen Canon data (`foundation_v1.knowme.json`)
- Calculate Taksa rotations from weekday
- Infer planet → role assignments
- Change Thai engine calculations
- Change prediction, Mirror, or Daily Mirror copy
- Expose Taksa or remedies to public UI

Weekday metadata alone is insufficient for role assignment. Canon holds Tuesday rotation plus per-chart assignments only — other weekdays are not filled.

---

## Public output unchanged

Proof:

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint()` unchanged before/after enrichment
- No Taksa imports in `thai_beta_report_page.dart`
- Mirror consumer copy files contain no Taksa role labels
- `userFacingAllowed` remains `false` for all evidence attachments
- Full Thai validation suite green after phase

---

## Recommended next phase

**Taksa Rotation Model**

A source-backed rotation model is required before runtime can emit deterministic planet → Taksa role assignments. Only then can Taksa evidence attach to exact internal signals (Taksa Evidence Attachment phase).
