# KnowMe Developer Handoff

**Purpose:** How a new developer continues the KnowMe project.  
**Last updated:** August 3, 2026
**Start here after reading:** [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md) and [`CURRENT_STATUS.md`](CURRENT_STATUS.md)

---

## 1. Repository Setup

### Clone and branch

```bash
git clone https://github.com/notekmitl/knowme.git
cd knowme
git checkout main
```

**Important:** `main` is canonical. Human-Readable Core Reading V1.1 shipped in
PR #67, birth-hour state was fixed in PR #68/#69, and public LEVEL 1 badges
shipped in PR #70 with the public-identifier redaction hotfix in PR #71.
Human Readability V2 shipped through PR #75, Production hardening PR #76, and
the evidence-backed Closing fallback PR #77. Production Hosting `eb1f1c8` was
verified on 2026-08-03. Anonymous
users open `/beta/thai` without login or a seeded UID; eligible reports show
compact public-safe evidence details. V1.3.5 detailed evidence stays internal.

**Automation workflow:** Use Single-Agent + Local Gate — see [`KNOWME_SINGLE_AGENT_WORKFLOW.md`](KNOWME_SINGLE_AGENT_WORKFLOW.md). The external AI Worker is **retired** (historical: [`AI_WORKER_OPERATION.md`](AI_WORKER_OPERATION.md)). The obsolete in-repo `ai-worker/` directory is gitignored and must not be committed.

### Flutter setup

```bash
flutter pub get
flutter run
```

### Firebase credentials (local only — never commit)

| File | Purpose |
|------|---------|
| `backend/firebase/serviceAccountKey.json` | Firestore export scripts, admin operations |
| `lib/firebase_options.dart` | Already in repo — Flutter Firebase config |

Place `serviceAccountKey.json` at the path above. It is gitignored by `backend/.gitignore`.

### Optional: regenerate real-user export

```bash
python test/validation/real_user_runtime_v1/export/firestore_user_export.py
dart run test/validation/real_user_runtime_v1/analysis/real_user_runtime_validation_v1_runner.dart
```

Output: `test/validation/real_user_runtime_v1/output/` (export JSON is gitignored — contains PII).

### IDE

`.vscode/launch.json` is in repo with standard Flutter launch configs.

---

## 2. Branch Strategy

| Branch | Role |
|--------|------|
| `main` | Canonical integration and release branch |
| `feature/fusion-result` | Historical architecture snapshot; not the base for new work |
| `feature/connect-test-flow` | Historical test-flow branch |

**Workflow:**

1. Fetch and verify `origin/main`, then create one `codex/*` branch/worktree for the task.
2. Define `task.md` and `task_scope.json`; keep commits and allow-list focused.
3. Run Local Gate PreCommit and PostCommit plus relevant validation.
4. Merge to `main` only when release-ready, then sync local `main`.

### Thai Beta anonymous operations

- Public anonymous entry: `https://knowme-app-694e1.web.app/beta/thai`.
- Do not request login, credentials, Firebase invite seeding, or a seeded UID for the anonymous flow.
- Evidence Badge is controlled by `public_beta`; visibility depends only on the rollout flag and eligible LEVEL 1 report evidence, not Auth, UID, admin status, or invite membership.
- PR #61 fixed route preservation/reload (`981ed04`, merge `da85013`, Production bundle `da85013`).
- The anonymous Production validation and route/reload incident are closed. Reopen only with a reproducible regression.

### Thai Birth Profile Human-Readable Core Reading V1

- `/beta/thai` presents the existing lifelong evidence as six continuous
  reader-facing narrative sections plus a collapsed
  “ดวงนี้วิเคราะห์จากอะไร” disclosure.
- The old eight-card structure and repeated system labels are retired.
- “จากพื้นดวงสู่จังหวะชีวิต” visibly separates Core Reading from the
  unchanged Timeline.
- Web and PDF use the same deterministic
  `ThaiBirthProfileCoreReading.fromAnalysis` output.
- Birth Normalization, Thai Engine, Frozen Canon, Timeline, feedback, Auth,
  Firebase data/rules, and audience are unchanged.
- Production validation passed for full-time/no-time Web, real PDF parity,
  public-safe LEVEL 1 badges, Timeline placement, and zero related console
  errors. Interpretive accuracy remains an owner/tester judgment.

### Thai Beta Human Readability V2 release

- PR #75 (`ce96440`, merge `a30a114`) shipped the reader-facing composition,
  typography, current-period focus, date clarification, and compact evidence UI.
- Production PDF validation exposed two remaining presentation gaps. PR #76
  (`7d3e0e2`, merge `59e140e`) removed the public `Canon` label, separated
  Personal Core from domain copy, and made Closing one Strength → Risk → Action
  context. PR #77 (`dccd103`, merge `eb1f1c8`) added a computed-fact fallback
  when ranked themes have no supported Closing copy.
- Hosting deploy to `knowme-app-694e1` completed on 2026-08-03. Production smoke
  testing passed known-time/no-time, Desktop/Mobile, Evidence once, Timeline
  placement, no internal labels, and real 8-page Web/PDF semantic parity.
- This closes product readability hardening only. Do not claim statistical or
  astrological accuracy, and do not describe the 10-person cohort as started.

### Production funnel measurement

Production Funnel Measurement V1 is read-only and reports aggregates only:

```powershell
python tool/production_funnel_measurement.py --start 2026-06-23 --end 2026-07-28
```

The local gitignored service account is required. Never commit its credential or
raw user export. Current result: eligible 4 → MBTI started 2 → completed 1 →
Narrative preview 1; decision **IMPROVE**, confidence limited by sample size.
Definitions and denominator rules: [`PRODUCTION_FUNNEL_MEASUREMENT_V1.md`](PRODUCTION_FUNNEL_MEASUREMENT_V1.md).

### Current product priority — Thai Birth Profile Core Reading

`/beta/thai` must lead with **“ดวงจากวันเกิดของคุณ”** before Life Timeline.
Web and PDF build that section from the same `ThaiBetaAnalysis`; do not create
parallel calculations or copy real user birth data into fixtures. With no birth
time, Lagna/houses must remain absent. See
[`THAI_BIRTH_PROFILE_CORE_READING_V1.md`](THAI_BIRTH_PROFILE_CORE_READING_V1.md).
V1.1 owns evidence per structured paragraph, rejects near-duplicate claims, and
renders the lifelong Core once before Timeline/current/future. It is released
and verified in Production. Standalone Thai Mirror behavior remains the
default; do not restore its legacy lifelong blocks inside Thai Beta Web or PDF.

Thai Astrology quality and real-person Product Acceptance are current. Preserve
Funnel history, but do not route the next implementation to MBTI/Funnel,
Chinese, Western, or Fusion until the owner changes this priority.

---

## 3. Where to Start

### Understand the product (30 min)

1. [`docs/KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md) — vision, philosophy, subsystems
2. [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) — pipeline layers
3. [`docs/CURRENT_STATUS.md`](CURRENT_STATUS.md) — what's done and what's active

### Understand the app flow (15 min)

```
lib/main.dart
  → AuthGate
  → ProfileGate
  → HomePage (Home V3)
```

Key pages:

| Page | Path |
|------|------|
| Home | `lib/presentation/pages/home/home_page.dart` |
| Profile setup | `lib/presentation/pages/profile/profile_setup_page.dart` |
| Edit profile | `lib/presentation/pages/profile/edit_profile_page_v1.dart` |
| MBTI mini test | `lib/features/tests/mbti/presentation/mbti_mini_test_page.dart` |
| BaZi result | `lib/presentation/pages/bazi/bazi_result_page.dart` |

### Understand the runtime pipeline (30 min)

Read in order:

1. `lib/features/narrative_runtime/integration/user_runtime_pipeline_service.dart`
2. `lib/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart`
3. `lib/features/global_fusion/v2/builder/global_fusion_runtime_builder.dart`
4. `lib/features/human_pattern/builder/human_pattern_snapshot_builder.dart`
5. `lib/features/narrative_runtime/service/narrative_runtime_service.dart`
6. `lib/features/home_cohesion/application/home_v3_loader.dart`

### Pick a work area

| If you are working on… | Start in… |
|------------------------|-----------|
| Home / funnel | `lib/features/home_cohesion/` |
| Narrative copy/selection | `lib/features/narrative_runtime/` |
| Pattern activation | `lib/features/human_pattern/` |
| Fusion recovery | `lib/features/global_fusion/v2/` |
| Mirror engines | `lib/features/mirror_v3/` |
| Thai astrology | `lib/features/astrology/thai/` |
| Personality tests | `lib/features/tests/` |
| Validation | `test/validation/` |

---

## 4. Validation Workflow

### Before changing an engine layer

1. Identify which validation runner covers your layer.
2. Run the runner **before and after** your change.
3. Compare JSON output in `test/validation/*/output/`.
4. Do not claim PASS without running the relevant gate.

### Key validation commands

```bash
# Full synthetic pipeline (1000 humans, V3)
dart run test/validation/synthetic_population_v3/pipeline/synthetic_human_pipeline_runner_v3.dart

# GF2 production gate
dart run test/validation/synthetic_population_v3/analysis/gf2_production_validation_v1_runner.dart

# Narrative V5 gate
dart run test/validation/synthetic_population_v3/analysis/narrative_evidence_branching_v5_runner.dart

# Human Pattern activation recovery
dart run test/validation/synthetic_population_v3/analysis/activation_recovery_v2_runner.dart
flutter test test/human_pattern/pattern_activation_recovery_test.dart

# Human Pattern dead-zone audit
dart run test/validation/human_pattern_activation_audit/human_pattern_activation_audit_runner.dart

# Real user funnel audit (requires Firestore export)
dart run test/validation/real_user_runtime_v1/analysis/real_user_runtime_validation_v1_runner.dart

# Home UI tests
flutter test test/home_screen_v3_test.dart
```

### Validation output locations

| Runner family | Output |
|---------------|--------|
| `synthetic_population_v3/output/` | GF2, narrative V3–V5, activation recovery JSON |
| `real_user_runtime_v1/output/` | Real user funnel + validation (export gitignored) |
| `human_pattern_activation_audit/output/` | Pattern activation audit |

---

## 4.1 Codex Automation (Single-Agent + Local Gate)

For scoped Codex tasks (not manual dev work), use the authoritative workflow in [`KNOWME_SINGLE_AGENT_WORKFLOW.md`](KNOWME_SINGLE_AGENT_WORKFLOW.md). Codex is the only executor for a task branch/worktree; do not allow Cursor, Claude Code, or another agent to edit that same branch/worktree concurrently.

1. Prepare `task.md` and `task_scope.json` on the target branch/worktree.
2. Give Codex [`STANDARD_CODEX_AGENT_PROMPT.md`](STANDARD_CODEX_AGENT_PROMPT.md) once per task when the task prompt does not already contain equivalent controls.
3. Agent runs PreCommit Gate → commit → PostCommit Gate → writes `TASK_RESULT.md`.
4. Read `TASK_RESULT.md` for the final outcome.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PreCommit
powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PostCommit
```

The external AI Worker and OpenAI reviewer loop are **retired** (historical: [`AI_WORKER_OPERATION.md`](AI_WORKER_OPERATION.md)).

---

## 5. Important Rules

### Do

- **Trace before editing** — follow caller chain, Firestore paths, providers.
- **Prefer minimal safe changes** — small diffs, no unnecessary rewrites.
- **Reuse existing services** — QuestionService, ScoringRouter, PersonalityLensLoader, existing loaders.
- **Preserve production flow** — AuthGate → ProfileGate → HomePage.
- **Protect secrets** — never commit `serviceAccountKey.json`, `.env`, or Firestore user exports.
- **Run validation** for any engine-layer change.
- **Check frozen status** — [`GOVERNANCE.md`](GOVERNANCE.md) before modifying Fusion V1 UI, BaZi V1, Thai V2 core, MBTI Summary

### Do not

- **Refactor architecture** without explicit program approval.
- **Create duplicate systems** — inspect existing services first.
- **Assume module ID consistency** — legacy and new IDs may differ.
- **Push PII** — real user exports stay local.
- **Polish frozen systems** without asking: *Does this improve user understanding?*
- **Bypass pipeline layers** — Human Model must consume fusion; Narrative must consume patterns.

### Priority order (from master context)

```
Stability > Correctness > Architecture purity > Speed
```

---

## 6. What Not to Change

| System | Reason |
|--------|--------|
| Fusion Result V1 presentation | Frozen v1 — see [`FUSION_RESULT_V1_SPEC.md`](FUSION_RESULT_V1_SPEC.md) |
| GF1 / MV1 core gates | Conditional freeze — use GF2/MV2 recovery instead of weakening gates |
| Thai Theme Resolver / Engine / Presenter | Existing pipeline — read-only in Thai Mirror spec |
| `backend/firebase/serviceAccountKey.json` | Secret — local only |
| `.gitignore` rules for PII exports | Repository survival protection |

**Exception programs (allowed additive work):**

- Chinese Zodiac Personality Expansion — content library only, not BaZi core rewrite
- Funnel Recovery — Home cohesion + telemetry (active)

---

## 7. Firestore Quick Reference

**Full semantics:** [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md) — `tests/*` vs `results/*`, legacy compatibility, MBTI contracts.

| Path | Content |
|------|---------|
| `users/{uid}/profile/main` | Birth profile (name, date, time, place, coords) |
| `users/{uid}/tests/mbti_mini` | MBTI session/progress (**not** fusion input) |
| `users/{uid}/results/mbti*` | MBTI deterministic snapshots (**fusion input**) |
| `users/{uid}/results/eq*` | EQ module results |
| `users/{uid}/results/big_five*` | Big Five results |
| `users/{uid}/astrology/western_natal` | Western chart |
| `users/{uid}/astrology/chinese_bazi` | BaZi chart (**UI source of truth**) |
| `users/{uid}/funnel_telemetry/*` | Funnel Recovery V2 events |

BaZi UI reads `astrology/chinese_bazi` — **not** `results/chinese_bazi`.

---

## 8. Routing Rules

Routing is **hybrid** — legacy and feature-specific routes coexist. **Do not aggressively unify.**

| System | Route helper | Entry page | Notes |
|--------|--------------|------------|-------|
| MBTI Progressive | `MbtiRoutes.miniTestRoute()` | `MbtiMiniTestPage` | Still named `mini` for backward compatibility — **do not rename casually** |
| MBTI Cognitive | `MbtiCognitiveRoutes` | `MbtiCognitiveTestPage` | Dedicated route |
| MBTI Summary | `MbtiSummaryRoutes` | `MbtiSummaryFusionPage` | Dedicated route |
| Universal tests | — | `UniversalTestPage` | Legacy — still active for simple quizzes |

**Production app flow:**

```
main.dart → AuthGate → ProfileGate → HomePage
```

**When to use UniversalTestPage vs feature architecture:** see [`MBTI_ARCHITECTURE.md`](MBTI_ARCHITECTURE.md) and §Code Organization in [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## 9. Naming Conventions

| Area | Convention | Example |
|------|------------|---------|
| Route classes | `FeatureRoutes` | `MbtiRoutes`, `MbtiCognitiveRoutes` |
| Feature folders | `snake_case` | `mbti_summary` |
| Models | `FeatureResult`, `FeatureSessionState` | `MbtiResultSummary`, `MbtiMiniSessionState` |
| Widgets | `FeatureSpecificWidget` | `MbtiResultHero`, `MbtiSummarySectionCard` |
| AppText keys | `feature_context_action` | `mbti_result_progress_title`, `fusion_v11_*` |

Avoid: `Widget1`, `title1`, `mbtiSummary` (camelCase folders).

---

## 10. AI Agent Workflow

### Roles

| Tool | Role |
|------|------|
| ChatGPT (or similar) | Product architect, UX critic, system designer, strategy |
| Codex | Sole implementation executor, code execution, focused diffs, validation, commit/push when explicitly authorized |

**Pattern:** design/review → implement in Codex → validate → iterate. One task uses one Codex-owned branch/worktree; Cursor, Claude Code, and other agents must not edit it concurrently. Avoid blind implementation without tracing callers.

### Expected change report

After non-trivial edits, report:

1. Files changed
2. Behavior changes
3. Architecture impact
4. Blast radius
5. Validation run (if engine layer)

### Collaboration rules

- Challenge assumptions — detect architectural risk, prevent fantasy engineering
- Prefer: *this works because… / risk is… / better option is…*
- Do not blindly agree or validate without evidence

### Anti-patterns

| Never | Prefer |
|-------|--------|
| Giant rewrite of working systems | Additive folder, presentation-only change |
| Premature mega-framework abstraction | Duplication until pattern repeats |
| Rename core routes casually | Keep `mini` naming for MBTI backward compat |
| Fusion reads `tests/*` | Fusion reads `results/*` |
| Bypass pipeline layers | HM consumes fusion; Narrative consumes patterns |
| Polish frozen systems without product reason | Blocker fixes only — see [`GOVERNANCE.md`](GOVERNANCE.md) |

### Priority order

```
Stability > Correctness > Architecture purity > Speed
```

---

## 11. Documentation Map

| Need | Read |
|------|------|
| Product vision + rules | `docs/KNOWME_MASTER_CONTEXT.md` |
| What's done now + deployment | `docs/CURRENT_STATUS.md` |
| Pipeline + code organization | `docs/ARCHITECTURE.md` |
| What's next (evidence-based) | `docs/ROADMAP.md` |
| Freeze registry | `docs/GOVERNANCE.md` |
| Firestore semantics | `docs/FIRESTORE_SCHEMA.md` |
| MBTI architecture | `docs/MBTI_ARCHITECTURE.md` |
| Fusion V1 frozen UI spec | `docs/FUSION_RESULT_V1_SPEC.md` |
| Public deploy | `docs/DEPLOYMENT.md` |
| GF2 implementation detail | `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md` |
| Narrative V5 proof | `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` |
| Real user funnel data | `docs/REAL_USER_RUNTIME_VALIDATION_V1.md` |
| Deep spec per domain | Other `docs/*.md` validation and spec files |

---

## 12. Getting Help from the Codebase

When debugging "why doesn't narrative appear for this user?":

1. Check profile exists: `users/{uid}/profile/main`
2. Check personality lens: at least one of MBTI / Big Five / EQ in `results/`
3. Trace `UserRuntimePipelineService.loadNarrativeForUser` — returns `null` if birth data missing, no personality lenses, or empty pattern activations
4. Compare with real-user validation failure audit in `real_user_runtime_validation_v1.json`

When debugging Home display:

1. `HomeV3Loader.load(uid)` → bundle + narrative
2. `HomeV3Assembler.fromSources` → unlock hero, completion bar, preview flags
3. `HomeProfileCompletion.fromCoverage` → progress percentages

---

## 13. First Task Suggestions

For a new developer joining today:

1. Run the app on `feature/fusion-result`, complete profile, observe Home V3.
2. Run `flutter test test/home_screen_v3_test.dart`.
3. Read `REAL_USER_RUNTIME_VALIDATION_V1.md` — understand the 2.6% narrative reach problem.
4. Pick up funnel telemetry analysis or a scoped Home cohesion fix — **do not start with architecture rewrites**.
