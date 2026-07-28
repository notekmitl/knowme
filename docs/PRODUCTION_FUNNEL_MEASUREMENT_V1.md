# Production Funnel Measurement V1

**Status:** COMPLETE — first privacy-safe Production aggregate

**Measured:** 28 July 2026

**Decision:** **IMPROVE**

**Production writes / deploy:** none

## Outcome

The existing telemetry is sufficient to produce a narrow authenticated-user
funnel, but the cohort is too small to claim that Funnel Recovery V2 caused an
improvement. The largest observed loss is **eligible → MBTI started**.

| Stage | Unique users | Rate | Formula |
|---|---:|---:|---|
| Eligible | 4 | 100% | `4 / 4` |
| MBTI started | 2 | 50% | `2 / 4 eligible` |
| MBTI completed | 1 | 25% of eligible | `1 / 4 eligible` |
| MBTI completed after start | 1 | 50% of starters | `1 / 2 started` |
| Narrative preview reached | 1 | 25% | `1 / 4 eligible` |

Drop-off:

| Transition | Lost | Rate |
|---|---:|---:|
| Eligible → MBTI started | 2 | `2 / 4 = 50%` |
| MBTI started → completed | 1 | `1 / 2 = 50%` |
| MBTI completed → Narrative preview | 0 | `0 / 1 = 0%` |

The first transition is the single bottleneck because it loses the largest
absolute number of eligible users.

## Cohort and time window

- Timezone: `Asia/Bangkok` (`UTC+07:00`; Thailand has no daylight-saving change).
- Inclusive start: `2026-06-23 00:00`.
- Exclusive end: `2026-07-28 00:00`; the incomplete 28 July day is excluded.
- The repository contains telemetry in the 21 June architecture snapshot
  (`780a4c1`), and the first observable Production telemetry is 23 June. Because
  no authoritative first-deploy timestamp exists for Funnel Recovery V2, the
  start is an **observable-data boundary**, not a claimed release instant.
- Eligible means an authenticated unique user with `profile.birthDate` and at
  least one `home_view` event in the window.

This is an activity cohort. It can include an account created before the window
if that account opened Home during the window.

## Event inventory and semantics

| Event/source | Emission point | Meaning used | Timestamp | Coverage / risk |
|---|---|---|---|---|
| `home_view` | `HomePage.initState` | Home opened | log `createdAt`, fallback client `at` | Authenticated only; does not prove the astrology report was read |
| `mbti_start` | Home unlock/test CTA and `MbtiMiniTestPage` bootstrap | Unique eligible user entered MBTI path | same | Duplicate rows expected because more than one call site emits it |
| `mbti_complete` | after `saveResult` and `markCompleted` succeed | Saved MBTI completion | same | Strong completion semantic |
| `narrative_preview_seen` | after MBTI preview loading finishes | Narrative preview reached | same | Preview reach, not the historical full Narrative pipeline definition |

The tracker also contains Big Five and EQ events, but they are not combined
with the requested MBTI funnel.

Storage:

```text
users/{uid}/funnel_telemetry/{event}        summary count + last seen
users/{uid}/funnel_telemetry/_events/log/*  event log
```

Firestore rules make these documents owner-only. The measurement service
account reads them locally; identifiers are used only as in-memory set keys and
are never emitted.

## Data quality

- 4 unique eligible users: below the decision minimum of 20.
- 126 timestamped event rows in the completed window; 0 invalid timestamps.
- 115 repeated rows beyond the first per user/event, dominated by recurring
  `home_view`; event-row totals are therefore never treated as people.
- `mbti_start` has multiple call sites, so only unique users are counted.
- Anonymous coverage is zero by design: `FunnelTelemetry.track` returns when
  Firebase Auth has no UID.
- No invalid completion-before-start or preview-before-completion ordering was
  observed.
- Client `at` can differ from server `createdAt`; the command prefers server
  time and uses client time only as fallback.
- No pre-release control cohort with identical semantics exists.

## Baseline and target

The historical 2.6% baseline is `1 / 38` Firestore accounts reaching at least
one generated full-Narrative paragraph. This V1 result is `1 / 4` active,
astrology-ready authenticated users reaching the MBTI Narrative preview.

Those denominators and Narrative definitions differ, so **the apparent
2.6% → 25% change must not be interpreted as causal lift or compared directly**.
The current rate numerically equals the 25% product target, but the sample is
not decision-sized.

## Decision: IMPROVE

Keep the current telemetry and measurement command, but do not claim Funnel
Recovery V2 effectiveness yet. The single product transition to examine after
a decision-sized cohort is **eligible → MBTI started**. This task does not
change that transition or any UI.

Re-evaluate KEEP / IMPROVE / STOP when at least 20 eligible users exist in a
completed window with the same definitions:

- KEEP if Narrative preview reach is at least 25%.
- IMPROVE if reach is below 25% but non-zero; use the largest observed
  transition.
- STOP if a decision-sized eligible cohort produces zero Narrative reach.

## Repeatable read-only command

Prerequisite: local gitignored
`backend/firebase/serviceAccountKey.json`. Never commit it.

```powershell
python tool/production_funnel_measurement.py `
  --start 2026-06-23 `
  --end 2026-07-28
```

`--start` is inclusive and `--end` is exclusive Bangkok date. With no `--end`,
the command uses today's Bangkok date as the exclusive boundary, excluding the
partial current day. Optional `--output <path>` writes only the aggregate JSON.

Focused test:

```powershell
python -m unittest discover `
  -s test/validation/production_funnel_measurement_v1 `
  -p "test_*.py" -v
```

The command is read-only and adds no analytics provider or paid service.
