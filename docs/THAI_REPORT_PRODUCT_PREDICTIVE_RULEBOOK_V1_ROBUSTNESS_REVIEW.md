# Product Predictive Rulebook V1 — Robustness Review

สถานะ: **DESIGN EVALUATION COMPLETE — RULES STILL PENDING OWNER APPROVAL**

Evaluation ใช้ calculation outputs จริงจาก pipeline ที่ `asOf=2026-08-29 Asia/Bangkok` ผ่าน design-only temporary probe ไม่มีการเพิ่ม runtime/test file เข้า commit

## Population

- Owner Known 00:03, Owner Known 00:35, Owner Unknown
- Synthetic non-Owner 12 profiles: birth years 1958–2010, times across 01:05–23:50 และหนึ่ง Unknown
- Known ascendants observed: Aries, Leo, Libra, Scorpio, Sagittarius, Aquarius
- Thai-day start planets observed: Sun, Moon, Mars, Jupiter, Venus, Saturn, Rahu
- Current ages 15–68; stages opening/peak/closing; harmony -4 through +6
- Optional relationship statuses cover single, partnered, married, complicated and not_disclosed

## Per-profile result

Abbreviations use rule families, not reader copy

| Profile | Known | Lagna / day start | Age / period / stage | Product rule atoms | Risk note |
|---|---:|---|---|---|---|
| owner_0003 | yes | Aquarius / Saturn | 44 / Venus / opening | current career role; current relationship clarity; next12 income | Candidate 0005 source set |
| owner_0035 | yes | Aquarius / Saturn | 44 / Venus / opening | same three atoms as 00:03 | identical-event-set risk; degrees differ but V1 rules do not consume degree |
| owner_unknown | no | none / not asserted | 44 internal date-only context | none | fail-closed |
| p01 | yes | Sagittarius / Rahu | 56 / Mars / opening | current career opportunity; current income; next12 career opportunity/role; past domain transition | no conflict |
| p02 | yes | Scorpio / Venus | 51 / Mercury / opening | past education/social transition | sparse but supported by proposed rule |
| p03 | yes | Sagittarius / Mars | 45 / Jupiter / peak | next12 career opportunity | event set repeats p07; other profile facts remain distinct |
| p04 | yes | Libra / Rahu | 37 / Sun / peak | current+next12 career ending, expense, health load, recovery pressure | no positive opposing atom |
| p05 | yes | Leo / Saturn | 34 / Rahu / peak | current career role | no conflict |
| p06 | yes | Aries / Jupiter | 31 / Rahu / closing | next12 income; next12 relationship clarity | no conflict |
| p07 | yes | Sagittarius / Saturn | 25 / Jupiter / closing | next12 career opportunity | event set repeats p03; period facts differ |
| p08 | yes | Sagittarius / Rahu | 22 / Venus / peak | next12 career role, income, relationship clarity/entry | status single supplied in design matrix |
| p09 | yes | Sagittarius / Moon | 61 / Jupiter / peak | current career opportunity/role; next12 career role | no conflict |
| p10 | yes | Aquarius / Rahu | 68 / Mercury / peak | current+next12 career ending, expense, relationship ending, health load, recovery; past domain transition | status married supplied; no entry atom |
| p11 | yes | Libra / Sun | 15 / Moon / peak | current relationship clarity/entry; past family duty | status single supplied |
| p12_unknown | no | none / not asserted | 42 internal date-only context | none | fail-closed |

## Rule fires

Counts combine current and next12 firings for one rule ID The life-period transition fact is counted separately

| Rule | Profiles with at least one fire | Rate of 15 | Assessment |
|---|---:|---:|---|
| `PPR-PAST-FAMILY-DUTY-001` | 1 | 6.7% | retained; one positive case |
| `PPR-PAST-EDUCATION-SOCIAL-001` | 1 | 6.7% | retained; one positive case |
| `PPR-PAST-DOMAIN-TRANSITION-001` | 2 | 13.3% | retained; domain resolver required |
| `PPR-CAREER-ROLE-001` | 7 | 46.7% | not near-universal |
| `PPR-CAREER-OPPORTUNITY-001` | 5 | 33.3% | not near-universal |
| `PPR-CAREER-ENDING-001` | 2 | 13.3% | fires both horizons for two profiles |
| `PPR-INCOME-001` | 5 | 33.3% | not near-universal |
| `PPR-EXPENSE-001` | 2 | 13.3% | fires both horizons for two profiles |
| `PPR-RELATIONSHIP-CLARITY-001` | 5 | 33.3% | status-neutral copy required |
| `PPR-RELATIONSHIP-ENTRY-001` | 2 | 13.3% | requires explicit single input |
| `PPR-RELATIONSHIP-ENDING-001` | 1 | 6.7% | requires explicit non-single input |
| `PPR-HEALTH-LOAD-001` | 2 | 13.3% | medical-safe vocabulary only |
| `PPR-RECOVERY-001` | 2 | 13.3% | no recovery-easing output |
| `PPR-LIFE-PERIOD-TRANSITION-001` | 13 | 86.7% | above 80%; retained only as exact Known-time boundary fact, never event narrative |

Product-inference atoms fired 47 times across horizons; boundary facts available for 13 Known profiles Total evaluated outputs 60 Rules with zero fires: 0 Rules above 80%: 1 exact boundary rule with documented genericity boundary

## Required risk checks

| Gate | Result |
|---|---:|
| Identical full event set across all profiles | 0 |
| Unique product event sets | 12 / 15 |
| Unresolved contradictory atoms | 0 |
| Unsupported atoms labeled approved/current | 0 |
| Known-to-Unknown leakage | 0 |
| Fixture-name/date/time branches | 0 |
| Unknown product event fires | 0 / 2 profiles |
| Rules never firing | 0 |

Three pairwise duplicate-set risks remain: 00:03/00:35, p03/p07 and the two Unknown profiles This is not hidden 00:03 and 00:35 differ in degree but Rulebook V1 consumes lagna-lord structure, not degree Unknown deliberately converges to omissions Adding degree-sensitive behavior solely to separate the Owner fixtures is prohibited

## Decision

The population check shows thresholds are selective and fail closed, but it does not validate the astrology meaning of the proposed role sets or event mappings Every product inference remains `OWNER_RULE_REVIEW_REQUIRED` Robustness PASS authorizes review only, not implementation
