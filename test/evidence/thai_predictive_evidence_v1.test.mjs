import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import { buildResolvedRegistry } from '../../tool/resolve_thai_predictive_evidence_v1.mjs';
import { runEvidenceNegativeControls, validateEvidenceRegistry } from '../../tool/validate_thai_predictive_evidence_v1.mjs';

test('canonical evidence registry resolves all Candidate 0011 chain references', () => {
  const result = validateEvidenceRegistry();
  assert.equal(result.status, 'PASS_THAI_PREDICTIVE_EVIDENCE_V1');
  assert.equal(result.counts.entries, 42);
  assert.equal(result.counts.typedForecastMaterials, 9);
  assert.equal(result.counts.unresolvedReference, 0);
  assert.equal(result.counts.nonexistentReference, 0);
  assert.equal(result.counts.fixtureValueMismatch, 0);
  assert.equal(result.counts.domainMismatch, 0);
  assert.equal(result.counts.horizonMismatch, 0);
  assert.equal(result.counts.directionMismatch, 0);
  assert.equal(result.counts.manuallyAssertedMaterial, 0);
  assert.equal(result.counts.errors, 0);
});

test('registry contains exactly the 42 references consumed by Candidate 0011', () => {
  const registry = buildResolvedRegistry();
  const map = JSON.parse(fs.readFileSync('docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json', 'utf8'));
  assert.deepEqual(registry.entries.map((entry) => entry.id).sort(), Object.keys(map.resolvedReferenceIndex).sort());
});

test('all neutral evidence negative controls reject corruption', () => {
  const controls = runEvidenceNegativeControls();
  assert.equal(controls.length, 9);
  assert.ok(controls.every((control) => control.rejected), JSON.stringify(controls, null, 2));
});
