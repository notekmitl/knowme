# Thai Birth Profile Core Reading V1

**Status:** Production released and verified for `/beta/thai` (2026-08-06)
**Scope:** Thai Beta presentation + PDF only  
**Engine/Canon:** unchanged

## Owner-approved Exemplar Narrative V1 follow-up

The active stacked Draft branch ports the owner-approved exemplar onto the
current Past-to-Future Narrative V3 base for both Thai Beta Web and PDF/export:

Post-Engine integration uses accepted Draft PR #84 HEAD
`57971d9d1cd2f1b634f1e1a9da7b779f40a6dd74`. Combined source-tested HEAD
`5d5c1d9b5540a37ed8d251a06db0e4f41575113b` passes 1,500/1,500 Required tests
and produces a new synthetic application-flow packet with known-time Aquarius
19°19′, unknown-time fail-closed output, and exact shared Web/PDF document
parity. This dependency update does not expand the Narrative implementation
scope; both PRs remain Draft and nothing is deployed.

Owner Product Acceptance passed on 2026-08-06 and authorized controlled stack
Merge/Deploy. Accepted Combined source-tested SHA remains
`5d5c1d9b5540a37ed8d251a06db0e4f41575113b`; the accepted Engine base remains
`57971d9d1cd2f1b634f1e1a9da7b779f40a6dd74`. At the time this acceptance was
recorded, no PR had been merged or deployed, Production/feature flags were
unchanged, and GitHub had created no CI checks/workflow runs.

The approved stack is now merged through PR #81 (`7047fd9`), PR #82
(`04f5d7e`), PR #84 (`ee04ded`), and PR #83 (`7dd04f9`). Firebase Hosting
release `1786018899255000` / version `df025ab8aeb294cd` serves the matching
cache-pinned bundle. Production checks passed for known-time and unknown-time
application flows, actual 12/11-page PDFs, Web/PDF semantic parity,
fail-closed omissions, responsive widths, and runtime logs. The rollout remains
`public_beta`; no Auth, Feedback, audience, Canon, or Production data changed.

1. `สรุปตรง ๆ`
2. `หลักการนับวันทางโหราศาสตร์ไทย`
3. `โครงสร้างดวงหลัก` — a compact table of computed weekday, Lagna degree,
   Lagna lord, and supported house/lord facts
4. identity/core when evidence supports it
5. work, money, relationships, and wellbeing in reader-facing prose
6. one grounded closing synthesis
7. the unchanged V3 current, past, future, and Timeline surfaces
8. `หัวข้อที่ไม่ได้แสดง` at the end when a requested topic failed closed

The overview contains only fields already exposed by the same
`ThaiBetaAnalysis`; it is not a new planetary-longitude or dasha engine. Web and
PDF serialize the same fact rows and omission records. Each withheld topic has
a verifiable missing-evidence reason instead of generic horoscope copy. This
follow-up does not modify Birth Normalization, the frozen Thai Engine/Canon,
Timeline or Prediction calculations, evidence eligibility, authentication,
feedback, standalone Thai Mirror defaults, or Production data.

The fail-closed disclosure also covers existing current-life and future results
when either is absent. A complete known-time analysis is expected to produce no
omissions under normal pipeline operation.

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

1. สรุปตรง ๆ
2. หลักการนับวันทางโหราศาสตร์ไทย
3. โครงสร้างดวงหลัก
4. ภาพรวมตัวตน — only when supported
5. การงาน
6. การเงิน
7. ความรักและความสัมพันธ์
8. สุขภาพและพลังชีวิตตามตำรา
9. คำชี้หลักจากพื้นดวง
10. ดวงนี้วิเคราะห์จากอะไร — collapsed by default
11. Visual divider: “จากพื้นดวงสู่จังหวะชีวิต”
12. Existing V3 current, past, future, and Timeline content
13. Existing source transparency and disclaimers
14. หัวข้อที่ไม่ได้แสดง — only when one or more topics were withheld
15. Existing PDF and feedback flow

The narrative sections use natural paragraphs without repeated
fact/reading/strength/caution/action labels. Exact normalized claims are owned
once across Core Reading at paragraph level. Empty unsupported content is
omitted rather than filled with generic copy, and the same omission plus reason
is appended at the end of Web and PDF. PDF serializes the same section/fact-row
Domain object; the methodology disclosure is expanded as plain text in the
export. It then continues with the unchanged V3 current/past/future surfaces and
non-duplicated transparency/disclaimer sections.

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

Round 4 of Draft PR #86 makes the final fail-closed omission disclosure an
atomic PDF semantic unit: its heading, lead paragraph and first omission reason
must remain on one page. This changes pagination only; omission evidence and
public reasons remain unchanged.

Focused coverage checks full-time, no-time fail-closed behavior,
before/after sunrise, different date/place, deterministic score-based
Strength/Risk selection, exact paragraph-to-atom provenance,
source-fact-based semantic-domain enforcement (including plausible-looking
keys backed by the wrong fact), exact and near-semantic duplicate rejection
across distinct semantic keys, non-reuse of consumer narrative fields,
field/value-matched provenance for section themes and `topThemes`, complete
Methodology provenance, single-context Strength → Risk → Action synthesis,
fail-closed unsupported closing themes, removal of system labels and legacy lifelong blocks,
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

## Round 5 unknown-time weekday rule

The consumer Core Reading renders an astrological weekday only when a birth time was supplied and the sunrise-boundary result is supported. Unknown time omits the final weekday and records the unsupported topic; it does not render a noon fallback or sunrise time. This presentation rule does not alter Engine or normalization results.
# Round 6 compatibility note

Round 6 changes only future forecast presentation and export structure. Core Reading ownership, accepted known-time calculations, unknown-time omissions, day-boundary behavior, and evidence semantics remain unchanged.
# Active Round 7 compatibility

Round 7 changes forecast material typing, Action composition, and acceptance validation only. Core Reading ownership, evidence meaning, day-boundary rules, known-time calculations, and unknown-time omissions are unchanged. Product Acceptance remains pending.
