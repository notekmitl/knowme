import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import { recomputeEvidenceOwners, runOr4NegativeControls, validateOr4Full } from '../../tool/validate_predictive_authority_foundation_v3_or4.mjs';

const read = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

test('evidence independence is recomputed from real owner ids', () => {
  const ledger = read('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json');
  assert.equal(ledger.ownerCountingPolicy.storedIndependentSignalCountTrusted, false);
  assert.equal(ledger.ownerCountingPolicy.placementAloneTierC, false);
  const owners = recomputeEvidenceOwners(['T0003-CANON-RAHU-SCOPE', 'T0003-CANON-DET-WORK'], ledger);
  assert.deepEqual(owners, ['EO-MH2537-P290-291-PLACEMENT-30-41']);
});

test('all sixteen OR4 negative controls are rejected', () => {
  const controls = runOr4NegativeControls();
  assert.equal(controls.length, 16);
  assert.ok(controls.every((row) => row.rejected));
});

test('research ledger uses verified passages but authorizes no target gap claim', () => {
  const research = read('docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.json');
  assert.equal(research.records.length, 3);
  assert.equal(research.counts.admittedToCandidate, 0);
  assert.equal(research.counts.searchSnippetsUsed, 0);
  assert.equal(research.counts.aiSummariesUsedAsAuthority, 0);
  assert.ok(research.records.every((row) => row.source.startsWith('https://www.finearts.go.th/') && row.exactPassageOrVerifiedFinding.length > 25));
  const domicile = research.records.find((row) => row.researchId === 'RESEARCH-HS13-P176-DOMICILE-DEFINITION');
  assert.equal(domicile.timingGranularity, 'CONCEPT_ONLY');
  assert.equal(domicile.domain, 'zodiac_domicile');
  assert.match(domicile.prohibitedInference, /ห้ามเรียกข้อความนี้ว่าวิธีดวงรายปี/u);
});

test('Candidate 0016 has no unsupported causal or Unknown claims', () => {
  const candidate = read('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.json');
  assert.equal(candidate.counts.knownPredictions, 6);
  assert.equal(candidate.counts.causalClaims, 0);
  assert.equal(candidate.counts.tierC, 0);
  assert.equal(candidate.unknown.predictionClaims.length, 0);
  assert.equal(candidate.known.summaryOmitted, true);
  assert.ok(candidate.known.omissions.some((row) => row.section === 'แนวโน้ม 12 เดือนข้างหน้า'));
});

test('robustness uses computed inputs and the same selector without expected copy', () => {
  const robustness = read('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.json');
  assert.equal(robustness.generationMode, 'COMPUTED_FROM_FIXTURE_SELECTOR_AND_DECISION_FUNCTION');
  assert.equal(robustness.inputs.length, 15);
  assert.equal(robustness.counts.known, 12);
  assert.equal(robustness.counts.unknown, 3);
  assert.equal(robustness.counts.inputExpectedTextFields, 0);
  assert.equal(robustness.counts.hardcodedCounters, 0);
  assert.equal(robustness.counts.unsupportedClaims, 0);
  assert.equal(robustness.counts.knownToUnknownLeakage, 0);
});

test('full OR4 validation passes with Product Content still no-go', () => {
  const result = validateOr4Full();
  assert.equal(result.status, 'PASS_OR4_EVIDENCE_MODEL_CANDIDATE_VALID_PRODUCT_CONTENT_STILL_NO_GO_NOT_RUNTIME');
  assert.equal(result.counts.negativeControlsRejected, 16);
  assert.equal(result.counts.errors, 0);
});
