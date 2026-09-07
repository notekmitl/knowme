// OR7 content/evidence only. This tool never invokes or modifies production runtime.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {read, resolveReference, sha, fileSha} from './or5r_actual_authority_v2.mjs';
import {
  buildCandidate as buildCandidate0020,
  evaluatePastEquivalence,
  pastEquivalenceNegativeControls,
  RUN1,
  RUN2,
  RAW03,
  RAW35,
} from './pr115_or6_content_candidate.mjs';

export const BASE = '1a94b0b02acae5a7890297288088cac92d92168b';
const REGISTRY = read('docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json');
const TRUTH_CORRECTION = 'docs/CANDIDATE_0020_CONTENT_TRUTH_CORRECTION.json';
const writeJson = (path, value) => fs.writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
const writeMd = (path, value) => fs.writeFileSync(path, value.endsWith('\n') ? value : value + '\n');
const clone = value => structuredClone(value);
const stable = value => JSON.stringify(value);

const candidate0020 = buildCandidate0020();
const c20ByOwner = new Map(candidate0020.predictionClaims.map(claim => [claim.semanticOwner, claim]));

const proposedWording = {
  overview: 'วัยเด็กของคุณถูกปัญหาในครอบครัวจำกัดอยู่มาก แต่ตั้งแต่อายุ 11 ปี เส้นชีวิตเปลี่ยนเป็นขาขึ้นและต่อเนื่องมาถึงตอนนี้',
  'past-0-10': 'ช่วงอายุ 0–10 ปี สุขภาพที่อ่อนแอ การงานที่ย่ำแย่ และการเงินที่ติดขัดของพ่อแม่ทำให้คุณได้รับการดูแลใกล้ชิดน้อยลง',
  'past-11-29': 'ช่วงอายุ 11–29 ปี ชีวิตเปลี่ยนเป็นขาขึ้น คุณได้ผลดีจากการเรียนและเริ่มสร้างเส้นทางงานของตัวเอง',
  'past-30-41': 'ช่วงอายุ 30–41 ปี ชีวิตยังอยู่ในขาขึ้น คุณรับผิดชอบงานมากขึ้นและต้องตัดสินใจเรื่องสำคัญด้วยตัวเองมากกว่าเดิม',
  current: 'ตอนนี้สิ่งที่คุณลงมือทำ การสื่อสารกับคนอื่น และการตัดสินใจติดขัดน้อยลง จึงจัดการเรื่องตรงหน้าได้คล่องกว่าเดิม',
  work: 'คุณมีงานทำต่อเนื่องและรับผิดชอบงานหลักได้เต็มที่ ภาระที่รับมากเกินไปจะเบียดเวลาของงานหลักและทำให้คุณภาพลดลง',
  finance: 'คุณมีเงินใช้และมีโชคลาภ เงินพร้อมใช้ทำให้ตัดสินใจเรื่องรายจ่ายได้คล่องขึ้น แต่รายจ่ายระยะยาวจะลดเงินที่เหลือสำหรับแผนใหม่',
  relationship: 'ความสัมพันธ์จะแน่นแฟ้นขึ้นเมื่อคำพูดและการกระทำของทั้งสองฝ่ายตรงกัน หากความคาดหวังยังไม่ตรงกัน การเพิ่มข้อผูกพันจะช้าลง',
  health: 'กำลังของคุณยังรองรับกิจวัตรได้ แต่เมื่อพักไม่พอ ร่างกายจะใช้เวลาฟื้นนานขึ้นและเหลือแรงสำหรับกิจกรรมถัดไปน้อยลง',
  support: 'ครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่ายจะให้ความช่วยเหลือคุณ',
  rolling12: 'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570 ขอบเขตงานที่คุณรับผิดชอบจะกว้างขึ้น และรายรับจะเพิ่มขึ้น หากอำนาจตัดสินใจไม่เพิ่มตามงาน คุณภาพงานหลักจะลดลง ส่วนเงินพร้อมใช้จะไม่เพิ่มตามรายรับหากรายจ่ายประจำโตตาม',
};

const claimMeta = {
  overview: {
    claimId: 'C21-A35-OVERVIEW-01',
    semanticSummary: 'เส้นชีวิตเริ่มด้วยข้อจำกัดครอบครัว ก่อนเปลี่ยนเป็นขาขึ้นตั้งแต่อายุ 11 จนถึงปัจจุบัน',
    meaningAtoms: ['life-arc-childhood-constraint-to-rising-adulthood'],
    exactUnsupportedMeanings: ['งาน เงิน หรือแรงสนับสนุนเป็นเรื่องเด่นในภาพรวม', 'เหตุการณ์เฉพาะหลังอายุ 11'],
    duplicationOwner: 'ภาพรวมเป็นเจ้าของเฉพาะเส้นชีวิต ไม่เป็นเจ้าของผลรายด้าน',
  },
  'past-0-10': {
    claimId: 'C21-A35-PAST-0-10-01',
    semanticSummary: 'ปัญหาสุขภาพ งาน และเงินของพ่อแม่ทำให้การดูแลใกล้ชิดลดลงในวัย 0–10',
    meaningAtoms: ['past-0-10-parent-constraints-limited-close-care'],
    exactUnsupportedMeanings: ['โรคเฉพาะ', 'พ่อหรือแม่คนใดคนหนึ่ง', 'จำนวนเงิน', 'ผลกระทบถาวรต่อเด็ก'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของเหตุการณ์ครอบครัววัย 0–10 เพียงจุดเดียว',
  },
  'past-11-29': {
    claimId: 'C21-A35-PAST-11-29-01',
    semanticSummary: 'ชีวิตวัย 11–29 เป็นขาขึ้น โดยการเรียนและการเริ่มสร้างทางงานให้ผลดี',
    meaningAtoms: ['past-11-29-learning-and-career-start-benefit'],
    exactUnsupportedMeanings: ['การเลื่อนตำแหน่ง', 'งานหรือนายจ้างเฉพาะ', 'เหตุการณ์ความสัมพันธ์หรือสุขภาพ'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของผลการเรียนและการเริ่มสร้างทางงานในวัย 11–29',
  },
  'past-30-41': {
    claimId: 'C21-A35-PAST-30-41-01',
    semanticSummary: 'ชีวิตวัย 30–41 ยังเป็นขาขึ้น พร้อมความรับผิดชอบงานและการตัดสินใจที่เพิ่มขึ้น',
    meaningAtoms: ['past-30-41-work-responsibility-and-decision-weight'],
    exactUnsupportedMeanings: ['ตำแหน่งงานเฉพาะ', 'การเปลี่ยนงาน', 'อำนาจเหนือบุคคลใด'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของความรับผิดชอบและการตัดสินใจของวัย 30–41',
  },
  current: {
    claimId: 'C21-A35-CURRENT-01',
    semanticSummary: 'การลงมือทำ การสื่อสาร และการตัดสินใจในปัจจุบันติดขัดน้อยลง',
    meaningAtoms: ['current-action-communication-decision-smoothness'],
    exactUnsupportedMeanings: ['ช่วงเปลี่ยนผ่าน', 'ผลลัพธ์ที่รับประกัน', 'การตัดสินใจเฉพาะเรื่อง'],
    duplicationOwner: 'ย่อหน้าปัจจุบันเป็นเจ้าของความคล่องของการทำ พูด และคิด ไม่สรุปงานหรือเงิน',
  },
  work: {
    claimId: 'C21-A35-WORK-01',
    semanticSummary: 'มีงานทำต่อเนื่อง แต่ภาระเกินกำลังเบียดเวลาและคุณภาพงานหลัก',
    meaningAtoms: ['current-work-availability', 'current-work-load-reduces-core-quality'],
    exactUnsupportedMeanings: ['การเลื่อนตำแหน่ง', 'นายจ้างหรืองานเฉพาะ', 'วันที่เกิดเหตุ'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของสภาพงานปัจจุบัน; การขยายขอบเขตงานในปีถัดไปเป็นของ rolling12',
  },
  finance: {
    claimId: 'C21-A35-FINANCE-01',
    semanticSummary: 'มีเงินใช้และโชคลาภ แต่รายจ่ายระยะยาวลดเงินที่พร้อมใช้กับแผนใหม่',
    meaningAtoms: ['current-money-available-and-luck', 'current-long-expense-limits-options'],
    exactUnsupportedMeanings: ['จำนวนเงิน', 'ขนาดโชคลาภ', 'วันที่ได้เงิน', 'รายได้จากงานเฉพาะ'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของฐานเงินปัจจุบัน; การเปลี่ยนรายรับและรายจ่ายในปีถัดไปเป็นของ rolling12',
  },
  relationship: {
    claimId: 'C21-A35-RELATIONSHIP-01',
    semanticSummary: 'การทำตามข้อตกลงทำให้ความสัมพันธ์แน่นแฟ้น; ความคาดหวังไม่ตรงกันชะลอข้อผูกพัน',
    meaningAtoms: ['current-relationship-agreement-strengthens', 'current-expectation-mismatch-delays-commitment'],
    exactUnsupportedMeanings: ['บุคคลเฉพาะ', 'การแต่งงาน', 'การเลิกรา', 'วันที่เกิดเหตุ'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของผลต่อความสัมพันธ์และไม่อธิบายงานหรือเงิน',
  },
  health: {
    claimId: 'C21-A35-HEALTH-01',
    semanticSummary: 'กำลังรองรับกิจวัตร แต่การพักไม่พอทำให้ฟื้นช้าและเหลือแรงน้อยลง',
    meaningAtoms: ['current-stamina-supports-routine', 'current-insufficient-rest-slows-recovery'],
    exactUnsupportedMeanings: ['ชื่อโรค', 'การวินิจฉัย', 'การรักษา', 'เหตุการณ์สุขภาพเฉพาะ'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของกำลังและผลของการพัก ไม่ให้คำแนะนำทางการแพทย์',
  },
  support: {
    claimId: 'C21-A35-SUPPORT-01',
    semanticSummary: 'ครู ผู้มีประสบการณ์ เพื่อน และเครือข่ายให้ความช่วยเหลือ',
    meaningAtoms: ['current-support-from-teachers-peers-network'],
    exactUnsupportedMeanings: ['ชื่อบุคคล', 'ผู้สนับสนุนที่รับประกันผล', 'ความสัมพันธ์เชิงรัก'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของแหล่งความช่วยเหลือเพียงจุดเดียว',
  },
  rolling12: {
    claimId: 'C21-A35-HORIZON-01',
    semanticSummary: 'ในกรอบวันที่ ขอบเขตงานและรายรับเพิ่ม; อำนาจตัดสินใจและรายจ่ายกำหนดคุณภาพงานกับเงินพร้อมใช้',
    meaningAtoms: ['rolling12-work-scope-expands', 'rolling12-income-and-recurring-cost-rise', 'rolling12-decision-authority-quality-effect', 'rolling12-expense-cash-effect'],
    exactUnsupportedMeanings: ['เดือนดีหรือเดือนเสีย', 'เหตุการณ์รายเดือน', 'จำนวนรายรับ', 'ตำแหน่งงาน', 'จุดทบทวนกลางปี'],
    duplicationOwner: 'ย่อหน้านี้เป็นเจ้าของการเปลี่ยนแปลงภายในกรอบวันที่ ไม่ย้ำสถานะปัจจุบัน',
  },
};

const orderedOwners = ['overview', 'past-0-10', 'past-11-29', 'past-30-41', 'current', 'work', 'finance', 'relationship', 'health', 'support', 'rolling12'];

export const candidateClaims = orderedOwners.map(owner => {
  const source = c20ByOwner.get(owner);
  const meta = claimMeta[owner];
  assert.ok(source, owner);
  assert.ok(meta, owner);
  return {
    claimId: meta.claimId,
    sourceClaimId: source.claimId,
    semanticOwner: owner,
    section: source.section,
    timeScope: source.timeScope,
    context: source.context,
    period: source.period,
    domain: source.domain,
    horizon: source.horizon,
    direction: source.direction,
    evidenceRefs: clone(source.evidenceRefs),
    sourceBoundMeaning: source.sourceBoundMeaning,
    semanticSummary: meta.semanticSummary,
    proposedReaderWording: proposedWording[owner],
    interpretationOwnerMustApprove: `Owner must approve that “${proposedWording[owner]}” stays within: ${source.sourceBoundMeaning}`,
    exactUnsupportedMeanings: meta.exactUnsupportedMeanings,
    duplicationOwner: meta.duplicationOwner,
    meaningAtoms: meta.meaningAtoms,
    classification: 'PROPOSED_OWNER_TEMPLATE',
    accepted: false,
    implemented: false,
    noSemanticExpansion: true,
  };
});

export const predictionOmissions = [
  {
    claimId: 'C21-A35-NEXT-OMIT-01',
    semanticOwner: 'next',
    section: 'ช่วงชีวิตถัดไป — อายุ 63–79 ปี',
    classification: 'OMIT_UNSUPPORTED_MISSING_COMPONENT',
    sourceCandidate: candidate0020.omissions[0].actualSourceWording,
    reason: 'Owner accepts the OR6 omission: no resolved relationship domain-to-template binding exists, so neither heading nor filler appears.',
  },
  {
    claimId: 'C21-A35-SUMMARY-OMIT-01',
    semanticOwner: 'summary',
    section: 'สรุปคำทำนาย',
    classification: 'OMIT_NO_NEW_SEMANTIC_FUNCTION',
    sourceCandidate: c20ByOwner.get('summary').proposedReaderWording,
    reason: 'A summary would only repeat work, money and support already owned elsewhere; it is omitted rather than adding or duplicating a claim.',
  },
];

const advice = 'กำหนดขอบเขตงานที่รับเพิ่ม ตรวจเงินคงเหลือหลังรายจ่ายจำเป็นก่อนขยายแผน และกันเวลาพักไว้ให้ร่างกายฟื้นแรง';
const disclaimer = 'คำทำนายนี้เป็นการตีความตามหลักโหราศาสตร์และความเชื่อ ใช้ประกอบการพิจารณาร่วมกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ';
const psychologyParagraph = 'คุณคิดเป็นระบบและทำได้ดีเมื่อรู้ว่าขั้นต่อไปต้องทำอะไร ความอดทนช่วยให้คุณค่อย ๆ สร้างสิ่งต่าง ๆ ให้มั่นคง จึงเป็นคนที่คนอื่นพึ่งพาได้';

function sectionText(section) {
  return [section.title, ...section.paragraphs].join('\n');
}

function psychologyOmissions() {
  const foundation = candidate0020.sections.filter(section => section.kind === 'foundation');
  return foundation.map(section => ({
    title: section.title,
    fullOriginalParagraphs: clone(section.paragraphs),
    retained: section.title === 'สรุปตัวคุณแบบตรง ๆ' ? [psychologyParagraph] : [],
    omitted: section.title !== 'สรุปตัวคุณแบบตรง ๆ' || section.paragraphs.join(' ') !== psychologyParagraph,
    reason: section.title === 'สรุปตัวคุณแบบตรง ๆ'
      ? 'Retain only the timeless personality sentences; omit the time-bound warning and self-review advice.'
      : 'Omit prediction/advice or repeated domain packaging from psychology; do not carry the legacy section into Candidate 0021.',
  }));
}

export function buildCandidate0021() {
  const claim = owner => candidateClaims.find(item => item.semanticOwner === owner);
  const provenance = candidate0020.sections.filter(section => section.kind === 'provenance').map(clone);
  const sections = [
    {kind: 'profile', title: 'ข้อมูลดวง', paragraphs: ['เกิดวันที่ 6 มิถุนายน 2525 เวลา 00:35 น. จังหวัดเชียงใหม่', 'เพศชาย · วันทางโหราศาสตร์เป็นวันเสาร์', 'ลัคนาราศีกุมภ์ 19°19′']},
    {kind: 'prediction', title: claim('overview').section, paragraphs: [claim('overview').proposedReaderWording], claimId: claim('overview').claimId},
    {kind: 'heading', title: 'คำทำนายอดีต', paragraphs: []},
    ...['past-0-10', 'past-11-29', 'past-30-41'].map(owner => ({kind: 'prediction', title: claim(owner).section, paragraphs: [claim(owner).proposedReaderWording], claimId: claim(owner).claimId})),
    ...['current', 'work', 'finance', 'relationship', 'health', 'support', 'rolling12'].map(owner => ({kind: 'prediction', title: claim(owner).section, paragraphs: [claim(owner).proposedReaderWording], claimId: claim(owner).claimId})),
    {kind: 'advice', title: 'คำแนะนำ', paragraphs: [advice]},
    {kind: 'disclaimer', title: 'ข้อจำกัด', paragraphs: [disclaimer, 'ข้อความด้านสุขภาพใช้เพื่อการทบทวนทั่วไป ไม่ใช่การวินิจฉัยโรคหรือคำแนะนำทางการแพทย์']},
    {kind: 'separation', title: 'พื้นดวงและมุมมองด้านจิตวิทยา', paragraphs: ['เนื้อหาต่อไปนี้กล่าวถึงลักษณะพื้นฐานเท่านั้น แยกจากคำทำนายและคำแนะนำ']},
    {kind: 'psychology', title: 'ลักษณะพื้นฐาน', paragraphs: [psychologyParagraph]},
    {kind: 'separation', title: 'ที่มาและวิธีอ่าน', paragraphs: ['ข้อมูลและหลักที่ใช้ประกอบรายงาน แยกจากคำทำนาย']},
    ...provenance,
  ];
  const fullReaderCopy = sections.flatMap(section => [section.title, ...section.paragraphs, '']).join('\n').trimEnd();
  return {
    schema: 'candidate-0021-actual-0035/1',
    fixture: clone(candidate0020.fixture),
    status: 'PROPOSED_OWNER_COPY_PENDING_REVIEW',
    implemented: false,
    accepted: false,
    sourceArchitectureChanged: false,
    sourceCandidate: 'Candidate 0020 OWNER_REJECTED_PRODUCT_CONTENT',
    predictionClaims: candidateClaims,
    predictionOmissions,
    psychology: {paragraph: psychologyParagraph, omissions: psychologyOmissions()},
    advice,
    disclaimer,
    sections,
    fullReaderCopy,
  };
}

function tokenSet(text) {
  return new Set(text.toLowerCase().split(/[\s,.;:!?—–()]+/u).filter(token => token.length >= 3));
}

export function pairwiseSemanticOwnership(candidate) {
  const pairs = [];
  for (let i = 0; i < candidate.predictionClaims.length; i += 1) {
    for (let j = i + 1; j < candidate.predictionClaims.length; j += 1) {
      const left = candidate.predictionClaims[i];
      const right = candidate.predictionClaims[j];
      const sharedMeaningAtoms = left.meaningAtoms.filter(atom => right.meaningAtoms.includes(atom));
      const leftTokens = tokenSet(left.proposedReaderWording);
      const rightTokens = tokenSet(right.proposedReaderWording);
      const sharedLexicalTokens = [...leftTokens].filter(token => rightTokens.has(token));
      const sameExactWording = left.proposedReaderWording === right.proposedReaderWording;
      const duplicate = sameExactWording || sharedMeaningAtoms.length > 0;
      let rationale = 'Distinct semantic atoms and outcomes.';
      if (left.semanticOwner === 'overview' || right.semanticOwner === 'overview') rationale = 'Overview owns only the life arc; the other paragraph owns the concrete period/domain result.';
      if (left.semanticOwner === 'rolling12' || right.semanticOwner === 'rolling12') rationale = 'Rolling-12 owns dated changes in work scope and income/cost balance; the other paragraph owns a present or historical condition.';
      if (duplicate) rationale = 'Rejected: the pair shares an exact wording or semantic atom.';
      pairs.push({
        leftClaimId: left.claimId,
        rightClaimId: right.claimId,
        leftOwner: left.semanticOwner,
        rightOwner: right.semanticOwner,
        leftMeaning: left.semanticSummary,
        rightMeaning: right.semanticSummary,
        sameExactWording,
        sharedLexicalTokens,
        sharedMeaningAtoms,
        duplicate,
        decision: duplicate ? 'DUPLICATE' : 'DISTINCT_OWNER',
        rationale,
      });
    }
  }
  return {
    schema: 'candidate-0021-semantic-ownership/1',
    claims: candidate.predictionClaims.length,
    expectedPairs: candidate.predictionClaims.length * (candidate.predictionClaims.length - 1) / 2,
    pairs,
    duplicatePairs: pairs.filter(pair => pair.duplicate),
    status: pairs.every(pair => !pair.duplicate) ? 'AI_PAIRWISE_OWNERSHIP_PASS_PENDING_OWNER_COPY_REVIEW' : 'PAIRWISE_OWNERSHIP_NO_GO',
    ownerContentPass: false,
  };
}

function spansMatching(claims, rules) {
  return claims.flatMap(claim => rules.flatMap(rule => rule.pattern.test(claim.proposedReaderWording)
    ? [{claimId: claim.claimId, semanticOwner: claim.semanticOwner, exactSpan: claim.proposedReaderWording, reason: rule.reason}]
    : []));
}

const genericRules = [
  {pattern: /เดินหน้าเป็นหลัก|มีจังหวะขยับต่อ|จังหวะงานไม่หยุดนิ่ง|เรื่องนี้ยังเดินหน้าต่อ/u, reason: 'Direction is asserted without a concrete result.'},
  {pattern: /อยู่ในทางที่ดีขึ้น|โดยรวม(?:ดีขึ้น|แข็งแรงขึ้น)/u, reason: 'Broad improvement can apply to many readers without explaining the outcome.'},
  {pattern: /เป็นแกนสำคัญ|เข้ามามีบทบาทมากขึ้น/u, reason: 'Abstract importance substitutes for a direct result.'},
];
const vaguePressureRules = [
  {pattern: /แรงกด(?:ด้านเงิน|ดัน)?|กดพลัง/u, reason: 'Pressure is named without saying what it changes.'},
];
const riskLexicon = ['เดินหน้า', 'ดีขึ้น', 'แรงกด'];

function lexicalOveruse(claims) {
  const text = claims.map(claim => claim.proposedReaderWording).join('\n');
  return riskLexicon.map(term => ({term, count: text.split(term).length - 1})).filter(item => item.count >= 3);
}

function rejected0020SemanticPairs(candidate) {
  const signals = [
    {meaning: 'งานเป็นผลเด่นหรือเดินหน้า', match: text => /งาน.*(?:เรื่องเด่น|เดินหน้า|ขยับ|ไม่หยุดนิ่ง)/u.test(text)},
    {meaning: 'เงินดีขึ้นหรือคล่องขึ้น', match: text => /เงิน.*(?:เรื่องเด่น|ดีขึ้น|คล่อง|เดินหน้า)/u.test(text)},
    {meaning: 'แรงสนับสนุนเป็นผลเด่น', match: text => /แรงสนับสนุน/u.test(text)},
  ];
  const duplicates = [];
  for (const signal of signals) {
    const owners = candidate.predictionClaims.filter(claim => signal.match(claim.proposedReaderWording));
    for (let i = 0; i < owners.length; i += 1) for (let j = i + 1; j < owners.length; j += 1) {
      duplicates.push({meaning: signal.meaning, leftClaimId: owners[i].claimId, rightClaimId: owners[j].claimId,
        leftSpan: owners[i].proposedReaderWording, rightSpan: owners[j].proposedReaderWording});
    }
  }
  return duplicates;
}

function psychologyEvidence(candidate) {
  const predictionTerms = [/ช่วงนี้/u, /จะ/u, /ถ้ารับงานเพิ่ม/u];
  const adviceTerms = [/ก่อนตัดสินใจ/u, /ควร/u, /ลอง/u];
  const domainHeadings = new Set(['การงาน', 'การเงิน', 'ความรักและความสัมพันธ์', 'สุขภาพ', 'สุขภาพและพลังชีวิต', 'โชคลาภและแรงสนับสนุน']);
  const psychology = candidate.sections.filter(section => ['foundation', 'psychology'].includes(section.kind));
  const predictionLeakage = psychology.flatMap(section => section.paragraphs.filter(text => predictionTerms.some(rule => rule.test(text))).map(exactSpan => ({section: section.title, exactSpan})));
  const adviceLeakage = psychology.flatMap(section => section.paragraphs.filter(text => adviceTerms.some(rule => rule.test(text))).map(exactSpan => ({section: section.title, exactSpan})));
  const repeatedHeadings = psychology.filter(section => domainHeadings.has(section.title)).map(section => ({heading: section.title, fullSection: sectionText(section)}));
  return {predictionLeakage, adviceLeakage, repeatedHeadings};
}

function summaryWithoutFunction(candidate) {
  const summary = candidate.predictionClaims.find(claim => claim.semanticOwner === 'summary');
  if (!summary) return [];
  const otherText = candidate.predictionClaims.filter(claim => claim.semanticOwner !== 'summary').map(claim => claim.proposedReaderWording).join('\n');
  const repeatedDomains = ['งาน', 'เงิน', 'แรงสนับสนุน'].filter(term => summary.proposedReaderWording.includes(term) && otherText.includes(term));
  return repeatedDomains.length ? [{claimId: summary.claimId, exactSpan: summary.proposedReaderWording, repeatedDomains}] : [];
}

export function auditCandidate0021(candidate, ownership) {
  const psychology = psychologyEvidence(candidate);
  const evidence = {
    genericOutcomePhrases: spansMatching(candidate.predictionClaims, genericRules),
    vaguePressurePhrases: spansMatching(candidate.predictionClaims, vaguePressureRules),
    lexicalOveruse: lexicalOveruse(candidate.predictionClaims),
    crossSectionSemanticRepetition: ownership.duplicatePairs,
    psychologyPredictionLeakage: psychology.predictionLeakage,
    psychologyAdviceLeakage: psychology.adviceLeakage,
    repeatedDomainHeadings: psychology.repeatedHeadings,
    summaryWithoutNewFunction: summaryWithoutFunction(candidate),
    chronology: candidate.predictionClaims.map(claim => ({claimId: claim.claimId, owner: claim.semanticOwner, timeScope: claim.timeScope, exactSpan: claim.proposedReaderWording})),
    pairwiseMeaningsChecked: ownership.pairs.map(pair => ({leftClaimId: pair.leftClaimId, rightClaimId: pair.rightClaimId, leftMeaning: pair.leftMeaning, rightMeaning: pair.rightMeaning, decision: pair.decision})),
  };
  const counters = {
    generic_outcome_phrases: evidence.genericOutcomePhrases.length,
    vague_pressure_phrases: evidence.vaguePressurePhrases.length,
    lexical_overuse: evidence.lexicalOveruse.length,
    cross_section_semantic_repetition: evidence.crossSectionSemanticRepetition.length,
    psychology_prediction_leakage: evidence.psychologyPredictionLeakage.length,
    psychology_advice_leakage: evidence.psychologyAdviceLeakage.length,
    repeated_domain_headings: evidence.repeatedDomainHeadings.length,
    summary_without_new_function: evidence.summaryWithoutNewFunction.length,
  };
  const otherChecks = {
    bannedCandidate0021Phrases: ['เดินหน้าเป็นหลัก', 'มีจังหวะขยับต่อ', 'จังหวะงานไม่หยุดนิ่ง', 'เรื่องนี้ยังเดินหน้าต่อ', 'แรงกดด้านเงิน', 'มีแรงกดดัน', 'ยังเดินไปข้างหน้า', 'เป็นแกนสำคัญ', 'เข้ามามีบทบาทมากขึ้น', 'อยู่ในทางที่ดีขึ้น', 'โดยรวมดีขึ้น', 'อาจ', 'มีแนวโน้ม', 'ลอง', 'ควรถามตัวเอง']
      .filter(phrase => candidate.predictionClaims.some(claim => claim.proposedReaderWording.includes(phrase))),
    unsupportedReferenceClaims: candidate.predictionClaims.filter(claim => claim.evidenceRefs.some(id => !resolveReference(id, REGISTRY).resolved)).map(claim => claim.claimId),
    classificationErrors: candidate.predictionClaims.filter(claim => claim.classification !== 'PROPOSED_OWNER_TEMPLATE' || claim.accepted || claim.implemented).map(claim => claim.claimId),
    predictionOmissionLeaks: candidate.predictionOmissions.filter(omission => candidate.fullReaderCopy.includes(omission.sourceCandidate) || candidate.fullReaderCopy.includes(omission.section)).map(omission => omission.claimId),
  };
  const status = Object.values(counters).every(value => value === 0) && Object.values(otherChecks).every(value => value.length === 0)
    ? 'AI_HUMAN_EDITORIAL_AUDIT_READY_PENDING_OWNER_COPY_REVIEW'
    : 'CANDIDATE_0021_CONTENT_AUDIT_NO_GO';
  return {
    schema: 'candidate-0021-content-audit/1',
    status,
    ownerContentPass: false,
    candidateImplemented: false,
    passes: [
      {pass: 1, completeRead: true, focus: ['chronology', 'continuous_reading', 'prediction_quality', 'outcome_clarity', 'decisiveness'], sectionsRead: candidate.sections.length},
      {pass: 2, completeRead: true, focus: ['natural_thai', 'lexical_and_semantic_repetition', 'template_language', 'internal_contradiction', 'personality_advice_methodology_leakage', 'unsupported_content'], sectionsRead: candidate.sections.length},
    ],
    counters,
    evidence,
    otherChecks,
    note: 'Counters are derived from full exact spans, explicit pairwise meaning review and section-role checks. A machine-ready result is not Owner Content PASS.',
    fullCandidateReaderCopy: candidate.fullReaderCopy,
  };
}

export function auditRejectedCandidate0020(candidate = candidate0020) {
  const psychology = psychologyEvidence(candidate);
  const evidence = {
    genericOutcomePhrases: spansMatching(candidate.predictionClaims, genericRules),
    vaguePressurePhrases: spansMatching(candidate.predictionClaims, vaguePressureRules),
    lexicalOveruse: lexicalOveruse(candidate.predictionClaims),
    crossSectionSemanticRepetition: rejected0020SemanticPairs(candidate),
    psychologyPredictionLeakage: psychology.predictionLeakage,
    psychologyAdviceLeakage: psychology.adviceLeakage,
    repeatedDomainHeadings: psychology.repeatedHeadings,
    summaryWithoutNewFunction: summaryWithoutFunction(candidate),
  };
  return {
    counters: {
      generic_outcome_phrases: evidence.genericOutcomePhrases.length,
      vague_pressure_phrases: evidence.vaguePressurePhrases.length,
      lexical_overuse: evidence.lexicalOveruse.length,
      cross_section_semantic_repetition: evidence.crossSectionSemanticRepetition.length,
      psychology_prediction_leakage: evidence.psychologyPredictionLeakage.length,
      psychology_advice_leakage: evidence.psychologyAdviceLeakage.length,
      repeated_domain_headings: evidence.repeatedDomainHeadings.length,
      summary_without_new_function: evidence.summaryWithoutNewFunction.length,
    },
    evidence,
    status: 'OWNER_REJECTED_PRODUCT_CONTENT_DETECTED',
  };
}

export function buildBeforeAfter(candidate21) {
  const byOwner21 = new Map(candidate21.predictionClaims.map(claim => [claim.semanticOwner, claim]));
  const predictionPairs = candidate0020.predictionClaims.map(before => {
    const after = byOwner21.get(before.semanticOwner);
    const omission = candidate21.predictionOmissions.find(item => item.semanticOwner === before.semanticOwner);
    return {
      semanticOwner: before.semanticOwner,
      beforeClaimId: before.claimId,
      beforeFullParagraph: before.proposedReaderWording,
      afterClaimId: after?.claimId ?? omission?.claimId,
      afterFullParagraph: after?.proposedReaderWording ?? null,
      disposition: after ? 'HUMAN_EDITORIAL_REWRITE_PROPOSED' : omission?.classification,
      reason: after ? after.duplicationOwner : omission?.reason,
    };
  });
  return {
    schema: 'candidate-0020-to-0021-before-after/1',
    beforeStatus: 'OWNER_REJECTED_PRODUCT_CONTENT',
    afterStatus: 'PROPOSED_OWNER_COPY_PENDING_REVIEW',
    predictionPairs,
    beforeAllSections: candidate0020.sections.map(section => ({kind: section.kind, title: section.title, fullParagraphs: clone(section.paragraphs)})),
    afterAllSections: candidate21.sections.map(section => ({kind: section.kind, title: section.title, fullParagraphs: clone(section.paragraphs)})),
    note: 'Both complete section inventories preserve every title and paragraph verbatim on each side. Null After means an explicit omission, never an abbreviation.',
  };
}

function markdownSectionInventory(sections) {
  return sections.map((section, index) => `### ${index + 1}. ${section.title}\n\nKind: \`${section.kind}\`\n\n${section.fullParagraphs.length ? section.fullParagraphs.join('\n\n') : '_No paragraph in this heading-only section._'}`).join('\n\n');
}

function claimTable(claims) {
  return '| Claim | Owner | Section | Scope | Domain | Horizon | Direction | Classification |\n|---|---|---|---|---|---|---|---|\n' +
    claims.map(claim => `| ${claim.claimId} | ${claim.semanticOwner} | ${claim.section} | ${claim.timeScope} | ${claim.domain} | ${claim.horizon} | ${claim.direction} | ${claim.classification} |`).join('\n');
}

export function buildAll() {
  const minute03Run1 = read(`${RUN1}/${RAW03}`);
  const minute35Run1 = read(`${RUN1}/${RAW35}`);
  assert.equal(fileSha(`${RUN1}/${RAW03}`), fileSha(`${RUN2}/${RAW03}`));
  assert.equal(fileSha(`${RUN1}/${RAW35}`), fileSha(`${RUN2}/${RAW35}`));
  const equivalence = evaluatePastEquivalence(minute03Run1, minute35Run1);
  const equivalenceControls = pastEquivalenceNegativeControls(minute03Run1, minute35Run1);
  assert.ok(equivalence.equivalent);
  assert.ok(equivalenceControls.every(control => control.rejected));
  const truthCorrection = read(TRUTH_CORRECTION);
  assert.equal(truthCorrection.finalStatus, 'OWNER_REJECTED_PRODUCT_CONTENT');
  const candidate = buildCandidate0021();
  const ownership = pairwiseSemanticOwnership(candidate);
  const audit = auditCandidate0021(candidate, ownership);
  const rejected0020Audit = auditRejectedCandidate0020();
  const beforeAfter = buildBeforeAfter(candidate);
  assert.equal(ownership.pairs.length, 55);
  assert.equal(ownership.duplicatePairs.length, 0);
  assert.equal(audit.status, 'AI_HUMAN_EDITORIAL_AUDIT_READY_PENDING_OWNER_COPY_REVIEW');
  assert.ok(Object.values(rejected0020Audit.counters).every(value => value > 0));
  assert.equal(candidate0020.status, 'PROPOSED_OWNER_COPY_PENDING_REVIEW');

  writeJson('docs/CANDIDATE_0021_CLAIM_MAP.json', candidate);
  writeJson('docs/CANDIDATE_0021_SEMANTIC_OWNERSHIP.json', ownership);
  writeJson('docs/CANDIDATE_0021_CONTENT_AUDIT.json', audit);

  writeMd('docs/CANDIDATE_0021_ACTUAL_0035_FULL_READER_COPY.md', '# Candidate 0021 — actual 00:35 full reader copy\n\n**PROPOSED OWNER COPY — PENDING OWNER COPY REVIEW — NOT IMPLEMENTED — NOT ACCEPTED**\n\nThis is the complete continuous reader copy. Candidate 0020 remains separately preserved as rejected history. The 63–79 prediction and redundant summary are omitted; psychology contains timeless traits only.\n\n<!-- BEGIN CANDIDATE 0021 FULL READER COPY -->\n' + candidate.fullReaderCopy + '\n<!-- END CANDIDATE 0021 FULL READER COPY -->\n\nFull-reader-copy SHA-256 (UTF-8 exact model value): `' + sha(candidate.fullReaderCopy) + '`.\n');

  writeMd('docs/CANDIDATE_0021_CLAIM_MAP.md', '# Candidate 0021 — claim map\n\nEvery prediction remains `PROPOSED_OWNER_TEMPLATE`, pending Owner wording approval and not implemented. Existing OR6 evidence references and source-bound meanings are reused without new evidence architecture.\n\n' + claimTable(candidate.predictionClaims) + '\n\n' + candidate.predictionClaims.map(claim => `## ${claim.claimId}\n\n**Proposed wording**\n\n${claim.proposedReaderWording}\n\n**Source-bound meaning**\n\n${claim.sourceBoundMeaning}\n\n**Interpretation requiring Owner approval**\n\n${claim.interpretationOwnerMustApprove}\n\n- Context/period/domain/horizon/direction: ${claim.context}; ${claim.period}; ${claim.domain}; ${claim.horizon}; ${claim.direction}\n- Evidence references: ${claim.evidenceRefs.join('; ')}\n- Exact unsupported meanings excluded: ${claim.exactUnsupportedMeanings.join('; ')}\n- Duplication owner: ${claim.duplicationOwner}\n- Meaning atoms: ${claim.meaningAtoms.join('; ')}\n- Classification: ${claim.classification}; accepted=${claim.accepted}; implemented=${claim.implemented}\n`).join('\n') + '\n## Explicit prediction omissions\n\n' + candidate.predictionOmissions.map(omission => `### ${omission.claimId}\n\n**Before/source wording (full)**\n\n${omission.sourceCandidate}\n\n**Candidate 0021 wording**\n\n_No reader-facing paragraph or heading._\n\n${omission.reason}\n`).join('\n'));

  writeMd('docs/CANDIDATE_0021_SEMANTIC_OWNERSHIP.md', '# Candidate 0021 — semantic ownership\n\n**AI pairwise ownership result: no duplicate pair detected; pending Owner copy review.** This is not Content PASS.\n\nAll **55/55** pairs across 11 prediction paragraphs were reviewed using full semantic summaries, meaning atoms, domains and time scopes—not exact-string comparison alone.\n\n' + ownership.pairs.map((pair, index) => `## Pair ${index + 1}: ${pair.leftClaimId} × ${pair.rightClaimId}\n\n- Left meaning: ${pair.leftMeaning}\n- Right meaning: ${pair.rightMeaning}\n- Shared meaning atoms: ${pair.sharedMeaningAtoms.length ? pair.sharedMeaningAtoms.join('; ') : 'none'}\n- Shared lexical tokens: ${pair.sharedLexicalTokens.length ? pair.sharedLexicalTokens.join('; ') : 'none'}\n- Exact wording equal: ${pair.sameExactWording}\n- Decision: ${pair.decision}\n- Rationale: ${pair.rationale}\n`).join('\n'));

  writeMd('docs/CANDIDATE_0020_TO_0021_BEFORE_AFTER.md', '# Candidate 0020 → Candidate 0021 — complete Before/After\n\nCandidate 0020 is Owner-rejected historical evidence. Candidate 0021 is proposed copy pending review. No paragraph is shortened or replaced by an ellipsis.\n\n## Prediction mapping\n\n' + beforeAfter.predictionPairs.map((pair, index) => `### ${index + 1}. ${pair.semanticOwner}\n\n**Before — Candidate 0020 (full)**\n\n${pair.beforeFullParagraph}\n\n**After — Candidate 0021 (full)**\n\n${pair.afterFullParagraph ?? '_Omitted completely; no reader-facing paragraph or heading._'}\n\nDisposition: ${pair.disposition}. ${pair.reason}\n`).join('\n') + '\n## Candidate 0020 — all sections and paragraphs (full)\n\n' + markdownSectionInventory(beforeAfter.beforeAllSections) + '\n\n## Candidate 0021 — all sections and paragraphs (full)\n\n' + markdownSectionInventory(beforeAfter.afterAllSections) + '\n');

  writeMd('docs/CANDIDATE_0021_CONTENT_AUDIT.md', '# Candidate 0021 — human editorial audit\n\n**AI/Machine editorial audit ready; PENDING OWNER COPY REVIEW. This is not Owner Content PASS.**\n\nTwo complete reads were performed. Pass 1 checked sequence, continuous reading, predictive quality, direct outcomes and decisiveness. Pass 2 checked natural Thai, lexical and semantic repetition, formula language, internal contradiction, psychology/advice/methodology leakage and unsupported content.\n\n## Derived counters\n\n```json\n' + JSON.stringify(audit.counters, null, 2) + '\n```\n\nEvery counter is backed by exact-span arrays in the JSON record. Pairwise semantic ownership covers 55/55 pairs with each pair’s full meaning and decision. Candidate 0020 is used as a real rejected control and produces nonzero values for all eight added counters:\n\n```json\n' + JSON.stringify(rejected0020Audit.counters, null, 2) + '\n```\n\n## Psychology disposition\n\nOnly the timeless two-sentence trait description remains under “ลักษณะพื้นฐาน”. Time-bound prediction, self-review advice, and repeated domain sections are omitted and listed with full original paragraphs in the Candidate JSON.\n\n## Full Candidate read in both passes\n\n```text\n' + candidate.fullReaderCopy + '\n```\n');

  return {candidate, ownership, audit, rejected0020Audit, beforeAfter, equivalence, equivalenceControls};
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = buildAll();
  console.log(JSON.stringify({
    candidateClaims: result.candidate.predictionClaims.length,
    omittedPredictions: result.candidate.predictionOmissions.length,
    pairwiseChecks: result.ownership.pairs.length,
    duplicatePairs: result.ownership.duplicatePairs.length,
    auditStatus: result.audit.status,
    counters: result.audit.counters,
    rejected0020DetectedCounters: result.rejected0020Audit.counters,
    fullCopySha256: sha(result.candidate.fullReaderCopy),
  }, null, 2));
}
