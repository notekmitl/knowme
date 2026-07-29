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

Core Reading V1 assembled the right lifelong evidence, but exposed it as eight
separate cards. Every card repeated labels such as “หลักจากพื้นดวง”,
“คำอ่านพื้นดวง”, “สิ่งที่ควรระวัง”, and “แนวทางใช้ประโยชน์”. Summary, life
overview, and deep identity also reused several of the same facts. The result
read like system output instead of one interpretation written for a person.

Human-Readable Core Reading V1 keeps the same facts and replaces only that
presentation/composition layer. Claims are assigned once across the report,
technical chart structure moves into a collapsed disclosure, and a visible
divider separates lifelong reading from Life Timeline.

### Product Acceptance follow-up V1.1

Production review found one remaining composition leak: a curated
meta-validation caution (“อย่าใช้ข้อความนี้แทน…”) could become the first
paragraph when time-oriented identity copy was omitted. Some fixtures therefore
showed only two summary paragraphs, while the closing reflection could expand
to six.

V1.1 filters meta-validation copy from every public/PDF Core Reading claim,
uses unused traceable reflection evidence to keep the summary at three to four
paragraphs, and limits the closing to three paragraphs. The Product Acceptance
follow-up adds a structured paragraph model: each paragraph has one semantic
domain, a stable semantic key, a claim role, and exact internal evidence
references. Supported strength, risk, and action atoms are composed into one
reader-facing synthesis, while semantic-key and text-similarity checks prevent
exact and near-duplicate claims.

Thai Beta now renders the lifelong interpretation once. Its embedded Thai
Mirror surface contributes only Timeline/current/future and
transparency/disclaimer content; standalone Thai Mirror retains the prior
default. PDF follows the same boundary and no longer appends hero, signature,
dashboard, strengths, cautions, advice, narrative, reflection, or closing
blocks after Core Reading. Engine facts, ordering, no-time rules, and PDF
source remain unchanged.

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

Internal evidence keys live on each structured paragraph for deterministic
traceability and are never rendered or exported.

## Report order

1. สรุปตัวคุณจากพื้นดวง
2. การงาน
3. การเงิน
4. ความรักและความสัมพันธ์
5. สุขภาพและพลังชีวิตตามตำรา
6. สิ่งที่ดวงนี้อยากบอกคุณ
7. ดวงนี้วิเคราะห์จากอะไร — collapsed by default
8. Visual divider: “จากพื้นดวงสู่จังหวะชีวิต”
9. Existing Life Timeline and future-period content
10. Existing source transparency, disclaimers, PDF, and feedback flow

The six narrative sections use natural paragraphs without repeated
fact/reading/strength/caution/action labels. Exact normalized claims are owned
once across Core Reading at paragraph level. Empty unsupported content is
omitted rather than filled with generic copy. PDF serializes the same
seven-section Domain object; the methodology disclosure is expanded as plain
text in the export. It then continues directly with Timeline/current/future
and non-duplicated transparency/disclaimer sections.

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

Focused coverage checks full-time, no-time fail-closed behavior,
before/after sunrise, different date/place, deterministic score-based
Strength/Risk selection, exact paragraph-to-atom provenance,
source-fact-based semantic-domain enforcement (including plausible-looking
keys backed by the wrong fact), exact and near-semantic duplicate rejection
across distinct semantic keys, non-reuse of consumer narrative fields,
supported synthesis, removal of system labels and legacy lifelong blocks,
collapsed methodology behavior, divider-before-Timeline ordering, standalone
Thai Mirror default behavior, web/PDF parity, and public identifier safety:

```powershell
flutter test test/validation/thai_beta/core_reading/thai_birth_profile_core_reading_test.dart
flutter test test/validation/thai_beta/thai_beta_report_export_test.dart
flutter test test/validation/thai_beta/thai_beta_feedback_test.dart
```

For Draft PR #67 only, the standalone Thai Mirror golden is an **approved
pre-existing exception**: on 29 July 2026, `origin/main` and the PR branch were
run in the same local Flutter/Windows environment and both failed at exactly
32.63% / 305,379 differing pixels. The golden baseline, global Gate scripts,
and CI configuration were not changed. Default Thai Mirror behavior remains
covered by the non-golden widget-tree/content regression in the focused Core
Reading test.

