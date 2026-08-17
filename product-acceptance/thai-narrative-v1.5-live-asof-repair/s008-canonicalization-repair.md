# S008 fixed-point degree canonicalization repair

Status: **technical parity verified; PR #95 remains Draft for Owner review of the separately enumerated copy normalization; not merged or deployed**.

## Causal path

Before this repair, the raw engine `siderealAscendantDeg` entered `ThaiBetaReportSnapshot`, which was hashed by `ThaiBetaReportHash`; `ThaiBetaNarrativeContext._profileSeed` consumed the first eight report-hash hex digits; that seed selected reader-visible hero, dashboard, section and advice variants. The concrete path is:

- raw engine value → `lib/features/thai_beta/domain/thai_beta_report_snapshot.dart:28-30`
- snapshot → report hash → `lib/features/thai_beta/application/thai_beta_analysis.dart:187`
- report hash → profile seed → `lib/features/thai_beta/application/narrative/thai_beta_narrative_context.dart:79-83`
- profile seed → reader-visible selection → `lib/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart:98`, `:1423`, `:1588-1606`, `:1714-1790`, `:1950-1991`

S008 was identical across runtimes for Lagna key/lord, houses and structured profile facts, life periods, period scores, displayed degree and canonical facts. Only the pre-boundary raw audit double differed by one ULP.

## Numeric contract

`ThaiBetaCanonicalDegree` normalizes degrees into `[0, 360)`, multiplies by `1,000,000,000`, rounds once and stores an integer. The maximum value is `359,999,999,999`, safely below JavaScript's `9,007,199,254,740,991` exact-integer limit. The raw `ThaiAstrologyProfile.siderealAscendantDeg` and every engine decision remain unchanged. Snapshot/hash consumers accept both legacy raw numeric/string values and the fixed integer representation; no second raw field is added to the hashed snapshot.

The final S008 identities are exact:

| Field | Dart VM | Chrome |
|---|---|---|
| Raw audit degree | `102.39560244592322` | `102.39560244592323` |
| Canonical units | `102395602446` | `102395602446` |
| Canonical fixed degree | `102.395602446` | `102.395602446` |
| Displayed degree | `12°24′` | `12°24′` |
| Lagna / lord | `lagna_cancer` / `lagna_lord_moon` | same |
| Snapshot SHA-256 | `a66fca8cea2d3dea760ded15006b37442a5a544ab281dea60e87052666f8a52a` | same |
| Report hash | `2eb290b66a735d572ee9efc2bf2ab8d23130fd5a73804093d84296577910121c` | same |
| Narrative SHA-256 | `4bd2ed61a0d27a7268f4d68adb04bb8b6643a1e52582e720eec5495d89463d28` | same |
| Canonical text SHA-256 | `1613d306c4fcfb506a806498ba43a073e19013b2021d740c43d8833c85cd067e` | same |

## Final four-run result

VM run 1/run 2 and real Chrome run 1/run 2 each executed 300 profiles: Known 225, Unknown 75, unique reports 300/300, unique narratives 300/300 and Unknown omission 75/75. VM nondeterminism and Chrome nondeterminism are zero. VM/Chrome raw findings contain only the disclosed S008 one-ULP value; canonical degree, profile, structured material, period scores, report/content hash, canonical text, narrative, omission and copy-impact mismatch counts are all zero. No tolerance, allowlist, runtime branch, expected-output change or golden rewrite is used.

The finance semantic-classifier marker `เสี่ยง` was added after the first fresh R7 rerun exposed three false negatives for copy that explicitly said `ไม่อยากเสี่ยง`. This changes no reader-visible output or expected result; the complete R7 scope then passed 286/286.

Production remains V1.4. No merge, deployment or Firebase change occurred.
