# KnowMe Developer Handoff

**Purpose:** How a new developer continues the KnowMe project.  
**Last updated:** June 2026  
**Start here after reading:** [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md) and [`CURRENT_STATUS.md`](CURRENT_STATUS.md)

---

## 1. Repository Setup

### Clone and branch

```bash
git clone https://github.com/notekmitl/knowme.git
cd knowme
git checkout feature/fusion-result
```

**Important:** `main` (357 files) is far behind `feature/fusion-result` (1,534 files). All architecture work lives on the feature branch until merged.

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
| `feature/fusion-result` | **Active development** — full architecture snapshot |
| `main` | Legacy baseline — do not assume it contains Mirror/GF2/Narrative/Home V3 |
| `feature/connect-test-flow` | Older test-flow branch |

**Workflow:**

1. Branch from `feature/fusion-result` for new work.
2. Small commits, focused scope.
3. Run relevant validation before claiming engine changes.
4. Merge to `main` only when release-ready.

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

## 5. Important Rules

### Do

- **Trace before editing** — follow caller chain, Firestore paths, providers.
- **Prefer minimal safe changes** — small diffs, no unnecessary rewrites.
- **Reuse existing services** — QuestionService, ScoringRouter, PersonalityLensLoader, existing loaders.
- **Preserve production flow** — AuthGate → ProfileGate → HomePage.
- **Protect secrets** — never commit `serviceAccountKey.json`, `.env`, or Firestore user exports.
- **Run validation** for any engine-layer change.
- **Check frozen status** before modifying Fusion V1 UI, BaZi V1, Thai V2 core, MBTI Summary.

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
| Fusion Result V1 presentation | Frozen v1 — maintenance only |
| GF1 / MV1 core gates | Conditional freeze — use GF2/MV2 recovery instead of weakening gates |
| Thai Theme Resolver / Engine / Presenter | Existing pipeline — read-only in Thai Mirror spec |
| `backend/firebase/serviceAccountKey.json` | Secret — local only |
| `.gitignore` rules for PII exports | Repository survival protection |

**Exception programs (allowed additive work):**

- Chinese Zodiac Personality Expansion — content library only, not BaZi core rewrite
- Funnel Recovery — Home cohesion + telemetry (active)

---

## 7. Firestore Quick Reference

| Path | Content |
|------|---------|
| `users/{uid}/profile/main` | Birth profile (name, date, time, place, coords) |
| `users/{uid}/results/mbti*` | MBTI test results |
| `users/{uid}/results/eq*` | EQ module results |
| `users/{uid}/results/big_five*` | Big Five results |
| `users/{uid}/astrology/western_natal` | Western chart |
| `users/{uid}/astrology/chinese_bazi` | BaZi chart (**UI source of truth**) |
| `users/{uid}/funnel_telemetry/*` | Funnel Recovery V2 events |

BaZi UI reads `astrology/chinese_bazi` — **not** `results/chinese_bazi`.

---

## 8. Documentation Map

| Need | Read |
|------|------|
| Product vision + rules | `docs/KNOWME_MASTER_CONTEXT.md` |
| What's done now | `docs/CURRENT_STATUS.md` |
| Pipeline architecture | `docs/ARCHITECTURE.md` |
| What's next (evidence-based) | `docs/ROADMAP.md` |
| GF2 implementation detail | `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md` |
| Narrative V5 proof | `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` |
| Real user funnel data | `docs/REAL_USER_RUNTIME_VALIDATION_V1.md` |
| Full historical context | `KNOWME MASTER CONTEXT vNEXT (FULL STRUCTURED v2).txt` (repo root) |
| Deep spec per domain | Other `docs/*.md` validation and spec files |

---

## 9. Getting Help from the Codebase

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

## 10. First Task Suggestions

For a new developer joining today:

1. Run the app on `feature/fusion-result`, complete profile, observe Home V3.
2. Run `flutter test test/home_screen_v3_test.dart`.
3. Read `REAL_USER_RUNTIME_VALIDATION_V1.md` — understand the 2.6% narrative reach problem.
4. Pick up funnel telemetry analysis or a scoped Home cohesion fix — **do not start with architecture rewrites**.
