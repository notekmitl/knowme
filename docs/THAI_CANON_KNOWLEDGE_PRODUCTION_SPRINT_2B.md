# Thai Astrology Canon — Knowledge Production Sprint 2B (Continued Production + Modeling Gap)

> **✅ MODELING GAP RESOLVED (D-068):** The chart-scoping gap below was resolved by
> adding **one** optional `context` qualifier to the Atomic Knowledge Unit (not
> separate chart/period fields). Production resumed in
> [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2C.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2C.md).
> The ทักษา dignity-role *ontology* sub-gap (§4.1 class B vocabulary) remains open
> and is deferred — class-A significations + chart-scoped placements are now
> produced without it. The report below is retained as the original analysis.

> **Outcome:** Production continued through the **unchanged pipeline** (D-065/D-066).
> D-067 wording was corrected (entities exist because **required for Canon
> representation**, not because of OCR frequency). One additional **general**
> natural-signification unit was produced (`moon --owns--> domain.finance`, p.83).
> **Canon coverage increased 7 → 8 units.** Production then **paused** on a
> genuine **Knowledge Modeling Gap**: the book's per-life-period readings are built
> on the **ทักษา dignity-role class** (บริวาร/อายุ/เดช/ศรี/มูละ/อุตสาหะ…) which the
> ontology cannot represent, and those role assignments + planet placements are
> **chart-scoped per archetype** — not general planet properties. Per D-065, this
> is reported, not redesigned.

Status: **CURRENT** · Knowledge production only · Platform **frozen** (D-065) ·
D-066/D-067 complete · No platform/ontology redesign · No deploy.

---

## 1 · D-067 wording correction (Sprint 2B)

Earlier Sprint 2A text described the seven Mahabhut Named Positions as
"enumerated from OCR frequency." That was **incorrect as a creation criterion**.

**Correct rule (now in `DECISION_LOG.md` D-067, `canon_ontology_data.dart`,
Sprint 2A doc, `ARCHITECTURE.md`, `PROJECT_INDEX.md`):**

- An ontology entity is introduced **because it is required for Canon
  representation** — the book expresses placement through these named positions,
  so its statements cannot be represented without them.
- **OCR frequency is supporting evidence for prioritization only, never the
  criterion for creating an entity.**

No ontology entities were added or changed in Sprint 2B — wording only.

---

## 2 · Pages read this sprint

| page | archetype | OCR quality | production action |
| --- | --- | --- | --- |
| 151 | (continuation of ดวงมนุษย์เจ้าสำราญ) | readable narrative | **skip** — interpretive career effects only; no new atomic general facts |
| 152 | ดวงมนุษย์เจ้าสำราญ | mixed (corruption mid-page) | **skip** — career lists + corrupted lines; no extractable atomic facts |
| 221 | ดวงนักวิชาการ | readable | **skip** — career guidance only; Jupiter significators already in batch (p.220) |
| 222 | ดวงนักวิชาการ | readable | **gap trigger** — see §4 (ทักษา roles + chart-scoped placement) |
| 83 | ดวงนักภาษา | readable (section header) | **produced** — general signification moon→finance |
| 44 | ดวงกำพร้า | readable (significator lines) | **already covered** — Jupiter→learning on p.220; placement on p.50 |

**OCR-corrupted pages recorded for re-OCR (not guessed):** 152 (mid-page corruption
lines 26–34).

---

## 3 · Units produced (Sprint 2B)

| id | fact | page | basis (stated by the page) |
| --- | --- | --- | --- |
| `mahabhut.p83.moon_owns_finance` | `moon --owns--> domain.finance` | 83 | `ดาวจันทร์ (๒)อันเป็นดาวแห่งการเงิน` |

**Why this unit qualifies:** it is a **general natural signification** — the same
phrase recurs identically across unrelated archetype charts (p.47 `ดาวแห่งเงินและทอง`,
p.83 `ดาวแห่งการเงิน`, p.222 `ดาวแห่งการค้า` for trade/commerce). `การเงิน` resolves
to `domain.finance` via the existing ontology alias. It is **not** chart-scoped.

**Cumulative coverage after Sprint 2B:**

| metric | Sprint 2A | Sprint 2B |
| --- | --- | --- |
| total units | 7 | **8** |
| Planet Library subjects | Jupiter, Mars | Jupiter, Mars, **Moon** |
| Planet → Domain produced | 2 (Jupiter) | **3** (Jupiter×2, Moon×1) |

Validated through the real platform (`thai_canon_production_sprint2_test.dart`):
174 canon tests green; analyze clean.

---

## 4 · Knowledge Modeling Gap (stop condition)

While reading pages 151–222 and scanning the corpus for `ดาวแห่ง…` significator
patterns, a structural gap emerged that blocks faithful bulk extraction.

### 4.1 · Two classes of "ดาวแห่ง X" statements

The book uses `ดาว X อันเป็นดาวแห่ง Y` in two **different** ways:

**A — General natural significations** (planet property, recurring identically):

| planet | stated signification | example pages | representable now? |
| --- | --- | --- | --- |
| Jupiter | การเรียน/การศึกษา, ปัญญา, หน้าที่การงาน | 44, 220 | ✅ produced |
| Moon | การเงิน (and การค้า in trade context) | 47, 83, 222 | ✅ finance produced |
| Venus | ภรรยา | 48, 85, 118 | ⏸ ontology has `domain.relationship` but not spouse-specific; needs human decision |
| Mars | สามี | 84 | ⏸ same |
| Mercury | บุตรธิดา | 49, 87 | ⏸ ontology has `domain.family` but not children-specific; needs human decision |

**B — Chart-scoped ทักษา dignity roles** (NOT a planet property):

The roles **บริวาร / อายุ / เดช / ศรี / มูละ / อุตสาหะ** are assigned to
**different planets in different charts**:

| role (ทักษา) | planet on p.52 | planet on p.67 | planet on p.75 |
| --- | --- | --- | --- |
| บริวาร | Sun | Moon | — |
| ศรี | — | Sun | — |
| มูละ | — | — | Sun |
| อายุ | — | — | (varies) |
| เดช | Mars (p.53) | — | — |

The **same dignity role attaches to different planets per archetype chart**. These
are not `planet --owns--> meaning` facts — they are **chart-configuration facts**
whose subject is the archetype chart + life period, not the planet alone.

### 4.2 · Why the current atomic model cannot represent class B

1. **Ontology gap (secondary):** the ทักษา role vocabulary
   (`บริวาร/อายุ/เดช/ศรี/มูละ/อุตสาหะ`) has no ontology entities. Per D-065, an
   Ontology Expansion would be permitted **only if required for Canon
   representation** — but see (2).

2. **Modeling gap (primary):** even with those entities, the atomic unit
   `subject --relation--> object` has no field for **which archetype chart** or
   **which life period** scopes the fact. Example from p.222:
   `ดาวจันทร์อันเป็นดาวแห่งการค้า อยู่เรือนมรณะ` — the placement
   `moon --located_in--> marana` is true **for ดวงนักวิชาการ**, not as a general
   Jupiter/Moon rule. Representing it as a bare atomic fact would **misstate** the
   Canon (forbidden inference).

3. **Volume:** the majority of remaining book content (life-period readings,
   archetype analyses) is class B. Continuing without resolving this would either
   stop almost immediately on every page or misrepresent chart-scoped facts as
   general rules.

### 4.3 · What is NOT claimed

- This is **not** an Ontology Expansion request (yet). The ทักษา roles may need
  ontology vocabulary, but the **primary blocker is atomic scoping** (chart/period
  context).
- This is **not** a platform redesign proposal. Per D-065, the correct output is
  this **Knowledge Modeling Gap Report**.
- Sprint 2A placements (p.50/150/220) remain **faithful per-page extractions**
  cited to their archetype pages; their status as general vs chart-scoped rules
  awaits this modeling decision.

### 4.4 · Recommended human decision (not implemented)

Choose one path (human decision required):

1. **Chart-scoped atomic units** — extend the atomic evidence model with an
   optional `archetypeChart` / `lifePeriod` qualifier (minimal, not a platform
   redesign) so class-B facts can be represented faithfully; then resume production.
2. **Ontology Expansion for ทักษา roles** (D-065 cat. 2) **plus** chart scoping —
   if the roles are confirmed as required Canon vocabulary.
3. **Restrict production scope** to class-A general significations only — slower
   coverage increase, but no modeling change.

Until one path is chosen, **bulk production of life-period readings is blocked**.

---

## 5 · Compliance

- **Extraction, not generation (D-066).** Only the general moon→finance fact was
  added; chart-scoped placements were not misrepresented.
- **No platform/ontology redesign.** D-067 wording corrected only.
- **OCR-corrupted pages not guessed.** Page 152 recorded for re-OCR.
- **Stop condition honoured.** Genuine Knowledge Modeling Gap reported instead of
  forcing extraction or redesigning the platform.

---

## 6 · Related documents

- [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2A.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2A.md) — ontology expansion + first batch.
- [`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2.md`](THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2.md) — original ontology gap.
- [`THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`](THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md) — D-065/D-066 pipeline + gap rules.
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-067 (wording corrected).
