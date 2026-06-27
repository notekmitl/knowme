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

---

## Related documents

- [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) — rules, reading order, Documentation Policy.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry (decisions D-004–D-006, D-015, D-018).
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — conceptual model the decisions shape.
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) §10 — major decisions in project context.
- [`PROJECT_INDEX.md`](PROJECT_INDEX.md) — full documentation map.
