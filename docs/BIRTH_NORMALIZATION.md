# Birth Normalization Foundation

> The **single birth-input layer** for every astrology system. Raw user birth
> information in, one normalized birth artifact out — with a real, location-aware
> sunrise day boundary for Thai.

Status: **CURRENT** · Architecture only (no deploy). Decision Log **D-035**.

---

## Goal

Convert raw user birth information into normalized birth data **once**, before any
astrology engine runs, so every system shares the same resolved location,
timezone, calendar and (for Thai) day boundary.

```
Raw User Input
      ↓
Birth Normalization        (lib/features/birth_normalization/)
      ↓
Thai Birth Context · Western Birth Context · BaZi Birth Context (placeholder)
      ↓
Astrology Engines
```

## Contract (the rule)

- **No astrology engine may consume `RawBirthInput` directly.** Every engine
  consumes `NormalizedBirth` (or its per-system context).
- The **Thai** pipeline is migrated (see *Migration* below): its engine input is
  built only from `ThaiBirthContext`. Western/BaZi remain context-only until
  those engine paths are built, consistent with the project's stability-first,
  additive posture.

---

## Inputs

`RawBirthInput`: birth date, optional birth time (`birthHour`/`birthMinute`,
null = unknown), province, country, free-text place, timezone id, and optional
explicit coordinates. `RawBirthInput.fromProfileMap` maps the existing
`users/{uid}/profile/main` doc (`birthDate`, `birthTime`, `birthPlace`,
`latitude`, `longitude`, `timezone`).

## Output — `NormalizedBirth`

| Field | Meaning |
|---|---|
| `raw` | the original `RawBirthInput` |
| `location` | resolved `BirthLocation` (lat/lng + source) |
| `timeZone` | resolved `BirthTimeZone` (id + fixed UTC offset) |
| `calendar` | `BirthCalendar` (Gregorian today) |
| `sunrise` / `sunriseAvailable` | local sunrise on the civil birth date |
| `thai` | `ThaiBirthContext` — sunrise-based astrological date |
| `western` | `WesternBirthContext` — exact instant, no day shift |
| `bazi` | `BaZiBirthContext` — **placeholder**, not implemented |
| `reasons` | `List<BirthNormalizationReason>` — every choice, traceable |

`BirthNormalizationResult` wraps either a valid `NormalizedBirth` or an explained
failure (e.g. missing/unparseable birth date).

---

## Thai normalization — sunrise day boundary

The Thai astrological day begins at **local sunrise**, not a fixed clock time.

- Compute **true local sunrise** for the birth date + coordinates + timezone
  (`SunriseCalculator`, the standard Almanac algorithm, official zenith 90.833°).
- If the birth instant is **before** local sunrise → `astrologicalDate` =
  **previous** calendar day. Otherwise → same day.
- **Never hardcoded to 06:00.** It is location-aware (lat/lng), season-aware
  (date), and timezone-aware (offset). This supersedes the legacy frozen
  `ThaiDayBoundary` (06:00) — now a deprecated shim (see *Migration* below).
- No birth time → noon is assumed (after sunrise everywhere outside polar
  regions, so Thai resolves to the same day — the safe default), recorded as a
  reason.
- Polar latitudes/dates where the sun does not rise → no day shift, recorded as
  a reason.

## Western normalization

Uses the **actual astronomical instant** (`localDateTime − utcOffset`). **No day
adjustment.**

## BaZi normalization

**Adapter only — not implemented.** `BaZiBirthContext` carries the raw instant so
the `NormalizedBirth` shape is stable; `implemented` is always `false`. Real BaZi
normalization (true solar time + solar-term month-pillar boundaries) is future
work.

---

## Determinism

Everything is a pure function — no clock, no I/O, no network. Same `RawBirthInput`
→ identical `NormalizedBirth` (sunrise, Thai date, reasons). The sunrise
calculator is self-contained math (no astronomy/timezone package dependency).

Location resolution uses the canonical **77-province** table
(`application/thai_provinces.dart`: name, lat/lng, timezone, source — provincial
capital coordinates, WGS84) plus a regional-country table and fixed no-DST
offsets. Birth Normalization resolves **every** Thai province, and the same table
feeds the Research province picker so the selectable set can never drift from the
resolvable set. Explicit coordinates from the location picker remain the
highest-priority production path; the tables are a sensible fallback, not a
geocoder. Unknown location/timezone defaults to Bangkok (Thai-first), recorded as
a reason.

---

## Package layout

```
lib/features/birth_normalization/
  birth_normalization.dart            barrel export
  domain/
    raw_birth_input.dart              RawBirthInput (+ fromProfileMap)
    birth_location.dart               BirthLocation + BirthLocationSource
    birth_time_zone.dart              BirthTimeZone
    birth_calendar.dart               BirthCalendar
    birth_normalization_reason.dart   BirthNormalizationReason
    thai_birth_context.dart           ThaiBirthContext
    western_birth_context.dart        WesternBirthContext
    bazi_birth_context.dart           BaZiBirthContext (placeholder)
    normalized_birth.dart             NormalizedBirth
    birth_normalization_result.dart   BirthNormalizationResult
  application/
    sunrise_calculator.dart           deterministic local sunrise
    birth_time_zone_resolver.dart     id → fixed offset
    thai_provinces.dart               canonical 77-province table (name/lat/lng/tz/source)
    birth_location_resolver.dart      explicit / province / country / default
    birth_normalizer.dart             BirthNormalizer (entry point)
    adapters/
      thai_birth_adapter.dart       Normalized internals → ThaiBirthContext
      thai_engine_adapter.dart      ThaiBirthContext / profile → ThaiBirthData (engine seam)
      western_birth_adapter.dart
      bazi_birth_adapter.dart
```

Birth Normalization owns **all** adapters (including the `ThaiEngineAdapter` bridge
to the engine model). Thai owns only `ThaiBirthData`.

---

## Migration — Thai pipeline (DONE)

The Thai engine input is now produced **exclusively** from a normalized
`ThaiBirthContext`. Birth Normalization is the single source of truth for
timezone, coordinates and the sunrise day boundary — the raw `birthDate`/
`birthTime` parsing and duplicated timezone logic that lived in each loader are
removed.

```
RawBirthInput → BirthNormalizer → ThaiBirthContext → ThaiEngineAdapter → ThaiBirthData → Thai Engine
```

1. **Single seam:** `ThaiEngineAdapter` (`birth_normalization/application/adapters/`)
   is the **one** adapter from normalized birth to the Thai engine model:
   `fromContext` / `fromNormalized` / `fromProfileMap`. **Birth Normalization owns
   the adapter; Thai owns only the engine model `ThaiBirthData`** (a pure data
   class — no `fromThaiContext`, no import of normalization). See D-037.
2. **Both production loaders route through it** — no more local parsing or
   `_offsetForTimezone`/`_timeZoneOffset` duplication:
   - `user_profile_birth_loader.dart` (narrative runtime)
   - `FirestoreAstrologyFusionLensProbe.thaiBirthDataFromProfile` (fusion)
3. **Day boundary:** `ThaiBirthData.astrologicalDate` carries the sunrise-based
   date. `ThaiBirthData.localDateTime` still keeps the **exact** civil instant —
   the astronomical lagna and the exact-datetime verified-lunar lookup must not
   shift a day. The verified lunar dataset is keyed on the exact civil datetime
   (the boundary-adjusted weekday is baked into the data), so that lookup is
   deliberately left unchanged and the golden cases (GC-04/GC-05) still pass.
4. **`ThaiDayBoundary` is a deprecated shim.** It no longer hardcodes 06:00 — it
   delegates to the same `SunriseCalculator` (Bangkok reference point). New code
   must read `ThaiBirthContext.astrologicalDate`.

Behaviour is preserved for the Thai (Asia/Bangkok) user base. The one intentional
correctness improvement: non-Bangkok timezones now resolve to their real offset
instead of the previous fusion-probe default of UTC/ICT.

Western/BaZi engines consume their contexts when those paths are built (future).

---

## Thai Astrological Date — one source for every layer (D-042)

The Thai day shown in the Summary must be the day **every** layer reasons from.
A before-sunrise birth (e.g. Sunday 00:30, sunrise ~05:48) is astrologically the
**previous** day (Saturday), and Foundation, Life Timeline, Prediction, Decision,
Question, Runtime and the Consumer report must all start from Saturday.

**The contract:**

- `ThaiBirthData.astrologicalDate` is the **single normalized Thai date** (the
  sunrise day boundary from `ThaiBirthContext`). `ThaiBirthData.thaiWeekdayNumber`
  (อาทิตย์=1 … เสาร์=7) is derived from it and is the **only** Thai weekday source.
- **No layer recomputes the weekday from the civil date.** No layer reads
  `localDateTime`/`dateOnly` for the Thai day.
- `localDateTime` stays the exact civil instant — used **only** as the lagna time
  and as the verified-lunar lookup key (the dataset bakes the sunrise-adjusted
  weekday into the record, so GC-04/GC-05 already return the previous-day weekday).

**Fixes applied:**

- `ThaiMirrorPipeline` now feeds the Life Timeline via
  `LifePeriodEngine.fromBirthData(birthData)` (astrological date), not
  `fromBirthDate(birthData.dateOnly)` (civil date).
- `ThaiMirrorProfileEnrichment` derives its weekday/day-based fallback keys from
  `astrologicalDate` / `thaiWeekdayNumber`, not `localDateTime`.
- `LifePeriodEngine.fromBirthData` and
  `LifeTimelineIntelligenceEngine.fromBirthData` are the preferred,
  consistency-safe entry points (V10–V13 inherit the timeline they build).

---

## Tests

`test/validation/birth_normalization/birth_normalization_test.dart` — before/after
sunrise → correct Thai day; season, province and timezone all change sunrise;
no-birth-time noon assumption; Western exact instant + no shift; BaZi placeholder;
explicit-vs-default location; default timezone; invalid input; profile-map
round-trip; and determinism.

`test/validation/birth_normalization/thai_birth_normalization_migration_test.dart`
— migration seam: `ThaiEngineAdapter.fromContext` (before/after sunrise, exact
instant preserved, `dateOnly` fallback); `ThaiEngineAdapter.fromProfileMap`
(Bangkok profile, before-sunrise roll-back, noon assumption, null on no date);
`UserProfileBirthLoader.fromMap` legacy field regression; and `ThaiDayBoundary`
shim agreeing with `astrologicalDate`. The existing
`test/thai_foundation_engine_test.dart` (incl. GC-04/GC-05 + the `ThaiDayBoundary`
audit) still passes unchanged.

`test/validation/thai/thai_astrological_date_consistency_test.dart` — the D-042
regression: birth Sunday 00:30 (before sunrise) → astrological date Saturday, and
**every** layer (normalization, Foundation enrichment, Life Timeline, Timeline
Intelligence, Prediction, Decision, Question, Runtime, Consumer pipeline) starts
from Saturday; the civil date would (wrongly) start from Sunday.

## Related docs

`ARCHITECTURE.md`, `DOMAIN_MODEL.md`, `ROADMAP.md`, `DECISION_LOG.md` (D-035,
D-036, D-042), `THAI_FOUNDATION_ENGINE_V1_1_NOTES.md` (legacy 06:00 boundary),
`PROJECT_INDEX.md`.
