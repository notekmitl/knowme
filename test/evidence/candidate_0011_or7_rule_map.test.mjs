import assert from 'node:assert/strict';
import test from 'node:test';
import { validateOr7RuleMap } from '../../tool/validate_candidate_0011_or7_rule_map.mjs';

test('Candidate 0011 has 22 complete resolved product-rule chains', () => {
  const result = validateOr7RuleMap();
  assert.equal(result.status, 'PASS_CANDIDATE_0011_OR7_RULE_MAP_AND_ASOF');
  assert.equal(result.counts.predictionParagraphs, 22);
  assert.equal(result.counts.completeChains, 22);
  assert.equal(result.counts.chainsWithGaps, 0);
  assert.equal(result.counts.or6ResolverErrors, 0);
});

test('actual 00:03 generator results are equivalent across accepted and typed asOf dates', () => {
  const result = validateOr7RuleMap();
  assert.equal(result.counts.asOfInvariantMismatches, 0);
  assert.equal(result.counts.forecastMaterialMismatches, 0);
});
