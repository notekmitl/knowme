# KnowMe Current Status

**Last updated:** July 2026  
**Branch:** `main`  
**Merge tip:** `d4e7f8b` (PR #8 — Public Beta web cache-bust; includes PR #7 AuthGate public bypass)  
**Prior architecture snapshot:** `feature/fusion-result`  
**Automation workflow (authoritative):** Single-Agent + Local Gate — [`docs/KNOWME_SINGLE_AGENT_WORKFLOW.md`](KNOWME_SINGLE_AGENT_WORKFLOW.md). External AI Worker **retired** July 2026 (historical record: [`docs/AI_WORKER_OPERATION.md`](AI_WORKER_OPERATION.md)).
**Thai Beta Public:** Anonymous `/beta/thai` → `ThaiBetaLandingPage` (not Login) — **production-verified** 2026-07-22 on Hosting `knowme-app-694e1` from `main` @ `d4e7f8b` via `scripts/deploy_web.ps1` (entrypoint `?v=<sha>` cache-bust; Evidence Badge rollout remains `invited_beta`).
**Thai Beta Narrative:** V1 + V1.1 curated blocks + **V1.1.1 Block Integrity & Confidence Consistency** on `main` (report surface; not email-gated).

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
| **Thai Beta Narrative Quality V1–V1.1.1** | Merged to `main` + **hosted** | Curated blocks + Block Integrity & Confidence Consistency; `docs/THAI_BETA_NARRATIVE_QUALITY_V1_REVIEW.md`; PR https://github.com/notekmitl/knowme/pull/1; production https://knowme-app-694e1.web.app/beta/thai |
| **Thai Beta anonymous Public route** | Merged + **hosted + verified** | PRs #7–#8; AuthGate/public bootstrap + immutable JS cache-bust; anonymous Landing PASS 2026-07-22 @ `d4e7f8b` |
| **Single-Agent + Local Gate** | Merged to `main` | `docs/KNOWME_SINGLE_AGENT_WORKFLOW.md`, `scripts/knowme_task_gate.ps1` |

**Also complete (supporting):**

- Narrative V3 selection, V4 plan topology (`docs/NARRATIVE_INTELLIGENCE_SELECTION_V3.md`, `docs/NARRATIVE_PLAN_TOPOLOGY_V4.md`)
- Synthetic population validation V1–V3 (`docs/SYNTHETIC_HUMAN_POPULATION_V1.md`, `docs/SYNTHETIC_POPULATION_V2_1000_REPORT.md`)
- Real User Runtime Validation V1 (`docs/REAL_USER_RUNTIME_VALIDATION_V1.md`)
- Thai Astrology Consumer Report evolution V3→V8 — long-form narrative (V3–V5), article-style result page (V4), evidence-combination personalization (V7), and the Life Timeline / life-period engine (V8). See `docs/EXECUTIVE_SUMMARY.md`.
- Repository Survival V1 — architecture snapshot pushed to GitHub

---

## Current Focus

**Convert astrology-complete users into personality-test completers.**

Real users (38 Firestore accounts): **2.6% reach Narrative**. Blocker is personality test completion, not narrative engine failure.

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
| Hosting source vs `main` | **Low** | Public hosting last deployed from `main` @ `a6874f5` (2026-07-21); still **manual** only (`scripts/deploy_web.ps1`), no auto-deploy |
| Real user PII export local-only | **High** | `firestore_user_export.json` gitignored — must regenerate locally |
| Firebase service account local-only | **High** | `backend/firebase/serviceAccountKey.json` gitignored |
| Legacy + new architecture coexist | **Medium** | Parallel scoring, navigation, and module IDs — trace before editing |
| Funnel Recovery V2 unvalidated in production | **Medium** | Implemented and on GitHub; conversion metrics not yet measured post-deploy |

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
| Hosting source vs `main` | Low | Last public deploy from `main` @ `a6874f5` (manual); no auto-deploy | Keep using `scripts/deploy_web.ps1` for intentional releases |
| Real user PII export local-only | High | `firestore_user_export.json` gitignored | Regenerate locally |
| Firebase service account local-only | High | `backend/firebase/serviceAccountKey.json` gitignored | Never commit |

---

## Deployment

| Item | Value |
|------|-------|
| **Status** | Public beta live on Firebase Hosting (June 2026) |
| **Primary URL** | https://knowme-app-694e1.web.app |
| **Firebase project** | `knowme-app-694e1` |
| **Branch deployed from** | `main` @ `a6874f5` (2026-07-21); still **manual** deploy only — no auto-deploy |
| **Full guide** | [`docs/DEPLOYMENT.md`](DEPLOYMENT.md) |

Deploy: `.\scripts\deploy_web.ps1` or `firebase deploy --only hosting --project knowme-app-694e1`

**Governance / freeze detail:** [`docs/GOVERNANCE.md`](GOVERNANCE.md)

## Next Priority

0. **Invited-Beta production UI re-check (operator)** — agent deploy verified bundle/flag/gates; interactive invited narrative/badge needs seeded invite UID + credentials (allow-list not changed by deploy task).
1. **Deploy / measure Funnel Recovery V2** — track `funnel_telemetry` for MBTI adoption and narrative reach (target: 2.6% → 25%+ narrative reach on active users).
2. **Keep hosting deploys intentional** — continue `scripts/deploy_web.ps1` from `main` when releasing; no auto-deploy.
3. **Maintain frozen systems** — blocker fixes only on Fusion V1 UI, BaZi V1, Thai V2, MBTI Summary.
4. **Re-run real-user validation** after funnel changes — compare against `real_user_runtime_validation_v1.json` baseline.

**Not next (explicitly deferred per master context):**

- AI narrative layer
- Astrology fusion redesign
- Big Five as primary funnel path (MBTI mini is the recovery path)
- Architecture rewrites
