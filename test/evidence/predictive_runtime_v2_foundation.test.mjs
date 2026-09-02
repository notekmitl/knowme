import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';

test('runtime audit proves 49 selectors and 392 boundaries without overclaiming content', () => {
  const audit = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', 'utf8'));
  assert.equal(audit.status, 'PASS_PREDICTIVE_RUNTIME_V2_FOUNDATION_AUDIT');
  assert.equal(audit.counts.selectorContextsReached, 49);
  assert.equal(audit.counts.periodMatrixReachable, 392);
  assert.equal(audit.counts.contextsWithEmittedPredictionsAtApplicableAge, 1);
  assert.equal(audit.counts.contextsFailClosedAtApplicableAge, 48);
  assert.equal(audit.scopeBoundary.contentCompletenessClaimedFor49Contexts, false);
  for (const key of ['periodPlacementPromotedToPrediction', 'fixtureSpecificBranchHits', 'pinnedFixtureLiteralHits', 'unsupportedClaims', 'knownToUnknownLeakage']) assert.equal(audit.counts[key], 0, key);
});
