import assert from 'node:assert/strict';
import test from 'node:test';
import fs from 'node:fs';
import { validateOr2 } from '../../tool/validate_predictive_authority_foundation_v3_or2.mjs';

const read = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

test('OR2 validates the complete 392-period and 181-page evidence set', () => {
  const result = validateOr2();
  assert.equal(result.status, 'PASS_FULL_REVIEW_SOURCE_DIRECT_GAP_CONFIRMED_NO_GO');
  assert.equal(result.counts.ledgerRows, 392);
  assert.equal(result.counts.pagesVisuallyReviewed, 181);
  assert.equal(result.counts.errors, 0);
});

test('OR2 keeps unexamined and extraction shortcuts at zero', () => {
  const ledger = read('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json');
  assert.equal(ledger.counts.periods_unexamined, 0);
  assert.equal(ledger.counts.contexts_first_period_only, 0);
  assert.equal(ledger.counts.first_period_shortcut_count, 0);
  assert.equal(ledger.counts.target_fixture_special_case_count, 0);
});

test('OR2 reports actual direct coverage without promoting reviewed gaps', () => {
  const coverage = read('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json');
  assert.equal(coverage.metrics.periods_examined, 392);
  assert.equal(coverage.metrics.unexamined_periods, 0);
  assert.equal(coverage.interpretation.sourceDirectPeriodCoverage, '235/392');
  assert.equal(coverage.interpretation.fullPredictiveAuthority, false);
  assert.equal(coverage.interpretation.noGo, true);
});

test('Candidate 0014 is evidence-only and Unknown remains fail-closed', () => {
  const candidate = read('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json');
  assert.match(candidate.status, /NOT_RUNTIME/);
  assert.equal(candidate.unknownFixture.noonSubstitution, false);
  assert.equal(candidate.unknownFixture.ascendant, null);
  assert.equal(candidate.unknownFixture.houses, null);
  assert.equal(candidate.unknownFixture.thaiAstrologicalDay, null);
  assert.equal(candidate.unknownFixture.knownCopyLeakage, false);
  assert.equal(candidate.unknownFixture.emptyPredictionHeadings, false);
});

test('real-data negative controls are all rejected', () => {
  validateOr2();
  const controls = read('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_NEGATIVE_CONTROLS.json');
  assert.equal(controls.counts.controls, 18);
  assert.equal(controls.counts.rejected, 18);
  assert.ok(controls.controls.every((control) => control.mutationUsesRealEvidenceData && control.rejected));
});
