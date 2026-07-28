# Thai Birth Profile Core Reading V1

**Status:** Implemented for `/beta/thai`  
**Scope:** Thai Beta presentation + PDF only  
**Engine/Canon:** unchanged

## Product decision

Thai Astrology Beta now leads with **“ดวงจากวันเกิดของคุณ”**. The lifelong
birth-profile reading appears before Life Timeline and future-period content.
The product sequence is Thai Astrology quality and real-person validation
first; Chinese, Western, Fusion, psychology, MBTI, and Funnel work are not part
of this phase.

## Root cause

The accepted Thai Beta page passed `personalCoreFirst: true`, but
`ThaiMirrorResultPage` still rendered:

1. hero;
2. personal signature;
3. Life Timeline;
4. current/future prediction;
5. life dashboard and narrative sections.

The first substantial report was therefore age/period-oriented. It did not
assemble the existing lifelong computed facts into one explicit birth-profile
report.

## Source of truth

`ThaiBirthProfileCoreReading.fromAnalysis(analysis)` consumes the same
`ThaiBetaAnalysis` already used by the web report and PDF:

```
ThaiBetaInput
  → BirthNormalizer (province coordinates, Asia/Bangkok, local sunrise)
  → ThaiEngineAdapter
  → Thai Foundation Engine
       sidereal zodiac · Lahiri ayanamsa · whole-sign houses
  → ThaiMirrorPipeline / Mirror themes and evidence
  → ThaiBetaNarrativeComposer
  → ThaiBirthProfileCoreReading
       ├─ web section
       └─ PDF export sections
```

No second analysis, AI, external API, random selection, QA fallback, or
hardcoded real-person reading is used.

## Computed-fact inventory

| Input/fact | Calculation source | Core Reading use |
|---|---|---|
| Civil birth date | `ThaiBetaInput` | normalization input |
| Province/place | Birth location resolver | coordinates and local sunrise |
| Birth time, when supplied | normalized local datetime | sunrise boundary and ascendant |
| Local sunrise | `SunriseCalculator` | Thai astrological day explanation |
| Thai astrological date/weekday | `BirthNormalizer` / `ThaiBirthData` | chart structure |
| Lagna, when time exists | Thai Foundation Engine | chart structure |
| Mahabhut/Myanmar-derived themes | Foundation → Theme → Mirror | personal/life-domain readings |
| Ranked Mirror themes and section evidence | `ThaiMirrorPipeline` | summary, identity, work, money, love, wellbeing |

Internal evidence keys remain in the Domain object for tests/traceability and
are never rendered or exported.

## Report order

1. สรุปดวงสำคัญ
2. โครงสร้างดวงหลัก
3. ภาพรวมชีวิต
4. ตัวตนและนิสัยลึก ๆ
5. การงาน
6. การเงิน
7. ความรักและความสัมพันธ์
8. สุขภาพและพลังชีวิตตามตำรา
9. Existing Life Timeline and future-period content
10. Existing reflection, source transparency, PDF, and feedback flow

Each Core Reading section includes only supported fields among: fact found,
interpretation, strength, caution, and practical use. Empty unsupported fields
are omitted instead of being filled with generic copy.

## Time and location rules

- The local sunrise is calculated from the actual date, resolved coordinates,
  and timezone; no `00:00` or `06:00` day boundary is hardcoded.
- A pre-sunrise birth preserves the civil birth date but uses the previous day
  for rules whose astrological day starts at sunrise.
- With birth time, the Foundation Engine may expose Lagna.
- Without birth time, Core Reading explicitly omits Lagna, houses, and other
  time-dependent claims.
- The same input remains deterministic.

## Safety boundaries

- Frozen Mahabhut Canon, Engine formulas, Evidence Badge rollout, audience,
  authentication, navigation, and feature flags are unchanged.
- Timeline/current/future markers are rejected from Core Reading copy and stay
  in the existing Timeline section below it.
- Public/PDF output never exposes Canon/Ontology IDs, source prose, debug keys,
  raw evidence keys, coordinates, or confidence internals.
- Health copy is explicitly framed as an astrological belief and not a medical
  diagnosis.
- Product accuracy/“ตรง” acceptance remains an owner/tester decision.

## Known limits

- The Engine does not expose a complete public planetary degree/aspect table;
  the Core Reading therefore does not invent one.
- Arbitrary dates can have limited verified Thai lunar dataset coverage; this
  phase uses the existing graceful fallback and does not claim missing lunar
  facts.
- A no-time reading is intentionally less detailed.

## Validation

Focused coverage checks full-time, no-time, before/after sunrise, different
date/place, determinism, web-before-Timeline ordering, web/PDF parity, and
public identifier safety:

```powershell
flutter test test/validation/thai_beta/core_reading/thai_birth_profile_core_reading_test.dart
flutter test test/validation/thai_beta/thai_beta_report_export_test.dart
flutter test test/validation/thai_beta/thai_beta_feedback_test.dart
```

