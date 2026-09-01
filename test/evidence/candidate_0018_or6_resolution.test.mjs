import assert from 'node:assert/strict';
import test from 'node:test';
import { buildResolvedRegistry } from '../../tool/resolve_candidate_0018_or6.mjs';
import { runOr6NegativeControls, validateRegistry } from '../../tool/validate_candidate_0018_or6.mjs';

test('all OR6 evidence references resolve to repository values and commits', () => {
  const result = validateRegistry();
  assert.equal(result.status, 'PASS_OR6_ACTUAL_EVIDENCE_RESOLUTION');
  assert.equal(result.counts.typedForecastMaterials, 12);
  assert.equal(result.counts.unresolvedReference, 0);
  assert.equal(result.counts.nonexistentReference, 0);
  assert.equal(result.counts.fixtureValueMismatch, 0);
  assert.equal(result.counts.domainMismatch, 0);
  assert.equal(result.counts.horizonMismatch, 0);
  assert.equal(result.counts.directionMismatch, 0);
  assert.equal(result.counts.manuallyAssertedMaterial, 0);
  assert.equal(result.counts.errors, 0);
});

test('the twelve typed materials are actual regression-known-0003 ledger rows', () => {
  const registry = buildResolvedRegistry();
  const typed = registry.entries.filter((entry) => entry.id.startsWith('typed.'));
  assert.equal(typed.length, 12);
  assert.ok(typed.every((entry) => entry.resolvedValue.fixture === 'regression-known-0003'));
  assert.ok(typed.every((entry) => entry.locator.jsonPointer.startsWith('/claims/')));
  assert.deepEqual([...new Set(typed.map((entry) => entry.expectedHorizon))].sort(), ['current', 'next12Months', 'nextLifePeriod']);
  assert.deepEqual([...new Set(typed.map((entry) => entry.expectedDomain))].sort(), ['career', 'finance', 'health', 'relationship']);
});

test('all nine OR6 negative controls reject their corruption', () => {
  const controls = runOr6NegativeControls();
  assert.equal(controls.length, 9);
  assert.ok(controls.every((control) => control.rejected), JSON.stringify(controls, null, 2));
});
