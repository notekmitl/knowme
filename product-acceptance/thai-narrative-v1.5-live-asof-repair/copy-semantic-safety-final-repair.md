# V1.5 copy semantic safety final repair

## Decision and scope

The Owner authorized a final repair on PR #95 and allowed only the two stale broad-normalization expectations in `thai_beta_copy_normalization_scope_test.dart` to be replaced. The authorization did not allow canonical/golden/expected-output changes, R1–R7.1 changes, test deletion or weakening, profile allowlists, merge, deploy, or Firebase mutation.

## Root cause and repair

The prior reader-visible composer performed a broad post-composition replacement of one future opportunity sentence. Across the 300-profile corpus, that behavior affected 93 profiles and 112 `summary` fields and created 19 omissions in the legacy comparison path. It was therefore not a safe copy-only normalization.

The final repair removes that broad composer transformation. The accepted cautious opportunity wording is selected at the Life Map semantic-source boundary for the future opportunity semantic condition, and `ช่วงนี้` is recognized as a time marker by the plain-Thai renderer. The rule uses semantic identifiers and tense, not a profile/case ID. Raw astrology doubles, S008 fixed-point canonicalization, engine facts, period scores and accepted canonical material are unchanged.

## Fresh audit result

- Corpus: 300 profiles; Known 225; Unknown 75.
- Previously implicated scope: 93 unique profiles / 112 `summary` fields.
- Exact reader-visible textual deltas against accepted baseline: 0.
- Non-empty summaries made empty: 0.
- Unauthorized additions: 0.
- Prediction-to-advice transformations: 0.
- Canonical-five mismatches: 0/5.
- Unknown fail-closed mismatches: 0.
- Web/PDF mismatches: 0.
- Legacy comparison rows that are empty: 19/19, while all 19 current semantic-source summaries are non-empty.
- `owner-unknown`: exact accepted R7.1 canonical text.

## Runtime and regression result

Fresh Dart VM run 1/run 2 and real Chrome run 1/run 2 each completed 300/300, with nondeterminism 0 and zero mismatch for profile, structured material, period score, report, canonical text, narrative, Unknown omission and copy impact. S008 retains the disclosed raw IEEE-754 difference (`102.39560244592322` VM versus `102.39560244592323` Chrome), while both canonicalize to integer `102395602446` and produce identical reader output.

Fresh final gates: focused 6/6; screenshots 24/24; Life Map 67/67; matrix 864/864 and each weekday 108/108; R7 focused 286/286; synthetic 300 unique reports and 300 unique narratives; scoped analyzer clean; full analyzer branch 299/main 299/delta 0; full suite branch 2,914 passed/39 failed and pinned main 2,889 passed/39 failed with common failures 39, branch-only 0, main-only 0; Web release build successful without deploy.

R7.1 remains 10,709,328 bytes, 80 ZIP entries, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`, checksums 79/79 and immutable comparison 63/63. R1–R7.1 modified paths are 0.

No merge, deployment, Firebase mutation, golden update, accepted-output update or Production change occurred. Production remains V1.4 Hosting version `10af10c6d960d590`.
