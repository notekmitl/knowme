import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {read, sha} from '../../tool/or5r_actual_authority_v2.mjs';
import {
  BASE,
  buildAll,
  buildCandidate0021,
  pairwiseSemanticOwnership,
  auditCandidate0021,
  auditRejectedCandidate0020,
} from '../../tool/pr115_or7_content_candidate.mjs';

const clone = value => structuredClone(value);
const built = buildAll();
const candidate = built.candidate;
const ownership = built.ownership;
const audit = built.audit;

test('Candidate 0020 truth correction records the Owner rejection without rewriting history', () => {
  const correction = read('docs/CANDIDATE_0020_CONTENT_TRUTH_CORRECTION.json');
  assert.equal(correction.finalStatus, 'OWNER_REJECTED_PRODUCT_CONTENT');
  assert.deepEqual(correction.lexicalCountsInPredictionParagraphs, {เดินหน้า: 6, ดีขึ้น: 4, แรงกด: 3});
  assert.equal(correction.oldAuditMutated, false);
  assert.equal(correction.ownerDecision.machineAuditTruthful, false);
  assert.equal(correction.ownerDecision.schemaOrTestPassEqualsContentPass, false);
});

test('Candidate 0020 files remain byte-identical to the OR7 base', () => {
  const paths = [
    'docs/CANDIDATE_0020_ACTUAL_0035_FULL_READER_COPY.md',
    'docs/CANDIDATE_0020_BEFORE_AFTER.md',
    'docs/CANDIDATE_0020_CLAIM_MAP.md',
    'docs/CANDIDATE_0020_CLAIM_MAP.json',
    'docs/CANDIDATE_0020_CONTENT_AUDIT.md',
    'docs/CANDIDATE_0020_CONTENT_AUDIT.json',
  ];
  for (const path of paths) {
    const baseBytes = execFileSync('git', ['show', `${BASE}:${path}`]);
    assert.equal(sha(fs.readFileSync(path)), sha(baseBytes), path);
  }
});

test('existing past equivalence and all three controls remain valid', () => {
  assert.equal(built.equivalence.equivalent, true);
  assert.equal(built.equivalence.periods.length, 3);
  assert.deepEqual(built.equivalence.periods.map(period => period.period), ['0-10', '11-29', '30-41']);
  assert.equal(built.equivalenceControls.length, 3);
  assert.ok(built.equivalenceControls.every(control => control.rejected));
});

test('Candidate 0021 is proposed-only, source-bound and chronologically ordered', () => {
  assert.equal(candidate.status, 'PROPOSED_OWNER_COPY_PENDING_REVIEW');
  assert.equal(candidate.implemented, false);
  assert.equal(candidate.accepted, false);
  assert.equal(candidate.predictionClaims.length, 11);
  assert.deepEqual(candidate.predictionClaims.map(claim => claim.semanticOwner), [
    'overview', 'past-0-10', 'past-11-29', 'past-30-41', 'current', 'work', 'finance', 'relationship', 'health', 'support', 'rolling12',
  ]);
  for (const claim of candidate.predictionClaims) {
    assert.equal(claim.classification, 'PROPOSED_OWNER_TEMPLATE');
    assert.equal(claim.accepted, false);
    assert.equal(claim.implemented, false);
    assert.equal(claim.noSemanticExpansion, true);
    assert.ok(claim.sourceBoundMeaning);
    assert.ok(claim.interpretationOwnerMustApprove);
    assert.ok(claim.exactUnsupportedMeanings.length > 0);
    assert.ok(claim.duplicationOwner);
    assert.ok(claim.evidenceRefs.length > 0);
  }
});

test('Candidate 0021 uses direct copy and excludes all Owner-banned formula phrases', () => {
  const predictionText = candidate.predictionClaims.map(claim => claim.proposedReaderWording).join('\n');
  const banned = ['เดินหน้าเป็นหลัก', 'มีจังหวะขยับต่อ', 'จังหวะงานไม่หยุดนิ่ง', 'เรื่องนี้ยังเดินหน้าต่อ', 'แรงกดด้านเงิน', 'มีแรงกดดัน', 'ยังเดินไปข้างหน้า', 'เป็นแกนสำคัญ', 'เข้ามามีบทบาทมากขึ้น', 'อยู่ในทางที่ดีขึ้น', 'โดยรวมดีขึ้น', 'อาจ', 'มีแนวโน้ม', 'ลอง', 'ควรถามตัวเอง'];
  for (const phrase of banned) assert.equal(predictionText.includes(phrase), false, phrase);
  assert.equal(candidate.predictionClaims.find(claim => claim.semanticOwner === 'current').proposedReaderWording.includes('42–62'), false);
  assert.equal(predictionText.includes('ช่วงเปลี่ยนผ่าน'), false);
  assert.equal(sha(candidate.fullReaderCopy), '230FDCC5A6746D056E1125BAEF5161473058436106D96705D5702B3C7869BA24');
});

test('past copy is past-facing, current is direct and rolling-12 contains no monthly invention', () => {
  const past = candidate.predictionClaims.filter(claim => claim.semanticOwner.startsWith('past-'));
  for (const claim of past) {
    assert.doesNotMatch(claim.proposedReaderWording, /จะ|กำลัง|ต่อไป|ข้างหน้า|ลอง|ทบทวน|นึกย้อน|ถามตัวเอง/u);
  }
  const current = candidate.predictionClaims.find(claim => claim.semanticOwner === 'current').proposedReaderWording;
  assert.match(current, /ลงมือทำ/u);
  assert.match(current, /การสื่อสาร/u);
  assert.match(current, /การตัดสินใจ/u);
  const rolling = candidate.predictionClaims.find(claim => claim.semanticOwner === 'rolling12').proposedReaderWording;
  assert.match(rolling, /29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570/u);
  assert.doesNotMatch(rolling, /มกราคม|กุมภาพันธ์|มีนาคม|เมษายน|พฤษภาคม|มิถุนายน|กรกฎาคม|กันยายน|ตุลาคม|พฤศจิกายน|ธันวาคม|เดือนดี|เดือนเสีย/u);
});

test('unsupported next period and redundant summary are omitted without headings or filler', () => {
  assert.deepEqual(candidate.predictionOmissions.map(item => item.semanticOwner), ['next', 'summary']);
  assert.equal(candidate.fullReaderCopy.includes('ช่วงชีวิตถัดไป — อายุ 63–79 ปี'), false);
  assert.equal(candidate.fullReaderCopy.includes('สรุปคำทำนาย'), false);
  assert.equal(candidate.fullReaderCopy.includes(candidate.predictionOmissions[0].sourceCandidate), false);
  assert.equal(candidate.fullReaderCopy.includes(candidate.predictionOmissions[1].sourceCandidate), false);
});

test('psychology contains timeless traits only and no repeated prediction-domain headings', () => {
  const psychology = candidate.sections.filter(section => section.kind === 'psychology');
  assert.equal(psychology.length, 1);
  assert.equal(psychology[0].title, 'ลักษณะพื้นฐาน');
  const text = psychology.flatMap(section => section.paragraphs).join('\n');
  assert.doesNotMatch(text, /ช่วงนี้|จะ|ถ้ารับงานเพิ่ม|ก่อนตัดสินใจ|ควร|ลอง/u);
  const headings = new Set(psychology.map(section => section.title));
  for (const heading of ['การงาน', 'การเงิน', 'ความรักและความสัมพันธ์', 'สุขภาพ', 'สุขภาพและพลังชีวิต']) assert.equal(headings.has(heading), false);
  assert.ok(candidate.psychology.omissions.every(item => item.fullOriginalParagraphs.length > 0));
});

test('all 55 prediction pairs have explicit meanings and distinct semantic ownership', () => {
  assert.equal(ownership.expectedPairs, 55);
  assert.equal(ownership.pairs.length, 55);
  assert.equal(ownership.duplicatePairs.length, 0);
  assert.equal(ownership.status, 'AI_PAIRWISE_OWNERSHIP_PASS_PENDING_OWNER_COPY_REVIEW');
  for (const pair of ownership.pairs) {
    assert.ok(pair.leftMeaning);
    assert.ok(pair.rightMeaning);
    assert.equal(pair.sameExactWording, false);
    assert.equal(pair.sharedMeaningAtoms.length, 0);
    assert.equal(pair.decision, 'DISTINCT_OWNER');
    assert.ok(pair.rationale);
  }
});

test('pairwise validator rejects exact and semantic-atom duplication, not just matching strings', () => {
  const semanticMutant = clone(candidate);
  semanticMutant.predictionClaims[1].meaningAtoms.push(semanticMutant.predictionClaims[0].meaningAtoms[0]);
  assert.ok(pairwiseSemanticOwnership(semanticMutant).duplicatePairs.length > 0);
  const exactMutant = clone(candidate);
  exactMutant.predictionClaims[1].proposedReaderWording = exactMutant.predictionClaims[0].proposedReaderWording;
  assert.ok(pairwiseSemanticOwnership(exactMutant).duplicatePairs.length > 0);
});

test('Candidate 0021 editorial counters are exact-span and pairwise-derived zeroes', () => {
  assert.equal(audit.status, 'AI_HUMAN_EDITORIAL_AUDIT_READY_PENDING_OWNER_COPY_REVIEW');
  assert.equal(audit.ownerContentPass, false);
  assert.equal(audit.candidateImplemented, false);
  assert.deepEqual(audit.counters, {
    generic_outcome_phrases: 0,
    vague_pressure_phrases: 0,
    lexical_overuse: 0,
    cross_section_semantic_repetition: 0,
    psychology_prediction_leakage: 0,
    psychology_advice_leakage: 0,
    repeated_domain_headings: 0,
    summary_without_new_function: 0,
  });
  assert.equal(audit.evidence.chronology.length, 11);
  assert.equal(audit.evidence.pairwiseMeaningsChecked.length, 55);
  assert.ok(audit.evidence.chronology.every(item => item.exactSpan));
});

test('the real rejected Candidate 0020 triggers every new editorial counter', () => {
  const rejected = auditRejectedCandidate0020();
  assert.equal(rejected.status, 'OWNER_REJECTED_PRODUCT_CONTENT_DETECTED');
  for (const [counter, value] of Object.entries(rejected.counters)) assert.ok(value > 0, `${counter}=${value}`);
  assert.deepEqual(rejected.evidence.lexicalOveruse, [
    {term: 'เดินหน้า', count: 6},
    {term: 'ดีขึ้น', count: 4},
    {term: 'แรงกด', count: 3},
  ]);
});

test('eight isolated mutation controls make their corresponding counters nonzero', () => {
  const cases = [
    ['generic_outcome_phrases', mutant => { mutant.predictionClaims[0].proposedReaderWording = 'เรื่องงานเดินหน้าเป็นหลัก'; }],
    ['vague_pressure_phrases', mutant => { mutant.predictionClaims[0].proposedReaderWording = 'มีแรงกดดัน'; }],
    ['lexical_overuse', mutant => { mutant.predictionClaims[0].proposedReaderWording = 'เดินหน้า เดินหน้า เดินหน้า'; }],
    ['cross_section_semantic_repetition', mutant => { mutant.predictionClaims[1].meaningAtoms.push(mutant.predictionClaims[0].meaningAtoms[0]); }],
    ['psychology_prediction_leakage', mutant => { mutant.sections.push({kind: 'psychology', title: 'ลักษณะพื้นฐานสอง', paragraphs: ['ช่วงนี้จะเปลี่ยน']}); }],
    ['psychology_advice_leakage', mutant => { mutant.sections.push({kind: 'psychology', title: 'ลักษณะพื้นฐานสอง', paragraphs: ['ควรลองทบทวน']}); }],
    ['repeated_domain_headings', mutant => { mutant.sections.push({kind: 'psychology', title: 'การงาน', paragraphs: ['คิดเป็นระบบ']}); }],
    ['summary_without_new_function', mutant => { const summary = clone(mutant.predictionClaims[0]); summary.claimId = 'MUTANT-SUMMARY'; summary.semanticOwner = 'summary'; summary.proposedReaderWording = 'งาน เงิน และแรงสนับสนุนเด่น'; summary.meaningAtoms = ['mutant-summary']; mutant.predictionClaims.push(summary); }],
  ];
  for (const [counter, mutate] of cases) {
    const mutant = clone(candidate);
    mutate(mutant);
    const mutantOwnership = pairwiseSemanticOwnership(mutant);
    const result = auditCandidate0021(mutant, mutantOwnership);
    assert.ok(result.counters[counter] > 0, counter);
  }
});

test('Before/After and generated JSON reproduce complete exact content', () => {
  const report = fs.readFileSync('docs/CANDIDATE_0020_TO_0021_BEFORE_AFTER.md', 'utf8');
  for (const section of built.beforeAfter.beforeAllSections) for (const paragraph of section.fullParagraphs) assert.ok(report.includes(paragraph));
  for (const section of built.beforeAfter.afterAllSections) for (const paragraph of section.fullParagraphs) assert.ok(report.includes(paragraph));
  assert.deepEqual(read('docs/CANDIDATE_0021_CLAIM_MAP.json'), candidate);
  assert.deepEqual(read('docs/CANDIDATE_0021_SEMANTIC_OWNERSHIP.json'), ownership);
  assert.deepEqual(read('docs/CANDIDATE_0021_CONTENT_AUDIT.json'), audit);
  assert.ok(fs.readFileSync('docs/CANDIDATE_0021_ACTUAL_0035_FULL_READER_COPY.md', 'utf8').includes(candidate.fullReaderCopy));
});

test('Candidate0011 exact oracle and SHA remain unchanged', () => {
  const path = 'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json';
  const baseBytes = execFileSync('git', ['show', `${BASE}:${path}`]);
  assert.equal(sha(fs.readFileSync(path)), sha(baseBytes));
  const oracle = read(path);
  assert.equal(oracle.source.acceptedReaderFacingSha256.toUpperCase(), '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
});

test('two fresh extraction directories remain byte-deterministic for both relevant fixtures', () => {
  for (const name of ['OR5_RAW_0003_20260829.json', 'OR5_ACTUAL_0035_RUNTIME_EVIDENCE.json']) {
    assert.equal(sha(fs.readFileSync(`build/or5r-neutral-v2-run1/${name}`)), sha(fs.readFileSync(`build/or5r-neutral-v2-run2/${name}`)), name);
  }
});
