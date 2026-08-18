# Copy semantic test-contract migration

## Authorized change

Only two stale tests in `test/validation/thai_beta/live_asof/thai_beta_copy_normalization_scope_test.dart` were migrated:

1. `opportunity normalization scope is fixed and fully enumerated` became `reader-visible summaries have no broad normalization or semantic delta`.
2. `Owner Unknown normalization is copy-only and remains cautious` became `canonical, fail-closed, Web/PDF, and S008 contracts stay exact`.

The original expectations required 93 profiles / 112 summaries to change and expected 19 omissions. Those expectations contradicted the accepted zero-semantic-delta product contract.

## Replacement behavioral assertions

The retained test file now generates fresh pipeline output for all 300 corpus cases and independently compares it with the accepted manifest. It asserts:

- 300 cases, Known 225 and Unknown 75;
- exact current report and narrative hashes for every case;
- no broad `copyNormalizationImpact` rows;
- exact delta 0, omission 0, addition 0 and prediction-to-advice transformation 0;
- canonical-five exact 5/5 and Web/PDF parity;
- Unknown fail-closed behavior;
- exact `owner-unknown` R7.1 canonical text;
- S008 report/narrative/canonical identity across the prior VM/Chrome evidence while retaining its raw one-ULP diagnostic difference.

Coverage was not deleted or weakened: no `skip`, suppression, allowlist, case-specific production branch, golden update or expected canonical text change was introduced. The new assertions validate observable pipeline output rather than calling the removed production normalization helper.
