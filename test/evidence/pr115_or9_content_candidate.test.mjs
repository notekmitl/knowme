import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {read, sha} from '../../tool/or5r_actual_authority_v2.mjs';
import {pairwiseSemanticOwnership} from '../../tool/pr115_or7_content_candidate.mjs';
import {buildCandidate0022} from '../../tool/pr115_or8_content_candidate.mjs';
import {
  BASE,
  OWNER_REVIEW_0022,
  CHANGED_OWNERS,
  TARGET_WORDING,
  C22_BLOCKED_SPANS,
  EXACT_EVIDENCE,
  buildCandidate0023,
  auditOr9,
  negativeControls,
  buildAll,
} from '../../tool/pr115_or9_content_candidate.mjs';

const stable = value => JSON.stringify(value);
const built = buildAll();
const candidate = built.candidate;
const c22 = buildCandidate0022();

test('Candidate 0022 rejection is recorded without implementation authority', () => {
  assert.equal(OWNER_REVIEW_0022.verdict, 'OWNER_REJECTED_FOR_IMPLEMENTATION');
  assert.equal(OWNER_REVIEW_0022.blockedExactSpans, 6);
  assert.equal(OWNER_REVIEW_0022.unsupportedCausalLinks, 6);
  assert.equal(OWNER_REVIEW_0022.readerPerceivedRepetitions, 2);
  assert.equal(OWNER_REVIEW_0022.mayImplement, false);
});

test('Candidate 0011, 0020, 0021 and 0022 historical files remain byte-identical to OR9 base', () => {
  const paths = [
    'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json',
    ...['0020', '0021'].flatMap(id => [`docs/CANDIDATE_${id}_ACTUAL_0035_FULL_READER_COPY.md`, `docs/CANDIDATE_${id}_CLAIM_MAP.json`, `docs/CANDIDATE_${id}_CONTENT_AUDIT.json`]),
    'docs/CANDIDATE_0022_ACTUAL_0035_FULL_READER_COPY.md',
    'docs/CANDIDATE_0022_EXACT_COPY_EVIDENCE.md',
    'docs/CANDIDATE_0022_EXACT_COPY_EVIDENCE.json',
    'docs/CANDIDATE_0022_CLAIM_MAP.md',
    'docs/CANDIDATE_0022_CLAIM_MAP.json',
    'docs/CANDIDATE_0022_SEMANTIC_OWNERSHIP.md',
    'docs/CANDIDATE_0022_SEMANTIC_OWNERSHIP.json',
    'docs/CANDIDATE_0022_CONTENT_AUDIT.md',
    'docs/CANDIDATE_0022_CONTENT_AUDIT.json',
  ];
  for (const path of paths) assert.equal(sha(fs.readFileSync(path)), sha(execFileSync('git', ['show', `${BASE}:${path}`])), path);
});

test('Candidate 0023 changes exactly the four Owner-directed prediction paragraphs', () => {
  assert.deepEqual(built.beforeAfter.map(item => item.semanticOwner), CHANGED_OWNERS);
  const c22ByOwner = new Map(c22.predictionClaims.map(claim => [claim.semanticOwner, claim.proposedReaderWording]));
  const c23ByOwner = new Map(candidate.predictionClaims.map(claim => [claim.semanticOwner, claim.proposedReaderWording]));
  assert.deepEqual([...c23ByOwner].filter(([owner, text]) => text !== c22ByOwner.get(owner)).map(([owner]) => owner), CHANGED_OWNERS);
  assert.deepEqual(Object.fromEntries(c23ByOwner), TARGET_WORDING);
});

test('Candidate 0023 exact four replacement paragraphs match the Owner instruction', () => {
  assert.equal(TARGET_WORDING['past-11-29'], 'ช่วงอายุ 11–29 ปี ชีวิตดีขึ้นจากวัยเด็ก การเรียนให้ผลดี และคุณเริ่มสร้างเส้นทางงานของตัวเอง');
  assert.equal(TARGET_WORDING.relationship, 'ความสัมพันธ์ที่สำคัญจะแน่นแฟ้นขึ้น');
  assert.equal(TARGET_WORDING.support, 'ครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่ายจะเข้ามาช่วย');
  assert.equal(TARGET_WORDING.rolling12, 'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570 ขอบเขตงานจะกว้างขึ้น และรายรับจะเพิ่มขึ้น');
});

test('all non-target reader paragraphs and all advice, limitation, psychology and provenance data are byte-exact to Candidate 0022', () => {
  for (let index = 0; index < c22.sections.length; index += 1) {
    const oldSection = c22.sections[index];
    const newSection = candidate.sections[index];
    assert.equal(newSection.title, oldSection.title, `title ${index}`);
    assert.equal(newSection.kind, oldSection.kind, `kind ${index}`);
    const owner = c22.predictionClaims.find(claim => claim.claimId === oldSection.claimId)?.semanticOwner;
    if (!CHANGED_OWNERS.includes(owner)) assert.equal(stable(newSection.paragraphs), stable(oldSection.paragraphs), `paragraphs ${index}`);
  }
  assert.equal(stable(candidate.sections.slice(13)), stable(c22.sections.slice(13)));
  assert.equal(stable(candidate.psychology), stable(c22.psychology));
  assert.equal(candidate.advice, c22.advice);
  assert.equal(candidate.disclaimer, c22.disclaimer);
});

test('remaining clause inventory is actual length and is 100 percent exact-evidence supported', () => {
  assert.equal(EXACT_EVIDENCE.entryCount, 23);
  assert.equal(EXACT_EVIDENCE.supportedCount, 23);
  assert.equal(EXACT_EVIDENCE.blockedCount, 0);
  assert.equal(EXACT_EVIDENCE.overallStatus, 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW');
  for (const entry of EXACT_EVIDENCE.entries) {
    assert.equal(entry.result, 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW');
    assert.ok(candidate.fullReaderCopy.includes(entry.exactSpan), entry.id);
    assert.ok(entry.evidenceRefs.length > 0, entry.id);
  }
});

test('all Candidate 0022 blocked causal spans are absent without replacement detail', () => {
  assert.equal(C22_BLOCKED_SPANS.length, 6);
  for (const span of C22_BLOCKED_SPANS) assert.equal(candidate.fullReaderCopy.includes(span), false, span);
  assert.equal(candidate.fullReaderCopy.includes('ช่วงชีวิตถัดไป — อายุ 63–79 ปี'), false);
  assert.equal(candidate.fullReaderCopy.includes('สรุปคำทำนาย'), false);
});

test('all acceptance counters are zero', () => {
  assert.deepEqual(built.audit.counters, {
    conditional_prediction_fallback: 0,
    cross_horizon_semantic_repetition: 0,
    reader_perceived_repetition: 0,
    generic_positive_then_risk_formula: 0,
    unsupported_causal_link: 0,
    unnatural_thai_phrase: 0,
    advice_disguised_as_prediction: 0,
    personality_disguised_as_prediction: 0,
  });
});

test('pairwise semantic ownership has 55 distinct pairs and no duplicate', () => {
  assert.equal(built.ownership.pairs.length, 55);
  assert.equal(built.ownership.duplicatePairs.length, 0);
  assert.ok(built.ownership.pairs.every(pair => pair.decision === 'DISTINCT_OWNER'));
});

test('negative controls detect every one of the six Candidate 0022 blocked spans', () => {
  const rows = built.controls.filter(control => control.kind === 'reintroduced-c0022-blocked-span');
  assert.equal(rows.length, 6);
  assert.deepEqual(rows.map(row => row.input), C22_BLOCKED_SPANS);
  assert.ok(rows.every(row => row.detected));
});

test('negative control detects support outcomes reintroduced across work and finance', () => {
  const row = built.controls.find(control => control.kind === 'support-work-finance-outcome');
  assert.equal(row.detected, true);
});

test('negative controls detect อาจ ถ้า and หาก ambiguity fallbacks', () => {
  const rows = built.controls.filter(control => control.kind === 'conditional-fallback');
  assert.deepEqual(rows.map(row => row.input), ['อาจ', 'ถ้า', 'หาก']);
  assert.ok(rows.every(row => row.detected));
});

test('negative control detects compensating unsupported detail', () => {
  const row = built.controls.find(control => control.kind === 'compensating-new-detail');
  assert.equal(row.detected, true);
});

test('generated evidence, claim map, ownership, audit and Before/After are exact', () => {
  assert.deepEqual(read('docs/CANDIDATE_0023_EXACT_COPY_EVIDENCE.json'), EXACT_EVIDENCE);
  assert.deepEqual(read('docs/CANDIDATE_0023_CLAIM_MAP.json'), candidate);
  assert.deepEqual(read('docs/CANDIDATE_0023_SEMANTIC_OWNERSHIP.json'), built.ownership);
  assert.deepEqual(read('docs/CANDIDATE_0023_CONTENT_AUDIT.json'), built.audit);
  const report = fs.readFileSync('docs/CANDIDATE_0022_TO_0023_BEFORE_AFTER.md', 'utf8');
  for (const row of built.beforeAfter) {
    assert.ok(report.includes(row.beforeFullParagraph));
    assert.ok(report.includes(row.afterFullParagraph));
  }
});

test('Candidate 0011 exact SHA remains unchanged', () => {
  const oracle = read('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
  assert.equal(oracle.source.acceptedReaderFacingSha256.toUpperCase(), '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
});

test('Candidate 0023 build is deterministic across two independent builds', () => {
  const first = buildCandidate0023();
  const second = buildCandidate0023();
  assert.equal(stable(first), stable(second));
  assert.equal(sha(first.fullReaderCopy), sha(second.fullReaderCopy));
  assert.equal(candidate.status, 'EXACT_EVIDENCE_GATE_PASS_PENDING_OWNER_FINAL_COPY_REVIEW');
  assert.equal(candidate.implemented, false);
  assert.equal(candidate.accepted, false);
});

test('audit rejects advice/personality/semantic duplicate mutations', () => {
  const advice = structuredClone(candidate);
  advice.predictionClaims.find(claim => claim.semanticOwner === 'work').proposedReaderWording += ' ควรหยุดรับงานเพิ่ม';
  assert.ok(auditOr9(advice, EXACT_EVIDENCE).counters.advice_disguised_as_prediction > 0);
  const semantic = structuredClone(candidate);
  semantic.predictionClaims[1].meaningAtoms.push(semantic.predictionClaims[0].meaningAtoms[0]);
  assert.ok(pairwiseSemanticOwnership(semantic).duplicatePairs.length > 0);
  assert.equal(negativeControls(candidate).length, 11);
});
