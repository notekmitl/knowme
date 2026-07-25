# Thai Life Map V1.2.7 — Simulated 864 Profile Matrix

**Status:** COMPLETED
**Fixtures:** synthetic QA only (no real-user PII / Auth / Firestore)
**Reference clock:** `2026-07-15T12:00:00.000` (Asia/Bangkok)
**Production Canon / formulas / invited_beta:** unchanged (matrix + optional `asOf` plumbing only)

## Core matrix

| Metric | Value |
|--------|------:|
| Generated | 864 |
| Executed | 864 |
| Skipped | 0 |
| Passed | 864 |
| Failed | 0 |
| Mahabhut 8/0 | 375 |
| Mahabhut with unknown | 489 |

## By weekday category

| Category | Pass | Fail |
|----------|-----:|-----:|
| วันอาทิตย์ (`sunday`) | 108 | 0 |
| วันจันทร์ (`monday`) | 108 | 0 |
| วันอังคาร (`tuesday`) | 108 | 0 |
| วันพุธกลางวัน (`wednesday_day`) | 108 | 0 |
| วันพุธกลางคืน (`wednesday_night`) | 108 | 0 |
| วันพฤหัสบดี (`thursday`) | 108 | 0 |
| วันศุกร์ (`friday`) | 108 | 0 |
| วันเสาร์ (`saturday`) | 108 | 0 |

## Age-band distribution (current age)

| Band | Count |
|------|------:|
| earlyChildhood | 48 |
| schoolAge | 48 |
| teen | 40 |
| youngAdult | 96 |
| workingAdult | 160 |
| midlife | 120 |
| elder | 352 |

## Unresolved Mahabhut reasons

| Reason | Count |
|--------|------:|
| `AMBIGUOUS_ARCHETYPE_PLANET_PLACEMENT` | 1225 |
| `AMBIGUOUS_MAHABHUT_POSITION` | 144 |
| `SOURCE_CONFLICT_ARCHETYPE_PLANET_PLACEMENT` | 112 |

## Failed fixture IDs

_None_

## Boundary suite

Boundary assertions live in `thai_life_map_v127_boundary_test.dart` (Wednesday second-cutoff, ThaiBeta minute before/after sunset, birthday/year/leap, ages 1 & 108, pre-sunrise astrological-date rollover). Core matrix markdown does not re-execute that suite; CI runs both files.
