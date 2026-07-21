# KnowMe Canon Platform — Atomic Knowledge Foundation V2

> Knowledge-platform refinement only. **No architecture redesign, no engine
> change, no UI, no runtime behaviour change, no deploy.** This milestone moves
> the Canon Platform from a **Statement-based** model to an **Atomic Knowledge**
> model and makes Canon a **knowledge graph**.

Status: **CURRENT** · Decision Log **D-058** · Knowledge platform only · Engine
frozen. Builds on the frozen platform (D-056) and the provenance policy (D-057).

Module: `lib/features/astrology/thai/knowledge/canon/atomic/` (pure Dart).

---

## Direction

```
Book → Atomic Knowledge → Knowledge Graph → Rule Engine → Reasoning → Narrative
```

NOT `Book → Statement → Narrative`. Narrative is **generated** from the knowledge
layer; it is never stored as Canon.

## Terminology shift

| Old | New |
| --- | --- |
| Statement (free text) | **Knowledge Unit** = one **atomic fact** |
| Paragraph in the DB | Atomic facts in a **Knowledge Graph** |
| File-count coverage | **Knowledge-domain** completeness |

The free-text `statement` on candidate/DB units is now **working material** only;
the canonical object is the `AtomicKnowledgeUnit`.

## 1 · Knowledge Unit (atomic) — `atomic_knowledge_unit.dart`

`AtomicKnowledgeUnit` represents **one atomic fact**:

```
subject (entity) --relation--> object (entity)   [+ condition, effect, strength]
```

e.g. `jupiter --owns--> wealth`, `condition = jupiter_in_house_2`,
`strength = high`, `confidence = high`, `evidence = {book, chapter, page}`.

- Exactly one `(subject, relation, object)`.
- `subjectKind` / `objectKind` (`AtomicEntityKind`: planet/house/sign/domain/
  meaning/rule/condition/effect/remedy/period/aspect/other).
- `condition` / `effect` are single structured tokens (not prose).
- `strength` (`AtomicStrength`), `confidence` (`KnowledgeConfidence`).
- `evidence` is an `AtomicEvidenceRef` — **reference only** (book/chapter/section/
  page + optional short locator), never copyrighted text (D-057).
- `label` renders a deterministic structured string (e.g. `jupiter owns wealth`),
  which is a label — never narrative.

### GOOD vs BAD

```
GOOD  jupiter --owns--> wealth   (strength=high, condition=jupiter_in_house_2)
BAD   "Jupiter in House 2 usually brings financial success…"   ← narrative
```

## 2 · Atomic Knowledge Rule — `atomic_extraction_rules.dart`

**One Fact / One Meaning / One Rule.** A paragraph with 12 ideas yields **12**
units, not one summary.

- `classify(text)` → `atomic` or `narrative`. Deterministic heuristics reject:
  multiple sentences, prose length (> 6 words for a token), narrative marker words
  (*usually, often, brings, because, indicates that, …*, plus Thai connectives),
  and multi-idea conjunctions (`and`/`or`/`และ`).
- `validateUnit` / `validateAll` enforce atomic subject/object/condition/effect,
  require a book reference, and flag duplicate ids.

The extraction pipeline thus admits only **entities, relationships, conditions,
effects, exceptions, confidence and evidence** — and rejects paragraphs,
summaries, rewritten narrative, interpretation and prediction.

## 3 · Knowledge Graph — `atomic_knowledge_graph.dart`

Canon is a **graph**. Relationships are first-class.

- Nodes = entities (`kind:value`, e.g. `planet:jupiter`).
- Edges = relations (`owns`, `supports`, `opposes`, `belongs_to`, `located_in`,
  `requires`, `produces`, `exception_to`, `relates_to`) carrying condition,
  strength and the source unit id.
- Deterministic ordering; queries: `neighbours`, `edgesFrom`, `edgesWithRelation`,
  `relationsBetween`.
- `validate()` flags duplicate edges and direct contradictions
  (`supports` + `opposes` on the same ordered pair).

```
planet --owns--> meaning
planet --supports--> planet
house  --belongs_to--> domain
rule   --requires--> condition
```

## 4 · Canon Completeness Report — `canon_completeness_report.dart`

Measures completeness **by knowledge domain**, never by file count, and is
**deterministic**.

- `CanonCompletenessSpec` holds per-domain targets (structural counts: 9 planets,
  12 houses, 12 signs, 72 directed planet pairs …) — counts of *structures*, not
  invented meanings.
- `generate(units, spec)` → per-domain `present/expected/coverage`, plus
  `evidenceCoverage`, `verifiedRelationships`, `unknownRelationships`.

```
Planet Library: 100% (9/9)
House Library:  95%  (…)
Planet Relationships: 12%
Evidence Coverage: 33%
Verified Relationships: 12
Unknown Relationships: 44
```

## Validation (tests)

`test/validation/thai/thai_canon_atomic_knowledge_test.dart` (12 tests):
atomicity (one-fact units valid; narrative object rejected; missing reference
rejected; duplicate ids), extraction rejects narrative/paragraphs/conjunctions,
knowledge graph build + queries + contradiction detection, **deterministic**
completeness report (incl. empty base), JSON round-trip, and decoupling (the
atomic layer imports no engine/runtime/matrix/mirror/fusion/narrative/flutter).
Full canon suite (78 tests) stays green; `flutter analyze` clean.

## Constraints honoured

- No redesign of frozen architecture; no new engine/runtime/UI; no runtime
  behaviour change; not deployed.
- Untouched: `PlanetRelationshipMatrix`, Rule Engine, Timeline, Prediction,
  Decision, Runtime, Mirror, Conversation, Fusion, Narrative.
- No fabricated knowledge — the atomic layer is structure + vocabulary; baseline
  knowledge stays empty. Provenance by reference only (D-057).
