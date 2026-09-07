import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {read, sha} from '../../tool/or5r_actual_authority_v2.mjs';
import {buildCandidate0021, pairwiseSemanticOwnership} from '../../tool/pr115_or7_content_candidate.mjs';
import {
  BASE,
  OWNER_REVIEW_0021,
  TARGET_WORDING,
  EXACT_EVIDENCE,
  buildCandidate0022,
  auditOr8,
  mutationControls,
  buildAll,
} from '../../tool/pr115_or8_content_candidate.mjs';

const clone = value => structuredClone(value);
const stable = value => JSON.stringify(value);
const built = buildAll();
const candidate = built.candidate;

test('Candidate 0021 Owner review is recorded exactly and prohibits implementation', () => {
  assert.equal(OWNER_REVIEW_0021.structureOrder, 'PASS');
  assert.equal(OWNER_REVIEW_0021.pastDirectness, 'PASS');
  assert.equal(OWNER_REVIEW_0021.psychologySeparation, 'PASS');
  assert.equal(OWNER_REVIEW_0021.unsupportedNextPeriodOmission, 'PASS');
  assert.equal(OWNER_REVIEW_0021.finalReaderWording, 'REJECTED');
  assert.equal(OWNER_REVIEW_0021.conditionalPredictionLanguage, 'FAIL');
  assert.equal(OWNER_REVIEW_0021.crossHorizonRepetition, 'FAIL');
  assert.equal(OWNER_REVIEW_0021.naturalSpokenThai, 'PARTIAL');
  assert.equal(OWNER_REVIEW_0021.mayImplement, false);
  assert.deepEqual(read('docs/CANDIDATE_0021_OWNER_REVIEW.json'), OWNER_REVIEW_0021);
});

test('Candidate 0011 and Candidate 0020/0021 historical evidence remain byte-identical to OR8 base', () => {
  const paths = [
    'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json',
    'docs/CANDIDATE_0020_ACTUAL_0035_FULL_READER_COPY.md',
    'docs/CANDIDATE_0020_CLAIM_MAP.json',
    'docs/CANDIDATE_0020_CONTENT_AUDIT.json',
    'docs/CANDIDATE_0021_ACTUAL_0035_FULL_READER_COPY.md',
    'docs/CANDIDATE_0021_CLAIM_MAP.json',
    'docs/CANDIDATE_0021_CLAIM_MAP.md',
    'docs/CANDIDATE_0021_SEMANTIC_OWNERSHIP.json',
    'docs/CANDIDATE_0021_SEMANTIC_OWNERSHIP.md',
    'docs/CANDIDATE_0021_CONTENT_AUDIT.json',
    'docs/CANDIDATE_0021_CONTENT_AUDIT.md',
  ];
  for (const path of paths) {
    const baseBytes = execFileSync('git', ['show', `${BASE}:${path}`]);
    assert.equal(sha(fs.readFileSync(path)), sha(baseBytes), path);
  }
});

test('Candidate 0022 prediction paragraphs reproduce the Owner redline exactly', () => {
  assert.equal(candidate.predictionClaims.length, 11);
  assert.deepEqual(Object.fromEntries(candidate.predictionClaims.map(claim => [claim.semanticOwner, claim.proposedReaderWording])), TARGET_WORDING);
  assert.equal(candidate.status, 'BLOCKED_BY_EXACT_EVIDENCE_GAP');
  assert.equal(candidate.implemented, false);
  assert.equal(candidate.accepted, false);
  assert.equal(sha(candidate.fullReaderCopy), '853AC9AA7F00BE7A3CC7736E530311D8B371EA67F2766205FDC368EFB7117E5A');
});

test('psychology and provenance are byte-exact model data from Candidate 0021', () => {
  const oldCandidate = buildCandidate0021();
  assert.equal(stable(candidate.sections.slice(15)), stable(oldCandidate.sections.slice(15)));
  assert.equal(stable(candidate.psychology), stable(oldCandidate.psychology));
  assert.equal(candidate.sections[15].title, 'พื้นดวงและมุมมองด้านจิตวิทยา');
  assert.equal(candidate.sections[17].title, 'ที่มาและวิธีอ่าน');
});

test('summary and unsupported 63–79 period remain completely omitted', () => {
  assert.deepEqual(candidate.predictionOmissions.map(item => item.semanticOwner), ['next', 'summary']);
  assert.equal(candidate.fullReaderCopy.includes('ช่วงชีวิตถัดไป — อายุ 63–79 ปี'), false);
  assert.equal(candidate.fullReaderCopy.includes('สรุปคำทำนาย'), false);
});

test('exact-copy gate checks every clause and blocks six exact spans without substitution', () => {
  assert.equal(EXACT_EVIDENCE.entryCount, 27);
  assert.equal(EXACT_EVIDENCE.supportedCount, 21);
  assert.equal(EXACT_EVIDENCE.blockedCount, 6);
  assert.equal(EXACT_EVIDENCE.overallStatus, 'BLOCKED_EXACT_SPAN');
  const blocked = EXACT_EVIDENCE.entries.filter(entry => entry.result === 'BLOCKED_EXACT_SPAN');
  assert.deepEqual(blocked.map(entry => entry.exactSpan), [
    'การเรียนให้ผลดีและเปิดทางให้คุณเริ่มสร้างเส้นทางงานของตัวเอง',
    'การเพิ่มข้อผูกพันจะช้ากว่าที่คิด เพราะความคาดหวังของทั้งสองฝ่ายยังไม่ตรงกันทั้งหมด',
    'ทำให้งานและเรื่องเงินคล่องขึ้น',
    'รายรับจะเพิ่มตามงาน',
    'ภาระที่เพิ่มเร็วกว่าสิทธิ์ตัดสินใจจะทำให้งานบางส่วนช้าลง',
    'รายจ่ายประจำที่โตตามรายรับจะทำให้เงินเหลือเก็บเพิ่มไม่ทันรายรับ',
  ]);
  for (const entry of EXACT_EVIDENCE.entries) {
    assert.ok(candidate.fullReaderCopy.includes(entry.exactSpan), entry.id);
    assert.ok(entry.evidenceRefs.length > 0, entry.id);
    if (entry.result === 'BLOCKED_EXACT_SPAN') {
      assert.ok(entry.missingComponent, entry.id);
      assert.ok(entry.nearestSupportedMeaning, entry.id);
      assert.notEqual(entry.nearestSupportedMeaning, entry.exactSpan, entry.id);
    }
  }
});

test('claims inherit the existing chain and expose blocked exact spans instead of claiming support', () => {
  assert.deepEqual(candidate.predictionClaims.filter(claim => claim.evidenceStatus === 'BLOCKED_EXACT_SPAN').map(claim => claim.semanticOwner), ['past-11-29', 'relationship', 'support', 'rolling12']);
  for (const claim of candidate.predictionClaims) {
    assert.ok(claim.sourceBoundMeaning);
    assert.ok(claim.evidenceRefs.length > 0);
    assert.ok(claim.exactEvidenceEntryIds.length > 0);
    assert.equal(claim.accepted, false);
    assert.equal(claim.implemented, false);
    assert.equal(claim.noSemanticExpansion, claim.evidenceStatus !== 'BLOCKED_EXACT_SPAN');
  }
});

test('all 55 semantic-owner pairs are distinct even though two reader-perceived repetitions remain', () => {
  assert.equal(built.ownership.pairs.length, 55);
  assert.equal(built.ownership.duplicatePairs.length, 0);
  assert.ok(built.ownership.pairs.every(pair => pair.decision === 'DISTINCT_OWNER'));
  assert.equal(built.audit.counters.reader_perceived_repetition, 2);
});

test('Candidate 0021 negative control exposes the editorial failures named by Owner', () => {
  const counters = built.c21Negative.counters;
  assert.equal(counters.conditional_prediction_fallback, 2);
  assert.equal(counters.cross_horizon_semantic_repetition, 2);
  assert.equal(counters.reader_perceived_repetition, 2);
  assert.equal(counters.generic_positive_then_risk_formula, 3);
  assert.equal(counters.unnatural_thai_phrase, 1);
  const evidence = built.c21Negative.evidence;
  assert.ok(evidence.conditional_prediction_fallback.some(item => item.exactSpan.includes('เมื่อคำพูด') && item.exactSpan.includes('หากความคาดหวัง')));
  assert.ok(evidence.conditional_prediction_fallback.some(item => item.exactSpan.includes('หากอำนาจตัดสินใจ')));
  assert.ok(evidence.cross_horizon_semantic_repetition.some(item => item.kind === 'work-risk'));
  assert.ok(evidence.cross_horizon_semantic_repetition.some(item => item.kind === 'finance-risk'));
  assert.deepEqual(evidence.unnatural_thai_phrase.map(item => item.exactSpan), ['วัยเด็กของคุณถูกปัญหาในครอบครัวจำกัดอยู่มาก']);
});

test('Candidate 0022 new counters are evidence-derived and keep the overall result blocked', () => {
  assert.deepEqual(built.audit.counters, {
    conditional_prediction_fallback: 0,
    cross_horizon_semantic_repetition: 0,
    reader_perceived_repetition: 2,
    generic_positive_then_risk_formula: 0,
    unsupported_causal_link: 6,
    unnatural_thai_phrase: 0,
    advice_disguised_as_prediction: 0,
    personality_disguised_as_prediction: 0,
  });
  assert.equal(built.audit.status, 'BLOCKED_BY_EXACT_EVIDENCE_GAP');
  assert.equal(built.audit.ownerContentPass, false);
  assert.equal(built.audit.implemented, false);
  assert.equal(built.audit.evidence.unsupported_causal_link.length, 6);
  assert.equal(built.audit.evidence.reader_perceived_repetition.length, 2);
  assert.ok(built.audit.passes.every(pass => pass.complete));
});

test('all eight isolated mutation controls are detected', () => {
  const controls = mutationControls(candidate, EXACT_EVIDENCE);
  assert.equal(controls.length, 8);
  assert.ok(controls.every(control => control.detected), JSON.stringify(controls));
});

test('counter functions reject exact, semantic, advice, personality and evidence mutations', () => {
  const semanticMutant = clone(candidate);
  semanticMutant.predictionClaims[1].meaningAtoms.push(semanticMutant.predictionClaims[0].meaningAtoms[0]);
  assert.ok(pairwiseSemanticOwnership(semanticMutant).duplicatePairs.length > 0);
  const exactMutant = clone(candidate);
  exactMutant.predictionClaims[1].proposedReaderWording = exactMutant.predictionClaims[0].proposedReaderWording;
  assert.ok(pairwiseSemanticOwnership(exactMutant).duplicatePairs.length > 0);
  const auditMutant = clone(candidate);
  auditMutant.predictionClaims.find(claim => claim.semanticOwner === 'work').proposedReaderWording += ' ควรลองรับงานเพิ่ม';
  assert.ok(auditOr8(auditMutant, EXACT_EVIDENCE).counters.advice_disguised_as_prediction > 0);
});

test('Before/After and generated JSON reproduce complete exact content', () => {
  const report = fs.readFileSync('docs/CANDIDATE_0021_TO_0022_BEFORE_AFTER.md', 'utf8');
  for (const section of built.beforeAfter.beforeAllSections) for (const paragraph of section.fullParagraphs) assert.ok(report.includes(paragraph));
  for (const section of built.beforeAfter.afterAllSections) for (const paragraph of section.fullParagraphs) assert.ok(report.includes(paragraph));
  assert.deepEqual(read('docs/CANDIDATE_0022_CLAIM_MAP.json'), candidate);
  assert.deepEqual(read('docs/CANDIDATE_0022_EXACT_COPY_EVIDENCE.json'), EXACT_EVIDENCE);
  assert.deepEqual(read('docs/CANDIDATE_0022_SEMANTIC_OWNERSHIP.json'), built.ownership);
  assert.deepEqual(read('docs/CANDIDATE_0022_CONTENT_AUDIT.json'), built.audit);
  assert.ok(fs.readFileSync('docs/CANDIDATE_0022_ACTUAL_0035_FULL_READER_COPY.md', 'utf8').includes(candidate.fullReaderCopy));
});

test('Candidate 0011 exact SHA remains unchanged', () => {
  const oracle = read('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
  assert.equal(oracle.source.acceptedReaderFacingSha256.toUpperCase(), '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
});

test('Candidate 0022 build is deterministic across two independent model builds', () => {
  const first = buildCandidate0022();
  const second = buildCandidate0022();
  assert.equal(stable(first), stable(second));
  assert.equal(sha(first.fullReaderCopy), sha(second.fullReaderCopy));
});
