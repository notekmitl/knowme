# KnowMe Canon Platform — Knowledge Extraction Workspace V4

> Knowledge-platform refinement only. **No architecture redesign, no engine
> change, no runtime change, no deploy.** This milestone builds the production
> environment for converting Canon books into Atomic Knowledge. The workspace is
> the **only supported path** for adding new Canon knowledge.

Status: **CURRENT** · Decision Log **D-060** · Workspace only · Engine frozen.
Builds on Atomic Knowledge V2 (D-058), Canonical Ontology V3 (D-059) and the
provenance policy (D-057).

Module: `lib/features/astrology/thai/knowledge/canon/workspace/` (pure Dart). No
engine depends on it; it depends on no engine/runtime/matrix/mirror/fusion.

---

## Workflow

```
Book Page → Extraction Workspace → Atomic Knowledge Units → Ontology Validation →
Knowledge Graph Validation → Review → Canon Database
```

Nothing enters Canon directly: every imported unit belongs to one session.

## 1 · Extraction Session — `knowledge_extraction_session.dart`

`KnowledgeExtractionSession` owns the lifecycle and holds the session's
`AtomicKnowledgeUnit`s + provenance. States:

```
Draft → Extracting → Validated → Reviewed → Approved → Imported → Archived
```

`transitionTo()` is a deterministic state machine: forward edges, explicit
backward edges (re-extract / re-validate / re-review), archive from any
non-terminal state, and illegal jumps (e.g. Draft→Imported) are rejected with a
stable reason.

## 2 · Source Page Tracking — `extraction_source.dart`

`ExtractionSource` records **provenance only**: book, edition, chapter, page
range, reviewer, extraction date and progress (`pagesDone/pagesPlanned`). It
never stores copyrighted paragraphs (D-057); `hasReference` is true when a page
range or chapter is present.

## 3 · Workspace Validator — `workspace_validator.dart`

`WorkspaceValidator.validate(session, ontology, baseline)` → deterministic
`WorkspaceValidationReport`. Failure classes (all blocking errors):

| code | class |
| --- | --- |
| `atomicity_*` | atomicity (one fact/meaning/rule; rejects narrative; duplicate id) |
| `ontology_unresolved_subject` / `ontology_unresolved_object` | entity not in the ontology |
| `relationship_not_registered` | relation not in the ontology registry |
| `missing_evidence_reference` | no book reference |
| `duplicate_knowledge` | same fact under different unit ids |
| `graph_contradiction` / `graph_duplicate_edge` | conflicts within the session graph |
| `graph_baseline_conflict` | session contradicts existing Canon (e.g. opposes vs supports) |
| `coverage_no_impact` (warning) | session would not change coverage |

## 4 · Knowledge Diff — `knowledge_diff.dart`

`KnowledgeDiff.compute(baseline, incoming)` classifies each unit (identity = unit
id) as **NEW / UPDATED / UNCHANGED / CONFLICT / DEPRECATED**. A changed *fact*
(subject/relation/object/condition) under a stable id is a **CONFLICT**; a changed
*qualifier* (strength/confidence/evidence/notes) is an **UPDATE**. Canon is never
overwritten blindly — conflicts surface for review. Deterministic (sorted).

## 5 · Completeness Integration — `completeness_delta.dart`

`CompletenessDelta.forImport(baseline, incoming, diff)` applies the diff (NEW +
UPDATED add/replace by id; DEPRECATED remove; **CONFLICT not applied**) and
computes before/after `CanonCompletenessReport`s plus deltas: total units,
verified relationships, unknown relationships and per-domain present counts.
Reviewers immediately see coverage increase / new unknowns / new verified
knowledge. Deterministic.

## 6 · Review Report — `review_report.dart`

`ReviewReport.build(session, ontology, baseline)` → a single deterministic,
**structured (non-narrative, no-AI)** decision surface: session summary, unit
count, validation, diff, coverage delta, warnings and `readyForImport`
(= validation has no errors **and** the diff has no conflicts).

## Validation (tests)

`test/validation/thai/thai_canon_workspace_test.dart` (14 tests): deterministic
session lifecycle (full happy path + illegal-jump rejection + archive),
validator catches every failure class (atomicity, ontology subject/object,
relationship registration, evidence, duplicate, graph contradiction, baseline
conflict) + deterministic report, diff classifies all five kinds + deterministic,
completeness delta deterministic (and conflicts not applied), review report
deterministic + import gating, and decoupling (no engine/runtime/matrix/mirror/
fusion/narrative/flutter imports). Full canon suite (109 tests) green; `flutter
analyze` clean.

## Constraints honoured

- No architecture redesign, no new engine, no UI, no runtime behaviour change,
  not deployed.
- Untouched: Ontology, Knowledge Graph logic, Atomic Knowledge, Rule Engine,
  Timeline, Prediction, Decision, Runtime, Mirror, Conversation, Fusion,
  `PlanetRelationshipMatrix`. The workspace consumes those layers read-only.
- Provenance only — never stores copyrighted paragraphs (D-057); no fabricated
  knowledge.
