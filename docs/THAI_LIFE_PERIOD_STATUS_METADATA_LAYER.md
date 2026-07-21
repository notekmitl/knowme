# Thai Life Period Status Metadata Layer

Internal audit and trace wiring for life-period rise/fall metadata. No engine calculation, no user-facing changes.

**Commit:** Thai Life Period Status Metadata Layer  
**Prerequisite:** Thai Canon Period Status Mapping (`2c934a4`)

---

## 1 · Audit: where status would come from

| Source | Rise/fall (`ดวงขึ้น` / `ดวงตก`) | Finding |
|---|---|---|
| [`PeriodState`](../lib/features/astrology/thai/core/life_period/life_period_engine.dart) | **Absent** — planet, ages, progress only | `absentOnRuntime` |
| [`LifeTimeline`](../lib/features/astrology/thai/core/life_period/life_period_engine.dart) | **Absent** | `absentOnRuntime` |
| [`PeriodIntelligence`](../lib/features/astrology/thai/core/life_period/period_intelligence.dart) | **Absent** — natal bonds / elements only | `absentOnRuntime` |
| [`PeriodScores.easeIndex`](../lib/features/astrology/thai/mirror/presentation/timeline/period_composite_score.dart) | **Not rise/fall** — composite domain score | not equivalent |
| [`ThaiMirrorLifePeriodState`](../lib/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart) | **Absent** — narrative strings only | `labelInCanonContextOnly` (UI) |
| Frozen Canon `life_period` context | Present in Canon tokens (e.g. `อาย ๓ ขวบ [ดวงตก]`) | `labelInCanonContextOnly` — not on runtime models |
| Per-person mahabhut placement engine | **Absent** — would need new calculation | `derivableOnlyByNewCalculation` |

**Conclusion:** `BLOCKED_BY_RUNTIME_STATUS_ABSENCE` — status is **not** already computed on runtime output. This phase does **not** add rise/fall calculation or fake status fields.

---

## 2 · What was added (internal only)

| Component | Role |
|---|---|
| [`life_period_status_metadata.dart`](../lib/features/astrology/thai/core/life_period/life_period_status_metadata.dart) | Audit findings, blocker codes, allowed Canon ids, resolver |
| [`ThaiCanonPeriodStatusDiscovery.audit()`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_period_status_discovery.dart) | Production audit → labels when metadata becomes available |
| [`ThaiCanonEvidenceTrace.lifePeriodStatusMetadataBlocker`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_trace.dart) | Explicit blocker on enricher trace (not silent) |

### Allowed values (when engine exposes metadata in a future phase)

| Internal Canon id | Thai label (evidence layer) |
|---|---|
| `periodStatus.duengKhuen` | `ดวงขึ้น` |
| `periodStatus.duengTok` | `ดวงตก` |

Prefer **Canon id** on engine metadata; Thai labels resolved at evidence discovery via [`ThaiCanonPeriodStatusRuntimeMapping`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_period_status_runtime_mapping.dart).

---

## 3 · Was status newly computed?

**No.** Status was **not** already computed. Nothing was newly calculated. The resolver returns an empty index with blocker `BLOCKED_BY_RUNTIME_STATUS_ABSENCE`.

---

## 4 · Canon periodStatus evidence attachment

| Path | periodStatus attachments |
|---|---|
| Production (`ThaiMirrorPipeline` + enricher) | **0** — discovery empty (blocked) |
| QA override (`periodStatusLabelsByIndex`) | Attaches when exact labels injected (unchanged) |

Evidence mapping table from Period Status Mapping phase remains wired; production discovery cannot populate labels until engine metadata exists.

---

## 5 · Updated evidence counts (9 fixtures)

| Metric | Before this phase | After |
|---|---:|---:|
| Thai validation tests | 366 pass | **377 pass** |
| `STRONG_MATCH` | 177 | **177** |
| `periodStatusStructural` attachments (production) | 0 | **0** |
| `skippedPeriodStatusNotes` | 0 | **0** |
| `lifePeriodsWithoutRuntimeStatus` | 86 | **86** (unchanged — metadata still absent) |
| `lifePeriodStatusMetadataBlocker` | — | **`BLOCKED_BY_RUNTIME_STATUS_ABSENCE`** × 9 fixtures |
| `INTERNAL_ONLY` trace rows | 95 | **104** (+9 blocker rows) |

---

## 6 · Proof user-facing output unchanged

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint()` unchanged before/after enrichment.
- Consumer timeline copy (`ThaiMirrorConsumerPresenter`) unchanged — no `ดวงขึ้น`/`ดวงตก` in period summaries.
- No Mirror copy, Daily Mirror, or public UI edits.

---

## 7 · Recommended next phase

**No User-Facing Integration Yet**

Rationale: metadata layer confirms the engine does not yet expose deterministic rise/fall status. A future **Engine Life Period Rise/Fall Metadata** phase must resolve per-person mahabhut placement (or equivalent existing structural output) before production Canon periodStatus evidence can attach. Internal badges or user-facing seams remain premature.

---

## 8 · Later engine phase (out of scope here)

When the life-period engine exposes deterministic status metadata:

1. Populate `LifePeriodStatusMetadataAudit.byPeriodIndex` from existing engine fields only.
2. Clear `lifePeriodStatusMetadataBlocker`.
3. Production `ThaiCanonPeriodStatusDiscovery` will attach `periodStatusStructural` evidence without QA override.
4. `lifePeriodsWithoutRuntimeStatus` will decrease accordingly.

Do **not** infer status from prediction prose, composite scores, or mahabhut position tables without an existing engine resolver.
