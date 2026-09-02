import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';

test('runtime audit proves actual 49-context and 392-period product coverage', () => {
  const audit = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', 'utf8'));
  assert.equal(audit.status, 'PASS_PREDICTIVE_RUNTIME_V2_OR1_PRODUCT_COVERAGE');
  assert.equal(audit.counts.knownProfilesWithCompleteV2Report, 225);
  assert.equal(audit.counts.knownProfilesUsingBaselineFallback, 0);
  assert.equal(audit.counts.unknownProfilesFailClosed, 75);
  assert.equal(audit.counts.contextsWithCompleteContent, 49);
  assert.equal(audit.counts.contextsWithoutCompleteContent, 0);
  assert.equal(audit.counts.periodsMapped, 392);
  assert.equal(audit.counts.periodsUnmapped, 0);
  assert.equal(audit.counts.uniqueRepresentativeContextReports, 49);
  for (const key of ['unsupportedClaims', 'fixtureSpecificBranches', 'knownToUnknownLeakage', 'integrityErrors']) {
    assert.equal(audit.counts[key], 0, key);
  }
  assert.deepEqual(audit.verifierErrors, []);
});

test('generated catalog has no global accepted-context or hardcoded fixture metric', () => {
  const runtime = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart', 'utf8');
  const catalog = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart', 'utf8');
  assert.equal(catalog.includes('runtimePredictiveV2AcceptedContext'), false);
  assert.equal(runtime.includes('int get fixtureSpecificBranches => 0'), false);
  assert.equal((catalog.match(/RuntimePredictivePeriodRow\(/gu) ?? []).length, 392);
});
