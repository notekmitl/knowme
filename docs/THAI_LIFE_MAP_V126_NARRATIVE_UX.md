# Thai Life Map V1.2.6 — Narrative Clarity & Life-stage UX

**Status:** **Ready for Invited Beta Validation**  
**Not:** Validation Passed (real invited-user Life Map Feedback count still **0**)  
**Narrative UX merge:** PR #25 → `ab093ad` (feature `639c76c`)  
**Age-boundary closure merge:** PR #27 → `f3409de` (fix `4fc4d51`)  
**Time-bucket UX + Mahabhut UI omit:** PR #31 → `5bcabfa` (feature `21b93aa`)  
**Usability feedback (past density / theme / Mahabhut gate / accordion):** PR #33 → `c698c22` (feature `16257ea`)  
**Past life-breadth + prompt removal:** PR #35 → `399ac7a` (feature `65e2ec2`)  
**Past phase-label hygiene:** PR #36 → `5529264` (fix `7adc292`)  
**Production deploy:** Firebase `knowme-app-694e1` from `main` @ `5529264` (2026-07-24)  
**Public URL:** https://knowme-app-694e1.web.app/beta/thai?v=5529264

## Past life-breadth (PR #35 / #36)

| Change | Detail |
|--------|--------|
| Root cause | Age-band-only past banks + `_fitPastWordBudget` / closing pads reused school/homework vocabulary and “ลองนึกย้อน…” closers |
| New composer | `PastRetrospectiveComposer` selects 1–3 age-safe life facets from affinity, period scores, keyword/essence only |
| Structure | 2–3 short paragraphs (~90–160 approx Thai words): atmosphere → possible life experiences → inner effect (no advice) |
| Soft language | `อาจ` / `แนวโน้ม` / `ในบางคน` — no hardcode Saturn→ย้ายบ้าน; no fate claims |
| Prompt removal | No `ลองนึกย้อน` / `ลองทบทวน` / retrospective question endings on Past path |
| Hygiene (#36) | Strip leading `ช่วง` from `phaseName` to avoid `ช่วงช่วง…`; prefer childhood opening facet among selected evidence |

## Usability feedback (PR #33)

| Change | Detail |
|--------|--------|
| Past narrative | 2–3 short paragraphs (~90–160 approx Thai words); planet/phase/keyword/band-specific; soft language (`อาจ` / `แนวโน้ม`); no advice |
| Theme label | User copy `ธีมหลัก` → **เรื่องสำคัญของช่วงนี้** (Life Map UI only) |
| Mahabhut report gate | Resolve all 8 first; show name+description on **every** card only when all known **and** explainable; else hide all |
| Descriptions | Derived from approved Mahabhuta content mappings + Khumsap from ontology alias + p17 rise-set (presentation layer only) |
| Accordion | Removed `ซ่อนรายละเอียดช่วงชีวิต` from expanded content; arrow / card tap still toggles |

### Mahabhut fixtures

| Fixture | Resolver | User UI |
|---------|----------|---------|
| Sample QA | known **8** / unknown **0** | Show all 8 + descriptions |
| 1972-04-04 02:00 BKK | known **7** / unknown **1** | Hide Mahabhut on all cards; internal reasons retained |

## Time-bucket UX (PR #31)

Presentation density by period bucket (Canon 8 periods ages 1–108 unchanged):

| Bucket | UX |
|--------|-----|
| **Past** | Compact non-expandable card: name, age, planet, **เรื่องสำคัญของช่วงนี้**, Mahabhut when report-complete, denser **สิ่งที่น่าจะผ่านมา**. No advice / caution / comparison / evidence footer. |
| **Present** | Highest priority; **expanded by default**; full detail; narrative age = actual user age. |
| **Future** | Collapsed with one-sentence preview (`อาจ` / `เมื่อถึง`); expand to full present-level detail. |

### Mahabhut display (presentation only)

| Layer | Behavior |
|-------|----------|
| Resolver + Frozen Canon | **Unchanged** — 1972-04-04 02:00 BKK remains **known=7 / unknown=1** |
| Presenter | Report-level `mahabhutShownOnReport`; internal `mahabhutKnown` / `mahabhutUnknownReason` |
| User UI | All-or-none with descriptions; never show unresolved system copy |
| Fallback | None invented; no user-specific hardcodes |

**Root cause of “many unresolved” UI copy (PR #31):** presenter previously set `mahabhutPositionLabel` from `displayLabel`. **Follow-up (PR #33):** partial known display still felt broken — fixed with report-level consistency + explanations.

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

Still computed in models for audit / future QA paths. Mahabhut user surface is **report-complete only** (all 8 + descriptions); unresolved reasons stay internal.

## Frozen Canon & formulas

- No edits under Canon knowledge packages
- No Mahabhut / life-period formula changes
- V1.2.4 Accuracy Audit suite green (report-level UI expectations updated)

## Security & invited beta

| Role | Expected | Verified this round |
|------|----------|---------------------|
| Anonymous | Landing; no Evidence Badge; no invited feedback panel | Production browser `/beta/thai?v=5529264` |
| Normal signed-in | No invited panel | Automated V1.2.5 gating tests |
| Invited signed-in | Panel when allow-listed | Automated V1.2.5 tests only — **no live invited UID seeded** |
| Admin without invite | No invited user panel | Automated V1.2.5 tests |
| Evidence Badge | `invited_beta` | Deploy dart-define + bundle marker |
| Firestore rules | Unchanged | Deploy reported rules already up to date |

## Automated tests (evidence) — PR #35 / #36 / deploy `5529264`

| Suite | Result |
|-------|--------|
| Local Gate PreCommit + PostCommit | PASS (both feature PRs) |
| Life Map validation tree (`test/validation/thai_beta/life_map/`) | **68 passed** |
| Focused past-breadth suite | **4 passed** (+ time-bucket / narrative UX in gate) |
| Analyze (past + period composers) | No issues |
| `flutter build web --release` via `scripts/deploy_web.ps1` | PASS @ `5529264` |

## Browser / Visual QA — Production @ `5529264`

| Check | Result |
|-------|--------|
| Hosted `main.dart.js?v=5529264` | Deployed; cache-bust via `?v=5529264` |
| Bundle markers | `invited_beta` present; Past path no longer pads with `ลองนึกย้อน` |
| `/beta/thai?v=5529264` anonymous | Thai research landing; no Evidence Badge; no invited panel |
| Past narrative samples (same presenter path as Production) | Childhood home/family breadth; adult work/money when affinity supports; no retrospective prompts; no `ช่วงช่วง` after #36 |
| Interactive Form→Report canvas fill | **Limited** — Flutter TextField controllers do not reliably sync from browser automation (known); narrative verified via presenter path + landing/bundle checks |
| Live invited / admin sessions | **Not executed** — no invite UIDs seeded |

## Feedback counts (at close)

| Metric | Value |
|--------|------:|
| Real invited users with Life Map Feedback (`thai_life_map_beta_feedback`) | **0** (unchanged; research landing count is a separate path) |
| QA Life Map Feedback created this round | **None** |

## Validation status

**V1.2.6 Narrative and Life-stage UX deployed — Ready for Invited Beta Validation**

Do **not** treat as Validation Passed until ≥5 real invited users submit Life Map Feedback.

## Rollback

Redeploy prior Hosting SHA (`5bcabfa` or earlier) via `scripts/deploy_web.ps1` from that commit. Rules unchanged — no rules rollback required for this release.

## Known limitations

- Production click-expand of every future period across all ages not fully browser-automated this round
- Invited-user / admin live panel not re-checked without seeded allow-list UID
- Score/sub-period engine data remains in models but is not user-visible in detail
- Charts with any unresolved Mahabhut hide the section for the whole report (by design)
