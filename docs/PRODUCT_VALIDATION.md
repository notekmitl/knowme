# KnowMe Phase A — Product Validation

**Status:** CURRENT (implementation record · product measurement)
**Audience:** Product, developers, validation, AI agents.
**Last updated:** June 2026
**Builds on:** P3 Global Mirror Experience
([`GLOBAL_MIRROR_EXPERIENCE_P3.md`](GLOBAL_MIRROR_EXPERIENCE_P3.md)).

---

## 1. Goal

The platform architecture is complete. Phase A answers a single product
question: **do users actually experience WOW?** — and, if they stall, **where**.

This is **measurement only**. No new engine, no new provider, no AI, no UI
redesign, no runtime change. It observes the existing P3 experience and turns the
event log into **product** insights (about the product, never about a named user).

---

## 2. Architecture — `lib/features/product_validation/`

| Type | Role |
| --- | --- |
| `ProductEventType` / `ProductEvent` | The measurable moments and a recorded event (type + epoch-ms + structural props). |
| `ProductFunnelStage` | The ordered funnel mirroring the P3 flow: Home → Current Life → Prediction → Decision → Conversation → Reflection. |
| `ProductMetrics` | Per-session metrics derived from one event log. |
| `ProductFunnel` | Aggregate funnel across sessions (reach, conversion, drop-off). |
| `ProductInsight` / `ProductInsights` | Product-level signals grouped as WOW / curiosity / engagement / drop-off. |
| `ProductInsightsEngine` | Pure, deterministic: sessions → metrics + funnel + insights. |
| `ProductValidationTracker` | The instrumentation surface (one method per moment). `Noop` + `Recorder` implementations. |
| `ProductValidationRecorder` | In-memory event store with an injectable clock; derives metrics/insights on demand. |
| `ProductValidation` | App-wide access point (`ProductValidation.tracker`). |
| `ProductValidationDashboard` | The **internal-only** dashboard widget. |
| `ProductValidationRoutes` | Additive `/internal/product-validation` route (not linked from any user surface). |

**Determinism.** Metrics, funnels and insights are pure functions of the event
log; the recorder takes an injectable clock so tests are exact.

**No backend sink.** Events live in memory for the running app and are read by the
internal dashboard. A persistent sink (Firestore / web storage) can be added
behind `ProductValidationTracker` later without changing any caller.

---

## 3. Metrics

Per the goal, Phase A measures:

| Metric | Source |
| --- | --- |
| **Time to first WOW** | session start → first `insightViewed` |
| **Time to first conversation** | session start → first `conversationQuestionAsked` |
| **Cards opened** | count of `evidenceExpanded` (a card's "what this is based on") |
| **Questions asked** | count of `conversationQuestionAsked` |
| **Prediction viewed** | `predictionViewed` present |
| **Decision viewed** | `decisionViewed` present |
| **Conversation completion** | asked ≥1 question **and** saw an answer |
| **Reflection completion** | `reflectionViewed` present |
| **Return visit** | more than one session observed |

### Instrumentation points (additive, in P3 widgets)

- `MirrorHome` → `sessionStarted`, `homeViewed`, `journeyStarted` (on Begin).
- `MirrorJourney` → `insightViewed` / `predictionViewed` / `decisionViewed` /
  `askMoreViewed` / `reflectionViewed` per stage, `journeyRestarted`.
- `MirrorConversationEntry` → `conversationTopicOpened`,
  `conversationQuestionAsked`, `conversationAnswerViewed`,
  `conversationSuggestionTapped`.
- `MirrorWhyTile` (evidence expander) → `evidenceExpanded(cardId)`.

---

## 4. Funnels

```
Home  →  Current Life (WOW)  →  Prediction  →  Decision  →  Conversation  →  Reflection
```

A session "reaches" a stage if its event log contains the stage trigger. The
funnel reports, per stage: **reached count**, **conversion from start**,
**conversion from the previous stage**, and **drop-off from the previous stage**.

- **Where users stop** → the stage with the largest drop-off (`biggestDropOff`).
- **Where users become curious** → evidence-expansion and topic-open rates.
- **Where users become engaged** → conversation-completion rate, questions per
  engaged session, reflection-completion rate, return visits.

---

## 5. Success criteria

These are the **product** thresholds Phase A exists to evaluate (targets to read
against on the dashboard — not enforced in code):

| Signal | Target |
| --- | --- |
| WOW reach rate | ≥ 80% of sessions see their Current Life read |
| Time to first WOW | ≤ ~10s (fast, no setup friction) |
| Prediction → Decision continuation | ≥ 70% |
| Conversation entry | ≥ 40% reach Ask More |
| Conversation completion | ≥ 25% ask and receive an answer |
| Reflection completion | ≥ 20% reach the closing reflection |
| Evidence curiosity | ≥ 15% open a card's evidence |
| Return visit | observed |

A milestone passes validation when the funnel shows no single catastrophic
drop-off before WOW and the WOW reach rate clears its target.

---

## 6. The dashboard (internal only)

Reachable only by navigating directly to `/internal/product-validation`; it is
**not linked** from any user surface. It renders the engagement funnel and the
WOW / curiosity / engagement / drop-off insights from the in-memory recorder,
with refresh and reset.

---

## 7. Scope & future

- **Deploy:** yes (ships with the platform release; measurement on by default,
  `ProductValidation.recorder.enabled` can disable it).
- **Future:** a persistent/remote sink for cross-device aggregation, and
  per-provider breakdowns once more reasoning providers are registered.

---

## 8. Thai Astrology Research (standalone validation surface)

A separate, production-deployed validation surface for the Thai Astrology lens,
collecting real-world accuracy feedback from external users (D-038). It is **not**
Phase-A telemetry — it captures explicit, attributable feedback per report.

- **Package:** `lib/features/thai_beta/` · **Routes:** `/beta/thai` (public),
  `/internal/thai-beta` (admin).
- **Flow:** `ThaiBetaInput → BirthNormalizer → ThaiEngineAdapter → ThaiMirrorPipeline
  → existing ThaiMirrorResultPage → feedback → thai_beta_feedback`. Reuses the
  production engine and report — no new astrology pipeline, no runtime/reasoning change.
- **Captured per submission:** raw input, normalized-birth snapshot (sunrise, Thai
  astrological date, used-previous-day, timezone, coordinates), report snapshot,
  engine versions, feedback (overall stars, most/least accurate, what to analyze
  more, **why recommend to a friend**, perceived method, consent), plus provenance:
  sequential `researchId` (`TH-00000001`), `startedAt` / `submittedAt` /
  `durationSeconds`, and a SHA-256 `reportHash` of the report snapshot.

### Security & data quality

- **Rules are repo-managed** (`firestore.rules`, registered in `firebase.json`):
  existing data stays owner-only under `users/{uid}/**`; `thai_beta_feedback` allows
  public validated **create** but **admin-only read**; `counters/thai_research`
  permits only +1 increments (backs sequential ids). No console-only config.
- **Admin surface is gated** by `ThaiResearchAdminGuard` against an `admins/{uid}`
  allow-list (same source of truth as the rules), failing **closed**. Public users
  never reach the dashboard, detail, or statistics. (Provision an admin by creating
  `admins/{uid}` out-of-band; client writes to `admins/` are denied.)
- **No silent save failures:** the store returns success (with Reference ID) or an
  error, and the UI shows Thank-you / “please try again” accordingly.

### Admin dashboard

Total feedback, average rating, rating distribution, and most-frequent themes for
accurate topics / complaints / requested improvements; the list shows `researchId`
+ duration, and the detail view shows `researchId`, duration, and `reportHash`.

### UX V1 (D-039)

Usability/transparency pass before inviting real users (UX only — no engine or
normalization change): the flow shows **no navigation controls**; birth time uses a
**true 24-hour picker** (never AM/PM); and a **Research summary** appears
immediately before the report — an “ข้อมูลที่ใช้วิเคราะห์” card (Thai Buddhist-era
dates, sunrise, Thai astrological date, timezone), a transparency banner explaining
the sunrise day-boundary shift, and the collapsible technical panel
(coordinates / timezone / sunrise / hash / research id). Full detail in
[`THAI_RESEARCH.md`](THAI_RESEARCH.md).

### UX polish (D-040)

A guided funnel to lift trust, completion, and feedback quality: a **landing
screen** (purpose / time / privacy / participation / participant count), a
**4-step progress indicator** on every screen, clearer CTA copy, and a dedicated
**completion screen** (thank-you + Reference ID + invite to return). UX only.

### Desktop/web fixes (D-041)

Web/desktop input parity: the birth-time wheel is replaced by two inline
hour/minute controls (click / type / keyboard), and the province dropdown by a
searchable type-ahead autocomplete; popups are height-bounded so they never run
off-screen. UX only — no engine/runtime/report change.

---

## Related documents

- [`GLOBAL_MIRROR_EXPERIENCE_P3.md`](GLOBAL_MIRROR_EXPERIENCE_P3.md) — the
  experience being measured.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — Product Validation + Thai Astrology Research sections.
- [`DECISION_LOG.md`](DECISION_LOG.md) D-031 (Phase A) and D-038 (Thai Astrology Research).
