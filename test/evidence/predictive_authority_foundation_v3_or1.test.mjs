import assert from 'node:assert/strict';
import test from 'node:test';
import { validateOr1 } from '../../tool/validate_predictive_authority_foundation_v3_or1.mjs';

test('PR114 OR1 validates source-direct atoms and preserves honest NO-GO coverage', () => {
  const result = validateOr1();
  assert.equal(result.status, 'PASS_WITH_SOURCE_DIRECT_AUTHORITY_GAP_NO_GO');
  assert.equal(result.counts.atoms, 56);
  assert.equal(result.counts.contexts, 49);
  assert.equal(result.counts.sourceDirectPeriods, 50);
  assert.equal(result.counts.matrixPeriods, 392);
  assert.equal(result.counts.unresolvedTextCount, 0);
  assert.equal(result.counts.negativeControlsRejected, result.counts.negativeControls);
  assert.equal(result.counts.errors, 0);
});
