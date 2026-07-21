# Chinese Zodiac Impact Validation V1

Generated: 2026-06-28T06:34:31.920944Z
Profiles: 24

## Validation Methodology
Controlled A/B comparison per profile:
A) BaZi core only (Day Master + Dominant Element + Element Balance)
B) BaZi core + Chinese Zodiac Year Animal (runtime integration path)

Each arm runs through:
1. Lens theme outputs (Western baseline + BaZi arm)
2. Astrology Fusion Generator (cross-lens agreements/tensions/signals)
3. Simulated downstream pipeline (validation-only lens→mirror bridge):
   Global Fusion Foundation → Human Model → Human Pattern → Narrative Runtime

Fixed Western chart (Aries/Cancer/Leo) and fixed overlapping personality mirror
(MBTI + Big Five with expressive/driven/supportive themes) hold non-BaZi inputs
constant so deltas isolate Year Animal impact.

### Production Scope Note
Production KnowMeRuntimePipeline currently feeds Thai astrology into Mirror Platform;
BaZi Zodiac integrates at BaziRealAdapter → AstrologyFusionGenerator today.
Downstream Mirror→Global Fusion→Human Model→Narrative metrics use a validation-only
bridge that maps BaZi fusion themes into MV1 signals without modifying frozen systems.


## Before vs After Metrics (Aggregate)
| Metric | Before (Core) | After (+Zodiac) | Delta |
| --- | ---: | ---: | ---: |
| themeCountTotal | 216 | 382 | 166 |
| themeCountAvg | 9 | 15.92 | 6.92 |
| fusionAgreementsTotal | 96 | 164 | 68 |
| fusionAgreementsAvg | 4 | 6.83 | 2.83 |
| fusionTensionsTotal | 60 | 90 | 30 |
| fusionTensionsAvg | 2.50 | 3.75 | 1.25 |
| fusionSignalsTotal | 84 | 108 | 24 |
| fusionSignalsAvg | 3.50 | 4.50 | 1 |
| globalAgreementsTotal | 0 | 0 | 0 |
| globalAgreementsAvg | 0 | 0 | 0 |
| globalTensionsTotal | 0 | 42 | 42 |
| globalTensionsAvg | 0 | 1.75 | 1.75 |
| globalReinforcementsTotal | 0 | 0 | 0 |
| globalReinforcementsAvg | 0 | 0 | 0 |
| globalBlindSpotsTotal | 84 | 92 | 8 |
| globalBlindSpotsAvg | 3.50 | 3.83 | 0.33 |
| humanPatternCountTotal | 84 | 118 | 34 |
| humanPatternCountAvg | 3.50 | 4.92 | 1.42 |
| humanActivationCountTotal | 192 | 225 | 33 |
| humanActivationCountAvg | 8 | 9.38 | 1.38 |
| narrativeParagraphCountTotal | 144 | 165 | 21 |
| narrativeParagraphCountAvg | 6 | 6.88 | 0.88 |
| narrativeEvidenceCountTotal | 144 | 188 | 44 |
| narrativeEvidenceCountAvg | 6 | 7.83 | 1.83 |
| narrativeConfidenceAvg | 0.41 | 0.47 | 0.06 |

## High-Value Animals
- Rooster (rooster)
- Snake (snake)
- Rabbit (rabbit)
- Ox (ox)

## Low-Value Animals
- Dog (dog)
- Horse (horse)
- Monkey (monkey)
- Tiger (tiger)

## Theme Collisions
- `supportive` — 16 profiles
- `driven` — 10 profiles
- `expressive` — 8 profiles
- `leadership` — 8 profiles
- `independent` — 6 profiles
- `growth_focused` — 6 profiles
- `reliable` — 6 profiles
- `passionate` — 6 profiles
- `responsive` — 6 profiles
- `persistent` — 4 profiles
- `calm` — 2 profiles

## Narrative Impact
Of 24 profiles: 13 gained paragraphs with evidence anchors; 0 grew longer without new evidence; 11 unchanged at narrative layer.

## Duplication Analysis
Across all profiles: 166 net-new zodiac theme slots vs 78 theme collisions with BaZi core. Most repeated collisions: supportive (16 profiles), driven (10 profiles), expressive (8 profiles), leadership (8 profiles), independent (6 profiles).

## Per-Profile Summary
| Profile | Animal | Tier | Theme Δ | Pattern Δ | Narrative Δ |
| --- | --- | --- | ---: | ---: | ---: |
| rat_a | Rat | HIGH | 8 | 2 | 0 |
| rat_b | Rat | MEDIUM | 7 | 2 | 1 |
| ox_a | Ox | MEDIUM | 7 | 1 | 0 |
| ox_b | Ox | HIGH | 8 | 2 | 2 |
| tiger_a | Tiger | LOW | 6 | 2 | 0 |
| tiger_b | Tiger | MEDIUM | 7 | 2 | 1 |
| rabbit_a | Rabbit | HIGH | 8 | 2 | 0 |
| rabbit_b | Rabbit | HIGH | 9 | 3 | 3 |
| dragon_a | Dragon | HIGH | 7 | 1 | 0 |
| dragon_b | Dragon | HIGH | 6 | 1 | 1 |
| snake_a | Snake | HIGH | 9 | 1 | 0 |
| snake_b | Snake | HIGH | 9 | 1 | 1 |
| horse_a | Horse | MEDIUM | 6 | 1 | 1 |
| horse_b | Horse | LOW | 5 | 1 | 1 |
| goat_a | Goat | LOW | 6 | 1 | 0 |
| goat_b | Goat | MEDIUM | 6 | 2 | 2 |
| monkey_a | Monkey | HIGH | 6 | 0 | 0 |
| monkey_b | Monkey | MEDIUM | 5 | 0 | 0 |
| rooster_a | Rooster | HIGH | 8 | 1 | 1 |
| rooster_b | Rooster | HIGH | 9 | 2 | 3 |
| dog_a | Dog | NONE | 4 | 1 | 0 |
| dog_b | Dog | MEDIUM | 6 | 2 | 2 |
| pig_a | Pig | LOW | 7 | 1 | 0 |
| pig_b | Pig | MEDIUM | 7 | 2 | 2 |

## Recommendation
KEEP AND PROMOTE: Zodiac adds measurable fusion and downstream richness (19/24 profiles MEDIUM+ impact) without material tension inflation. Prioritize wiring BaZi zodiac into production Mirror path so live users receive Human Pattern and Narrative gains.

