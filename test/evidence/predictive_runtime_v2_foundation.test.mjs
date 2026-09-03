import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';

test('runtime audit proves OR2 editorial, evidence, context and period coverage', () => {
  const audit = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', 'utf8'));
  assert.equal(audit.status, 'PASS_PREDICTIVE_RUNTIME_V2_OR2_EDITORIAL_AND_EVIDENCE');
  assert.equal(audit.counts.knownProfilesWithCompleteV2Report, 225);
  assert.equal(audit.counts.knownProfilesUsingBaselineFallback, 0);
  assert.equal(audit.counts.unknownProfilesFailClosed, 75);
  assert.equal(audit.counts.contextsWithCompleteContent, 49);
  assert.equal(audit.counts.periodsMapped, 392);
  assert.equal(audit.counts.periodsUnmapped, 0);
  for (const key of ['unsupportedClaims', 'unexpectedFixtureSpecificBranches', 'fixtureReferenceLeakage', 'evidenceBindingMismatches', 'knownToUnknownLeakage', 'integrityErrors']) {
    assert.equal(audit.counts[key], 0, key);
  }
  for (const [key, value] of Object.entries(audit.contentQualityCounters)) assert.equal(value, 0, key);
  assert.equal(audit.humanReviewContexts, 49);
  assert.equal(audit.humanReviewFailures, 0);
  assert.deepEqual(audit.verifierErrors, []);
});

test('claim bindings and reuse evidence are derived and clean', () => {
  const bindings = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_CLAIM_LEVEL_BINDINGS.json', 'utf8'));
  const reuse = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_OWNER_REUSE_AUDIT.json', 'utf8'));
  const comparison = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_GOLDEN_NEIGHBOR_COMPARISON.json', 'utf8'));
  assert.equal(bindings.summary.entries, 637);
  assert.equal(bindings.summary.missing, 0);
  assert.equal(bindings.summary.mismatch, 0);
  assert.equal(bindings.summary.manualAssertionWithoutBinding, 0);
  assert.equal(bindings.summary.fixtureReferenceLeakage, 0);
  assert.equal(reuse.summary.evidenceMismatchedReuse, 0);
  assert.equal(comparison.status, 'PASS');
});

test('generated catalog has no global accepted-context or hardcoded fixture metric', () => {
  const runtime = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart', 'utf8');
  const catalog = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart', 'utf8');
  assert.equal(catalog.includes('runtimePredictiveV2AcceptedContext'), false);
  assert.equal(runtime.includes('int get fixtureSpecificBranches => 0'), false);
  assert.equal((catalog.match(/RuntimePredictivePeriodRow\(/gu) ?? []).length, 392);
});
