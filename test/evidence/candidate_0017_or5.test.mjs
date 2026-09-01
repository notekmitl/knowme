import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import {validateCandidate0017} from '../../tool/validate_candidate_0017_or5.mjs';

const read = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

test('Candidate 0017 has complete rule chains for the content-first target', () => {
  const result = validateCandidate0017();
  assert.equal(result.status, 'PASS_CONTENT_FIRST_RULE_CHAIN_PENDING_OWNER_REVIEW_NOT_RUNTIME');
  assert.equal(result.counts.chainEntries, 15);
  assert.equal(result.counts.predictionEntries, 13);
  assert.equal(result.counts.typedForecastMaterials, 12);
  assert.equal(result.counts.errors, 0);
});

test('typed forecast material is never authorized as a standalone prediction', () => {
  const contract = read('knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1.json');
  assert.equal(contract.typedForecastRule.standalonePredictionAllowed, false);
  assert.deepEqual(contract.typedForecastRule.requires, ['MAHABHUT_CONTEXT_OR_PERIOD_SELECTOR', 'PRODUCTION_CANON_DOMAIN_AUTHORITY']);
});

test('Unknown remains fail-closed with zero prediction claims', () => {
  const map = read('docs/CANDIDATE_0017_RULE_CHAIN_MAP.json');
  assert.equal(map.unknown.predictionClaims.length, 0);
  assert.equal(map.unknown.fixture.noonSubstitution, false);
  assert.equal(map.unknown.fixture.ascendant, null);
  assert.equal(map.unknown.knownCopyBorrowed, false);
});
