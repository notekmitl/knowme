# Thai Astrology Canon — Knowledge Production Sprint 2C (Context Qualifier + Resumed Production)

> **Outcome:** The Sprint 2B Knowledge Modeling Gap is **RESOLVED** by **D-068**:
> one optional `context` qualifier on the Atomic Knowledge Unit records *the scope
> under which a fact is true* (e.g. inside one archetype chart). The unit's
> `(subject, relation, object)` identity is unchanged — applicability only.
> Production **resumed** on the unchanged pipeline: chart-scoped planet placements
> now carry an `archetype_chart` context, and a new placement was produced.
> **Canon coverage increased 8 → 9 units.** No Runtime / Rule Engine / Workspace /
> Authoring / Canon-DB / ontology redesign.

Status: **CURRENT** · Atomic-model additive extension (D-068) · Platform otherwise
frozen (D-065) · D-066/D-067 complete · No deploy.

---

## 1 · The `context` qualifier (D-068)

Per the modeling-gap resolution brief, exactly **one** optional qualifier was added
— **not** separate `archetypeChart` / `lifePeriod` fields.

```
context:
  type:  archetype_chart | taksa_chart | lagna | life_period | other
  value: <atomic token from the source>     # e.g. ดวงนักวิชาการ, aries, saturn
```

- **`AtomicContextType`** (`atomic_relation.dart`) — the scope *kind*, enum-typed
  for determinism, wire names `archetype_chart` / `taksa_chart` / `lagna` /
  `life_period` / `other`.
- **`AtomicContext { type, value }`** (`atomic_knowledge_unit.dart`) — the scope
  itself; `value` is an atomic token taken from the source.
- **`AtomicKnowledgeUnit.context`** — a single optional field. `null` ⇒ general /
  unconditional fact; present ⇒ the same fact, true **only within that scope**.

**Semantics:** applicability only. A scoped unit has the *identical*
`(subject, relation, object)` as its general form; the context never changes what
the fact *is*, only *where it holds*.

**Rules honoured (from the brief):** optional · deterministic (enum type + atomic
value, JSON round-trips) · provenance still required (the unit's evidence
reference is unchanged) · no inference · no external knowledge · no runtime
changes · no Rule Engine changes · no Canon redesign.

**Validation** (`atomic_extraction_rules.dart`) gains two checks, applied **only
when context is present**:

| code | when |
| --- | --- |
| `empty_context_value` | context present but its value is blank |
| `non_atomic_context` | context value reads as prose (fails the atomic-token test) |

---

## 2 · No-inference choice for the context value

The book's archetype charts are named on the page (e.g. `ดวงนักวิชาการ`,
`ดวงกําพร้า`, `ดวงมนุษย์เจ้าสําราญ`). The context `value` is the **verbatim Thai
chart heading from the page** — *not* an English translation. Translating the
heading would be interpretation/external knowledge; using the source's own label
keeps the scope identifier deterministic and faithful. (`type` is the controlled
enum; only `value` carries the source token.)

---

## 3 · Resumed production (unchanged pipeline)

Pages already read (44/50/150/220/222/83) were revisited to confirm each chart
heading at its source before scoping. Two classes of fact, as established in
Sprint 2B:

- **General natural significations** → **no context** (recur identically across
  charts): `jupiter --owns--> learning` (p.44/220), `jupiter --owns--> career`
  (p.220), `moon --owns--> finance` (p.83).
- **Chart-scoped placements** → `context = {archetype_chart, <heading>}`:

| id | fact | chart context (verbatim heading) | page | basis |
| --- | --- | --- | --- | --- |
| `…p220.jupiter_in_thongchai` | jupiter `located_in` thongchai (high) | `ดวงนักวิชาการ` | 220 | `ดาวพฤหัส…สถิตเรือนธงชัย…เข้มแข็ง` |
| `…p220.jupiter_in_khumsap` | jupiter `located_in` khumsap (high) | `ดวงนักวิชาการ` | 220 | `…สถิตเสถียรเรือนขุมทรัพย์…เข้มแข็ง` |
| `…p220.mars_in_athibodi` | mars `located_in` athibodi | `ดวงนักวิชาการ` | 220 | `…พฤหัส…และอังคาร…เรือนธงชัยและอธิบดีตามลำดับ` |
| **`…p222.moon_in_marana`** *(new)* | moon `located_in` marana | `ดวงนักวิชาการ` | 222 | `…ตกอยู่ในเรือนมรณะ คือดาวจันทร์(๒)…อยู่เรือนมรณะ` |
| `…p150.jupiter_in_puti` | jupiter `located_in` puti (low) | `ดวงมนุษย์เจ้าสําราญ` | 150 | `…สถิตเรือนปูติ…กำลังอ่อน` |
| `…p50.jupiter_in_athibodi` | jupiter `located_in` athibodi | `ดวงกําพร้า` | 50 | `ดาวพฤหัส(๕)สถิตเรือนอธิบดี` |

The five Sprint-2A/2B placements were **re-scoped** with their (now source-verified)
archetype context; one **new** placement (`p222 moon_in_marana`) was produced.

**Cumulative coverage:**

| metric | 2A | 2B | 2C |
| --- | --- | --- | --- |
| total units | 7 | 8 | **9** |
| Planet Library subjects | 2 | 3 | 3 (Jupiter, Mars, Moon) |
| Planet → Domain produced | 2 | 3 | 3 |
| chart-scoped placements | 5 (unscoped) | 5 | **6 (scoped)** |

Validated through the **real** platform (`thai_canon_production_sprint2_test.dart`):
every unit resolves to the ontology, passes `AtomicExtractionRules`, and the report
is deterministic. New assertions prove placements are chart-scoped while
significations stay general, and that the *same* named position can be scoped to
different charts without collision (mars@`ดวงนักวิชาการ` vs jupiter@`ดวงกําพร้า` in
athibodi). **236 thai validation tests green; analyze clean.**

---

## 4 · What remains open

- **ทักษา dignity-role ontology vocabulary** (บริวาร/อายุ/เดช/ศรี/มูละ/อุตสาหะ;
  Sprint 2B §4.1 class B) is **still not in the ontology**. With `context` now
  available, those life-period readings become representable **once** the role
  vocabulary is added — a future **Ontology Expansion** decision (D-065 cat. 2),
  not a modeling gap. It was **not** added in this sprint (no entity is created
  until confirmed required and sourced).
- Bulk page-by-page extraction of the remaining archetype chapters continues
  through this same unchanged pipeline; each chart heading is read at its source
  before scoping. Production stops only at the next genuine Ontology or Modeling
  Gap.

---

## 5 · Compliance

- **One qualifier only (D-068).** No separate chart/period fields; unit identity
  unchanged; applicability-only.
- **Extraction, not generation (D-066).** Chart context = the source's verbatim
  heading; no translation, inference or external knowledge.
- **Frozen elsewhere (D-065).** No Runtime / Rule Engine / Workspace / Authoring /
  Canon-DB / ontology redesign; reference-only provenance (D-057); no deploy.
- **Validated before claiming:** 236 thai tests green; analyze clean; deterministic
  coverage report.

---

## 6 · Related documents

- [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md) — the modeling gap this resolves.
- [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2A.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2A.md) — ontology expansion + first batch.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-068 (and D-067, D-066, D-065).
- Atomic Knowledge V2 (`canon/atomic/`); `thai_canon_atomic_knowledge_test.dart` (context tests).
