# Thai Report Canon Evidence Upgrade

> **Scope:** Evidence enrichment only — no engine, Mirror copy, UI, or Canon changes.
>
> **Prerequisites:** Canon Freeze `2a44ac4` · Integration Audit `ca96e91` · Evidence
> Mapping Layer `4c5a584`

Status: **COMPLETE** · Internal metadata only — user-facing output unchanged.

---

## 1 · What was added

New types under `lib/features/astrology/thai/knowledge/canon/integration/`:

| Component | Role |
|---|---|
| `ThaiCanonEvidenceAttachment` | Internal metadata for one report signal |
| `ThaiCanonEvidenceTrace` | Unmapped / skipped evidence audit |
| `ThaiMirrorCanonEvidenceBundle` | Pipeline result + attachments + trace |
| `ThaiReportCanonEvidenceEnricher` | Enrichment entry point (read-only) |
| `ThaiCanonEvidenceType` | Domain classifier for attachments |

Tests: `test/validation/thai/thai_report_canon_evidence_upgrade_test.dart`

**Not changed:** `ThaiMirrorPipeline`, engines, composers, `ThaiContentRegistry`,
user-visible strings, frozen Canon JSON.

---

## 2 · What evidence can attach

| Domain | Trigger | Attachment type | User-facing |
|---|---|---|---|
| Mahabhut positions | Section `ThaiMirrorEvidence` with `mahabhutaPosition` lens + profile `mahabhutaPositionKeys` | `mahabhutPosition` | No |
| Planet significations | Section evidence with `lagnaLord` lens → `planet.*` owns / attribute relates_to | `planetSignification` | No |
| Life Period structure | `LifeTimeline` period → `planet.*` located_in `mahabhutPosition.*` @ `life_period` | `lifePeriodStructural` | No |
| Prediction rules | Phase E `periodStatus.*` produces/opposes/relates_to rules | `predictionRule` (internal section id) | No |
| Taksa | Only if exact runtime key present | Not attached (no runtime keys) | No |
| Remedies | Indexed but skipped | Trace count only | **Never** |

All attachments default to `internalOnly: true`, `userFacingAllowed: false`.

---

## 3 · Report areas with Canon evidence (QA sample profile)

For `ThaiMirrorPipeline.sampleQaBirthData()` enrichment produces:

- **Mahabhut position** attachments per active content key (section + profile signals)
- **Planet signification** attachments for lagna-lord section evidence rows
- **Life-period structural** attachments per timeline period (8 periods)
- **Prediction rule** attachment (`prediction:phase_e_rules`) with Phase E Canon refs

Evidence ref count scales with profile content (planet library refs per lagna lord).

---

## 4 · Report areas still on hardcoded content

| Area | Source | Canon attachment |
|---|---|---|
| Mirror narrative / hero copy | `ThaiMirrorConsumerCopy`, evidence composer | None (by design) |
| Lagna sign prose | `ThaiContentRegistry` lagna sections | Signal listed in trace as unmapped |
| Myanmar seven prose | Content library | Signal listed in trace as unmapped |
| Life timeline consumer copy | Timeline composers | Structural Canon refs only — copy unchanged |
| Future prediction copy | `PredictionComposer` | Internal rule refs only — text unchanged |
| Daily Mirror | Fusion Runtime | Out of scope |
| thai_beta UI | Wraps pipeline | Out of scope |

---

## 5 · Unmapped report areas (internal trace)

`ThaiCanonEvidenceTrace` records (not shown to users):

| Category | Example |
|---|---|
| Signals without Canon evidence | `coreSelf:lagna_aries`, `*:myanmar_seven_*` |
| Runtime keys without Canon map | Keys with no `ThaiContentKeys` ↔ ontology pairing |
| Canon candidates without runtime | `taksaRole.*`, `periodStatus.*`, `planet.ketu` |
| Skipped remedy evidence | **87** units (count only) |
| Skipped Taksa evidence | Taksa assignment units (count only) |
| Skipped periodStatus | `periodStatus.duengKhuen/duengTok` — no runtime rise/fall keys |

Access via `bundle.trace` after `ThaiReportCanonEvidenceEnricher.enrich(...)`.

---

## 6 · Remedy safety boundary

- Remedy Canon is **never** attached to report sections.
- No attachment uses `ThaiCanonEvidenceType.remedyInternal`.
- No attachment sets `userFacingAllowed: true`.
- `trace.skippedRemedyEvidenceCount == 87` documents intentional exclusion.
- No remedy advice or display copy was generated.

---

## 7 · Proof user-facing output did not change

Validation (`thai_report_canon_evidence_upgrade_test.dart`):

1. `ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline)` identical before and after enrichment.
2. `identical(bundle.pipelineResult, pipeline)` — pipeline object not replaced.
3. `identical(pipeline.mirrorResult, …)` / `viewState` / `profile` — no mutation.
4. Full Thai suite: **317 / 317 pass** (307 prior + 10 upgrade tests).

Fingerprint covers: mirror themes/sections/summaries, view hero, view section titles, profile mahabhuta keys.

---

## 8 · Usage (internal)

```dart
final pipeline = ThaiMirrorPipeline.generate(birthData);
final bundle = await ThaiReportCanonEvidenceEnricher.enrich(pipeline);

// User-facing output — unchanged
final viewState = bundle.pipelineResult.viewState;

// Internal QA metadata
final attachments = bundle.attachments;
final unmapped = bundle.trace.signalsWithoutCanonEvidence;
```

---

## 9 · Recommended next phase

**Thai Engine Canon Integration (evidence-only seam)**

Wire `ThaiCanonEvidenceAttachment` into engine/signal trace objects as optional
metadata — still without changing calculation results or Mirror copy. Alternatively,
enable source-transparency UI behind an internal QA flag only (not consumer-facing).

---

## 10 · Related documents

| Document | Role |
|---|---|
| [`THAI_CANON_EVIDENCE_MAPPING_LAYER.md`](THAI_CANON_EVIDENCE_MAPPING_LAYER.md) | Loader / index / mapper |
| [`THAI_CANON_INTEGRATION_AUDIT.md`](THAI_CANON_INTEGRATION_AUDIT.md) | Pre-integration audit |
