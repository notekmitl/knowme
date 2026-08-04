# KnowMe Current Status

**Last updated:** August 3, 2026
**Branch:** `main`  
**Merge tip before Core Reading V1:** `380348f` (PR #63 Production Funnel Measurement V1); Production hosted @ `da85013`

**Prior architecture snapshot:** `feature/fusion-result`  
**Automation workflow (authoritative):** Codex Single-Agent + Local Gate — [`docs/KNOWME_SINGLE_AGENT_WORKFLOW.md`](KNOWME_SINGLE_AGENT_WORKFLOW.md). Codex is the sole executor for one task branch/worktree at a time; Cursor, Claude Code, and other agents must not edit that same branch/worktree concurrently. External AI Worker **retired** July 2026 (historical record: [`docs/AI_WORKER_OPERATION.md`](AI_WORKER_OPERATION.md)).
**Thai Beta Public:** Anonymous `/beta/thai` → `ThaiBetaLandingPage` (not Login). LEVEL 1 Canon badges now use `public_beta`: rollout flag + eligible public-safe report evidence only, never Auth/UID/invite membership.
**Thai Beta Narrative / Life Map:** **Human Readability V2 Production QA passed** on 2026-08-03 at Hosting release `eb1f1c8`. PR #75 shipped the reader-facing rewrite; PR #76 removed the final public `Canon` label and closed Personal Core/Closing gaps; PR #77 added the evidence-backed Closing fallback found by Production smoke testing. Known-time/no-time, Desktop/Mobile, Timeline, Evidence, and the real 8-page PDF were verified end-to-end; V1.3.5 detailed evidence remains **internal only**.
**Thai Mirror QA screenshot baseline:** Repair V1 merged through PR #80 at `3671b62fba86fc83365fdba597b695b1f3324c6b`. Fifty-one harness PNGs now form the deterministic Flutter 3.41.1 baseline and restore the QA screenshot Gate. The separate standalone consumer golden remains a known 32.63% / 305,379-pixel failure and requires its own task.
**Thai Beta Past-to-Future Narrative V3:** Recovered from the validated V3 archive and resumed on post-PR-80 main `3671b62fba86fc83365fdba597b695b1f3324c6b`. Local Gate passed at implementation commit `468827ffec9ef845db91a498f7287e52c925ab57`; Draft PR #81 is open. V3 is not a Production release. The standalone consumer golden remains a separate known failure.

---

## Completed Programs

| Program | Status | Evidence |
|---------|--------|----------|
| **Thai Mirror (engine + structural)** | Production structural ready | `docs/THAI_MIRROR_SPECIFICATION_V1.md`, `lib/features/astrology/thai/mirror/` |
| **Thai Consumer Report (V3–V8)** | Production deployed | `docs/EXECUTIVE_SUMMARY.md`, consumer presenter + result page, evidence narrative (V7), Life Timeline (V8) |
| **Thai Life Timeline Intelligence (V9)** | Implemented (engine + presentation, tests + gates pass) | `docs/THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md` — planet relationship engine, per-period intelligence, current-age analysis, future-period preview (evidence only) |
| **Thai Prediction Intelligence Foundation (V10)** | Implemented (engine + tests; no presentation) | `docs/THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md` — deterministic predictions per category × window over V9 (evidence only; not AI, not transit) |
| **Thai Future Prediction Presentation (V10.5)** | Production deployed — first Thai Prediction Intelligence release | Future Prediction section inside the existing consumer report (Life Timeline → Future Prediction → Signature Insight); `PredictionComposer`/`PredictionReasonCopy`/`ThaiMirrorFuturePredictionSection`; tendency copy, copy boundary preserved; story-coverage + screenshot gates extended (D-021) |
| **Thai Decision Intelligence Foundation (V11)** | Implemented (engine + tests; no presentation) | `docs/THAI_DECISION_INTELLIGENCE_V11.md` — deterministic per-scenario decision guidance over V10 (10 scenarios → verdict/confidence/reasons/evidence/timing/tradeoffs); evidence only; not AI, not transit, not compatibility (D-022) |
| **Thai Question Reasoning Foundation (V12)** | Implemented (engine + tests; no presentation) | `docs/THAI_QUESTION_REASONING_FOUNDATION_V12.md` — deterministic structured-intent → decision-query resolver over V11 (10 topics × 6 intents → resolved scenario, relevant windows/evidence, priority reasons, structured answer, confidence); evidence only; no AI, no LLM, no parser (D-023) |
| **Thai Unified Reasoning Runtime (V13)** | Implemented (engine + tests; no presentation) | `docs/THAI_REASONING_RUNTIME_V13.md` — single orchestration entry point over V9–V12 (`evaluate`/`predict`/`decide`/`question`/`answer` → unified snapshots + flattened evidence + trace + confidence); the only public reasoning entry point; evidence only; not AI, not transit, not compatibility; no presenter/UI/LLM (D-024) |
| **Thai Scenario Simulation Foundation (V14)** | Implemented (engine + tests; no presentation) | `docs/THAI_SCENARIO_SIMULATION_V14.md` — deterministic hypothetical decision-path evaluation over the runtime (7 scenarios × Act now/Best window/Alternative window/Do nothing → expected/opportunity/risk/tradeoffs/timing/confidence/evidence + ranked comparison); consumes the runtime only; evidence only; not AI, no presenter, no parser (D-025) |
| **Thai Transit Intelligence Integration (V15)** | Implemented (engine + tests; no presentation) | `docs/THAI_TRANSIT_INTEGRATION_V15.md` — day-of-week-ruler transit assessed vs natal + current period via the shared V9 relationship engine, converted to evidence and merged through an Enhanced Runtime wrapper; transit contributes evidence only (never decides/predicts/answers); runtime untouched; evidence only; not AI, no presenter (D-026) |
| **Mirror Conversation Experience Foundation (V16)** | Implemented (foundation + tests; no UI/deploy) | `docs/THAI_MIRROR_CONVERSATION_V16.md` — deterministic guided conversation over the V13 runtime (8 topics, predefined question catalog → runtime `evaluate`/`predict`/`decide`/`question` → structured answer → suggested follow-ups); consumes the runtime only; no AI, no LLM, no chat model, no parser, no free text (D-027) |
| **Thai Astrology QA Harness V1** | Implemented | `docs/ASTROLOGY_QA_HARNESS_V1.md` — preview route, profiles A–H, screenshot regression + story coverage CI |
| **GF2** | Implemented + validated | `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md`, 1000-human gate PASS |
| **Human Model** | Implemented | `lib/features/human_model/`, synthetic pipeline validated |
| **Human Pattern** | Recovery V2 complete | `docs/HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` — 9/20 dead patterns recovered |
| **Narrative V5** | Complete | `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` — 1000/1000 unique, 0 collapse |
| **Funnel Recovery V2** | Implemented | `lib/features/home_cohesion/`, `lib/features/funnel_telemetry/`, MBTI → narrative preview loop |
| **Thai Beta Narrative Quality V1–V1.2.2 + Life Map V1.2.3** | Merged to `main` + **hosted** | Life Map V1.2.3; PR https://github.com/notekmitl/knowme/pull/18; production https://knowme-app-694e1.web.app/beta/thai |
| **Thai Birth Profile Core Reading V1/V1.1** | **Production released + verified** | PR #67 (`e3b88df`, merge `a4ce716`) plus birth-hour fixes PR #68/#69; lifelong “ดวงจากวันเกิดของคุณ” before Timeline; Web/PDF share one `ThaiBetaAnalysis`; no Engine/Canon change — [`THAI_BIRTH_PROFILE_CORE_READING_V1.md`](THAI_BIRTH_PROFILE_CORE_READING_V1.md) |
| **Thai Beta Human Readability V2** | **Production released + verified** | PR #75 (`ce96440`, merge `a30a114`), Production hardening PR #76 (`7d3e0e2`, merge `59e140e`), and Closing fallback PR #77 (`dccd103`, merge/Hosting `eb1f1c8`). Eight deterministic fixtures, Web/PDF parity, known/no-time fail-closed behavior, Desktop/Mobile layout, and the real 8-page Production PDF passed. This is product readability validation only, not a claim of astrological accuracy; the 10-person cohort has not started. |
| **Public LEVEL 1 Canon Evidence Badge** | **Production released + anonymously verified** | PR #70 (`71578aa`, merge `c1598d6`) removed Auth/UID/invite dependency; PR #71 (`c32add8`, merge `adf0142`) removed internal section identifiers from public output. Web/capture/PDF use the same eligible evidence policy. |
| **Life Map Mahabhut Canon index (Production fix)** | Merged to `main` + **hosted** | PR https://github.com/notekmitl/knowme/pull/20 @ `07d0eb9`; wires Frozen Canon `repository.index` into Timeline/Consumer presenters — unknown no longer forced by null index. Presenter-path QA (1972-04-04 02:00 BKK): **known=7 / unknown=1** (ธงชัย, unknown, ปูติ, อธิบดี, ขุมทรัพย์, ปูติ, มรณะ, ราชา). Sample pipeline fixture: known=8 / unknown=0 |
| **Thai Life Map V1.2.4 Accuracy Audit** | Merged tests + report | PR #22 @ `cb33a3d`; 22 fixtures / 176 periods; known 139 / unknown 37; [`THAI_LIFE_MAP_V124_ACCURACY_AUDIT.md`](THAI_LIFE_MAP_V124_ACCURACY_AUDIT.md) |
| **Thai Life Map V1.2.5 Invited Beta Feedback** | Merged + **hosted** — **Ready for Validation** | PR #23 @ `b5d1243`; deploy Firebase Hosting + rules 2026-07-23; anonymous Production QA PASS (no panel/badge leak); **0 real invited Feedback** → not Validation Passed; [`THAI_LIFE_MAP_V125_BETA_VALIDATION.md`](THAI_LIFE_MAP_V125_BETA_VALIDATION.md) |
| **Thai Life Map V1.2.6 Narrative & Life-stage UX** | Merged + **hosted** — **Ready for Validation** | PR #25/#27/#31/#33; past life-breadth PR #35 @ `399ac7a` + phase hygiene PR #36 @ `5529264` (evidence-linked Past facets; no `ลองนึกย้อน`; Canon/formulas unchanged); [`THAI_LIFE_MAP_V126_NARRATIVE_UX.md`](THAI_LIFE_MAP_V126_NARRATIVE_UX.md) |
| **Thai Life Map V1.2.7 Simulated 864 Matrix** | Merged + **hosted** | PR #38 @ `2e633b8`; 8 weekday categories × ages 1–108 = **864/864** production-path passes; independent Sakamoto/Almanac oracle; optional `asOf` plumbing; Canon unresolved tallied (not forced 8/0); [`THAI_LIFE_MAP_V127_SIMULATED_MATRIX.md`](THAI_LIFE_MAP_V127_SIMULATED_MATRIX.md) |
| **Thai Life Map V1.2.8 Verdict Narrative** | Merged + **hosted** — **product-failed on UI** | PR #40 @ `4b42f95`; hedges/labels improved but meta-language remained (`แกนของชีวิต` / `บรรยากาศหลัก`) |
| **Thai Life Map V1.2.9 Semantic Verdict Fix** | Merged + **hosted** — **product-failed on UI** | PR #42 @ `7ca091f`; semantic claims existed but UI prose stayed system-like (`ช่วงนั้น` / domain dump) |
| **Thai Life Map V1.3.0 Plain Thai Narrative** | Merged + **hosted** — **product-failed on UI** | PR #44 @ `ad1e948`; plain Thai improved but Past too short / Current abstract duel / hero disclaimer |
| **Thai Life Map V1.3.1 Narrative Depth** | Merged + **hosted** — **product-failed on UI** | PR #46 @ `41d7988`; Past depth OK but duplicate core card / success banner / Past soft opener / abstract Current remained |
| **Thai Life Map V1.3.2 Copy Hierarchy** | Merged + **hosted** — **product-failed on UI** | PR #48 @ `c1c0cbc`; single hero + silent complete birth + Past/Current language; owner Production Acceptance failed (personality-only hero / Past skeletons / Current headings) |
| **Thai Life Map V1.3.3 Holistic Domains** | Merged + **hosted** — **product-failed on UI** | PR #50 @ `dff4b43`; holistic hero + Past variety + Current domains; owner Production Acceptance failed (abstract overview / Past templates / wrong domain set) |
| **Thai Life Map V1.3.4 Narrative Quality** | Merged + **hosted + anonymously validated** | PR #52 @ `7a3d07d`; overview/Past/Current quality on PeriodScores only — no SE/degrees/houses; accepted UI restored by PR #58 and verified end-to-end on Production bundle `da85013`; [`THAI_LIFE_MAP_V134_NARRATIVE_QUALITY.md`](THAI_LIFE_MAP_V134_NARRATIVE_QUALITY.md) |
| **Thai Life Map V1.3.5 Evidence Detail** | Evidence **internal**; customer detailed report **rejected**; accepted UI restored + validated | PR #54/#56 failed PA; PR #58 @ `0eb7bdb` restored accepted Life Map and removed `_DetailedEvidenceReport` from the public path; anonymous QA confirmed no internal evidence/Canon prose leakage on `da85013`; [`THAI_LIFE_MAP_V135_EVIDENCE_DETAIL.md`](THAI_LIFE_MAP_V135_EVIDENCE_DETAIL.md) |
| **Thai Beta anonymous Public route** | Merged + **hosted + verified** | Anonymous needs no account or seeded UID. PR #61 fixed `PublicThaiBetaApp` using `/` as its Navigator route; merge `da85013`, Production bundle `da85013`, reload remains on `/beta/thai` |
| **Codex Single-Agent + Local Gate** | Current repository workflow | `docs/KNOWME_SINGLE_AGENT_WORKFLOW.md`, `scripts/knowme_task_gate.ps1` |

**Also complete (supporting):**

- Narrative V3 selection, V4 plan topology (`docs/NARRATIVE_INTELLIGENCE_SELECTION_V3.md`, `docs/NARRATIVE_PLAN_TOPOLOGY_V4.md`)
- Synthetic population validation V1–V3 (`docs/SYNTHETIC_HUMAN_POPULATION_V1.md`, `docs/SYNTHETIC_POPULATION_V2_1000_REPORT.md`)
- Real User Runtime Validation V1 (`docs/REAL_USER_RUNTIME_VALIDATION_V1.md`)
- Thai Astrology Consumer Report evolution V3→V8 — long-form narrative (V3–V5), article-style result page (V4), evidence-combination personalization (V7), and the Life Timeline / life-period engine (V8). See `docs/EXECUTIVE_SUMMARY.md`.
- Repository Survival V1 — architecture snapshot pushed to GitHub

---

## Current Focus

**Make Thai Astrology Beta useful and credible to real testers before expanding
to other systems.**

The immediate product surface is the lifelong Thai birth-profile reading on
`/beta/thai`. Funnel history and measurement remain recorded, but Funnel/MBTI
work is not the current next implementation priority.

**Active product surface:**

- Home V3 unlock hero when astrology complete + no MBTI
- Profile completion bar (35% → 100%)
- MBTI mini (16Q) → instant narrative preview
- Recovery banner for astrology-only users
- Funnel telemetry in Firestore

**Engine status:** Synthetic validation proves pipeline diversity and determinism. Production bottleneck is **funnel conversion**, not upstream collapse.

---

## Known Risks

| Risk | Severity | Detail |
|------|----------|--------|
| Personality test cliff | **Critical** | 97% of profile users never start MBTI (`REAL_USER_RUNTIME_VALIDATION_V1.md`) |
| Hosting source vs `main` | **Low** | Public Hosting was manually deployed from `main` @ `eb1f1c8` on 2026-08-03; deploy remains manual (`scripts/deploy_web.ps1`), with no auto-deploy |
| Real user PII export local-only | **High** | `firestore_user_export.json` gitignored — must regenerate locally |
| Firebase service account local-only | **High** | `backend/firebase/serviceAccountKey.json` gitignored |
| Legacy + new architecture coexist | **Medium** | Parallel scoring, navigation, and module IDs — trace before editing |
| Funnel Recovery V2 effectiveness unproven | **Medium** | Production Funnel Measurement V1 observed 1/4 Narrative preview reach, but n=4 and baseline semantics differ; no causal lift claim |

---

## Technical Debt Register

Accepted debt — do not hide; trace before editing.

| Item | Severity | Detail | Rule |
|------|----------|--------|------|
| Hybrid test architecture | Medium | `UniversalTestPage` + feature-specific systems coexist | Low blast radius migration only — do not aggressively unify |
| Repeated session patterns | Low | MBTI + Cognitive duplicate session state patterns | Duplication > bad abstraction until justified |
| AppText monolith | Low | `lib/core/i18n/app_text.dart` large | ARB/codegen future; acceptable for now |
| Fusion outlier coverage | Low | Special-case copy for ESTJ, ENTJ, INTJ, ENFP only | Quality > coverage — expand carefully |
| Dual astrology providers | Medium | `presentation/providers/astrology_provider.dart` + `lib/astrology/providers/astrology_provider.dart` | Do not aggressively merge — duplicate path risk |
| Hosting source vs `main` | Low | Last public deploy from `main` @ `adf0142` (manual); no auto-deploy | Keep using `scripts/deploy_web.ps1` for intentional releases |
| Real user PII export local-only | High | `firestore_user_export.json` gitignored | Regenerate locally |
| Firebase service account local-only | High | `backend/firebase/serviceAccountKey.json` gitignored | Never commit |

---

## Deployment

| Item | Value |
|------|-------|
| **Status** | Public beta live on Firebase Hosting (June 2026) |
| **Primary URL** | https://knowme-app-694e1.web.app |
| **Firebase project** | `knowme-app-694e1` |
| **Branch deployed from** | `main` @ `adf0142` (2026-07-30, PR #71); still **manual** deploy only — no auto-deploy |
| **Full guide** | [`docs/DEPLOYMENT.md`](DEPLOYMENT.md) |

Deploy: `.\scripts\deploy_web.ps1` or `firebase deploy --only hosting --project knowme-app-694e1`

**Governance / freeze detail:** [`docs/GOVERNANCE.md`](GOVERNANCE.md)

## Next Priority

**Thai Birth Profile Human-Readable Core Reading V1.1 is Production released
and verified.**

PR #67, birth-hour fixes PR #68/#69, public badge PR #70, and redaction hotfix
PR #71 are merged. Anonymous Production smoke testing passed for selected birth
time and unknown birth time, LEVEL 1 eligible evidence, Core Reading placement,
Timeline separation, public-safe output, and real Web/PDF parity. No further
Core Reading release action is pending; future interpretive accuracy decisions
remain owner/tester judgments.

**Production Funnel Measurement V1 remains COMPLETE — decision IMPROVE.**

- Completed Bangkok window: 23 June–27 July 2026.
- Eligible 4; MBTI started 2; completed 1; Narrative preview reached 1.
- Observed reach is `1/4 = 25%`, but n=4 is below the decision minimum and is not directly comparable with the historical `1/38 = 2.6%` full-Narrative baseline.
- Single observed bottleneck: eligible → MBTI started (2/4 lost).
- No Funnel/UI change is authorized by this result. Re-run the read-only command after a decision-sized cohort; see [`PRODUCTION_FUNNEL_MEASUREMENT_V1.md`](PRODUCTION_FUNNEL_MEASUREMENT_V1.md).

Keep hosting deploys intentional and maintain frozen systems with blocker fixes only.

**Not next (explicitly deferred per master context):**

- AI narrative layer
- Astrology fusion redesign
- Big Five as primary funnel path (MBTI mini is the recovery path)
- Architecture rewrites
