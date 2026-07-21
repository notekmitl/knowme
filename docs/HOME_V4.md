# KnowMe Phase B — Home V4 Integration

> **Superseded on Home by Phase C — Daily Mirror**
> ([`DAILY_MIRROR_PHASE_C.md`](DAILY_MIRROR_PHASE_C.md), D-033). The Home
> emotional entry is now `DailyMirrorSection`; the Phase B staged
> `MirrorHomeSection` described below has been removed. The Home **wiring**
> (optional `mirrorBirthDate` on `HomeScreenV3`, birth date from `HomePage`'s
> bundle, legacy-hero fallback) is unchanged and still current.

**Status:** HISTORICAL (Phase B record · Home wiring still current)
**Audience:** Developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** P3 Global Mirror Experience
([`GLOBAL_MIRROR_EXPERIENCE_P3.md`](GLOBAL_MIRROR_EXPERIENCE_P3.md)) and
Phase A Product Validation ([`PRODUCT_VALIDATION.md`](PRODUCT_VALIDATION.md)).

---

## 1. Goal

Make the **Mirror Experience the default emotional entry of Home**. Before
Phase B the experience lived behind the hidden `/mirror-experience` route while
production Home (V3) led with the legacy `HomeHeroSection`. Phase B brings the
Mirror cards onto Home as first-class citizens.

Hard constraints (honoured):

- **Do not redesign the Runtime.** The Fusion/Global/Thai reasoning stack is
  untouched.
- **Do not redesign the Mirror Experience.** The P3 cards, full-page
  `MirrorJourney`/`MirrorHome`, and the `/mirror-experience` route are unchanged.
- **No duplicated UI — reuse all Mirror widgets.**
- **Telemetry must continue working.** Phase A instrumentation keeps firing.

```
Login
  ↓
Home  (= Mirror Home)
  ↓
Current Life
  ↓
Prediction
  ↓
Decision
  ↓
Ask
  ↓
Conversation
  ↓
Reflection
```

---

## 2. What shipped

### `MirrorHomeSection` — the embeddable entry

`lib/features/mirror_experience/ui/mirror_home_section.dart`

A new, **embeddable** widget (not a page) that is the emotional entry of Home.
It reuses the exact P3 card widgets — **no duplicated UI**:

- `MirrorInsightCard` (Current Life)
- `MirrorPredictionCard` (Prediction)
- `MirrorDecisionCard` (Decision)
- `MirrorConversationEntry` (Ask → Conversation)
- `MirrorReflection` (Reflection)

Unlike the full-page `MirrorJourney` (a `Scaffold` with its own app bar /
bottom bar), the section renders **inline inside the Home scroll** and reveals
each stage in place via a single `Continue` action, so all stages appear
directly on Home and accumulate as the user continues. It consumes the
**`FusionRuntime` only** through `MirrorExperienceRuntime.fusion` and
`MirrorExperienceService`.

### Home wiring

`lib/features/home_cohesion/presentation/home_screen_v3.dart`

`HomeScreenV3` gains one optional parameter, `DateTime? mirrorBirthDate`:

- **birth date present →** `MirrorHomeSection` **replaces** `HomeHeroSection` as
  the emotional entry.
- **birth date absent →** the legacy `HomeHeroSection` is preserved, so the
  profile-completion / MBTI-unlock onboarding path is unchanged.

Everything below the entry — `HomeAstrologySummaryCard`, the psychology
enhancement section, narrative preview, and the compact profile — is unchanged.

`lib/presentation/pages/home/home_page.dart`

`HomePage` derives the birth date from its **already-loaded** source bundle
(`_sourceBundle.profileFields['birthDate']`, parsed via
`BirthProfileFormat.parseStoredDate`) and passes it to `HomeScreenV3`. There is
**no new loader and no extra Firestore read** — the date is a by-product of the
existing Home V3 load path.

---

## 3. Telemetry continuity (Phase A)

`MirrorHomeSection` keeps Product Validation working. On mount it fires
`sessionStarted`, `homeViewed`, and `journeyStarted`, then `insightViewed` for
the first WOW. Each `Continue` reveal fires the matching stage event
(`predictionViewed`, `decisionViewed`, `askMoreViewed`, `reflectionViewed`), and
restart fires `journeyRestarted`. The reused P3 cards retain their own events
(`evidenceExpanded`, conversation topic/question/answer/suggestion). The funnel
(Home → Current Life → Prediction → Decision → Conversation → Reflection) is
therefore measured directly from Home. The internal dashboard remains at
`/internal/product-validation`.

---

## 4. Boundaries

- **Reasoning:** consumes `FusionRuntime` only; no provider or Thai types on the
  Home surface (explain-life-not-astrology preserved end to end).
- **Frozen:** Runtime stack, P3 Mirror widgets/journey, `/mirror-experience`
  route, and the AuthGate → ProfileGate → HomePage boot flow.
- **Additive only:** one new widget, one optional `HomeScreenV3` parameter, one
  birth-date helper on `HomePage`.

---

## 5. Tests

`test/validation/home_v4/home_v4_mirror_entry_test.dart`

- Without a birth date, Home keeps the legacy `HomeHeroSection`.
- With a birth date, `MirrorHomeSection` is the entry, the Current Life card
  renders, and `sessionStarted` + `insightViewed` are recorded.
- `Continue` reveals Prediction then Decision inline.

Existing suites still pass: `test/home_screen_v3_test.dart`,
`test/validation/mirror_experience_p3/`,
`test/validation/product_validation_phase_a/`.

---

## 6. Future work

- Localized Thai copy and richer per-provider phrasing on the Home cards.
- Additional providers fusing into the same Home surface once registered.
- Persistent/remote telemetry sink for cross-device funnels (Phase A seam).

See [`DECISION_LOG.md`](DECISION_LOG.md) **D-032**,
[`ARCHITECTURE.md`](ARCHITECTURE.md) (Home V4 section), and
[`ROADMAP.md`](ROADMAP.md).
