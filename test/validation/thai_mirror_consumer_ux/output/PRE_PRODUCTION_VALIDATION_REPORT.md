# Thai Astrology Consumer UI — Pre-Production Validation Report

> **Superseded (June 2026):** A mid-June pre-production snapshot of the consumer UI
> *before* the Life Timeline (V8), evidence-driven narrative composer (V7), and the
> permanent QA harness. Its open items (shared dashboard fallbacks, single strength
> card, similar theme pairs, headline collisions, web QA blocked by AuthGate) have
> since been addressed by later work. Current references:
> [`docs/EXECUTIVE_SUMMARY.md`](../../../../docs/EXECUTIVE_SUMMARY.md) and
> [`docs/ASTROLOGY_QA_HARNESS_V1.md`](../../../../docs/ASTROLOGY_QA_HARNESS_V1.md).
> Retained as a historical validation record.

**Generated:** 2026-06-24  
**Scope:** Consumer presentation layer only (engine unchanged)  
**Artifacts:** `test/validation/thai_mirror_consumer_ux/screenshots/` (30 PNGs)  
**Machine report:** `consumer_ux_validation_report.json`

---

## Executive Summary

| Verdict | **NEEDS ANOTHER ITERATION** |
|---------|----------------------------|

The **layout and information architecture** match the intended consumer experience: hero → birth confidence → strengths → cautions → advice → life dashboard → source → footer. English labels and technical astrology terms are gone. Birth-time transparency is implemented and readable in copy.

However, **content differentiation is not strong enough for production**. Many users will see identical life-dashboard lines, only one strength card in common profiles, and 23 theme-phrase pairs exceed 30% similarity. Headlines differ, but the body experience converges on shared fallbacks.

---

## Phase 1 — Real Screenshot Verification

**Method:** Real Flutter widget rendering saved as PNG (not pixel-diff golden comparison).  
**Command:** `flutter test test/validation/thai_mirror_consumer_ux/consumer_section_screenshot_test.dart --update-goldens`

### Section screenshots (Profile A, with birth time)

| # | Section | File |
|---|---------|------|
| 1 | Hero | `screenshots/profile_a_01_hero.png` |
| 2 | Birth confidence | `screenshots/profile_a_02_birth_confidence.png` |
| 3 | จุดเด่นของคุณ | `screenshots/profile_a_03_strengths.png` |
| 4 | สิ่งที่ควรระวัง | `screenshots/profile_a_04_cautions.png` |
| 5 | คำแนะนำสำหรับช่วงนี้ | `screenshots/profile_a_05_advice.png` |
| 6 | ชีวิตของคุณในด้านต่าง ๆ | `screenshots/profile_a_06_life_dashboard.png` |
| 7 | แหล่งที่มาของผลลัพธ์ | `screenshots/profile_a_07_source.png` |
| 8 | Footer | `screenshots/profile_a_08_footer.png` |
| — | Full page (fixture) | `screenshots/full_page_fixture.png` |

### Layout verification (from renders)

- Hero: gradient card, headline + summary + tag chips — **matches mockup intent**
- Strengths / cautions: titled sections with icon + white cards — **correct**
- Advice: lavender card with circular icon — **correct**
- Life dashboard: 5 aspect rows with status badges — **correct**
- Source: three labeled blocks (data / calculation / meaning) — **correct**
- Footer: disclaimer text — **correct**

### Notes

- **Test harness:** Thai glyphs render as □ boxes in headless Flutter tests (no Thai font bundled). Layout is accurate; verify copy on device or Chrome with Thai locale.
- **Flutter Web:** `build/web` served at `localhost:8765/#/thai-mirror/consumer-preview` renders black canvas in automated browser (Firebase + AuthGate bootstrap). Web visual QA requires authenticated session or a standalone preview entry point.

---

## Phase 2 — Different People Should Look Different

**10 synthetic profiles (A–J)** with radically different theme combinations.

### Headlines — all unique ✅

| Profile | Themes | Headline |
|---------|--------|----------|
| A | disciplined, analytical, builder | คุณเป็นคนชอบคิดก่อนทำ สร้างผลงานได้จริง และกำลังเรียนรู้ใจเย็น |
| B | expressive, creative, adventurous | คุณเป็นคนสื่อสารเก่ง คิดสร้างสรรค์ และเปิดรับการเปลี่ยนแปลง |
| C | relationship, diplomatic, nurturing | คุณเป็นคนหาจุดร่วมเก่ง เห็นใจผู้อื่น และกำลังเรียนรู้พูดความรู้สึก |
| D | ambitious, competitive, leadership | คุณเป็นคนมุ่งมั่นและไม่หยุด อยากควบคุมทุกอย่าง และเป็นผู้นำโดยธรรมชาติ |
| E | reflective, spiritual, seeker | คุณเป็นคนไม่ชอบความขัดแย้ง มองภาพรวม และชอบเรียนรู้ |
| F | resilient, survivor, independent | คุณเป็นคนปรับตัวเก่ง ชอบพึ่งตัวเอง และอดทนต่อเนื่อง |
| G | perfectionist, analytical, overthinking | คุณเป็นคนชอบคิดก่อนทำ ใส่ใจรายละเอียด และกำลังเรียนรู้ใจเย็น |
| H | charismatic, social, expressive | คุณเป็นคนผสมแผนกับความยืดหยุ่น สื่อสารเก่ง และเข้าใจความรู้สึกคนอื่น |
| I | stability, loyalty, responsibility | คุณเป็นคนอยากควบคุมทุกอย่าง กำลังเรียนรู้ใจเย็น และรับผิดชอบสูง |
| J | freedom, exploration, change | คุณเป็นคนปรับตัวเก่ง เปิดรับการเปลี่ยนแปลง และกล้าลองและลงมือทำ |

**Screenshots:** `screenshots/profile_{a-j}_hero.png` and `profile_{a-j}_dashboard.png`

### Differentiation failures ❌

| Issue | Impact |
|-------|--------|
| **A vs G headlines** share "ชอบคิดก่อนทำ" + "ใจเย็น" | Two “radically different” profiles feel similar at first glance |
| **Only 1 strength card** per profile | Presenter reads only `strengths` section; test profiles have 1 theme there → sparse “จุดเด่น” |
| **Shared dashboard fallbacks** | See table below |

### Identical life-dashboard copy across profiles

| Aspect | Shared fallback text | Profiles with exact same text |
|--------|---------------------|-------------------------------|
| สุขภาพ | พักผ่อนพอและแบ่งเวลาพักใจ จะช่วยให้คุณแข็งแรงต่อเนื่อง | **8/10** (A,B,C,D,E,G,H,J) |
| ความรัก | ความสัมพันธ์ดีขึ้นเมื่อมีความไว้วางใจและเวลาอยู่ด้วยกันอย่างจริงใจ | **7/10** (A,B,D,E,G,H,J) |
| การเงิน | คุณมักใช้เงินอย่างมีแผนและให้ความสำคัญกับความมั่นคง | **7/10** (B,C,D,E,G,H,J) |
| การงาน | งานที่ให้คุณใช้จุดแข็งและเห็นเป้าหมายชัด คุณมักทำได้ดี | **3/10** (B,C,G) |

**Conclusion:** Headlines pass; **dashboard and strengths do not** — most users scrolling past the hero will see repeated copy.

---

## Phase 3 — Duplicate Content Audit (57 themes)

**23 pairs flagged above 30% similarity** (trigram Jaccard on phrase fields).

| Theme A | Theme B | Field | Similarity |
|---------|---------|-------|------------|
| independent_in_relationships | reserved | strengthTitle | **57.9%** |
| empathetic | empathy | heroDetail | **55.1%** |
| protective | supportive | loveHint | 45.6% |
| control | overthinking | cautionTitle | 43.5% |
| creative | entrepreneurial | workHint | 43.4% |
| grounded | stable | strengthTitle | 41.9% |
| creative | creativity | heroDetail | 41.8% |
| protective | protective_of_others | strengthBody | 40.0% |
| embrace_change | open_to_collaboration | heroDetail | 38.7% |
| entrepreneurial | explorer | luckHint | 38.6% |
| persistence | resilient | strengthTitle | 36.8% |
| curious | embrace_change | luckHint | 35.8% |
| ambitious | self_criticism | strengthBody | 35.7% |
| explorer | visionary | luckHint | 34.9% |
| analytical | overthinking | strengthBody | 34.8% |
| big_picture | leader | workHint | 34.7% |
| empathetic | empathy | strengthTitle | 33.3% |
| entrepreneurial | visionary | luckHint | 33.3% |
| loyal | relationship_oriented | strengthTitle | 32.3% |
| creative | creativity | strengthTitle | 31.6% |
| builder | teacher | workHint | 31.1% |
| express_emotions_more_freely | independent | strengthTitle | 31.0% |
| strategic | teacher | workHint | 30.9% |

**Root cause:** Near-synonym themes (empathy/empathetic, creative/creativity) and shared default `strengthTitle`/`strengthBody` patterns in `thai_mirror_theme_phrases.dart`.

---

## Phase 4 — Missing Birth Time Experience

**Implemented** in `ThaiMirrorBirthDataConfidenceBanner` + `ThaiMirrorConsumerCopy.birthDataConfidence()`.

| State | Title | Body |
|-------|-------|------|
| **With birth time** | ข้อมูลวันเกิดครบถ้วน | ใช้วันเกิดและเวลาเกิดในการวิเคราะห์ ผลลัพธ์ด้านบุคลิกน่าเชื่อถือมากขึ้น |
| **Without birth time** | ไม่มีเวลาเกิด | ใช้เฉพาะวัน เดือน ปีเกิดในการวิเคราะห์ ผลลัพธ์บางส่วนอาจคลาดเคลื่อน โดยเฉพาะด้านบุคลิกเชิงลึก |

- Visible green (complete) / amber (missing) banner below hero ✅  
- Human-readable Thai, no jargon ✅  
- Screenshot: `screenshots/profile_a_no_birth_time_banner.png`

---

## Phase 5 — Readability Audit

### Automated scan: 0 regex flags

No English tokens, banned internal terms, or listed AI-style phrases in theme copy.

### Manual review — issues requiring rewrite

| Category | Problem | Example |
|----------|---------|---------|
| **Generic fallbacks** | Same line for many users | ความสัมพันธ์ดีขึ้นเมื่อมีความไว้วางใจ… (7 profiles) |
| **Thin strengths** | Section feels empty | 1 card vs 3 in fixture mock |
| **Near-duplicate themes** | User can't tell empathetic vs empathy apart | See Phase 3 pairs |
| **Abstract luck line** | Doesn't say what person is like | โอกาสดีมักมาเมื่อคุณเปิดใจลองสิ่งใหม่ที่เหมาะกับตัวเอง |

### Priority rewrites (top duplicate pairs)

1. **empathetic ↔ empathy** — differentiate heroDetail: one focuses on *reading others*, one on *responding*
2. **creative ↔ creativity** — merge or split: creativity = process, creative = output/style
3. **grounded ↔ stable** — grounded = practical feet-on-earth; stable = emotional consistency
4. **independent_in_relationships ↔ reserved** — distinct strength titles required
5. **control ↔ overthinking** — caution titles must not share "อย่า..." pattern

### Global fallback rewrites (life dashboard)

| Current | Suggested direction |
|---------|---------------------|
| ความสัมพันธ์ดีขึ้นเมื่อมีความไว้วางใจ… | Remove as global fallback; always derive from top relationship theme |
| พักผ่อนพอและแบ่งเวลาพักใจ… | Tie to stress theme (overthinking, ambitious, perfectionist) |
| คุณมักใช้เงินอย่างมีแผน… | Tie to disciplined/builder vs entrepreneurial/explorer |

---

## Phase 6 — Production Readiness Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| **Clarity** | 7.5 | Structure clear; strengths section often too thin |
| **Differentiation** | 6.0 | Unique headlines; repeated dashboard + sparse cards |
| **Readability** | 7.5 | Natural Thai when read as text; fallbacks feel generic |
| **User trust** | 8.0 | Source transparency + disclaimers strong |
| **Birth-time transparency** | 9.0 | Visible, plain-language banner |
| **Consumer friendliness** | 6.5 | Layout excellent; content repetition hurts usefulness |
| **Average** | **7.4** | Below bar when content quality weighted |

### Recommendation

## **NEEDS ANOTHER ITERATION**

Do **not** deploy until:

1. **Presenter:** Populate 2–3 strength cards from top themes (coreSelf + strengths + work), not only `strengths` section
2. **Life dashboard:** Never show global fallback if any top theme has an aspect hint; rotate hints across themes
3. **Theme phrases:** Rewrite 23 flagged pairs; target <25% similarity for synonym themes
4. **Profile collision:** Differentiate A vs G headline paths (analytical + builder vs analytical + perfectionist)
5. **Visual QA:** Manual check on Chrome/Android with Thai fonts before sign-off

---

## Files Reference

| Purpose | Path |
|---------|------|
| Screenshots | `test/validation/thai_mirror_consumer_ux/screenshots/` |
| Validation runner | `test/validation/thai_mirror_consumer_ux/analysis/consumer_ux_validation_runner.dart` |
| Theme copy | `lib/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart` |
| Presenter | `lib/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart` |
| Result page | `lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart` |
