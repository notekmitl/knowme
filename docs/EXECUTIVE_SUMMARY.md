# KnowMe — Executive Summary

**Status:** CURRENT — the fastest way to understand the entire project.
**Audience:** Everyone (humans + AI agents).
**Last updated:** June 2026
**Live:** Public beta — https://knowme-app-694e1.web.app (Firebase project `knowme-app-694e1`)

For behavioral rules read [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md); for the
full documentation map read [`PROJECT_INDEX.md`](PROJECT_INDEX.md).

---

## 1. What KnowMe is

A deterministic, multi-lens **self-understanding** product. It combines astrology
(Thai / Western / Chinese BaZi) and structured personality tests (MBTI / EQ / Big Five)
into progressively deeper, human-readable reflection — a *digital mirror for
self-understanding*, not a horoscope or quiz app.

**Core stance:** deterministic engines first (no LLM in core paths) → predictable,
debuggable, explainable output. Same input → same result.

**Strategic reality:** the engines are diverse and validated; the **bottleneck is
funnel conversion** — only ~2.6% of real users reach the narrative because most never
start a personality test after astrology.

---

## 2. Current / production architecture

```
User (Firestore profile + test results)
        ↓
Lens Systems        Thai · Western · BaZi · MBTI · EQ · Big Five · Personality Mirror
        ↓
Mirror (MV1 + MV2 promotion)         KnowMeMirrorSnapshot
        ↓
GF1 — Global Fusion Foundation       GlobalFusionSnapshot
        ↓
GF2 — Global Fusion Recovery         composed fusionSnapshot (flag-gated)
        ↓
Human Model → Human Pattern          dimensions → pattern activations
        ↓
Narrative Runtime (V5)               deterministic NarrativeResult
        ↓
Home Experience (+ Fusion/Result pages)
```

Each layer consumes the layer above and never bypasses upstream contracts. Detail:
[`ARCHITECTURE.md`](ARCHITECTURE.md), [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md).

**Two production runtime paths:**
- **Home load:** `HomeV3Loader` → `HomeV2Loader` (+ optional `NarrativeRuntimeLoader`) → `HomeV3Assembler` → `HomeScreenV3`.
- **Full narrative pipeline:** `UserRuntimePipelineService.loadNarrativeForUser(uid)` → mirror input → dual mirror snapshots → GF1 (+ GF2) → Human Model → Human Pattern → Narrative.

**The Thai Astrology Consumer Report runs its own self-contained pipeline** (see §4),
separate from the global narrative pipeline.

---

## 3. Astrology engines

| System | Owner | State |
|--------|-------|-------|
| **Thai foundation** (lagna, Myanmar Seven, Mahabhuta, lunar calendar) | `lib/features/astrology/thai/foundation/` | Engine **V1.1**, conditional freeze |
| **Thai theme scoring** (resolver → engine → presenter) | `lib/features/astrology/thai/theme/` | V1 production path |
| **Thai life-period engine** (8-planet life cycle + V9 Life Timeline Intelligence) | `lib/features/astrology/thai/core/life_period/` | **V9**, active (evidence only) |
| **Thai prediction foundation** (deterministic predictions per category × window over V9) | `lib/features/astrology/thai/core/prediction/` | **V10**, active (evidence only) |
| **Thai future prediction presentation** (consumer-report Future Prediction section) | `lib/features/astrology/thai/mirror/presentation/prediction/` + `…/ui/widgets/thai_mirror_future_prediction_section.dart` | **V10.5**, production (consumes `PredictionIntelligence` only; tendency copy; D-021) |
| **Thai decision foundation** (deterministic per-scenario decision guidance over V10) | `lib/features/astrology/thai/core/decision/` | **V11**, active (evidence only; D-022) |
| **Thai question foundation** (deterministic structured-intent → decision-query resolver over V11) | `lib/features/astrology/thai/core/question/` | **V12**, active (evidence only; no LLM/parser; D-023) |
| **Thai reasoning runtime** (orchestration of V9→V12 behind one entry point) | `lib/features/astrology/thai/core/runtime/` | **V13**, active (evidence only; no presenter/UI/LLM; D-024) |
| **Thai V2 structural stack** (signal → interpretation → theme_v2 → mirror_v2 → fusion_v2) | `lib/features/astrology/thai/…/v2` | Built for validation; **not** wired into the report |
| **Western Natal V1** | astrology services + `astrology/western_natal` | Temporary freeze; fusion input |
| **Chinese BaZi V1** | `lib/features/bazi/` + backend API | Temporary freeze; source of truth `astrology/chinese_bazi` |
| **Astrology Fusion V6** | `lib/features/astrology/fusion/` | Freeze candidate (multi-system astrology reflection) |

---

## 4. Thai Astrology Consumer Report (the deepest, most recent work)

A deterministic, evidence-backed Thai report that explains who a user tends to be and —
via the **V8 Life Timeline** — *why life tends to change across age periods*.

**Self-contained pipeline** (orchestrated by `ThaiMirrorPipeline.generate`):

```
ThaiBirthData
  → ThaiFoundationEngine            lagna / Myanmar Seven / Mahabhuta
  → ThaiMirrorProfileEnrichment     fallback lens keys
  → Theme scoring                   resolver → engine → presenter
  → ThaiMirrorAssembler             V1 "Truth Lock": structure + evidence, NO copy
  → ThaiMirrorNarrativeGenerator    internal section summaries
  → LifePeriodEngine.fromBirthDate  V8 life-period sequence (evidence only)
  → ThaiMirrorConsumerPresenter     ALL user-facing Thai copy
  → ThaiMirrorResultPage            article-style consumer page (one shared page)
```

**Version ledger (shipped):** V1 Truth-Lock structural mirror · V1.1/V1.2 foundation +
narrative gen · V2 combination/lagna copy engine + parallel V2 structural stack · V3
long-form narrative · V4 article-style page + closing · V5 storytelling polish · V6
contradiction observations · **V7 evidence-combination personalization (evidence
composer + signature insight)** · **V8 life-period engine + Life Timeline** ·
**V9 Life Timeline Intelligence (planet relationship engine + per-period
intelligence + current-age analysis + future-period preview, evidence only)** ·
**V10 Prediction Intelligence Foundation (deterministic predictions per category
× window over V9 — evidence only; not AI, not transit; no presenter)** ·
**V10.5 Future Prediction presentation (consumer-report section: current · next
12 months · next life period; tendency copy; the first production Thai
Prediction Intelligence release)** · **V11 Decision Intelligence Foundation
(deterministic per-scenario decision guidance over V10 — verdict/confidence/
reasons/evidence/timing/tradeoffs for ten scenarios; evidence only; not AI, not
transit, not compatibility; no presenter)** · **V12 Question Reasoning
Foundation (deterministic structured-intent → decision-query resolver over V11 —
ten topics × six intents → resolved scenario, relevant windows/evidence,
priority reasons, structured answer, confidence; evidence only; no AI, no LLM, no
parser; no presenter)** · **V13 Unified Reasoning Runtime (single orchestration
entry point coordinating Timeline/Prediction/Decision/Question — `evaluate` /
`predict` / `decide` / `question` / `answer` returning unified snapshots +
flattened evidence + trace + confidence; evidence only; not AI, not transit, not
compatibility; no presenter)**.

**Copy boundary:** engines emit structure + evidence; only the consumer presenter and
copy composers emit Thai prose — this keeps the engine frozen while UX iterates.

Full detail kept in this document's companion sections and in
[`ASTROLOGY_QA_HARNESS_V1.md`](ASTROLOGY_QA_HARNESS_V1.md). The original
[`THAI_MIRROR_SPECIFICATION_V1.md`](THAI_MIRROR_SPECIFICATION_V1.md) /
[`THAI_MIRROR_UI_SPECIFICATION_V1.md`](THAI_MIRROR_UI_SPECIFICATION_V1.md) predate this
report and are HISTORICAL/SUPERSEDED.

---

## 5. Personality lenses & cross-lens pipeline

| Lens | Owner | State |
|------|-------|-------|
| MBTI Progressive (16→40→80) + Cognitive | `lib/features/tests/mbti/`, `mbti_cognitive/` | Implemented |
| MBTI Summary Fusion | `lib/features/tests/mbti_summary/` | Frozen v1.3 |
| EQ (6 modules) | `lib/features/tests/eq/` | Usable+ / frozen-ish |
| Big Five Progressive | `lib/features/tests/big_five/` | Implemented (future MVP) |
| Cross-lens Fusion Result | `lib/features/tests/fusion/` | Frozen v1 ([`FUSION_RESULT_V1_SPEC.md`](FUSION_RESULT_V1_SPEC.md)) |
| Personality Mirror | `lib/features/personality_mirror/` | Temporary freeze |

**Mirror → Fusion → Narrative:** MV1 core gates (frozen) + MV2 promotion (additive) →
GF1 foundation (frozen) → GF2 recovery (implemented, flag-gated, 1000-human PASS) →
Human Model → Human Pattern (Recovery V2) → Narrative Runtime V5 (1000/1000 unique on
synthetic). Status of record: [`GF2_PRODUCTION_IMPLEMENTATION_V1.md`](GF2_PRODUCTION_IMPLEMENTATION_V1.md),
[`NARRATIVE_EVIDENCE_BRANCHING_V5.md`](NARRATIVE_EVIDENCE_BRANCHING_V5.md).

---

## 6. Presentation layer

- **Home V3.8** (`lib/features/home_cohesion/`) — emotional surface: hero, signature
  themes, insight cards, profile strip, psychology-test cards, Funnel Recovery V2 UI
  (completion bar, unlock hero, MBTI CTA, narrative preview, recovery banner).
- **Thai Consumer Report** — single `ThaiMirrorResultPage` shared by signed-in entry,
  QA harness, demo, and web preview (never duplicated). Sections: birth-confidence →
  hero → Life Timeline → signature insight → life dashboard → strengths/cautions →
  advice → narrative → reflection → closing → source transparency.
- **Other result surfaces** — BaZi result page, Fusion result page, Astrology Fusion
  entry.
- **Web launch routing** (`lib/core/web/`) — `WebLaunchRouter` parses the browser URL so
  preview/QA deep links open the report and bypass `AuthGate` on web.

---

## 7. QA infrastructure

Reusable, production-faithful harness — renders the **real pipeline and page**, never a
duplicate UI. Detail: [`ASTROLOGY_QA_HARNESS_V1.md`](ASTROLOGY_QA_HARNESS_V1.md).

| Capability | Where |
|------------|-------|
| Preview from URL (profiles A–H, viewport/theme/locale/age/no-time) | `/thai-mirror/consumer-preview`, `qa/harness/` |
| Screenshot regression (A–H × desktop/tablet/mobile, pinned `asOf`) | `test/validation/thai_mirror_qa_harness/screenshot_regression_test.dart` |
| Story-coverage CI (sections present, no empty/placeholder/English-leak/overflow) | `…/story_coverage_validation_test.dart` |
| No-stale-build policy (service worker disabled + `no-cache` entry files) | `web/index.html`, `firebase.json` |
| Synthetic validation (200→1000 humans), real-user replay (38) | `test/validation/synthetic_population*/`, `real_user_runtime_v1/` |

**Gate:** Thai presentation changes must pass screenshot regression + story coverage
before deploy.

---

## 8. Freeze map

Full detail: [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md); policy: [`GOVERNANCE.md`](GOVERNANCE.md).

| System | Status |
|--------|--------|
| Western Natal V1 / Chinese BaZi V1 | Temporary freeze |
| Thai engine (foundation/theme/assembler) | Conditional freeze v0.1.0 |
| **Thai Consumer Report / Timeline (V9 Intelligence) / Prediction Foundation (V10) / Decision Foundation (V11) / Question Foundation (V12) / Reasoning Runtime (V13) / Evidence Composer** | **Active (additive on frozen engine)** |
| Thai Fusion V2 | Conditional freeze v0.1.0 |
| Astrology Fusion V6 | Freeze candidate |
| QA Harness | Active (additive) |
| Fusion Result V1 (presentation) | Frozen v1 |
| MBTI Summary | Frozen-ish v1.3 · EQ MVP frozen-ish · Big Five future MVP |
| Edit Profile V1 · Personality Mirror V1 | Temporary freeze |
| MV1 core gates / GF1 | Conditional freeze · GF2 implemented+validated |
| Human Model / Human Pattern (Recovery V2) | Completed |
| Narrative Runtime V5 | Frozen (terminal) |

---

## 9. Known technical debt

From [`CURRENT_STATUS.md`](CURRENT_STATUS.md) — accepted debt, trace before editing:

| Item | Severity | Note |
|------|----------|------|
| Hybrid test architecture (`UniversalTestPage` + feature systems) | Medium | Low-blast-radius migration only |
| Dual astrology providers (`presentation/providers/` + `lib/astrology/providers/`) | Medium | Do not aggressively merge |
| Parallel Thai stacks (V1 production vs V2 structural) | Medium | V2 not wired into the report |
| Repeated session patterns (MBTI + Cognitive) | Low | Duplication > bad abstraction for now |
| `AppText` monolith | Low | ARB/codegen later |
| Fusion outlier copy coverage (ESTJ/ENTJ/INTJ/ENFP) | Low | Quality > coverage |
| `origin/main` behind `feature/fusion-result` | High | Merge when release-ready |
| Real-user PII export + Firebase service account local-only | High | Gitignored; never commit |
| Thai lunar dataset coverage limited (license-blocked) | Medium | Uncovered dates degrade gracefully |

---

## 10. Major decisions

Full rationale (context, alternatives, tradeoffs) for each is in [`DECISION_LOG.md`](DECISION_LOG.md).

1. **Deterministic before AI** — no LLM in core astrology/MBTI-summary/narrative.
2. **Funnel before features** — conversion is the priority over more engine diversity.
3. **GF2 shipped despite a "reject" gate** — root-cause isolation re-attributed the
   `stable_orientation` failure to the Human Pattern layer (fixed in Recovery V2), not
   GF2. See [`GF2_ROOT_CAUSE_ISOLATION_REPORT.md`](GF2_ROOT_CAUSE_ISOLATION_REPORT.md),
   [`HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`](HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md).
4. **Narrative reached a terminal validated state at V5** (1000/1000 unique); further
   narrative work is additive copy, not engine reopening.
5. **Thai report evolved additively (V3–V8) on a frozen engine** via a strict copy
   boundary, rather than reopening the deterministic core.
6. **QA renders the real pipeline/page** — one shared `ThaiMirrorResultPage`; no
   duplicate report UI.
7. **Freeze-what-works governance** — most subsystems are maintenance-only; additive
   exception programs are the sanctioned way to extend them.
8. **Service worker disabled** — eliminated stale-build refresh friction for QA and
   users.

---

## 11. Roadmap

### Completed
Thai engine V1.1 + Consumer Report V3–V8 + **Life Timeline Intelligence V9** +
**Prediction Intelligence Foundation V10** + **Future Prediction Presentation
V10.5 (first production Prediction Intelligence release)** + **Decision
Intelligence Foundation V11 (engine only)** + **Question Reasoning Foundation
V12 (engine only)** + **Unified Reasoning Runtime V13 (engine only)** + QA
Harness V1 · Western Natal V1 · BaZi V1 ·
Astrology Fusion V6 · MV1/MV2 · GF1 · **GF2 (1000-human PASS)** · Human Model · Human
Pattern Recovery V2 · **Narrative V2–V5 (1000/1000 unique)** · Funnel Recovery V2
(product) · Synthetic validation 200→1000 · Real-User Validation V1 · Public Deployment
V1. Source: [`ROADMAP.md`](ROADMAP.md), [`CURRENT_STATUS.md`](CURRENT_STATUS.md).

### Active (current focus)
- **Funnel conversion** (astrology → MBTI → narrative): target 2.6% → 25%+ narrative
  reach on active users.
- **Funnel telemetry measurement** post-deploy.
- **Home experience refinement.**
- **Chinese Zodiac Personality Expansion** (additive content).
- **Real-user validation re-runs** vs the 38-user baseline.

### Remaining / future
- Thai lunar dataset full coverage (license-blocked).
- Thai Consumer Report UI-V2 Firestore hydrate (persist/cache assembled report).
- Reuse the QA harness for Western / Chinese / Fusion / Compatibility reports.
- Wire the Thai V2 structural stack into fusion when the fusion roadmap reaches astrology.
- Merge `feature/fusion-result` → `main`.
- **AI Narrative Layer** — deferred until Mirror + GF + validation are stable.

---

## 12. Future direction

KnowMe's engines are validated; the next era is **conversion and depth, not new
engines**. Near-term value comes from turning astrology-complete users into
test-completers (so the validated narrative pipeline actually reaches them), continuing
additive quality work on the Thai Consumer Report, and generalizing the QA harness
across report domains. AI enhancement remains a deliberately deferred future layer that
sits *on top of* the deterministic core — never replacing it.

---

## 13. Related documents

- [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) — rules + reading order (read first).
- [`PROJECT_INDEX.md`](PROJECT_INDEX.md) — full documentation map.
- [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — highest-level conceptual model + diagrams.
- [`DECISION_LOG.md`](DECISION_LOG.md) — why the major decisions in §10 were made.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — pipeline layers + runtime paths.
- [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md) — vision/philosophy/subsystems.
- [`CURRENT_STATUS.md`](CURRENT_STATUS.md) — status, risks, technical debt.
- [`ROADMAP.md`](ROADMAP.md) — completed / active / future.
- [`GOVERNANCE.md`](GOVERNANCE.md) + [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze policy + registry.
- [`ASTROLOGY_QA_HARNESS_V1.md`](ASTROLOGY_QA_HARNESS_V1.md) — QA infrastructure.

---

## Appendix — Thai key file map

| Area | Path |
|------|------|
| Pipeline | `lib/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart` |
| Foundation engine | `lib/features/astrology/thai/foundation/thai_foundation_engine.dart` |
| Life-period engine (V8) + Timeline Intelligence (V9) | `lib/features/astrology/thai/core/life_period/` |
| Prediction Intelligence Foundation (V10) | `lib/features/astrology/thai/core/prediction/` |
| Future Prediction presentation (V10.5) | `lib/features/astrology/thai/mirror/presentation/prediction/` + `…/ui/widgets/thai_mirror_future_prediction_section.dart` |
| Decision Intelligence Foundation (V11) | `lib/features/astrology/thai/core/decision/` |
| Question Reasoning Foundation (V12) | `lib/features/astrology/thai/core/question/` |
| Unified Reasoning Runtime (V13) | `lib/features/astrology/thai/core/runtime/` |
| Theme scoring | `lib/features/astrology/thai/theme/` |
| Mirror assembler | `lib/features/astrology/thai/mirror/thai_mirror_assembler.dart` |
| Consumer presenter | `lib/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart` |
| Copy composers (incl. V7 evidence composer) | `lib/features/astrology/thai/mirror/presentation/copy/` |
| Timeline presentation (V8) | `lib/features/astrology/thai/mirror/presentation/timeline/` |
| Consumer page + widgets | `lib/features/astrology/thai/mirror/presentation/ui/` |
| QA harness | `lib/features/astrology/thai/qa/harness/` |
| Web launch routing | `lib/core/web/` |
| QA tests | `test/validation/thai_mirror_qa_harness/`, `test/validation/thai_mirror_v8_timeline/`, `test/validation/thai_mirror_v9_intelligence/` |
