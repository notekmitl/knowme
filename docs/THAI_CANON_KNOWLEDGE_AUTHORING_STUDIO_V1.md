# KnowMe Canon Platform — Knowledge Authoring Studio V1

> The Canon **Foundation and Workspace are complete**. This milestone adds the
> **official human editing layer** that sits *before* the Workspace, to make
> page-by-page knowledge production practical. It is an **authoring tool only** —
> not runtime, not an engine. No new platform infrastructure.

Status: **CURRENT** · Decision Log **D-062** · Authoring layer only · Engine
frozen · No deploy · No UI.

Module: `lib/features/astrology/thai/knowledge/canon/authoring/` (pure Dart).
Depends read-only on the atomic + ontology + workspace layers; no engine/runtime
dependency.

---

## Workflow

```
Reference Book Page → Authoring Studio → Draft Knowledge Units → Workspace
Validation → Diff → Review → Canon Import
```

Drafts are editable; **nothing created here is Canon**. Import happens only
through the Workspace.

## 1 · Draft Knowledge Unit — `draft_knowledge_unit.dart`

`DraftKnowledgeUnit` is the editable mirror of an `AtomicKnowledgeUnit`: subject,
relation, object (+ kinds), condition, effect, strength, confidence, evidence
reference, domain, notes. It stays atomic (one subject/relation/object) — **no
narrative fields**. `toAtomic()` is a total conversion that drives the Workspace
validator; `factKey` is the deterministic fact identity.

## 2 · Ontology Assistance — `ontology_assist.dart`

Each subject/object is classified against the Canonical Ontology:

- **Resolved** — resolves by id or alias.
- **MissingOntology** — looks like a canonical id (`<knownCategory>.<slug>`) but
  the entity isn't in the ontology yet → add the ontology entry first.
- **Unknown** — not resolvable and not a recognizable id → the reviewer must map
  or rename it.

The studio **never auto-creates ontology entries**. `allResolved()` gates a clean
authoring state; the reviewer must resolve every unknown before validation.

## 3 · Batch Editing — `authoring_studio.dart`

One page can yield dozens of units. Editing operations (deterministic, never
throw) — all keep the output atomic:

- `addDraft` — seeds evidence from the page being authored (book/chapter/page).
- `duplicate(id)` — copy with a fresh id, inserted right after.
- `split(id, [objects])` — replace one draft with one atomic draft per object
  (subject/relation kept). E.g. *Jupiter owns A, B, C* → 3 units.
- `merge(ids)` — collapse **same-fact** drafts (keeps strongest confidence / a
  referenced evidence). Rejected when facts differ — merging never breaks
  atomicity.
- `delete(id)`, `reorder(old, new)` — bounds-checked.

Ids are generated deterministically (`<studio>-uNNN`) from a serialized `seq`.

## 4 · Validation Preview — reuses the Workspace, no duplicated logic

`validate(ontology, baseline)` delegates to **`WorkspaceValidator.validate`** on
`toSession()`; `preview(...)` returns the Workspace's own `ReviewReport`
(validation + diff + coverage impact). The preview is therefore **byte-for-byte
the same** as what the Workspace will produce — verified by test (issue
signatures equal). No validation logic is reimplemented.

## 5 · Export / Import — `toJson()` / `fromJson()`

Serializes id, `seq`, source and every draft (with order). Importing reproduces
the **identical** editing state, and continued editing yields the same next ids —
so unfinished work resumes deterministically.

## Validation (tests)

`test/validation/thai/thai_canon_authoring_test.dart` (11 tests): page-provenance
seeding + ontology resolution; assist distinguishes resolved/missing/unknown;
**deterministic** ontology resolution; batch edits (split/duplicate/merge/reorder/
delete) preserve atomicity and bounds; **validation preview equals
`WorkspaceValidator`** on the same session (+ deterministic `ReviewReport`);
export/import reproduces the identical draft (ids/order/seq/fields, same next id);
and decoupling (no engine/runtime/matrix/mirror/fusion/narrative/flutter imports).
Full canon suite (131 tests) green; `flutter analyze` clean.

## Constraints honoured

- Authoring layer only — no UI, no runtime/engine/matrix change, no deploy.
- Untouched: Workspace, Ontology, Knowledge Graph, Atomic Knowledge, Rule Engine,
  Timeline, Prediction, Decision, Runtime, Mirror, Conversation, Fusion,
  `PlanetRelationshipMatrix`. The studio consumes them read-only and **reuses**
  the Workspace validator.
- No fabricated knowledge — drafts are reviewer-authored; provenance reference
  only (D-057); nothing here is Canon until imported via the Workspace.
