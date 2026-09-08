import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const truth = JSON.parse(readFileSync('docs/PREDICTIVE_RUNTIME_V2_OR2_TRUTH_CORRECTION.json', 'utf8'));

test('OR2 truth correction records engineering pass and product content no-go', () => {
  assert.equal(truth.status, 'ENGINEERING_COVERAGE_PASS_PRODUCT_CONTENT_FAIL');
  assert.equal(truth.ownerAcceptance, 'NOT_GRANTED');
  assert.equal(truth.ownerHumanReview, 'PENDING');
  assert.equal(truth.productContentStatus, 'NO_GO');
});

test('truth counters are recomputed from reader claims', () => {
  assert.deepEqual(truth.counts, {
    contexts: 49,
    pastFutureTenseMismatchContexts: 39,
    unresolvedWorkDirectionConflictContexts: 43,
    currentDomainTo12MonthClauseDuplicate: 98,
    currentDomainToNextClauseDuplicate: 33,
    healthAndRestPhraseOccurrences: 47,
  });
  assert.equal(truth.duplicateLedger.length, 131);
});

test('historical human-review claim is explicitly reclassified as machine audit', () => {
  assert.equal(truth.previousAuditTruthCorrection.generatedFromMachineCounters, true);
  assert.equal(truth.previousAuditTruthCorrection.provesHumanReading, false);
  assert.equal(truth.previousAuditTruthCorrection.correctedClassification, 'MACHINE_CONTENT_AUDIT');
  assert.equal(truth.previousAuditTruthCorrection.correctedResult, 'NO_GO');
});
