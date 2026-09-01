import assert from 'node:assert/strict';
import test from 'node:test';
import { BEFORE_PATHS, EXPECTED_READER_SHA, buildManifest } from '../../tool/validate_pr114_final_merge_surface.mjs';

test('PR114 OR8 retains a closed, smaller and non-runtime merge surface', () => {
  const manifest = buildManifest();
  assert.equal(manifest.status, 'PASS_PR114_OR8_FINAL_MERGE_SURFACE');
  assert.equal(manifest.counts.beforeChangedPaths, BEFORE_PATHS);
  assert.ok(manifest.counts.afterChangedPaths < BEFORE_PATHS);
  assert.equal(manifest.counts.removedExperimentPaths, 154);
  for (const key of ['orphanRetained', 'missingDependencies', 'staleReferences', 'activeImportsRejectedCandidates', 'activeImportsObsoleteOr', 'conflictingContracts', 'candidate0011ByteDelta', 'runtimeApplicationDelta', 'flutterTestDelta', 'productAcceptanceDelta']) {
    assert.equal(manifest.counts[key], 0, key);
  }
});

test('Candidate 0011 remains the sole immutable content oracle', () => {
  const manifest = buildManifest();
  assert.equal(manifest.ownerAcceptedOracle.candidate, '0011');
  assert.equal(manifest.ownerAcceptedOracle.readerFacingSha256, EXPECTED_READER_SHA);
  assert.equal(manifest.ownerAcceptedOracle.claims, 24);
  assert.equal(manifest.ownerAcceptedOracle.predictions, 22);
  assert.equal(manifest.ownerAcceptedOracle.resolvedTargetFixtureChains, '22/22');
  assert.equal(manifest.scopeBoundary.runtimeImplemented, false);
  assert.equal(manifest.scopeBoundary.proves49ContextReadiness, false);
});

test('every PR-changed proposed Canon path is explicitly classified', () => {
  const manifest = buildManifest();
  assert.equal(manifest.counts.proposedPathsReviewed, 33);
  assert.equal(manifest.counts.proposedRequiredCanonicalFoundation, 3);
  assert.equal(manifest.counts.proposedRequiredSourceTrace, 9);
  assert.equal(manifest.counts.proposedRejectedExperiment, 21);
  assert.ok(manifest.proposedKnowledgeReview.every((entry) => ['REQUIRED_CANONICAL_FOUNDATION', 'REQUIRED_SOURCE_TRACE', 'REJECTED_EXPERIMENT', 'UNUSED'].includes(entry.classification)));
  assert.ok(manifest.proposedKnowledgeReview.filter((entry) => entry.retained).every((entry) => entry.runtimeMayConsume === false));
});
