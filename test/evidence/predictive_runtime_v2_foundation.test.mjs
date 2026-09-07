import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';

const audit = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', 'utf8'));

test('OR10R runtime audit proves actual profile, context and period coverage', () => {
  assert.equal(audit.status, 'PASS_PR115_OR10R_SIGNATURE_RUNTIME');
  assert.equal(audit.counts.profiles, 300);
  assert.equal(audit.counts.knownProfilesWithCompleteV2Report, 225);
  assert.equal(audit.counts.knownProfilesUsingBaselineFallback, 0);
  assert.equal(audit.counts.unknownProfilesFailClosed, 75);
  assert.equal(audit.counts.unknownPlaceholderVariants, 225);
  assert.equal(audit.counts.contextsWithCompleteContent, 49);
  assert.equal(audit.counts.periodsMapped, 392);
  assert.equal(audit.counts.periodsUnmapped, 0);
  assert.equal(audit.counts.sameSignatureBodyMismatch, 0);
  assert.ok(audit.counts.uniquePredictiveSignatures > 0);
  assert.ok(audit.counts.uniqueGeneratedPredictiveBodies > 0);
});

test('OR10R runtime counters are derived and clean', () => {
  for (const key of [
    'unsupportedClaims',
    'fixtureSpecificBranches',
    'goldenOverrideApplications',
    'unexpectedFixtureSpecificBranches',
    'fixtureReferenceLeakage',
    'evidenceBindingMismatches',
    'knownToUnknownLeakage',
    'genericFallback',
    'duplicateSemanticOwner',
    'staleCandidate0011RuntimePath',
    'candidate0022RejectedPhraseHits',
    'conditionalPredictionFallback',
    'unsupportedCausalLink',
    'readerPerceivedRepetition',
    'adviceLeakage',
    'personalityLeakage',
  ]) {
    assert.equal(audit.counts[key], 0, key);
  }
  assert.deepEqual(audit.verifierErrors, []);
});

test('active Candidate 0023 binding and historical Candidate 0011 identity are explicit', () => {
  assert.equal(audit.activeTarget.context, 'mahabhut2537.rem0.saturday');
  assert.equal(audit.activeTarget.age, 44);
  assert.equal(audit.activeTarget.period, 'mahabhut2537.rem0.saturday.venus.42_62');
  assert.equal(audit.activeTarget.typedMaterials, 12);
  assert.equal(audit.activeTarget.rawForecastSha256, '292AEA14829A29935A0B877E8A536A6557DAB43ACD68BAE535E091B7D7CD7669');
  assert.equal(audit.activeTarget.candidate0023FullReaderCopySha256, 'FDA1DA8917CD5ADCA4650AECF87414DCFCDEE7F13019DF0794ECF76DFD91E7F2');
  assert.equal(audit.historicalOracle.candidate0011Sha256, '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
  assert.equal(audit.historicalOracle.productionRuntimeOracle, false);
});

test('generated catalog contains all 392 rows and no fixture evidence', () => {
  const catalog = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart', 'utf8');
  assert.equal((catalog.match(/RuntimePredictivePeriodRow\(/gu) ?? []).length, 392);
  assert.equal((catalog.match(/'fixture\./gu) ?? []).length, 0);
});
