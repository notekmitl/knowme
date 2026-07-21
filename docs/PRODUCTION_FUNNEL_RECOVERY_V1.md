# Production Funnel Recovery V1

> **HISTORICAL (strategy, June 2026).** Funnel-recovery strategy reference (MBTI-mini thesis). Strategy is still relevant; the Firestore funnel numbers are a June 2026 snapshot. Index: [`PROJECT_INDEX.md`](PROJECT_INDEX.md).

**Program:** Production Funnel Recovery V1  
**Authority:** [`docs/KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md), [`docs/GOVERNANCE.md`](GOVERNANCE.md)  
**Scope:** Product strategy only — no code, no implementation, no engine changes  
**Status:** COMPLETE  
**Date:** 2026-06-21  
**Inputs:** Real User Runtime Validation V1, Firestore export (38 users), Home V3.8 codebase audit

---

## Executive Summary

Real users complete **astrology** (81.6%) but abandon before **personality tests** (MBTI 2.6%, Big Five 0%, EQ 5.3%). Narrative reach is **2.6%** (1/38). The funnel cliff is not product interest — it is **post-astrology motivation and discoverability**.

Home currently delivers immediate astrology value and frames psychology tests as **optional exploration**, not as the **unlock path to a deeper profile**. No visible progress ties tests to Narrative.

**Recovery thesis:** Do not acquire more users until the **24-user recovery cohort** (astrology complete, zero personality tests) can be converted at ≥25% via a single fast test path (MBTI Mini, 16 questions).

---

## 1. Conversion Funnel

### 1.1 Data source

Firestore export of 38 production users (`firestore_user_export.json`), cross-validated with Real User Runtime Validation V1 pipeline replay.

Two views:

| View | Users | Use |
|---|---:|---|
| All Firestore accounts | 38 | Full platform audit (includes automation) |
| Product-like users | 26 | Excludes UIDs with test/verify/cors/e2e/audit |

Metrics below show **all users** first; product-like in parentheses where different.

### 1.2 Full conversion funnel

| Step | Users | Cumulative % | Step conversion | Drop-off from prior |
|---|---:|---:|---:|---:|
| Signup (Firestore account) | 38 | 100% | — | — |
| Profile created | 31 (26) | 81.6% (100%*) | 81.6% | **−18.4%** |
| Thai astrology input (birth date) | 31 (26) | 81.6% | 100% of profile | 0% |
| BaZi chart generated | 25 (22) | 65.8% (84.6%) | 80.6% of astrology | **−19.4%** |
| Western natal stored | 33 (23) | 86.8% | — | Not in Mirror path |
| MBTI result saved | 1 (1) | 2.6% (3.8%) | 3.2% of profile users | **−97.4%** |
| Big Five result saved | 0 (0) | 0% | 0% | **−100%** |
| EQ result (any module) | 2 (2) | 5.3% (7.7%) | 6.5% of profile users | **−94.7%** |
| Mirror (dual input) | 2 | 5.3% | — | Blocked by personality |
| Human Pattern (≥1 activation) | 1 | 2.6% | 50% of Mirror | **−50%** |
| **Narrative (≥1 paragraph)** | **1** | **2.6%** | 100% of HP | 0% |

\*Among product-like users, all 26 have profiles; signup→profile drop-off is concentrated in automation accounts.

### 1.3 Drop-off visualization

```
Signup          ████████████████████████████████████████  38  (100%)
Profile         ████████████████████████████████░░░░░░░░  31  (−18%)
Thai astrology  ████████████████████████████████░░░░░░░░  31  (0%)
BaZi            ██████████████████████████░░░░░░░░░░░░░░  25  (−19%)
MBTI            █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   1  (−97%)  ← CLIFF
Big Five        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0  (−100%)
EQ (any)        ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   2  (−95%)
Narrative       █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   1  (−97%)
```

### 1.4 Abandonment points

| Rank | Abandonment point | Severity | Evidence |
|---:|---|---|---|
| 1 | **After astrology, before any personality test** | Critical | 29/31 profile users have zero MBTI/Big Five/EQ results |
| 2 | **Profile setup never completed** | Moderate | 7 users (mostly automation) never create profile |
| 3 | **BaZi not generated despite profile** | Low | 6 users with birth profile but no BaZi doc |
| 4 | **Mirror reached but zero pattern activation** | Edge | 1 user (`k80ff6ci...`) — EQ-only, insufficient cross-mirror |
| 5 | **Post-personality, pre-narrative** | None observed | 1 success user completes full stack |

**Dominant abandonment:** Users receive satisfying astrology output on Home and **never discover that tests are required** for the deeper KnowMe stack.

### 1.5 Average completion path (observed)

| Path | Users | % of population |
|---|---:|---:|
| **A — Astrology only** (profile + Thai + optional BaZi, no tests) | 29 | 76.3% |
| **B — Profile incomplete** (no birth data) | 7 | 18.4% |
| **C — Partial personality** (EQ started/completed, no MBTI) | 1 | 2.6% |
| **D — Full stack** (profile + astrology + MBTI + narrative) | 1 | 2.6% |
| **E — Mirror without narrative** (personality + astrology, 0 patterns) | 1 | 2.6% |

**Modal path:** Profile → Thai astrology → BaZi (optional) → **stop on Home astrology hero**.

**Successful path:** Profile → Thai → BaZi → **MBTI Mini completed** → Mirror → GF2 → Human Pattern → Narrative V5.

No user has ever completed Big Five in production.

---

## 2. Home Experience Audit

### 2.1 Current Home structure (V3.8)

Above-the-fold order on mobile:

1. **Hero** — "ดวงของคุณ" + astrology identity statement + gold CTA **"ดูผลโหราศาสตร์ทั้งหมด"**
2. **Signature** — "หลายมุมมองสะท้อนตรงกันว่า..." (theme chips from astrology/fusion)
3. **Insight** — "สิ่งที่ KnowMe เข้าใจเกี่ยวกับคุณ" (short reflection cards)
4. **Profile strip** — name, birth date, place, edit link
5. **Psychology tests** — MBTI / EQ / Big Five cards (below fold for most devices)
6. **More** — astrology, fusion overview, profile, settings

### 2.2 Ten-second comprehension test

**Question:** Can a user understand that *"Doing tests unlocks a deeper profile"* within 10 seconds?

**Answer: NO.**

| Signal user sees in 10s | Message implied |
|---|---|
| Hero astrology identity | "KnowMe already understands my chart" |
| Gold CTA → full astrology | "Go deeper into **astrology**, not tests" |
| Signature + insight from chart themes | "I'm done — this is my profile" |
| Psychology subtitle | "หาก**อยาก**รู้จักตัวเองใน**อีกมุม**... **ลอง**สำรวจ" = optional, not required |
| Test card status "พร้อมสำรวจ" | Exploratory mood, not unlock urgency |
| No % complete bar for KnowMe stack | No gap awareness |
| No "Narrative locked" state | No destination visible |

**Comprehension score:** ~15% would infer tests unlock something essential. ~85% would treat tests as optional add-ons after astrology satisfaction.

### 2.3 Documented friction

| # | Friction | Impact |
|---|---|---|
| F1 | **Astrology satisfies curiosity before tests appear** | User exits emotionally "complete" |
| F2 | **Psychology section uses optional Thai copy** (`HomeV3Copy.psychologySubtitle`) | No unlock framing |
| F3 | **Primary CTA routes to astrology result**, not MBTI Mini | Wrong next action |
| F4 | **Tests are Section 5** — below profile strip on scroll | Low discovery |
| F5 | **Profile completeness tracks 3 fields only** (name, date, place) — not tests | "Complete" feeling at wrong milestone |
| F6 | **`completenessLabel` exists in data model but is not rendered** in `HomeCompactProfileSection` | Missed progress UI |
| F7 | **EQ home requires 6 modules × 20 questions (120 total)** before "completed" status | Overwhelming commitment signal |
| F8 | **Big Five exposes 10 → 44 → 80 question depth ladder** with zero starters | Perceived long test |
| F9 | **Narrative on Home loads from synthetic QA snapshot** (`NarrativeRuntimeLoader`) — not user's real narrative | User cannot preview what tests unlock |
| F10 | **No visible link between tests and "สิ่งที่ KnowMe เข้าใจ" insight section** | Insight feels astrology-derived only |
| F11 | **"ภาพรวมหลายมุมมอง" (Fusion) in More menu** — gated behind personality the user doesn't know they need | Hidden payoff |
| F12 | **Three equal-weight test cards** — no recommended "start here" | Decision paralysis |

### 2.4 Home audit verdict

Home is optimized for **emotional astrology delivery**, not **conversion to personality completion**. It successfully converts users to profile + chart. It **actively discourages** test urgency through copy, layout, and CTA hierarchy.

---

## 3. Narrative Unlock Strategy

**Design only — no implementation.**

### 3.1 Design principles

1. **Show the gap** — user must see what they have vs what is locked
2. **One next action** — never three equal test cards as the primary prompt
3. **Progress is KnowMe-wide** — not per-test silos
4. **Preview the payoff** — blurred/teaser narrative beats abstract "complete your profile"
5. **Astrology counts** — don't reset progress; build on existing 35% base

### 3.2 KnowMe Profile Completion model

| Milestone | Trigger | Display copy | Completion % |
|---|---|---|---:|
| Birth profile saved | Profile `main` doc complete | "KnowMe รู้จักดวงของคุณแล้ว" | **35%** |
| BaZi chart generated | `astrology/chinese_bazi` exists | "เพิ่มมิติปาจื้อแล้ว" | **42%** |
| First personality signal | MBTI Mini **or** Big Five Quick (10Q) **or** EQ Awareness | "บุคลิกของคุณเริ่มปรากฏ" | **52%** |
| Cross-mirror fusion live | Astrology + personality mirrors both active | "หลายมุมมองเริ่มเชื่อมกัน" | **68%** |
| Big Five standard **or** 2nd personality lens | Big Five 44Q or MBTI + EQ module | "แพทเทิร์นที่ซ่อนอยู่เปิดเผยแล้ว" | **78%** |
| Human Pattern active | ≥1 pattern activation | "KnowMe เห็นแพทเทิร์นของคุณแล้ว" | **88%** |
| **Narrative unlocked** | ≥6 narrative paragraphs generated from **user's** snapshot | "เรื่องราวของคุณพร้อมแล้ว" | **100%** |

### 3.3 Progressive unlock states (UI concept)

#### State A — After astrology (current majority: 29 users)

```
┌─────────────────────────────────────────┐
│  KnowMe Profile          ████░░░░  35%  │
│                                         │
│  ✓ ดวงชะตาไทย                          │
│  ✓ ปาจื้อ (if present)                  │
│  ○ บุคลิกภาพ — ยังไม่ได้เริ่ม           │
│  🔒 เรื่องราวส่วนตัว — ล็อคอยู่          │
│                                         │
│  [ ทำแบบทดสอบ 16 ข้อ ปลดล็อค 52% → ]   │
└─────────────────────────────────────────┘
```

#### State B — After MBTI Mini

```
KnowMe Profile          ██████░░  52%
+ "แพทเทิร์นใหม่ 3 รายการพร้อมดู" (teaser count)
CTA: "ดูแพทเทิร์นที่เปิดแล้ว" / secondary "เพิ่ม Big Five +17%"
```

#### State C — After Big Five Quick (10Q)

```
KnowMe Profile          ███████░  60%
"New hidden patterns available" — show 2 blurred pattern labels
```

#### State D — After EQ Awareness (optional accelerator)

```
KnowMe Profile          ████████  75%
"ความฉลาดทางอารมณ์เสริมแพทเทิร์นความสัมพันธ์"
```

#### State E — Narrative unlocked

```
KnowMe Profile          ██████████  100%
Replace insight empty state with first narrative paragraph preview
CTA: "อ่านเรื่องราวของคุณ"
```

### 3.4 Unlock placement rules

| Surface | Rule |
|---|---|
| Hero sub-line | Always show `% complete` when <100% |
| Hero primary CTA | If `<52%`: route to recommended test; if `≥88%`: route to narrative |
| Psychology section | Collapse to **one recommended next test** + "ดูทั้งหมด" expander |
| Signature section | At `<52%`: show locked state "ปลดล็อคเมื่อทำแบบทดสอบบุคลิก" |
| Insight section | Show blurred preview of narrative paragraph at `≥68%` |

### 3.5 What NOT to do

- Do not require all 6 EQ modules for unlock progress
- Do not show 80-question Big Five as the default entry
- Do not use synthetic QA narrative as Home preview
- Do not add randomness or gamification badges — progress must map to real pipeline stages

---

## 4. Test Completion Strategy

### 4.1 Test inventory audit

| Test | Minimum viable | Standard | Deep | Time estimate (mini) | Production adoption |
|---|---:|---:|---:|---|---:|
| **MBTI Mini** | 16 Q | 40 Q | 80 Q | **3–5 min** | **1 user** |
| **Big Five** | 10 Q (quick) | 44 Q (BFI) | 80 Q (IPIP) | 2 min / 12 min / 20 min | **0 users** |
| **EQ** | 1 module (20 Q) | 3 modules (60 Q) | 6 modules (120 Q) | 5 min / 15 min / 30 min | 2 users (partial) |

### 4.2 Abandonment risk matrix

| Test | Length risk | Value clarity risk | Discovery risk | Composite risk |
|---|---|---|---|---|
| MBTI Mini | **Low** | Medium | **High** | **Medium** |
| Big Five Quick | **Low** | **High** (unknown brand) | **High** | **High** |
| Big Five Standard | **High** | High | High | **Very high** |
| EQ single module | Medium | Medium | **High** | Medium |
| EQ full (6 modules) | **Very high** | Low (far from narrative) | High | **Very high** |

### 4.3 Perceived value gap

| Test | What user thinks they get | What pipeline actually needs |
|---|---|---|
| MBTI | "My type label" | Personality mirror → cross-mirror fusion → patterns |
| Big Five | "Trait scores" | Strongest personality signal for Human Pattern density |
| EQ | "Emotional score" | Supplemental personality mirror weight |

**Problem:** UI sells **test results**. Pipeline needs **mirror inputs**. User doesn't see that MBTI Mini unlocks **"เรื่องราวของคุณ"** — they think they already have a profile from astrology.

### 4.4 Fastest path to first narrative

**Recommended minimum viable personality path:**

```
MBTI Mini (16 questions, ~4 minutes)
  → Personality mirror active
  → Cross-mirror fusion with existing Thai + BaZi
  → Human Pattern activation (proven: 8 patterns on success user)
  → Narrative V5 (proven: 6 paragraphs)
```

**Why MBTI Mini first:**

| Criterion | MBTI Mini | Big Five Quick | EQ Awareness |
|---|---|---|---|
| Questions | 16 | 10 | 20 |
| Production proof | 1 full success | 0 | 0 partial |
| Home card prominence | Equal (should be primary) | Equal | Equal |
| Pipeline personality weight | High | High | Medium |
| Brand recognition (Thai users) | **High** | Low | Medium |
| Time to mirror | **~4 min** | ~2 min | ~5 min |

**Secondary path (after first narrative):** Big Five Quick (10Q) to raise pattern density and narrative richness — not required for first unlock.

**EQ strategy:** Treat EQ as **depth layer**, not gate. One module (Awareness, 20Q) adds +8% progress; do not block narrative on 6/6 EQ completion.

### 4.5 Test UX recommendations (design)

| Change | Rationale |
|---|---|
| Rename entry CTA to **"ปลดล็อคโปรไฟล์ลึก — 16 ข้อ"** | Ties test to unlock, not exploration |
| Show **question count + time** on card | Reduces fear |
| MBTI result page → **"ดูเรื่องราวที่ปลดล็อckแล้ว"** CTA | Closes loop to narrative |
| Big Five card → default to **Quick 10** tier, hide 80Q until engaged | Matches 0% adoption reality |
| EQ card → **"เริ่ม 1 โมดูล"** not "6 โมดูล" | 120Q is a conversion killer |
| Post-test celebration at **52%** milestone | Dopamine at first mirror activation |

---

## 5. Recovery Cohort Analysis

### 5.1 Cohort definition

**Recovery Cohort R1:** Users with Thai birth profile complete, **zero** personality test results (MBTI, Big Five, or EQ).

| Metric | Value |
|---|---:|
| All users in R1 | **29** |
| Product-like users in R1 | **24** |
| Automation accounts in R1 | 5 |
| Also have BaZi chart | 22 (75.9%) |
| Also have Western natal | ~23 |

These users have **proven self-discovery intent** — they completed profile setup and received astrology output — but never started a personality test.

### 5.2 Cohort value estimate

| If conversion rate | R1 users converted | New narrative users | Narrative reach (26 product-like base) |
|---|---:|---:|---:|
| 10% | 2–3 | +2 | ~12% |
| 25% | 6 | +6 | ~27% |
| 40% | 10 | +10 | ~42% |
| **Target: 30% narrative adoption** | **~7–8** | **+7** | **~30%** |

**30% narrative adoption on 26 product-like users = 8 users reaching Narrative.**  
Current: 1. Gap: **+7 users from R1 cohort.**

### 5.3 Re-engagement strategy (design only)

#### Segment R1-A: Active astrology readers (hero engaged, recent login)

- **Trigger:** User opens Home, scrolls hero, does not tap test within session
- **Strategy:** Replace psychology subtitle with unlock banner on **second visit**
- **Message angle:** "ดวงของคุณครบแล้ว — เหลืออีก 16 ข้อเพื่อให้ KnowMe เล่าเรื่องของคุณ"
- **Channel:** In-app Home state change only (no push in V1 design)
- **Success metric:** MBTI Mini start rate ≥20% of R1-A

#### Segment R1-B: Profile complete, dormant (no login 7+ days)

- **Trigger:** Return visit after absence
- **Strategy:** Hero shows **"โปรไฟล์ของคุณรออยู่ที่ 35%"** with single CTA
- **Message angle:** Progress loss aversion — "แพทเทิร์นของคุณยังไม่ถูกเปิด"
- **Channel:** Email/push (strategy spec only — **no copy implementation**)
- **Success metric:** Return-to-test rate ≥15%

#### Segment R1-C: BaZi-enriched (22 users with chart)

- **Trigger:** Has BaZi but no personality
- **Strategy:** Lead with cross-mirror promise — "ปาจื้อ + บุคลิก = ภาพที่สมบูรณ์"
- **Message angle:** Completeness framing, not new test request
- **Success metric:** Highest conversion sub-segment (target 35%)

#### Segment R1-D: Western chart only edge cases

- **Note:** Western stored but not in Mirror path — do not message western value until product supports it
- **Strategy:** Same as R1-A; do not mention western

### 5.4 Recovery sequencing

| Phase | Audience | Action | Goal |
|---|---|---|---|
| **Phase 1** | R1 cohort (24) | Home unlock UI + MBTI Mini primary CTA | 6 users complete MBTI |
| **Phase 2** | MBTI completers who didn't return | Post-result narrative teaser | 4 users view narrative |
| **Phase 3** | Narrative viewers | Big Five Quick upsell for depth | +2 users at 78%+ progress |
| **Phase 4** | Validated ≥25% reach | Resume acquisition | New users enter improved funnel |

**Do not run paid acquisition during Phase 1.** New users would hit the same astrology-satisfaction wall.

---

## 6. Prioritized Funnel Fixes

Priority scored by: **narrative reach impact × feasibility × confidence**.

| Priority | Fix | Type | Impact | Effort | Owner |
|:---:|---|---|---|---|---|
| **P0** | **Home unlock bar + % complete** tied to pipeline stages | UX | Very high | Medium | Product + Design |
| **P0** | **Single primary CTA: MBTI Mini 16Q** when personality missing | UX | Very high | Low | Product |
| **P0** | **Rewrite psychology copy** from optional → unlock | Copy | High | Low | Product |
| **P1** | **Hero CTA switches** from astrology → test when `<52%` | UX | High | Low | Product |
| **P1** | **Post-MBTI result → narrative preview** CTA | UX | High | Medium | Product |
| **P1** | **Load real user narrative on Home** when pipeline complete (replace QA loader) | Integration | High | Medium | Engineering |
| **P2** | **EQ card shows 1-module entry** not 6-module wall | UX | Medium | Low | Product |
| **P2** | **Big Five defaults to Quick 10Q** on card | UX | Medium | Low | Product |
| **P2** | **Blurred narrative teaser** at 68%+ progress | UX | Medium | Medium | Design |
| **P3** | Profile setup → **immediate MBTI prompt** after birth save | Onboarding | Medium | Medium | Product |
| **P3** | R1-B email re-engagement | Growth | Medium | Medium | Growth |
| **P4** | Western astrology Mirror integration | Engine | Low (for funnel) | High | Out of scope V1 |
| **P4** | Big Five marketing/education content | Content | Low | Medium | Content |

### Fixes explicitly deferred

- Engine / fusion / narrative algorithm changes
- New test content or AI summaries
- Paid acquisition campaigns
- Big Five as **first** test (0% adoption, low brand recognition vs MBTI)

---

## FUNNEL_RECOVERY_PRIORITY

### What single change would create the largest increase in narrative reach?

**Replace the Home primary CTA with a single unlock action: "ปลดล็อคโปรไฟล์ลึก — ทำแบบทดสอบ 16 ข้อ (~4 นาที)" when the user has astrology but no personality results.**

Why this one change:

- **29 users** are blocked at exactly this step
- MBTI Mini is the **only production-proven** path to Narrative (1/1 success)
- Current Home CTA **"ดูผลโหราศาสตร์ทั้งหมด"** reinforces the wrong loop — more astrology, not personality
- 16 questions is the **lowest-friction** mirror input that satisfies pipeline requirements
- No engine work required — only Home hierarchy, copy, and CTA routing

Estimated impact: **+5 to +8 narrative users** from R1 cohort alone (25–35% conversion on 24 product-like users), raising narrative reach from **2.6% → 18–30%**.

### What is the fastest route to 30% narrative adoption?

**Three moves in sequence (minimum time path):**

| Week | Move | Target metric |
|---|---|---|
| 1 | Home unlock bar + MBTI Mini primary CTA + copy rewrite | MBTI start rate ≥25% of R1 |
| 2 | Post-MBTI narrative preview + real narrative on Home for complete users | MBTI→Narrative ≥60% |
| 3 | Re-engage R1-B dormant users with "35% complete" message | +2–3 dormant conversions |

**Math:** 24 R1 users × 30% MBTI completion × 70% narrative activation ≈ **5 new narrative users** + 1 existing = **6/26 = 23%**. To hit **30% (8 users)**, need **~33% MBTI completion** or **2 additional Big Five Quick completions** from MBTI graduates.

**Fastest single-test path:** MBTI Mini only — do not require Big Five or full EQ for first narrative.

### What should be built before acquiring more users?

| Build | Why before acquisition |
|---|---|
| **1. Home unlock system (P0 fixes)** | New users currently convert to astrology then churn — same as existing 29 |
| **2. MBTI Mini → Narrative loop closure** | Users must **see** what tests unlock or they won't start |
| **3. Real narrative on Home for complete users** | QA synthetic narrative misrepresents product value |
| **4. Funnel telemetry** | Need `profile → test_start → test_complete → narrative_reach` events to validate fixes |
| **5. R1 cohort recovery (Phase 1–2)** | Cheaper to convert 24 warm users than acquire cold users who will hit same wall |

**Do not build before acquisition:**

- New astrology features (already converts)
- Big Five deep tier promotion (0% adoption)
- Full EQ 6-module completion gate
- Engine/fusion/narrative improvements (already PASS on complete users)

**Acquisition gate:** Resume broader user acquisition when **≥25% of profile-complete users reach Narrative** on real Firestore population (≥7 of 26 product-like users, or expanded sample at same rate).

---

## Appendix: Validation cross-reference

| Real User V1 finding | Funnel Recovery response |
|---|---|
| 36/38 blocked on personality | P0 unlock CTA + copy |
| Big Five 0% | Defer; MBTI first; Big Five Quick as Phase 3 upsell |
| EQ 2 users, 6-module wall | EQ as optional depth, not gate |
| 1 narrative success via MBTI | MBTI Mini as canonical first path |
| Home astrology satisfaction | Switch CTA hierarchy after 35% |
| 24-user recovery cohort | Phase 1–2 re-engagement target |

---

## Artifacts

| Artifact | Path |
|---|---|
| Real user validation | `docs/REAL_USER_RUNTIME_VALIDATION_V1.md` |
| Firestore export | `test/validation/real_user_runtime_v1/output/firestore_user_export.json` |
| Validation metrics | `test/validation/real_user_runtime_v1/output/real_user_runtime_validation_v1.json` |
| Home copy source | `lib/features/home_cohesion/presentation/home_v3_copy.dart` |
| Home layout source | `lib/features/home_cohesion/presentation/home_screen_v3.dart` |
