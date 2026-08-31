import assert from 'node:assert/strict';
import test from 'node:test';

import { validateFoundation, validateProposedClaim } from '../../tool/validate_predictive_authority_foundation_v3.mjs';

test('Foundation V3 validates 49 contexts and 392 periods with zero raw errors', () => {
  const result = validateFoundation();
  assert.equal(result.status, 'PASS_PENDING_OWNER_RULEBOOK_AND_CONTENT_REVIEW');
  assert.equal(result.counts.contexts, 49);
  assert.equal(result.counts.applications, 392);
  assert.equal(result.counts.rawErrors, 0);
});

test('all required negative controls are rejected from computed input', () => {
  const result = validateFoundation();
  assert.equal(result.counts.negativeControls, 16);
  assert.equal(result.counts.negativeControlsRejected, 16);
  assert.ok(result.negativeControls.every((entry) => entry.rawErrors.includes(entry.expectedCode)));
});

test('placement-only input cannot become prediction authority', () => {
  const errors = validateProposedClaim({ placement_record: { planet: 'sun' }, applicable_rules: [] }, new Set());
  assert.ok(errors.includes('PLACEMENT_ONLY_PREDICTION'));
});

test('Unknown fixture remains fail-closed and Known fixture identities stay separated', () => {
  const result = validateFoundation();
  assert.equal(result.fixtureSeparation.known0003.ascendant, 'Aquarius 9°24′');
  assert.equal(result.fixtureSeparation.known0035.ascendant, 'Aquarius 19°19′');
  assert.equal(result.fixtureSeparation.unknown.noonSubstitution, false);
  assert.equal(result.fixtureSeparation.unknown.ascendant, null);
  assert.equal(result.fixtureSeparation.unknown.houses, null);
  assert.equal(result.fixtureSeparation.unknown.thaiAstrologicalDay, null);
});
