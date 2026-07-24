# Thai Life Map V1.2.6 — Narrative Clarity & Life-stage UX

**Status:** **Ready for Invited Beta Validation**  
**Not:** Validation Passed (real invited-user Life Map Feedback count still **0**)  
**Narrative UX merge:** PR #25 → `ab093ad` (feature `639c76c`)  
**Age-boundary closure merge:** PR #27 → `f3409de` (fix `4fc4d51`)  
**Time-bucket UX + Mahabhut UI omit:** PR #31 → `5bcabfa` (feature `21b93aa`)  
**Production deploy:** Firebase `knowme-app-694e1` from `main` @ `5bcabfa` (2026-07-24)  
**Public URL:** https://knowme-app-694e1.web.app/beta/thai?v=5bcabfa

## Time-bucket UX (PR #31)

Presentation density by period bucket (Canon 8 periods ages 1–108 unchanged):

| Bucket | UX |
|--------|-----|
| **Past** | Compact non-expandable card: name, age, planet, theme, confirmed Mahabhut only, 1–2 retrospective sentences under **สิ่งที่น่าจะผ่านมา**. No advice / caution / comparison / evidence footer. |
| **Present** | Highest priority; **expanded by default**; full detail; narrative age = actual user age. |
| **Future** | Collapsed with one-sentence preview (`อาจ` / `เมื่อถึง`); expand to full present-level detail. |

### Mahabhut display (presentation only)

| Layer | Behavior |
|-------|----------|
| Resolver + Frozen Canon | **Unchanged** — 1972-04-04 02:00 BKK remains **known=7 / unknown=1** (`AMBIGUOUS_ARCHETYPE_PLANET_PLACEMENT`) |
| Presenter | `mahabhutPositionLabel` = confirmed Thai name only; `mahabhutKnown` + `mahabhutUnknownReason` retained internally |
| User UI | Omit “ตำแหน่งมหาภูต” line when unresolved — **never** show “ยังยืนยันตำแหน่งไม่ได้” / “ยืนยันอันดับตำแหน่งไม่ได้” |
| Fallback | None invented; no user-specific hardcodes |

**Root cause of “many unresolved” UI copy:** presenter previously set `mahabhutPositionLabel` from `displayLabel`, which always surfaces the unknown Thai string. Resolver was already correct when Canon index is wired — not a Canon regression.

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

Still computed in models for audit / future QA paths. Mahabhut user label shows **only when Canon-confirmed**; unresolved reasons stay internal.

## Frozen Canon & formulas

- No edits under Canon knowledge packages
- No Mahabhut / life-period formula changes
- V1.2.4 Accuracy Audit suite green (expectations unchanged)

## Security & invited beta

| Role | Expected | Verified this round |
|------|----------|---------------------|
| Anonymous | Landing; no Evidence Badge; no invited feedback panel | Production browser `/beta/thai?v=5bcabfa` |
| Normal signed-in | No invited panel | Automated V1.2.5 gating tests |
| Invited signed-in | Panel when allow-listed | Automated V1.2.5 tests only — **no live invited UID seeded** |
| Admin without invite | No invited user panel | Automated V1.2.5 tests |
| Evidence Badge | `invited_beta` | Deploy dart-define + bundle marker |
| Firestore rules | Unchanged | Deploy reported rules already up to date |

## Automated tests (evidence) — PR #31 / deploy `5bcabfa`

| Suite | Result |
|-------|--------|
| Local Gate PreCommit + PostCommit | PASS |
| Focused time-bucket + narrative + Mahabhut + V1.2.3 UI + timeline widgets | **28 passed** |
| Broader (focused + V1.2.4 accuracy + V1.2.5 beta validation) | **57 passed** |
| Analyze (changed presentation paths) | No issues |
| `flutter build web --release` via `scripts/deploy_web.ps1` | PASS @ `5bcabfa` |

## Browser / Visual QA — Production @ `5bcabfa`

| Check | Result |
|-------|--------|
| Hosted `main.dart.js?v=5bcabfa` | HTTP 200, `cache-control: no-cache, must-revalidate` |
| Bundle markers | `invited_beta`, `thai_life_map_beta_feedback_panel`, `thai_life_map_stage_label`; past title escaped string present; unknown Mahabhut user strings **absent** |
| `/beta/thai?v=5bcabfa` anonymous | Thai research landing (“ดูดวงไทย — งานวิจัย”); **no** Evidence Badge; **no** invited Life Map feedback panel |
| QA harness `/thai-mirror/consumer-preview?profile=A&age=11` | Past compact + สิ่งที่น่าจะผ่านมา; current expanded with วัยเรียน / ผู้ปกครอง; future preview with `อาจ`/`เมื่อถึง`; **no** unknown Mahabhut copy |
| Mobile 390×844 | Viewport set; no horizontal overflow observed on hero/Life Map header |
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

Redeploy prior Hosting SHA (`e16ad14` or earlier) via `scripts/deploy_web.ps1` from that commit. Rules unchanged — no rules rollback required for this release.

## Known limitations

- Production click-expand of every future period across all ages not fully browser-automated this round
- Invited-user / admin live panel not re-checked without seeded allow-list UID
- Score/sub-period engine data remains in models but is not user-visible in detail
- One Canon-ambiguous period per some charts remains unresolved internally (e.g. 1972 fixture unknown=1) — UI omits the line rather than inventing a placement