# Thai Report Predictive Narrative V2 — Phase 1 OR3 Validation

Validation date: 2026-08-30 Asia/Bangkok

Scope: Markdown/design/evidence/calibration only No application, engine, generator, UI, report, infographic, PDF/export, committed runtime test or `product-acceptance/` change

## Owner disposition recorded

- Option B remains the product direction
- Event Ontology and Evidence Architecture accepted for further design
- Rulebook V1 rejected as implementation rule set
- Candidate 0005 Known/Unknown rejected as content/implementation/expected-output target
- Candidate 0006 is a validity-gate projection, not a content target

## Required gates

| Gate | Result |
|---|---:|
| repository population evaluated | 300/300 |
| Known / Unknown | 225 / 75 |
| relationship-status design coverage | 60 each across 5 values |
| rolling segments correct | 300/300, 100% |
| V1 authority audit | 14/14 rules, 100% |
| V1.1 retained rules | 3 |
| retained rule required-field completeness | 3/3, 100% |
| retained event rules | 0 |
| unsourced retained thresholds | 0 |
| arbitrary fixed predictive confidence | 0 |
| unsupported-as-approved | 0 |
| `currentAge+1` blanket usage in V1.1 | 0 |
| forbidden within-year reader timing | 0 |
| hardcoded fixture rule branch | 0 |
| unresolved contradictions in retained rules | 0 |
| Known→Unknown leakage | 0/75 |
| past reflection/question | 0 |
| prohibited psychology | 0 |
| unsupported event count | 0 |
| Candidate 0006 semantic-owner duplicate | 0 |
| Candidate 0006 reader-visible duplicate | 0 |
| Unknown empty predictive headings | 0 |
| Unknown duplicate omission statements | 0 |

Historical V1 still contains the rejected `currentAge+1`, thresholds and `OWNER_APPROVED_PRODUCT_INFERENCE` rule-class labels so the audit remains reproducible Its header now prohibits implementation Those historical occurrences are not retained-rule failures

## Population results

- All eight supported start planets represented: Sun 51, Moon 43, Mars 39, Mercury 21, Jupiter 42, Venus 43, Saturn 47, Rahu 14
- Stages: opening 94, peak 101, closing 105; harmony covers negative/neutral/positive
- V1 product rule fire rates range 2.7–37.8%; exact boundary fact 100% of eligible Known profiles
- Sensitivity ±5 changes up to 115 profiles looser and 68 profiles stricter depending on rule
- V1 opposing event candidates before its rejected resolver: 2 profiles, S009 and S028
- Semantic validity: not established by distribution
- Predictive accuracy: not measurable without historical labeled outcomes
- V1.1 retained event predictions: 0; unresolved contradictions: 0

## Candidate results

- Known: exact life-period facts 2, event predictions 0, tendencies 1, omitted predictive blocks 2, advice 0, visible duplicates 0, Golden supported-content coverage 2/4
- Owner rolling trace: Segment A 2026-08-29–2027-06-05, 281 days, age 44, role อุตสาหะ; Segment B 2027-06-06–2027-08-28, 84 days, age 45, role มูละ
- Unknown: one limitation paragraph, empty predictive headings 0, duplicate hits 0, time-dependent assertions 0, Known-copy borrowing 0

## Executed tests

Design calibration used a temporary non-committed Flutter test over `ThaiBetaSyntheticMatrix.build()` and wrote a raw JSON ledger outside the repository It passed 1/1 and was deleted before commit

Focused command:

```text
flutter test test/validation/thai_beta/narrative/thai_beta_input_fixture_separation_test.dart --reporter expanded
```

Result: 4/4 passed

- 00:03 = Aquarius 9°24′ / Saturday
- 00:35 = Aquarius 19°19′ / Saturday
- Unknown = no noon, ascendant, houses or Thai-day assertion

## Repository validation

- `git diff --check`: pass
- Working delta: Markdown only
- application/source/code/test/generated artifact delta: 0
- `product-acceptance/` delta: 0
- Full Flutter suite/analyzer: not rerun because source/test delta is zero
- `monthlyTimelineAvailable=false`; G05/G10 remain blocked

Result: **FINAL RULE VALIDITY GATE — NO-GO — DOMAIN AUTHORITY OR CALIBRATION BLOCKER RECORDED — NO RUNTIME AUTHORIZATION**
