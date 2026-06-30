# KnowMe Architecture

**Purpose:** Explain how the product stack fits together.  
**Audience:** Developers and AI agents working on KnowMe.  
**Last updated:** June 2026

For philosophy and product rules, see [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md).

---

## Stack Overview

```
User (Firestore profile + test results)
        ↓
Lens Systems
        ↓
Mirror (MV1 + MV2 Promotion)
        ↓
GF1 — Global Fusion Foundation
        ↓
GF2 — Global Fusion Recovery
        ↓
Human Model
        ↓
Human Pattern
        ↓
Narrative Runtime
        ↓
Home Experience (+ Fusion / Result pages)
```

Each layer consumes the output of the layer above. Downstream layers do not bypass upstream contracts.

---

## Layer 1 — User & Data

**What enters the system:**

| Input | Source | Path |
|-------|--------|------|
| Birth profile | Profile setup / edit | `users/{uid}/profile/main` |
| MBTI / EQ / Big Five results | Test flows | `users/{uid}/results/*` |
| Western natal chart | Astrology generation | `users/{uid}/astrology/western_natal` |
| BaZi chart | Backend + Firestore | `users/{uid}/astrology/chinese_bazi` |

**App entry:** `AuthGate` → `ProfileGate` → `HomePage`  
**Reference:** `lib/presentation/pages/auth/`, `lib/presentation/pages/profile/`

---

## Layer 1.5 — Birth Normalization (single birth-input layer)

**Owner:** `lib/features/birth_normalization/`

Sits **before** every astrology engine. Turns raw user birth information into one
normalized artifact so all systems share resolved location/timezone/calendar and
(for Thai) a real sunrise day boundary.

```
RawBirthInput
      ↓ BirthNormalizer (pure, deterministic)
NormalizedBirth
  ├─ location (BirthLocation)        explicit coords → province → country → Bangkok
  ├─ timeZone (BirthTimeZone)        id → fixed UTC offset (no-DST region)
  ├─ calendar (BirthCalendar)        Gregorian
  ├─ sunrise  (SunriseCalculator)    location-, season-, timezone-aware (no 06:00)
  ├─ thai     (ThaiBirthContext)     astrologicalDate = prev day if before sunrise
  ├─ western  (WesternBirthContext)  exact instant, no day shift
  ├─ bazi     (BaZiBirthContext)     placeholder, not implemented
  └─ reasons  (BirthNormalizationReason[])  every choice, traceable
```

**Contract:** engines consume `NormalizedBirth`, never `RawBirthInput`. The
**Thai pipeline is migrated** (D-036) and **cleaned up** (D-037):

```
RawBirthInput → BirthNormalizer → NormalizedBirth → ThaiEngineAdapter → ThaiBirthData → Thai Engine
```

**Ownership:** Birth Normalization owns **all** adapters — including
`ThaiEngineAdapter` (`.../birth_normalization/application/adapters/`), the single
seam that maps a `ThaiBirthContext` / profile to the engine model. Thai owns
**only** its engine model `ThaiBirthData` (a pure data class with no knowledge of
normalization). Both production loaders (`UserProfileBirthLoader`,
`FirestoreAstrologyFusionLensProbe`) route through `ThaiEngineAdapter` — no
duplicated parsing/timezone logic. `localDateTime` keeps the exact civil instant
(lagna + verified-lunar lookup); `astrologicalDate` carries the sunrise boundary.
`ThaiDayBoundary` is a deprecated shim over `SunriseCalculator` (no hardcoded
06:00). Western/BaZi paths are documented follow-up. See `BIRTH_NORMALIZATION.md`.

---

## Layer 2 — Lens Systems

Lens systems convert raw user data into **domain-specific signals and snapshots**. Each lens is independently usable; none is authoritative alone.

| Lens | Package | Output |
|------|---------|--------|
| Thai Astrology | `lib/features/astrology/thai/` | Theme bundles, Thai mirror sections, full consumer report (see sub-stack below) |
| Western Natal | Astrology services + providers | Chart model for fusion |
| Chinese BaZi | `lib/features/bazi/` | Four pillars, element balance |
| MBTI | `lib/features/tests/mbti/` | Personality type + dimensions |
| EQ | `lib/features/tests/eq/` | 6 module scores |
| Big Five | `lib/features/tests/big_five/` | Five factor scores |
| Personality Mirror | `lib/features/personality_mirror/` | Cross-personality-lens coverage |

**Loader:** `PersonalityLensLoader` aggregates available personality snapshots for a user.

**Astrology-specific fusion (within lens tier):** `lib/features/astrology/fusion/` — Astrology Fusion V6 for multi-system astrology reflection (separate from global cross-mirror fusion).

### Thai Astrology Consumer Report (self-contained sub-stack)

The Thai lens ships an end-to-end **consumer report** that runs independently of the
global narrative pipeline above. It has its own deterministic pipeline, presentation
layer, and QA harness. Full detail: [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md).

```
ThaiBirthData (Firestore profile or QA harness)
  → ThaiFoundationEngine            (lagna, Myanmar Seven, Mahabhuta)
  → ThaiMirrorProfileEnrichment     (fallback lens keys)
  → Theme scoring (resolver → engine → presenter)
  → ThaiMirrorAssembler             (V1 "Truth Lock": structural sections/evidence, no copy)
  → ThaiMirrorNarrativeGenerator    (internal section summaries)
  → LifePeriodEngine.fromBirthDate  (V8: traditional 8-planet life-period sequence)
  → ThaiMirrorConsumerPresenter     (all user-facing Thai copy)
  → ThaiMirrorResultPage            (article-style consumer page)
```

| Concern | Owner |
|---------|-------|
| Birth → profile foundation | `lib/features/astrology/thai/foundation/` |
| Life-period engine (V8) | `lib/features/astrology/thai/core/life_period/` |
| Knowledge foundation (read-only evidence over the frozen rules) | `lib/features/astrology/thai/knowledge/` |
| Knowledge data (data-driven, V2) | `knowledge/planet_relationships/` (JSON; Flutter asset) |
| Knowledge research (V3, engine/matrix-independent) | `lib/features/astrology/thai/knowledge/research/`, data `knowledge/research/` |
| Knowledge evidence + linking (V4) | `lib/features/astrology/thai/knowledge/evidence/`, data `knowledge/evidence/` |
| Source collection (V7) | `lib/features/astrology/thai/knowledge/sources/`, data `knowledge/sources/` |
| Consensus engine (V8) | `lib/features/astrology/thai/knowledge/consensus/` |
| Matrix review proposal (V9) | `lib/features/astrology/thai/knowledge/review/` |
| Canonical knowledge layer (Canon V1) | `lib/features/astrology/thai/knowledge/canon/`, data `knowledge/canon/` — Tier ladder + "Canon always wins" + `หลักมหาภูต` book-ingestion skeleton |
| Mahabhut Canon Database (Canon Extraction V1) | `lib/features/astrology/thai/knowledge/canon/database/`, data `knowledge/canon/` — multi-book Book→Chapter→Section→Topic→Unit DB + manifest system + extraction pipeline + traceability + validation layer (structure only) |
| Mahabhut Ingestion Toolchain (V1) | `lib/features/astrology/thai/knowledge/canon/ingestion/` + CLI `tool/canon_ingest.dart` — pure-Dart import/extract(Candidates)/validate/approve/diff/QA/metrics; restructures provided text only, promotes to the Canon Database |
| Mahabhut Content Engineering (V1) | reviewer aids in `ingestion/` (review assistant + checklist, coverage analysis, consistency checker) + Reviewer Workspace `lib/features/knowledge_workspace/canon_review/` (route `/internal/knowledge/canon-review`, admin-guarded); read-only, composes the toolchain |
| Canon shared util | `canon/canon_json.dart` — single decode-helper leaf (`canonEnumByName`/`canonStringList`), no imports; used by root engine + database + ingestion |
| **Canon Platform Freeze (V1)** | `docs/THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md`, D-056 — platform **FROZEN**/Production Ready; deps verified (leaf → database → ingestion, no cycles/leakage); scope superseded for future-work classification by **Production Mode (D-065)** |
| **Canon Platform Production Mode** | `docs/THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`, D-065 — platform **COMPLETE**; **only supported workflow**: Working Source → AI-assisted Atomic Extraction → Human Review → Ontology → Workspace → Review → Import → Canon DB → Rule Engine → Reasoning → Narrative; future work = Knowledge Production / Ontology Expansion (when required) / Bug Fixes / Performance-only; gaps via reports not redesign; success = Coverage increase |
| **Canon Knowledge Rule (D-066)** | `docs/THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md` — **Extraction allowed, Generation forbidden**: AI MAY deterministically extract the atomic facts *stated on a Canon page* (and resolve ontology terms) but MUST NOT hallucinate, infer beyond the text, interpret, summarize, or use external knowledge; every unit traces to a page; Human Review mandatory before validation/import |
| Canon Atomic Knowledge (V2) | `canon/atomic/` (D-058) — `AtomicKnowledgeUnit` (one fact: subject→relation→object + condition/effect/strength/confidence + reference evidence), relation/entity/domain vocabulary, `AtomicExtractionRules` (reject narrative), `AtomicKnowledgeGraph` (first-class relations), deterministic `CanonCompletenessReport`; pure Dart, no engine/runtime |
| Canon Ontology (V3) | `canon/ontology/` (D-059) — **Canonical Ontology Layer**: `CanonicalEntity` (stable id `<category>.<slug>`, aliases, taxonomy `parentId`, status), `CanonicalOntology` (deterministic alias resolution, relationship registry = superset of V2 `AtomicRelation`, domain taxonomy), deterministic `OntologyValidationReport`, seeded `CanonOntologyData.standard` (vocabulary only). Mandatory vocabulary for all extraction; no package may invent entity/relationship names; pure Dart, no engine/runtime |
| Canon Extraction Workspace (V4) | `canon/workspace/` (D-060) — **only supported Canon ingestion path**: `KnowledgeExtractionSession` (deterministic lifecycle Draft→…→Imported→Archived), `ExtractionSource` (provenance-only page tracking), `WorkspaceValidator` (catches every failure class), `KnowledgeDiff` (NEW/UPDATED/UNCHANGED/CONFLICT/DEPRECATED), `CompletenessDelta` (before/after report), `ReviewReport` (deterministic structured gate). Consumes atomic+ontology read-only; no engine depends on it; pure Dart, no engine/runtime |
| Canon Knowledge Production (V1) | `canon/production/` (D-061) — content-tier: `KnowledgeProductionReport` deterministic per-domain produced/verified/coverage/status over imported atomic units for the 6 foundational domains; ontology seeded 12 houses + `meaning`/`role`/`keyword` categories; `AtomicEntityKind` gains `element`/`keyword`/`role`. **Facts currently Unknown — source book absent; none fabricated.** Pure Dart, no engine/runtime |
| Canon Authoring Studio (V1) | `canon/authoring/` (D-062) — human editing layer **before** the Workspace: `DraftKnowledgeUnit` (editable atomic mirror), `OntologyAssist` (resolved/missingOntology/unknown; never auto-creates), `AuthoringStudio` (batch edit add/duplicate/split/merge/delete/reorder; deterministic ids; validation **preview reuses `WorkspaceValidator`/`ReviewReport`**; export/import reproduces identical draft). Authoring only; consumes workspace+ontology+atomic read-only; pure Dart, no engine/runtime/UI |
| Canon Golden Dataset (V1) | `canon/golden/` (D-063) — QA **regression suite**: `GoldenDataset`+`GoldenExpectation` (declared deterministic outcome; `versionTag`+FNV-1a `fingerprint`), `GoldenVerifier` drives the **real** pipeline (`WorkspaceValidator`/`KnowledgeDiff`/`CompletenessDelta`/`ReviewReport`, no logic reimplemented) and reports mismatches, 10 synthetic fixtures, deterministic `GoldenReport`. QA only — no astrology engine consumes it; no copyrighted text, no invented facts; pure Dart, no engine/runtime/UI |
| Canon Working Source Adapter (V1) | `canon/working_source/` (D-064) — **temporary** source layer feeding the Authoring Studio: one `WorkingSource` interface over `Txt`/`Ocr`/`Pdf`/`Image` adapters → identical `WorkingPage`s via one deterministic paginator; studio consumes only the interface through a provenance-only `ExtractionSource`. Includes `WorkingSourceFolder.loadTxt` (folder of per-page OCR `.txt` → one page each, page# from filename, numeric order, verbatim + UTF-8/EOL normalise only). Never Canon — only book/edition/chapter/page survive; `dispose` discards prose. No automatic extraction, no AI; pure Dart (folder read uses `dart:io`), no engine/runtime/ontology/workspace-redesign |
| Pipeline orchestration | `lib/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart` |
| Structural assembly | `lib/features/astrology/thai/mirror/` |
| Consumer copy + timeline | `lib/features/astrology/thai/mirror/presentation/` (copy/, timeline/) |
| QA harness + preview route | `lib/features/astrology/thai/qa/harness/`, `lib/core/web/` |

A parallel **V2 structural stack** (`foundation/v2/` → `signal/` → `interpretation/`
→ `theme_v2/` → `mirror_v2/` → `fusion_v2/`) exists for validation/fusion work and
is **not** wired into the consumer pipeline today.

The **knowledge foundation** (`lib/.../thai/knowledge/`, D-043) is a read-only
evidence layer that records the provenance of the frozen rules. V1 covered Planet
Relationship only. As of **V2** (D-044) it is **data-driven**: records are loaded
from JSON (`knowledge/planet_relationships/`, a registered Flutter asset) by
`PlanetRelationshipKnowledgeImporter`, which validates the data (schema, missing
fields, unknown enums, duplicates, broken references, matrix-consistency,
coverage) and produces a Knowledge Import Report — no hardcoded records. It
changes no engine behaviour and is not in any runtime/consumer path — see
[`THAI_KNOWLEDGE_IMPORTER_V2.md`](THAI_KNOWLEDGE_IMPORTER_V2.md).

The **knowledge research** layer (`knowledge/research/`, V3/D-045) collects
primary-source references (books/authors/schools/quotes) that support planet
relationships, via `KnowledgeResearchEngine` (group/evidence/conflict/coverage).
It is deliberately **independent of the engine and the matrix** (planets/relations
are plain strings) — see [`THAI_KNOWLEDGE_RESEARCH_V3.md`](THAI_KNOWLEDGE_RESEARCH_V3.md).
**V4** (D-046) adds `EvidenceRecord` + `KnowledgeEvidenceEngine`
(`knowledge/evidence/`): research records reference citable evidence by
`evidenceIds` (many-to-many) instead of embedding source fields; the engine
links the corpora and audits duplicates/broken-links/orphans/coverage — see
[`THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md`](THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md).

#### Thai Astrology Research (public validation surface, `lib/features/thai_beta/`)

A standalone product-validation surface that **reuses** the consumer report above —
it adds no astrology pipeline and no runtime/reasoning change:

```
ThaiBetaInput (public form, /beta/thai)
  → RawBirthInput → BirthNormalizer → ThaiEngineAdapter   (the normalization seam)
  → ThaiMirrorPipeline → ThaiMirrorResultPage             (the existing report)
  → "ข้อมูลที่ใช้คำนวณ" debug panel + structured feedback
  → ThaiBetaStore.save → thai_beta_feedback               (with researchId, hashes, timing)
```

| Concern | Owner |
|---------|-------|
| Input → report runner | `thai_beta/application/thai_beta_analysis.dart` |
| Firestore persistence + sequential research id | `thai_beta/application/thai_beta_store.dart` |
| Dashboard aggregates (pure) | `thai_beta/application/thai_beta_dashboard.dart` |
| Admin gate (fail-closed) | `thai_beta/application/thai_research_admin_access.dart`, `thai_beta/presentation/admin/thai_research_admin_guard.dart` |
| Report fingerprint (SHA-256) | `thai_beta/domain/thai_beta_report_hash.dart` |

**Security model (repo-managed, see `firestore.rules`):** existing data stays
owner-only under `users/{uid}/**`; `thai_beta_feedback` allows public, validated
**create** but **admin-only read**; a bounded `counters/thai_research` (+1-only)
backs sequential `researchId`s (`TH-00000001`); admins are an explicit
`admins/{uid}` allow-list, enforced both by the rules and by
`ThaiResearchAdminGuard` on `/internal/thai-beta`. Saves never fail silently — the
store returns a success/error result and the UI shows the Reference ID or a retry.

The same `ThaiResearchAdminGuard` gates the **Knowledge Workspace**
(`/internal/knowledge`, V5/D-047, `lib/features/knowledge_workspace/`) — a
read-only researcher surface that browses the knowledge/research/evidence layers
(V1–V4), filters by school/author/book/relationship/status/planet, and shows
per-relationship detail (current matrix · research · evidence · conflicts). It
depends on the knowledge layer only (no runtime/prediction) — see
[`THAI_KNOWLEDGE_WORKSPACE_V5.md`](THAI_KNOWLEDGE_WORKSPACE_V5.md).

The same guard gates the **Knowledge Acquisition Dashboard**
(`/internal/knowledge/acquire`, V6/D-048,
`lib/features/knowledge_workspace/acquisition/`) — a JSON-only workbench to
populate the platform gradually. `KnowledgeAcquisitionEngine`/`Session` validate
→ preview → apply → rollback batches (`evidence[]` + `research[]`), classify each
record (imported/updated/skipped/error) and detect conflicts, emitting an Import
Report; `toAssetJson()` exports the merged corpus to commit back to the repo. It
**never modifies the `PlanetRelationshipMatrix`** (merges only the research +
evidence corpora) — see
[`THAI_KNOWLEDGE_ACQUISITION_V6.md`](THAI_KNOWLEDGE_ACQUISITION_V6.md).

On top of the knowledge platform sits an **evidence → consensus → review**
pipeline, all knowledge-layer and matrix-independent: **V7** (D-049) collects
real sources (`knowledge/sources/`, one JSON per source with cited
`from→to→relation→page→quote` assertions; `KnowledgeSourceEngine` validates and
reports source coverage); **V8** (D-050) `KnowledgeConsensusEngine` counts
friend/enemy/neutral votes per directed relationship and classifies agreement
(consensus/majority/split/disputed) with a source-count confidence; **V9**
(D-051) `MatrixReviewEngine` produces a **proposal only** — per relationship the
current matrix value (read from the V2 mirror, never the engine), consensus,
supporting/conflicting sources, user research, and a Keep/Review/Replace
recommendation plus an engine-impact estimate. None of these read or modify the
`PlanetRelationshipMatrix`; acting on a review is a separate human-gated step.
See [`THAI_SOURCE_COLLECTION_V7.md`](THAI_SOURCE_COLLECTION_V7.md),
[`THAI_CONSENSUS_ENGINE_V8.md`](THAI_CONSENSUS_ENGINE_V8.md),
[`THAI_MATRIX_REVIEW_V9.md`](THAI_MATRIX_REVIEW_V9.md).

The Thai lens also exposes a **deterministic reasoning stack** built additively on
the life-period engine: Timeline Intelligence (V9) → Prediction (V10) → Decision
(V11) → Question (V12) → **Thai Reasoning Runtime (V13)**, the single Thai entry
point, with Scenario Simulation (V14) and Transit (V15) layered on top, and the
deterministic **Mirror Conversation** (V16) as the first guided experience. See
`THAI_REASONING_RUNTIME_V13.md` and `THAI_MIRROR_CONVERSATION_V16.md`.

### Global Reasoning Runtime (V17 — cross-system foundation)

**Owner:** `lib/features/runtime/`

The Thai Reasoning Runtime (V13) is now the **reference implementation** for a
system-agnostic runtime architecture. V17 generalizes it **without merging or
rewriting Thai** — Thai remains the first and only implementation, wrapped by an
adapter.

```
ReasoningRuntime  (discovers providers; no hard-coded system dependency)
        ↓ dispatch by ReasoningModule + ReasoningCapability
ReasoningProvider  →  ThaiRuntimeAdapter  →  Thai Reasoning Runtime (V13, frozen)
        ↓
ReasoningResponse  (module-tagged ReasoningEvidence + ReasoningTrace + confidence + raw)
```

| Concern | Owner |
|---------|-------|
| Contracts (`ReasoningProvider`/`Request`/`Response`/`Evidence`/`Trace`/`Module`/`Capability`) | `lib/features/runtime/` |
| Dispatch + capability detection + evidence aggregation | `lib/features/runtime/reasoning_runtime.dart` |
| Provider discovery (no system import) | `lib/features/runtime/reasoning_provider_registry.dart` |
| Thai provider (the only V17 implementation) | `lib/features/runtime/adapters/thai_runtime_adapter.dart` |

Future systems (Western, BaZi, MBTI, Big Five, EQ, Compatibility) add their own
`ReasoningProvider` and register it — the runtime needs no change. See
`GLOBAL_REASONING_RUNTIME_V17.md`.

### Cross-System Fusion Runtime (P2)

**Owner:** `lib/features/runtime/fusion/`

The Fusion Runtime sits **above** the Global Runtime (it composes, never replaces
it). It fans one capability out across every supporting provider, then detects
agreement / conflict / missing evidence / priority and merges everything into one
`FusionResult`.

```
Global Runtime
        ↓ fan out a capability across providers
Fusion Runtime  (agreement · conflict · missing · priority · merged evidence · fused confidence)
        ↓
Conversation  →  Future AI
```

With only the Thai provider registered, fusion runs in **single-provider mode**:
one observation, no agreement/conflict, confidence passed through — same result
shape as multi-provider fusion. The Mirror Conversation (V16) now consumes the
**`FusionRuntime`** (which hosts the Global Runtime with the Thai provider) rather
than the Global Runtime directly. See `GLOBAL_FUSION_RUNTIME_P2.md`.

### Global Mirror Experience (P3 — first product experience)

**Owner:** `lib/features/mirror_experience/`

The platform's first real product surface — a **UX milestone, not an engine**. It
consumes the **`FusionRuntime` only** (never a provider, never a system runtime):
`MirrorExperienceService` reads the cross-system fields of a `FusionResult`
(`priorities`, `mergedEvidence`, `confidence`) and turns them into plain-language
view models, so it touches no Thai types.

```
MirrorHome
        ↓ Begin
MirrorJourney  (Current Life → Prediction → Decision → Ask More → Conversation → Reflection)
        ↓ each stage
MirrorExperienceService → FusionRuntime.fuse(evaluate | predict | decide)
```

Principles: **explain life, not astrology** (no planet/engine terminology on the
surface), **emotion first, evidence second** (numbers behind an expandable
section), and **conversation starts from cards** (driving the V16 flow over
fusion). Wired additively at `/mirror-experience`; the production AuthGate →
ProfileGate → HomePage boot flow is unchanged. A standalone preview boots from
`lib/main_mirror_experience.dart`. See `GLOBAL_MIRROR_EXPERIENCE_P3.md`.

### Product Validation (Phase A — measurement only)

**Owner:** `lib/features/product_validation/`

Instrumentation that **observes** the P3 experience to answer "do users WOW, and
where do they stop?" — no engine/provider/AI, no UI redesign, no runtime change.
The P3 widgets call `ProductValidation.tracker.<event>()` at the measurable
moments; a deterministic `ProductInsightsEngine` turns sessions into per-session
`ProductMetrics`, an engagement `ProductFunnel` and `ProductInsights` (WOW /
curiosity / engagement / drop-off).

```
P3 experience  → ProductValidation.tracker (additive track calls)
                         ↓ in-memory recorder
ProductInsightsEngine → funnel + metrics + insights
                         ↓
Internal dashboard  (/internal/product-validation — not linked from any user surface)
```

Events are in-memory (read by the internal dashboard in-session); a persistent
sink can be added behind the tracker without changing callers. See
`PRODUCT_VALIDATION.md`.

### Home V4 (Phase B — Mirror Experience as the emotional entry)

**Owner:** `lib/features/mirror_experience/ui/mirror_home_section.dart` (+
wiring in `lib/features/home_cohesion/presentation/home_screen_v3.dart` and
`lib/presentation/pages/home/home_page.dart`)

Phase B makes the Mirror Experience the **default emotional entry of Home** —
not a hidden route. An embeddable `MirrorHomeSection` reuses the exact P3 cards
(no duplicated UI) and reveals them inline inside the Home scroll:

```
HomePage (→ HomeScreenV3)
        ↓ birth date available?
  yes → MirrorHomeSection  (Current Life → Prediction → Decision → Conversation → Reflection, revealed inline)
  no  → HomeHeroSection    (legacy hero / unlock onboarding preserved)
        ↓ below the entry (unchanged)
  HomeAstrologySummaryCard → Psychology → Compact Profile
```

`HomePage` derives the birth date from its already-loaded source bundle
(`profileFields['birthDate']`) — no new loader, no extra Firestore read. The
section consumes the **`FusionRuntime` only** (via `MirrorExperienceRuntime`)
and still emits the Phase A telemetry (session/home/journey + per-stage views),
so Product Validation continues to work. The frozen Runtime and the full-page
`MirrorJourney`/`/mirror-experience` route are untouched. See `HOME_V4.md`.

### Daily Mirror (Phase C — Home becomes "Today")

**Owner:** `lib/features/mirror_experience/ui/daily_mirror_section.dart`
(+ `MirrorExperienceService.daily()`)

Phase C turns the Home emotional entry into a **daily life read** rather than a
stage tour. `DailyMirrorSection` replaces the Phase B `MirrorHomeSection` and
shows "Today": three life-guidance messages, one suggested step, one
conversation entry — Prediction / Decision / Timeline never appear as concepts.

```
HomeScreenV3 (birth date present)
        ↓
DailyMirrorSection
        ↓  MirrorExperienceService.daily()  (reuses evaluate + predict + decide reads)
   Today · clarity
   ├─ Today's opening   (opportunity ← strongest forward area)
   ├─ Go gently with    (caution    ← most tender area)
   ├─ Worth your focus  (focus      ← decision focus + lean)
   ├─ One small step     (action     ← decision lean)
   ├─ What this is based on  (expandable evidence — MirrorWhyTile)
   ├─ Something on your mind? → MirrorConversationEntry (inline)
   └─ See the fuller reflection → MirrorHome (secondary, full journey)
```

`daily()` composes the **existing** current-life / forward / decision fusion
reads — no new runtime, provider, capability or AI. Telemetry adds
`dailyMirrorOpened`, `dailyActionClicked`, `dailyConversationStarted` and reuses
`evidenceExpanded`; the section also fires the internal stage events so the
Phase A funnel stays coherent. See `DAILY_MIRROR_PHASE_C.md`.

### Daily Habit Loop (Phase D — make it a daily habit)

**Owner:** `lib/features/mirror_habit/`

Phase D closes the daily loop — **Open → Read → Take Action → Reflect → Return
Tomorrow** — without any new reasoning, AI or astrology. It persists a compact,
non-astrology snapshot of each day (tones + area keys + clarity + the loop flags)
and derives the habit views deterministically.

```
DailyMirrorSection  (Open / Read / Take Action / Reflect)
        ↓ records open → action → reflect
MirrorHabitStore          (users/{uid}/mirror_daily/{dateKey}; lazy + null-uid no-op)
        ↓ MirrorDayRecord[]
MirrorHabitEngine  →  MirrorHabitSnapshot
        ├─ MirrorStreak            (consecutive days, grace day, longest)
        ├─ MirrorComparison        (Yesterday vs Today: focus + clarity shift)
        ├─ MirrorPeriodReflection  (Weekly / Monthly: opens, reflections, tone, area)
        └─ LifeTrend               (rising / steady / easing over ~30d)
        ↓
MirrorHabitSection  (streak · last-7 strip · yesterday · reflect · weekly/monthly · trend · return-tomorrow)

MirrorHabitEngine.metrics()  →  internal dashboard Daily-Habit panel
   (current/longest streak, 7-/30-day retention, sessions/week, reflection rate)
```

The engine is pure (`MirrorHabitEngine` over `MirrorDayRecord`); persistence is a
swappable seam (`MirrorHabitStore` → `FirestoreMirrorHabitStore` /
`InMemoryMirrorHabitStore`, default `MirrorHabit.store`). The Daily Mirror read
itself is unchanged — Phase D only adds a store hook and a section. One new
telemetry event, `dailyReflectionSaved`. See `DAILY_HABIT_PHASE_D.md`.

---

## Layer 3 — Mirror

**Owner:** `lib/features/mirror_v3/`

**Role:** Normalize lens signals into a **`KnowMeMirrorSnapshot`** — agreements, tensions, reinforcements, blind spots, evidence lineage.

```
Lens signals (Thai, BaZi, MBTI, …)
        ↓
KnowMeMirrorEngineInput
        ↓
KnowMeMirrorSnapshotBuilder (MV1)
        ↓
Mirror Promotion Engine (MV2) — optional, additive
        ↓
KnowMeMirrorSnapshot (+ promotedFindings)
```

**Mirror roles in global fusion:**

- `GlobalFusionMirrorRoles.astrology` — Thai + BaZi merged signals
- `GlobalFusionMirrorRoles.personality` — MBTI / Big Five / EQ lenses

**Adapters:** `knowme_mirror_astrology_adapter.dart`, `knowme_mirror_bazi_adapter.dart`  
**Integration:** `lib/features/runtime_integration/pipeline/runtime_mirror_input_builder.dart`

**Freeze:** MV1 core gates unchanged when recovery disabled.

---

## Layer 4 — GF1 (Global Fusion Foundation)

**Owner:** `lib/features/global_fusion/foundation/`

**Role:** Aggregate multiple mirror snapshots into a **`GlobalFusionSnapshot`** — cross-mirror agreements, tensions, normalized themes, confidence.

```
GlobalFusionInput (mirror refs)
        ↓
GlobalFusionFoundationBuilder
        ↓
GlobalFusionSnapshot (GF1)
```

**Freeze:** GF1 v1.0.0 — conditional freeze. Does not consume MV2 promoted findings directly for foundation build.

---

## Layer 5 — GF2 (Global Fusion Recovery)

**Owner:** `lib/features/global_fusion/v2/`

**Role:** Recover findings filtered by GF1/MV1 gates without weakening core gates. Produces a **composed fusion snapshot** for downstream layers.

```
GF1 foundationSnapshot
        ↓
GF2 Recovery Engines (R001–R004)
        ↓
GlobalFusionRecoveryComposer
        ↓
GlobalFusionComposedSnapshot.fusionSnapshot
```

**Feature flag:** `GlobalFusionRecoveryConfig.enabled`  
**Production default for narrative pipeline:** enabled (see `UserRuntimePipelineService`)

**Validated:** 1000-human synthetic gate — `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md`

---

## Layer 6 — Human Model

**Owner:** `lib/features/human_model/`

**Role:** Map fusion snapshot → structured human model with dimensions and source patterns for activation.

```
HumanModelInput(fusionSnapshot)
        ↓
HumanModelFoundationBuilder
        ↓
HumanModelSnapshot
```

Human Model consumes **fusion output only** — no direct mirror bypass.

---

## Layer 7 — Human Pattern

**Owner:** `lib/features/human_pattern/`

**Role:** Activate entries from the pattern registry based on human model sources.

```
HumanPatternInput(humanModelSnapshot)
        ↓
HumanPatternSnapshotBuilder
        ↓
HumanPatternSnapshot (activations)
```

**Recovery V2:** Fixed Category B/E activation resolution in `PatternActivationEngine` — see `docs/HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`.

If activations are empty, narrative cannot generate.

---

## Layer 8 — Narrative Runtime

**Owner:** `lib/features/narrative_runtime/`

**Role:** Generate deterministic **`NarrativeResult`** paragraphs from pattern activations.

```
HumanPatternSnapshot
        ↓
NarrativeRuntimeService.generate
        ↓
NarrativeResult (sections: identity, relationship, decision, growth, …)
```

**Intelligence stack (validated synthetic):**

| Version | Focus |
|---------|-------|
| V2 | Selection ordering |
| V3 | Evidence-aware selection scoring |
| V4 | Plan topology (structural convergence) |
| V5 | Evidence lineage branching (copy divergence) |

**Loaders:**

- `NarrativeRuntimeLoader.loadForUser(uid)` — production Home path
- `UserRuntimePipelineService.loadNarrativeForUser(uid)` — full Firestore → pipeline

**Requires:** Birth profile + at least one personality lens + non-empty pattern activations.

---

## Layer 9 — Home Experience

**Owner:** `lib/features/home_cohesion/`

**Role:** Present the emotional product surface — hero, signature themes, insight cards, profile strip, psychology test cards, funnel recovery UI.

```
HomeV2Loader (Firestore bundle)
        +
NarrativeRuntimeLoader (optional narrative overlay)
        ↓
HomeV3Assembler
        ↓
HomeScreenV3Data → HomeScreenV3 widgets
```

**Funnel Recovery V2 additions:**

- Profile completion bar (`HomeProfileCompletion`)
- Unlock hero + MBTI CTA
- Narrative preview card
- Recovery banner
- Funnel telemetry hooks

**Related presentation (outside home_cohesion):**

- `lib/presentation/pages/bazi/bazi_result_page.dart`
- `lib/features/tests/fusion/` — Fusion result page
- `lib/features/astrology/fusion/presentation/` — Astrology fusion entry

---

## Major Runtime Paths

### Path A — Production Home load

```
HomePage.initState
  → HomeV3Loader.load(uid)
  → HomeV2Loader.loadBundle(uid)
  → NarrativeRuntimeLoader.loadForUser(uid)
  → HomeV3Assembler.fromSources
  → HomeScreenV3 render
```

### Path B — Full user narrative pipeline

```
UserRuntimePipelineService.loadNarrativeForUser(uid)
  → UserProfileBirthLoader + PersonalityLensLoader
  → RuntimeMirrorInputBuilder
  → Dual KnowMeMirrorSnapshotBuilder (astrology + personality)
  → GlobalFusionFoundationBuilder + GlobalFusionRuntimeBuilder.composeRecovery
  → HumanModelFoundationBuilder + HumanPatternSnapshotBuilder
  → NarrativeRuntimeService.generate
```

### Path C — MBTI completion → narrative preview

```
MbtiMiniTestPage.finish
  → FunnelTelemetry (mbti_complete)
  → MbtiNarrativePreviewPage
  → NarrativeRuntimeLoader.loadForUser
  → FunnelTelemetry (narrative_preview_seen)
  → Return to Home (reload)
```

### Path D — Validation replay (synthetic)

```
test/validation/synthetic_population_v3/pipeline/synthetic_human_pipeline_runner_v3.dart
  → Full stack replay on factory-generated profiles
  → JSON output in test/validation/synthetic_population_v3/output/
```

---

## What This Document Does Not Cover

- UI polish specs for Fusion V1 (frozen — see [`FUSION_RESULT_V1_SPEC.md`](FUSION_RESULT_V1_SPEC.md))
- Thai astrology foundation engine internals (see `docs/THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`)
- Scoring algorithms for individual tests (see [`MBTI_ARCHITECTURE.md`](MBTI_ARCHITECTURE.md) and respective `lib/features/tests/` packages)
- Firestore session semantics (see [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md))
- Backend BaZi API (`backend/` — separate from Flutter architecture)

---

## Code Organization

**Preferred layout under `lib/`:**

```
lib/
  core/           # Shared app logic (i18n, theme, constants) — no feature business logic
  data/           # Shared static data (question banks, test_modules.dart)
  features/       # Feature-owned logic (preferred architecture)
  presentation/   # Legacy/general UI — coexistence expected
  services/       # App-wide services (profile, question_service)
```

### Feature pattern

```
lib/features/<feature>/
  domain/
  application/
  data/
  presentation/
  widgets/
```

**Test features:** `lib/features/tests/mbti/`, `mbti_cognitive/`, `mbti_summary/`, etc.

**Rules:**

- Feature owns its logic — avoid cross-feature leakage
- Small focused files; deterministic helpers; presentation isolation
- Avoid 1000-line god files
- Prefer **additive** new folders over rewriting existing systems

### Package ownership (runtime)

| Concern | Owns |
|---------|------|
| Birth profile CRUD | `lib/services/profile_service.dart`, profile pages |
| Test sessions + Firestore writes | `lib/features/tests/*` |
| Mirror contracts + engines | `lib/features/mirror_v3/` |
| Cross-mirror fusion | `lib/features/global_fusion/` |
| Pattern activation | `lib/features/human_pattern/` |
| Narrative generation | `lib/features/narrative_runtime/` |
| Firestore → pipeline adapters | `lib/features/runtime_integration/` |
| Home presentation | `lib/features/home_cohesion/` |
| Funnel analytics | `lib/features/funnel_telemetry/` |
| Validation harnesses | `test/validation/` |

### Hybrid architecture note

Legacy `UniversalTestPage` + feature-specific test architecture coexist intentionally. Do not aggressively unify — see [`CURRENT_STATUS.md`](CURRENT_STATUS.md) technical debt.
