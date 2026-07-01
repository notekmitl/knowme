# DECISION LOG

**Status:** CURRENT
**Audience:** Developers and AI agents.
**Last updated:** June 2026

The record of **why** major architectural and product decisions were made. Future AI
sessions and developers should consult this before reopening any settled decision.

**Rules (see [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) §16 Documentation Policy):**
- Every major architectural or product decision must be recorded here.
- Decisions are append-only. To reverse one, add a **new** decision that supersedes it
  (reference the old ID) — do not delete history.
- **Status** values: `Accepted` · `Superseded` · `Deferred` · `Proposed`.

**Decision index**

| ID | Decision | Date | Status |
|----|----------|------|--------|
| D-001 | Deterministic-before-AI core | 2026-06 | Accepted |
| D-002 | Layered pipeline; downstream never bypasses upstream | 2026-06 | Accepted |
| D-003 | CanonicalProfileResolver — single profile source + legacy migration | 2026-06 | Accepted |
| D-004 | Thai Foundation engine freeze (V1.1 / v0.1.0) | 2026-06 | Accepted |
| D-005 | Western Natal engine freeze (V1) | 2026-06 | Accepted |
| D-006 | Chinese BaZi engine freeze (V1) | 2026-06 | Accepted |
| D-007 | Thai Consumer Report evolution V1→V8 (additive on frozen engine) | 2026-06 | Accepted |
| D-008 | Evidence Composer V7 (evidence-combination personalization) | 2026-06 | Accepted |
| D-009 | Life Period Engine V1 (V8 timeline; evidence-only core) | 2026-06 | Accepted |
| D-010 | QA Harness V1 (render real pipeline/page; screenshot + story coverage) | 2026-06 | Accepted |
| D-011 | Preview Harness + web deep-link auth bypass | 2026-06 | Accepted |
| D-012 | Service worker disabled (no-stale-build policy) | 2026-06 | Accepted |
| D-013 | Astrology API on Cloud Run (FastAPI backend) | 2026-06 | Accepted |
| D-014 | GF2 ships — failure re-attributed to Human Pattern layer | 2026-06 | Accepted |
| D-015 | Narrative intelligence frozen at V5 (terminal) | 2026-06 | Accepted |
| D-016 | Funnel before features (conversion is the priority) | 2026-06 | Accepted |
| D-017 | Documentation governance (index + classification + alignment) | 2026-06 | Accepted |
| D-018 | Freeze policy (maintenance-only + additive exceptions) | 2026-06 | Accepted |
| D-019 | Thai Life Timeline Intelligence V9 (evidence-only relationship/period intelligence) | 2026-06 | Accepted |
| D-035 | Birth Normalization Foundation (single birth-input layer; sunrise boundary) | 2026-06 | Accepted |
| D-036 | Thai pipeline consumes Birth Normalization (migration; single source of truth) | 2026-06 | Accepted |
| D-037 | Birth architecture cleanup (Normalization owns adapters; Thai owns engine models) | 2026-06 | Accepted |
| D-042 | Thai astrological date consistency + 77-province database | 2026-06 | Accepted |
| D-043 | Thai Astrology Knowledge Foundation V1 (traceable evidence over the frozen matrix) | 2026-06 | Accepted |
| D-044 | Thai Astrology Knowledge Importer V2 (data-driven knowledge; JSON + importer) | 2026-06 | Accepted |
| D-045 | Thai Astrology Knowledge Research Infrastructure V3 (primary-source research layer; engine/matrix-independent) | 2026-06 | Accepted |
| D-046 | Thai Astrology Knowledge Evidence Linking V4 (evidence records; research references evidenceIds) | 2026-06 | Accepted |
| D-047 | Thai Astrology Research Workspace V5 (read-only admin knowledge workspace; deployed) | 2026-06 | Accepted |
| D-048 | Thai Astrology Knowledge Acquisition V6 (admin JSON-import workbench: validate/preview/apply/rollback + Import Report; matrix never modified; no deploy) | 2026-06 | Accepted |
| D-049 | Thai Astrology Source Collection V7 (one JSON per real source with cited assertions; validation + Source Coverage Report; knowledge only) | 2026-06 | Accepted |
| D-050 | Thai Astrology Consensus Engine V8 (vote-count agreement between sources; consensus/majority/split/disputed + confidence; matrix never read/modified) | 2026-06 | Accepted |
| D-051 | Thai Astrology Matrix Review V9 (proposal-only review of the frozen matrix vs evidence; Keep/Review/Replace + engine-impact estimate; no code change) | 2026-06 | Accepted |
| D-052 | Thai Astrology Canon V1 (Canonical Knowledge Architecture: Tier ladder + canonical-knowledge nodes + "Canon always wins" resolver + หลักมหาภูต book-ingestion skeleton; engine/matrix frozen; no deploy) | 2026-06 | Accepted |
| D-053 | Thai Astrology Mahabhut Canon Extraction V1 (multi-book Canon Database: Book→Chapter→Section→Topic→Unit + Evidence/CrossRef/SourceRef + manifest system + extraction pipeline + traceability + validation layer; structure only, no extraction; V1-compatible; engine frozen; no deploy) | 2026-06 | Accepted |
| D-054 | Thai Astrology Mahabhut Ingestion Toolchain V1 (pure-Dart toolchain + CLI: import pipeline OCR/txt/md → extraction to Candidates → validation → approval workflow → promote to Canon DB; diff/QA/metrics; restructures provided text only, no fabricated knowledge; engine frozen; no deploy) | 2026-06 | Accepted |
| D-055 | Thai Astrology Mahabhut Content Engineering V1 (human-review layer: reviewer workspace `/internal/knowledge/canon-review` behind admin guard + review assistant/highlights + checklist + coverage analysis + consistency checker + style guide + review checklist; read-only aids, compose existing toolchain, no fabricated knowledge; engine frozen; no deploy) | 2026-06 | Accepted |
| D-056 | Thai Astrology Canon Platform Freeze V1 (platform FROZEN + Production Ready; full audit; behaviour-preserving fixes only: fixed `canon_json.dart` import build break + consolidated duplicate `_enumByName`/`_stringList` helpers; verified no circular deps / layer leakage; future work = Content Engineering only; engine frozen; no deploy) | 2026-06 | Accepted |
| D-057 | Canon Provenance Policy — reference-only citations (book = Canon Reference; never store copyrighted narrative; extraction stops seeding verbatim quote; `missing_citation`/`hasCitation` require a book reference not a quote; DB warns only on no-provenance; checklist "verbatim"→"faithful structured knowledge"; no model redesign; engine frozen; no deploy) | 2026-06 | Accepted |
| D-058 | Canon Atomic Knowledge Foundation V2 (Statement→Atomic Knowledge; pure-Dart `canon/atomic/`: `AtomicKnowledgeUnit` one-fact subject→relation→object + condition/effect/strength/confidence + reference evidence; relation/entity/domain vocabulary; `AtomicExtractionRules` reject narrative & enforce atomicity; `AtomicKnowledgeGraph` first-class relationships; deterministic `CanonCompletenessReport` domain coverage; no redesign/engine/UI/runtime change; no deploy) | 2026-06 | Accepted |
| D-059 | Canon Ontology Foundation V3 (Canonical Ontology Layer; pure-Dart `canon/ontology/`: `CanonicalEntity` id/canonicalName/category/aliases/description/parentId/status, id convention `<category>.<slug>`; `CanonicalOntology` deterministic alias resolution (unknown/ambiguous unresolved), relationship registry superset of V2 `AtomicRelation`, domain taxonomy; deterministic `OntologyValidationReport` dup ids/alias collisions/unregistered rel/category mismatch/orphans/cycles; seeded `CanonOntologyData.standard` vocabulary only; graph logic untouched; no redesign/engine/UI/runtime change; no deploy) | 2026-06 | Accepted |
| D-060 | Canon Knowledge Extraction Workspace V4 (only supported Canon ingestion path; pure-Dart `canon/workspace/`: `KnowledgeExtractionSession` deterministic lifecycle Draft→Extracting→Validated→Reviewed→Approved→Imported→Archived; `ExtractionSource` provenance-only page tracking; `WorkspaceValidator` catches every failure class (atomicity/ontology/relationship/evidence/duplicate/graph+baseline conflict/coverage); `KnowledgeDiff` NEW/UPDATED/UNCHANGED/CONFLICT/DEPRECATED; `CompletenessDelta` before/after report (conflicts not applied); `ReviewReport` deterministic structured non-narrative gate; consumes atomic+ontology read-only, no engine depends on it; no redesign/engine/UI/runtime change; no deploy) | 2026-06 | Accepted |
| D-061 | Canon Knowledge Production V1 (production begins; source book absent so facts left **Unknown**, none fabricated; ontology seeded 12 houses + `meaning`/`role`/`keyword` categories; Canon-compatible fix adds `element`/`keyword`/`role` to `AtomicEntityKind`; content-tier deterministic `KnowledgeProductionReport` `canon/production/` over imported atomic units (6 V1 domains, all-atomic/provenance/coverage); empty `foundation_v1.knowme.json`; knowledge enters only via workspace; no engine/runtime/matrix/UI change; no deploy) | 2026-06 | Accepted |
| D-062 | Canon Knowledge Authoring Studio V1 (human editing layer before the Workspace; pure-Dart `canon/authoring/`: `DraftKnowledgeUnit` editable atomic mirror (no narrative); `OntologyAssist` resolved/missingOntology/unknown, never auto-creates; `AuthoringStudio` deterministic batch edit add/duplicate/split/merge/delete/reorder (stays atomic), deterministic ids, validation **preview reuses `WorkspaceValidator`/`ReviewReport`**, export/import reproduces identical draft; authoring only, consumes workspace+ontology+atomic read-only; no engine/runtime/matrix/UI change; no deploy) | 2026-06 | Accepted |
| D-063 | Golden Canon Dataset V1 (QA regression suite; pure-Dart `canon/golden/`: `GoldenDataset`+`GoldenExpectation` declared deterministic outcome, deterministic `versionTag`+FNV-1a `fingerprint`; `GoldenVerifier` drives the **real** pipeline (`WorkspaceValidator`/`KnowledgeDiff`/`CompletenessDelta`/`ReviewReport`, no logic reimplemented) and reports field mismatches; 10 fixtures (minimal/single planet/single house/planet+house/conflict/duplicate/ontology failure/relationship failure/coverage increase/deprecated); deterministic `GoldenReport`; QA only, synthetic structural fixtures, no copyrighted text, no invented facts; no engine/runtime/matrix/UI change; no deploy) | 2026-06 | Accepted |
| D-064 | Canon Working Source Adapter V1 (temporary source material for the Authoring Studio; pure-Dart `canon/working_source/`: one `WorkingSource` interface over `Txt`/`Ocr`/`Pdf`/`Image` adapters normalised to identical `WorkingPage`s by one deterministic paginator; studio consumes only the interface via provenance-only `ExtractionSource`; **temporary/never Canon** — only book/edition/chapter/page survive, `dispose` discards prose and Canon stays intact; no automatic extraction, no AI, no runtime/engine/ontology change, no workspace redesign; no deploy) | 2026-06 | Accepted |
| D-065 | Canon Platform Production Mode (platform **COMPLETE** and **FROZEN**; transition from Platform Development to Knowledge Production; official pipeline Working Source→Authoring→Atomic Knowledge→Ontology→Workspace→Review→Import→Canon DB→Rule Engine→Reasoning→Narrative is the **only supported production workflow**; future work limited to Knowledge Production / Ontology Expansion (when extraction requires) / Bug Fixes / Performance-without-behaviour-change; platform change only on proven inconsistency or unrepresentable Canon knowledge; gaps via Ontology Gap Report or Knowledge Modeling Gap Report — not platform redesign; success metric = Knowledge Coverage increase, not LOC or new modules; no runtime/engine/workspace redesign; no deploy unless requested) | 2026-06 | Accepted |
| D-069 | Knowledge Production milestone naming — **Production Batch** replaces **Sprint** for ongoing milestones (D-065 Production Mode). Historical Sprints 1–3 remain unchanged (they include platform work: D-067, D-068). From Batch 4 onward: milestones are **Production Batch N** only; goal = Knowledge Coverage; stop only on Ontology Gap / Knowledge Modeling Gap / unrecoverable OCR; deferred items stay deferred; no platform development | 2026-06 | Accepted |
| D-070 | Production **metric report** — each Production Batch reports Coverage by **Planet**, **Archetype**, **Position**, and **Context**. Metrics are **reporting only**: derived from existing Canon units, recomputed/asserted in the production test, with **no** effect on Canon knowledge or runtime and **no** new platform/ontology code. First applied in Production Batch 5 | 2026-06 | Accepted |
| D-072 | Ontology Expansion — **Planet Library attribute categories** (D-065 cat. 2). Adds `attributeCategory` + `attribute` ontology categories and **11 category vocabulary entities** (color, gemstone, metal, taste, disease, bodyPart, place, person type, direction, season, gender) with Thai section-heading aliases from pp.30–36. **Vocabulary only** — no meanings, relationships, or Canon claims. Attribute *value* tokens are added during Batch 8 extraction (parentId → category). Ontology-only first commit; unblocks pp.30–36 production | 2026-07 | Accepted |
| D-073 | **Mahabhut Canon Completion Program** — supersedes Foundation-only Production Charter and Volume 1 production pause. Objective: **Complete Mahabhut Canon** (not foundation-only). Phases C→I: Taksa → Life Period → Prediction Rules → Remedies → Lookup Tables → Final Audit → Freeze. Continue until every representable domain is processed; **do not stop after each batch**. Stop only for genuine Ontology Gap, Knowledge Modeling Gap, or unrecoverable OCR. Ontology expansion allowed when genuinely required (D-065/D-067); modeling changes only when true Modeling Gap proven. Platform/Runtime/Canon architecture unchanged; Knowledge Rule unchanged (D-066). Volume 1 baseline (357 units) is starting point, not scope limit. Final deliverable: **Mahabhut Canon Complete** | 2026-07 | Accepted |
| D-071 | Production **Coverage by Source Page** report — each Production Batch reports per page-range status (Completed / In Progress / Deferred / OCR Blocked / Not Started). This is a **documentation reporting layer only**: it must **not** affect Canon knowledge, ontology, runtime, or validation (kept in the batch doc, not as a test gate). First applied in Production Batch 6. Also: source-internal contradictions (e.g. นักวิชาการ Jupiter at both ธงชัย and ขุมทรัพย์) are recorded **faithfully** as verbatim atomic units and resolved downstream by CanonConflictResolver — never deleted or inferred away, and not a stop condition | 2026-06 | Accepted |
| D-068 | Atomic applicability scope — **`context` qualifier** (resolves Sprint 2B Knowledge Modeling Gap). Adds **one** optional `AtomicContext {type, value}` to `AtomicKnowledgeUnit` (type ∈ archetype_chart/taksa_chart/lagna/life_period/other; value = atomic token from the source). A unit without context = general fact; with context = true only within that scope. The (subject, relation, object) identity is **unchanged** — applicability only. Validation extended (value must be atomic + non-empty; provenance unchanged). **No** Runtime/Rule-Engine/Workspace/Authoring/Canon-DB/ontology redesign. Unblocks chart-scoped production (Sprint 2C) | 2026-06 | Accepted |
| D-067 | Ontology Expansion — **Mahabhut Named Positions** (D-065 cat. 2; Canon knowledge could not be represented). Adds one ontology category `mahabhutPosition` + 7 entities (`thongchai/athibodi/khumsap/racha/puti/marana/phangkha`). **Creation criterion = required by Canon representation** (the book expresses placement through these named positions, so its statements cannot be represented without them); ids + Thai aliases come **only** from the Canon source; OCR frequency is **supporting evidence for prioritization only, never the creation criterion**. **No meanings/interpretations/relationships/strength/bhāva-mapping** encoded. Ontology-only: no Runtime/Workspace/Authoring/Atomic/Canon-DB/Rule-Engine change; existing ids preserved; ontology validates clean. Unblocks Mahabhut production; first real batch produced (Sprint 2A) | 2026-06 | Accepted |
| D-066 | Knowledge Rule clarification — **Extraction allowed, Generation forbidden** (clarifies D-065; AI MAY perform deterministic information extraction FROM the Canon source text — read the page, identify atomic facts stated there, restructure into atomic triples, resolve ontology terms — but MUST NOT hallucinate, infer beyond the text, interpret, summarize, or use external knowledge; every unit traces to a page; workflow Book→OCR→Working Source→AI-assisted Atomic Extraction→Human Review→Workspace Validation→Canon Import; Human Review mandatory; reference-only provenance unchanged; documentation/policy only, no code/runtime/engine/platform change) | 2026-06 | Accepted |

---

## D-001 — Deterministic-before-AI core

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Astrology/personality products often lean on LLMs, which are
  unpredictable, hard to debug, and can overclaim.
- **Decision:** Core astrology, MBTI summary fusion, and the narrative runtime contain
  **no LLM dependency**. Identical inputs always produce identical outputs.
- **Reason:** Predictable, debuggable, explainable, reproducible UX; testable via
  synthetic-population gates.
- **Alternatives considered:** LLM-generated narrative; hybrid LLM+templates.
- **Tradeoffs:** More engineering for diversity/naturalness (solved via Narrative
  V2–V5 and the Thai evidence composer) vs. effortless variety from an LLM.
- **Impact:** All engines are testable and frozen-able; AI is a deferred future *layer
  on top*, never a core dependency.
- **Related documents:** `KNOWME_MASTER_CONTEXT.md`, `AI_ALIGNMENT_CONTEXT.md`.
- **Related implementation:** `lib/features/narrative_runtime/`, `lib/features/astrology/thai/`.

## D-002 — Layered pipeline; downstream never bypasses upstream

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Multiple lenses feed multiple consumers; uncontrolled coupling would
  make changes unsafe.
- **Decision:** A strict layered pipeline — Lens → Mirror (MV1/MV2) → GF1 → GF2 →
  Human Model → Human Pattern → Narrative → Home. Each layer consumes only the layer
  above's contract.
- **Reason:** Isolated, replaceable layers; freezes can be applied per layer.
- **Alternatives considered:** Direct lens→narrative shortcuts; a monolithic builder.
- **Tradeoffs:** More contracts/adapters vs. lower blast radius.
- **Impact:** Enables per-layer freeze and additive recovery (MV2/GF2).
- **Related documents:** `ARCHITECTURE.md`, `EXECUTIVE_SUMMARY.md`.
- **Related implementation:** `lib/features/mirror_v3/`, `lib/features/global_fusion/`, `lib/features/human_model/`, `lib/features/human_pattern/`.

## D-003 — CanonicalProfileResolver

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Legacy code wrote birth fields to the user root doc (`users/{uid}`);
  newer code expects `users/{uid}/profile/main`. Two readers risked divergence.
- **Decision:** A single `CanonicalProfileResolver` owns reads/writes of
  `users/{uid}/profile/main` and performs **idempotent** migration of legacy root birth
  fields into the canonical path.
- **Reason:** One source of truth for the profile; safe coexistence with legacy data.
- **Alternatives considered:** Migrate-all batch job; keep dual readers; rewrite legacy
  writers.
- **Tradeoffs:** A migration shim persists vs. a riskier big-bang migration.
- **Impact:** Profile reads are consistent across Home, fusion, astrology, narrative.
- **Related documents:** `FIRESTORE_SCHEMA.md`, `ARCHITECTURE.md`.
- **Related implementation:** `lib/core/profile/canonical_profile_resolver.dart`,
  `lib/services/profile_service.dart`, `test/canonical_profile_resolver_test.dart`.

## D-004 — Thai Foundation engine freeze

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The Thai foundation/theme/assembler engines were validated and
  production-ready; ongoing product work was in presentation, not calculation.
- **Decision:** Freeze the Thai engine at **V1.1 / v0.1.0** (conditional freeze);
  iterate only on the additive presentation layer.
- **Reason:** Protect validated deterministic calculations while UX evolves.
- **Alternatives considered:** Keep iterating on the engine; reopen for houses/aspects.
- **Tradeoffs:** New chart features deferred vs. calculation stability.
- **Impact:** Established the copy boundary (engine emits structure/evidence only).
- **Related documents:** `PROJECT_FREEZE.md`, `GOVERNANCE.md`, `THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`.
- **Related implementation:** `lib/features/astrology/thai/foundation/`, `theme/`, `mirror/`.

## D-005 — Western Natal engine freeze

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Western Natal V1 was E2E-verified and consumed mainly as a fusion input.
- **Decision:** Temporary freeze; maintenance only, no result-page/chart redesign.
- **Reason:** It is an input, not a primary surface; stability over expansion.
- **Alternatives considered:** Promote Western to a primary report.
- **Tradeoffs:** No Western consumer report vs. focus on Thai + funnel.
- **Impact:** Western remains a stable fusion contributor.
- **Related documents:** `PROJECT_FREEZE.md`, `GOVERNANCE.md`.
- **Related implementation:** astrology services + Firestore `users/{uid}/astrology/western_natal`.

## D-006 — Chinese BaZi engine freeze

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** BaZi V1 (backend + Flutter) was verified; the source of truth is
  `users/{uid}/astrology/chinese_bazi` (not `results/`).
- **Decision:** Temporary freeze of the Four Pillars / Day Master engine; extend only
  via the additive **Chinese Zodiac Personality Expansion** (content library + resolver).
- **Reason:** Keep the verified engine stable; allow additive content value.
- **Alternatives considered:** Reopen the engine for zodiac personality.
- **Tradeoffs:** Expansion limited to content vs. engine changes.
- **Impact:** Clear additive lane for zodiac content without core risk.
- **Related documents:** `PROJECT_FREEZE.md`, `GOVERNANCE.md`, `BAZI_MIRROR_INTEGRATION_V1.md`, `CHINESE_ZODIAC_IMPACT_VALIDATION_V1.md`.
- **Related implementation:** `lib/features/bazi/`, `lib/services/bazi_firestore_service.dart`, backend BaZi API.

## D-007 — Thai Consumer Report evolution V1→V8

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The original V1 mirror was an analyst-style, nine-section fusion view.
  The product needed a warm, readable consumer report.
- **Decision:** Evolve the report **additively** through V1→V8 (long-form narrative,
  article-style page, storytelling polish, contradiction observations, evidence
  personalization, life timeline) on top of the **frozen** engine, via a strict copy
  boundary.
- **Reason:** Deliver consumer value without reopening validated calculations.
- **Alternatives considered:** Rebuild the report end-to-end; let engines emit copy.
- **Tradeoffs:** Presentation complexity (composers, CI gates) vs. engine safety.
- **Impact:** The original V1 specs became HISTORICAL/SUPERSEDED; `EXECUTIVE_SUMMARY.md`
  is now authoritative.
- **Related documents:** `EXECUTIVE_SUMMARY.md`, `THAI_MIRROR_SPECIFICATION_V1.md`, `THAI_MIRROR_UI_SPECIFICATION_V1.md`.
- **Related implementation:** `lib/features/astrology/thai/mirror/presentation/`.

## D-008 — Evidence Composer V7

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Earlier consumer copy was templated and repetitive across profiles.
- **Decision:** Introduce an evidence-combination-driven composer (`ReportFacet` /
  `ReportTone` / `EvidenceProfile`) that personalizes headlines, hero, contradictions,
  and signature lines.
- **Reason:** Differentiated, natural copy that stays deterministic and traceable.
- **Alternatives considered:** LLM copy; larger static phrase banks.
- **Tradeoffs:** More composer logic vs. genuine per-profile divergence.
- **Impact:** Reduced cross-profile similarity; validated by similarity/diversity audits.
- **Related documents:** `EXECUTIVE_SUMMARY.md`.
- **Related implementation:** `presentation/copy/thai_mirror_evidence_composer.dart`, `thai_mirror_report_copy.dart`.

## D-009 — Life Period Engine V1 (V8 timeline)

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Users wanted to understand *why life changes over time*, not just a
  static identity snapshot.
- **Decision:** Add a `LifePeriodEngine` based on the traditional eight-planet life
  cycle. The **core engine returns evidence only**; scoring and narrative live in the
  presentation timeline layer.
- **Reason:** Keep the engine reusable for future features (annual prediction,
  compatibility, fusion) and preserve the copy boundary.
- **Alternatives considered:** Bake scoring/copy into the engine; static age bands.
- **Tradeoffs:** Extra presentation layer vs. a reusable, testable core.
- **Impact:** Shipped the Life Timeline; engine reusable for V9+ prediction surfaces.
- **Related documents:** `EXECUTIVE_SUMMARY.md`, `ASTROLOGY_QA_HARNESS_V1.md`.
- **Related implementation:** `lib/features/astrology/thai/core/life_period/`, `presentation/timeline/`.

## D-010 — QA Harness V1

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Manual visual QA of the consumer report was slow, non-deterministic, and
  blocked by auth/service-worker friction.
- **Decision:** Build a harness that renders the **real production pipeline and page**
  (never a duplicate UI), with screenshot regression (A–H × viewports, pinned `asOf`)
  and story-coverage CI gates.
- **Reason:** Deterministic, automated quality gates; faithful to production.
- **Alternatives considered:** Hand-written widget fixtures; a separate preview UI.
- **Tradeoffs:** Harness maintenance vs. trustworthy, repeatable QA.
- **Impact:** Presentation changes are gated before deploy; pattern is reusable across
  report domains.
- **Related documents:** `ASTROLOGY_QA_HARNESS_V1.md`, `EXECUTIVE_SUMMARY.md`.
- **Related implementation:** `lib/features/astrology/thai/qa/harness/`, `test/validation/thai_mirror_qa_harness/`.

## D-011 — Preview Harness + web deep-link auth bypass

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** QA/preview needed to open any report state from a URL without login,
  incognito, or manual cache clears.
- **Decision:** A `/thai-mirror/consumer-preview` route + `WebLaunchRouter` that parses
  the browser URL (`Uri.base`) and bypasses `AuthGate` for preview deep links.
- **Reason:** Shareable, deterministic previews for QA and review.
- **Alternatives considered:** A logged-in-only internal QA screen.
- **Tradeoffs:** A web-only auth-bypass path (scoped to preview routes) vs. friction.
- **Impact:** Enabled the screenshot harness and shareable review links.
- **Related documents:** `ASTROLOGY_QA_HARNESS_V1.md`.
- **Related implementation:** `lib/core/web/`, `presentation/pages/thai_mirror_consumer_preview_page.dart`.

## D-012 — Service worker disabled (no-stale-build policy)

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The deprecated Flutter web service worker forced `Ctrl+Shift+R`/incognito
  to see fresh deploys.
- **Decision:** Do not register a service worker; unregister/clear any existing one
  once; serve entry files (`index.html`, `main.dart.js`, `flutter.js`,
  `flutter_bootstrap.js`, `flutter_service_worker.js`) as `no-cache`.
- **Reason:** Latest build activates on the next normal page load.
- **Alternatives considered:** Custom SW update prompts; cache-busting query strings.
- **Tradeoffs:** No offline caching vs. always-fresh deploys.
- **Impact:** Removed stale-build friction for QA and users.
- **Related documents:** `ASTROLOGY_QA_HARNESS_V1.md` §3, `DEPLOYMENT.md`.
- **Related implementation:** `web/index.html`, `firebase.json`.

## D-013 — Astrology API on Cloud Run

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Astrology + BaZi chart generation runs in a Python/FastAPI backend
  separate from the Flutter client.
- **Decision:** Host the astrology API on **Google Cloud Run**; the web deploy injects
  the Cloud Run base URL via `--dart-define=ASTROLOGY_API_BASE_URL`, with a production
  fallback baked into release builds so a plain build cannot ship `localhost`.
- **Reason:** Scalable, managed backend; clean separation from the Flutter app.
- **Alternatives considered:** Bundle astrology logic in-app; Cloud Functions.
- **Tradeoffs:** A separate deploy step + network dependency vs. server-side compute.
- **Impact:** Two-step production deploy (API then web); base URL configured centrally.
- **Related documents:** `DEPLOYMENT.md`.
- **Related implementation:** `lib/core/config/api_config.dart`, `lib/services/astrology_api_service.dart`, `lib/services/bazi_api_service.dart`, `scripts/deploy_astrology_api.ps1`, `config/astrology_api_base_url.txt`.

## D-014 — GF2 ships; failure re-attributed to Human Pattern layer

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** A pre-implementation calibration gate recommended **rejecting** GF2
  because VG-002 (`stable_orientation`) failed under frozen Human-Pattern rules.
- **Decision:** Root-cause isolation proved the failure was owned by the **Human
  Pattern activation layer** (wrong source-type selection), not GF2. Fix HP
  (`_resolveSourcePattern`, Recovery V2) and **ship GF2**.
- **Reason:** The gate measured the wrong layer; fixing HP recovered the pattern.
- **Alternatives considered:** Reject GF2; weaken MV1/GF1 gates.
- **Tradeoffs:** Extra investigation effort vs. shipping a correct, validated recovery.
- **Impact:** GF2 passed the 1000-human gate and shipped (flag-gated).
- **Related documents:** `GF2_ROOT_CAUSE_ISOLATION_REPORT.md`, `GF2_FINAL_IMPLEMENTATION_DECISION.md` (superseded), `HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`, `GF2_PRODUCTION_IMPLEMENTATION_V1.md`.
- **Related implementation:** `lib/features/global_fusion/v2/`, `lib/features/human_pattern/engines/pattern_activation_engine.dart`.

## D-015 — Narrative intelligence frozen at V5

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Narrative output collapsed at scale; an intelligence stack (V2 selection
  → V3 evidence-aware → V4 plan topology → V5 evidence branching) reached 1000/1000
  unique on the synthetic population.
- **Decision:** Treat V5 as the **terminal** narrative-intelligence state; further work
  is additive copy (registry), not engine reopening.
- **Reason:** The diversity goal was met and validated.
- **Alternatives considered:** Continue iterating the intelligence stack.
- **Tradeoffs:** Locks the algorithm vs. avoids churn on a solved problem.
- **Impact:** Narrative engine is frozen; AI narrative is a separate future layer.
- **Related documents:** `NARRATIVE_EVIDENCE_BRANCHING_V5.md`, `NARRATIVE_INTELLIGENCE_SELECTION_V3.md`, `NARRATIVE_PLAN_TOPOLOGY_V4.md`.
- **Related implementation:** `lib/features/narrative_runtime/intelligence/`.

## D-016 — Funnel before features

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Real-user replay (38 users) showed only ~2.6% reach the narrative; the
  cliff is after astrology, before any personality test — not an engine failure.
- **Decision:** Prioritize **funnel conversion** (Home unlock, completion bar, MBTI
  mini → instant narrative preview, telemetry) over new engines/features.
- **Reason:** Validated engines deliver no value if users never reach them.
- **Alternatives considered:** Build more lenses/engines first.
- **Tradeoffs:** Defer engine expansion vs. fix the actual bottleneck.
- **Impact:** Funnel Recovery V2 implemented; conversion is the active priority.
- **Related documents:** `REAL_USER_RUNTIME_VALIDATION_V1.md`, `PRODUCTION_FUNNEL_RECOVERY_V1.md`, `ROADMAP.md`, `CURRENT_STATUS.md`.
- **Related implementation:** `lib/features/home_cohesion/`, `lib/features/funnel_telemetry/`.

## D-017 — Documentation governance

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Docs had drifted from the implementation (stale Thai status, a broken
  README, no master index, no alignment file).
- **Decision:** Establish a governed documentation system: `PROJECT_INDEX.md` (map +
  classification), `AI_ALIGNMENT_CONTEXT.md` (rules + reading order), `EXECUTIVE_SUMMARY.md`
  (whole-project), `PROJECT_FREEZE.md` (freeze registry), `DOMAIN_MODEL.md` (concepts),
  and this `DECISION_LOG.md`; classify historical docs with banners; never delete history.
- **Reason:** Keep documentation a reliable, navigable source of truth for AI + humans.
- **Alternatives considered:** Ad-hoc docs; delete stale files.
- **Tradeoffs:** Upkeep discipline vs. trustworthy documentation.
- **Impact:** Implemented across the documentation sprints; codified in the
  Documentation Policy (`AI_ALIGNMENT_CONTEXT.md` §16).
- **Related documents:** `PROJECT_INDEX.md`, `AI_ALIGNMENT_CONTEXT.md`, `EXECUTIVE_SUMMARY.md`, `DOMAIN_MODEL.md`.
- **Related implementation:** `docs/` (documentation only).

## D-018 — Freeze policy

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Legacy + new architectures coexist; aggressive rewrites risk production.
- **Decision:** Most systems are **maintenance-only** (blocker fixes, serious
  usability, analytics-driven, incidents). Extensions happen via **additive exception
  programs** (Consumer Report presentation, QA harness, Funnel Recovery, Chinese Zodiac
  Expansion), never by reopening frozen contracts.
- **Reason:** Stability > correctness > architecture purity > speed.
- **Alternatives considered:** Open refactoring; unify parallel architectures.
- **Tradeoffs:** Accept duplication/parallel stacks vs. lower blast radius.
- **Impact:** Codified in `GOVERNANCE.md` + `PROJECT_FREEZE.md`; enforced by alignment rules.
- **Related documents:** `GOVERNANCE.md`, `PROJECT_FREEZE.md`, `AI_ALIGNMENT_CONTEXT.md`.
- **Related implementation:** repository-wide policy.

## D-019 — Thai Life Timeline Intelligence V9

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The V8 Life Period Engine produced a period *sequence* and the
  presentation layer scored/narrated it, but the engine had only a thin
  friend/neutral/enemy relationship table. The product goal shifted from UI
  polish to making the Thai engine *significantly more intelligent*: planet
  relationships, per-period intelligence, current-age analysis, future-period
  preview.
- **Decision:** Add a V9 **Life Timeline Intelligence** layer **additively** in
  the reusable core (`core/life_period/`), emitting **evidence only**:
  a combined Planet Relationship Engine (natural friend/enemy + element
  supporting/conflicting → a `PlanetBond` of support/harmony/neutral/friction/
  conflict), per-period `PeriodIntelligence` (ruler, element, strength tier,
  natal + neighbour interaction), `CurrentAgeAnalysis` (dominant influences +
  why-it-matters factors), and `FuturePeriodPreview` (transition, element shift,
  opportunities, challenges), bundled by `LifeTimelineIntelligenceEngine`. The
  V8 `PlanetRelationshipMatrix` is reused untouched; presentation owns all prose
  via a new `PeriodIntelligenceComposer`.
- **Reason:** Deepen interpretation while preserving the deterministic, frozen
  engine and the copy boundary (D-001, D-004, D-007, D-009). Keeps the engine
  reusable for Future/Annual Prediction, Compatibility and Fusion.
- **Alternatives considered:** Bake intelligence/scoring/copy into the engine;
  reopen the frozen foundation; an LLM interpretation layer.
- **Tradeoffs:** More evidence types/composers vs. richer, traceable
  interpretation with no engine risk.
- **Impact:** No new runtime path, no pipeline-contract change; the consumer
  report's Life Timeline gains a "ทำไมช่วงนี้ถึงสำคัญ" analysis card and a
  "ช่วงต่อไปของคุณ" future-preview card. Engine tests + story-coverage CI pass;
  V8 diversity unaffected.
- **Related documents:** `THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`,
  `EXECUTIVE_SUMMARY.md`, `PROJECT_FREEZE.md`, `DOMAIN_MODEL.md`.
- **Related implementation:** `lib/features/astrology/thai/core/life_period/`
  (V9 modules), `presentation/timeline/period_intelligence_composer.dart`,
  `test/validation/thai_mirror_v9_intelligence/`.

## D-020 — Thai Prediction Intelligence Foundation V10

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** V9 made the Thai engine *interpret* who a person is and where they
  are in their life-period timeline, but produced no structured *reasoning about
  what tends to happen* per life area. The next step is a prediction substrate —
  explicitly **not AI and not Transit** — that several future features (Future
  Prediction, Transit, Compatibility, AI Conversation) can all reuse.
- **Decision:** Add a V10 **Prediction Intelligence Foundation** as a new,
  additive, reusable core package (`core/prediction/`) that consumes the V9
  `LifeTimelineIntelligence` bundle (current-age analysis, future preview,
  per-period planet relationships, natal context) and emits **deterministic
  evidence only**: a `Prediction` per `PredictionCategory` (Career, Finance,
  Relationship, Health, Learning, Personal Growth, Family) × `PredictionWindow`
  (Current, Next 12 months, Next Life Period), each carrying a `PredictionScore`
  (strength + confidence), typed `PredictionEvidence`, `PredictionOpportunity`/
  `PredictionRisk` lists and three `PredictionReason`s (timing, planet, life
  period). Reasons are emitted as **codes**, never prose.
- **Reason:** Establish one deterministic reasoning layer rather than letting
  each downstream feature re-derive predictions, while preserving the frozen
  engines, the copy boundary (D-001, D-004, D-007, D-009) and reproducibility.
- **Alternatives considered:** Generate forecasts with an LLM; fold prediction
  into the timeline presenter; introduce transit math now.
- **Tradeoffs:** Another evidence vocabulary to maintain vs. a single shared,
  testable substrate with zero engine/UI risk.
- **Impact:** **No runtime, UI, Firestore or routing changes** — engine + tests
  + docs only. Nothing consumes it yet; it is the foundation a later
  presentation/feature layer will build on. Determinism, evidence-integrity,
  stability and window-calculation tests pass.
- **Related documents:** `THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`,
  `THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`, `EXECUTIVE_SUMMARY.md`,
  `PROJECT_FREEZE.md`, `DOMAIN_MODEL.md`.
- **Related implementation:** `lib/features/astrology/thai/core/prediction/`,
  `test/validation/thai_mirror_v10_prediction/`.

## D-021 — Thai Future Prediction Presentation V10.5 (first production release)

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The V10 Prediction Intelligence Foundation (D-020) shipped as a
  deterministic, copy-free engine that nothing consumed yet. The product needed
  to surface those predictions to users **inside the existing Thai Consumer
  Report** — without a new result page, route or pipeline — to make V10 the
  first production release of Thai Prediction Intelligence.
- **Decision:** Add an **additive presentation layer** that consumes
  `PredictionIntelligence` only and renders a new **Future Prediction** section
  between the Life Timeline and the Signature Insight. New presentation-only
  components: `PredictionReasonCopy` (the sole place `PredictionReasonCode`s
  become Thai prose), `PredictionSectionModel` (UI view state),
  `PredictionComposer` (evidence → tendency copy, deterministic by seed) and
  `ThaiMirrorFuturePredictionSection` (the `PredictionWidget`). Each horizon
  (Current · Next 12 Months · Next Life Period) shows a top opportunity, top
  risk, a qualitative confidence meter (no number), and Why / Why Now / What To
  Watch plus technical planet evidence behind an expandable detail.
- **Reason:** Preserve the copy boundary (engine stays code-only; the presenter
  translates), keep the production flow/page/pipeline untouched, and honour the
  UX rules — tendency language, no astrology terminology or planet names in the
  headline copy, article style readable in under two minutes.
- **Alternatives considered:** A standalone prediction page/route; letting the
  timeline presenter emit predictions; showing raw confidence percentages.
- **Tradeoffs:** A second composer/view-state to maintain vs. a clean,
  testable, reusable surface with zero engine risk.
- **Impact:** Engine unchanged; one optional view-state field, one new section
  in the existing page. Story-coverage and screenshot-regression gates extended
  to cover the new section (goldens regenerated). Deployed to production as the
  first Thai Prediction Intelligence release.
- **Related documents:** `THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`,
  `EXECUTIVE_SUMMARY.md`, `ROADMAP.md`, `CURRENT_STATUS.md`, `PROJECT_INDEX.md`.
- **Related implementation:**
  `lib/features/astrology/thai/mirror/presentation/prediction/`,
  `lib/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_future_prediction_section.dart`,
  `test/validation/thai_mirror_v10_prediction_presentation/`.

## D-022 — Thai Decision Intelligence Foundation V11

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** V10 (D-020) predicts strength/risk/confidence per life area and
  horizon, and V10.5 (D-021) surfaces those predictions. The next reasoning step
  is to convert predictions into **actionable decision guidance** for concrete
  life choices (career change, marriage, investment, …) — still deterministic,
  still evidence-only, and reusable by future Transit / Compatibility / AI Chat.
- **Decision:** Add the **Decision Intelligence Foundation** as a new reusable
  core package `lib/features/astrology/thai/core/decision/`. It consumes V10
  `PredictionIntelligence` (via a read-only `DecisionContext`) and, for each of
  ten Supported Scenarios (V1), emits a `DecisionRecommendation`: a verdict
  (`shouldAct` / `shouldPrepare` / `shouldWait` / `shouldAvoid`), confidence,
  four reasons (favourability/timing/risk/natal), supporting & conflicting
  evidence traceable to six input families, best/worst timing, tradeoffs and a
  projected outcome. Each scenario maps onto weighted V10 categories and a
  `stakes` level (1–3) that derives its risk weighting and act/avoid thresholds.
- **Reason:** Keep the copy boundary intact (codes only, no Thai prose, no
  presenter, no UI), reuse the V9/V10 evidence rather than re-deriving anything,
  and make the verdict reconstructable from its reasons/evidence so it is fully
  testable and reusable by later features.
- **Alternatives considered:** Folding decision logic into the V10 engine or the
  presenter; emitting per-scenario copy now; introducing transit/compatibility
  inputs early.
- **Tradeoffs:** Another evidence vocabulary to maintain vs. a single shared,
  testable substrate with zero engine/UI risk.
- **Impact:** **No runtime, UI, Firestore or routing changes** — engine + tests
  + docs only. Nothing consumes it yet; it is the foundation a later
  presentation/feature layer will build on. Determinism, consistency,
  evidence-traceability, scenario-stability and timing-stability tests pass.
- **Related documents:** `THAI_DECISION_INTELLIGENCE_V11.md`,
  `THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`, `EXECUTIVE_SUMMARY.md`,
  `ROADMAP.md`, `CURRENT_STATUS.md`, `DOMAIN_MODEL.md`, `PROJECT_INDEX.md`,
  `PROJECT_FREEZE.md`.
- **Related implementation:** `lib/features/astrology/thai/core/decision/`,
  `test/validation/thai_mirror_v11_decision/`.

## D-023 — Thai Question Reasoning Foundation V12

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** V11 (D-022) produces per-scenario decision guidance. The next
  reasoning step is to let a caller ask concrete questions ("Should I…?", "When
  should I…?", "What is the biggest risk…?") and get a structured answer —
  without an LLM, a natural-language parser, or any copy — so the same substrate
  can power a future AI front-end or voice assistant deterministically.
- **Decision:** Add the **Question Reasoning Foundation** as a new reusable core
  package `lib/features/astrology/thai/core/question/`. It consumes **structured
  intent objects** (`QuestionIntent` = kind + topic + optional constraint), never
  parsed text. Each of ten Supported Topics routes 1:1 onto a V11
  `DecisionScenario`; the engine reads that recommendation and **re-projects the
  existing decision evidence** (it recomputes nothing) into a `QuestionResult`:
  a structured answer (stance from the verdict, or informational), relevant
  windows (focus/best/worst), relevant evidence (the original V11 atoms
  re-ranked by intent, provenance preserved), priority reasons (re-ordered by the
  intent's emphasis axis) and confidence (= the underlying decision confidence).
- **Reason:** Keep the copy boundary intact (codes/stances only, no Thai prose,
  no presenter, no UI), avoid an LLM/parser in the deterministic core, and make
  every answer fully traceable to V11 evidence so it is testable and reusable.
- **Alternatives considered:** Parsing free-text questions; folding question
  routing into the decision engine or a presenter; recomputing scenario-specific
  scores per question.
- **Tradeoffs:** Another small vocabulary (intents/stances) to maintain vs. a
  clean, testable, reusable query surface with zero engine risk.
- **Impact:** **No runtime, UI, Firestore or routing changes** — engine + tests
  + docs only. Determinism, intent-mapping, scenario-resolution,
  evidence-traceability and confidence-stability tests pass.
- **Related documents:** `THAI_QUESTION_REASONING_FOUNDATION_V12.md`,
  `THAI_DECISION_INTELLIGENCE_V11.md`, `EXECUTIVE_SUMMARY.md`, `ROADMAP.md`,
  `CURRENT_STATUS.md`, `DOMAIN_MODEL.md`, `PROJECT_INDEX.md`, `PROJECT_FREEZE.md`.
- **Related implementation:** `lib/features/astrology/thai/core/question/`,
  `test/validation/thai_mirror_v12_question/`.

## D-024 — Thai Unified Reasoning Runtime V13

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** V9–V12 produced four separate reasoning layers (Timeline,
  Prediction, Decision, Question), each chained onto the one beneath it. Any
  caller (and especially future features — Transit, Compatibility, AI
  Conversation) had to know that wiring: which engine builds which, in what
  order, and how to thread results through. That couples every consumer to the
  internal pipeline and risks inconsistent wiring.
- **Decision:** Add the **Unified Reasoning Runtime** as a new core package
  `lib/features/astrology/thai/core/runtime/`. `ThaiReasoningRuntime` is the
  single public reasoning entry point. It exposes `evaluate()`, `predict()`,
  `decide()`, `question()` and `answer()`, taking one structured
  `ReasoningRequest` (chart anchors + optional question intent + optional
  scenario focus) and returning one `ReasoningResponse`: per-layer snapshots
  (Timeline/Prediction/Decision/Question — deeper ones null when not reached),
  flattened cross-layer `ReasoningEvidence`, a `ReasoningTrace` of ordered
  `ReasoningStep`s, and an overall confidence drawn from the deepest layer that
  ran. The runtime orchestrates the existing engines unchanged and recomputes
  nothing of their internal logic.
- **Reason:** Give every present and future consumer one stable surface, hide
  the orchestration wiring, keep determinism and full evidence traceability, and
  preserve the copy boundary (codes/snapshots only — no Thai prose, presenter,
  UI, Firestore, parser or LLM).
- **Alternatives considered:** Letting each feature wire the four engines
  itself; exposing the raw engine results without snapshots/trace; folding
  orchestration into the question engine.
- **Tradeoffs:** A thin orchestration + snapshot layer to maintain vs. removing
  duplicated, drift-prone wiring from every consumer.
- **Impact:** **No runtime-behaviour, UI, Firestore or routing changes** —
  additive engine + tests + docs only. The four underlying engines are
  untouched. Determinism, runtime-consistency, trace-integrity and
  evidence-integrity tests pass.
- **Related documents:** `THAI_REASONING_RUNTIME_V13.md`,
  `THAI_QUESTION_REASONING_FOUNDATION_V12.md`,
  `THAI_DECISION_INTELLIGENCE_V11.md`, `EXECUTIVE_SUMMARY.md`, `ROADMAP.md`,
  `CURRENT_STATUS.md`, `DOMAIN_MODEL.md`, `PROJECT_INDEX.md`,
  `PROJECT_FREEZE.md`.
- **Related implementation:** `lib/features/astrology/thai/core/runtime/`,
  `test/validation/thai_mirror_v13_runtime/`.

## D-025 — Thai Scenario Simulation Foundation V14

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** V13 (D-024) gave one orchestration entry point. The next reasoning
  step is to let a caller weigh **hypothetical decision paths** ("what if I act
  now vs at the best window vs not at all?") and compare them — deterministically,
  with no AI, and without re-implementing decision logic.
- **Decision:** Add the **Scenario Simulation Foundation** as a new reusable core
  package `lib/features/astrology/thai/core/simulation/`.
  `ScenarioSimulationEngine.simulate(...)` evaluates four paths per scenario —
  **Act now**, **Act at the best window**, **Act at an alternative (worst)
  window** and **Do nothing** — by re-querying the V13 runtime
  (`ThaiReasoningRuntime.decide`) at the relevant hypothetical `asOf`. It reads
  each runtime recommendation's outcome/windows/tradeoffs/evidence and produces a
  `SimulationResult`: per-option expected outcome, potential opportunity,
  potential risk, tradeoffs, timing, confidence and supporting evidence, plus a
  ranked `SimulationComparison` (best/worst + value-of-acting vs Do Nothing). Do
  Nothing is a neutral baseline whose risk is the opportunity cost of inaction.
- **Reason:** Treat options as *timing paths* evaluated through the runtime so
  the simulation is genuinely "evaluate the hypothetical via the existing
  runtime," stays deterministic, preserves evidence provenance (atoms are the
  runtime's `ReasoningEvidence`, unchanged), and keeps the copy boundary intact
  (no Thai prose, presenter, parser, UI, Firestore or AI).
- **Alternatives considered:** Defining options as different sub-scenarios;
  computing window outcomes from cached decision windows without re-querying;
  calling the decision/prediction engines directly.
- **Tradeoffs:** A few extra runtime evaluations per simulation vs. a faithful,
  fully traceable "what-if at time T" model with zero engine risk.
- **Impact:** **No runtime-behaviour, UI, Firestore or routing changes** —
  additive engine + tests + docs only. The runtime and the four engines beneath
  it are untouched. Determinism, scenario-consistency, comparison-stability and
  evidence-traceability (incl. runtime-only consumption) tests pass.
- **Related documents:** `THAI_SCENARIO_SIMULATION_V14.md`,
  `THAI_REASONING_RUNTIME_V13.md`, `THAI_DECISION_INTELLIGENCE_V11.md`,
  `EXECUTIVE_SUMMARY.md`, `ROADMAP.md`, `CURRENT_STATUS.md`, `DOMAIN_MODEL.md`,
  `PROJECT_INDEX.md`, `PROJECT_FREEZE.md`.
- **Related implementation:** `lib/features/astrology/thai/core/simulation/`,
  `test/validation/thai_mirror_v14_simulation/`.

## D-026 — Thai Transit Intelligence Integration V15

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The platform reasons on the age/life-period axis. Adding *transit*
  risked spawning a parallel astrology stack. The requirement was to integrate
  transit as an **enhancement layer** that contributes evidence only, with
  reasoning staying inside the V13 runtime and the runtime itself unmodified.
- **Decision:** Add the **Transit Intelligence Integration** as a new core
  package `lib/features/astrology/thai/core/transit/`. The transiting planet is
  the Thai **day-of-week ruler** of the evaluation date (the calendar signal the
  age/period pipeline does not capture), assessed against the natal ruler and the
  current life-period planet via the **shared V9 `PlanetRelationshipEngine`**
  (reused, no duplicate scoring). `TransitIntelligenceEngine` converts this into
  a `TransitAssessment` (events, influences, impact, evidence). An
  `EnhancedReasoningRuntime` **wraps** the frozen `ThaiReasoningRuntime`: it runs
  the runtime unchanged, builds the `TransitContext` **from the runtime response**
  (never bypassing it), and merges transit evidence into a single
  `EnhancedReasoningResponse` pool. Transit never decides, predicts or answers,
  and never alters confidence or a base snapshot.
- **Reason:** Keep one reasoning entry point, avoid a parallel transit
  architecture, preserve determinism and evidence provenance, reuse existing
  relationship logic, and keep the copy boundary (no Thai prose, presenter, UI,
  Firestore or AI).
- **Alternatives considered:** A standalone transit reasoning stack; modifying
  the runtime to inject transit internally (rejected — runtime is frozen);
  extending the `ReasoningLayer` enum (rejected — would modify the runtime).
- **Tradeoffs:** A thin wrapper + a normalised merged-evidence shape (transit
  atoms carry a literal `transit` layer) vs. touching the frozen runtime.
- **Impact:** **No runtime-behaviour, UI, Firestore or routing changes** —
  additive engine + wrapper + tests + docs only. The runtime, simulation and the
  four engines are untouched. Determinism, transit-stability, evidence-merge and
  runtime-compatibility tests pass.
- **Related documents:** `THAI_TRANSIT_INTEGRATION_V15.md`,
  `THAI_REASONING_RUNTIME_V13.md`, `THAI_SCENARIO_SIMULATION_V14.md`,
  `EXECUTIVE_SUMMARY.md`, `ROADMAP.md`, `CURRENT_STATUS.md`, `DOMAIN_MODEL.md`,
  `PROJECT_INDEX.md`, `PROJECT_FREEZE.md`.
- **Related implementation:** `lib/features/astrology/thai/core/transit/`,
  `test/validation/thai_mirror_v15_transit/`.

## D-027 — Mirror Conversation Experience Foundation V16

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The reasoning platform (V9–V15) is complete but only reachable as
  structured engine/runtime calls. The product needs a *conversational* surface
  without introducing an AI/LLM/parser, and without modifying any frozen engine,
  the runtime, simulation or transit.
- **Decision:** Add the **Mirror Conversation Experience Foundation** as a new
  package `lib/features/astrology/thai/conversation/` (an experience layer, **not**
  under `core/`). The conversation is a **deterministic guided graph**: a fixed
  `ConversationCatalog` of predefined, selectable `ConversationQuestion`s, each
  mapping to a single `ThaiReasoningRuntime` call (`evaluate`/`predict`/`decide`/
  `question`) plus a curated set of follow-up ids. `ConversationFlow` (`openTopic`
  + `ask`) is the only driver: it consumes the **runtime only**, wraps the runtime
  output in a structured `ConversationAnswer`, records it in `ConversationMemory`,
  and emits `ConversationSuggestion`s (curated follow-ups, then unasked siblings,
  capped at three). Eight `ConversationTopic`s (Current Life, Career, Money,
  Relationship, Family, Health, Growth, Future) anchor the catalog.
- **Reason:** Deliver a conversational experience with zero AI/LLM/parser, full
  determinism and reproducibility, a single reasoning entry point (the runtime),
  and the freeze intact. There is no free text — the user only ever picks from the
  predefined catalog.
- **Alternatives considered:** A chat model / LLM front-end (rejected — explicitly
  out of scope); a natural-language parser mapping typed text to intents (rejected
  — non-deterministic, out of scope); calling the decision/question engines
  directly (rejected — must consume the runtime only).
- **Tradeoffs:** Question/suggestion *labels* are English structural strings in
  the foundation (a later presenter localises them to Thai consumer copy), keeping
  the engine copy boundary intact while still giving the foundation a usable shape.
- **Impact:** **No runtime-behaviour, UI, Firestore or routing changes** —
  additive experience foundation + tests + docs only. The runtime, simulation,
  transit and the four engines are untouched. Catalog-integrity, guided-flow
  (example reproduction), runtime-only-consistency, suggestion-logic and
  determinism tests pass. No deploy (foundation only).
- **Related documents:** `THAI_MIRROR_CONVERSATION_V16.md`,
  `THAI_REASONING_RUNTIME_V13.md`, `THAI_QUESTION_REASONING_FOUNDATION_V12.md`,
  `EXECUTIVE_SUMMARY.md`, `ROADMAP.md`, `CURRENT_STATUS.md`, `DOMAIN_MODEL.md`,
  `PROJECT_INDEX.md`, `PROJECT_FREEZE.md`.
- **Related implementation:** `lib/features/astrology/thai/conversation/`,
  `test/validation/thai_mirror_v16_conversation/`.

## D-028 — Global Reasoning Runtime Foundation V17

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The Thai Reasoning Runtime (V13) had proven itself as a clean,
  deterministic orchestration entry point. Other systems (Western, BaZi, MBTI,
  Big Five, EQ, Compatibility) will need the same shape, but we must not merge
  implementations, rewrite Thai, or bind a cross-system runtime to Thai.
- **Decision:** Promote the Thai runtime to the **reference implementation** and
  add a system-agnostic **Global Reasoning Runtime** as a new package
  `lib/features/runtime/`. It defines `ReasoningProvider`, `ReasoningRuntime`,
  `ReasoningModule`, `ReasoningCapability`, `ReasoningRequest`,
  `ReasoningResponse`, `ReasoningEvidence`, `ReasoningTrace`. The runtime
  dispatches a request to the provider that owns the requested `ReasoningModule`,
  detects capabilities, and aggregates module-tagged evidence. Providers are
  **discovered** via `ReasoningProviderRegistry` — the runtime imports no concrete
  system. The **only** implementation is `ThaiRuntimeAdapter`, which wraps the
  frozen `ThaiReasoningRuntime`, builds a Thai request from the generic request's
  common fields + `parameters`, and maps the Thai response into a
  `ReasoningResponse` (native response preserved in `raw`). The V16 Mirror
  Conversation now consumes the **`ReasoningRuntime`** (Thai provider only) instead
  of `ThaiReasoningRuntime` directly.
- **Reason:** One cross-system entry point, no parallel runtimes, no hard-coded
  Thai dependency, Thai untouched, and a clean extension path (new system = new
  provider + registration, zero runtime change).
- **Alternatives considered:** Merging all systems into one runtime (rejected —
  couples unrelated systems, rewrites Thai); making the generic runtime import
  Thai directly (rejected — hard-coded dependency); generics/type-parameterised
  requests per system (rejected for the foundation — a `parameters` map + opaque
  `raw` keeps the core system-agnostic).
- **Tradeoffs:** System-specific inputs travel in an untyped `parameters` map and
  rich outputs via an opaque `raw` (each provider/consumer casts what it knows) —
  in exchange for a runtime core with no system imports.
- **Impact:** **No runtime-behaviour, UI, Firestore or routing changes** —
  additive architecture + adapter + tests + docs only. Thai (V9–V16), simulation
  and transit are untouched; the V16 conversation was rewired to the global
  runtime with behaviour preserved. Provider-registration, runtime-dispatch,
  capability-detection and evidence-aggregation tests pass; the V16 suite still
  passes. No deploy (architecture only).
- **Related documents:** `GLOBAL_REASONING_RUNTIME_V17.md`,
  `THAI_REASONING_RUNTIME_V13.md`, `THAI_MIRROR_CONVERSATION_V16.md`,
  `ARCHITECTURE.md`, `ROADMAP.md`, `EXECUTIVE_SUMMARY.md`, `PROJECT_FREEZE.md`,
  `PROJECT_INDEX.md`.
- **Related implementation:** `lib/features/runtime/`,
  `test/validation/global_runtime_v17/`.

## D-029 — Cross-System Fusion Runtime P2

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The Global Runtime (V17) dispatches one request to one provider.
  The platform needs to **combine** multiple systems (Thai, Western, BaZi, MBTI,
  EQ, Big Five, Compatibility) into a single reasoning result — but only Thai
  exists today, so the layer must also work with one provider.
- **Decision:** Add the **Fusion Runtime** as a new package
  `lib/features/runtime/fusion/`. It sits **above** the Global Runtime (composes,
  does not replace it). `FusionRuntime.fuse(FusionContext)` fans a capability out
  across every supporting provider via `ReasoningRuntime.run`, collects each as a
  `FusionObservation`, then detects **agreement**, **conflict**, **missing
  evidence** and **priority** on a shared `domain` axis, merges per-domain
  evidence (`FusionEvidence`), computes a fused `FusionConfidence` (provider
  average ± agreement/conflict adjustments, banded by `FusionRule`), and returns
  one `FusionResult`. With one provider it sets `singleProviderMode` and passes
  confidence through unchanged. The Mirror Conversation (V16) now consumes the
  **`FusionRuntime`** instead of the Global Runtime.
- **Reason:** A single unified reasoning surface above the runtime, ready for
  multi-system fusion, that already works with one provider and keeps all
  arithmetic deterministic and tunable (via `FusionRule`).
- **Alternatives considered:** Putting fusion inside the Global Runtime (rejected —
  V17 dispatch is one-provider-per-module and frozen); fusing on raw layer
  evidence rather than the cross-system `domain` axis (rejected — `domain` is the
  only semantic axis shared across systems); special-casing single-provider mode
  in consumers (rejected — fusion returns the same shape for 1..N providers).
- **Tradeoffs:** Fusion compares on `domain` net magnitudes (a coarse but
  cross-system-stable signal); richer per-source fusion is deferred. System inputs
  still travel via the untyped `parameters` map.
- **Impact:** **No runtime-behaviour, UI, Firestore or routing changes** —
  additive fusion layer + tests + docs only. The Global Runtime, the Thai stack,
  simulation and transit are untouched; the V16 conversation was rewired to fusion
  with behaviour preserved. Agreement, conflict, single-provider, priority and
  evidence-merge tests pass; the V16 and V17 suites still pass. No deploy.
- **Related documents:** `GLOBAL_FUSION_RUNTIME_P2.md`,
  `GLOBAL_REASONING_RUNTIME_V17.md`, `THAI_MIRROR_CONVERSATION_V16.md`,
  `ARCHITECTURE.md`, `ROADMAP.md`, `EXECUTIVE_SUMMARY.md`.
- **Related implementation:** `lib/features/runtime/fusion/`,
  `test/validation/fusion_runtime_p2/`.

## D-030 — Global Mirror Experience P3

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The Runtime Platform is complete (Timeline → … → Fusion Runtime)
  but had **no product surface**. The platform needed its first real, human
  experience — a UX milestone, not another engine.
- **Decision:** Add the **Global Mirror Experience** as a new feature
  `lib/features/mirror_experience/`. It consumes the **`FusionRuntime` only**
  (never a provider, never a system runtime). `MirrorExperienceService` turns a
  `FusionResult` into plain-language view models from the cross-system fields
  (`priorities`, `mergedEvidence`, `confidence`) — so it touches no Thai types.
  `MirrorJourney` guides the user through Home → Current Life → Prediction →
  Decision → Ask More → Conversation → Reflection. The conversation **starts from
  cards** (driving the V16 flow over fusion), never an empty chat. Copy is
  governed by one rule — **explain life, not astrology** — with all numbers behind
  an expandable "evidence" section.
- **Reason:** Ship the platform's first production experience while keeping the
  reasoning boundary intact: a presentation layer that depends only on the fused,
  system-agnostic result and would render future providers unchanged.
- **Alternatives considered:** Reading the Thai `raw` payload for richer stance
  copy (rejected — couples the experience to a provider and to astrology
  semantics); rewiring HomePage to host the experience (rejected — the production
  AuthGate → ProfileGate → HomePage flow stays untouched; the experience is an
  additive `/mirror-experience` route + a standalone preview entrypoint).
- **Tradeoffs:** Decision/answer framing uses the fused direction + clarity (a
  coarse but cross-system-stable signal) rather than the Thai stance enum; richer
  per-provider phrasing is deferred to a future presenter.
- **Impact:** **No engine, runtime, provider or fusion changes** — additive
  feature + tests + docs, plus one additive route hook in `main.dart`. The frozen
  reasoning stack and the production boot flow are untouched. Service (fusion-only,
  deterministic, astrology-free copy) and widget-walkthrough tests pass; V16/V17/P2
  suites still pass. **Deploy: yes — first platform-level production release.**
- **Related documents:** `GLOBAL_MIRROR_EXPERIENCE_P3.md`,
  `GLOBAL_FUSION_RUNTIME_P2.md`, `THAI_MIRROR_CONVERSATION_V16.md`,
  `ARCHITECTURE.md`, `ROADMAP.md`, `EXECUTIVE_SUMMARY.md`.
- **Related implementation:** `lib/features/mirror_experience/`,
  `test/validation/mirror_experience_p3/`.

## D-031 — Product Validation Phase A

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The platform and its first product surface (P3) shipped, but there
  was **no measurement** of whether users actually experience WOW or where they
  stall. Phase A needs to measure that without building engines/providers/AI or
  redesigning the UI.
- **Decision:** Add a measurement-only feature `lib/features/product_validation/`.
  A `ProductValidationTracker` (with `Noop` + in-memory `Recorder`
  implementations) records typed `ProductEvent`s at the experience's measurable
  moments; a pure, deterministic `ProductInsightsEngine` turns sessions into
  `ProductMetrics`, a `ProductFunnel` (Home → Current Life → Prediction →
  Decision → Conversation → Reflection) and `ProductInsights` grouped as WOW /
  curiosity / engagement / drop-off. An **internal-only** dashboard
  (`/internal/product-validation`, not linked from any user surface) renders them.
  The P3 widgets are instrumented with **additive** `ProductValidation.tracker`
  calls only.
- **Reason:** Answer "do users WOW, and where do they stop?" with a deterministic,
  testable instrumentation layer that observes the experience without changing it.
- **Alternatives considered:** Adding `firebase_analytics`/`shared_preferences`
  (rejected for now — new deps; kept dependency-free with a pluggable sink seam);
  writing events to Firestore (rejected — backend schema change, against the
  no-runtime-change constraint); building the dashboard into the user flow
  (rejected — measurement must be internal-only).
- **Tradeoffs:** Events are in-memory for the running app (read by the internal
  dashboard in-session); cross-device/persistent aggregation and per-provider
  breakdowns are deferred behind the tracker seam. "Return visit" is detected at
  the session level within a process until a persistent sink is added.
- **Impact:** **No engine, runtime, provider, fusion or user-flow changes** —
  additive feature + additive `track*` calls in P3 widgets + one additive
  internal route hook in `main.dart`. Recorder/engine/funnel/insight determinism
  and dashboard-smoke tests pass; the P3 walkthrough still passes. **Deploy: yes**
  (ships with the platform release; measurement can be disabled via
  `ProductValidation.recorder.enabled`).
- **Related documents:** `PRODUCT_VALIDATION.md`,
  `GLOBAL_MIRROR_EXPERIENCE_P3.md`, `ARCHITECTURE.md`, `ROADMAP.md`,
  `EXECUTIVE_SUMMARY.md`.
- **Related implementation:** `lib/features/product_validation/`,
  `test/validation/product_validation_phase_a/`.

## D-032 — Home V4 (Mirror Experience as the emotional entry)

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The Mirror Experience (P3) shipped behind a hidden route
  (`/mirror-experience`). Production Home (V3: `HomePage` → `HomeScreenV3`) still
  led with the legacy `HomeHeroSection`. Phase B needs to make the Mirror
  Experience the default emotional entry of Home **without redesigning the
  Runtime or the Mirror Experience**, reusing the existing Mirror widgets and
  keeping Phase A telemetry working.
- **Decision:** Add an **embeddable** `MirrorHomeSection`
  (`lib/features/mirror_experience/ui/`) that reuses the exact P3 cards
  (`MirrorInsightCard`, `MirrorPredictionCard`, `MirrorDecisionCard`,
  `MirrorConversationEntry`, `MirrorReflection`) and reveals them inline
  (Current Life → Prediction → Decision → Conversation → Reflection) inside the
  Home scroll. `HomeScreenV3` takes an optional `mirrorBirthDate`: when present,
  the section **replaces** `HomeHeroSection` as the emotional entry; when absent
  (incomplete profile), the legacy hero / unlock onboarding is preserved.
  `HomePage` derives the date from its already-loaded source bundle
  (`profileFields['birthDate']`) — no new loader, no new Firestore read.
- **Reason:** Make Mirror first-class on Home with the smallest possible change:
  one new container widget + two optional wiring points. No widget UI is
  duplicated; the full-page `MirrorJourney`/`MirrorHome` and the
  `/mirror-experience` route stay intact.
- **Alternatives considered:** Pushing the full-page `MirrorJourney` from Home
  (rejected — keeps Mirror "hidden" behind a Begin gate, not on Home);
  refactoring `MirrorJourney` to render inline (rejected — would redesign the
  frozen P3 experience and risk its tests); rebuilding Home from scratch as a
  new page (rejected — large refactor, against minimal-safe-change rule).
- **Tradeoffs:** `MirrorHomeSection` re-implements the small stage/telemetry
  orchestration of `MirrorJourney` (the cards themselves are reused), so the two
  share intent but not the container. Reveal is in-place (cards accumulate on
  the Home scroll) rather than paged.
- **Impact:** **No engine, runtime, provider, fusion or Mirror-widget changes.**
  Additive: one new widget, an optional `mirrorBirthDate` param on
  `HomeScreenV3`, and a birth-date helper on `HomePage`. Telemetry continues
  (session/home/journey + per-stage events fire from the section). Home V4,
  Mirror P3, Phase A, and `HomeScreenV3` tests all pass. **Deploy: yes.**
- **Related documents:** `HOME_V4.md`, `GLOBAL_MIRROR_EXPERIENCE_P3.md`,
  `PRODUCT_VALIDATION.md`, `ARCHITECTURE.md`, `ROADMAP.md`.
- **Related implementation:**
  `lib/features/mirror_experience/ui/mirror_home_section.dart` (Phase B;
  superseded by the Daily Mirror in D-033),
  `lib/features/home_cohesion/presentation/home_screen_v3.dart`,
  `lib/presentation/pages/home/home_page.dart`,
  `test/validation/home_v4/`.

## D-033 — Daily Mirror (Home becomes "Today")

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** Home V4 (D-032) placed the Mirror Experience on Home as a staged
  walkthrough (`MirrorHomeSection`: Current Life → Prediction → Decision →
  Conversation → Reflection). Phase C wants Home to feel like a **daily life
  read**, not a tour of engine stages: a "Today" surface with three key messages
  (opportunity, caution, focus), one suggested action and one conversation
  entry — with Prediction / Decision / Timeline hidden as concepts. No new
  Runtime, Provider or AI.
- **Decision:** Add a `MirrorDaily` view model + a `MirrorExperienceService.daily()`
  composer that reuses the existing current-life / forward / decision fusion
  reads and reframes them as life guidance (no new capability, no new reasoning).
  A new `DailyMirrorSection` (`lib/features/mirror_experience/ui/`) is the Home
  emotional entry: today's date + clarity, the three labelled messages, one
  suggested step, an expandable "what this is based on" (reusing `MirrorWhyTile`),
  one conversation entry (reusing `MirrorConversationEntry`), and a **secondary**
  link into the full guided `MirrorHome` journey. `HomeScreenV3` now renders
  `DailyMirrorSection` in place of `MirrorHomeSection` when a birth date is
  present; the legacy hero is still the fallback. `MirrorHomeSection` (Phase B)
  is removed as dead code.
- **Reason:** Deliver "experience life guidance, not engine outputs" with the
  smallest change: a composer over existing reads + one new section widget, and
  a one-line swap on Home.
- **Alternatives considered:** Keeping the staged `MirrorHomeSection` and just
  relabelling (rejected — still a stage tour, not a daily read); a new
  reasoning/daily-forecast engine (rejected — violates no-new-runtime/AI);
  computing the daily read in the widget (rejected — keep it deterministic and
  testable in the service).
- **Tradeoffs:** The Daily Mirror surfaces today's read all at once rather than
  as a funnel of stages; internally the section still fires the stage telemetry
  (`insightViewed`/`predictionViewed`/`decisionViewed`) so the Phase A funnel
  stays coherent, plus four new Daily Mirror signals.
- **Telemetry:** new `dailyMirrorOpened`, `dailyActionClicked`,
  `dailyConversationStarted`; evidence expand reuses `evidenceExpanded`. Phase A
  recorder/engine/dashboard are unchanged (additive events only).
- **Impact:** **No engine, runtime, provider, fusion or capability changes.**
  Additive view model + service method + copy + one new widget + a one-line Home
  swap + three additive telemetry events. Phase C, Home V4, Mirror P3, Phase A,
  and `HomeScreenV3` tests all pass. **Deploy: yes.**
- **Related documents:** `DAILY_MIRROR_PHASE_C.md`, `HOME_V4.md`,
  `GLOBAL_MIRROR_EXPERIENCE_P3.md`, `PRODUCT_VALIDATION.md`, `ARCHITECTURE.md`,
  `ROADMAP.md`.
- **Related implementation:**
  `lib/features/mirror_experience/ui/daily_mirror_section.dart`,
  `lib/features/mirror_experience/mirror_experience_service.dart` (`daily()`),
  `lib/features/home_cohesion/presentation/home_screen_v3.dart`,
  `test/validation/daily_mirror_phase_c/`.

## D-034 — Daily Habit Loop

- **Date:** 2026-06 · **Status:** Accepted
- **Context:** The Daily Mirror (D-033) gives a daily read but nothing makes it a
  **habit**: no streak, no history, no sense of return. Phase D wants Mirror
  Streak, Mirror History, Yesterday-vs-Today, Weekly/Monthly Reflection and a
  Life Trend, and to measure 7-/30-day retention, average sessions, streak and
  reflection rate — **without new reasoning, AI or astrology**.
- **Decision:** Add a self-contained `lib/features/mirror_habit/` package:
  deterministic domain (`MirrorDayRecord` + streak/comparison/period/trend/
  metrics value objects), a pure `MirrorHabitEngine` (+ `MirrorHabitSnapshot`),
  and a `MirrorHabitStore` seam with a per-user `FirestoreMirrorHabitStore`
  (`users/{uid}/mirror_daily/{dateKey}`, established conventions, lazy + guarded,
  null-uid no-op) and an `InMemoryMirrorHabitStore`. The Daily Mirror records the
  loop (open → action → **reflect**) and renders a `MirrorHabitSection` (streak,
  last-7 strip, Yesterday-vs-Today, one-tap reflection, weekly/monthly, life
  trend, return-tomorrow nudge). The internal dashboard gains an async
  Daily-Habit metrics panel. One new telemetry event, `dailyReflectionSaved`.
- **Reason:** Close the daily loop with a deterministic, testable habit layer
  over the day records — the Daily Mirror only gains a store + a section; the
  read itself is unchanged.
- **Alternatives considered:** `shared_preferences`/localStorage (rejected — new
  dep, single-device, no cross-device retention; `cloud_firestore` already
  present and per-user); a streak/forecast "engine" with predictive logic
  (rejected — that would be new reasoning); storing the read text (rejected —
  only tones/area-keys/clarity are persisted, never astrology data).
- **Tradeoffs:** Persistence is best-effort and degrades to in-session-only when
  Firebase is unavailable or a write is denied (the loop UI still works from the
  locally-merged today record). Retention here is **per-user** (history old
  enough + active in window), not a population cohort metric.
- **Firestore:** new owner-scoped subcollection `users/{uid}/mirror_daily`,
  covered by the same recursive owner rule the app already relies on for
  `profile` / `tests` / `funnel_telemetry`; rules are not in-repo (console-managed)
  and a denied write simply no-ops.
- **Impact:** **No reasoning/runtime/provider/fusion/AI changes, no astrology.**
  Additive package + a store hook + a section in `DailyMirrorSection` + one
  dashboard panel + one telemetry event. Phase D, C, Home V4, P3, Phase A and
  `HomeScreenV3` tests all pass. **Deploy: yes.**
- **Related documents:** `DAILY_HABIT_PHASE_D.md`, `DAILY_MIRROR_PHASE_C.md`,
  `PRODUCT_VALIDATION.md`, `ARCHITECTURE.md`, `ROADMAP.md`.
- **Related implementation:** `lib/features/mirror_habit/`,
  `lib/features/mirror_experience/ui/daily_mirror_section.dart`,
  `lib/features/product_validation/ui/product_validation_dashboard.dart`,
  `test/validation/daily_habit_phase_d/`.

## D-035 — Birth Normalization Foundation

- **Date:** 2026-06 · **Status:** Accepted · Architecture only (no deploy)
- **Context:** Each astrology system needs birth data resolved consistently
  (location, timezone, calendar) and Thai specifically needs the astrological day
  to start at **local sunrise**, not the legacy hardcoded 06:00 (`ThaiDayBoundary`,
  frozen V1.1). Birth resolution was scattered (e.g. `UserProfileBirthLoader`
  builds `ThaiBirthData` and the engine re-applies 06:00).
- **Decision:** Add `lib/features/birth_normalization/` as the **single
  birth-input layer** before every engine. `RawBirthInput` → `BirthNormalizer`
  (pure/deterministic) → `NormalizedBirth` bundling resolved `BirthLocation` /
  `BirthTimeZone` / `BirthCalendar`, a computed local sunrise, and one context per
  system: `ThaiBirthContext` (sunrise-based `thaiAstrologicalDate`),
  `WesternBirthContext` (exact instant, no shift), `BaZiBirthContext`
  (placeholder). A self-contained `SunriseCalculator` (Almanac algorithm, zenith
  90.833°) makes the Thai boundary **location-, season- and timezone-aware** — no
  hardcoded 06:00. Every choice is recorded in `BirthNormalizationReason`.
- **Reason:** One deterministic, traceable place to turn raw input into per-system
  birth data; correct Thai day boundary; stable contract for future Western/BaZi.
- **Scope boundary (stability > architecture purity):** This milestone ships the
  **layer + contract + tests + docs only**. The frozen Thai/foundation engines are
  **not rewired** here; migrating them to consume `NormalizedBirth` (and read
  `thaiAstrologicalDate` instead of `ThaiDayBoundary`) is documented follow-up.
  The stated rule ("no engine consumes `RawBirthInput`") is the target end-state.
- **Alternatives considered:** adding a tz-database (`timezone`) and an astronomy/
  ephemeris package (rejected — new deps; fixed offsets are correct for the
  no-DST supported region and the Almanac sunrise is accurate enough and
  dependency-free); rewiring the frozen engine now (rejected — violates freeze /
  stability for an architecture-only milestone).
- **Impact:** Additive new package only. No engine/runtime/UI/Firestore changes,
  no deploy. 15 tests pass (sunrise location/season/timezone awareness, Thai
  day boundary, Western/BaZi, resolution, determinism).
- **Related documents:** `BIRTH_NORMALIZATION.md`, `ARCHITECTURE.md`,
  `DOMAIN_MODEL.md`, `ROADMAP.md`, `THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`.
- **Related implementation:** `lib/features/birth_normalization/`,
  `test/validation/birth_normalization/`.

---

## D-036 — Thai pipeline consumes Birth Normalization

- **Date:** 2026-06 · **Status:** Accepted · Migration only (no deploy) · Completes the D-035 follow-up
- **Context:** D-035 shipped the Birth Normalization layer but left the frozen Thai
  pipeline still parsing raw `birthDate`/`birthTime` (in two places —
  `UserProfileBirthLoader` and `FirestoreAstrologyFusionLensProbe`) and each
  duplicating its own timezone logic. The sunrise day boundary
  (`ThaiBirthContext.astrologicalDate`) was unused.
- **Decision:** Make `ThaiBirthData` the adapter target of `ThaiBirthContext`:
  add `ThaiBirthData.fromThaiContext` (+ an `astrologicalDate` field) and a single
  seam `ThaiBirthContextAdapter.fromProfileMap` that runs
  `BirthNormalizer.normalizeProfileMap`. Both production loaders route through it;
  their duplicated `_offsetForTimezone`/`_timeZoneOffset` is deleted. `ThaiDayBoundary`
  becomes a deprecated shim that delegates to `SunriseCalculator` (no hardcoded
  06:00) and points callers at `astrologicalDate`.
- **Scope boundary:** The frozen sub-engines are **not** rewritten. `localDateTime`
  still carries the exact civil instant (lagna astronomy + the exact-datetime
  verified-lunar lookup must not shift a day); `astrologicalDate` carries the
  sunrise boundary. The verified lunar dataset is keyed on the exact civil datetime
  with the boundary-adjusted weekday baked into the data, so that lookup is left
  unchanged — golden cases GC-04/GC-05 still pass. Prediction/Timeline/Decision/
  Runtime/Mirror/Conversation are untouched.
- **Reason:** Birth Normalization is now the **single source of truth** for
  timezone, coordinates and the sunrise day boundary; no parsing or timezone logic
  is duplicated in the Thai pipeline.
- **Behaviour:** Preserved for the Asia/Bangkok user base. One intentional
  correctness fix: non-Bangkok timezones now resolve to their real offset instead
  of the fusion probe's previous UTC/ICT default.
- **Impact:** No feature change, no deploy. All existing Thai engine tests pass;
  added `thai_birth_normalization_migration_test.dart` (before/after sunrise,
  regression). The full suite's 22 pre-existing failures (golden screenshots,
  app-boot, narrative-coverage audits, env-gated repair export) are unrelated and
  unchanged (verified against baseline).
- **Related documents:** `BIRTH_NORMALIZATION.md`, `ARCHITECTURE.md`,
  `THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`.
- **Related implementation:**
  `lib/features/astrology/thai/foundation/integration/thai_birth_context_adapter.dart`,
  `lib/features/astrology/thai/foundation/models/thai_birth_data.dart`,
  `lib/features/astrology/thai/foundation/calendar/thai_day_boundary.dart`,
  `lib/features/narrative_runtime/integration/user_profile_birth_loader.dart`,
  `lib/features/astrology/fusion/application/astrology_fusion_lens_probe.dart`.

---

## D-037 — Birth architecture cleanup

- **Date:** 2026-06 · **Status:** Accepted · Architecture cleanup only (no runtime/UI/deploy) · Refines D-036
- **Context:** After D-036 the Thai→engine conversion existed in **two** places, both
  on the Thai side: `ThaiBirthData.fromThaiContext` (a converter on the engine
  model) and `ThaiBirthContextAdapter` (a separate adapter in
  `thai/foundation/integration/`). This duplicated converter logic and gave the
  engine model knowledge of Birth Normalization.
- **Decision:** Establish a single ownership boundary:
  - **Birth Normalization owns all adapters.** One bridge, `ThaiEngineAdapter`
    (`birth_normalization/application/adapters/thai_engine_adapter.dart`), maps
    `ThaiBirthContext` / `NormalizedBirth` / profile → `ThaiBirthData`
    (`fromContext` / `fromNormalized` / `fromProfileMap`).
  - **Thai owns only engine models.** `ThaiBirthData` is now a pure data class —
    `fromThaiContext` removed, no import of Birth Normalization. The
    `ThaiBirthContextAdapter` file is deleted.
  - Both loaders (`UserProfileBirthLoader`, `FirestoreAstrologyFusionLensProbe`)
    call `ThaiEngineAdapter`.
- **Dependency direction:** The `adapters/` ring is the designated bridge and is
  the one place allowed to import an engine model (`ThaiBirthData`). The generic
  normalization barrel does **not** export it, so the core normalization layer
  stays engine-agnostic; the deprecated `ThaiDayBoundary` still consumes only
  `SunriseCalculator`. No import cycle.
- **Reason:** One adapter, one converter, one source of truth; clear ownership.
- **Impact:** No runtime/feature/UI change, no deploy. Pure rename/move + delete.
  All Thai + normalization tests pass (the migration test was updated for the new
  symbol names).
- **Related documents:** `BIRTH_NORMALIZATION.md`, `ARCHITECTURE.md`.
- **Related implementation:**
  `lib/features/birth_normalization/application/adapters/thai_engine_adapter.dart`,
  `lib/features/astrology/thai/foundation/models/thai_birth_data.dart` (pure model),
  `lib/features/narrative_runtime/integration/user_profile_birth_loader.dart`,
  `lib/features/astrology/fusion/application/astrology_fusion_lens_probe.dart`.

---

## D-038 — Thai Astrology Research (production validation + hardening)

- **Date:** 2026-06 · **Status:** Accepted · Product-validation milestone (deployed to production)
- **Context:** A standalone, public Thai Astrology experience was launched at
  `/beta/thai` to collect real-world validation feedback, reusing the completed
  Birth Normalization pipeline and the production Thai Engine (no new astrology
  pipeline, no runtime/reasoning change). Hardening then prepared it for external
  users.
- **Decision (pipeline):** `ThaiBetaInput → RawBirthInput → BirthNormalizer →
  ThaiEngineAdapter → ThaiMirrorPipeline → existing ThaiMirrorResultPage`. The
  feature lives in `lib/features/thai_beta/` and never bypasses the normalization
  seam. Submissions persist to the `thai_beta_feedback` collection.
- **Decision (security):**
  - **Rules in-repo.** `firestore.rules` + `firestore.indexes.json` are now
    version-controlled and registered in `firebase.json` (deploy with
    `firebase deploy --only firestore:rules`). No console-only configuration.
    Model: existing data stays owner-only under `users/{uid}/**`;
    `thai_beta_feedback` allows public **create** (validated) but **admin-only
    read**; a bounded `counters/{id}` (+1-only) backs research ids; default deny.
  - **Admin gate.** `/internal/thai-beta` is wrapped by `ThaiResearchAdminGuard`,
    which reuses FirebaseAuth and an explicit `admins/{uid}` allow-list (the same
    source of truth the rules enforce). It **fails closed** — signed-out users see
    login, non-admins get access-denied, only allow-listed admins see the
    dashboard / detail / statistics. (No admin-role system existed previously; this
    introduces the minimal, rules-enforceable one.)
- **Decision (data quality):**
  - **No silent save failures.** `ThaiBetaStore.save` returns a
    `ThaiBetaSaveResult`; the UI shows Success (with Reference ID) → Thank you, or
    Error → “please try again”.
  - **Sequential `researchId`** (`TH-00000001`) allocated atomically with the
    write via a Firestore transaction on `counters/thai_research`; shown to the user
    as a Reference ID and stored.
  - **Provenance:** stores `startedAt`, `submittedAt`, `durationSeconds`, and a
    deterministic SHA-256 `reportHash` of the report snapshot (order-independent
    canonical JSON) as a tamper-evident fingerprint of exactly what the user saw.
  - **Feedback** gains “Why would you recommend this system to a friend?”.
- **Rename:** all user-facing copy uses **Thai Astrology Research** (no “Beta”).
  Routes (`/beta/thai`, `/internal/thai-beta`) and the `thai_beta_feedback`
  collection are intentionally unchanged to avoid breaking deployed links / orphaning
  data (stability > purity); internal Dart identifiers keep the `ThaiBeta*` prefix.
- **Impact:** Deployed to production (hosting + Firestore rules). New tests cover
  research-id formatting, duration clamping, hash determinism, save-failure
  surfacing, and the admin guard's three states. Provisioning note: an admin must be
  added out-of-band by creating `admins/{uid}` (CLI/console) — `write: if false`
  blocks client writes by design.
- **Related documents:** `PRODUCT_VALIDATION.md`, `ARCHITECTURE.md`, `ROADMAP.md`.
- **Related implementation:** `lib/features/thai_beta/**`, `firestore.rules`,
  `firestore.indexes.json`, `firebase.json`,
  `lib/core/web/web_launch_router.dart`, `lib/main.dart`.

---

## D-039 — Thai Astrology Research UX improvements V1

- **Date:** 2026-06 · **Status:** Accepted · UX only (deployed) · Builds on D-038
- **Context:** Before inviting real external users, the Research experience needed
  clearer usability and transparency. Engine and Birth Normalization are **not**
  touched.
- **Decision:**
  - **No navigation controls.** Every step in the flow sets
    `automaticallyImplyLeading: false` (the report page has no app bar) — it is a
    standalone research experience.
  - **True 24-hour birth-time picker** (`showThaiBeta24HourTimePicker`), replacing
    the AM/PM `showTimePicker`; a `00:00–23:59` wheel, never AM/PM (users misread
    12 AM / 12 PM around midnight).
  - **Research summary before the report** (`ThaiBetaSummaryPage`): an
    “ข้อมูลที่ใช้วิเคราะห์” card (name, birth date/time, province, gender, sunrise,
    Thai astrological date, timezone; Thai Buddhist-era dates) + a transparency
    banner explaining the sunrise day-boundary shift (or “ใช้วันเกิดตามปฏิทิน”) +
    the collapsible technical panel (lat/lng/coordinates/timezone/sunrise/hash/
    research id). The shared production `ThaiMirrorResultPage` is left **unchanged**
    (it is covered by golden/screenshot tests and reused by Home), so the summary
    is a preceding screen rather than an injected header.
  - The technical debug panel moved off the feedback page to the summary screen.
- **Reason:** Reassure users about exactly what was used to analyze them before they
  read, and remove ambiguity in time entry — without risking the engine, the
  normalization layer, or the shared report widget.
- **Impact:** UX only; deployed to production. New tests assert Thai date
  formatting, weekday mapping, and that the **displayed** Thai astrological date
  equals Birth Normalization for birth times 00:00 / 03:00 / 05:47 / 05:48 / 12:00 /
  23:59. Existing Thai-research tests still pass.
- **Related documents:** `THAI_RESEARCH.md`, `PRODUCT_VALIDATION.md`.
- **Related implementation:** `lib/features/thai_beta/presentation/**`
  (`pages/thai_beta_summary_page.dart`, `widgets/thai_beta_time_picker.dart`,
  `widgets/thai_beta_summary_card.dart`, `widgets/thai_beta_transparency_banner.dart`,
  `widgets/thai_beta_debug_panel.dart`, `thai_beta_thai_date_format.dart`).

---

## D-040 — Thai Astrology Research UX polish

- **Date:** 2026-06 · **Status:** Accepted · UX only (deployed) · Builds on D-039
- **Context:** Before inviting real users at scale, increase trust, completion
  rate, and feedback quality. No engine, runtime, report, normalization, or mirror
  change.
- **Decision:**
  - **Landing screen** before the form (`ThaiBetaLandingPage`) setting
    expectations — purpose, estimated time, privacy, research participation, and a
    best-effort participant count (`counters/thai_research.seq`, omitted when
    unavailable) — with primary CTA “เริ่มการวิเคราะห์”.
  - **4-step progress indicator** (`ThaiBetaProgressBar`) on every step:
    กรอกข้อมูล · ตรวจสอบข้อมูล · อ่านผล · ส่งความคิดเห็น.
  - **Clearer CTA copy:** input “เริ่มวิเคราะห์”, summary “ยืนยันข้อมูลและดูผล”,
    feedback “ส่งความคิดเห็น”.
  - **Completion screen** (`ThaiBetaCompletionPage`) replaces the post-save dialog:
    thank-you, prominent Reference ID, and an invitation to return after future
    improvements (restart returns to the landing screen).
- **Reason:** A guided, expectation-setting funnel with visible progress and a
  satisfying close improves completion and the quality/credibility of feedback —
  without touching any frozen system.
- **Impact:** UX only; deployed to production. Widget smoke tests cover the
  landing CTA, the progress bar labels, and the completion screen; all existing
  Thai-research tests still pass.
- **Related documents:** `THAI_RESEARCH.md`, `PRODUCT_VALIDATION.md`.
- **Related implementation:** `lib/features/thai_beta/presentation/pages/`
  (`thai_beta_landing_page.dart`, `thai_beta_completion_page.dart`) and
  `presentation/widgets/thai_beta_progress_bar.dart`; routing in
  `presentation/thai_beta_routes.dart` and `lib/core/web/web_launch_router.dart`.

---

## D-041 — Thai Astrology Research desktop/web UX fixes

- **Date:** 2026-06 · **Status:** Accepted · UX only (deployed) · Builds on D-040
- **Context:** The V1 controls worked on mobile but were awkward on web/desktop:
  the scrolling birth-time wheel was hard to operate with a mouse/keyboard, and the
  plain province dropdown was slow to navigate. No engine/runtime/report change.
- **Decision:**
  - **Birth time** → two inline controls (`ThaiBetaTimeField`): hour `00–23` +
    minute `00–59` Material 3 `DropdownMenu`s supporting click, type, and keyboard
    navigation; the scrolling wheel (and its bottom sheet) is removed. Menu height
    is bounded so the popup never goes off-screen.
  - **Province** → searchable type-ahead autocomplete (`ThaiBetaProvinceField`):
    filter while typing, keyboard navigation, mouse selection, touch support, clear
    button, height-bounded options list. Resolver keys are preserved so sunrise
    accuracy is unchanged.
  - Birth **date** keeps the centered `showDatePicker` dialog; with time inline
    there is no off-screen picker.
- **Reason:** Desktop is a primary surface for real participants; click/type/
  keyboard parity and on-screen popups reduce friction and input errors.
- **Impact:** UX only; deployed to production. New widget tests cover autocomplete
  filtering + selection (`เชียง`, `อุดร`) and the two-control time field; all
  existing Thai-research tests still pass.
- **Related documents:** `THAI_RESEARCH.md`, `PRODUCT_VALIDATION.md`.
- **Related implementation:**
  `lib/features/thai_beta/presentation/widgets/thai_beta_time_picker.dart`
  (now `ThaiBetaTimeField`), `.../widgets/thai_beta_province_field.dart`, and
  `.../pages/thai_beta_input_page.dart`.

---

## D-042 — Thai astrological date consistency + 77-province database

- **Date:** 2026-06 · **Status:** Accepted · Consistency fix (deployed) · No new features
- **Context:** Two production-grade consistency bugs surfaced in Thai Research:
  1. **Province coverage** — Birth Normalization's province table held only ~15
     entries, so most provinces fell back to the Bangkok default coordinate
     (wrong sunrise → potentially wrong Thai day), and the Research picker list
     could drift from the resolvable set.
  2. **Thai date drift** — the Consumer/Mirror runtime fed the **civil** date
     into the Life Timeline (`LifePeriodEngine.fromBirthDate(birthData.dateOnly)`)
     and the Mirror enrichment derived its weekday from `localDateTime`. For a
     before-sunrise birth the Summary correctly showed the previous day (e.g.
     Saturday) while the Life Timeline started from the civil day (Sunday) — the
     layers disagreed on the Thai day.
- **Decision:**
  - **Province DB:** one canonical 77-province table
    (`birth_normalization/application/thai_provinces.dart`) — name, latitude,
    longitude, timezone (`Asia/Bangkok`), source (provincial-capital WGS84). The
    resolver builds its coordinate map from it (+ common aliases), and the
    Research picker (`thai_beta_province_options.dart`) derives from the same
    table, so selectable ≡ resolvable. Birth Normalization resolves every
    province.
  - **One Thai date for every layer:** `ThaiBirthData.astrologicalDate` is the
    single normalized Thai date and `ThaiBirthData.thaiWeekdayNumber`
    (อาทิตย์=1…เสาร์=7, derived from it) is the only Thai weekday source. No layer
    recomputes the weekday or reads the civil date for the Thai day. The pipeline
    now uses `LifePeriodEngine.fromBirthData(birthData)` and the enrichment uses
    `astrologicalDate`. `localDateTime` remains only the lagna time and the
    verified-lunar lookup key (the dataset already bakes the sunrise-adjusted
    weekday in — GC-04/GC-05 unchanged). Added consistency-safe `fromBirthData`
    entry points on `LifePeriodEngine` and `LifeTimelineIntelligenceEngine`
    (V10–V13 inherit the timeline they build).
- **Reason:** Trust depends on the whole report agreeing with the Thai day it
  shows; a complete province database keeps the sunrise boundary (and therefore
  the Thai day) accurate nationwide. Minimal, additive change — no engine rewrite,
  no frozen-contract change.
- **Impact:** Consumer/Research correctness; deployed to production. New
  regression `test/validation/thai/thai_astrological_date_consistency_test.dart`
  proves birth Sunday 00:30 → Saturday across normalization, Foundation
  enrichment, Life Timeline, Timeline Intelligence, Prediction, Decision,
  Question, Runtime and the Consumer pipeline. All existing Thai / birth /
  research suites still pass.
- **Related documents:** `BIRTH_NORMALIZATION.md`, `THAI_RESEARCH.md`.
- **Related implementation:**
  `lib/features/birth_normalization/application/thai_provinces.dart`,
  `.../application/birth_location_resolver.dart`,
  `lib/features/thai_beta/presentation/thai_beta_province_options.dart`,
  `lib/features/astrology/thai/foundation/models/thai_birth_data.dart`,
  `.../mirror/runtime/thai_mirror_pipeline.dart`,
  `.../mirror/thai_mirror_profile_enrichment.dart`,
  `.../core/life_period/life_period_engine.dart`,
  `.../core/life_period/life_timeline_intelligence.dart`.

---

## D-043 — Thai Astrology Knowledge Foundation V1

- **Date:** 2026-06 · **Status:** Accepted · Architecture/knowledge only · No engine change · No deploy
- **Context:** The frozen `PlanetRelationshipMatrix` (D-009/V8) encodes
  friend/enemy/neutral rules that drive Life Period, Prediction, Decision and
  Mirror reasoning, but the prior Knowledge Audit found **no documented source**
  in the repository for any of those rules. There was no traceable place to
  record *why* a relationship value is what it is, or its provenance/confidence.
- **Decision:** Add a read-only **knowledge layer**
  (`lib/features/astrology/thai/knowledge/`). V1 implements the **Planet
  Relationship** domain only: `planet_relationship_knowledge.dart` exposes one
  `PlanetRelationshipRecord` per directed inter-planet pair (8 × 7 = 56), with
  `from`, `to`, current matrix value, source school, source name, reference,
  page, confidence, verified flag and notes, plus a coverage report. Each
  record's value is read from the frozen matrix at build time, so the knowledge
  base can never drift from the engine. Self-pairs are excluded (identity guard,
  not a relationship). The remaining five domains (Element, Dignity, Weekday
  Lords, Life Period Ring, Lagna Rules) are deferred to later versions.
- **Reason:** Future engine decisions must rest on traceable evidence rather
  than undocumented constants. Capturing the honest state — every value
  currently `Unknown` / `verified = false` — makes the provenance gap explicit
  and gives a single place to attach real Thai/Vedic sources later, without ever
  touching the engine.
- **No invented references:** Where a source is undocumented the record stores
  `Unknown` with `verified = false`. V1 coverage is therefore: 56 records
  (Friend 22 · Enemy 16 · Neutral 18), Verified 0, Unknown 56 — record coverage
  100%, verified coverage 0%.
- **Impact:** Purely additive; no behaviour change to Matrix, Relationship
  Engine, Prediction, Timeline, Runtime or Consumer. New validation
  `test/validation/thai/thai_planet_relationship_knowledge_test.dart` proves
  every frozen-matrix relationship has exactly one record whose value matches
  the matrix. Not deployed.
- **Related documents:** `THAI_KNOWLEDGE_FOUNDATION_V1.md`, `DOMAIN_MODEL.md`,
  `ARCHITECTURE.md`, `ROADMAP.md`.
- **Related implementation:**
  `lib/features/astrology/thai/knowledge/planet_relationship_knowledge.dart`,
  `test/validation/thai/thai_planet_relationship_knowledge_test.dart`.

---

## D-044 — Thai Astrology Knowledge Importer V2

- **Date:** 2026-06 · **Status:** Accepted · Architecture/knowledge only · No engine change · No deploy
- **Context:** Knowledge Foundation V1 (D-043) recorded Planet Relationship
  evidence, but the records were built in Dart (derived from the frozen matrix).
  Knowledge that lives in source code cannot be reviewed, sourced or edited as
  data, which is what future engine decisions need.
- **Decision:** Move the Planet Relationship knowledge **out of code into JSON**
  and add an import pipeline:
  - Data: `knowledge/planet_relationships/` with `*.schema.json` (contract),
    `*.knowme.json` (the canonical 56 records) and `*.template.json` (blank
    shape for adding a sourced record). Registered as a Flutter asset.
  - Model: `planet_relationship_knowledge.dart` becomes a data-driven model
    (record adds `status`; source adds author/edition/publisher/year/quote;
    coverage adds the status split). `PlanetRelationshipKnowledge` is now an
    instance holding imported records — **no hardcoded records**.
  - Importer: `PlanetRelationshipKnowledgeImporter` parses + validates (schema,
    missing fields, unknown enums, duplicates, broken/self references,
    matrix-consistency warning, coverage) and produces a Knowledge Import
    Report.
- **Reason:** Data-driven knowledge is reviewable and editable without code
  changes, while matrix-consistency validation guarantees the knowledge can
  never silently diverge from the frozen engine.
- **No invented references:** the canonical data seeds every relation from the
  frozen matrix with provenance `Unknown` / `status = unknown` /
  `verified = false`. Import report: 56 records (Friend 22 · Enemy 16 ·
  Neutral 18), 0 errors, 0 warnings, 0% verified coverage.
- **Impact:** Purely additive; Matrix/Engine/Prediction/Timeline/Runtime/
  Consumer untouched. The V1 validation test is replaced by an importer test
  (`thai_planet_relationship_knowledge_test.dart`) proving clean import, full
  56-pair coverage, matrix agreement, the honest seeded state, and that the
  importer flags each error/warning class. Not deployed.
- **Related documents:** `THAI_KNOWLEDGE_IMPORTER_V2.md`,
  `THAI_KNOWLEDGE_FOUNDATION_V1.md`.
- **Related implementation:**
  `knowledge/planet_relationships/*.json`,
  `lib/features/astrology/thai/knowledge/planet_relationship_knowledge.dart`,
  `lib/features/astrology/thai/knowledge/planet_relationship_knowledge_importer.dart`,
  `test/validation/thai/thai_planet_relationship_knowledge_test.dart`.

---

## D-045 — Thai Astrology Knowledge Research Infrastructure V3

- **Date:** 2026-06 · **Status:** Accepted · Architecture/knowledge only · No engine change · No deploy
- **Context:** Knowledge Importer V2 (D-044) made the engine's relationship
  rules data-driven, but they are all `Unknown` / unverified — there was no
  place to collect the *primary-source research* (books, authors, schools,
  quotes) needed to verify them. This is knowledge research, not software
  research.
- **Decision:** Add a **knowledge-research layer** for documented sources:
  - Data: `knowledge/research/` with `research.schema.json` and
    `research.template.json` (registered as a Flutter asset).
  - Model: `KnowledgeResearchRecord` (id, topic, entity, school, author, book,
    edition, publisher, year, page, language, quote, interpretation,
    relationship[], confidence, reviewedBy, status, notes) where **one record
    may support multiple relationships**, with status
    `draft/candidate/reviewed/verified/disputed/rejected`.
  - Engine: `KnowledgeResearchEngine` with `load`, `groupBySource`,
    `groupBySchool`, `findSupportingEvidence`, `findConflicts`, `coverage`,
    producing a Research Coverage Report (Books, Authors, Schools, Verified/
    Pending sources, Relationships supported, Relationships without evidence).
- **Reason:** Verifying the matrix needs an independent corpus of references; a
  research layer with status/conflict tracking is the substrate for that, and
  keeping it engine-/matrix-independent ensures sources are recorded as written
  rather than reverse-justified from engine values.
- **Hard boundary:** the research layer has **no engine and no matrix
  dependency** — planets/relations are plain strings, the source files import
  none of `core/life_period/*`, `planet_relationship_matrix`, or `life_planet`
  (enforced by a test), and the 56-pair universe is sized from a layer-local
  planet list.
- **No invented references / no data yet:** V3 ships the infrastructure only.
  The baseline Research Coverage Report is 0 books / 0 authors / 0 verified and
  56 relationships without evidence — the honest starting point.
- **Impact:** Purely additive; Matrix/Engine/Prediction/Timeline/Runtime/
  Consumer untouched. New tests
  (`test/validation/thai/thai_knowledge_research_test.dart`) cover load,
  grouping, evidence, conflicts, coverage and the decoupling guard. Not
  deployed.
- **Related documents:** `THAI_KNOWLEDGE_RESEARCH_V3.md`,
  `THAI_KNOWLEDGE_IMPORTER_V2.md`.
- **Related implementation:**
  `knowledge/research/*.json`,
  `lib/features/astrology/thai/knowledge/research/knowledge_research_record.dart`,
  `lib/features/astrology/thai/knowledge/research/knowledge_research_engine.dart`,
  `test/validation/thai/thai_knowledge_research_test.dart`.

---

## D-046 — Thai Astrology Knowledge Evidence Linking V4

- **Date:** 2026-06 · **Status:** Accepted · Architecture/knowledge only · No engine change · No deploy
- **Context:** Research records (V3) embedded bibliographic source fields, so the
  same book/author would be re-typed across records and could drift. Evidence
  needs to be a first-class, de-duplicated, citable entity.
- **Decision:** Introduce `EvidenceRecord` (`knowledge/evidence/` data +
  `lib/.../knowledge/evidence/`) with review status
  `draft/reviewed/verified/disputed/deprecated`, and **replace the bibliographic
  fields on `KnowledgeResearchRecord` with `evidenceIds[]`** (many-to-many).
  Add `KnowledgeEvidenceEngine` (`loadEvidence`, `findEvidence`, `findResearch`,
  `findRelationships`, `findOrphans`, `coverage`, `validate`) that links the two
  corpora and audits the linkage (duplicate evidence, broken links, missing/
  unused evidence, circular references) and produces an Evidence Coverage Report.
- **Reason:** One source backing many interpretations (and vice-versa) is the
  natural shape of citations; centralising it removes duplication and lets the
  workspace (V5) browse by source/author/school.
- **Boundary:** still knowledge-layer only — no engine, matrix, runtime or
  prediction dependency (enforced by test). No invented references; ships no
  data (baseline coverage all zero).
- **Impact:** Additive + a contained model change to the V3 research record
  (V3 test updated). New test
  `test/validation/thai/thai_knowledge_evidence_linking_test.dart`. Not deployed.
- **Related documents:** `THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md`.
- **Related implementation:** `knowledge/evidence/*.json`,
  `lib/features/astrology/thai/knowledge/evidence/*.dart`,
  `lib/features/astrology/thai/knowledge/research/*.dart`.

---

## D-047 — Thai Astrology Research Workspace V5

- **Date:** 2026-06 · **Status:** Accepted · Admin-only internal tool · **Deployed**
- **Context:** The knowledge/evidence/research layers (V1–V4) had no human
  surface; researchers need to browse and audit them.
- **Decision:** Add a **read-only** internal workspace (`/internal/knowledge`,
  `lib/features/knowledge_workspace/`) behind the existing admin guard. It
  browses evidence, research and relationships; filters by school/author/book/
  relationship/status/planet; shows coverage (unknown/candidate/verified/
  disputed) and, per relationship, the current matrix value, research records,
  evidence and conflicts.
- **Reason:** A safe, read-only auditing surface accelerates the actual
  knowledge research without risking any engine/runtime behaviour.
- **Boundary / validation:** depends only on the knowledge layer (V1–V4) — **no
  runtime, no prediction** dependency. Read-only (no editing). The relationship
  detail reads the frozen matrix value for display only.
- **Impact:** Additive feature + one internal route; production boot flow
  unchanged. Deployed (admin only).
- **Related documents:** `THAI_KNOWLEDGE_WORKSPACE_V5.md`.
- **Related implementation:** `lib/features/knowledge_workspace/`.

---

## D-048 — Thai Astrology Knowledge Acquisition V6

- **Date:** 2026-06 · **Status:** Accepted · Internal admin tool · No engine/runtime change · **No deploy**
- **Context:** The Knowledge Platform (V1–V5) could store, link and browse
  knowledge, but there was no safe way to *populate* it. Real Thai astrology
  research needs to be added gradually without hand-editing Dart and without any
  risk to the engine or the frozen matrix.
- **Decision:** Add a **JSON-only acquisition** layer — `knowledge/acquisition/`
  (schema + template) and `lib/features/knowledge_workspace/acquisition/`
  (`KnowledgeAcquisitionEngine` + `KnowledgeAcquisitionSession` + dashboard at
  `/internal/knowledge/acquire`, admin-guarded). A batch carries `evidence[]` +
  `research[]`; the engine validates and previews (dry-run), classifying each
  record **imported / updated / skipped / error** and detecting **conflicts**
  for touched pairs; `apply()` advances an in-session corpus, `rollback()` undoes
  the last import; every import yields an **Import Report**
  (imported/updated/skipped/conflicts/errors). `toAssetJson()` exports the merged
  corpus for committing back into the repo asset files.
- **Reason:** Decouples *collecting* knowledge from *shipping* it. Researchers
  can paste sources, see exactly what would change, apply/undo safely, then
  commit the resulting JSON — no Dart edits, no engine exposure.
- **Boundary / validation:** the layer merges only the research + evidence
  corpora; it **never imports or modifies the `PlanetRelationshipMatrix`** or the
  engine (asserted by test). The "current matrix" shown is read from the frozen
  V2 knowledge record for display only. No runtime/prediction dependency.
- **Impact:** Additive feature + one internal route; production flow unchanged.
  New engine + test exposed a small additive change to V4
  (`KnowledgeEvidenceEngine.evidenceRecordFromMap` made public for reuse). Not
  deployed.
- **Related documents:** `THAI_KNOWLEDGE_ACQUISITION_V6.md`.
- **Related implementation:** `knowledge/acquisition/*.json`,
  `lib/features/knowledge_workspace/acquisition/*.dart`.

---

## D-049 — Thai Astrology Source Collection V7

- **Date:** 2026-06 · **Status:** Accepted · Knowledge only · No engine/matrix change · **No deploy**
- **Context:** The platform could store/link/browse/import knowledge (V1–V6) but
  held no actual astrology sources. Collecting real sources is the point.
- **Decision:** Add `knowledge/sources/` (one JSON **per source**: id/title/
  author/edition/publisher/year/language/school/isbn/url/license/notes + cited
  `assertions` of `from→to→relation→page→quote`) with schema, template and an
  `sources.index.json`. Add `SourceRecord`/`SourceAssertion` +
  `KnowledgeSourceEngine` (load, `validate()` for duplicate/conflicting/
  missing-page/missing-quote/broken-reference/duplicate-source, and a Source
  Coverage Report: books/schools/authors/assertions/relationships-covered/
  -missing).
- **Reason:** The output is *knowledge, not software*. Every assertion keeps its
  original quote + page and points back to one source, so claims are auditable.
- **Boundary:** pure knowledge layer; plain strings; **no engine/matrix
  dependency** (test-enforced). Adding sources never changes the matrix.
- **Impact:** Additive; ships no fabricated sources (baseline coverage 0/56).
  New test `thai_source_consensus_review_test.dart`. Not deployed.
- **Related documents:** `THAI_SOURCE_COLLECTION_V7.md`.

---

## D-050 — Thai Astrology Consensus Engine V8

- **Date:** 2026-06 · **Status:** Accepted · Knowledge only · **No deploy**
- **Context:** Multiple sources (V7) will assert the same relationship
  differently; agreement needs to be measured before any review.
- **Decision:** Add `KnowledgeConsensusEngine` — for every directed relationship
  count friend/enemy/neutral votes and distinct sources, classify
  `consensus/majority/split/disputed/uncovered`, and estimate confidence from
  source count (1–2 low, 3–7 medium, 8+ high; downgraded one level for split/
  disputed). Produces a Consensus Report.
- **Reason:** Turns raw source votes into a single, explainable agreement signal
  that the Matrix Review (V9) can reason about.
- **Boundary:** reads only source assertions; **does not read or modify the
  `PlanetRelationshipMatrix`** (test-enforced).
- **Impact:** Additive engine + tests (incl. the brief's worked example,
  4/2/1 → majority/medium). Not deployed.
- **Related documents:** `THAI_CONSENSUS_ENGINE_V8.md`.

---

## D-051 — Thai Astrology Matrix Review V9

- **Date:** 2026-06 · **Status:** Accepted · **Proposal only** · No engine/matrix change · **No deploy**
- **Context:** With sources (V7) and consensus (V8) in place, the frozen matrix
  can be reviewed against evidence — but this is a *knowledge decision, not a
  code decision*.
- **Decision:** Add `MatrixReviewEngine` producing a **proposal** per
  relationship: current matrix (read from the V2 knowledge mirror, not the
  engine), consensus, supporting/conflicting sources, user research, and a
  recommendation **Keep / Review / Replace** with rationale, plus a qualitative
  **engine-impact estimate** over timeline/prediction/decision/compatibility/
  conversation (only Replace rows would change behaviour).
- **Reason:** Makes matrix changes evidence-driven, auditable and human-gated.
- **Boundary:** **changes no code**; never reads or writes the engine matrix.
  Acting on any Replace/Review is a separate, explicitly-approved future step.
- **Impact:** Additive analysis engine + tests; baseline proposal is 56 Keep /
  0 Review / 0 Replace (no sources yet). Not deployed.
- **Related documents:** `THAI_MATRIX_REVIEW_V9.md`.

---

## D-052 — Thai Astrology Canon V1 (Canonical Knowledge Architecture)

- **Date:** 2026-06 · **Status:** Accepted · Knowledge layer only · Engine frozen · **No deploy**
- **Context:** The knowledge platform (V1–V9) treated every source as equal. Real
  Thai astrology has a hierarchy of authority. An audit
  (`THAI_ASTROLOGY_CANON_AUDIT_V1.md`) confirmed the 56 relationships are seeded
  from the frozen matrix with no documented source, that calculation-source
  hierarchies were never bridged with the knowledge `school` vocabulary, and that
  `หลักมหาภูต` / `ส. หยกฟ้า` did not yet appear anywhere in the repo.
- **Decision:** Add a **Canonical Knowledge Layer**
  (`lib/features/astrology/thai/knowledge/canon/`): a **Source Priority ladder**
  (`KnowledgeTier`: Tier 0 calculation engine → Tier 1 Canon `หลักมหาภูต` → Tier 2
  Thai classical → Tier 3 research → Tier 4 internet), a `CanonicalKnowledgeNode`
  carrying Source/Tier/Canonical/Confidence/Evidence/References/Conditions/
  Exceptions (authority **derived from the source registry, never self-declared**),
  a `CanonConflictResolver` encoding **"Canon always wins"** (supporting sources
  add detail or are overruled, canon-vs-canon flagged for human review, no-canon
  is provisional), a `CanonKnowledgeEngine` (load/validate/resolve/coverage), and a
  `CanonBookManifest` + `knowledge/canon/mahabhut.*` skeleton as the **architecture
  to extract `หลักมหาภูต` later** (no extraction yet).
- **Reason:** Establishes a permanent, auditable foundation where a canonical
  interpretive source can win over supporting texts — without altering anything
  that runs.
- **Boundary:** **No engine / Swiss Ephemeris / formula / day / lagna / bhava /
  planet / Runtime / Provider / Mirror / Fusion / Narrative change.**
  `PlanetRelationshipMatrix` never imported, read, or written (decoupling test).
  No fabricated knowledge — baseline ships an empty node corpus and a not-started
  book skeleton; sources register identities only. Not deployed.
- **Impact:** Additive `canon/` layer + `knowledge/canon/` data + 20 tests
  (`thai_canon_knowledge_test.dart`).
- **Related documents:** `THAI_ASTROLOGY_CANON_V1.md`,
  `THAI_ASTROLOGY_CANON_AUDIT_V1.md`.

---

## D-053 — Thai Astrology Mahabhut Canon Extraction V1 (Canon Database)

- **Date:** 2026-06 · **Status:** Accepted · Knowledge layer only · Engine frozen · **No deploy**
- **Context:** Canon V1 (D-052) established the tier ladder, node, resolver and a
  single book skeleton. To ingest `หลักมหาภูต` (and future texts) we need a
  normalized, multi-book database with full traceability — **structure only, no
  extraction yet**.
- **Decision:** Add the **Mahabhut Canon Database**
  (`lib/features/astrology/thai/knowledge/canon/database/`): normalized entities
  Book→Chapter→Section→Topic→`CanonKnowledgeUnit` (type ∈ topic/concept/rule/
  formula/interpretation/meaning/example/exception/condition) plus first-class
  Evidence, CrossReference, SourceReference and Location; a multi-book
  **Manifest System** (`CanonLibraryManifest`: metadata/extraction-state/
  validation-state/version/progress); an auditable **Extraction Pipeline**
  (Book→…→Validation→Canon Database→Knowledge Index→Reasoning Engine) with
  error-gating; a **Traceability System** (`CanonDatabase.trace` → book/chapter/
  section/topic/page/source citation); a **Cross-Reference System**; and a
  **Validation Layer** (`draft→extracted→reviewed→validated→canonApproved`). A
  read-only `CanonKnowledgeIndex` is the reasoning-engine query seam.
- **Reason:** A permanent, extensible foundation so books enter the system one
  chapter at a time without further architecture change, every insight traceable
  to its page.
- **Boundary:** Compatible with V1–V9, runtime, provider, mirror, fusion,
  narrative and the evidence layer. **No calculation-engine / Swiss-Ephemeris /
  formula change.** `PlanetRelationshipMatrix` never imported/read/written
  (decoupling test). No fabricated content — DB baseline and book manifest ship
  empty/not-started. Canon V1 bridge converts approved assertive units into
  `CanonicalKnowledgeNode`s so the existing resolver/engine are unchanged. Not
  deployed.
- **Impact:** Additive `canon/database/` layer + `knowledge/canon/` data (db
  schema/template/baseline + library manifest) + 21 tests
  (`thai_canon_database_test.dart`); Canon V1's 20 tests stay green.
- **Related documents:** `THAI_MAHABHUT_CANON_EXTRACTION_V1.md`,
  `THAI_ASTROLOGY_CANON_V1.md`.

---

## D-054 — Thai Astrology Mahabhut Ingestion Toolchain V1

- **Date:** 2026-06 · **Status:** Accepted · Knowledge tooling only · Engine frozen · **No deploy**
- **Context:** The Canon Database (D-053) is ready but the book text is not yet
  available. Rather than fabricate canon (forbidden), build the toolchain that
  turns prepared text into canon-approved knowledge once a chapter is supplied.
- **Decision:** Add a pure-Dart ingestion toolchain
  (`lib/features/astrology/thai/knowledge/canon/ingestion/`) + CLI
  (`tool/canon_ingest.dart`): **Import Pipeline** (OCR/plain/Markdown/TXT →
  pages/chapters/sections/paragraphs, no PDF); **Extraction Engine** (verbatim
  Candidate units, semantics left to a human, never auto-approved); a
  **Candidate Layer** (`CanonCandidateStore`, kept separate from the database);
  a **Validation Engine** (required fields, duplicate, broken reference, missing
  citation, missing page, invalid cross-reference, empty rule, empty concept);
  an **Approval Workflow** state machine (candidate→validated→reviewed→
  canonApproved) with `promote()` → `CanonDatabasePatch`; a **Diff Engine**
  (rule/citation change detection across OCR versions); **QA Tools**
  (missing-citation/duplicate-rule/orphan-rule/broken-xref/empty-concept); and
  **Extraction Metrics** (counts/coverage/progress).
- **Reason:** Makes book ingestion near-automatic and code-free, while keeping the
  no-fabrication and full-traceability guarantees.
- **Boundary:** Restructures only user-provided text — no invented knowledge, no
  internet, no memory-sourced content, no guessing. Reasoning Engine reads only
  canon-approved units. **No change** to Swiss Ephemeris, calculation engine,
  matrix, runtime, provider, mirror, fusion, narrative, or the existing Thai
  engine; ingestion layer imports none of them and stays Flutter-free (CLI runs
  under plain `dart run`). Not deployed.
- **Impact:** Additive `canon/ingestion/` layer + CLI + 15 tests
  (`thai_canon_ingestion_toolchain_test.dart`); Canon V1 (20) and Canon Database
  (21) tests stay green.
- **Related documents:** `THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1.md`,
  `THAI_MAHABHUT_CANON_EXTRACTION_V1.md`, `THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md`.

---

## D-055 — Thai Astrology Mahabhut Content Engineering V1

- **Date:** 2026-06 · **Status:** Accepted · Reviewer tooling only · Engine frozen · **No deploy**
- **Context:** With the ingestion toolchain (D-054) in place, the remaining cost
  of converting "หลักมหาภูต" is human review. Reduce it without adding new
  architecture or fabricating content.
- **Decision:** Add a human-review layer that composes the existing toolchain:
  **Reviewer Workspace** (`lib/features/knowledge_workspace/canon_review/`,
  route `/internal/knowledge/canon-review` behind the existing
  `ThaiResearchAdminGuard`) showing source text + candidate + citation + cross
  references + validation errors together, with Coverage and Consistency tabs and
  a per-unit checklist; **Review Assistant** (`ingestion/canon_review_assistant.dart`,
  highlights + `CanonReviewChecklist`, composing the Validation Engine + QA
  Tools); **Coverage Analysis** (`canon_coverage_analysis.dart`:
  chapter/section/knowledge-density/citation/validation coverage); **Consistency
  Checker** (`canon_consistency_checker.dart`: concept naming, duplicate
  rule-id, duplicate formula, citation/metadata gaps); a **Canon Style Guide**
  and a **Content Review Checklist** doc.
- **Reason:** Lets a human read/review/approve efficiently with mechanical aids,
  while preserving no-fabrication and full traceability.
- **Boundary:** Aids are read-only and never create/alter knowledge; no parallel
  checker (analyzers reuse existing engines). No fabricated knowledge, no
  internet, no guessing. **No change** to engine, runtime, Swiss Ephemeris,
  matrix, provider, mirror, fusion, narrative; workspace reuses the existing
  admin guard + route chain. Not deployed.
- **Impact:** Additive analyzers + reviewer UI + route + 9 tests
  (`thai_canon_content_engineering_test.dart`); Toolchain (15), Canon V1 (20) and
  Canon Database (21) suites stay green.
- **Related documents:** `THAI_MAHABHUT_CONTENT_ENGINEERING_V1.md`,
  `THAI_MAHABHUT_CANON_STYLE_GUIDE.md`, `THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md`,
  `THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1.md`.

---

## D-056 — Thai Astrology Canon Platform Freeze V1

- **Date:** 2026-06 · **Status:** Accepted · **Platform FROZEN** · Engine frozen · **No deploy**
- **Context:** The Canon Platform (D-052 → D-055) is complete. Declare a freeze so
  future work is canonical *content*, not platform changes.
- **Decision:** Ratify the platform as Production Ready and **frozen**. Full audit
  performed (architecture, database, manifest, knowledge model, validation,
  approval workflow, toolchain, CLI, reviewer workspace, QA, metrics, docs).
  Behaviour-preserving fixes only: (1) fixed a build break — added the missing
  `canon/canon_json.dart` import to `canon_knowledge_engine.dart`; (2)
  consolidated duplicate `_enumByName`/`_stringList` helpers in
  `database/canon_entities.dart` and `ingestion/canon_candidate.dart` to the
  shared `canon_json.dart`. Verified no circular dependencies, no layer leakage
  (leaf → database → ingestion; root reasoning pillar independent), consistent
  data/schema namespacing, and that the two manifests (`CanonBookManifest` per-book
  vs `CanonLibraryManifest` multi-book) are complementary, not duplicate.
- **Reason:** Lock a stable foundation; reduce risk; direct effort to Content
  Engineering.
- **Boundary:** From now, **no new platform features/layers/schemas/workflows or
  architecture changes** without a new explicit decision; bug fixes that block
  real usage are allowed. No fabricated knowledge; engine and all frozen surfaces
  untouched. Not deployed.
- **Impact:** Build break removed; duplicate logic eliminated; 65 canon tests stay
  green; `flutter analyze` clean.
- **Related documents:** `THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md` (+ all canon
  platform docs).

---

## D-057 — Canon Provenance Policy: reference-only citations (copyright)

- **Date:** 2026-06 · **Status:** Accepted · Implementation mode · Engine frozen · **No deploy**
- **Context:** Implementation-mode directive reframes the book as a **Canon
  Reference**: extract structured knowledge, **never store copyrighted narrative
  text**. This is a *real inconsistency* with the frozen platform, which was
  quote-first and **required** a verbatim quote to approve a unit — the one
  condition under which the freeze permits change.
- **Decision:** Provenance is by **reference**, not stored text. Minimal,
  behaviour-preserving changes: (1) extraction no longer seeds `evidenceQuote`
  with the verbatim paragraph; (2) `CanonCandidateUnit.hasCitation` and the
  validator's `missing_citation` now require a **book reference** (page /
  chapter / section), not a quote; `missing_page` still requires a page; (3) the
  Canon Database warns only when evidence has **no provenance at all** (no quote
  *and* no page), not merely a missing quote; (4) the review checklist's
  "verbatim" item becomes "faithful structured knowledge (not copied paragraph
  text)". The verbatim paragraph remains only as local working material and is
  never promoted to `canon_database.knowme.json`. Canon V1's `hasEvidence`
  already accepted a page-only reference, so no model redesign was needed.
- **Reason:** Comply with the copyright principle (Knowledge → Rules → Narrative;
  narrative generated from the knowledge layer, never hardcoded book text) while
  preserving Canon compatibility.
- **Boundary:** No new layers/schemas/workflows; no fabricated knowledge; engine
  and all frozen surfaces untouched. Not deployed.
- **Impact:** Canon suite stays green (66 tests after splitting one DB test);
  `flutter analyze` clean.
- **Related documents:** `THAI_MAHABHUT_CANON_STYLE_GUIDE.md` (§0 Provenance),
  `THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md`,
  `THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md`.

---

## D-058 — Canon Atomic Knowledge Foundation V2

- **Date:** 2026-06 · **Status:** Accepted · Knowledge platform only · Engine frozen · **No deploy**
- **Context:** Implementation-mode refinement: move Canon from a Statement-based
  model to an **Atomic Knowledge** model and make Canon a **knowledge graph**, so
  the flow is Book → Atomic Knowledge → Knowledge Graph → Rule Engine → Reasoning
  → Narrative (never Book → Statement → Narrative).
- **Decision:** Add a pure-Dart atomic layer
  (`lib/features/astrology/thai/knowledge/canon/atomic/`): `AtomicKnowledgeUnit`
  (one atomic fact = subject `--relation-->` object + condition/effect/strength/
  confidence + reference-only evidence); a controlled vocabulary
  (`AtomicRelation`, `AtomicEntityKind`, `AtomicStrength`, `KnowledgeDomain`);
  `AtomicExtractionRules` (one fact/meaning/rule; rejects paragraphs, summaries,
  rewritten narrative, interpretation, prediction); `AtomicKnowledgeGraph`
  (entities = nodes, relations = first-class edges; validation + queries); and a
  deterministic `CanonCompletenessReport` (domain-based coverage + evidence/
  verified/unknown-relationship metrics). The free-text `statement` is demoted to
  working material; the atomic unit is the canonical object.
- **Reason:** Atomic, graph-shaped knowledge is reusable and reason-able; narrative
  is generated from it and never stored as Canon.
- **Boundary:** No architecture redesign, no new engine, no UI, no runtime
  behaviour change. Untouched: `PlanetRelationshipMatrix`, Rule Engine, Timeline,
  Prediction, Decision, Runtime, Mirror, Conversation, Fusion, Narrative. No
  fabricated knowledge; provenance by reference only (D-057). Not deployed.
- **Impact:** Additive `atomic/` layer + 12 tests
  (`thai_canon_atomic_knowledge_test.dart`); full canon suite (78) green;
  `flutter analyze` clean.
- **Related documents:** `THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`,
  `THAI_MAHABHUT_CANON_STYLE_GUIDE.md`, `THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md`.

---

## D-059 — Canon Ontology Foundation V3 (Canonical Ontology Layer)

- **Date:** 2026-06 · **Status:** Accepted · Knowledge platform only · Engine frozen · **No deploy**
- **Context:** Atomic units (D-058) needed a single controlled vocabulary so no
  Canon package invents entity or relationship names. Flow becomes Book → Atomic
  Knowledge → **Canonical Ontology** → Knowledge Graph → Rule Engine → Reasoning →
  Narrative.
- **Decision:** Add a pure-Dart ontology layer
  (`lib/features/astrology/thai/knowledge/canon/ontology/`): `CanonicalEntity`
  (stable `id`, `canonicalName`, `category`, `aliases`, structured `description`,
  `parentId`, `status`) with id convention `<category>.<slug>`; `CanonicalOntology`
  registry with **deterministic alias resolution** (unknown/ambiguous stays
  unresolved — never guesses), a **relationship registry** (the only legal graph
  relationships; a superset of every V2 `AtomicRelation` wire) and a **domain
  taxonomy** (`domain.life` root + children); `validate()` → deterministic
  `OntologyValidationReport` (duplicate ids, alias collisions, unregistered
  relationship, category/id mismatch, orphan entities, taxonomy cycles); and a
  seeded `CanonOntologyData.standard()` (9 grahas, 4 elements, life domains,
  relationship entities) — **vocabulary only, no astrological claims**.
- **Reason:** A mandatory vocabulary layer makes extraction consistent and
  reason-able and prevents drift; entities are identified by id, never display
  text.
- **Boundary:** No architecture redesign, no new engine, no UI, no runtime
  behaviour change. **Knowledge Graph logic untouched** — relationship coverage is
  proved by a read-only test against `AtomicRelation`. Untouched:
  `PlanetRelationshipMatrix`, Rule Engine, Prediction, Timeline, Decision,
  Runtime, Mirror, Conversation, Fusion, Narrative. Not deployed.
- **Impact:** Additive `ontology/` layer + 17 tests
  (`thai_canon_ontology_test.dart`); full canon suite (95) green; `flutter
  analyze` clean.
- **Related documents:** `THAI_CANON_ONTOLOGY_V3.md`,
  `THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`, `THAI_MAHABHUT_CANON_STYLE_GUIDE.md`.

---

## D-060 — Canon Knowledge Extraction Workspace V4

- **Date:** 2026-06 · **Status:** Accepted · Workspace only · Engine frozen · **No deploy**
- **Context:** Atomic Knowledge (D-058) + Canonical Ontology (D-059) needed a
  production workflow. The workspace becomes the **only supported path** for
  adding Canon knowledge: Book Page → Extraction Workspace → Atomic Knowledge
  Units → Ontology Validation → Knowledge Graph Validation → Review → Canon
  Database. Nothing enters Canon directly.
- **Decision:** Add a pure-Dart workspace package
  (`lib/features/astrology/thai/knowledge/canon/workspace/`):
  `KnowledgeExtractionSession` with a deterministic lifecycle (Draft → Extracting
  → Validated → Reviewed → Approved → Imported → Archived); `ExtractionSource`
  (provenance only: book/edition/chapter/page range/reviewer/date/progress);
  `WorkspaceValidator` → deterministic report catching every failure class
  (atomicity, ontology-unresolved subject/object, relationship registration,
  evidence reference, duplicate knowledge, graph conflicts incl. baseline
  conflict, coverage impact); `KnowledgeDiff` (NEW/UPDATED/UNCHANGED/CONFLICT/
  DEPRECATED — never overwrite Canon blindly); `CompletenessDelta` (before/after
  `CanonCompletenessReport`, conflicts not applied); and `ReviewReport` (a
  deterministic, structured, non-narrative decision surface gating
  `readyForImport`).
- **Reason:** A single auditable, deterministic ingestion path keeps Canon
  consistent and reviewable, and prevents direct/blind writes.
- **Boundary:** No architecture redesign, no new engine, no UI, no runtime
  behaviour change. The workspace consumes the atomic + ontology layers
  read-only; no engine may depend on it. Untouched: Ontology, Knowledge Graph
  logic, Atomic Knowledge, Rule Engine, Timeline, Prediction, Decision, Runtime,
  Mirror, Conversation, Fusion, `PlanetRelationshipMatrix`. Not deployed.
- **Impact:** Additive `workspace/` layer + 14 tests
  (`thai_canon_workspace_test.dart`); full canon suite (109) green; `flutter
  analyze` clean.
- **Related documents:** `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`,
  `THAI_CANON_ONTOLOGY_V3.md`, `THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`,
  `THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md`.

---

## D-061 — Canon Knowledge Production V1 (production begins; facts stay Unknown)

- **Date:** 2026-06 · **Status:** Accepted · Content production · Engine frozen · **No deploy**
- **Context:** With the platform foundation complete (D-052…D-060), V1 shifts to
  producing real Canon knowledge for six foundational domains (Planet Library,
  House Library, Planet→Meaning, Planet→Keywords, Planet→Domain, Planet→Element)
  using `หลักมหาภูต` as Canon.
- **Decision / outcome:** The canonical **source text is not in the repository**
  (only `knowledge/canon/sources/mahabhut/README.md`). Per the absolute Canon rule
  ("no speculative astrology; if unsupported, leave it Unknown; never invent from
  memory/internet"), **no facts were fabricated** — substantive knowledge is left
  Unknown. Delivered the maximum compliant value: (a) ontology expansion — seeded
  the 12 houses and added `meaning`/`role`/`keyword` categories (structural
  vocabulary, no claims); (b) a Canon-compatible fix adding `element`/`keyword`/
  `role` to `AtomicEntityKind`; (c) a content-tier `KnowledgeProductionReport`
  (`canon/production/`) — deterministic per-domain produced/verified/coverage/
  status over imported atomic units, with all-atomic + provenance checks; (d) the
  empty `foundation_v1.knowme.json` dataset + a one-step unblock.
- **Reason:** Inventing planet/house meanings would violate the project's core
  principle; the honest deliverable is a ready production pipeline + truthful
  Unknown reports.
- **Boundary:** No runtime/engine/matrix change, no UI, no deploy, no new platform
  infrastructure beyond the structural ontology + atomic-kind fix + report
  aggregator. Knowledge enters only via the workspace; provenance reference-only
  (D-057). `PlanetRelationshipMatrix`, Rule Engine, Timeline, Prediction,
  Decision, Runtime, Mirror, Conversation, Fusion untouched.
- **Impact:** `canon/production/` + ontology/atomic vocabulary additions + 11 tests
  (`thai_canon_production_test.dart`); full canon suite (120) green; `flutter
  analyze` clean.
- **Related documents:** `THAI_CANON_KNOWLEDGE_PRODUCTION_V1.md`,
  `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`, `THAI_CANON_ONTOLOGY_V3.md`,
  `knowledge/canon/sources/mahabhut/README.md`.

---

## D-062 — Canon Knowledge Authoring Studio V1 (human editing layer)

- **Date:** 2026-06 · **Status:** Accepted · Authoring layer only · Engine frozen · **No deploy**
- **Context:** Production V1 (D-061) showed the need to make page-by-page
  conversion practical for a human reviewer. The studio is the official editing
  layer that sits *before* the Workspace: Reference Book Page → Authoring Studio →
  Draft Knowledge Units → Workspace Validation → Diff → Review → Canon Import.
- **Decision:** Add a pure-Dart authoring package
  (`lib/features/astrology/thai/knowledge/canon/authoring/`): `DraftKnowledgeUnit`
  (editable, atomic mirror of `AtomicKnowledgeUnit` — no narrative fields);
  `OntologyAssist` (classifies each subject/object as resolved / missingOntology /
  unknown; never auto-creates entries); `AuthoringStudio` with deterministic batch
  editing (add/duplicate/split/merge/delete/reorder; output stays atomic),
  deterministic id generation, ontology assistance, validation **preview that
  reuses `WorkspaceValidator`/`ReviewReport` (no duplicated logic)**, and
  export/import that reproduces the identical draft state.
- **Reason:** Efficient human authoring with the same validation guarantees as the
  Workspace, without forking validation logic or touching any frozen layer.
- **Boundary:** Authoring only — no UI, no runtime/engine/matrix change, no deploy.
  Consumes Workspace + ontology + atomic read-only. Untouched: Workspace, Ontology,
  Knowledge Graph, Atomic Knowledge, Rule Engine, Timeline, Prediction, Decision,
  Runtime, Mirror, Conversation, Fusion, `PlanetRelationshipMatrix`. Nothing here
  is Canon until imported via the Workspace; provenance reference-only (D-057).
- **Impact:** Additive `authoring/` layer + 11 tests
  (`thai_canon_authoring_test.dart`); full canon suite (131) green; `flutter
  analyze` clean.
- **Related documents:** `THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md`,
  `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`,
  `THAI_CANON_KNOWLEDGE_PRODUCTION_V1.md`.

---

## D-063 — Golden Canon Dataset V1 (QA regression suite)

- **Date:** 2026-06 · **Status:** Accepted · QA assets only · Engine frozen · **No deploy**
- **Context:** With the platform complete, Canon development needs a deterministic
  regression suite so future extraction / validation / pipeline changes can be
  verified against fixed, known-good outcomes — without any astrology engine
  consuming the data.
- **Decision:** Add a pure-Dart QA package
  (`lib/features/astrology/thai/knowledge/canon/golden/`): `GoldenDataset` +
  `GoldenExpectation` (declared deterministic outcome: units, ontology coverage,
  graph shape, validation result + error codes, diff counts + readiness,
  completeness deltas) with deterministic `versionTag` and FNV-1a `fingerprint`;
  `GoldenVerifier` that runs the **real** pipeline (`WorkspaceValidator`,
  `KnowledgeDiff`, `CompletenessDelta`, `ReviewReport` — no logic reimplemented)
  and reports field-level mismatches; a catalog of **10 fixtures** (minimal,
  single planet, single house, planet+house, conflict, duplicate, ontology
  failure, relationship failure, coverage increase, deprecated); and deterministic
  reports (`GoldenReport`).
- **Reason:** A fixed, deterministic regression contract for the whole Canon
  pipeline, built on the existing validator rather than a parallel one.
- **Boundary:** QA only — no UI, no runtime/engine/matrix change, no deploy. No
  copyrighted text and no invented astrology facts (synthetic structural fixtures;
  the relationship-failure case uses a *custom* ontology missing a relationship
  rather than mutating shared data). Untouched: Authoring Studio, Workspace,
  Ontology, Knowledge Graph, Atomic Knowledge, Rule Engine, Timeline, Prediction,
  Decision, Runtime, Mirror, Conversation, Fusion, `PlanetRelationshipMatrix`.
- **Impact:** Additive `golden/` layer + 18 tests
  (`thai_canon_golden_test.dart`); full canon suite (149) green; `flutter analyze`
  clean.
- **Related documents:** `THAI_CANON_GOLDEN_DATASET_V1.md`,
  `THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`,
  `THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md`.

---

## D-064 — Canon Working Source Adapter V1 (temporary source material)

- **Date:** 2026-06 · **Status:** Accepted · Adapter layer only · Engine + platform frozen · **No deploy**
- **Context:** Knowledge production required Canon sources to already exist as TXT
  files. Reviewers also have PDFs, page images and OCR output. We need to feed
  that temporary material to the Authoring Studio without persisting copyrighted
  prose and without redesigning any frozen layer.
- **Decision:** Add a pure-Dart **Working Source** layer
  (`lib/features/astrology/thai/knowledge/canon/working_source/`): one common
  `WorkingSource` interface (`pages()`, `page()`, `extractionSourceForPage()`,
  `dispose()`) over four adapters — `TxtWorkingSource`, `OcrWorkingSource`,
  `PdfWorkingSource`, `ImageWorkingSource` — all normalised to identical
  `WorkingPage`s by one deterministic paginator. The Authoring Studio consumes
  only the interface (via a provenance-only `ExtractionSource`), never a concrete
  file type.
- **Reason:** Removes the TXT-only constraint while keeping the platform frozen
  and provenance reference-only.
- **Boundary:** Adapter only — no automatic extraction, no AI, no runtime/engine/
  ontology change, no workspace redesign, no deploy. Working Sources are
  **temporary**: only book/edition/chapter/page references survive (D-057);
  `ExtractionSource` has no text field, so prose cannot cross into Canon; `dispose`
  discards everything and Canon stays intact. Untouched: Atomic Knowledge,
  Ontology, Knowledge Graph, Workspace, Authoring Studio, Golden Dataset, Rule
  Engine, Prediction, Timeline, Decision, Runtime, Mirror, Conversation, Fusion,
  `PlanetRelationshipMatrix`.
- **Impact:** Additive `working_source/` layer + tests
  (`thai_canon_working_source_test.dart`); full canon suite green; `flutter
  analyze` clean.
- **Folder intake (2026-06-30, Knowledge Production Sprint 2):** extended the TXT
  working source (no platform redesign) with `WorkingSourceFolder.loadTxt` +
  `TxtWorkingSource.fromPages` + `WorkingSourcePaginator.pageVerbatim`. Reads a
  folder of per-page OCR `.txt` files (one file = one page; page number from the
  filename; numeric order; verbatim text with only UTF-8/BOM + line-ending
  normalisation; missing/duplicate page numbers raise, never merge). Smoke-verified
  on the real OCR drop (`D:\MahabhutOCR\txt`, 308 pages → refs 1…308). Implementation
  improvement only — no runtime/Canon/ontology/workspace change. 164 canon tests
  green; analyze clean.
- **Related documents:** `THAI_CANON_WORKING_SOURCE_ADAPTER_V1.md`,
  `THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md`,
  `THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md`.

---

## D-065 — Canon Platform Production Mode (platform complete; knowledge production only)

- **Date:** 2026-06 · **Status:** Accepted · Platform **FROZEN** · Production mode active · **No deploy unless requested**
- **Context:** With D-056…D-064 the Canon Platform is complete: Working Source
  intake, Authoring Studio, Atomic Knowledge, Ontology, Workspace, Golden QA, and
  the production tracker. Further platform layers would add complexity without
  increasing Canon knowledge coverage.
- **Decision:** Ratify **Production Mode** — stop creating platform layers,
  infrastructure and framework abstractions. The official pipeline (Working Source →
  Authoring Studio → Atomic Knowledge → Ontology Resolution → Workspace
  Validation → Review → Canon Import → Canon Database → Rule Engine → Reasoning
  → Narrative) is the **only supported production workflow**. Future work is
  limited to: (1) Knowledge Production, (2) Ontology Expansion only when
  extraction genuinely requires it, (3) Bug Fixes (implementation inconsistencies
  only), (4) Performance without behaviour change. Platform changes permitted
  only when a real inconsistency is proven or Canon knowledge cannot be
  represented — otherwise produce an Ontology Gap Report or Knowledge Modeling
  Gap Report. Success is measured by **Knowledge Coverage increase**, not LOC or
  new modules.
- **Reason:** Lock the completed architecture and redirect all effort to verified
  Canon knowledge from the official source.
- **Boundary:** No runtime/engine/workspace redesign; no ontology redesign unless
  extraction requires it; no deploy unless requested; no architecture experiments.
  Knowledge rule unchanged: never invent/summarize/interpret during extraction;
  knowledge enters only through Working Source → Authoring → Workspace → Review →
  Import.
- **Impact:** Governance documentation only (`THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`);
  no code changes; supersedes D-056 scope classification for future work.
- **Related documents:** `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md`,
  `THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md`, `THAI_CANON_KNOWLEDGE_PRODUCTION_V1.md`.

---

## D-068 — Atomic applicability scope: the `context` qualifier

- **Date:** 2026-06-30 · **Status:** Accepted · Resolves the Sprint 2B Knowledge
  Modeling Gap · Atomic-model extension (additive) · **No deploy**
- **Context:** Sprint 2B (`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md`) showed the
  book's life-period / archetype readings are **chart-scoped**: a placement such as
  `moon --located_in--> marana` is true **within ดวงนักวิชาการ**, not as a general
  rule. The atomic unit had no way to record *the scope under which a fact is
  true*, so bulk extraction would have to either stop or misstate Canon.
- **Decision:** Add **one** optional qualifier — `AtomicContext { type, value }` —
  to `AtomicKnowledgeUnit`. **Not** separate `archetypeChart`/`lifePeriod` fields;
  a single generalized scope object whose `type` is one of
  `archetype_chart` / `taksa_chart` / `lagna` / `life_period` / `other` and whose
  `value` is an atomic token taken **from the source** (e.g. the chart's own name).
  Examples: `{archetype_chart, ดวงนักวิชาการ}`, `{lagna, aries}`,
  `{life_period, saturn}`.
- **Semantics:** A unit **without** context is a general/unconditional fact. A unit
  **with** context asserts the *same* `(subject, relation, object)` fact, applicable
  **only within that scope**. The unit's identity is unchanged — this only extends
  applicability.
- **Rules honoured:** optional · deterministic (enum-typed scope + atomic value) ·
  provenance still required (the unit's evidence reference is unchanged) · no
  inference · no external knowledge (the project's first batch uses the source's
  **verbatim Thai chart headings** as values, never translated). **No** Runtime,
  Rule Engine, Workspace, Authoring, Canon Database or ontology redesign.
- **Validation:** `AtomicExtractionRules.validateUnit` now rejects an empty
  context value (`empty_context_value`) or a prose value (`non_atomic_context`).
- **Impact:** `atomic_relation.dart` (+`AtomicContextType`), `atomic_knowledge_unit.dart`
  (+`AtomicContext`, optional field, JSON, label), `atomic_extraction_rules.dart`
  (+2 checks); 236 thai tests green; analyze clean. Production resumed (Sprint 2C):
  chart-scoped placements now carry context; coverage 8 → 9 units.
- **Related documents:** `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md` (the gap),
  `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2C.md` (this resolution + resumed batch),
  `THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`.

---

## D-067 — Ontology Expansion: Mahabhut Named Positions

- **Date:** 2026-06-30 · **Status:** Accepted · D-065 category 2 (Ontology Expansion) · Ontology-only · **No deploy**
- **Context:** Sprint 2 (`THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2.md`) proved that
  `หลักมหาภูต` expresses planetary placement through its own system of **named
  positions** (`เรือนธงชัย`, `อธิบดี`, `ขุมทรัพย์`, `ราชา`, `ปูติ`, `มรณะ`,
  `ภังคะ`) rather than the numbered bhāva. The Canonical Ontology (planets +
  houses 1–12 + elements + domains) could not represent them, so Canon knowledge
  could not be expressed — the one condition under which D-065 permits a platform
  change.
- **Decision:** Extend **only** `CanonOntology`. Add one category
  `OntologyCategory.mahabhutPosition` and seven `CanonicalEntity`s
  (`mahabhutPosition.thongchai/athibodi/khumsap/racha/puti/marana/phangkha`).
- **Creation criterion (corrected, Sprint 2B):** an entity is introduced **because
  it is required for Canon representation** — the book expresses planetary
  placement through these named positions, so its statements cannot be represented
  without them. **OCR frequency is supporting evidence for prioritization only,
  never the criterion for creating an entity.** (For the record, the seven also
  occur with high frequency — มรณะ 74 · ภังคะ 71 · ขุมทรัพย์ 58 · ธงชัย 55 · อธิบดี
  51 · ราชา 50 · ปูติ 48 — but that frequency merely confirms priority; the
  entities exist because the Canon text uses them as placement vocabulary.) No
  external Thai-astrology terminology was introduced. Each entity carries only an
  id, a phonetic-romanisation `canonicalName` (not a translation) and the Thai
  surface forms (`เรือน…` + bare term) as aliases.
- **Reason:** Make the book's core vocabulary representable so production can
  proceed faithfully, without inventing meaning.
- **Boundary — vocabulary only:** **No meanings, interpretations, relationships,
  strength polarities or bhāva-number mappings** are encoded (those are Canon
  knowledge produced from the book under human review). **No** change to Runtime,
  Workspace, Authoring, Atomic Knowledge, Canon Database, Rule Engine or the
  `PlanetRelationshipMatrix`. All existing ontology ids are preserved (`other`
  remains the fallback). The atomic model represents a position via its existing
  `objectKind: other` escape hatch + the ontology id — no atomic change required.
- **Impact:** `ontology_category.dart` (+1 category), `canon_ontology_data.dart`
  (+7 entities, included in `allEntities()`); ontology validates clean; 174 canon
  tests green; analyze clean. First real production batch produced and validated
  (`thai_canon_production_sprint2_test.dart`; `foundation_v1.knowme.json`).
- **Related documents:** `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2.md` (gap),
  `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2A.md` (this expansion + first batch),
  `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md` (D-065/D-066).

---

## D-066 — Knowledge Rule clarification: Extraction allowed, Generation forbidden

- **Date:** 2026-06-30 · **Status:** Accepted · Clarifies D-065 · Documentation/policy only · **No code change**
- **Context:** An earlier interpretation read the Knowledge Rule as forbidding AI
  from reading the Canon source at all ("never OCR/read/extract"), which blocked
  the intended production workflow. The Canon policy never forbade AI
  *extraction* — it forbids AI *generation*. The distinction was implicit and
  needed to be explicit.
- **Decision:** State the rule as **Extraction is allowed; Generation is
  forbidden.** AI **may** perform deterministic information extraction FROM the
  Canon source text — read a Working Source page, identify the atomic facts
  **stated on that page**, restructure them into atomic triples (subject →
  relation → object + qualifiers) without adding meaning, and resolve the page's
  surface terms to the Canonical Ontology. AI **must not** hallucinate, infer
  beyond the text, interpret, summarize, or use external knowledge. The intended
  workflow is **Book → OCR → Working Source → AI-assisted Atomic Knowledge
  Extraction → Human Review → Workspace Validation → Canon Import**; every unit
  traces to a page (reference-only provenance, D-057) and **Human Review remains
  mandatory** before validation/import. Unrepresentable facts or missing entities
  produce gap reports — never invention.
- **Reason:** Unblock AI-assisted knowledge production while preserving the
  anti-hallucination guarantees; "extracted FROM the source, never invented."
- **Boundary:** Documentation/policy clarification only — no runtime/engine/
  platform/ontology/workspace change, no new code. The Working Source Adapter
  itself remains a dumb text supplier (it still performs no OCR and no extraction,
  D-064); extraction happens at the authoring/atomic step under human review.
- **Impact:** Updated `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md` (Knowledge Rule
  + pipeline), `THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md`,
  `THAI_MAHABHUT_CONTENT_ENGINEERING_V1.md`, and the sprint note in
  `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_1.md`.
- **Related documents:** `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md` (D-065),
  `THAI_CANON_KNOWLEDGE_AUTHORING_STUDIO_V1.md`,
  `THAI_CANON_WORKING_SOURCE_ADAPTER_V1.md`.

---

## D-073 — Mahabhut Canon Completion Program (supersedes Foundation-only charter)

- **Date:** 2026-07-01 · **Status:** Accepted · Supersedes Foundation-only Production
  Charter and Volume 1 production pause · Documentation/governance only at
  authorization · **No platform/runtime/Canon redesign at decision time**
- **Context:** Volume 1 (Batches 4–9) established a foundation baseline (357 units,
  98.6% of the Volume 1 representable pool) but intentionally deferred Taksa,
  life-period, prediction rules, remedies, and lookup tables under a
  foundation-only charter. The product objective is now **complete Canon coverage**
  of `หลักมหาภูต`, not foundation-only extraction.
- **Decision:** Authorize the **Mahabhut Canon Completion Program**. Cancel the
  previous Foundation-only Production Charter. Continue production until every
  representable knowledge domain in the book is processed. Phase order:
  **C Taksa → D Life Period → E Prediction Rules → F Remedies → G Lookup Tables →
  H Final Audit → I Mahabhut Canon Freeze**. Do **not** stop after every
  Production Batch. Stop **only** for genuine Ontology Gap, genuine Knowledge
  Modeling Gap, or unrecoverable OCR. Ontology Expansion permitted when genuinely
  required (D-065 cat. 2, D-067 criterion). Knowledge Modeling changes permitted
  only when a true Modeling Gap is proven and documented. Knowledge Rule unchanged
  (D-066): no hallucination, no external knowledge, no interpretation;
  deterministic extraction; human review mandatory. Use existing platform; do not
  redesign Platform, Runtime, or Canon architecture. Commit at meaningful
  milestones. Final deliverable: **Mahabhut Canon Complete**.
- **Reason:** Volume 1 proved the pipeline and baseline; remaining book content is
  the majority of Canon knowledge and was deferred by charter, not by
  unrepresentability.
- **Boundary:** Volume 1 closure doc remains the historical baseline (357 units);
  D-065–D-072 policies remain active except the foundation-only scope limit and
  pause. Batch numbering may continue for traceability but does not imply pause.
- **Impact:** `THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md` is the program of
  record; `PROJECT_INDEX.md` and `ROADMAP.md` updated; Volume 1 closure marked
  superseded as scope authority (baseline preserved).
- **Related documents:** `THAI_CANON_PRODUCTION_VOLUME_1_CLOSURE.md`,
  `THAI_CANON_KNOWLEDGE_PRODUCTION_SPRINT_2B.md` (Taksa gap analysis),
  `THAI_CANON_PLATFORM_PRODUCTION_MODE_V1.md` (D-065/D-066).

---

## D-074 — Mahabhut Taksa role ontology (Phase C)

- **Date:** 2026-07-01 · **Status:** Accepted · Ontology expansion only · **No
  platform/runtime/engine change**
- **Context:** D-073 Phase C requires representing ทักษา dignity roles from
  `หลักมหาภูต` pp.38–41 and per-chart `ดาวแห่ง…` assignments. Sprint 2B
  identified missing `taksaRole` vocabulary. Eight roles appear explicitly in
  Canon text on p38–39.
- **Decision:** Add `OntologyCategory.taksaRole` and eight entities:
  `taksaRole.boriwan`, `.ayu`, `.det`, `.sri`, `.mula`, `.utsaha`, `.montri`,
  `.kalakini` — Thai aliases verbatim from source; **no meaning, polarity,
  strength, or prediction fields**.
- **Reason:** Minimum vocabulary required to represent explicit Canon Taksa
  assignments without inventing roles.
- **Boundary:** Vocabulary only. Role meanings use existing `domain.*` via `owns`
  only where atomic (four roles on p39). Compound meanings remain modeling gaps.
- **Impact:** `canon_ontology_data.dart`, `ontology_category.dart`,
  `thai_canon_ontology_test.dart`; production Phase C (+95 units).
- **Related documents:** `THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_C.md`,
  `THAI_MAHABHUT_CANON_COMPLETION_PROGRAM.md` (D-073).

---

## D-075 — Mahabhut Life Period ontology (Phase D)

- **Date:** 2026-07-01 · **Status:** Accepted · Ontology expansion only · **No
  platform/runtime/engine change**
- **Context:** D-073 Phase D requires vocabulary for `ดวงขึ้น` / `ดวงตก`
  classification and recoverable `เสวยอายุ` dasha durations on p18, plus life-period
  scoped production using existing `life_period` context (D-068).
- **Decision:** Add `OntologyCategory.periodStatus` with `periodStatus.duengKhuen`
  and `periodStatus.duengTok`; add four `agePeriod.dasha*y` entities for OCR-clean
  dasha lines. **No meanings, prediction, or polarity encoded.**
- **Reason:** Minimum vocabulary for p17–18 universal rules and dasha duration facts.
- **Boundary:** Per-period tokens remain verbatim in `context.value`; no per-chart
  `agePeriod` entity explosion. Narrative life effects remain modeling gaps.
- **Impact:** `canon_ontology_data.dart`, `ontology_category.dart`, ontology and
  production tests; Phase D +226 units (678 cumulative).
- **Related documents:** `THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_D.md`.

---

## D-076 — Mahabhut prediction effect ontology (Phase E)

- **Date:** 2026-07-01 · **Status:** Accepted · Ontology expansion only · **No
  platform/runtime/engine change**
- **Context:** D-073 Phase E requires representing pp.40–41 universal rise/fall
  prediction vocabulary (`อ่อนแอ`, `เข้มแข็ง`) without inferring domain mappings.
- **Decision:** Add `OntologyCategory.predictionEffect` with
  `predictionEffect.weak` and `predictionEffect.strong` — Thai aliases verbatim
  from the Canon. **No meanings or polarity encoded.**
- **Reason:** Minimum vocabulary for universal position-strength prediction rules
  on pp.40–41 without domain inference.
- **Boundary:** Per-period narrative effects remain a modeling gap; `AtomicRelation`
  enum unchanged (`produces` / `opposes` used).
- **Impact:** Phase E +5 units (683 cumulative); ontology and production tests.
- **Related documents:** `THAI_CANON_KNOWLEDGE_PRODUCTION_PHASE_E.md`.

---

## Related documents

- [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) — rules, reading order, Documentation Policy.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (decisions D-004–D-006, D-015, D-018).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model the decisions shape.
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) §10 — major decisions in project context.
- [`PROJECT_INDEX.md`](PROJECT_INDEX.md) — full documentation map.
