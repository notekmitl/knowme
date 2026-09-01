import assert from 'node:assert/strict';
import test from 'node:test';
import { buildOracle } from '../../tool/build_candidate_0011_or7_oracle.mjs';
import { runOr7NegativeControls, validateOracle } from '../../tool/validate_candidate_0011_or7.mjs';

test('Candidate 0011 is the exact Owner-accepted immutable oracle', () => {
  const oracle = buildOracle();
  assert.equal(oracle.counts.claims, 24);
  assert.equal(oracle.counts.predictionParagraphs, 22);
  assert.equal(oracle.counts.adviceAndDisclosure, 2);
  assert.equal(oracle.source.acceptedReaderFacingSha256, oracle.source.currentReaderFacingSha256);
  assert.deepEqual(oracle.claimOrder, oracle.claims.map((claim) => claim.readerClaimId));
  assert.equal(validateOracle(oracle).status, 'PASS_CANDIDATE_0011_EXACT_ORACLE');
});

test('all OR7 exact-oracle negative controls reject corruption', () => {
  const controls = runOr7NegativeControls();
  assert.equal(controls.length, 9);
  assert.ok(controls.every((control) => control.rejected), JSON.stringify(controls, null, 2));
});
