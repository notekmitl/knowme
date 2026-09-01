import assert from 'node:assert/strict';
import test from 'node:test';
import fs from 'node:fs';
const read = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

test('OR2 raw ledger is retained but explicitly rejected as semantic authority', () => {
  const ledger = read('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json');
  assert.match(ledger.status, /OWNER_REJECTED_OCR_HEURISTIC/);
  assert.equal(ledger.rows.length, 392);
  assert.equal(ledger.counts.semantic_reviewed_periods, 0);
  assert.ok(ledger.rows.every((row) => row.semanticAuthorityStatus === 'UNREVIEWED_HEURISTIC_CANDIDATE'));
});

test('OR2 generated visual flags are revoked', () => {
  const pages = read('knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.json');
  assert.match(pages.status, /AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY/);
  assert.equal(pages.counts.visuallyReviewedWithEvidence, 0);
  assert.ok(pages.pages.every((page) => page.visuallyReviewed === false && page.semanticReviewEvidence === null));
});

test('OR2 197, 38 and 157 values are heuristic classifications only', () => {
  const coverage = read('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json');
  assert.equal(coverage.metrics.heuristic_event_candidates, 197);
  assert.equal(coverage.metrics.heuristic_trend_candidates, 38);
  assert.equal(coverage.metrics.marker_not_found_periods, 157);
  assert.equal(coverage.interpretation.semanticSourceAuthorityEstablished, false);
  assert.equal(coverage.interpretation.sourceDirectCoverage, null);
});

test('Candidate 0014 is Owner rejected while Unknown stays fail-closed', () => {
  const candidate = read('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json');
  assert.match(candidate.status, /OWNER_REJECTED/);
  assert.equal(candidate.unknownFixture.noonSubstitution, false);
  assert.equal(candidate.unknownFixture.ascendant, null);
  assert.equal(candidate.unknownFixture.houses, null);
  assert.equal(candidate.unknownFixture.thaiAstrologicalDay, null);
  assert.equal(candidate.unknownFixture.knownCopyLeakage, false);
  assert.equal(candidate.unknownFixture.emptyPredictionHeadings, false);
});
