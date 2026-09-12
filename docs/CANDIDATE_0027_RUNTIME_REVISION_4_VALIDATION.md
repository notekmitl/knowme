# Candidate 0027 Runtime Revision 4 — validation

**Status: PASS — READY FOR OWNER TESTING — NOT OWNER-ACCEPTED — PR #120 REMAINS DRAFT — NOT MERGED — NOT DEPLOYED**

Date: 2026-09-11

Implementation commit: `772f69dbb6f7b0ad81d25a26a4b7303b2c827264`

Fixture: ผู้ชาย · 6 มิถุนายน 2525 · 00:35 · เชียงใหม่ · วันทางโหราศาสตร์วันเสาร์ · ลัคนาราศีกุมภ์ 19°19′

Reference date: `asOf=2026-09-09 Asia/Bangkok`

## What Revision 4 implements

- Candidate 0027 is the reader realization for the existing Candidate 0023 selector/evidence component set.
- The exact Candidate 0027 source text between its document markers is emitted for the 00:35 fixture.
- The overview remains two paragraphs at the export boundary.
- `รายงานนี้ดูจากอะไร` and the facts-only `โครงสร้างดวงหลัก` are separate report sections.
- The compact infographic wording remains unchanged to preserve the accepted 1080×1920 layout.
- Unknown-time reports remain fail-closed.
- No selector, Canon rule, evidence source, fixture override, predictive claim or Production configuration was added.

## Validation results

| Gate | Result |
| --- | --- |
| Candidate 0027 source-exact runtime test | PASS |
| Focused Candidate runtime | 17/17 |
| Export regression | 58/58 |
| PDF title/canonical-field regression | 4/4 |
| OR5 historical authority projection | 1/1 |
| Node foundation/signature evidence | 9/9 |
| Candidate 0024 validator | PASS; controls 11/11 |
| Candidate 0025 validator | PASS; controls 6/6 |
| Candidate 0026 validator | PASS; controls 6/6 |
| Candidate 0027 validator | PASS; ownership 6/6; controls 15/15 |
| Full Flutter suite | 3,024/3,024; failed 0 |
| Full analyzer policy | exit 0; 298 warning/info diagnostics; no errors |
| Changed Dart/test files | 0 analyzer issues |
| `git diff --check` | PASS |

The first full-suite run exposed five stale reader-copy assertions: three exact Candidate 0023 phrases and two whole-document comparisons against the historical OR5R baseline. The phrases were updated to the authorized Candidate 0027 source. The OR5R file was not regenerated or edited; both tests now pin its exact SHA-256 and compare only stable selector/evidence/ownership fields. The final full suite passed 3,024/3,024.

## Historical protection

The pre-repair OR5R baseline remains exactly:

`91B71E6689193EE8C5CBD2604F24F139D380B9994A94437F4135FD42019CD998`

Candidate 0011, 0023, 0024, 0025 and 0026 historical files remain unchanged. Corrected validator constants now match the bytes at their pinned historical revisions; later runtime work is excluded from earlier revision-scope checks.

## Owner Review PDF

File: `KnowMe_Candidate_0027_Runtime_Revision_4_Owner_Review_0035.pdf`

Pages: 5 A4 pages

Size: 331,703 bytes

SHA-256: `EA15C74C87B4825B25A48C423E9ED28636CCEE15B90D51B407AC1A1931712362`

The PDF was rendered to five PNG pages and each page was inspected. Missing text, broken Thai glyphs, clipping, overlap and overflow are 0. Embedded fonts are Noto Sans Thai and Noto Sans. The PDF is an Owner-review artifact, not an accepted golden or Production artifact.

## Reproduction

All Flutter commands use CI-safe mode:

```bash
CI=true FLUTTER_SUPPRESS_ANALYTICS=true TZ=Asia/Bangkok TAR_OPTIONS=--no-same-owner flutter test --no-pub --concurrency=4 --reporter compact
CI=true FLUTTER_SUPPRESS_ANALYTICS=true TZ=Asia/Bangkok TAR_OPTIONS=--no-same-owner flutter analyze --no-pub --no-fatal-warnings --no-fatal-infos
node --test test/evidence/predictive_runtime_v2_foundation.test.mjs test/evidence/pr115_or10r_predictive_signature.test.mjs
node tool/validate_candidate_0027_reader_voice.mjs
```

## Stop boundary

The next gate is explicit Owner testing and an accept/reject decision. Until acceptance, PR #120 stays Open + Draft. No Ready for Review, merge, Firebase deployment, Production data access or Production change is authorized.
