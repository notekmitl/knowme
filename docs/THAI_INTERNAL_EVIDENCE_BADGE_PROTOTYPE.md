# Thai Internal Evidence Badge Prototype

**Phase:** Internal Evidence Badge Prototype  
**Status:** Complete (internal QA only)  
**Prerequisite commits:** Mahabhut Canon Complete freeze, Canon Evidence Mapping Layer, Thai Report Canon Evidence Upgrade, Thai Beta Canon Evidence Review Panel, Thai Canon Evidence Alignment QA, Period/Remainder/Archetype/Position/Rise-Fall metadata chain

## Objective

Add deterministic internal QA badges for Canon evidence review. Badges communicate evidence quality and integration readiness for reviewers — not user-facing truth, prediction confidence, or advice.

## Badge categories

| Wire | Label | Meaning |
|------|-------|---------|
| `CANON_SUPPORTED` | Canon Supported | Strong Canon evidence attached (alignment `STRONG_MATCH`) |
| `PARTIAL_CANON_SUPPORT` | Partial Evidence | Evidence exists but coverage is partial or trace-only |
| `CANON_DERIVED_INTERNAL` | Canon Derived (Internal) | Canon context marker / structural evidence without runtime user-facing fields |
| `RUNTIME_METADATA_SUPPORTED` | Runtime Metadata Supported | Runtime metadata chain supports evidence (e.g. rise/fall from position) |
| `OUT_OF_CANON_SCOPE` | Out of Canon Scope | Myanmar seven, Lagna sign, mahabhuta_thaya, or other out-of-scope signals |
| `BLOCKED_AMBIGUOUS` | Blocked Ambiguous | Matching blocked by ambiguous Canon placement |
| `BLOCKED_SOURCE_CONFLICT` | Source Conflict | Matching blocked by retained source conflict |
| `INTERNAL_ONLY` | Internal Only | Valid for QA but not allowed for user display |
| `REMEDY_HIDDEN` | Remedy Hidden | Remedy evidence exists but must not be shown as advice |
| `NO_CANON_EVIDENCE` | No Canon Evidence | In-scope signal with no deterministic Canon evidence |

## Badge assignment rules

Assignment is deterministic via `ThaiInternalEvidenceBadgeAssigner`:

1. **Attachments**
   - `remedyInternal` → `REMEDY_HIDDEN`
   - Signal contains `:periodStatus:canonDerived:` → `CANON_DERIVED_INTERNAL`
   - `periodStatusStructural` + `STRONG_MATCH` → `RUNTIME_METADATA_SUPPORTED`
   - `periodStatusStructural` + weak alignment → `PARTIAL_CANON_SUPPORT`
   - Alignment `STRONG_MATCH` (other types) → `CANON_SUPPORTED`
   - Alignment `RELATED_BUT_WEAK` → `PARTIAL_CANON_SUPPORT`
   - Alignment `UNMAPPED_SIGNAL` → `NO_CANON_EVIDENCE`
   - Alignment `OUT_OF_CANON_SCOPE` → `OUT_OF_CANON_SCOPE`
   - Alignment `SKIPPED_REMEDY` → `REMEDY_HIDDEN`
   - Alignment `SKIPPED_TAKSA` / `SKIPPED_PERIOD_STATUS` / `INTERNAL_ONLY` → `INTERNAL_ONLY`

2. **Trace signals** (`forTraceSignal`)
   - `outOfCanonScopeSignals` → `OUT_OF_CANON_SCOPE`
   - `inCanonScopeUnmappedSignals` → `NO_CANON_EVIDENCE`
   - `traceOnlyEvidenceCandidates` → `PARTIAL_CANON_SUPPORT`
   - `trace:skipped_remedy` → `REMEDY_HIDDEN`
   - Runtime status / rise-fall traces → `RUNTIME_METADATA_SUPPORTED`
   - Canon-derived status traces → `CANON_DERIVED_INTERNAL`
   - Ambiguous / source-conflict blockers → `BLOCKED_AMBIGUOUS` / `BLOCKED_SOURCE_CONFLICT`

3. **Summary aggregation** (`ThaiInternalEvidenceBadgeSummary.fromBundle`)
   - Counts per attachment badge
   - Adds trace-level counts for out-of-scope, unmapped, ambiguous, conflict, remedy, trace-only

Weak evidence is never promoted to `CANON_SUPPORTED`. Ambiguous and conflict cases are surfaced, not hidden.

## Where badges are rendered

**Internal only** — route `/internal/thai-canon-evidence` (admin-guarded):

| Surface | Badges shown |
|---------|----------------|
| Summary cards | Canon Supported, Runtime Metadata Supported, Partial Evidence, Canon Derived, Out of Canon Scope, Blocked Ambiguous, Source Conflict, Remedy Hidden, No Canon Evidence |
| Evidence table | Badge column (wire label per row) |
| Trace panel | Badge labels on remedy, Taksa, ambiguous/conflict blockers, runtime status sources, unmapped/out-of-scope/trace-only sections |

**Not rendered on:** Thai Mirror result page, Thai beta public result, consumer report sections, prediction copy, Mirror copy.

## Implementation files

- `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_internal_evidence_badge.dart` — model + assigner + summary
- `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_summary.dart` — badge on rows + summary
- `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_page.dart` — UI
- `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classifier.dart` — public `classifyAttachment` for badge rules
- `test/validation/thai/thai_internal_evidence_badge_test.dart`
- `test/validation/thai/thai_canon_evidence_review_panel_test.dart` (extended)

## Safety boundary

| Domain | Allowed internally | Forbidden publicly |
|--------|-------------------|-------------------|
| Remedy evidence | Count, `REMEDY_HIDDEN` badge, unit ids in trace | Procedure text, advice, `userFacingAllowed = true` |
| Prediction evidence | Internal badge on attachment | Prediction copy change, public confidence score |
| Rise/fall | Internal badge, trace blockers | ดวงขึ้น / ดวงตก on public report |
| Canon source | Unit id, page, relation metadata | Source prose |
| All evidence | `userFacingAllowed = false` | Any user-facing badge or label |

Frozen Canon data (`foundation_v1.knowme.json`) was not modified. No new Canon units were added.

## QA sample coverage (post metadata re-run baseline)

On `ThaiMirrorPipeline.sampleQaBirthData()` fixture:

- Attachments badged per alignment + period-status rules
- `blockedAmbiguous` trace count = 18 (AMBIGUOUS_POSITION blockers)
- `blockedSourceConflict` trace count = 3 (SOURCE_CONFLICT blockers)
- `remedyHidden` includes skipped remedy count (87 units)
- `runtimeMetadataSupported` / `canonDerivedInternal` from period-status attachments
- `outOfCanonScope` / `noCanonEvidence` from trace signal lists

## Proof public output did not change

Validated by tests:

1. `ThaiReportCanonEvidenceEnricher.userFacingFingerprint` unchanged before/after enrichment
2. `ThaiMirrorConsumerPresenter` timeline text unchanged (no ดวงขึ้น / ดวงตก)
3. `thai_beta_report_page.dart` and `thai_mirror_result_page.dart` do not import badge layer
4. Full Thai validation suite remains green (551 tests)

## Recommended next phase

**Internal Evidence QA Pass**

Reviewers should use the badge summary and trace panel on `/internal/thai-canon-evidence` to triage the 18 ambiguous and 3 source-conflict blockers, confirm remedy/taksa skip counts, and sign off before any runtime mapping expansion (Taksa/Khumsap) or user-facing integration.
