# Thai Life Map V1.2.8 — Verdict Narrative

**Status:** Merged + Production hosted @ `4b42f95` (PR #40)  
**Scope:** Past Verdict / Current Reality / Future Forecast copy tone  
**Non-goals:** Canon, formulas, Mahabhut resolution, period math, Past/Current/Future classification, Firestore, Auth, Evidence Badge, Unified Synthesis

## Narrative contract

| Bucket | Structure | Must not |
|--------|-----------|----------|
| **Past Verdict** | เหตุการณ์/การเปลี่ยนแปลง → ผลกระทบต่อชีวิต | retrospective prompts, coaching, hedges |
| **Current Reality** | สภาพจริง → แรงกดดัน/ความขัดแย้ง → ผลต่อชีวิต | generic advice, hedges |
| **Future Forecast** | ทิศทาง/เหตุการณ์หลัก → ด้านชีวิต → ผลลัพธ์ | invented catastrophe, heavy hedges |

Banned primary-body hedges (see `LifeMapVerdictCopy`): `อาจ`, `น่าจะ`, `มีแนวโน้ม`, `เป็นไปได้ว่า`, `ในบางคน`, plus coaching prompts (`ลองนึกย้อน`, …) and unsupported catastrophic claims.

## Implementation map

| Layer | Path |
|-------|------|
| Policy | `life_map_verdict_copy.dart` |
| Past | `past_retrospective_composer.dart` |
| Present/Future period cards | `period_narrative_composer.dart` |
| Current-age / next-period intelligence copy | `period_intelligence_composer.dart` |
| UI labels | `thai_mirror_life_timeline_section.dart` (`สิ่งที่ผ่านมา`, `แรงกดดันและความขัดแย้ง`, `ผลต่อชีวิต…`) |
| Tests | `test/.../v128/thai_life_map_v128_verdict_narrative_test.dart` + v127 matrix policy checks |

## Synthetic QA samples (production path, no PII)

Fixture: Friday birth weekday, age 42, lagna sun, seed 17 via `TimelinePresenter`.

**After (V1.2.8) — Current summary:**  
`ขณะนี้ในวัยทำงานเป็นช่วงดูแลใจ ซึ่ง… งาน ความมั่นคง และสมดุลชีวิตเป็นแรงกดดันหลักที่ต้องจัดระเบียบ`

**After — Current pressure / impact:**  
`แรงกดดันหลักคือการรับทุกโอกาสไว้จนโฟกัสกระจาย` / `สิ่งที่ถูกบังคับให้ชัดคือสมดุลงาน การเงิน และสุขภาพภายใต้ภาระจริง`

**Before (main V1.2.7 intelligence tendency copy, illustrative):**  
`ช่วงนี้มีแนวโน้มท้าทายนิสัยเดิม…` / `บางจังหวะอาจรู้สึกต้องปรับตัว…` / `สิ่งที่คุณสร้างตอนนี้มักอยู่กับคุณไปนาน`

**Before (main period UI labels):** `สิ่งที่น่าจะผ่านมา`, `สิ่งที่ควรระวัง`, `คำแนะนำสำหรับช่วงนี้`

## Unresolved evidence

Mahabhut all-or-nothing hide policy unchanged: unresolved positions are not shown and do not drive period prose. Narrative banks only use resolved planet affinity/scores/keyword/essence already on the period.

## Validation

- Focused v128 + v126 + timeline UI + v123 acceptance + v125 invited beta
- V1.2.7 production-path matrix: **864 executed, 0 skipped, 864 passed** (with verdict policy checks on past/current/future bodies)
- Local Gate PreCommit/PostCommit PASS
- Production web build + Hosting deploy from merged `main` @ `4b42f95` (`main.dart.js?v=4b42f95` verified)
- Light Production QA: anonymous `/beta/thai` landing loads on hosted runtime; full interactive Life Map scroll limited by Flutter web a11y in automation — narrative contract covered by automated production-path tests
