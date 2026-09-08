// OR8 content/evidence only. This tool never invokes or modifies production runtime.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {sha} from './or5r_actual_authority_v2.mjs';
import {
  buildCandidate0021,
  pairwiseSemanticOwnership,
  auditCandidate0021,
} from './pr115_or7_content_candidate.mjs';

export const BASE = 'c726216f91359dd27eb3eed591d272bc76c66c9e';
const clone = value => structuredClone(value);
const stable = value => JSON.stringify(value);
const writeJson = (path, value) => fs.writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
const writeMd = (path, value) => fs.writeFileSync(path, value.trimEnd() + '\n');

export const OWNER_REVIEW_0021 = {
  schema: 'candidate-0021-owner-review/1',
  recordedAt: '2026-09-07',
  candidate: 'Candidate 0021 actual 00:35',
  reviewedHead: BASE,
  verdict: 'OWNER_REJECTED_FINAL_READER_WORDING',
  structureOrder: 'PASS',
  pastDirectness: 'PASS',
  psychologySeparation: 'PASS',
  unsupportedNextPeriodOmission: 'PASS',
  finalReaderWording: 'REJECTED',
  conditionalPredictionLanguage: 'FAIL',
  crossHorizonRepetition: 'FAIL',
  naturalSpokenThai: 'PARTIAL',
  mayImplement: false,
  historicalFilesImmutable: true,
  note: 'Candidate 0021 is preserved as rejected historical evidence. Passing schema or machine audit is not Owner Content Acceptance.',
};

export const TARGET_WORDING = {
  overview: 'วัย 0–10 ปีเป็นช่วงที่ชีวิตติดขัดจากปัญหาในครอบครัว หลังอายุ 11 ปี ชีวิตเปลี่ยนเป็นขาขึ้นและดีขึ้นต่อเนื่องมาถึงปัจจุบัน',
  'past-0-10': 'ช่วงอายุ 0–10 ปี พ่อแม่มีปัญหาสุขภาพ งานไม่ราบรื่น และเงินติดขัด จึงดูแลคุณได้ไม่เต็มที่',
  'past-11-29': 'ช่วงอายุ 11–29 ปี ชีวิตดีขึ้นจากวัยเด็ก การเรียนให้ผลดีและเปิดทางให้คุณเริ่มสร้างเส้นทางงานของตัวเอง',
  'past-30-41': 'ช่วงอายุ 30–41 ปี งานและความรับผิดชอบเพิ่มขึ้น คุณต้องตัดสินใจเรื่องสำคัญด้วยตัวเองมากกว่าเดิม',
  current: 'ตอนนี้การลงมือทำ การพูดคุย และการตัดสินใจคล่องกว่าช่วงก่อน',
  work: 'งานมีเข้ามาต่อเนื่องและคุณยังรับผิดชอบงานหลักได้เต็มที่',
  finance: 'คุณมีเงินใช้และมีโชคลาภ เรื่องเงินในช่วงนี้คล่องตัวขึ้น',
  relationship: 'ความสัมพันธ์ที่สำคัญจะแน่นแฟ้นขึ้น แต่การเพิ่มข้อผูกพันจะช้ากว่าที่คิด เพราะความคาดหวังของทั้งสองฝ่ายยังไม่ตรงกันทั้งหมด',
  health: 'กำลังโดยรวมยังดี แต่ช่วงที่พักไม่พอ ร่างกายจะฟื้นช้าลงและทำกิจกรรมต่อเนื่องได้ลดลง',
  support: 'ครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่ายจะเข้ามาช่วย ทำให้งานและเรื่องเงินคล่องขึ้น',
  rolling12: 'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570 งานที่รับผิดชอบจะขยายและรายรับจะเพิ่มตามงาน ภาระที่เพิ่มเร็วกว่าสิทธิ์ตัดสินใจจะทำให้งานบางส่วนช้าลง ส่วนรายจ่ายประจำที่โตตามรายรับจะทำให้เงินเหลือเก็บเพิ่มไม่ทันรายรับ',
};

const c21 = buildCandidate0021();
const c21ByOwner = new Map(c21.predictionClaims.map(claim => [claim.semanticOwner, claim]));
const evidenceRefs = owner => clone(c21ByOwner.get(owner).evidenceRefs);
const supported = (id, owner, exactSpan, refs, reason) => ({
  id,
  semanticOwner: owner,
  exactSpan,
  result: 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW',
  evidenceRefs: refs,
  rationale: reason,
  missingComponent: null,
  nearestSupportedMeaning: null,
});
const blocked = (id, owner, exactSpan, refs, missingComponent, nearestSupportedMeaning) => ({
  id,
  semanticOwner: owner,
  exactSpan,
  result: 'BLOCKED_EXACT_SPAN',
  evidenceRefs: refs,
  rationale: 'The exact wording asserts a causal, certainty, or outcome link not established by the existing component chain.',
  missingComponent,
  nearestSupportedMeaning,
});

export const EXACT_EVIDENCE_ENTRIES = [
  supported('C22-E-001', 'overview', 'วัย 0–10 ปีเป็นช่วงที่ชีวิตติดขัดจากปัญหาในครอบครัว', evidenceRefs('overview'), 'The direct family constraint and 0–10 period are present in the source record.'),
  supported('C22-E-002', 'overview', 'หลังอายุ 11 ปี ชีวิตเปลี่ยนเป็นขาขึ้นและดีขึ้นต่อเนื่องมาถึงปัจจุบัน', evidenceRefs('overview'), 'The source explicitly labels ages 11–62 as a rising phase; age 44 is within it.'),
  supported('C22-E-003', 'past-0-10', 'พ่อแม่มีปัญหาสุขภาพ งานไม่ราบรื่น และเงินติดขัด', evidenceRefs('past-0-10'), 'The source directly names parental health, work, and money constraints.'),
  supported('C22-E-004', 'past-0-10', 'จึงดูแลคุณได้ไม่เต็มที่', evidenceRefs('past-0-10'), 'The existing normalized source-bound meaning records reduced close care as the consequence.'),
  supported('C22-E-005', 'past-11-29', 'ชีวิตดีขึ้นจากวัยเด็ก', evidenceRefs('past-11-29'), 'The 11–62 rising block supports improvement after the constrained childhood period.'),
  supported('C22-E-006', 'past-11-29', 'การเรียนให้ผลดี', evidenceRefs('past-11-29'), 'The existing Jupiter learning component and rising direction support a favorable learning result.'),
  blocked('C22-E-007', 'past-11-29', 'การเรียนให้ผลดีและเปิดทางให้คุณเริ่มสร้างเส้นทางงานของตัวเอง', evidenceRefs('past-11-29'), 'An explicit learning-causes-career-start relation; the existing chain co-locates learning and career but does not make one cause the other.', 'การเรียนให้ผลดี และคุณเริ่มสร้างเส้นทางงานของตัวเอง'),
  supported('C22-E-008', 'past-30-41', 'งานและความรับผิดชอบเพิ่มขึ้น', evidenceRefs('past-30-41'), 'The accepted past-period interpretation binds work, responsibility, and rising direction to ages 30–41.'),
  supported('C22-E-009', 'past-30-41', 'คุณต้องตัดสินใจเรื่องสำคัญด้วยตัวเองมากกว่าเดิม', evidenceRefs('past-30-41'), 'The existing authority/decision component supports greater decision weight without naming an event.'),
  supported('C22-E-010', 'current', 'ตอนนี้การลงมือทำ', evidenceRefs('current'), 'The current 42–62 flow component includes action.'),
  supported('C22-E-011', 'current', 'การพูดคุย', evidenceRefs('current'), 'The current flow component includes communication.'),
  supported('C22-E-012', 'current', 'การตัดสินใจคล่องกว่าช่วงก่อน', evidenceRefs('current'), 'The current flow component supports less friction in thinking and decisions.'),
  supported('C22-E-013', 'work', 'งานมีเข้ามาต่อเนื่อง', evidenceRefs('work'), 'The 42–62 source directly supports access to work across the current period.'),
  supported('C22-E-014', 'work', 'คุณยังรับผิดชอบงานหลักได้เต็มที่', evidenceRefs('work'), 'The current career=strong component supports capacity for the primary work.'),
  supported('C22-E-015', 'finance', 'คุณมีเงินใช้และมีโชคลาภ', evidenceRefs('finance'), 'The source directly says money is available and favorable gains are present.'),
  supported('C22-E-016', 'finance', 'เรื่องเงินในช่วงนี้คล่องตัวขึ้น', evidenceRefs('finance'), 'Current finance=strong plus the rising life-period direction supports present financial ease without an amount.'),
  supported('C22-E-017', 'relationship', 'ความสัมพันธ์ที่สำคัญจะแน่นแฟ้นขึ้น', evidenceRefs('relationship'), 'The current relationship=strong component supports strengthening without naming a person or event.'),
  blocked('C22-E-018', 'relationship', 'การเพิ่มข้อผูกพันจะช้ากว่าที่คิด เพราะความคาดหวังของทั้งสองฝ่ายยังไม่ตรงกันทั้งหมด', evidenceRefs('relationship'), 'A definite present mismatch, a definite delay, and “slower than expected”; the component only records mismatch as a possible secondary pressure.', 'ความคาดหวังที่ยังไม่ตรงกันอาจชะลอการเพิ่มข้อผูกพัน'),
  supported('C22-E-019', 'health', 'กำลังโดยรวมยังดี', evidenceRefs('health'), 'The current health=strong component supports stamina for ordinary activity.'),
  supported('C22-E-020', 'health', 'ช่วงที่พักไม่พอ ร่างกายจะฟื้นช้าลงและทำกิจกรรมต่อเนื่องได้ลดลง', evidenceRefs('health'), 'The rest-related Canon component and health pressure component support slower recovery and reduced continuing capacity.'),
  supported('C22-E-021', 'support', 'ครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่ายจะเข้ามาช่วย', evidenceRefs('support'), 'The source directly names teachers, peers, and connected people as support.'),
  blocked('C22-E-022', 'support', 'ทำให้งานและเรื่องเงินคล่องขึ้น', evidenceRefs('support'), 'A support-causes-work-and-finance outcome binding; the source has separate support, work, and money clauses but no causal link between them.', 'ครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่ายจะให้ความช่วยเหลือคุณ'),
  supported('C22-E-023', 'rolling12', 'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570', ['timing.rolling-12-month-label'], 'The dates are the rolling 12-month boundary from the pinned asOf date.'),
  supported('C22-E-024', 'rolling12', 'งานที่รับผิดชอบจะขยาย', evidenceRefs('rolling12'), 'The next-12-month career component directly supports broader responsibility scope.'),
  blocked('C22-E-025', 'rolling12', 'รายรับจะเพิ่มตามงาน', evidenceRefs('rolling12'), 'An explicit work-causes-income relation; the chain supports both expansion and increased income but does not bind income causally to work.', 'ขอบเขตงานจะกว้างขึ้น และรายรับจะเพิ่มขึ้น'),
  blocked('C22-E-026', 'rolling12', 'ภาระที่เพิ่มเร็วกว่าสิทธิ์ตัดสินใจจะทำให้งานบางส่วนช้าลง', evidenceRefs('rolling12'), 'A relative growth-rate premise and slowdown outcome; the existing career component instead binds insufficient authority to reduced primary-work quality.', 'หากอำนาจตัดสินใจไม่เพิ่มตามงาน คุณภาพงานหลักจะลดลง'),
  blocked('C22-E-027', 'rolling12', 'รายจ่ายประจำที่โตตามรายรับจะทำให้เงินเหลือเก็บเพิ่มไม่ทันรายรับ', evidenceRefs('rolling12'), 'Definite expense growth and a savings-lag outcome; the component only supports this as a conditional risk to available cash.', 'เงินพร้อมใช้จะไม่เพิ่มตามรายรับหากรายจ่ายประจำโตตาม'),
];

const blockedEntries = EXACT_EVIDENCE_ENTRIES.filter(entry => entry.result === 'BLOCKED_EXACT_SPAN');
export const EXACT_EVIDENCE = {
  schema: 'candidate-0022-exact-copy-evidence/1',
  candidate: 'Candidate 0022 actual 00:35',
  sourceArchitectureChanged: false,
  entries: EXACT_EVIDENCE_ENTRIES,
  entryCount: EXACT_EVIDENCE_ENTRIES.length,
  supportedCount: EXACT_EVIDENCE_ENTRIES.length - blockedEntries.length,
  blockedCount: blockedEntries.length,
  overallStatus: blockedEntries.length === 0 ? 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW' : 'BLOCKED_EXACT_SPAN',
  ownerAcceptance: false,
  implementationAuthorized: false,
  note: 'Nearest supported meanings are evidence notes only and are not substituted into Candidate 0022.',
};

const META = {
  overview: ['เส้นชีวิตติดขัดในวัย 0–10 ก่อนเป็นขาขึ้นตั้งแต่อายุ 11 ถึงปัจจุบัน', ['life-arc-childhood-constraint-to-rising-adulthood']],
  'past-0-10': ['ปัญหาสุขภาพ งาน และเงินของพ่อแม่ลดการดูแลในวัย 0–10', ['past-0-10-parent-constraints-limited-care']],
  'past-11-29': ['ชีวิตดีขึ้น การเรียนให้ผลดี และข้อความเป้าหมายอ้างว่าการเรียนเปิดทางสู่งาน', ['past-11-29-rise-learning-career-causal-target']],
  'past-30-41': ['งาน ความรับผิดชอบ และน้ำหนักการตัดสินใจเพิ่มในวัย 30–41', ['past-30-41-work-responsibility-decisions']],
  current: ['การลงมือทำ การพูดคุย และการตัดสินใจคล่องกว่าช่วงก่อน', ['current-action-talk-decision-ease']],
  work: ['งานมีต่อเนื่องและยังรับผิดชอบงานหลักได้', ['current-work-continuity-capacity']],
  finance: ['มีเงินใช้ โชคลาภ และความคล่องตัวทางเงินในปัจจุบัน', ['current-money-luck-liquidity']],
  relationship: ['ความสัมพันธ์แน่นแฟ้นขึ้น พร้อมข้อความเป้าหมายที่ฟันธงความคาดหวังและความล่าช้า', ['current-relationship-strength-and-definite-delay-target']],
  health: ['กำลังยังดี แต่การพักไม่พอลดการฟื้นและกิจกรรมต่อเนื่อง', ['current-stamina-rest-recovery']],
  support: ['ผู้ช่วยเหลือเข้ามาหนุน พร้อมข้อความเป้าหมายที่โยงผลไปสู่งานและเงิน', ['current-support-and-cross-domain-causal-target']],
  rolling12: ['งานและรายรับเปลี่ยนในกรอบวันที่ พร้อมสาม causal/outcome spans ที่ยังขาด component', ['rolling12-work-income-pressure-expense-target']],
};

export const CANDIDATE_0022_CLAIMS = c21.predictionClaims.map(source => {
  const entries = EXACT_EVIDENCE_ENTRIES.filter(entry => entry.semanticOwner === source.semanticOwner);
  const failures = entries.filter(entry => entry.result === 'BLOCKED_EXACT_SPAN');
  return {
    ...clone(source),
    claimId: source.claimId.replace('C21-', 'C22-'),
    sourceClaimId: source.claimId,
    semanticSummary: META[source.semanticOwner][0],
    meaningAtoms: META[source.semanticOwner][1],
    proposedReaderWording: TARGET_WORDING[source.semanticOwner],
    interpretationOwnerMustApprove: `Owner must approve the exact target wording only after every clause is evidence-supported: ${TARGET_WORDING[source.semanticOwner]}`,
    exactEvidenceEntryIds: entries.map(entry => entry.id),
    blockedExactSpans: failures.map(entry => entry.exactSpan),
    evidenceStatus: failures.length ? 'BLOCKED_EXACT_SPAN' : 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW',
    classification: failures.length ? 'PROPOSED_OWNER_TEMPLATE_BLOCKED_BY_EVIDENCE' : 'PROPOSED_OWNER_TEMPLATE',
    accepted: false,
    implemented: false,
    noSemanticExpansion: failures.length === 0,
  };
});

export function buildCandidate0022() {
  const byOwner = new Map(CANDIDATE_0022_CLAIMS.map(claim => [claim.semanticOwner, claim]));
  const ownerByC21Id = new Map(c21.predictionClaims.map(claim => [claim.claimId, claim.semanticOwner]));
  const sections = c21.sections.map(section => {
    if (section.kind !== 'prediction') return clone(section);
    const owner = ownerByC21Id.get(section.claimId);
    const claim = byOwner.get(owner);
    assert.ok(claim, section.claimId);
    return {...clone(section), paragraphs: [claim.proposedReaderWording], claimId: claim.claimId};
  });
  const fullReaderCopy = sections.flatMap(section => [section.title, ...section.paragraphs, '']).join('\n').trimEnd();
  const omissions = c21.predictionOmissions.map(item => ({...clone(item), claimId: item.claimId.replace('C21-', 'C22-')}));
  const candidate = {
    schema: 'candidate-0022-actual-0035/1',
    fixture: clone(c21.fixture),
    status: 'BLOCKED_BY_EXACT_EVIDENCE_GAP',
    implemented: false,
    accepted: false,
    sourceArchitectureChanged: false,
    sourceCandidate: 'Candidate 0021 OWNER_REJECTED_FINAL_READER_WORDING',
    predictionClaims: CANDIDATE_0022_CLAIMS,
    predictionOmissions: omissions,
    psychology: clone(c21.psychology),
    advice: c21.advice,
    disclaimer: c21.disclaimer,
    sections,
    fullReaderCopy,
  };
  assert.equal(stable(candidate.sections.slice(15)), stable(c21.sections.slice(15)), 'Psychology and provenance tail must be byte-exact model data');
  return candidate;
}

const predictionMap = candidate => new Map(candidate.predictionClaims.map(claim => [claim.semanticOwner, claim.proposedReaderWording]));
const pairEvidence = (kind, leftOwner, rightOwner, byOwner, reason) => ({
  kind,
  leftOwner,
  rightOwner,
  leftExact: byOwner.get(leftOwner),
  rightExact: byOwner.get(rightOwner),
  reason,
});

export function auditOr8(candidate, evidence = {entries: []}) {
  const byOwner = predictionMap(candidate);
  const predictionText = [...byOwner.entries()];
  const conditionalPredictionFallback = predictionText.filter(([, text]) => /หาก/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan, reason: 'Uses a conditional fallback inside prediction wording.'}));
  const crossHorizonSemanticRepetition = [];
  if (/ภาระ.*งานหลัก|คุณภาพ/u.test(byOwner.get('work') ?? '') && /คุณภาพงานหลัก/u.test(byOwner.get('rolling12') ?? '')) {
    crossHorizonSemanticRepetition.push(pairEvidence('work-risk', 'work', 'rolling12', byOwner, 'Current work risk is repeated in the rolling-12 paragraph.'));
  }
  if (/รายจ่าย/u.test(byOwner.get('finance') ?? '') && /รายจ่าย/u.test(byOwner.get('rolling12') ?? '')) {
    crossHorizonSemanticRepetition.push(pairEvidence('finance-risk', 'finance', 'rolling12', byOwner, 'Current finance expense risk is repeated in the rolling-12 paragraph.'));
  }
  const readerPerceivedRepetition = [...crossHorizonSemanticRepetition];
  if (/งาน/u.test(byOwner.get('support') ?? '')) readerPerceivedRepetition.push(pairEvidence('support-work', 'support', 'work', byOwner, 'The support paragraph repeats a work outcome readers already meet in the work section.'));
  if (/เงิน/u.test(byOwner.get('support') ?? '')) readerPerceivedRepetition.push(pairEvidence('support-finance', 'support', 'finance', byOwner, 'The support paragraph repeats a money outcome readers already meet in the finance section.'));
  const genericPositiveThenRiskFormula = predictionText.filter(([, text]) => /ภาระที่รับมากเกินไป|แต่รายจ่ายระยะยาว|หากความคาดหวังยังไม่ตรงกัน/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan, reason: 'Uses the repeated positive-result then generic-risk construction rejected in Candidate 0021.'}));
  const unsupportedCausalLink = (evidence.entries ?? []).filter(entry => entry.result === 'BLOCKED_EXACT_SPAN').map(entry => ({owner: entry.semanticOwner, exactSpan: entry.exactSpan, missingComponent: entry.missingComponent}));
  const unnaturalThaiPhrase = predictionText.flatMap(([owner, text]) => text.includes('วัยเด็กของคุณถูกปัญหาในครอบครัวจำกัดอยู่มาก') ? [{owner, exactSpan: 'วัยเด็กของคุณถูกปัญหาในครอบครัวจำกัดอยู่มาก', reason: 'Unnatural passive stacking in Thai.'}] : []);
  const adviceDisguisedAsPrediction = predictionText.filter(([, text]) => /ควร|ลอง|ก่อนตัดสินใจ/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan}));
  const personalityDisguisedAsPrediction = predictionText.filter(([, text]) => /คุณเป็นคน|นิสัย|บุคลิก/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan}));
  const exactEvidence = {
    conditional_prediction_fallback: conditionalPredictionFallback,
    cross_horizon_semantic_repetition: crossHorizonSemanticRepetition,
    reader_perceived_repetition: readerPerceivedRepetition,
    generic_positive_then_risk_formula: genericPositiveThenRiskFormula,
    unsupported_causal_link: unsupportedCausalLink,
    unnatural_thai_phrase: unnaturalThaiPhrase,
    advice_disguised_as_prediction: adviceDisguisedAsPrediction,
    personality_disguised_as_prediction: personalityDisguisedAsPrediction,
  };
  return {
    counters: Object.fromEntries(Object.entries(exactEvidence).map(([key, rows]) => [key, rows.length])),
    evidence: exactEvidence,
  };
}

export function mutationControls(candidate, evidence) {
  const mutateText = (owner, suffix) => {
    const value = clone(candidate);
    const claim = value.predictionClaims.find(item => item.semanticOwner === owner);
    claim.proposedReaderWording += ` ${suffix}`;
    return value;
  };
  const controls = [
    ['conditional_prediction_fallback', () => mutateText('work', 'หากยังไม่พร้อม เรื่องนี้จะช้าลง')],
    ['cross_horizon_semantic_repetition', () => {
      const value = mutateText('work', 'ภาระจะลดคุณภาพงานหลัก');
      value.predictionClaims.find(item => item.semanticOwner === 'rolling12').proposedReaderWording += ' คุณภาพงานหลักจะลดลง';
      return value;
    }],
    ['reader_perceived_repetition', () => mutateText('support', 'งานจะคล่องขึ้น')],
    ['generic_positive_then_risk_formula', () => mutateText('work', 'ภาระที่รับมากเกินไปจะทำให้งานช้าลง')],
    ['unsupported_causal_link', () => ({candidate, evidence: {...evidence, entries: [...evidence.entries, blocked('MUT-UNSUPPORTED', 'work', 'เพราะเหตุนี้รายรับจึงเพิ่ม', evidenceRefs('work'), 'No causal component.', 'งานมีต่อเนื่อง')]}})],
    ['unnatural_thai_phrase', () => mutateText('overview', 'วัยเด็กของคุณถูกปัญหาในครอบครัวจำกัดอยู่มาก')],
    ['advice_disguised_as_prediction', () => mutateText('work', 'ควรหยุดรับงานเพิ่ม')],
    ['personality_disguised_as_prediction', () => mutateText('work', 'คุณเป็นคนอดทน')],
  ];
  return controls.map(([counter, mutate]) => {
    const result = mutate();
    const mutatedCandidate = result.candidate ?? result;
    const mutatedEvidence = result.evidence ?? {entries: []};
    const value = auditOr8(mutatedCandidate, mutatedEvidence).counters[counter];
    return {counter, detected: value > 0, observedValue: value};
  });
}

export function buildBeforeAfter(candidate) {
  const afterByOwner = new Map(candidate.predictionClaims.map(claim => [claim.semanticOwner, claim]));
  const predictionPairs = c21.predictionClaims.map(before => {
    const after = afterByOwner.get(before.semanticOwner);
    return {
      semanticOwner: before.semanticOwner,
      beforeClaimId: before.claimId,
      beforeFullParagraph: before.proposedReaderWording,
      afterClaimId: after.claimId,
      afterFullParagraph: after.proposedReaderWording,
      exactEvidenceStatus: after.evidenceStatus,
      blockedExactSpans: clone(after.blockedExactSpans),
    };
  });
  return {
    schema: 'candidate-0021-to-0022-before-after/1',
    beforeStatus: 'OWNER_REJECTED_FINAL_READER_WORDING',
    afterStatus: candidate.status,
    predictionPairs,
    beforeAllSections: c21.sections.map(section => ({kind: section.kind, title: section.title, fullParagraphs: clone(section.paragraphs)})),
    afterAllSections: candidate.sections.map(section => ({kind: section.kind, title: section.title, fullParagraphs: clone(section.paragraphs)})),
    note: 'Every title and paragraph is complete. Candidate 0022 preserves the Owner target verbatim even where the evidence gate blocks an exact span.',
  };
}

const sectionInventory = sections => sections.map((section, index) => `### ${index + 1}. ${section.title}\n\nKind: \`${section.kind}\`\n\n${section.fullParagraphs.length ? section.fullParagraphs.join('\n\n') : '_No paragraph in this heading-only section._'}`).join('\n\n');
const claimTable = claims => '| Claim | Owner | Section | Evidence result | Classification |\n|---|---|---|---|---|\n' + claims.map(claim => `| ${claim.claimId} | ${claim.semanticOwner} | ${claim.section} | ${claim.evidenceStatus} | ${claim.classification} |`).join('\n');

export function buildAll() {
  const candidate = buildCandidate0022();
  const ownership = pairwiseSemanticOwnership(candidate);
  const oldCounters = auditCandidate0021(candidate, ownership).counters;
  const newAudit = auditOr8(candidate, EXACT_EVIDENCE);
  const c21Negative = auditOr8(c21, {entries: []});
  const controls = mutationControls(candidate, EXACT_EVIDENCE);
  const beforeAfter = buildBeforeAfter(candidate);
  const audit = {
    schema: 'candidate-0022-content-audit/1',
    status: 'BLOCKED_BY_EXACT_EVIDENCE_GAP',
    ownerContentPass: false,
    implemented: false,
    passes: [
      {pass: 1, focus: ['sequence', 'continuous reading', 'predictive directness', 'outcome clarity', 'certainty'], complete: true},
      {pass: 2, focus: ['natural spoken Thai', 'lexical and semantic repetition', 'formula construction', 'internal conflict', 'leakage', 'unsupported content'], complete: true},
    ],
    priorOr7Counters: oldCounters,
    counters: newAudit.counters,
    evidence: newAudit.evidence,
    candidate0021NegativeControl: c21Negative,
    mutationControls: controls,
    pairwiseChecks: ownership.pairs.length,
    pairwiseSemanticDuplicates: ownership.duplicatePairs.length,
    exactEvidenceBlockedCount: EXACT_EVIDENCE.blockedCount,
    note: 'Machine results do not confer Owner Content Acceptance. Nonzero evidence and reader-perceived findings keep Candidate 0022 blocked.',
    fullCandidateReaderCopy: candidate.fullReaderCopy,
  };
  assert.equal(ownership.pairs.length, 55);
  assert.equal(ownership.duplicatePairs.length, 0);
  assert.equal(EXACT_EVIDENCE.blockedCount, 6);
  assert.ok(controls.every(control => control.detected));
  assert.equal(c21Negative.counters.conditional_prediction_fallback, 2);
  assert.equal(c21Negative.counters.cross_horizon_semantic_repetition, 2);
  assert.equal(c21Negative.counters.unnatural_thai_phrase, 1);

  writeJson('docs/CANDIDATE_0021_OWNER_REVIEW.json', OWNER_REVIEW_0021);
  writeJson('docs/CANDIDATE_0022_EXACT_COPY_EVIDENCE.json', EXACT_EVIDENCE);
  writeJson('docs/CANDIDATE_0022_CLAIM_MAP.json', candidate);
  writeJson('docs/CANDIDATE_0022_SEMANTIC_OWNERSHIP.json', ownership);
  writeJson('docs/CANDIDATE_0022_CONTENT_AUDIT.json', audit);

  writeMd('docs/CANDIDATE_0021_OWNER_REVIEW.md', `# Candidate 0021 — Owner review\n\n**Final verdict: OWNER REJECTED FINAL READER WORDING — DO NOT IMPLEMENT.**\n\n- Structure/order: PASS\n- Past directness: PASS\n- Psychology separation: PASS\n- Unsupported next-period omission: PASS\n- Final reader wording: REJECTED\n- Conditional prediction language: FAIL\n- Cross-horizon repetition: FAIL\n- Natural spoken Thai: PARTIAL\n\nCandidate 0021 remains immutable historical evidence. Schema/tests/machine audit do not equal Content PASS or Owner Acceptance.\n`);
  writeMd('docs/CANDIDATE_0022_ACTUAL_0035_FULL_READER_COPY.md', `# Candidate 0022 — actual 00:35 full reader copy\n\n**OWNER TARGET COPY — BLOCKED BY EXACT EVIDENCE GAP — NOT IMPLEMENTED — NOT ACCEPTED**\n\nThe Owner target is preserved verbatim. Unsupported spans are not silently reworded; see the exact-copy evidence record. The 63–79 prediction and summary remain omitted. Psychology and provenance are byte-exact model data from Candidate 0021.\n\n<!-- BEGIN CANDIDATE 0022 FULL READER COPY -->\n${candidate.fullReaderCopy}\n<!-- END CANDIDATE 0022 FULL READER COPY -->\n\nFull-reader-copy SHA-256 (UTF-8 exact model value): \`${sha(candidate.fullReaderCopy)}\`.\n`);
  writeMd('docs/CANDIDATE_0022_EXACT_COPY_EVIDENCE.md', `# Candidate 0022 — exact-copy evidence gate\n\n**Overall status: BLOCKED_EXACT_SPAN — ${EXACT_EVIDENCE.blockedCount} of ${EXACT_EVIDENCE.entryCount} clause checks are blocked.** Evidence PASS would still not equal Owner Acceptance. Nearest supported meanings below are evidence notes only and are not substituted into Candidate 0022.\n\n${EXACT_EVIDENCE.entries.map(entry => `## ${entry.id} — ${entry.semanticOwner}\n\n- Exact span: “${entry.exactSpan}”\n- Result: \`${entry.result}\`\n- Evidence: ${entry.evidenceRefs.join('; ')}\n- Rationale: ${entry.rationale}\n${entry.missingComponent ? `- Missing component: ${entry.missingComponent}\n- Nearest supported meaning (not substituted): “${entry.nearestSupportedMeaning}”\n` : ''}`).join('\n')}\n`);
  writeMd('docs/CANDIDATE_0022_CLAIM_MAP.md', `# Candidate 0022 — claim map\n\nThe Owner target is evaluated against existing components only. A blocked exact span keeps its whole claim blocked; nothing is implemented or accepted.\n\n${claimTable(candidate.predictionClaims)}\n\n${candidate.predictionClaims.map(claim => `## ${claim.claimId}\n\n**Exact proposed wording**\n\n${claim.proposedReaderWording}\n\n- Source-bound meaning: ${claim.sourceBoundMeaning}\n- Context/period/domain/horizon/direction: ${claim.context}; ${claim.period}; ${claim.domain}; ${claim.horizon}; ${claim.direction}\n- Evidence references: ${claim.evidenceRefs.join('; ')}\n- Exact evidence entries: ${claim.exactEvidenceEntryIds.join('; ')}\n- Evidence status: \`${claim.evidenceStatus}\`\n- Blocked exact spans: ${claim.blockedExactSpans.length ? claim.blockedExactSpans.map(span => `“${span}”`).join('; ') : 'none'}\n- Interpretation requiring Owner approval: ${claim.interpretationOwnerMustApprove}\n- Exact unsupported meanings excluded by the underlying map: ${claim.exactUnsupportedMeanings.join('; ')}\n- Duplication owner: ${claim.duplicationOwner}\n- Classification: ${claim.classification}; accepted=${claim.accepted}; implemented=${claim.implemented}\n`).join('\n')}\n## Explicit omissions\n\n${candidate.predictionOmissions.map(item => `- ${item.section}: ${item.classification} — ${item.reason}`).join('\n')}\n`);
  writeMd('docs/CANDIDATE_0022_SEMANTIC_OWNERSHIP.md', `# Candidate 0022 — semantic ownership\n\n**Pairwise semantic duplicate result: 0 across 55/55 prediction pairs.** This does not clear the six exact evidence gaps or the two reader-perceived cross-domain repetitions in the target support wording.\n\n${ownership.pairs.map((pair, index) => `## Pair ${index + 1}: ${pair.leftClaimId} × ${pair.rightClaimId}\n\n- Left meaning: ${pair.leftMeaning}\n- Right meaning: ${pair.rightMeaning}\n- Shared meaning atoms: ${pair.sharedMeaningAtoms.length ? pair.sharedMeaningAtoms.join('; ') : 'none'}\n- Exact wording equal: ${pair.sameExactWording}\n- Decision: ${pair.decision}\n- Rationale: ${pair.rationale}\n`).join('\n')}\n`);
  writeMd('docs/CANDIDATE_0021_TO_0022_BEFORE_AFTER.md', `# Candidate 0021 → Candidate 0022 — complete Before/After\n\nCandidate 0021 is Owner-rejected final wording. Candidate 0022 preserves the exact Owner redline, including blocked spans. No paragraph is abbreviated.\n\n## Prediction mapping\n\n${beforeAfter.predictionPairs.map((pair, index) => `### ${index + 1}. ${pair.semanticOwner}\n\n**Before — Candidate 0021 (full)**\n\n${pair.beforeFullParagraph}\n\n**After — Candidate 0022 Owner target (full)**\n\n${pair.afterFullParagraph}\n\nEvidence status: \`${pair.exactEvidenceStatus}\`. Blocked spans: ${pair.blockedExactSpans.length ? pair.blockedExactSpans.map(span => `“${span}”`).join('; ') : 'none'}.\n`).join('\n')}\n## Candidate 0021 — all sections and paragraphs (full)\n\n${sectionInventory(beforeAfter.beforeAllSections)}\n\n## Candidate 0022 — all sections and paragraphs (full)\n\n${sectionInventory(beforeAfter.afterAllSections)}\n`);
  writeMd('docs/CANDIDATE_0022_CONTENT_AUDIT.md', `# Candidate 0022 — targeted editorial audit\n\n**AI/Machine result: BLOCKED BY EXACT EVIDENCE GAP — PENDING OWNER DECISION. This is not Content PASS.**\n\nTwo complete reads checked prediction flow and certainty, then spoken Thai, repetition, formula construction, leakage and unsupported content.\n\n## New OR8 counters\n\n\`\`\`json\n${JSON.stringify(audit.counters, null, 2)}\n\`\`\`\n\nThe JSON record contains every exact span and full pair used to derive these values. Candidate 0021 negative controls detect conditional fallback=${c21Negative.counters.conditional_prediction_fallback}, cross-horizon repetition=${c21Negative.counters.cross_horizon_semantic_repetition}, reader-perceived repetition=${c21Negative.counters.reader_perceived_repetition}, generic positive/risk formula=${c21Negative.counters.generic_positive_then_risk_formula}, and unnatural Thai=${c21Negative.counters.unnatural_thai_phrase}. All eight isolated mutation controls are detected.\n\nCandidate 0022 has six unsupported causal/certainty/outcome spans and two reader-perceived support-to-domain repetitions. Pairwise semantic-atom duplicates remain 0/55 because those cross-domain causal meanings are unique but improperly owned and unsupported rather than identical claims.\n\n## Full Candidate read in both passes\n\n\`\`\`text\n${candidate.fullReaderCopy}\n\`\`\`\n`);

  return {candidate, ownership, audit, beforeAfter, exactEvidence: EXACT_EVIDENCE, c21Negative, controls};
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = buildAll();
  console.log(JSON.stringify({
    claims: result.candidate.predictionClaims.length,
    clauseChecks: result.exactEvidence.entryCount,
    supported: result.exactEvidence.supportedCount,
    blocked: result.exactEvidence.blockedCount,
    exactEvidenceStatus: result.exactEvidence.overallStatus,
    pairwiseChecks: result.ownership.pairs.length,
    pairwiseDuplicates: result.ownership.duplicatePairs.length,
    counters: result.audit.counters,
    candidate0021NegativeCounters: result.c21Negative.counters,
    mutationControlsDetected: result.controls.filter(control => control.detected).length,
    fullCopySha256: sha(result.candidate.fullReaderCopy),
  }, null, 2));
}
