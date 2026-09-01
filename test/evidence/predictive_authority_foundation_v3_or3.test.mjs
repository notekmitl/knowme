import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import { validateOr3 } from '../../tool/validate_predictive_authority_foundation_v3_or3.mjs';

const read = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

test('OR2 values are reclassified as heuristics rather than semantic authority', () => {
  const correction = read('docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.json');
  assert.equal(correction.correctedCounts.heuristic_event_candidates, 197);
  assert.equal(correction.correctedCounts.heuristic_trend_candidates, 38);
  assert.equal(correction.correctedCounts.marker_not_found_periods, 157);
  assert.equal(correction.correctedCounts.semantic_reviewed_periods, 0);
  assert.equal(correction.correctedCounts.source_direct_authorized_periods, 0);
});

test('automated page inventory is not visual review evidence', () => {
  const inventory = read('knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.json');
  assert.equal(inventory.pages.length, 181);
  assert.equal(inventory.counts.visuallyReviewedWithEvidence, 0);
  assert.ok(inventory.pages.every((page) => page.semanticReviewEvidence === null && page.authorityStatus === 'INVENTORY_ONLY'));
});

test('synthesis contract requires independent signals and fail-closed Unknown', () => {
  const contract = read('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.json');
  const tierC = contract.authorityTiers.find((tier) => tier.tier === 'C');
  assert.equal(tierC.minimumIndependentSignals, 2);
  assert.equal(contract.independencePolicy.placementFactAloneQualifiesForTierC, false);
  assert.equal(contract.unknownTimePolicy.failClosed, true);
});

test('target dossier uses specific visual semantic records for pages 290 to 292', () => {
  const dossier = read('docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json');
  assert.deepEqual(dossier.reviewRecords.map((record) => record.page), [290, 291, 292]);
  assert.ok(dossier.reviewRecords.every((record) => record.reviewMethod === 'AI_VISUAL_SEMANTIC_REVIEW' && record.observation.length > 80));
  assert.equal(dossier.humanReview, 'PENDING');
});

test('Candidate 0014 remains rejected and Candidate 0015 meets the evidence contract', () => {
  const rejected = read('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json');
  const candidate = read('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.json');
  assert.match(rejected.status, /OWNER_REJECTED/);
  assert.equal(candidate.counts.unsupportedClaims, 0);
  assert.equal(candidate.counts.methodologicalReaderClaims, 0);
  assert.equal(candidate.counts.tierDReaderClaims, 0);
  assert.equal(candidate.unknown.predictionClaims.length, 0);
});

test('Candidate 0015 phase-two validation passes', () => {
  const result = validateOr3({ requireRobustness: false });
  assert.equal(result.status, 'PASS_OR3_PHASE2');
  assert.equal(result.counts.errors, 0);
});

test('all eight real-data negative controls are rejected', () => {
  const result = validateOr3({ requireRobustness: false });
  assert.equal(result.counts.negativeControls, 8);
  assert.equal(result.counts.negativeControlsRejected, 8);
  assert.ok(result.controls.every((control) => control.mutationUsesRealEvidenceData && control.rejected));
});
