import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import { semanticDuplicatePairs, validateCandidate0018, validateReaderClaims } from '../../tool/validate_candidate_0018_or6.mjs';

const read = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

test('Candidate 0018 resolves every six-part prediction chain', () => {
  const result = validateCandidate0018();
  assert.equal(result.status, 'PASS_OR6_EVIDENCE_BINDING_AND_READER_COPY_REPAIR_PENDING_OWNER_CONTENT_REVIEW_NOT_RUNTIME');
  assert.equal(result.counts.contentEntries, 15);
  assert.equal(result.counts.predictionEntries, 13);
  assert.equal(result.counts.typedForecastMaterialsUsed, 12);
  assert.equal(result.counts.errors, 0);
});

test('actual reader text has no prohibited advice, expansion or semantic duplicate', () => {
  const map = read('docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.json');
  assert.deepEqual(validateReaderClaims(map.known.claims), []);
  assert.deepEqual(semanticDuplicatePairs(map.known.claims), []);
});

test('Unknown remains fail-closed with no Known prediction borrowing', () => {
  const map = read('docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.json');
  assert.equal(map.unknown.predictionClaims.length, 0);
  assert.equal(map.unknown.fixture.noonSubstitution, false);
  assert.equal(map.unknown.fixture.ascendant, null);
  assert.equal(map.unknown.fixture.houses, null);
  assert.equal(map.unknown.knownCopyBorrowed, false);
});
