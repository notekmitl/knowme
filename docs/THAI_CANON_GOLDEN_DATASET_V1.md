# KnowMe Canon Platform — Golden Canon Dataset V1

> The Canon Platform Foundation is **COMPLETE** (Authoring Studio, Workspace,
> Ontology, Atomic Knowledge). This milestone adds the first **Golden Dataset** —
> the official QA reference / regression suite that all future Canon extraction,
> validation and pipeline changes are verified against. **No new platform
> infrastructure.**

Status: **CURRENT** · Decision Log **D-063** · QA assets only · Engine frozen ·
No deploy · No UI.

Module: `lib/features/astrology/thai/knowledge/canon/golden/` (pure Dart).
Depends read-only on the atomic + ontology + workspace layers; no engine/runtime
dependency.

---

## Principle

The Golden Dataset exists only to verify the **Canon pipeline**:

```
Extraction → Validation → Ontology Resolution → Workspace → Import →
Knowledge Graph → Completeness
```

It is **not production knowledge** and **no astrology engine consumes it**. It is
a Canon QA asset: synthetic fixtures with declared, deterministic expected
outcomes. **No copyrighted book text. No invented astrology facts.** Entities are
structural placeholders from the standard ontology (planets / houses / elements /
domains) plus a few clearly-synthetic tokens (e.g. `planet.nibiru`) used only to
drive negative cases.

## Dataset model — `golden_dataset.dart`

A `GoldenDataset` carries: `id`, `description`, `version`, `sourceType`
(`syntheticValid` / `syntheticInvalid`), an `ExtractionSource`, the incoming
`units`, an optional `baseline`, an optional custom `ontology`, and a
`GoldenExpectation`. Deterministic `versionTag` (`<id>@v<version>`) and
`fingerprint` (FNV-1a over canonical JSON) provide reproducible versioning.

`GoldenExpectation` is the **regression contract**: expected unit count, ontology
coverage (`allResolved`), graph shape (nodes/edges), validation result
(`valid` + `errorCodes`), import result (`diff` counts + `readyForImport`), and
completeness change (`totalUnitsDelta`, `verifiedRelationshipsDelta`).

## Verifier — `golden_verifier.dart`

`GoldenVerifier.run/verify` drives the **real** Canon pipeline — the same
`WorkspaceValidator`, `KnowledgeDiff`, `CompletenessDelta` and `ReviewReport` the
workspace uses (no logic reimplemented) — and compares the observed `GoldenActual`
against the declared expectation, returning a `GoldenVerification` with a stable,
field-ordered list of `GoldenMismatch`. `passes(d)` is the regression signal.

## Catalog — `golden_datasets.dart`

Ten deterministic fixtures (`GoldenDatasets.all()`):

| Dataset | Exercises |
| --- | --- |
| `golden.minimal` | empty corpus — nothing to import, import-ready |
| `golden.single_planet` | 3 atomic facts about one planet (NEW ×3) |
| `golden.single_house` | 2 atomic facts about one house |
| `golden.planet_house` | mixed planet + house corpus |
| `golden.conflict` | same id changes fact vs. baseline → **CONFLICT**, not import-ready |
| `golden.duplicate` | two ids assert one fact → `duplicate_knowledge` + `graph_duplicate_edge` |
| `golden.ontology_failure` | unresolved subject → `ontology_unresolved_subject` |
| `golden.relationship_failure` | unregistered relationship (custom ontology) → `relationship_not_registered` |
| `golden.coverage_increase` | 2 verified planet relationships → `verifiedRelationshipsDelta +2` |
| `golden.deprecated` | baseline fact dropped → **UNCHANGED** + **DEPRECATED**, `totalUnitsDelta -1` |

The `relationship_failure` fixture builds a **custom ontology missing `opposes`**
rather than mutating the shared ontology — failures are never created by changing
real data.

## Reports — `golden_report.dart`

Deterministic, structured (non-narrative) renderings, all reusing the workspace
`ReviewReport`:

- `forDataset(d)` — metadata + fingerprint + ontology coverage + graph shape +
  validation + diff + completeness + import verdict + PASS/FAIL with mismatches.
- `validationReport` / `diffReport` / `coverageReport` / `importReport` — focused
  views.
- `forCatalog(list)` — regression summary (per-dataset PASS/FAIL + fingerprints).
- `catalogPasses(list)` — whole-suite regression signal.

## Validation (tests)

`test/validation/thai/thai_canon_golden_test.dart` (18 tests): required dataset
types present; **every dataset reproduces its expected outcome exactly** (+ whole
catalog); verification and reports are **byte-for-byte deterministic**; dataset
versioning + fingerprints are deterministic and distinct; **regression detection
works** (a tampered expectation is flagged; a version bump changes the
fingerprint); reports show the verdict; and decoupling (no
engine/runtime/matrix/mirror/fusion/narrative/flutter imports). Full canon suite
(149 tests) green; `flutter analyze` clean.

## Constraints honoured

- QA datasets only — no UI, no runtime/engine/matrix change, no deploy.
- Untouched: Authoring Studio, Workspace, Ontology, Knowledge Graph, Atomic
  Knowledge, Rule Engine, Timeline, Prediction, Decision, Runtime, Mirror,
  Conversation, Fusion, `PlanetRelationshipMatrix`. The golden layer consumes them
  read-only and **reuses** the workspace pipeline.
- No fabricated knowledge and no copyrighted text — synthetic structural fixtures
  only.
