# Thai Life Map V1.2.6 — Narrative Clarity & Life-stage UX

**Status:** **Ready for Invited Beta Validation**  
**Not:** Validation Passed (real invited-user Life Map Feedback count still **0**)  
**Narrative UX merge:** PR #25 → `ab093ad` (feature `639c76c`)  
**Age-boundary closure merge:** PR #27 → `f3409de` (fix `4fc4d51`)  
**Production deploy:** Firebase `knowme-app-694e1` from `main` @ `e16ad14` (2026-07-24; includes PR #27)  
**Public URL:** https://knowme-app-694e1.web.app/beta/thai?v=e16ad14

## Problem (pre-fix)

User-facing Life Map period detail was hard to use:

- Unnatural Thai fragments (e.g. “คิดรอบก่อนตอบ”)
- Adult career/money/romance framing on childhood periods
- Score charts (0–100) without clear user action
- Raw nested ดาวแทรก / ทักษาจร lists users cannot interpret
- Dense, duplicated detail that did not answer “what matters in this stage?”

### Follow-up defect (closed in PR #27)

A child inside a long astrology period (e.g. age **11** in window **11–29**) still received young-adult narrative when the band was derived from the period mid-age instead of the reader’s actual age.

## Root cause

Presentation reused one adult domain scaffold and exposed engine nested lists. Narrative composition used fragment-style copy without life-stage context. After V1.2.6 narrative banks landed, mid-age classification still mislabeled the **current** period for long windows. Calculation and Frozen Canon were not the defect.

## Architecture change (presentation only)

| Layer | Change |
|-------|--------|
| Calculation / Canon | **Unchanged** |
| Engine period windows | **Unchanged** |
| `ThaiLifeStageContext` | Presentation bands by age |
| `PeriodNarrativeComposer` | Complete Thai sentence banks; `narrativeAge` input |
| `TimelinePresenter` | Current period → actual `timeline.currentAge`; past → `endAge`; future → `startAge` |
| `ThaiMirrorLifeTimelineSection` | Detail: สรุป / เรื่องที่เด่น / สิ่งที่ควรระวัง / คำแนะนำหรือแนวทางส่งเสริม / ความเปลี่ยนแปลงจากช่วงก่อน; hide score grid + nested raw lists |
| Curated heroes | Fix broken “คิดรอบก่อนตอบ” phrasing |

## Life-stage bands (presentation only)

Inclusive age bands (do **not** alter engine boundaries):

| Band | Ages | Tone |
|------|------|------|
| earlyChildhood | 1–6 | Caregiver / development |
| schoolAge | 7–12 | Learning / peers / discipline |
| teen | 13–17 | Identity / boundaries |
| youngAdult | 18–29 | Early adult choices |
| workingAdult | 30–49 | Work / balance |
| midlife | 50–64 | Review / responsibility |
| elder | 65+ | Quality of life / dignity |

**Current period:** use actual user age. **Past/future periods:** use nearest boundary age of that window. Child-oriented bands remap engine career/money/romance domains before copy selection. Engine scores still computed for compatibility.

## Hidden from user-facing UI (retained internally)

- Period score grid / score explanation chrome
- Nested ดาวแทรก / ทักษาจร expanders
- Engine keys / debug identifiers in detail copy

Still computed in models for audit / future QA paths. Mahabhut position label remains when known (Canon-index path).

## Frozen Canon & formulas

- No edits under Canon knowledge packages
- No Mahabhut / life-period formula changes
- V1.2.4 Accuracy Audit suite green (expectations unchanged)

## Security & invited beta

| Role | Expected | Verified this round |
|------|----------|---------------------|
| Anonymous | Landing; no Evidence Badge; no invited feedback panel | Production browser `/beta/thai?v=e16ad14` |
| Normal signed-in | No invited panel | Automated V1.2.5 gating tests |
| Invited signed-in | Panel when allow-listed | Automated V1.2.5 tests only — **no live invited UID seeded** |
| Admin without invite | No invited user panel | Automated V1.2.5 tests |
| Evidence Badge | `invited_beta` | Deploy dart-define + bundle marker |
| Firestore rules | Unchanged | Deploy reported rules already up to date |

## Automated tests (evidence) — pre-deploy re-check before `e16ad14` hosting

| Suite | Result |
|-------|--------|
| Focused v126 + timeline UI | **14 passed** |
| Full Life Map regression + V1.2.1 narrative + Evidence Badge QA | **109 passed** |
| Analyze (timeline paths) | No issues |
| `flutter build web --release` via `scripts/deploy_web.ps1` | PASS |

## Browser / Visual QA — Production @ `e16ad14`

| Check | Result |
|-------|--------|
| Hosted `main.dart.js?v=e16ad14` | HTTP 200, `cache-control: no-cache, must-revalidate` |
| Bundle markers | `invited_beta`, `thai_life_map_beta_feedback_panel`, `thai_life_map_stage_label` |
| `/beta/thai?v=e16ad14` anonymous | Thai research landing; **no** Evidence Badge; **no** invited Life Map feedback panel |
| QA harness `/thai-mirror/consumer-preview?profile=A&age=11` mobile | Life Map shows “วันนี้ ในวัย 11 ปี…”; period window 11–29; no Evidence Badge / invited panel |
| Period-detail expand / score-grid absence | Covered by widget tests; **live expand click not fully automated** this round |
| Live invited / admin sessions | **Not executed** — no invite UIDs seeded |

## Feedback counts (at close)

| Metric | Value |
|--------|------:|
| Real invited users with Life Map Feedback (`thai_life_map_beta_feedback`) | **0** (unchanged; research landing “1 คน” is a separate path) |
| QA Life Map Feedback created this round | **None** |

## Validation status

**V1.2.6 Narrative and Life-stage UX deployed — Ready for Invited Beta Validation**

Do **not** treat as Validation Passed until ≥5 real invited users submit Life Map Feedback.

## Rollback

Redeploy prior Hosting SHA (`ab093ad` or earlier) via `scripts/deploy_web.ps1` from that commit. Rules unchanged — no rules rollback required for this release.

## Known limitations

- Production click-expand of every period card across ages 5/11/15/23/35/55/70 not fully browser-automated
- Invited-user / admin live panel not re-checked without seeded allow-list UID
- Score/sub-period engine data remains in models but is not user-visible in detail
