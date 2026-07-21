# Mahabhut Canon — Production Volume 1 Closure

> **Official baseline** for `หลักมหาภูต` (ส. หยกฟ้า) foundation knowledge production.
> **Superseded as scope authority** by
> [`THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md`](THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md)
> (D-073). This document remains the **starting dataset record** (357 units); production
> continues under the Completion Program.

Status: **CLOSED (baseline)** · Superseded by **D-073** · Dataset:
[`foundation_v1.knowme.json`](../knowledge/canon/production/foundation_v1.knowme.json) ·
Validation gate:
[`thai_canon_production_sprint2_test.dart`](../test/validation/thai/thai_canon_production_sprint2_test.dart)

---

## 1 · Volume 1 charter

Volume 1 covers **foundation Canon knowledge** extractable without life-period
modeling, Taksa role modeling, or new ontology categories:

| In scope | Out of scope (Volume 1) |
|---|---|
| General planet significations (`owns` → `domain.*`) | Life-period readings (pp.52+ per chart, continuation pages) |
| Natal archetype placements (`located_in` → `mahabhutPosition.*`, 7 charts) | ทักษา role meanings & prediction rules (pp.39–41) |
| Planet library attributes (`relates_to` → `attribute.*`, pp.30–37) | ดวงขึ้น / ดวงตก rules (pp.17–18) |
| Gender-conditional general rules (p16) | Dasha age tables (p18) |
| | Chart lookup tables (pp.19–27) |
| | Remedies / แก้ดวง (pp.293–308) |
| | Preface / TOC prose (pp.1–15) |

Policies unchanged: D-065–D-072 · extraction only (D-066) · reference-only
provenance (D-057) · source-internal conflicts recorded faithfully (D-071).

---

## 2 · Primary metrics (replacing raw unit count)

### Definitions

| Metric | Meaning |
|---|---|
| **Representable Canon Knowledge** | Atomic facts **explicitly stated** in the Canon, **within the Volume 1 charter**, expressible with the **current** atomic model and D-067/D-072 ontology — **without** new ontology categories or modeling-policy decisions. |
| **Extracted Canon Knowledge** | Atomic facts **actually recorded** in `foundation_v1.knowme.json` and validated by the production test. |
| **Completion ratio** | `Extracted ÷ Representable` |

**Not counted as Representable:** facts that require a modeling-policy decision
(commodity, physique, bodyPart split), a new ontology category (symbol, commodity,
ทักษา role), or facts outside the Volume 1 charter (life-period, remedies).

**Differentiation (required):**

| Term | Meaning |
|---|---|
| **Unknown** | Canon does **not** explicitly state the fact (or it cannot be read). The model correctly has no unit. |
| **Knowledge Modeling Gap** | Canon **does** state the fact, but the current model cannot represent it without a policy or schema change. |
| **Ontology Gap** | A vocabulary category or token to name the fact does not exist in the ontology. |

---

## 3 · Volume 1 completion summary

| Knowledge class | Representable | Extracted | Gap | Notes |
|---|---:|---:|---:|---|
| Domain significations (`owns`) | 16 | 16 | 0 | p16, p28, p29 (clean lines), p220 |
| Natal placements (`located_in`) | 41 | 40 | 1 | Sun @ ดวงมนุษย์เจ้าสำราญ deferred (ambiguous p149) |
| Attribute lists — profession / place / disease | 268 | 268 | 0 | pp.30–36 discrete list items |
| Attribute scalars — color / taste / metal / gender (+ Moon gemstone) | 29 | 25 | 4 | Venus p35 ×3, Saturn gender p36 — **OCR blocked** |
| Directions — `ครองทิศ` (p37) | 8 | 8 | 0 | 8 planets; Ketu has no line |
| **Volume 1 total** | **362** | **357** | **5** | |

### Completion ratio

| View | Ratio |
|---|---|
| **Full Volume 1 representable pool** (includes OCR-recoverable + natal review item) | **357 / 362 = 98.6%** |
| **Currently readable representable only** (excludes OCR-blocked and ambiguous natal) | **357 / 357 = 100%** |

The five outstanding items are **not** modeling failures — they are **OCR recovery**
(four scalars) and **source forensics** (one natal seat). Everything else in the
Volume 1 representable pool is extracted.

### Legacy unit count (reference)

357 atomic knowledge units · 42 evidence pages (p16–p261) · 8 planets with
coverage (Sun–Saturn + Rahu; **Ketu: 0**).

---

## 4 · What has been completely extracted

### 4.1 General significations

| Source | Content | Status |
|---|---|---|
| p28 | Family-role table (7 planets → domains) | **Complete** |
| p29 | Concise lookup — clean domain mappings (4 units) | **Complete** (unparsed p29 lines → modeling gap, not in representable pool) |
| p16 | Gender-conditional spouse significators (Mars / Venus) | **Complete** |
| p220 | Jupiter → learning, career (chart-scoped evidence) | **Complete** |
| p83 | Moon → finance (general, recurring) | **Complete** |

### 4.2 Natal archetype placements (7 charts)

All **stated, unambiguous** natal seats for seven archetype charts are in Canon.

| Chart | Placements | Status |
|---|---:|---|
| ดวงนักวิชาการ | 7 | **Complete** (Jupiter @ ธงชัย **and** ขุมทรัพย์ — source tension, both recorded) |
| ดวงกำพร้า | 6 | **Complete** |
| ดวงนักภาษา | 6 | **Complete** |
| ดวงนักบริหาร | 6 | **Complete** |
| ดวงเศรษฐี | 5 | **Complete** (Sun / Saturn never stated) |
| ดวงมหาเศรษฐี | 5 | **Complete** (Sun / Saturn never stated) |
| ดวงมนุษย์เจ้าสำราญ | 5 | **Partial** — Sun seat ambiguous (p149); 5 other planets complete |

Injectivity holds for six charts; **not** asserted for ดวงนักวิชาการ (Jupiter
conflict) or ดวงมนุษย์เจ้าสำราญ (incomplete).

### 4.3 Planet library — list attributes (pp.30–36)

| Category | Units | Status |
|---|---:|---|
| profession (บุคคล) | 121 | **Complete** for stated list items |
| place (สถานที่) | 94 | **Complete** |
| disease (โรค) | 53 | **Complete** |

First **Rahu** production: 21 units total (20 from Batch 8 lists + 1 direction).

### 4.4 Planet library — scalars (pp.30–36)

| Planet | color | taste | metal | gender | gemstone | Status |
|---|---|---|---|---|---|---|
| Sun | ✓ | ✓ | ✓ | ✓ | — | **Complete** |
| Moon | ✓ | ✓ | ✓ | ✓ | ✓ | **Complete** |
| Mars | ✓ | ✓ | ✓ | ✓ | — | **Complete** |
| Mercury | ✓ | ✓ | ✓ | ✓ | — | **Complete** |
| Jupiter | ✓ | ✓ | ✓ | ✓ | — | **Complete** |
| Venus | **OCR** | **OCR** | **OCR** | ✓ | — | **Partial** |
| Saturn | ✓ | ✓ | ✓ | **OCR** | — | **Partial** |
| Rahu | — | — | — | — | — | **N/A** (lists only on p36) |

Gemstone appears only for Moon (explicit เพชรพลอย) — not Unknown for other planets.

### 4.5 Directions (p37)

All eight planets with a **ครองทิศ** line extracted. **Ketu** has no such line
→ not recorded; never inferred.

---

## 5 · Intentionally deferred (Volume 1 charter)

These Canon sections are **not** in the Volume 1 representable pool. Deferral is
**by policy**, not oversight.

| Section | Pages (approx.) | Reason |
|---|---|---|
| Life-period readings | pp.52–75, 89–111, 121–147, 157–179, 188–217, 226–253, 263–292 | Charter: no life-period modeling |
| ทักษา role meanings & prediction rules | pp.39–41 | Charter: no Taksa modeling |
| ดวงขึ้น / ดวงตก position-classification | pp.17–18 | Modeling gap + charter |
| Dasha age tables | p18 | Life-period timing |
| Chart lookup tables | pp.19–27 | Reference tables, not atomic significations |
| Remedies / แก้ดวง | pp.293–308 | Not started; remedy modeling TBD |
| Commodity lists (`เครื่องอุปโภคบริโภค`) | pp.30–36 | Ontology gap (`commodity` category not approved) |
| Physique (`รูปพรรณสัณฐาน`) | pp.30–36 | Modeling gap (compound phrases) |
| Planet symbols on p37 | p37 | Ontology gap (no symbol category) |
| Typed attribute relations | — | Doc-only future note (Batch 9); not scheduled |

---

## 6 · OCR-blocked (representable once text is recovered)

| Page | Planet | Missing scalars | Blocker |
|---|---|---|---|
| p35 | Venus | color, taste, metal | Garbled OCR (`ee A`, truncated lines) |
| p36 | Saturn | gender | Garbled OCR |

**Count:** 4 representable facts · 0 extracted · **awaiting OCR recovery or manual
verification** — not a modeling or ontology failure.

---

## 7 · Unknown (Canon does not state)

The model correctly has **no** unit for these. They are **not** production backlog
items within Volume 1.

| Area | Detail |
|---|---|
| **Season** | Exhaustive OCR: no `ฤดู` / `ฤดูกาล` anywhere. `attributeCategory.season` is vocabulary-only (D-072). |
| **Saturn natal seats** | Saturn is called เด่น/เข้มแข็ง in several charts but **no เรือน is ever stated** in natal sections. |
| **Sun natal (some charts)** | Not stated for ดวงเศรษฐี or ดวงมหาเศรษฐี natal intros. |
| **Ketu planet library** | No Ketu section on pp.30–36; no Ketu **ครองทิศ** on p37. |
| **Gemstone (most planets)** | Only Moon states เพชรพลอย explicitly; absence for other planets is **not stated**, not blocked. |
| **Rahu scalars** | p36 gives list attributes only; no color/taste/metal/gender lines for Rahu. |

---

## 8 · Open Ontology Gaps

Vocabulary categories **required to name** stated facts but **not** created in
Volume 1 (per D-059 / D-072 policy).

| Gap | Stated in Canon? | Volume 1 action |
|---|---|---|
| `attributeCategory.commodity` | Yes — `เครื่องอุปโภคบริโภค` lists pp.30–36 | Not approved; deferred |
| Symbol / creature tokens (p37) | Yes — ครุฑี, พยัคฆ์, etc. | No category created |
| ทักษา role entities | Yes — pp.39–41 | Sprint 2B sub-gap; charter blocks entry |
| `attributeCategory.season` | **No** — not in source | Vocabulary reserved; **not an ontology gap for content** |
| Domain aliases for p29 unparsed lines | Partial — Sun→ยศศักดิ์, Mercury→เจรจา, etc. | Missing `domain.*` aliases |

**Resolved in Volume 1:** D-067 Mahabhut Named Positions (7) · D-072 attribute
categories (11) + 293 value tokens.

---

## 9 · Open Knowledge Modeling Gaps

Canon **states** these facts; the current atomic model **cannot** represent them
without a policy or schema decision.

| Gap | Example | Why not representable |
|---|---|---|
| **bodyPart** as separate category | Anatomy inside `โรค…` disease phrases | Splitting one atomic statement → inference |
| **Physique** composites | `รูปพรรณสัณฐาน` per planet | Compound descriptions; no split policy |
| **Commodity** lists | `ได้แก่` under เครื่องอุปโภค | Needs `commodity` category (ontology + policy) |
| **p29 unparsed lookup lines** | Sun→ยศศักดิ์, Mercury→เจรจา, Venus compound, Saturn→โทษ | Domain alias or compound-split policy needed |
| **ดวงขึ้น / ดวงตก rules** | pp.17–18 | Position-classification rule objects |
| **ทักษา role meanings** | pp.39–41 `หมายถึง…` | Role entity + Taksa charter |
| **Prediction rules** | pp.40–41 weak/strong position rules | Rule objects beyond atomic triples |
| **Remedies** | pp.293–308 | Ritual/remedy procedure modeling |
| **Typed attribute relations** | Future `relates_to` specialization | Doc-only note; not blocking |

---

## 10 · Conflicts & multi-evidence (baseline record)

### Source-internal conflict (faithful)

**ดวงนักวิชาการ / Jupiter:** both `thongchai` and `khumsap` on p220 —
`jupiter_in_thongchai` and `jupiter_in_khumsap` both in Canon. Resolved
downstream by `CanonConflictResolver`; never deleted or inferred away.

### Multi-evidence (not conflicts)

Same subject–relation–object, distinct page evidence — intentional (e.g.
Jupiter→learning on p28, p29, p220).

---

## 11 · Production milestone history

| Milestone | Units | Cumulative focus |
|---|---:|---|
| Sprint 2A | 7 | D-067 positions + first placements / domains |
| Sprint 2B–2C | — | General finance signification; chart context (D-068) |
| Sprint 3 | 19 | ดวงกำพร้า + ดวงนักภาษา natal complete |
| Production Batch 4 | 30 | ดวงมนุษย์เจ้าสำราญ, นักวิชาการ, เศรษฐี |
| Production Batch 5 | 41 | ดวงมหาเศรษฐี + ดวงนักบริหาร; D-070 metrics |
| Production Batch 6 | 43 | Remaining Sun seats; D-071 page coverage |
| Production Batch 7 | 56 | Front-matter general significations |
| Production Batch 8 | 349 | Planet library attributes (D-072) |
| Production Batch 9 | **357** | Directions (p37) |
| **Volume 1 closure** | **357** | **Baseline frozen** |

Ontology commits: D-067 (`cc3f728` lineage) · D-072 (`cc3f728`).

---

## 12 · Volume 1 baseline statement

**Extracted Canon Knowledge:** **357** atomic units in
`foundation_v1.knowme.json`.

**Representable Canon Knowledge (Volume 1 charter):** **362** atomic facts.

**Completion ratio:** **98.6%** (100% of currently readable representable knowledge).

Volume 1 establishes the **official foundation baseline** for Mahabhut Canon
knowledge: general significations, seven natal archetype charts (minus one
ambiguous Sun seat), and the planet library through directions — with explicit
records of deferrals, gaps, and one source-internal placement tension.

**Production is paused.** Batch 10 and Volume 2 scope are **not** authorized by
this closure document.

**Update (D-073):** Production **resumed** under the
[Mahabhut Canon Completion Program](THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md).
This closure doc is the Volume 1 baseline only.

---

## Related documents

| Document | Role |
|---|---|
| [`THAI_CANON_KNOWLEDGE_PRODUCTION_BATCH_9.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_BATCH_9.md) | Last production batch |
| [`THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md`](THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md) | Active completion program (D-073) |
| [`THAI_CANON_KNOWLEDGE_PRODUCTION_V1.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_V1.md) | Platform production phase opener (D-061) |
| [`DECISION_LOG.md`](DECISION_LOG.md) | D-065–D-072 policies |
