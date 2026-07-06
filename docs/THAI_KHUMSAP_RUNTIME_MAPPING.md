# Thai Khumsap Runtime Mapping

**Phase:** Khumsap Runtime Mapping (internal metadata only)  
**Baseline:** `654133c` — Taksa Rotation Mapping Freeze  
**Feasibility result:** `READY_TO_ADD_INTERNAL_KHUMSAP_KEY`

---

## Feasibility audit

| # | Question | Finding |
|---|----------|---------|
| 1 | Does runtime already expose a Khumsap / ขุมทรัพย์ key? | **No** — no exact Khumsap runtime key before this phase |
| 2 | Does `ThaiContentKeys` contain an exact Khumsap key? | **No** — only `mahabhuta_thaya` (ทายะ), which is distinct |
| 3 | Does `ThaiContentRegistry` contain Khumsap content? | **No** — no public Khumsap prose section |
| 4 | Does any report signal explicitly represent ขุมทรัพย์? | **No** — profile still emits `mahabhuta_thaya` for the Myanmar-adapted slot |
| 5 | Does `mahabhuta_thaya` mean Khumsap by source-backed evidence? | **No** — equivalence not proven; must remain `OUT_OF_CANON_SCOPE` |

**Classification:** `READY_TO_ADD_INTERNAL_KHUMSAP_KEY`

Runtime lacked an exact Khumsap key, but adding a dedicated internal-only `mahabhuta_khumsap` mapping to Canon `mahabhutPosition.khumsap` is safe. No alias to `mahabhuta_thaya`.

---

## Internal key added

| Field | Value |
|-------|-------|
| Internal runtime key | `mahabhuta_khumsap` |
| Canon entity | `mahabhutPosition.khumsap` |
| Thai label (Canon alias) | ขุมทรัพย์ |
| Public `ThaiContentKeys` entry | **Not added** |
| Public `ThaiContentRegistry` prose | **Not added** |

---

## Exact mapping table

| Canon id | Internal runtime key | Kind |
|----------|---------------------|------|
| `mahabhutPosition.khumsap` | `mahabhuta_khumsap` | `internalMahabhutPosition` |

Six other Mahabhut positions continue to map to existing `ThaiContentKeys` (`mahabhuta_thongchai`, etc.).

---

## Explicit non-equivalence decision

| Runtime key | Canon entity | Decision |
|-------------|--------------|----------|
| `mahabhuta_thaya` (ทายะ) | — | **OUT_OF_CANON_SCOPE** |
| `mahabhuta_khumsap` | `mahabhutPosition.khumsap` (ขุมทรัพย์) | **Mapped** |

**`mahabhuta_thaya` ≠ `mahabhutPosition.khumsap`**

No collapse, no alias, no name-similarity inference.

---

## Evidence attachment / trace behavior

| Metric | Typical QA fixture behavior |
|--------|----------------------------|
| Khumsap mapped | **true** |
| Khumsap Canon units available | > 0 (planet `located_in` + lookup rows) |
| Khumsap evidence candidates | Same count — mapped internally |
| Khumsap attached via `mahabhuta_khumsap` signal | **0** (profile does not emit internal key yet) |
| Placement-derived khumsap attachments | May attach via archetype/life-period paths when applicable |
| `mahabhutPosition.khumsap` in unmapped candidates | **Removed** — entity is mapped |
| `mahabhuta_thaya` | **OUT_OF_CANON_SCOPE** (unchanged) |
| `userFacingAllowed` | **false** for all evidence attachments |
| Remedies | **hidden** (87 skipped per fixture) |

Trace-only note when no `mahabhuta_khumsap` report signal:  
`khumsap:mapped_internal (N Canon units; no mahabhuta_khumsap report signal)`

---

## Public safety boundary

This phase does **not**:

- Edit frozen Canon (`foundation_v1.knowme.json`)
- Add Canon units or ontology entities
- Map `mahabhuta_thaya` → `mahabhutPosition.khumsap`
- Change Thai engine calculations
- Change prediction, Mirror, or Daily Mirror copy
- Expose Khumsap or remedies to public UI
- Add public Khumsap prose to `ThaiContentRegistry`

---

## Public output unchanged

Proof:

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint()` unchanged before/after enrichment
- No Khumsap imports in `thai_beta_report_page.dart`
- Mirror consumer copy contains no `ขุมทรัพย์` / `mahabhuta_khumsap`
- Full Thai validation suite green after phase

---

## Validation

- `test/validation/thai/thai_khumsap_runtime_mapping_test.dart`
- `test/validation/thai/thai_canon_evidence_mapping_test.dart` — all 7 positions mapped
- `test/validation/thai/thai_canon_evidence_mapping_precision_test.dart` — thaya stays out of scope

---

## Recommended next phase

**Internal Evidence Mapping Refresh**

Re-run alignment QA and refresh the internal evidence freeze baseline now that all seven Mahabhut positions have runtime mapping and Taksa rotation mapping is frozen — before any public disclosure policy.

---

## Related

- [`THAI_CANON_EVIDENCE_MAPPING_PRECISION_PASS.md`](THAI_CANON_EVIDENCE_MAPPING_PRECISION_PASS.md)
- [`THAI_TAKSA_ROTATION_MAPPING_FREEZE.md`](THAI_TAKSA_ROTATION_MAPPING_FREEZE.md)
- [`THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md`](THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md)
