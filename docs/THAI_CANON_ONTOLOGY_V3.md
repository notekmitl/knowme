# KnowMe Canon Platform — Ontology Foundation V3

> Knowledge-platform refinement only. **No architecture redesign, no engine
> change, no UI, no runtime behaviour change, no deploy.** This milestone
> establishes the **Canonical Ontology Layer** — the single controlled
> vocabulary every Canon package must use.

Status: **CURRENT** · Decision Log **D-059** · Knowledge platform only · Engine
frozen. Builds on Atomic Knowledge V2 (D-058) and the provenance policy (D-057).

Module: `lib/features/astrology/thai/knowledge/canon/ontology/` (pure Dart).

---

## Direction

```
Book → Atomic Knowledge → Canonical Ontology → Knowledge Graph → Rule Engine →
Reasoning → Narrative
```

**No Canon package may invent entity or relationship names outside the
ontology.** Entities are never identified by display text; aliases resolve *to*
a stable id.

## 1 · Canonical Entity Registry — `canonical_entity.dart`

`CanonicalEntity` carries `id`, `canonicalName`, `category`, `aliases`,
`description` (structured only), `parentId` (taxonomy), and `status`
(`active`/`deprecated`).

- Ids follow `<category>.<slug>` (e.g. `planet.jupiter`, `domain.finance`,
  `relationship.owns`). The id — not the label — is the identity.
- Categories (`OntologyCategory`): planet, house, sign, element, domain,
  lifeArea, relationship, condition, effect, remedy, agePeriod, gender,
  confidence, evidence, school, book, author, knowledgeStatus, other.

## 2 · Alias Resolution — `canonical_ontology.dart`

Deterministic resolution to **one** canonical entity:

```
"Jupiter" / "Guru" / "ดาวพฤหัส"  → planet.jupiter
"Finance" / "Money" / "Wealth"   → domain.finance
```

- `normalize()` = trim + collapse whitespace + lowercase (Thai-safe).
- `resolve(surface)` / `resolveId(surface)` return null when **unknown or
  ambiguous** — the resolver never guesses. Colliding aliases are deliberately
  left out of the index and reported by validation.

## 3 · Relationship Ontology

The registered relationship vocabulary (the only legal graph relationships):
`owns, supports, opposes, requires, belongs_to, located_in, governs, influences,
produces, strengthens, weakens, exception_to, relates_to`.

This set is a **superset of every V2 `AtomicRelation` wire**, so the knowledge
graph can only use registered relationships — verified by test
(`unregisteredRelationships(AtomicRelation.values…)` is empty) **without
modifying graph logic**. `isRegisteredRelationship(wire)` rejects invented
strings.

## 4 · Domain Taxonomy

Hierarchical domains under a single root:

```
domain.life
├── domain.career      (Work, Profession, การงาน, อาชีพ)
├── domain.finance     (Money, Wealth, การเงิน, ทรัพย์)
├── domain.relationship(Love, Partnership, ความรัก, คู่ครอง)
├── domain.health      (Wellbeing, Wellness, สุขภาพ)
├── domain.family      (Home, ครอบครัว)
├── domain.learning    (Education, Study, การศึกษา)
├── domain.spiritual   (Spirituality, Faith, จิตวิญญาณ)
└── domain.personality (Self, Character, บุคลิกภาพ, ตัวตน)
```

`childrenOf`, `ancestorsOf`, and `taxonomyIsAcyclic` query the tree. Rules may
point only to canonical domain ids.

## 5 · Validation — `ontology_validation.dart`

`CanonicalOntology.validate()` produces a deterministic
`OntologyValidationReport` (issues sorted by signature). It rejects:

| code | meaning |
| --- | --- |
| `duplicate_id` | the same id declared more than once |
| `alias_collision` | one alias/surface form maps to >1 entity (also a duplicate alias) |
| `relationship_not_registered` | a `relationship`-category entity with no registered wire |
| `category_mismatch` | id prefix ≠ entity category |
| `orphan_entity` | `parentId` references a missing entity |
| `taxonomy_cycle` | the domain tree contains a cycle |
| `deprecated_parent` (warning) | parent entity is deprecated |

## Seeded vocabulary — `canon_ontology_data.dart`

`CanonOntologyData.standard()`: 9 grahas (with Sanskrit/Thai aliases), 4 elements,
the life-domain taxonomy and one entity per registered relationship. **Vocabulary
only** — no astrological claims, meanings or predictions; this is not knowledge.

## Validation (tests)

`test/validation/thai/thai_canon_ontology_test.dart` (17 tests): deterministic
multilingual alias resolution, unknown/ambiguous stays unresolved, duplicate ids
rejected, duplicate-alias/collision rejected, category mismatch, orphan parent,
unregistered relationship entity, deterministic validation report, acyclic
taxonomy (+ cycle detected), graph uses only registered relationships, JSON
round-trip, and decoupling (no engine/runtime/matrix/mirror/fusion/narrative/
flutter imports). Full canon suite (95 tests) green; `flutter analyze` clean.

## Constraints honoured

- No redesign of frozen architecture; no new engine/runtime/UI; no runtime
  behaviour change; not deployed. **Knowledge Graph logic untouched** — coverage
  is proved by a read-only test against `AtomicRelation`.
- Untouched: `PlanetRelationshipMatrix`, Knowledge Graph logic, Rule Engine,
  Prediction, Timeline, Decision, Runtime, Mirror, Conversation, Fusion,
  Narrative.
- Vocabulary only — no fabricated knowledge; provenance policy (D-057) preserved.
