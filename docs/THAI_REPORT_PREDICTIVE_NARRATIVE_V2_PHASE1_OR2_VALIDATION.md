# Thai Report Predictive Narrative V2 — Phase 1 OR2 Validation

Validation date: 2026-08-30 Asia/Bangkok

Scope: Markdown/design/evidence only No application, engine, generator, UI, infographic, PDF/export, runtime test or product-acceptance change

## Contract and content gates

| Gate | Result |
|---|---:|
| Event registry semantic coverage | 13/13 families |
| Rulebook rule definitions | 14/14 |
| Rule required-field completeness | 14/14, 100% |
| Rule-to-source mapping | 14/14, 100% |
| Single-signal event rules | 0 |
| Candidate 0005 Known prediction-to-rule mapping | 5/5, 100% |
| Candidate 0005 unmapped prediction | 0 |
| Candidate 0005 duplicate semantic owner | 0 |
| Candidate 0005 Unknown prediction paragraph | 0 by fail-closed design |
| Unsupported-as-approved | 0 |
| Forbidden prediction language | 0 |
| Past question/reflection | 0 |
| Prohibited psychology | 0 |
| Unsupported event count | 0 |
| Unsupported within-year timing | 0 |
| Hardcoded fixture branch | 0 |
| Unknown time-dependent leakage | 0 |

Candidate scan covers `อาจ`, `หาก`, `ตราบใด`, conditional outcome structures, `ลอง`, `เช็ก`, `ทบทวน`, `สังเกต`, early/middle/late year, half-year, month, good-month and caution-month wording G05/G10 remain outside the report

## Rule robustness

- Profiles: 15 total = Known 00:03, Known 00:35, Owner Unknown and 12 non-Owner synthetic profiles
- Product-inference atom fires: 47 across current/past/next12 horizons
- Exact life-period boundary facts: 13 Known profiles
- Total evaluated outputs: 60
- Unique product event sets: 12/15
- Identical full event set across all profiles: 0
- Rules never firing: 0
- Rules above 80%: one exact life-period boundary rule at 86.7%; retained only as a boundary fact
- Unresolved contradictory atoms: 0
- Known-to-Unknown leakage: 0
- Unsupported atoms labeled approved/current: 0
- Fixture-specific behavior: 0

Known 00:03 and 00:35 intentionally share the same V1 product event set because the rules consume lagna-lord structure rather than degree Adding a degree branch only to separate those fixtures is prohibited Unknown profiles both produce omissions

## Fixture regression

Command:

```text
flutter test test/validation/thai_beta/narrative/thai_beta_input_fixture_separation_test.dart --reporter expanded
```

Result: 4/4 passed

- 00:03 = Aquarius 9°24′, Saturday
- 00:35 = Aquarius 19°19′, Saturday
- Unknown = no noon, ascendant, houses or Thai-day assertion

## Repository validation

- `git diff --check`: pass
- `lib/` and `test/` delta from OR1 HEAD: 0
- generated application artifact delta: 0
- `product-acceptance/` delta: 0
- Documentation cross-reference: ontology, convergence, rulebook, Candidate Known/Unknown, robustness, contracts and matrix all exist
- Full Flutter suite/analyzer: not rerun because source/test delta is zero
- `monthlyTimelineAvailable=false` remains authoritative

Result: **OR2 DESIGN VALIDATION PASS — PRODUCT RULES AND CANDIDATE 0005 PENDING OWNER REVIEW — NO RUNTIME AUTHORIZATION**
