# Western Astrology Reader V2

## Purpose

Western Reader V2 replaces the legacy sign-card result with a deterministic
whole-chart reading in Thai. Calculation stays local to the authenticated
KnowMe backend; no LLM or Firestore lookup participates in the astronomical
calculation.

## Calculation contract

- Chart schema: `western_natal_v2`
- Reader contract: `knowme_western_reader_v2`
- Engine: `swiss_ephemeris_tropical_placidus_v2`
- Zodiac: tropical
- Houses: Placidus
- Required input: Gregorian birth date, known local civil time, IANA timezone,
  latitude, and longitude

The backend resolves the submitted local civil time through the IANA timezone
before converting it to UTC and then to a Julian day. Nonexistent or ambiguous
DST clock readings fail closed. It never treats a local clock as UTC and never
guesses a missing time or location.

The chart records normalized inputs, local civil datetime, UTC instant, engine
identity, and an input SHA-256. The Reader covers:

- Sun, Moon, and Ascendant;
- element, modality, and polarity balance;
- deterministic planet dominance;
- emphasized houses;
- conjunction, sextile, square, trine, and opposition ordered by exactness;
- work, money, love, wellbeing, strengths, cautions, and practical guidance.

The first release intentionally excludes transits, progressions, event timing,
and guaranteed predictions.

## Owner correctness case

Input: `1982-06-06 00:03`, Chiang Mai (`18.7883, 98.9853`),
`Asia/Bangkok`.

- Local civil: `1982-06-06T00:03:00+07:00`
- UTC instant: `1982-06-05T17:03:00Z`
- Big 3: Gemini Sun, Sagittarius Moon, Pisces Rising

Legacy V1 used `1982-06-06 00:03` directly as UT and therefore produced the
wrong Cancer Ascendant. V2 locks the corrected Pisces result in backend tests.

## Generation path and latency

The selected Western flow performs one authenticated
`POST /v1/generate-chart`. The backend calculates the chart and commits the
canonical profile, `astrology/western_natal`, `results/astrology`, and Fusion
invalidation in one Firestore batch. The response contains the saved chart and
the client hands that object directly to the result page.

This removes the previous client profile save, Firestore freshness read,
browser Fusion mirror, second lens probe, and destination reload from the
primary flow. The fallback coordinator also stops re-reading and mirroring the
chart after a successful Western response.

`scripts/benchmark_western_v2.py` measures the pure deterministic engine over
three Thai locations. The release threshold is a median below 25 ms per case;
the initial 500-iteration local run measured 0.118–0.123 ms medians. Production
click-to-result latency is a separate acceptance gate because network, Cloud
Run, Firestore, and browser rendering dominate that number.

## Security and persistence

Both the versioned and deprecated generation paths require a verified Firebase
ID token, and the request UID must match the token UID. The optional canonical
profile must match the calculation birth fields before it can be written.
Generation either commits the profile/chart/snapshot/invalidation batch once or
returns a failure; it does not expose a partially updated primary flow.

## Validation

Release validation includes backend correctness/auth/save tests, Dart model and
copy tests, direct-handoff/provider tests, legacy Fusion fingerprint regression,
responsive result-page widget tests at 390 px and 1280 px, full Flutter tests,
analyzer, benchmark, Production Web build, and live authenticated desktop/mobile
timing after Backend-first deployment.

The source candidate passes backend 46/46, focused Flutter 51/51, complete
Flutter 3,093/3,093, analyzer policy with 275 inherited non-fatal diagnostics
and no task-source diagnostic, the three-case benchmark, and the
Production-configured Web build in GitHub CI run `35508539559`. Live timing is
not inferred from the pure-engine benchmark and remains a post-deployment gate.
