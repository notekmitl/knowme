# Thai Canon Evidence Mapping Layer

> **Scope:** Read-only infrastructure — no engine, Mirror, UI, or Canon data changes.
>
> **Frozen Canon:** [`knowledge/canon/production/foundation_v1.knowme.json`](../knowledge/canon/production/foundation_v1.knowme.json)
> · Freeze `2a44ac4` · Integration audit [`THAI_CANON_INTEGRATION_AUDIT.md`](THAI_CANON_INTEGRATION_AUDIT.md)

Status: **COMPLETE** · Internal APIs and tests only.

---

## 1 · What was added

New package under `lib/features/astrology/thai/knowledge/canon/integration/`:

| File | Role |
|---|---|
| `thai_canon_production_loader.dart` | Loads frozen `foundation_v1.knowme.json` from assets (825 units + 28 reference cells) |
| `thai_canon_evidence_index.dart` | Deterministic in-memory query index |
| `thai_canon_evidence_mapper.dart` | Maps ontology/runtime keys → `ThaiCanonEvidenceRef` |
| `thai_canon_evidence_ref.dart` | Internal evidence traceability model |
| `thai_canon_evidence_safety.dart` | Remedy safety classification |
| `thai_canon_ontology_runtime_mapping.dart` | Canon ontology id ↔ existing runtime key table |
| `thai_canon_evidence_repository.dart` | Read-only facade (load + index + mapper) |
| `integration.dart` | Barrel export |

Tests: `test/validation/thai/thai_canon_evidence_mapping_test.dart`

Asset registration: `pubspec.yaml` explicitly bundles `foundation_v1.knowme.json`.

**Not changed:** Thai engines, prediction/decision logic, Mirror composers, Daily Mirror,
thai_beta UI, user-facing copy, frozen Canon JSON.

---

## 2 · Queryable Canon domains

The index supports deterministic queries over loaded production data:

| Domain | Query API | Loaded records |
|---|---|---|
| Foundation significations | `bySubject` / `byObject` / `byRelation` | In 825 atomic units |
| Archetype natal placements | `byContextType(archetypeChart)` / `byContextValue` | Yes |
| Planet library attributes | `byObject('attribute.*')` / `byDomain(planetLibrary)` | Yes |
| Taksa | `byTaksaRole` / `byObject('taksaRole.*')` | 95 units |
| Life Period | `byContextType(lifePeriod)` / `byLifePeriodContext` | 226 units |
| Prediction Rules | `byDomain` + `byObject('predictionEffect.*')` | 5 units |
| Remedies | `byRemedyDomain` / `byDomain(remedies)` | 87 units (**internal-only**) |
| Lookup Tables (atomic) | `byDomain(lookupTables)` | 55 units |
| Reference-table cells | `referenceCellsForTable` / `referenceCellsForPage` | 28 cells |

Loader skips non-unit metadata rows (`$note` entries without `id`) in the production
JSON arrays — the **825 + 28** validated counts are preserved.

---

## 3 · Runtime keys mapped

### Planets → `LifePlanet` enum name

| Canon id | Runtime key | Status |
|---|---|---|
| `planet.sun` | `sun` | Mapped |
| `planet.moon` | `moon` | Mapped |
| `planet.mars` | `mars` | Mapped |
| `planet.mercury` | `mercury` | Mapped |
| `planet.jupiter` | `jupiter` | Mapped |
| `planet.venus` | `venus` | Mapped |
| `planet.saturn` | `saturn` | Mapped |
| `planet.rahu` | `rahu` | Mapped |
| `planet.ketu` | — | **Unmapped** (no `LifePlanet`) |

### Mahabhut positions → `ThaiContentKeys`

| Canon id | Runtime key | Status |
|---|---|---|
| `mahabhutPosition.thongchai` | `mahabhuta_thongchai` | Mapped |
| `mahabhutPosition.athibodi` | `mahabhuta_adhibodi` | Mapped |
| `mahabhutPosition.marana` | `mahabhuta_marana` | Mapped |
| `mahabhutPosition.puti` | `mahabhuta_puti` | Mapped |
| `mahabhutPosition.racha` | `mahabhuta_rachiya` | Mapped |
| `mahabhutPosition.phangkha` | `mahabhuta_pyadhi` | Mapped (Canon ภังคะ → legacy key) |
| `mahabhutPosition.khumsap` | — | **Unmapped** (no content key) |

### No runtime key (explicitly unmapped)

| Ontology category | Count (approx.) | Notes |
|---|---|---|
| `taksaRole.*` | 8 | No Taksa engine keys |
| `periodStatus.*` | 2 | No rise/fall runtime keys |
| `predictionEffect.*` | 2 | Engine uses scoring, not Canon ids |
| `remedy.*` / `remedyItem.*` / `ritualTarget.*` | 20+ | Internal Canon only |
| `archetypeChart.*` | 7 | No birth→archetype resolver |
| `lookupTable.*` / `rotationIndex.*` / `placementDigit.*` | 15+ | Hardcoded chart tables still authoritative |
| `attribute.*` / `attributeCategory.*` | 300+ | No attribute UI surface |

Full unmapped inventory: `ThaiCanonOntologyRuntimeMapping.unmappedCanonEntityIds()`.

---

## 4 · Remedy protection

- Remedy units are **loaded and indexed** (`byRemedyDomain`, `evidenceForRemedyId`).
- Every remedy-domain `ThaiCanonEvidenceRef` carries
  `ThaiCanonEvidenceSafety.remedyInternalOnly`.
- `isNotSafeForUserOutput` is **true** for all remedy evidence.
- **No** display copy, recommendation copy, or UI wiring was added.

Example internal query (tests only):

```dart
final repo = await ThaiCanonEvidenceRepository.loadFromAsset();
final refs = repo.mapper.evidenceForRemedyId('remedy.sadoeKhroh');
assert(refs.every((r) => r.safety.isNotSafeForUserOutput));
```

---

## 5 · Runtime output unchanged

Proof via `thai_canon_evidence_mapping_test.dart`:

1. **`ThaiMirrorPipeline.generate`** structural fingerprint identical before and after
   loading `ThaiCanonEvidenceRepository`.
2. **No imports** from `integration/` in engine, Mirror, or presentation layers.
3. Full Thai validation suite: **306 / 306 pass** (287 prior + 19 new mapping tests).

The evidence layer answers *“Given a signal, what Canon evidence exists?”* — it does
**not** change *“Given a birth chart, what does the app say?”*

---

## 6 · Usage (internal)

```dart
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';

final repo = await ThaiCanonEvidenceRepository.loadFromAsset();

// Planet + domain signification
final learning = repo.mapper.evidenceForSubjectAndObject(
  subject: 'planet.jupiter',
  object: 'domain.learning',
);

// Mahabhut position placements
final thongchai = repo.mapper.evidenceForMahabhutPosition(
  'mahabhutPosition.thongchai',
);

// Runtime content key → Canon evidence
final fromKey = repo.mapper.evidenceForRuntimeContentKey(
  'mahabhuta_thongchai',
);
```

---

## 7 · Recommended next phase

**Thai Report Canon Evidence Upgrade**

Attach `ThaiCanonEvidenceRef` lists to existing source-transparency / evidence-explorer
view models **without** changing Mirror copy or engine calculations. Remedy refs remain
blocked from user-facing surfaces until a separate Remedy Safety policy phase.

---

## 8 · Related documents

| Document | Role |
|---|---|
| [`THAI_CANON_INTEGRATION_AUDIT.md`](THAI_CANON_INTEGRATION_AUDIT.md) | Pre-implementation audit |
| [`THAI_MAHABHUT_CANON_FREEZE.md`](THAI_MAHABHUT_CANON_FREEZE.md) | Phase I freeze record |
