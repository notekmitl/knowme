# Task: Thai Ascendant Correctness V1

Audit and minimally repair the Thai Foundation ascendant calculation against
an independent Swiss Ephemeris 2.10.03 oracle. The product contract remains
sidereal zodiac, Lahiri ayanamsha, and whole-sign houses.

Base: PR #82 HEAD `a20be549f8a25f529d539bb7f23734af469b8c50`.
PR #83 remains a separate Draft and must not receive Engine source changes.

The repair must fail closed for explicit unknown province keys, normalize the
supported Chiang Mai key forms without silently using Bangkok, preserve the
civil astronomical instant across the sunrise-day boundary, and compute the
approved synthetic audit instant at Aquarius 19°19′ within documented
approximation tolerance. No Swiss Ephemeris production dependency, Canon,
prediction, feature flag, Production data, merge, or deploy is allowed.

The owner approved a controlled screenshot rebaseline only for the QA harness
Known-time Profiles A–G whose rendered evidence changes directly from this
Engine correction. Profile H unknown-time, the standalone Thai Mirror golden,
test thresholds, Gate scripts, and every other golden remain unchanged. Every
changed image requires before/after visual inspection and two consecutive
24/24 screenshot runs from identical source and baseline.
