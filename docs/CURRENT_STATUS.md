# KnowMe Current Status

**Last updated:** June 2026  
**Branch:** `feature/fusion-result` @ `780a4c1` (Architecture Snapshot V1 on GitHub)  
**Tracked files:** 1,534

---

## Completed Programs

| Program | Status | Evidence |
|---------|--------|----------|
| **Thai Mirror (engine + structural)** | Production structural ready | `docs/THAI_MIRROR_SPECIFICATION_V1.md`, `lib/features/astrology/thai/mirror/` |
| **Thai Consumer Report (V3–V8)** | Production deployed | `docs/EXECUTIVE_SUMMARY.md`, consumer presenter + result page, evidence narrative (V7), Life Timeline (V8) |
| **Thai Life Timeline Intelligence (V9)** | Implemented (engine + presentation, tests + gates pass) | `docs/THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md` — planet relationship engine, per-period intelligence, current-age analysis, future-period preview (evidence only) |
| **Thai Astrology QA Harness V1** | Implemented | `docs/ASTROLOGY_QA_HARNESS_V1.md` — preview route, profiles A–H, screenshot regression + story coverage CI |
| **GF2** | Implemented + validated | `docs/GF2_PRODUCTION_IMPLEMENTATION_V1.md`, 1000-human gate PASS |
| **Human Model** | Implemented | `lib/features/human_model/`, synthetic pipeline validated |
| **Human Pattern** | Recovery V2 complete | `docs/HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md` — 9/20 dead patterns recovered |
| **Narrative V5** | Complete | `docs/NARRATIVE_EVIDENCE_BRANCHING_V5.md` — 1000/1000 unique, 0 collapse |
| **Funnel Recovery V2** | Implemented | `lib/features/home_cohesion/`, `lib/features/funnel_telemetry/`, MBTI → narrative preview loop |

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
| `origin/main` behind feature branch | **High** | `main` has 357 tracked files vs 1,534 on `feature/fusion-result` |
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
| `origin/main` behind feature branch | High | 357 vs 1,534 tracked files | Merge when release-ready |
| Real user PII export local-only | High | `firestore_user_export.json` gitignored | Regenerate locally |
| Firebase service account local-only | High | `backend/firebase/serviceAccountKey.json` gitignored | Never commit |

---

## Deployment

| Item | Value |
|------|-------|
| **Status** | Public beta live on Firebase Hosting (June 2026) |
| **Primary URL** | https://knowme-app-694e1.web.app |
| **Firebase project** | `knowme-app-694e1` |
| **Branch deployed from** | `feature/fusion-result` |
| **Full guide** | [`docs/DEPLOYMENT.md`](DEPLOYMENT.md) |

Deploy: `.\scripts\deploy_web.ps1` or `firebase deploy --only hosting --project knowme-app-694e1`

**Governance / freeze detail:** [`docs/GOVERNANCE.md`](GOVERNANCE.md)

## Next Priority

1. **Deploy / measure Funnel Recovery V2** — track `funnel_telemetry` for MBTI adoption and narrative reach (target: 2.6% → 25%+ narrative reach on active users).
2. **Merge `feature/fusion-result` → `main`** when release-ready — recovery from `main` alone is insufficient today.
3. **Maintain frozen systems** — blocker fixes only on Fusion V1 UI, BaZi V1, Thai V2, MBTI Summary.
4. **Re-run real-user validation** after funnel changes — compare against `real_user_runtime_validation_v1.json` baseline.

**Not next (explicitly deferred per master context):**

- AI narrative layer
- Astrology fusion redesign
- Big Five as primary funnel path (MBTI mini is the recovery path)
- Architecture rewrites
