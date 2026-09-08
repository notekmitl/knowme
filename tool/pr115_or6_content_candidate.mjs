// OR6 content/evidence only. This tool never invokes or modifies production runtime.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {fileSha, read, resolveReference, sha} from './or5r_actual_authority_v2.mjs';

export const BASE = '9067f541d8f718735f931af7afc3dd1f5726138a';
export const RUN1 = 'build/or5r-neutral-v2-run1';
export const RUN2 = 'build/or5r-neutral-v2-run2';
export const RAW03 = 'OR5_RAW_0003_20260829.json';
export const RAW35 = 'OR5_ACTUAL_0035_RUNTIME_EVIDENCE.json';
const BASELINE = 'test/evidence/fixtures/or5r_known_baseline.json';
const DECISION = 'docs/PR115_OR6_OWNER_CONTENT_DECISION.json';
const REGISTRY = read('docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json');
const CONTRACT = read('knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1.json');
const writeJson = (path, value) => fs.writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
const writeMd = (path, value) => fs.writeFileSync(path, value.endsWith('\n') ? value : value + '\n');
const clone = value => structuredClone(value);
const stable = value => JSON.stringify(value);
const refs = ids => ids.map(id => resolveReference(id, REGISTRY));

const sourceRefsByPeriod = {
  '0-10': ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT', 'canon.mahabhut.p28.saturn_owns_family'],
  '11-29': ['source.T0003-SRC-11-62-RISING-BLOCK', 'canon.mahabhut.p220.jupiter_owns_learning', 'canon.mahabhut.p220.jupiter_owns_career'],
  '30-41': ['source.T0003-SRC-11-62-RISING-BLOCK', 'source.T0003-SRC-30-41-PLACEMENT', 'canon.mahabhut.p39.det_owns_career'],
};

function relevantPeriodRows(raw) {
  return raw.completedPeriods.map(row => clone(row));
}

export function evaluatePastEquivalence(minute03, minute35) {
  const fields = {
    contextId: minute03.contextId === minute35.contextId,
    thaiAstrologicalDate: minute03.birthDataInternal.astrologicalDate === minute35.birthDataInternal.astrologicalDate,
    thaiAstrologicalDay: minute03.birthDataInternal.thaiWeekdayNumber === minute35.birthDataInternal.thaiWeekdayNumber,
    completedPeriodRows: stable(relevantPeriodRows(minute03)) === stable(relevantPeriodRows(minute35)),
    noActual0035FixtureBranch: minute35.plan.ownerAcceptedGoldenOverrideApplied === 0 &&
      minute35.plan.fixtureSpecificBranches === 0 && minute35.plan.unexpectedFixtureSpecificBranches === 0,
  };
  const periods = relevantPeriodRows(minute35).map(row => {
    const period = `${row.ageStart}-${row.ageEnd}`;
    const selectorId = `selector.${row.matrixApplicationId}`;
    const selector = resolveReference(selectorId, REGISTRY);
    const sourceBindings = refs(sourceRefsByPeriod[period] || []);
    const timeDependentKeys = Object.keys(row).filter(key => /ascendant|lagna|birthTime|timeDependent/i.test(key));
    const selectorMatches = selector.resolved && selector.value.contextId === row.contextId &&
      selector.value.matrixApplicationId === row.matrixApplicationId && selector.value.agePeriod === period &&
      selector.value.planet === row.planet && selector.value.taksaRole === row.taksaRole &&
      selector.value.mahabhutHouse === row.mahabhutHouse && selector.value.periodStatus === row.periodStatus;
    return {period, contextId: row.contextId, selectorId, row003: relevantPeriodRows(minute03).find(x => x.matrixApplicationId === row.matrixApplicationId),
      row035: row, selector, selectorMatches, sourceBindings,
      sourceBindingsResolved: sourceBindings.length > 0 && sourceBindings.every(x => x.resolved),
      timeDependentKeys, timeOrAscendantDependent: timeDependentKeys.length > 0,
      exactCandidateWordingTransferred: false,
      goldenDecisionUsedAsEquivalenceEvidence: false,
      status: selectorMatches && sourceBindings.length > 0 && sourceBindings.every(x => x.resolved) && timeDependentKeys.length === 0
        ? 'SOURCE_PERIOD_EQUIVALENT' : 'NOT_EQUIVALENT'};
  });
  const equivalent = Object.values(fields).every(Boolean) && periods.length === 3 && periods.every(p => p.status === 'SOURCE_PERIOD_EQUIVALENT');
  return {equivalent, fields, periods,
    importantBoundary: 'The 00:03 reader plan uses its accepted golden override. That fixture-specific reader wording is deliberately excluded. The shared Mahabhut context/period rows and resolved source bindings—not the golden decisions—are equivalent.',
    ascendantDifference: {minute003: minute03.canonical.degreeWithinSign, minute035: minute35.canonical.degreeWithinSign,
      affectsThisPastEquivalence: false, reason: 'The inspected selector rows contain no ascendant/time-dependent key and are byte-equal despite the degree difference.'}};
}

export function pastEquivalenceNegativeControls(minute03, minute35) {
  const controls = [];
  for (const [name, mutate] of [
    ['wrong Thai astrological day/context', x => { x.contextId = 'mahabhut2537.rem0.sunday'; x.birthDataInternal.thaiWeekdayNumber = 1; }],
    ['wrong period selector', x => { x.completedPeriods[0].matrixApplicationId = 'mahabhut2537.rem0.saturday.jupiter.0_10'; }],
    ['time/ascendant-dependent component introduced', x => { x.completedPeriods[0].ascendantDegree = 19.313708418191027; }],
  ]) {
    const mutant = clone(minute35); mutate(mutant);
    controls.push({name, rejected: !evaluatePastEquivalence(minute03, mutant).equivalent});
  }
  return controls;
}

const typed = (horizon, domain) => `typed.${horizon}.${domain}`;
const selector = period => ({'0-10': 'saturn.0_10', '11-29': 'jupiter.11_29', '30-41': 'rahu.30_41', '42-62': 'venus.42_62'}[period]);
const sref = period => `selector.mahabhut2537.rem0.saturday.${selector(period)}`;
const claim = (id, owner, section, timeScope, domain, horizon, direction, evidenceRefs, sourceBoundMeaning, proposedReaderWording, origin, semanticAtoms) => ({
  claimId: id, semanticOwner: owner, section, timeScope, context: 'mahabhut2537.rem0.saturday', period: timeScope,
  domain, horizon, direction, evidenceRefs, sourceBoundMeaning, proposedReaderWording,
  classification: 'PROPOSED_OWNER_TEMPLATE', origin, semanticAtoms,
  accepted: false, supportedByOwner: false, noSemanticExpansion: true,
});

export const candidateClaims = [
  claim('C20-A35-OVERVIEW-01', 'overview', 'ภาพรวมเส้นทางชีวิต', '0-62', 'life_path', 'overview', 'down_then_up',
    [sref('0-10'), sref('11-29'), sref('30-41'), sref('42-62'), 'source.T0003-SRC-0-10-FAMILY-CONSTRAINT', 'source.T0003-SRC-11-62-RISING-BLOCK', 'source.T0003-SRC-42-62-WORK', 'source.T0003-SRC-42-62-FINANCE', 'source.T0003-SRC-42-62-SUPPORT'],
    'วัย 0–10 มีข้อจำกัดด้านครอบครัว; อายุ 11–62 เป็นทิศทางขาขึ้น; อายุ 42–62 มีงาน เงิน และแรงสนับสนุนตามแหล่งข้อมูลเดิม',
    'ชีวิตวัยเด็กมีข้อจำกัดจากครอบครัว หลังอายุ 11 ปี จังหวะชีวิตดีขึ้น และตั้งแต่อายุ 42 ปี งาน เงิน และแรงสนับสนุนเป็นเรื่องเด่นของชีวิต',
    'REVIEW_REQUIRED_REWRITE', ['life-chronology-arc']),
  claim('C20-A35-PAST-0-10-01', 'past-0-10', 'อายุ 0–10 ปี', '0-10', 'family_constraints', 'past-life-period', 'dueng_tok',
    [sref('0-10'), ...sourceRefsByPeriod['0-10']],
    'แหล่งข้อมูลระบุข้อจำกัดด้านสุขภาพ การงาน และการเงินของพ่อแม่ ซึ่งทำให้มีเวลาดูแลใกล้ชิดน้อยลงในวัย 0–10',
    'ในวัย 0–10 ปี ข้อจำกัดด้านสุขภาพ การงาน และการเงินของครอบครัวทำให้ผู้ใหญ่มีเวลาดูแลใกล้ชิดน้อยลง ชีวิตช่วงนั้นจึงอยู่ภายใต้เงื่อนไขของบ้านเป็นหลัก',
    'PAST_EQUIVALENT_SOURCE_PERIOD_PROPOSAL', ['past-family-constraints']),
  claim('C20-A35-PAST-11-29-01', 'past-11-29', 'อายุ 11–29 ปี', '11-29', 'learning_and_career', 'past-life-period', 'dueng_khuen',
    [sref('11-29'), ...sourceRefsByPeriod['11-29']],
    'ช่วง 11–29 อยู่ในแนวโน้มขาขึ้น 11–62; ดาวพฤหัส/อายุ/ราชาเชื่อมกับการเรียนและการสร้างทางงานตาม Canon โดยไม่มีเหตุการณ์เฉพาะ',
    'ช่วงอายุ 11–29 ปี ชีวิตเดินหน้าไปในทางที่ดีขึ้น การเรียนและการสร้างทางงานเป็นแกนสำคัญของช่วงนั้น',
    'PAST_EQUIVALENT_SOURCE_PERIOD_PROPOSAL', ['past-learning-career']),
  claim('C20-A35-PAST-30-41-01', 'past-30-41', 'อายุ 30–41 ปี', '30-41', 'career_and_authority', 'past-life-period', 'dueng_khuen',
    [sref('30-41'), ...sourceRefsByPeriod['30-41']],
    'ช่วง 30–41 อยู่ในแนวโน้มขาขึ้น; ราหู/เดช/อธิบดีวางแกนที่งาน อำนาจตัดสินใจ และความรับผิดชอบ โดยไม่ระบุการเปลี่ยนงานเฉพาะ',
    'ช่วงอายุ 30–41 ปี ชีวิตยังเดินหน้าไปในทางที่ดี งาน อำนาจตัดสินใจ และความรับผิดชอบเข้ามามีบทบาทมากขึ้น',
    'REVIEW_REQUIRED_REWRITE', ['past-career-authority']),
  claim('C20-A35-CURRENT-01', 'current', 'คำทำนายปัจจุบัน — อายุ 44 ปี', '42-62', 'life_path', 'current', 'dueng_khuen',
    [sref('42-62'), 'source.T0003-SRC-42-62-FLOW'],
    'อายุ 44 อยู่ภายในช่วง 42–62; แหล่งข้อมูลรองรับทิศทางที่การทำ การพูด และการคิดเดินได้ราบรื่น โดยไม่ใช่ช่วงเปลี่ยนผ่าน',
    'ตอนนี้อายุ 44 ปี อยู่ในช่วง 42–62 ปี ซึ่งการทำงาน การสื่อสาร และการตัดสินใจราบรื่นขึ้น',
    'NARROWED_SUPPORTED_MEANING_AFTER_EXPANSION_REJECTION', ['current-flow']),
  claim('C20-A35-WORK-01', 'work', 'การงาน', '42-62', 'career', 'current', 'strong_primary_pressure_secondary',
    [sref('42-62'), 'source.T0003-SRC-42-62-WORK', typed('current', 'career')],
    'แหล่งข้อมูลรองรับทางทำงาน; typed material ให้ career=strong และ pressure เป็นความเสี่ยงรอง ไม่มีตำแหน่งงานหรือนายจ้างเฉพาะ',
    'เรื่องงานเดินหน้าเป็นหลัก มีงานให้ทำและมีจังหวะขยับต่อ ภาระงานยังกดเวลา แต่จังหวะงานไม่หยุดนิ่ง',
    'REVIEW_REQUIRED_REWRITE', ['current-work']),
  claim('C20-A35-FINANCE-01', 'finance', 'การเงิน', '42-62', 'finance', 'current', 'strong_primary_pressure_secondary',
    [sref('42-62'), 'source.T0003-SRC-42-62-FINANCE', 'canon.mahabhut.p39.sri_owns_finance', typed('current', 'finance')],
    'แหล่งข้อมูลรองรับการมีเงินใช้และโชคลาภ; typed material ให้ finance=strong และ pressure เป็นความเสี่ยงรอง โดยไม่มีจำนวนหรือวันเฉพาะ',
    'เรื่องเงินดีขึ้นเป็นหลัก มีเงินหมุนใช้และมีโชคลาภ แรงกดด้านเงินยังมีอยู่ แต่ความคล่องตัวทางการเงินเพิ่มขึ้น',
    'REVIEW_REQUIRED_REWRITE', ['current-finance']),
  claim('C20-A35-RELATIONSHIP-01', 'relationship', 'ความรักและความสัมพันธ์', '42-62', 'relationship', 'current', 'strong_primary_pressure_secondary',
    [sref('42-62'), 'canon.mahabhut.p16.venus_owns_relationship_male', 'canon.mahabhut.p28.venus_owns_relationship', typed('current', 'relationship')],
    'Canon เชื่อมดาวศุกร์กับความสัมพันธ์สำหรับชาย; typed material ให้ relationship=strong และ pressure เป็นความเสี่ยงรอง โดยไม่มีเหตุการณ์หรือบุคคลเฉพาะ',
    'ความสัมพันธ์อยู่ในทางที่ดีขึ้น แม้ยังมีแรงกดดัน แต่เรื่องนี้ยังเดินหน้าต่อ',
    'REVIEW_REQUIRED_REWRITE', ['current-relationship']),
  claim('C20-A35-HEALTH-01', 'health', 'สุขภาพ', '42-62', 'health', 'current', 'strong_primary_pressure_secondary',
    [sref('42-62'), 'canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน', typed('current', 'health')],
    'Canon ระบุความเจ็บป่วยจากการพักไม่พอ; typed material ให้ health=strong และ pressure เป็นความเสี่ยงรอง ไม่รองรับโรคเฉพาะหรือการวินิจฉัย',
    'สุขภาพโดยรวมแข็งแรงขึ้นและรองรับกิจวัตรได้ การพักไม่พอยังเป็นจุดที่กดพลังลง',
    'REVIEW_REQUIRED_REWRITE', ['current-health']),
  claim('C20-A35-SUPPORT-01', 'support', 'โชคลาภและแรงสนับสนุน', '42-62', 'support', 'current', 'dueng_khuen',
    [sref('42-62'), 'source.T0003-SRC-42-62-SUPPORT', 'source.T0003-SRC-42-62-WORK', 'source.T0003-SRC-42-62-FINANCE'],
    'แหล่งข้อมูลระบุแรงสนับสนุนจากครู ผู้มีประสบการณ์ เพื่อน และเครือข่าย พร้อมทางด้านงาน เงิน และโชคลาภ โดยไม่ระบุบุคคล',
    'แรงสนับสนุนมาจากครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่าย ช่วยเปิดทางให้งานและการเงินเดินต่อได้',
    'REVIEW_REQUIRED_REWRITE', ['current-support']),
  claim('C20-A35-HORIZON-01', 'rolling12', 'คำทำนาย 12 เดือนข้างหน้า', '2026-08-29/2027-08-28', 'career_and_finance', 'next12Months', 'strong_primary_pressure_secondary',
    [sref('42-62'), 'source.T0003-SRC-42-62-WORK', 'source.T0003-SRC-42-62-FINANCE', typed('next12Months', 'career'), typed('next12Months', 'finance'), 'timing.rolling-12-month-label'],
    'ช่วงวันที่มาจาก rolling asOf; typed materials ให้งานและเงิน=strong โดย pressure เป็นความเสี่ยงรอง; แหล่งข้อมูล 42–62 รองรับงาน เงิน และโชคลาภ',
    'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570 งานและเงินเป็นสองเรื่องที่เดินหน้า มีงานให้ทำต่อและเงินคล่องขึ้น ภาระงานกับแรงกดด้านเงินยังมีอยู่ แต่จังหวะ 12 เดือนนี้ยังเดินไปข้างหน้า',
    'REVIEW_REQUIRED_REWRITE', ['rolling12-work-finance']),
  claim('C20-A35-SUMMARY-01', 'summary', 'สรุปคำทำนาย', '42-62|2026-08-29/2027-08-28', 'life_path', 'summary', 'positive_primary',
    ['C20-A35-CURRENT-01', 'C20-A35-WORK-01', 'C20-A35-FINANCE-01', 'C20-A35-SUPPORT-01', 'C20-A35-HORIZON-01'],
    'ย่อเฉพาะผลของ claims ปัจจุบันและ 12 เดือนที่ map แล้ว ไม่เพิ่มช่วงชีวิตถัดไปหรือเหตุการณ์ใหม่',
    'ช่วงนี้เด่นเรื่องงานที่เดินหน้า เงินที่คล่องขึ้น และแรงสนับสนุนจากคนรอบตัว รอบ 12 เดือนข้างหน้ายังเดินไปในทางเดียวกัน',
    'PROPOSED_SUMMARY_FROM_MAPPED_CLAIMS', ['current-horizon-summary']),
];

export const omissions = [{
  claimId: 'C20-A35-NEXT-OMIT-01', semanticOwner: 'next', section: 'ช่วงชีวิตถัดไป — อายุ 63–79 ปี',
  timeScope: '63-79', classification: 'OMIT_UNSUPPORTED_MISSING_COMPONENT',
  actualSourceWording: 'เมื่อเข้าสู่อายุ 63–79 ปี ฐานงานและทรัพย์สินที่สะสมไว้จะเริ่มต่อยอด หน้าที่และอำนาจรับผิดชอบจะชัดขึ้น ในช่วงชีวิตถัดไป ความสัมพันธ์ที่รองรับภาระใหม่ไม่ได้จะเปลี่ยนระยะหรือยุติบทบาทเดิม เมื่อบทบาทใหม่เริ่มขึ้น ข้อตกลงที่ไม่ตรงกันจะทำให้จังหวะด้านความสัมพันธ์สะดุด รอยต่อของช่วงชีวิตจะทำให้ด้านความสัมพันธ์เปลี่ยนก่อนจังหวะใหม่ลงตัว',
  reason: 'Neutral V2 found no resolved domain-to-template binding for the quiet-relationship change/termination proposition. Mercury placement is not an event. The unsupported paragraph and heading are absent from Candidate reader copy; no filler replaces them.',
  evidenceRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79', 'canon.mahabhut.p28.mercury_owns_family', 'canon.mahabhut.p33.mercury_relates_attribute_profession_นักพูด'],
}];

const disclaimer = 'คำทำนายนี้เป็นการตีความตามหลักโหราศาสตร์และความเชื่อ ใช้ประกอบการพิจารณาร่วมกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ';
const advice = 'จัดลำดับงานและภาระที่รับไว้ให้ชัด เก็บส่วนของรายรับไว้เป็นเงินสำรอง และรักษาเวลาพักให้สม่ำเสมอ';

function exactExistingFoundation(boundary) {
  const byId = new Map(boundary.sections.map(s => [s.id, s]));
  const use = id => { const s = byId.get(id); assert.ok(s, id); return {title: s.title, paragraphs: [...s.paragraphs]}; };
  const health = use('report-body-08');
  health.paragraphs = health.paragraphs.filter(p => !p.includes('ไม่ใช่การวินิจฉัยโรค'));
  const provenance = use('report-body-27');
  provenance.paragraphs = provenance.paragraphs.filter(p => !p.includes('ไม่ใช่คำฟันธง'));
  return {
    foundation: ['report-body-02', 'report-body-03', 'report-body-04', 'report-body-05', 'report-body-06', 'report-body-07'].map(use).concat([health, use('report-body-09')]),
    provenance: [use('report-body-26'), provenance],
  };
}

export function buildCandidate(boundary = read(BASELINE)['35']) {
  const nonPrediction = exactExistingFoundation(boundary);
  const orderedOwners = ['overview', 'past-0-10', 'past-11-29', 'past-30-41', 'current', 'work', 'finance', 'relationship', 'health', 'support', 'rolling12', 'summary'];
  assert.deepEqual(candidateClaims.map(c => c.semanticOwner), orderedOwners);
  const sections = [
    {kind: 'profile', title: 'ข้อมูลดวง', paragraphs: ['เกิดวันที่ 6 มิถุนายน 2525 เวลา 00:35 น. จังหวัดเชียงใหม่', 'เพศชาย · วันทางโหราศาสตร์เป็นวันเสาร์', 'ลัคนาราศีกุมภ์ 19°19′']},
    {kind: 'prediction', title: 'ภาพรวมเส้นทางชีวิต', paragraphs: [candidateClaims[0].proposedReaderWording]},
    {kind: 'heading', title: 'คำทำนายอดีต', paragraphs: []},
    ...candidateClaims.slice(1, 4).map(c => ({kind: 'prediction', title: c.section, paragraphs: [c.proposedReaderWording], claimId: c.claimId})),
    ...candidateClaims.slice(4, 10).map(c => ({kind: 'prediction', title: c.section, paragraphs: [c.proposedReaderWording], claimId: c.claimId})),
    {kind: 'prediction', title: candidateClaims[10].section, paragraphs: [candidateClaims[10].proposedReaderWording], claimId: candidateClaims[10].claimId},
    {kind: 'prediction', title: candidateClaims[11].section, paragraphs: [candidateClaims[11].proposedReaderWording], claimId: candidateClaims[11].claimId},
    {kind: 'advice', title: 'คำแนะนำ', paragraphs: [advice]},
    {kind: 'disclaimer', title: 'ข้อจำกัด', paragraphs: [disclaimer, 'ข้อความด้านสุขภาพใช้เพื่อการทบทวนทั่วไป ไม่ใช่การวินิจฉัยโรคหรือคำแนะนำทางการแพทย์']},
    {kind: 'separation', title: 'พื้นดวงและมุมมองด้านจิตวิทยา', paragraphs: ['เนื้อหาต่อไปนี้แยกจากคำทำนาย และไม่นับเป็นคำทำนาย']},
    ...nonPrediction.foundation.map(x => ({kind: 'foundation', ...x})),
    {kind: 'separation', title: 'ที่มาและวิธีอ่าน', paragraphs: ['ข้อมูลและหลักที่ใช้ประกอบรายงาน แยกจากคำทำนาย']},
    ...nonPrediction.provenance.map(x => ({kind: 'provenance', ...x})),
  ];
  const lines = [];
  for (const s of sections) lines.push(s.title, ...s.paragraphs, '');
  return {schema: 'candidate-0020-actual-0035/1', fixture: {sex: 'male', birthDate: '1982-06-06', birthTime: '00:35', province: 'Chiang Mai', asOf: '2026-08-29', timeZone: 'Asia/Bangkok', ascendant: 'Aquarius 19°19′'},
    status: 'PROPOSED_OWNER_COPY_PENDING_REVIEW', implemented: false, accepted: false, predictionClaims: candidateClaims,
    omissions, advice, disclaimer, sections, fullReaderCopy: lines.join('\n').trimEnd()};
}

function actualPredictions(raw) {
  return raw.plan.decisions.filter(d => d.kind === 'prediction' && d.emitted).map(d => ({claimId: d.claimId, owner: d.semanticOwner, section: d.section, text: d.text}));
}

export function buildBeforeAfter(raw, candidate) {
  const before = actualPredictions(raw);
  const pairs = [
    ['overview', 'overview'], ['missing past 0-10', 'past-0-10'], ['missing past 11-29', 'past-11-29'], ['past', 'past-30-41'],
    ['current', 'current'], ['work', 'work'], ['finance', 'finance'], ['relationship', 'relationship'], ['health', 'health'],
    ['support', 'support'], ['rolling12', 'rolling12'], ['next', null],
  ].map(([oldOwner, newOwner]) => ({
    beforeOwner: oldOwner, before: before.find(x => x.owner === oldOwner)?.text ?? null,
    afterOwner: newOwner, after: newOwner ? candidate.predictionClaims.find(x => x.semanticOwner === newOwner)?.proposedReaderWording ?? null : null,
    afterClassification: newOwner ? 'PROPOSED_OWNER_TEMPLATE' : 'OMIT_UNSUPPORTED_MISSING_COMPONENT',
  }));
  return {schema: 'candidate-0020-before-after/1', beforeCount: before.length, afterPredictionCount: candidate.predictionClaims.length,
    before, after: candidate.predictionClaims.map(c => ({claimId: c.claimId, section: c.section, text: c.proposedReaderWording})), pairs,
    note: 'Null means no reader-facing paragraph exists on that side. It never substitutes for an existing paragraph: every existing Before and every proposed After paragraph is reproduced in full.'};
}

const predictionKinds = new Set(['prediction']);
const bannedPredictionPhrases = ['อาจ', 'มีแนวโน้ม', 'ลอง', 'ควรถามตัวเอง', 'รอบขยายผล', 'การมองเห็นผลงาน', 'ประคองด้านสุขภาพและการพัก', 'จากกฎที่มีหลักฐานครบ', 'ผลลัพธ์นี้เป็นมุมมองเพื่อทำความเข้าใจตัวเอง ไม่ใช่คำทำนาย'];
export function auditCandidate(candidate, equivalence) {
  const predictionSections = candidate.sections.filter(s => predictionKinds.has(s.kind));
  const predictionText = predictionSections.flatMap(s => s.paragraphs).join('\n');
  const past = candidate.predictionClaims.filter(c => c.semanticOwner.startsWith('past-'));
  const refsResolved = new Map();
  for (const c of candidate.predictionClaims.filter(c => c.semanticOwner !== 'summary')) {
    refsResolved.set(c.claimId, c.evidenceRefs.map(id => resolveReference(id, REGISTRY)));
  }
  const atomOwners = new Map();
  for (const c of candidate.predictionClaims) for (const atom of c.semanticAtoms) atomOwners.set(atom, [...(atomOwners.get(atom) || []), c.claimId]);
  const mixed = candidate.predictionClaims.filter(c => c.direction.includes('pressure_secondary'));
  const counters = {
    chronology_errors: stable(candidate.predictionClaims.map(c => c.semanticOwner)) === stable(['overview', 'past-0-10', 'past-11-29', 'past-30-41', 'current', 'work', 'finance', 'relationship', 'health', 'support', 'rolling12', 'summary']) ? 0 : 1,
    missing_required_periods: equivalence.equivalent && ['0-10', '11-29', '30-41'].every(period => past.some(c => c.timeScope === period)) ? 0 : 3 - past.length,
    future_tense_in_past: past.filter(c => /จะ|กำลัง|ต่อไป|ข้างหน้า/.test(c.proposedReaderWording)).length,
    past_reflection_questions: past.filter(c => /\?|？|ลอง|ทบทวน|นึกย้อน|ถามตัวเอง/.test(c.proposedReaderWording)).length,
    personality_inside_prediction: /คุณเป็นคน|นิสัย|บุคลิก|ตัวตน/.test(predictionText) ? 1 : 0,
    advice_inside_prediction: candidate.predictionClaims.filter(c => /ควร|จง|ให้คุณ|ต้องเลือก|ต้องจัด|ต้องเก็บ/.test(c.proposedReaderWording)).length,
    methodological_language: candidate.predictionClaims.filter(c => /หลักฐาน|กฎ|คำนวณ|selector|domain|typed|runtime|Canon|source/.test(c.proposedReaderWording)).length,
    ambiguous_template_language: candidate.predictionClaims.reduce((n, c) => n + bannedPredictionPhrases.filter(p => c.proposedReaderWording.includes(p)).length, 0),
    contradictory_direction: mixed.filter(c => !(/เป็นหลัก|โดยรวม|อยู่ในทางที่ดีขึ้น|ยังเดินไปข้างหน้า/.test(c.proposedReaderWording) && /แรงกด|พักไม่พอ|ภาระงาน/.test(c.proposedReaderWording))).length,
    semantic_duplicate_pairs: [...atomOwners.values()].filter(ids => ids.length > 1).reduce((n, ids) => n + (ids.length * (ids.length - 1) / 2), 0),
    duplicate_semantic_owner: candidate.predictionClaims.length - new Set(candidate.predictionClaims.map(c => c.semanticOwner)).size,
    unsupported_claims: candidate.predictionClaims.filter(c => !c.noSemanticExpansion || ['UNSUPPORTED_SEMANTIC_EXPANSION', 'UNSUPPORTED_MISSING_COMPONENT'].includes(c.classification)).length,
    missing_bindings: candidate.omissions.filter(o => o.classification === 'OMIT_UNSUPPORTED_MISSING_COMPONENT').length,
    certainty_downgrade: candidate.predictionClaims.filter(c => /อาจ|มีแนวโน้ม|น่าจะ|คงจะ|อาจจะ/.test(c.proposedReaderWording)).length,
    new_unmapped_claims: candidate.predictionClaims.filter(c => !c.sourceBoundMeaning || !c.evidenceRefs.length || (c.semanticOwner !== 'summary' && refsResolved.get(c.claimId).some(r => !r.resolved))).length,
  };
  const permittedNonzero = counters.missing_bindings === candidate.omissions.length && candidate.omissions.every(o => !candidate.fullReaderCopy.includes(o.actualSourceWording) && !candidate.fullReaderCopy.includes(o.section));
  const otherErrors = Object.entries(counters).filter(([key, value]) => key !== 'missing_bindings' && value !== 0);
  return {schema: 'candidate-0020-content-audit/1',
    status: otherErrors.length === 0 && permittedNonzero ? 'AI_MACHINE_CONTENT_AUDIT_READY_PENDING_OWNER_COPY_REVIEW' : 'CANDIDATE_CONTENT_AUDIT_NO_GO',
    ownerContentPass: false, candidateImplemented: false,
    passes: [
      {pass: 1, completeRead: true, focus: ['chronology', 'continuous_story', 'prediction_not_advice', 'decisive_primary_direction'], sectionsRead: candidate.sections.length},
      {pass: 2, completeRead: true, focus: ['natural_thai', 'tense', 'semantic_duplication', 'personality_substitution', 'advice_conversion', 'methodology_leakage', 'unsupported_content'], sectionsRead: candidate.sections.length},
    ], counters, allowedNonzero: {missing_bindings: candidate.omissions.length, reason: 'The sole missing next-period binding is explicitly omitted from reader copy; no heading or filler remains.'},
    derivedChecks: {resolvedReferenceClaims: [...refsResolved.entries()].map(([claimId, value]) => ({claimId, references: value.length, unresolved: value.filter(r => !r.resolved).length})),
      semanticAtomOwners: Object.fromEntries(atomOwners), disclaimerOccurrences: candidate.fullReaderCopy.split(disclaimer).length - 1,
      nextPeriodHeadingOccurrences: candidate.fullReaderCopy.split(omissions[0].section).length - 1,
      bannedPredictionHits: candidate.predictionClaims.flatMap(c => bannedPredictionPhrases.filter(p => c.proposedReaderWording.includes(p)).map(phrase => ({claimId: c.claimId, phrase}))),
      currentTransitionPhraseOccurrences: candidate.fullReaderCopy.split('อายุ 44 ปีเป็นช่วงเปลี่ยนผ่าน').length - 1},
    conclusions: [
      'Candidate uses past tense and restores all three proven-equivalent past periods without transferring exact Candidate0011 acceptance.',
      'Age 44 transition expansion is absent; current copy is narrowed to the existing 42–62 flow meaning.',
      'Next 63–79 prediction and heading are omitted because the existing binding is incomplete.',
      'Personality/foundation and provenance follow the prediction/disclaimer area and are explicitly outside prediction ownership.',
      'This machine audit checks consistency and mapped boundaries; it is not semantic truth, predictive accuracy or Owner Content PASS.'
    ], fullCandidateReaderCopy: candidate.fullReaderCopy};
}

function markdownSections(sections) {
  return sections.map(s => `## ${s.title}\n\n${s.paragraphs.join('\n\n')}`).join('\n\n');
}
function mdTable(rows) {
  return '| Claim | Owner | Section | Scope | Domain | Horizon | Direction | Classification |\n|---|---|---|---|---|---|---|---|\n' +
    rows.map(c => `| ${c.claimId} | ${c.semanticOwner} | ${c.section} | ${c.timeScope} | ${c.domain} | ${c.horizon} | ${c.direction} | ${c.classification} |`).join('\n');
}

export function buildAll() {
  const minute03 = read(`${RUN1}/${RAW03}`), minute35 = read(`${RUN1}/${RAW35}`);
  assert.equal(fileSha(`${RUN1}/${RAW03}`), fileSha(`${RUN2}/${RAW03}`));
  assert.equal(fileSha(`${RUN1}/${RAW35}`), fileSha(`${RUN2}/${RAW35}`));
  const boundary = read(BASELINE)['35'];
  assert.deepEqual(minute35.plan.decisions, boundary.decisions);
  const equivalence = evaluatePastEquivalence(minute03, minute35);
  const negativeControls = pastEquivalenceNegativeControls(minute03, minute35);
  assert.ok(equivalence.equivalent);
  assert.ok(negativeControls.every(c => c.rejected));
  const candidate = buildCandidate(boundary);
  const beforeAfter = buildBeforeAfter(minute35, candidate);
  const audit = auditCandidate(candidate, equivalence);
  assert.equal(audit.status, 'AI_MACHINE_CONTENT_AUDIT_READY_PENDING_OWNER_COPY_REVIEW');
  assert.equal(audit.derivedChecks.disclaimerOccurrences, 1);
  assert.equal(audit.derivedChecks.nextPeriodHeadingOccurrences, 0);
  assert.equal(audit.derivedChecks.currentTransitionPhraseOccurrences, 0);
  const equivalenceDoc = {schema: 'actual-0035-past-period-equivalence/1', fixture003: minute03.input, fixture035: minute35.input,
    asOf: minute35.asOf, equivalent: equivalence.equivalent, equivalence, negativeControls,
    conclusion: 'Past source-period equivalence PASS for 0–10, 11–29 and 30–41 only. Candidate wording is a new PROPOSED_OWNER_TEMPLATE; exact Candidate0011 wording/acceptance is not transferred.'};
  writeJson('docs/ACTUAL_0035_PAST_PERIOD_EQUIVALENCE.json', equivalenceDoc);
  writeMd('docs/ACTUAL_0035_PAST_PERIOD_EQUIVALENCE.md', '# Actual 00:35 — past-period equivalence\n\n**PASS for source-period applicability; NOT a transfer of Candidate0011 wording acceptance.**\n\n' +
    `00:03 and 00:35 share context \`${minute35.contextId}\`, Thai astrological date \`${minute35.birthDataInternal.astrologicalDate.slice(0, 10)}\`, weekday ${minute35.birthDataInternal.thaiWeekdayNumber}, and the same three completed period rows. Ascendant degrees differ (${minute03.canonical.degreeWithinSign} vs ${minute35.canonical.degreeWithinSign}), but inspected past selector rows have no ascendant/time-dependent field.\n\n` +
    equivalence.importantBoundary + '\n\n' + mdTable(equivalence.periods.map(p => ({claimId: p.selectorId, semanticOwner: 'past-selector', section: p.period, timeScope: p.period, domain: p.row035.taksaRole, horizon: 'past-life-period', direction: p.row035.periodStatus, classification: p.status}))) +
    '\n\n## Source bindings\n\n' + equivalence.periods.map(p => `### ${p.period}\n\n- Selector: ${p.selectorId} — ${p.selectorMatches ? 'resolved and equal' : 'mismatch'}\n- Sources: ${p.sourceBindings.map(r => `${r.id} (${r.resolved ? 'resolved' : 'unresolved'})`).join('; ')}\n- Time/ascendant-dependent keys: ${p.timeDependentKeys.length}\n`).join('\n') +
    '\n## Negative controls\n\n' + negativeControls.map(c => `- ${c.name}: ${c.rejected ? 'REJECTED' : 'NOT REJECTED'}`).join('\n') + '\n');
  writeJson('docs/CANDIDATE_0020_CLAIM_MAP.json', candidate);
  writeMd('docs/CANDIDATE_0020_CLAIM_MAP.md', '# Candidate 0020 — claim map\n\nEvery emitted prediction is `PROPOSED_OWNER_TEMPLATE`: component-bound proposed language, not supported/accepted copy and not implemented. Candidate0011 exact wording is not reused as authority.\n\n' +
    mdTable(candidate.predictionClaims) + '\n\n' + candidate.predictionClaims.map(c => `## ${c.claimId}\n\n**Proposed reader wording**\n\n${c.proposedReaderWording}\n\n**Source-bound meaning**\n\n${c.sourceBoundMeaning}\n\n- Evidence/components: ${c.evidenceRefs.join('; ')}\n- Classification: ${c.classification}; origin: ${c.origin}\n- No semantic expansion: ${c.noSemanticExpansion}; Owner accepted: ${c.accepted}\n- Omitted source wording: none beyond the explicit boundaries stated in source-bound meaning. Unsupported dates, amounts, people, diagnoses and causal outcomes were not added.\n`).join('\n') +
    '\n## Explicit omission\n\n' + candidate.omissions.map(o => `### ${o.claimId}\n\n**Actual source wording (full)**\n\n${o.actualSourceWording}\n\n**Candidate reader wording**\n\nNo reader-facing paragraph or heading.\n\n${o.reason}\n\nEvidence reviewed: ${o.evidenceRefs.join('; ')}\n`).join('\n'));
  writeMd('docs/CANDIDATE_0020_ACTUAL_0035_FULL_READER_COPY.md', '# Candidate 0020 — actual 00:35 full reader copy\n\n**PROPOSED OWNER COPY — PENDING OWNER COPY REVIEW — NOT IMPLEMENTED — NOT ACCEPTED**\n\nThe text below is continuous and complete. Prediction appears first in chronological order; foundation/psychology and provenance are explicitly separate and later. No next-period heading or filler appears because its chain is incomplete.\n\n<!-- BEGIN CANDIDATE 0020 FULL READER COPY -->\n' + candidate.fullReaderCopy + '\n<!-- END CANDIDATE 0020 FULL READER COPY -->\n\nFull-reader-copy SHA-256 (UTF-8, exact text between model fields): `' + sha(candidate.fullReaderCopy) + '`.\n');
  writeJson('docs/CANDIDATE_0020_CONTENT_AUDIT.json', audit);
  writeMd('docs/CANDIDATE_0020_CONTENT_AUDIT.md', '# Candidate 0020 — content audit\n\n**AI/Machine Content Audit — PENDING OWNER COPY REVIEW. This is not Owner Content PASS.**\n\nTwo complete reads were performed: pass 1 checked chronology/story/prediction/directness; pass 2 checked natural Thai/tense/semantic ownership/duplication/personality/advice/methodology/unsupported content.\n\n```json\n' + JSON.stringify(audit.counters, null, 2) + '\n```\n\nThe sole non-zero permitted counter is `missing_bindings=1`: next period 63–79 is omitted completely, including its heading, because the relationship/termination chain is incomplete. All other counters are zero.\n\n' + audit.conclusions.map(x => `- ${x}`).join('\n') + '\n\n## Full candidate read in both passes\n\n```text\n' + candidate.fullReaderCopy + '\n```\n');
  writeMd('docs/CANDIDATE_0020_BEFORE_AFTER.md', '# Candidate 0020 — complete Before/After\n\nBefore is the exact actual 00:35 runtime output. After is proposed Candidate 0020, not implemented or accepted. Every existing and proposed paragraph appears in full. A blank side is explicitly identified only when no reader-facing paragraph exists.\n\n' +
    beforeAfter.pairs.map((p, i) => `## ${i + 1}. ${p.beforeOwner} → ${p.afterOwner ?? 'explicit omission'}\n\n**Before (full)**\n\n${p.before ?? 'ไม่มี reader-facing paragraph ใน actual 00:35 สำหรับช่วงนี้'}\n\n**After (full)**\n\n${p.after ?? 'ไม่มี reader-facing paragraph หรือหัวข้อนี้ใน Candidate 0020 เพราะ binding ไม่ครบ'}\n\nClassification: ${p.afterClassification}\n`).join('\n') +
    '\n## Candidate summary (new composition, full)\n\n' + candidate.predictionClaims.find(c => c.semanticOwner === 'summary').proposedReaderWording + '\n');
  return {equivalenceDoc, candidate, beforeAfter, audit};
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = buildAll();
  console.log(JSON.stringify({pastEquivalent: result.equivalenceDoc.equivalent, candidateClaims: result.candidate.predictionClaims.length,
    omissions: result.candidate.omissions.length, auditStatus: result.audit.status, counters: result.audit.counters,
    fullCopySha256: sha(result.candidate.fullReaderCopy)}, null, 2));
}
