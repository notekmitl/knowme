import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {read, sha} from '../../tool/or5r_actual_authority_v2.mjs';
import {BASE, RAW03, RAW35, RUN1, RUN2, auditCandidate, buildBeforeAfter, buildCandidate, candidateClaims, evaluatePastEquivalence, omissions, pastEquivalenceNegativeControls} from '../../tool/pr115_or6_content_candidate.mjs';

const m03 = read(`${RUN1}/${RAW03}`);
const m35 = read(`${RUN1}/${RAW35}`);
const equivalence = evaluatePastEquivalence(m03, m35);
const candidate = buildCandidate();
const clone = value => structuredClone(value);

test('Owner decision keeps Neutral V2 while rejecting actual wording and implementation authority', () => {
  const d = read('docs/PR115_OR6_OWNER_CONTENT_DECISION.json');
  assert.equal(d.inputHead, BASE);
  assert.equal(d.neutralAuthorityValidatorV2, 'ACCEPTED_AS_ENGINEERING_AUDIT_MECHANISM');
  assert.equal(d.actual0035CurrentCopy, 'OWNER_REJECTED_AS_PRODUCT_CONTENT');
  assert.equal(d.implementationAuthorized, false);
  assert.equal(d.ownerAcceptanceClaimed, false);
});

test('00:03 and 00:35 past source periods are equivalent without copying golden authority', () => {
  assert.equal(equivalence.equivalent, true);
  assert.deepEqual(Object.values(equivalence.fields), [true, true, true, true, true]);
  assert.deepEqual(equivalence.periods.map(p => p.period), ['0-10', '11-29', '30-41']);
  for (const p of equivalence.periods) {
    assert.equal(p.status, 'SOURCE_PERIOD_EQUIVALENT');
    assert.equal(p.selectorMatches, true);
    assert.equal(p.sourceBindingsResolved, true);
    assert.equal(p.timeOrAscendantDependent, false);
    assert.equal(p.exactCandidateWordingTransferred, false);
    assert.equal(p.goldenDecisionUsedAsEquivalenceEvidence, false);
  }
  assert.notEqual(m03.canonical.degreeWithinSign, m35.canonical.degreeWithinSign);
  assert.equal(m03.plan.ownerAcceptedGoldenOverrideApplied, 1);
  assert.equal(m35.plan.ownerAcceptedGoldenOverrideApplied, 0);
});

test('past equivalence rejects wrong day/context, selector and time-dependent mutation', () => {
  const controls = pastEquivalenceNegativeControls(m03, m35);
  assert.equal(controls.length, 3);
  assert.ok(controls.every(c => c.rejected), JSON.stringify(controls));
});

test('two extraction runs remain deterministic for both relevant raw fixtures', () => {
  for (const name of [RAW03, RAW35]) {
    assert.deepEqual(read(`${RUN1}/${name}`), read(`${RUN2}/${name}`));
  }
});

test('Candidate 0020 has the required chronological prediction schema and only proposed templates', () => {
  assert.equal(candidate.status, 'PROPOSED_OWNER_COPY_PENDING_REVIEW');
  assert.equal(candidate.implemented, false);
  assert.equal(candidate.accepted, false);
  assert.equal(candidate.predictionClaims.length, 12);
  assert.equal(new Set(candidate.predictionClaims.map(c => c.claimId)).size, 12);
  assert.deepEqual(candidate.predictionClaims.map(c => c.semanticOwner), ['overview', 'past-0-10', 'past-11-29', 'past-30-41', 'current', 'work', 'finance', 'relationship', 'health', 'support', 'rolling12', 'summary']);
  for (const c of candidate.predictionClaims) {
    for (const key of ['claimId', 'semanticOwner', 'section', 'timeScope', 'context', 'period', 'domain', 'horizon', 'direction', 'evidenceRefs', 'sourceBoundMeaning', 'proposedReaderWording', 'classification']) assert.ok(c[key] !== undefined, `${c.claimId}/${key}`);
    assert.equal(c.classification, 'PROPOSED_OWNER_TEMPLATE');
    assert.equal(c.accepted, false);
    assert.equal(c.noSemanticExpansion, true);
  }
});

test('unsupported current transition and next-period relationship copy are absent without filler', () => {
  assert.equal(candidate.fullReaderCopy.includes('อายุ 44 ปีเป็นช่วงเปลี่ยนผ่าน'), false);
  assert.equal(candidate.fullReaderCopy.includes('ช่วงชีวิตถัดไป — อายุ 63–79 ปี'), false);
  assert.equal(candidate.fullReaderCopy.includes('ความสัมพันธ์ที่รองรับภาระใหม่ไม่ได้จะเปลี่ยนระยะหรือยุติบทบาทเดิม'), false);
  assert.equal(candidate.omissions.length, 1);
  assert.equal(candidate.omissions[0].classification, 'OMIT_UNSUPPORTED_MISSING_COMPONENT');
  assert.equal(candidate.fullReaderCopy.includes(candidate.omissions[0].actualSourceWording), false);
});

test('candidate disclaimer occurs once and required separation follows prediction', () => {
  assert.equal(candidate.fullReaderCopy.split(candidate.disclaimer).length - 1, 1);
  const disclaimerIndex = candidate.fullReaderCopy.indexOf('\nข้อจำกัด\n');
  const foundationIndex = candidate.fullReaderCopy.indexOf('\nพื้นดวงและมุมมองด้านจิตวิทยา\n');
  const provenanceIndex = candidate.fullReaderCopy.indexOf('\nที่มาและวิธีอ่าน\n');
  assert.ok(disclaimerIndex > 0 && foundationIndex > disclaimerIndex && provenanceIndex > foundationIndex);
  assert.match(candidate.fullReaderCopy, /เนื้อหาต่อไปนี้แยกจากคำทำนาย และไม่นับเป็นคำทำนาย/);
});

test('content audit derives all required counters; only explicitly omitted binding is nonzero', () => {
  const audit = auditCandidate(candidate, equivalence);
  assert.equal(audit.status, 'AI_MACHINE_CONTENT_AUDIT_READY_PENDING_OWNER_COPY_REVIEW');
  assert.equal(audit.ownerContentPass, false);
  assert.equal(audit.passes.length, 2);
  for (const [name, value] of Object.entries(audit.counters)) assert.equal(value, name === 'missing_bindings' ? 1 : 0, name);
  assert.equal(audit.derivedChecks.nextPeriodHeadingOccurrences, 0);
  assert.equal(audit.derivedChecks.currentTransitionPhraseOccurrences, 0);
  assert.deepEqual(audit.derivedChecks.bannedPredictionHits, []);
});

test('content counter negative controls detect regressions instead of hardcoding zero', () => {
  const cases = [
    ['future_tense_in_past', c => c.predictionClaims.find(x => x.semanticOwner === 'past-0-10').proposedReaderWording += ' จะเกิดอีก'],
    ['duplicate_semantic_owner', c => c.predictionClaims[1].semanticOwner = c.predictionClaims[0].semanticOwner],
    ['semantic_duplicate_pairs', c => c.predictionClaims[1].semanticAtoms = [...c.predictionClaims[0].semanticAtoms]],
    ['unsupported_claims', c => c.predictionClaims[0].noSemanticExpansion = false],
    ['new_unmapped_claims', c => c.predictionClaims[0].sourceBoundMeaning = ''],
    ['contradictory_direction', c => c.predictionClaims.find(x => x.semanticOwner === 'work').proposedReaderWording = 'งานเดินหน้า แต่ภาระงานทำให้งานหยุด'],
    ['certainty_downgrade', c => c.predictionClaims[0].proposedReaderWording += ' อาจเกิดขึ้น'],
  ];
  for (const [counter, mutate] of cases) {
    const c = clone(candidate); mutate(c);
    assert.ok(auditCandidate(c, equivalence).counters[counter] > 0, counter);
  }
});

test('Before/After includes every existing and proposed paragraph in full', () => {
  const report = buildBeforeAfter(m35, candidate);
  assert.equal(report.beforeCount, 10);
  assert.equal(report.afterPredictionCount, 12);
  for (const d of m35.plan.decisions.filter(d => d.kind === 'prediction' && d.emitted)) assert.ok(report.before.some(x => x.text === d.text));
  for (const c of candidate.predictionClaims) assert.ok(report.after.some(x => x.text === c.proposedReaderWording));
  assert.equal(report.pairs.find(x => x.beforeOwner === 'next').before, omissions[0].actualSourceWording);
  assert.equal(report.pairs.find(x => x.beforeOwner === 'next').after, null);
});

test('committed evidence documents are exact serializations of the candidate and audit', () => {
  const map = read('docs/CANDIDATE_0020_CLAIM_MAP.json');
  assert.deepEqual(map, candidate);
  assert.deepEqual(read('docs/CANDIDATE_0020_CONTENT_AUDIT.json'), auditCandidate(candidate, equivalence));
  assert.equal(read('docs/ACTUAL_0035_PAST_PERIOD_EQUIVALENCE.json').equivalent, true);
  const full = fs.readFileSync('docs/CANDIDATE_0020_ACTUAL_0035_FULL_READER_COPY.md', 'utf8');
  assert.ok(full.includes(candidate.fullReaderCopy));
  assert.ok(full.includes(sha(candidate.fullReaderCopy)));
});

test('Candidate0011 and historical Candidate0020 files are untouched', () => {
  for (const p of ['docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json', 'docs/CANDIDATE_0020_ACTUAL_0035.json', 'docs/CANDIDATE_0020_ACTUAL_0035.md']) {
    const base = execFileSync('git', ['show', `${BASE}:${p}`]);
    assert.equal(sha(fs.readFileSync(p)), sha(base), p);
  }
  const oracle = read('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
  assert.equal(oracle.source.acceptedReaderFacingSha256.toUpperCase(), '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
});
