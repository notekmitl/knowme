# KnowMe BaZi Reader V3

Status: governed implementation contract for
`knowme_bazi_reader_v3` and Thai interpretation contract
`knowme_bazi_reader_th_v3`.

## Purpose

Reader V3 retains the sourced Reader V2 BaZi and Thai interpretation layers
and replaces the known-time wall-clock basis with auditable apparent solar
time. This is a versioned KnowMe contract, not a claim of one universal BaZi
school standard or scientific proof of personality.

## Known birth time

Known time requires all of the following:

- Gregorian birth date and `HH:mm` local civil clock time;
- an IANA timezone name;
- finite WGS84 latitude in `[-90, 90]`; and
- finite WGS84 longitude in `[-180, 180]`.

The civil clock is resolved with `zoneinfo.ZoneInfo`. The UTC offset used is
the historical offset at the birth date and time, including daylight-saving
rules that were in force. A nonexistent civil clock reading in a forward DST
gap is rejected. A repeated civil clock reading in a backward DST fold is also
rejected because the current input contract has no explicit fold selector.
Reader V3 never chooses either case by guess.

Reader V3 then applies NOAA's fractional-year Equation of Time approximation:

```text
gamma = 2*pi/days_in_year * (day_of_year - 1 + (decimal_hour - 12)/24)

EoT = 229.18 * (
  0.000075
  + 0.001868*cos(gamma)
  - 0.032077*sin(gamma)
  - 0.014615*cos(2*gamma)
  - 0.040849*sin(2*gamma)
)

true_solar_offset_minutes =
  EoT + 4*longitude_degrees_east - historical_utc_offset_minutes
```

The corrected Gregorian date and time, rounded to the nearest second, is sent
to `lunar_python@1.4.8`. Consequently the correction can change the Hour
pillar and, near midnight or a solar-term boundary, the Day, Month, or Year
pillar.

Each result records the original civil datetime with offset, timezone,
historical UTC offset, reference meridian, latitude, longitude, longitude
correction, Equation of Time, total correction, corrected datetime, method,
and rounding rule. The input fingerprint includes coordinates for known-time
results.

Reference case:

```text
Input:     1990-05-12 15:30 Asia/Bangkok
Location:  13.7563, 100.5018
UTC offset: +420 minutes
Longitude correction: -17.992800 minutes
Equation of Time:       +3.897586 minutes
Total correction:      -14.095214 minutes
Applied solar time:     1990-05-12 15:15:54
```

## Unknown birth time

An empty or null birth time remains unknown. Reader V3 does not create a noon,
midnight, midpoint, location-derived clock, or any other substitute time. The
existing date-level fail-closed path checks Year and Month invariance across
the whole civil date, omits transition-ambiguous values, always omits the Hour
pillar, and omits luck-cycle onset and other time-dependent output. Its
`solar_time.status` is `not_computed_unknown_birth_time` and its corrected
datetime is null. Coordinates do not enter the unknown-time fingerprint.

## Thai reader

The reader-first order is:

1. Four Pillars and Day Master;
2. overall picture;
3. identity and practical use of energy;
4. work;
5. money;
6. love and relationships;
7. cautions and balance;
8. the current ten-year cycle;
9. the current year; and
10. calculation facts, input, method, sources, and limitations.

The prose describes tendencies and practical trade-offs. It does not promise
an event, diagnosis, investment return, legal result, or relationship outcome.
If a cycle or annual fact is unavailable, the report says so instead of
inventing one.

## PDF contract

Dedicated PDF export uses embedded Thai regular/bold fonts plus a CJK fallback,
A4 pages, bounded cards, page numbers, and ASCII hyphens. Long source entries
stack their label and value so URLs can wrap inside the card. Acceptance
requires Poppler rendering of every page and visual confirmation of readable
Thai/Chinese text with no clipping, overlap, overflow, blank accidental page,
replacement glyph, or broken fallback.

## Primary calculation sources

- NOAA Global Monitoring Laboratory, *General Solar Position Calculations*:
  https://gml.noaa.gov/grad/solcalc/solareqns.PDF
- IANA Time Zone Database:
  https://www.iana.org/time-zones
- Python `zoneinfo` and `fold` behavior:
  https://docs.python.org/3.12/library/zoneinfo.html
- Hong Kong Observatory, Heavenly Stems and Earthly Branches:
  https://www.hko.gov.hk/en/gts/time/stemsandbranches.htm
- Hong Kong Observatory, The 24 Solar Terms:
  https://www.hko.gov.hk/en/gts/time/24solarterms.htm
- 6tail `lunar-python` v1.4.8:
  https://github.com/6tail/lunar-python/tree/v1.4.8

The Thai interpretation references from Reader V2 remain Joey Yap's *BaZi
Essentials - The Ten Day Masters* (ISBN 9789675395321) and *The Power of X:
Enter the 10 Gods* (ISBN 9789675395918). KnowMe paraphrases the framework and
does not reproduce source passages.
