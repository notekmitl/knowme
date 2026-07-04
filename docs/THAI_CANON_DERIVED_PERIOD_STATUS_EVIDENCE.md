# Thai Canon-Derived Period Status Evidence Annotation

Internal periodStatus evidence from exact Canon `life_period` context markers. No engine calculation, no user-facing changes.

**Commit:** Thai Canon-Derived Period Status Evidence Annotation  
**Prerequisites:** Thai Life Period Status Metadata Layer (`0577d0a`)

---

## 1 · Runtime status still blocked

Engine output still does **not** expose ดวงขึ้น / ดวงตก.

| Trace field | Value |
|---|---|
| `lifePeriodStatusMetadataBlocker` | `BLOCKED_BY_RUNTIME_STATUS_ABSENCE` |
| `lifePeriodsWithoutRuntimeStatus` | All life-period anchors (86 across 9 fixtures) |

The blocker **remains** — Canon-derived annotation does not replace runtime metadata.

---

## 2 · How Canon-derived annotation works

1. [`ThaiReportCanonEvidenceEnricher`](../lib/features/astrology/thai/knowledge/canon/integration/thai_report_canon_evidence_enricher.dart) attaches `lifePeriodStructural` evidence per life-period planet.
2. [`ThaiCanonPeriodStatusFromEvidence`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_period_status_from_evidence.dart) scans those refs' `contextType == life_period` values for exact markers.
3. When markers are **unambiguous** across marked refs, enricher attaches `periodStatusStructural` with signal id `…:periodStatus:canonDerived:periodStatus.*`.
4. PeriodStatus Canon refs are loaded via [`evidenceForPeriodStatusCanonId`](../lib/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_mapper.dart) **excluding remedy-domain units** (e.g. `remedy.sadoeKhroh → periodStatus.duengTok` stays skipped).

Runtime QA override (`periodStatusLabelsByIndex`) takes precedence per period index.

---

## 3 · Exact marker rules

| Canon context marker | Canon id |
|---|---|
| `[ดวงขึ้น]` | `periodStatus.duengKhuen` |
| `[ดวงตก]` | `periodStatus.duengTok` |

Requirements:

- Marker must appear in `contextValue` on an already-attached `life_period` ref.
- Both markers on one context → **ambiguous** (skip).
- Conflicting markers across refs → **ambiguous** (skip).
- No marker on any ref → `lifePeriodsWithoutCanonStatusMarker`.
- **No** inference from mahabhut object, planet, easeIndex, or narrative copy.

---

## 4 · Trace split

| Field | Meaning |
|---|---|
| `lifePeriodsWithoutRuntimeStatus` | No engine/runtime label (still all periods in production) |
| `lifePeriodsWithCanonDerivedStatus` | Unambiguous Canon marker → internal periodStatus attached |
| `lifePeriodsWithoutCanonStatusMarker` | Structural evidence but no unambiguous marker |
| `lifePeriodStatusMetadataBlocker` | Unchanged — engine metadata absent |

---

## 5 · QA classification

Canon-derived `periodStatusStructural` attachments classify as **`INTERNAL_ONLY`**, not `STRONG_MATCH`.

Runtime-mapped attachments (QA override) remain `STRONG_MATCH` when label matches.

---

## 6 · Updated counts (QA sample fixture)

| Metric | Before | After |
|---|---:|---:|
| Thai validation tests | 376 pass | **388 pass** |
| `periodStatusStructural` (canon-derived) | 0 | **6** attachments (qa_sample) |
| `lifePeriodsWithCanonDerivedStatus` | 0 | **52** (9 fixtures aggregate) |
| `lifePeriodsWithoutCanonStatusMarker` | — | **34** (9 fixtures aggregate) |
| `lifePeriodsWithoutRuntimeStatus` | 86 (9 fixtures) | **86** (unchanged) |
| `lifePeriodStatusMetadataBlocker` | present | **still present** |
| Remedy attachments | 0 | **0** |

Aggregate alignment: canon-derived attachment records add `INTERNAL_ONLY` rows; `STRONG_MATCH` unchanged for production fixtures.

---

## 7 · Remaining limitations

- Canon-derived status is **planet-level** (all `life_period` units for that period's planet) — not age-scoped to the user's exact period window.
- Periods whose planet corpus mixes `[ดวงขึ้น]` and `[ดวงตก]` markers remain without canon-derived status.
- Runtime metadata still required for true per-person period status without relying on Canon corpus ambiguity rules.

---

## 8 · Public output proof

`userFacingFingerprint()` unchanged. Consumer timeline copy unchanged. All periodStatus attachments: `userFacingAllowed = false`.

---

## 9 · Recommended next phase

**Engine Life Period Rise/Fall Metadata**

Rationale: Canon-derived annotation covers a subset via frozen context markers, but runtime remains blocked and marker resolution is planet-corpus-limited. Engine metadata is the path to deterministic per-period status without Canon corpus ambiguity.

---

## Files touched

| File | Role |
|---|---|
| `thai_canon_period_status_from_evidence.dart` | Marker extractor |
| `thai_report_canon_evidence_enricher.dart` | Canon-derived attach + trace |
| `thai_canon_evidence_trace.dart` | New trace lists |
| `thai_canon_evidence_mapper.dart` | Exclude remedy domain from periodStatus refs |
| `thai_canon_evidence_alignment_classifier.dart` | INTERNAL_ONLY for canon-derived |
| `presentation/thai_canon_evidence_review_page.dart` | Trace panel |
| `integration.dart` | Export |
| `thai_canon_derived_period_status_evidence_test.dart` | Tests |
| Updates to period-status / metadata tests | Expectations |
