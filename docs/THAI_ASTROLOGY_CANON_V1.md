# Thai Astrology Canon V1 — Canonical Knowledge Architecture

> Elevate Thai astrology knowledge with a **Canonical Knowledge Architecture**.
> The book **`หลักมหาภูต` (ส. หยกฟ้า)** is the single **Canonical Source**; all
> other texts and research become **Supporting Knowledge**. This is a
> **knowledge-only** layer: it changes **no calculation engine, no runtime, no
> provider, no mirror, no fusion, no narrative runtime, and never touches the
> `PlanetRelationshipMatrix`.** No deploy.

Status: **CURRENT** · Knowledge layer only · Engine frozen · **No deploy**.
Decision Log **D-052**.

---

## Why

The knowledge platform V1–V9 can already collect sources (V7), measure
consensus (V8) and review the frozen matrix (V9) — but every source was treated
as **equal**. Real Thai astrology is not flat: it has a hierarchy of authority.
Canon V1 adds that missing dimension: a **Source Priority ladder** plus a
**conflict-resolution rule that lets the canonical book win**, and the
**architecture to ingest `หลักมหาภูต` later** without disturbing anything that
already runs.

This layer is the intended **permanent foundation** for Thai astrology
knowledge in KnowMe. Everything above it (engine, runtime, mirror, fusion) is
frozen and untouched.

---

## 1 · Source Priority (Tiers)

`lib/features/astrology/thai/knowledge/canon/knowledge_tier.dart`

| Tier | `KnowledgeTier` | Authority | Role |
|------|-----------------|-----------|------|
| **0** | `calculationEngine` | highest (ground truth) | Swiss Ephemeris, day/lagna/bhava/planet, frozen matrices. **The knowledge layer never asserts or overrides these.** |
| **1** | `canon` | **Canonical** | **`หลักมหาภูต` (ส. หยกฟ้า)** — when Canon speaks, Canon wins. |
| **2** | `thaiClassical` | supporting | Traditional Thai texts (e.g. พรหมชาติ). |
| **3** | `research` | supporting | Collected research (V3/V4/V7 corpus). |
| **4** | `internet` | supporting | Web material (lowest authority). |

`priority` (0→4) drives ordering; lower = more authoritative. Tier 0 is
**ground truth** (computed facts) and Tier 1 is the **canonical interpretive
authority**. Tiers 2–4 are explicitly `isSupporting`.

---

## 2 · Canonical Knowledge Node

`lib/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart`

Every node supports the eight required facets from the brief:

| Facet | Field |
|-------|-------|
| **Source** | `sourceId` → entry in `canon_sources.json` |
| **Tier** | `tier` — **resolved from the source registry**, never self-declared |
| **Canonical** | `canonical` — derived (`true` only for Tier 1) |
| **Confidence** | `confidence` (`none`/`low`/`medium`/`high`) |
| **Evidence** | `evidence[]` — quote-first (`page`, `quote`, `note`) |
| **References** | `references[]` — other node ids / external refs |
| **Conditions** | `conditions[]` — when it applies |
| **Exceptions** | `exceptions[]` — when it does NOT apply (ยกเว้น) |

Plus `topic`, `subject`, `category` (`rule`/`concept`/`formula`/`meaning`/
`interpretation`/`exception` — the audit vocabulary), `statement`, `status`, and
an optional normalized `value` (e.g. `friend` for rule-type nodes) used by
conflict resolution.

**Authority is derived, not declared.** The engine reads each node's `sourceId`,
looks up the source's tier, and stamps `tier`/`canonical` onto the node. A node
cannot promote itself to Canon.

---

## 3 · Conflict Resolution — *Canon always wins*

`lib/features/astrology/thai/knowledge/canon/canon_conflict_resolver.dart`

For every subject (`topic::subject`), `CanonConflictResolver.resolveSubject`
returns a `CanonResolution`:

- **Canon present** → outcome `canonical`. Canon's `value` is authoritative.
  Supporting nodes that **agree** (or carry no `value`) are kept as
  `supporting` — they *add detail, examples, explanation*. Supporting nodes that
  **contradict** Canon go to `overruledByCanon` (kept for transparency, **never
  applied**).
- **Canon vs Canon disagreement** → outcome `canonInternalConflict`. The layer
  **never auto-resolves** canon-vs-canon; it flags `needsHumanReview`. Supporting
  sources cannot break a canon tie.
- **No Canon** → outcome `supportingOnly` (provisional). Highest-tier supporting
  value is surfaced, and disagreement is noted, but it is explicitly *not*
  canonical.
- **No nodes** → `empty`.

This is the literal encoding of the project rule: *ถ้า Canon กล่าวไว้แล้ว Canon
ชนะเสมอ … ห้าม Override Canon.*

---

## 4 · Engine

`lib/features/astrology/thai/knowledge/canon/canon_knowledge_engine.dart`

`CanonKnowledgeEngine.load({sourcesJson, nodesJson})` /
`loadFromAssets()` returns a `CanonLoadResult` (engine + issues). It:

- parses `canon_sources.json` + `canon.knowme.json`,
- **resolves each node's tier/canonical from the source registry**,
- validates: `duplicate_source`, `duplicate_node`, `unknown_tier`,
  `unknown_category`, `broken_source_ref`, `broken_reference`,
  `canonical_tier_mismatch` (canonical coerced off when not Tier 1),
  `canon_missing_evidence`, `canon_internal_conflict`, `invalid_json`,
- exposes `resolve(topic, subject)`, `resolveAll()`, and `coverage()` →
  `CanonCoverageReport` (nodes by tier/category, canon-backed vs provisional
  subjects, canon conflicts, overruled count).

Malformed JSON degrades to an error (never throws).

---

## 5 · Book ingestion architecture (future extraction)

`lib/features/astrology/thai/knowledge/canon/canon_book_manifest.dart`
+ `knowledge/canon/mahabhut.book.schema.json`
+ `knowledge/canon/mahabhut.manifest.json`

`CanonBookManifest` models the book as **Part → Chapter → Section**, where each
`CanonBookSection` is a placeholder carrying `topic`, page range, an extraction
`status`, and the `nodeIds[]` it will eventually produce (linking back to
`canon.knowme.json`). `extractionReport()` reports progress.

**Nothing is extracted yet.** `mahabhut.manifest.json` ships as a
`not_started` skeleton with verified-later bibliographic fields. This is the
architecture so the whole of `หลักมหาภูต` can be turned into structured
knowledge later — *one section → many canon nodes → resolved as authority.*

---

## Data files

`knowledge/canon/`

| File | Purpose |
|------|---------|
| `canon_sources.json` | Source Priority registry (identities + tiers). `หลักมหาภูต` = Tier 1 canonical. **Asserts no knowledge.** |
| `canon.knowme.json` | Canonical knowledge nodes. **Empty baseline** — nothing fabricated, book not extracted. |
| `canon.schema.json` / `canon.template.json` | Node schema + authoring template (quote-first). |
| `mahabhut.book.schema.json` | Book-manifest schema for future extraction. |
| `mahabhut.manifest.json` | `หลักมหาภูต` skeleton, `not_started`. |

Registered under `pubspec.yaml` assets as `knowledge/canon/`.

---

## Constraints honoured

- **No engine / formula / Swiss Ephemeris / day / lagna / bhava / planet
  change.** No `Runtime`, `Provider`, `Mirror`, `Fusion`, `Narrative Runtime`
  change.
- **`PlanetRelationshipMatrix` never imported, read, or written.** Verified by a
  decoupling test that scans the canon source files.
- **No fabricated knowledge.** Baseline ships an empty node corpus and a
  not-started book skeleton; sources register identities only.
- **No deploy.**

---

## Tests

`test/validation/thai/thai_canon_knowledge_test.dart` (20 tests): tier ordering,
authority derivation, validation (broken refs, duplicates, unknown tier,
canonical coercion, missing evidence, malformed JSON), conflict resolution
(canon wins / overrule / canon-vs-canon / supporting-only / coverage), book
manifest parsing + progress, shipped-data integrity, and decoupling.

---

## Future work (not in V1)

- Extract `หลักมหาภูต` section-by-section into `canon.knowme.json` nodes, filling
  `mahabhut.manifest.json` `nodeIds`.
- Surface canon resolutions in the read-only Workspace (V5) as a new tab.
- Feed `CanonResolution` into the Matrix Review (V9) so "Canon says X" becomes a
  first-class recommendation signal — still proposal-only.
