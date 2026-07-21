# Daily Habit Loop — Phase D

> Turn the Daily Mirror into a **daily habit**. No new reasoning, no AI, no
> astrology — a deterministic habit layer over the day records.

Status: **Shipped / deployed.** See Decision Log **D-034**.

---

## Goal

The Daily Mirror (Phase C) gives a daily read, but nothing makes returning feel
like a habit. Phase D adds:

- **Mirror Streak** — consecutive days the user opened today's read.
- **Mirror History** — the last week at a glance (a 7-day strip).
- **Yesterday vs Today** — how the focus and clarity moved.
- **Weekly Reflection** / **Monthly Reflection** — opens, reflections, dominant
  tone and the most-focused life area over a window.
- **Life Trend** — a gentle arc (rising / steady / easing) over ~30 days.

…and measures the habit: **7-day retention, 30-day retention, average sessions,
mirror streak, reflection rate**.

The loop it closes:

```
Open → Read → Take Action → Reflect → Return Tomorrow
```

## Non-goals (boundaries)

- **No new reasoning / runtime / provider / fusion / AI / astrology.** The daily
  read is produced exactly as in Phase C; Phase D only records and reflects on it.
- **No astrology / engine vocabulary** in any user-facing copy — same rule as the
  rest of the Mirror ("explain life, not astrology").
- The records persist **only** tones, life-area keys, clarity and the loop flags —
  never planet/engine/system data, never free text.

---

## Architecture

New, self-contained package `lib/features/mirror_habit/`:

```
domain/
  mirror_day_record.dart        MirrorDayRecord (+ MirrorDate date helpers)
  mirror_streak.dart            MirrorStreak
  mirror_comparison.dart        MirrorComparison + MirrorShift
  mirror_period_reflection.dart MirrorPeriodReflection
  life_trend.dart               LifeTrend + LifeTrendDirection
  mirror_habit_metrics.dart     MirrorHabitMetrics
application/
  mirror_habit_engine.dart      pure functions: streak/compare/period/trend/metrics
  mirror_habit_snapshot.dart    MirrorHabitSnapshot.from(records, today)
  mirror_habit_store.dart       MirrorHabitStore (abstract) + InMemoryMirrorHabitStore
data/
  firestore_mirror_habit_store.dart  per-user Firestore store
mirror_habit.dart               MirrorHabit.store (default = Firestore, swappable)
ui/
  mirror_habit_copy.dart        life-first copy
  mirror_habit_section.dart     the habit loop made visible
```

### Determinism

`MirrorHabitEngine` is pure over a `List<MirrorDayRecord>` + a `today` date:

- **streak** — counts consecutive opened days back from today (with a one-day
  grace if today isn't opened yet); also reports the longest run.
- **compare** — today vs yesterday focus-tone shift (brightened / softened /
  steady) and clarity delta.
- **period(7) / period(30)** — opened days, actions, reflections, reflection
  rate, dominant focus tone, most-focused area key.
- **trend(30)** — compares the first vs second half of the window's focus tone to
  read rising / steady / easing (needs ≥4 days, else unknown).
- **metrics** — totals, current/longest streak, days active in last 7/30,
  per-user retention flags (history old enough **and** active in the window),
  average sessions per week, reflection rate.

### Persistence (swappable seam)

`MirrorHabitStore` has two implementations:

- `FirestoreMirrorHabitStore` — default, persists to
  `users/{uid}/mirror_daily/{dateKey}` following the app's established
  conventions (`SetOptions(merge: true)`, `serverTimestamp`). Firebase is
  resolved **lazily and defensively**: with no signed-in user — or no initialized
  Firebase (preview/tests) — it simply persists nothing and returns no history.
- `InMemoryMirrorHabitStore` — for tests, preview and as a clean deterministic
  reference.

`MirrorHabit.store` is the app-wide default (Firestore) and is swappable in tests.

> Firestore security rules are not in this repo (console-managed). The new
> `mirror_daily` subcollection is owner-scoped like `profile` / `tests` /
> `funnel_telemetry`; a denied or failed write is caught and no-ops, so the loop
> UI keeps working from the locally-merged today record.

---

## The loop in the Daily Mirror

`DailyMirrorSection` (`lib/features/mirror_experience/ui/`) now:

1. **Open / Read** — on mount, loads recent records, upserts today's record
   (`opened = true`, seeded from the day's read), and builds a
   `MirrorHabitSnapshot`.
2. **Take Action** — tapping the suggested step marks `actionTaken` and persists.
3. **Reflect** — a one-tap "Which felt most true today?" (the opening / the
   caution / the focus) marks `reflected` + the deterministic choice and persists.
   Fires the new `dailyReflectionSaved` telemetry event.
4. **Return Tomorrow** — a gentle nudge ("Come back tomorrow to make it N in a
   row.").

The habit views render in a `MirrorHabitSection` below the read: streak header,
last-7 strip, Yesterday-vs-Today line, the reflect control, weekly/monthly tiles,
the life trend, and the return nudge.

---

## Measurement

`MirrorHabitEngine.metrics()` feeds an async **Daily Habit** panel on the
internal Product Validation dashboard (`/internal/product-validation`): current /
longest streak, opened days, days active in the last 7 / 30, 7-/30-day retention,
sessions per week and reflection rate. The panel reads `MirrorHabit.store` (the
persisted per-user records) and is independent of the in-memory telemetry funnel.

Telemetry: one additive event, `dailyReflectionSaved`, alongside the Phase C
`dailyMirrorOpened` / `dailyActionClicked` / `dailyConversationStarted`.

---

## Tests

- `test/validation/daily_habit_phase_d/mirror_habit_engine_test.dart` — streak
  (consecutive / grace / broken / empty), Yesterday-vs-Today, weekly reflection,
  life trend (rising / unknown), retention metrics (short vs old history), and
  snapshot determinism.
- `test/validation/daily_habit_phase_d/daily_habit_widget_test.dart` — the Daily
  Mirror renders the habit section, persists today's open, records a reflection
  (store + `dailyReflectionSaved`), and the dashboard renders habit metrics from
  a seeded store.

Phase C, Home V4, P3, Phase A and `HomeScreenV3` suites continue to pass (the
default Firestore store is safe to construct and no-ops without Firebase).

---

## Future work

- Surface streak / reflection-rate trends across users in the internal dashboard
  (currently per-user from a single store).
- Optional reminders / re-engagement once retention data is observed.
