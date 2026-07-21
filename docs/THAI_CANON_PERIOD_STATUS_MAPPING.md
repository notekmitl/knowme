# Thai Canon Period Status Mapping

Evidence-layer mapping for frozen Canon `periodStatus.*` entities. No engine, copy, UI, or Canon data changes.

**Commit:** Thai Canon Period Status Mapping  
**Prerequisite:** Thai Canon Evidence Mapping Precision Pass (`af08e0c`)

---

## 1 · Runtime / report status discovery

| Source | Field / label | Status |
|---|---|---|
| `LifeTimeline` / `PeriodState` | rise/fall metadata | **Absent** — no status fields |
| `ThaiMirrorPipelineResult` | period status | **Absent** |
| `ThaiMirrorViewState` | life timeline | **Absent** on pipeline result |
| Consumer timeline presenter | `ดวงขึ้น` / `ดวงตก` | Built later; not on enricher input today |

**Decision:** Production discovery via [`ThaiCanonPeriodStatusDiscovery._discoverFromPipeline`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_period_status_discovery.dart) returns `{}` until report/timeline exposes exact Thai labels. No engine keys invented.

**QA injection:** `ThaiReportCanonEvidenceEnricher.enrich(..., periodStatusLabelsByIndex: …)` for deterministic tests only.

---

## 2 · Exact mapping table

| Canon entity | Runtime / report label | Kind |
|---|---|---|
| `periodStatus.duengKhuen` | `ดวงขึ้น` | `periodStatusLabel` |
| `periodStatus.duengTok` | `ดวงตก` | `periodStatusLabel` |

Implemented in [`ThaiCanonPeriodStatusRuntimeMapping`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_period_status_runtime_mapping.dart).

Rules enforced:

- Exact string match only — no synonyms, fuzzy match, or inference from planet/position/prediction copy.
- Ontology [`unmappedCanonEntityIds`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_ontology_runtime_mapping.dart) treats both `periodStatus.*` entities as **mapped** (table present).

---

## 3 · Evidence attached after mapping

When an exact label is present (QA injection or future runtime surface), [`ThaiReportCanonEvidenceEnricher`](../lib/features/astrology/thai/knowledge/canon/integration/thai_report_canon_evidence_enricher.dart) adds:

| Attachment | Type | Canon coverage |
|---|---|---|
| Per life-period signal | `periodStatusStructural` | All units where `subject` or `object` is `periodStatus.duengKhuen` / `periodStatus.duengTok` |

Includes:

- **p17** rise/fall structural rules (`relates_to` → `mahabhutPosition.*`)
- **p40–41** prediction rules (`produces` → `predictionEffect.weak/strong`, Kalakini `opposes` exceptions)

All attachments: `userFacingAllowed = false`, `internalOnly = true`.

When **no** runtime labels exist (all production fixtures today):

- No `periodStatusStructural` section attachments
- Bulk p40–41 rules remain **trace-only** (`prediction:phase_e_rules …`)
- Each life-period anchor listed in `trace.lifePeriodsWithoutRuntimeStatus` (not a mapping failure)

---

## 4 · Updated alignment counts (9 fixtures)

| Metric | Before | After |
|---|---:|---:|
| Thai validation tests | 351 pass | **366 pass** |
| `STRONG_MATCH` | 177 | **177** (unchanged — no production runtime labels) |
| `RELATED_BUT_WEAK` | 9 | **9** |
| `UNMAPPED_SIGNAL` | 0 | **0** |
| `OUT_OF_CANON_SCOPE` | 99 | **99** |
| `SKIPPED_PERIOD_STATUS` | 18 | **0** |
| `skippedPeriodStatusNotes` | 18 (2 notes × 9 fixtures) | **0** |
| `lifePeriodsWithoutRuntimeStatus` | — | **86** (trace-only `noStatusInRuntime`) |
| `INTERNAL_ONLY` | 9 | **95** (+86 no-status trace rows + 9 lookup) |
| In-scope unmapped | 0 | **0** |
| `periodStatus.*` in `unmappedCanonEvidenceCandidates` | 2 ids | **0** |

---

## 5 · Trace cleanup

| Trace field | Before | After |
|---|---|---|
| `skippedPeriodStatusNotes` | `periodStatus.duengKhuen/duengTok — no runtime rise/fall keys` | **Empty** — mapping table wired |
| `unmappedCanonEvidenceCandidates` | included `periodStatus.*` | **Removed** — table mapped |
| `lifePeriodsWithoutRuntimeStatus` | — | Populated per life-period anchor when label absent |
| Alignment classifier | `SKIPPED_PERIOD_STATUS` | `trace:noStatusInRuntime:*` → `INTERNAL_ONLY` |

---

## 6 · Remaining true mapping gaps

| Gap | Classification | Notes |
|---|---|---|
| No `ดวงขึ้น`/`ดวงตก` on pipeline output | `noStatusInRuntime` | Engine/report must surface labels — not evidence-layer failure |
| `taksaRole.*` | Skipped / unmapped candidates | Out of scope this phase |
| `planet.ketu` | Unmapped candidate | No runtime planet key |
| `mahabhutPosition.khumsap` | Unmapped candidate | `mahabhuta_thaya` stays **OUT_OF_CANON_SCOPE** — no inferred equivalence |
| Myanmar seven, Lagna sign | `OUT_OF_CANON_SCOPE` | Unchanged |
| Remedies | Skipped internal | Unchanged |

---

## 7 · Safety boundary

- No changes to `foundation_v1.knowme.json`, Thai engine, Mirror copy, Daily Mirror, or public UI.
- Evidence never user-facing; remedies never attached to report sections.
- Rise/fall never calculated or inferred in the evidence layer.
- Taksa roles not mapped in this phase.

---

## 8 · Public output proof

`ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline)` is identical before and after enrichment on all fixtures (including QA-injected period labels). Covered by:

- `test/validation/thai/thai_canon_period_status_mapping_test.dart`
- Existing upgrade / alignment / precision / review-panel fingerprint tests

---

## 9 · Recommended next phase

**No User-Facing Integration Yet**

Rationale: the period-status mapping table is complete, but production pipeline/report still does not expose deterministic `ดวงขึ้น`/`ดวงตก` labels — so structural period-status evidence cannot attach on real runs. Internal badges or user-facing seams should wait until runtime surfaces exact status metadata (or a dedicated runtime-mapping phase for Khumsap/Taksa is chosen first).

---

## Files touched

| Area | Files |
|---|---|
| Mapping | `thai_canon_period_status_runtime_mapping.dart`, `thai_canon_period_status_discovery.dart` |
| Ontology / mapper / trace / enricher | `thai_canon_ontology_runtime_mapping.dart`, `thai_canon_evidence_mapper.dart`, `thai_canon_evidence_type.dart`, `thai_canon_evidence_trace.dart`, `thai_report_canon_evidence_enricher.dart` |
| QA / review | `thai_canon_evidence_alignment_classifier.dart`, `thai_canon_evidence_alignment_runner.dart`, `thai_canon_evidence_alignment_report.dart`, `thai_canon_evidence_review_page.dart` |
| Tests | `thai_canon_period_status_mapping_test.dart`, updates to mapping / alignment / upgrade tests |
| Docs | this file |
