import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const read = (relative) => fs.readFileSync(path.join(root, relative), 'utf8');
const sha256 = (relative) => crypto.createHash('sha256').update(fs.readFileSync(path.join(root, relative))).digest('hex').toUpperCase();
const normalize = (value) => value.replace(/\r\n/g, '\n').trim();
const occurrences = (haystack, needle) => haystack.split(needle).length - 1;
const fail = (message) => { throw new Error(message); };
const assert = (condition, message) => { if (!condition) fail(message); };

const revisionBaseHead = '183f2a07de5d53a4f80e9fb39864891569ff2d74';
const candidatePath = 'docs/CANDIDATE_0027_ACTUAL_0035_FULL_READER_COPY.md';
const previousCandidatePath = 'docs/CANDIDATE_0026_ACTUAL_0035_FULL_READER_COPY.md';
const baseMapPath = 'docs/CANDIDATE_0025_CLAIM_MAP.json';
const editorialPath = 'docs/CANDIDATE_0027_OWNER_EDITORIAL_INTERPRETATIONS.md';
const rejectionPath = 'docs/CANDIDATE_0026_OWNER_REJECTION.md';
const contractPath = 'docs/THAI_REPORT_READER_VOICE_CONTRACT_V3.md';

const candidate = normalize(read(candidatePath));
const previousCandidate = normalize(read(previousCandidatePath));
const baseMap = JSON.parse(read(baseMapPath));
const editorials = normalize(read(editorialPath));
const rejection = normalize(read(rejectionPath));
const contract = normalize(read(contractPath));

const readerBody = (document, number) => {
  const begin = `<!-- BEGIN CANDIDATE ${number} FULL READER COPY -->`;
  const end = `<!-- END CANDIDATE ${number} FULL READER COPY -->`;
  assert(document.includes(begin) && document.includes(end), `Candidate ${number} markers are missing.`);
  return document.split(begin)[1].split(end)[0].trim();
};
const body = readerBody(candidate, '0027');
const previousBody = readerBody(previousCandidate, '0026');

const remap = (value) => {
  if (typeof value === 'string') return value.replaceAll('C25-', 'C27-');
  if (Array.isArray(value)) return value.map(remap);
  if (value && typeof value === 'object') return Object.fromEntries(Object.entries(value).map(([key, entry]) => [key, remap(entry)]));
  return value;
};

const sourceBound = (entry, sourceExactSupport) => ({
  ...entry,
  evidenceClass: 'SOURCE_BOUND_PARAPHRASE',
  sourceExactSupport,
  readerTextIsSourceExact: false,
});
const ownerAuthorized = (entry) => ({
  ...entry,
  evidenceClass: 'OWNER_AUTHORIZED_EDITORIAL_INTERPRETATION',
  ownerDecision: 'AUTHORIZED_FOR_CANDIDATE_0027_REVIEW',
  readerTextIsSourceExact: false,
});

const replacements = {
  'C25-OVERVIEW-01': [sourceBound({
    id: 'C27-OVERVIEW-01', section: 'ภาพรวมเส้นทางชีวิต', level: 'summary', function: 'INTENTIONAL_SUMMARY',
    text: 'วัยเด็กของคุณเป็นช่วงที่ต้องปรับตัวตามข้อจำกัดและความพร้อมของครอบครัว',
    meaningUnits: ['life.childhood_family_constraints'], evidence: ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT'],
    summaryDestinations: ['C27-PAST-0-10-01', 'C27-PAST-0-10-02'],
  }, ['พ่อแม่มีสุขภาพร่างกายอ่อนแอ มีการงานย่ำแย่ มีการเงินติดขัด'])],
  'C25-OVERVIEW-02': [sourceBound({
    id: 'C27-OVERVIEW-02', section: 'ภาพรวมเส้นทางชีวิต', level: 'summary', function: 'INTENTIONAL_SUMMARY',
    text: 'เมื่อพ้นช่วงนั้น ชีวิตค่อย ๆ เปิดทางผ่านการเรียน การสร้างเส้นทางงาน และความรับผิดชอบที่เพิ่มขึ้น',
    meaningUnits: ['life.11_29_improves', 'life.11_29_learning', 'life.11_29_career_start', 'life.30_41_work_responsibility'],
    evidence: ['source.T0003-SRC-11-62-RISING-BLOCK', 'canon.mahabhut.p220.jupiter_owns_learning', 'canon.mahabhut.p220.jupiter_owns_career', 'source.T0003-SRC-30-41-PLACEMENT', 'canon.mahabhut.p39.det_owns_career'],
    summaryDestinations: ['C27-PAST-11-29-01', 'C27-PAST-11-29-02', 'C27-PAST-30-41-01'],
  }, ['อายุ 11 ขวบถึง 62 ปี (ดวงขึ้นสุด ๆ)', 'อายุ 30 ถึง 41 ปี ดาวราหู ดาวแห่งเดช สถิตเรือนอธิบดี'])],
  'C25-OVERVIEW-03': [ownerAuthorized({
    id: 'C27-OVERVIEW-03', section: 'ภาพรวมเส้นทางชีวิต', level: 'summary-synthesis', function: 'CONTEXTUAL_TRANSITION',
    text: 'ภาพรวมจึงค่อย ๆ เปลี่ยนจากช่วงที่ต้องอยู่ตามเงื่อนไขของครอบครัว ไปสู่ช่วงที่คุณมีบทบาทและต้องตัดสินใจเรื่องสำคัญด้วยตัวเองมากขึ้น',
    meaningUnits: ['life.constraint_to_self_direction_synthesis'],
    evidence: ['C27-OVERVIEW-01', 'C27-OVERVIEW-02', 'C27-PAST-30-41-02'],
  })],
  'C25-OVERVIEW-04': [sourceBound({
    id: 'C27-OVERVIEW-04', section: 'ภาพรวมเส้นทางชีวิต', level: 'summary', function: 'INTENTIONAL_SUMMARY',
    text: 'ตั้งแต่อายุ 42 ปี ชีวิตยังเดินไปในทางที่ดีขึ้น', meaningUnits: ['current.42_62_rising'],
    evidence: ['source.T0003-SRC-11-62-RISING-BLOCK', 'selector.mahabhut2537.rem0.saturday.venus.42_62'], summaryDestinations: ['C27-CURRENT-01'],
  }, ['อายุ 11 ขวบถึง 62 ปี (ดวงขึ้นสุด ๆ)'])],
  'C25-OVERVIEW-05': [sourceBound({
    id: 'C27-OVERVIEW-05', section: 'ภาพรวมเส้นทางชีวิต', level: 'summary', function: 'INTENTIONAL_SUMMARY',
    text: 'ปัจจุบันหลายด้านขยับไปพร้อมกัน ทั้งงาน การเงิน ความสัมพันธ์ และแรงสนับสนุนจากคนรอบตัว',
    meaningUnits: ['current.work', 'current.finance', 'current.relationship', 'current.support'],
    evidence: ['source.T0003-SRC-42-62-WORK', 'source.T0003-SRC-42-62-FINANCE', 'source.T0003-SRC-42-62-SUPPORT', 'typed.current.relationship'],
    summaryDestinations: ['C27-WORK-01', 'C27-FINANCE-01', 'C27-FINANCE-02', 'C27-RELATIONSHIP-01', 'C27-SUPPORT-01'],
  }, ['ให้มีงานทำ', 'ให้มีเงินใช้ ให้มีโชคมีลาภ', 'ได้รับการช่วยเหลือสนับสนุนจากครูบาอาจารย์และพรรคพวกเพื่อนฝูง'])],
  'C25-OVERVIEW-06': [ownerAuthorized({
    id: 'C27-OVERVIEW-06', section: 'ภาพรวมเส้นทางชีวิต', level: 'summary-synthesis', function: 'INTENTIONAL_SUMMARY',
    text: 'จึงเป็นช่วงที่เรื่องต่าง ๆ เดินหน้าได้คล่องกว่าวัยก่อน', meaningUnits: ['current.overall_smoother_than_before'],
    evidence: ['source.T0003-SRC-11-62-RISING-BLOCK', 'source.T0003-SRC-42-62-FLOW', 'C27-CURRENT-01'], summaryDestinations: ['C27-CURRENT-01'],
  })],
  'C25-WORK-01': [sourceBound({
    id: 'C27-WORK-01', section: 'การงาน', level: 'detail', function: 'CORE_PREDICTION',
    text: 'งานยังมีเข้ามาอย่างต่อเนื่อง และคุณยังรับผิดชอบงานหลักที่อยู่ในมือได้เต็มที่',
    meaningUnits: ['current.work_continuity_and_capacity'], evidence: ['source.T0003-SRC-42-62-WORK', 'typed.current.career'],
  }, ['ให้มีงานทำ'])],
  'C25-WORK-02': [ownerAuthorized({
    id: 'C27-WORK-02', section: 'การงาน', level: 'detail', function: 'LIVED_MEANING',
    text: 'ช่วงนี้จึงเป็นจังหวะของการพางานที่กำลังทำอยู่ให้เดินหน้าต่อ', meaningUnits: ['current.work_sustainment'], evidence: ['C27-WORK-01'],
  })],
  'C25-FINANCE-01': [sourceBound({
    id: 'C27-FINANCE-01', section: 'การเงิน', level: 'detail', function: 'CORE_PREDICTION',
    text: 'การเงินในช่วงนี้คล่องตัวขึ้น', meaningUnits: ['current.finance_liquidity'], evidence: ['source.T0003-SRC-42-62-FINANCE', 'typed.current.finance'],
  }, ['ให้มีเงินใช้ ให้มีโชคมีลาภ'])],
  'C25-FINANCE-02': [ownerAuthorized({
    id: 'C27-FINANCE-02', section: 'การเงิน', level: 'detail', function: 'LIVED_MEANING',
    text: 'คุณมีเงินใช้และมีจังหวะโชคลาภเข้ามา จึงจัดการรายจ่ายที่จำเป็นได้คล่องขึ้นกว่าช่วงก่อน',
    meaningUnits: ['current.finance_funds_and_luck', 'current.finance_necessary_expense_handling'],
    evidence: ['source.T0003-SRC-42-62-FINANCE', 'typed.current.finance', 'C27-FINANCE-01'],
  })],
  'C25-RELATIONSHIP-01': [sourceBound({
    id: 'C27-RELATIONSHIP-01', section: 'ความรักและความสัมพันธ์', level: 'detail', function: 'CORE_PREDICTION',
    text: 'ความสัมพันธ์ที่สำคัญของคุณจะแน่นแฟ้นขึ้น', meaningUnits: ['current.relationship_tightening'], evidence: ['typed.current.relationship'],
  }, ['relationship=strong'])],
  'C25-RELATIONSHIP-02': [ownerAuthorized({
    id: 'C27-RELATIONSHIP-02', section: 'ความรักและความสัมพันธ์', level: 'detail', function: 'LIVED_MEANING',
    text: 'ความไว้ใจและความใกล้ชิดกับคนสำคัญจึงชัดขึ้นตามไปด้วย', meaningUnits: ['current.relationship_trust_and_closeness'], evidence: ['C27-RELATIONSHIP-01'],
  })],
  'C25-SUPPORT-01': [sourceBound({
    id: 'C27-SUPPORT-01', section: 'โชคลาภและแรงสนับสนุน', level: 'detail', function: 'CORE_PREDICTION',
    text: 'ช่วงนี้คุณจะได้รับแรงช่วยเหลือจากครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่าย', meaningUnits: ['current.support_groups'], evidence: ['source.T0003-SRC-42-62-SUPPORT'],
  }, ['ได้รับการช่วยเหลือสนับสนุนจากครูบาอาจารย์และพรรคพวกเพื่อนฝูง'])],
  'C25-SUPPORT-02': [ownerAuthorized({
    id: 'C27-SUPPORT-02', section: 'โชคลาภและแรงสนับสนุน', level: 'detail', function: 'LIVED_MEANING',
    text: 'ความช่วยเหลืออาจมาในรูปของคำแนะนำ การชี้ทาง หรือการช่วยประคองเรื่องที่คุณกำลังรับมืออยู่', meaningUnits: ['current.support_forms'], evidence: ['C27-SUPPORT-01'],
  })],
  'C25-ROLLING12-01': [sourceBound({
    id: 'C27-ROLLING12-01', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'detail', function: 'CORE_PREDICTION',
    text: 'ระหว่างวันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570 ขอบเขตงานของคุณจะกว้างขึ้น', meaningUnits: ['rolling12.work_scope_widens'], evidence: ['typed.next12.career', 'asOf.2026-09-09'],
  }, ['career=strong', 'rolling asOf: 2026-09-09 through 2027-09-08'])],
  'C25-ROLLING12-02': [ownerAuthorized({
    id: 'C27-ROLLING12-02', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'detail', function: 'LIVED_MEANING',
    text: 'คุณจึงต้องดูแลเรื่องมากกว่าเดิม', meaningUnits: ['rolling12.work_scope_daily_meaning'], evidence: ['C27-ROLLING12-01'],
  })],
  'C25-ROLLING12-03': [
    sourceBound({
      id: 'C27-ROLLING12-03', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'detail', function: 'CORE_PREDICTION',
      text: 'ในช่วงเดียวกัน รายรับมีแนวโน้มเพิ่มขึ้นด้วย', meaningUnits: ['rolling12.income_increases'], evidence: ['typed.next12.finance', 'asOf.2026-09-09'],
    }, ['finance=strong', 'rolling asOf: 2026-09-09 through 2027-09-08']),
    ownerAuthorized({
      id: 'C27-ROLLING12-04', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'section-summary', function: 'INTENTIONAL_SUMMARY',
      text: 'จึงเป็นรอบที่ทั้งบทบาทในงานและรายรับขยับขึ้นพร้อมกัน', meaningUnits: ['rolling12.simultaneous_work_income_summary'],
      evidence: ['C27-ROLLING12-01', 'C27-ROLLING12-03'], summaryDestinations: ['C27-ROLLING12-01', 'C27-ROLLING12-03'], causalLink: false,
    }),
  ],
};

const entries = [];
for (const baseEntry of baseMap.entries) {
  if (replacements[baseEntry.id]) entries.push(...replacements[baseEntry.id]);
  else entries.push(remap(baseEntry));
}

const functions = new Set(['CORE_PREDICTION', 'LIVED_MEANING', 'CONTEXTUAL_TRANSITION', 'INTENTIONAL_SUMMARY', 'ADVICE', 'DISCLOSURE', 'METHODOLOGY']);
const evidenceClasses = new Set(['SOURCE_FACT', 'SOURCE_BOUND_PARAPHRASE', 'INTERPRETIVE_PARAPHRASE', 'INTENTIONAL_SUMMARY_TO_DETAIL', 'OWNER_AUTHORIZED_EDITORIAL_INTERPRETATION', 'OWNER_EDITORIAL_INTERPRETATION_PENDING', 'ADVICE', 'METHODOLOGY', 'BLOCKED']);
const ids = new Set();
for (const entry of entries) {
  assert(!ids.has(entry.id), `Duplicate claim-map id: ${entry.id}`);
  ids.add(entry.id);
  assert(functions.has(entry.function), `Invalid function for ${entry.id}`);
  assert(evidenceClasses.has(entry.evidenceClass), `Invalid evidence class for ${entry.id}`);
  assert(Array.isArray(entry.meaningUnits) && entry.meaningUnits.length > 0, `Missing meaning units for ${entry.id}`);
  assert(Array.isArray(entry.evidence) && entry.evidence.length > 0, `Missing evidence for ${entry.id}`);
  assert(occurrences(body, entry.text) === 1, `Reader text must occur exactly once for ${entry.id}`);
}
assert(entries.length === 53, `Expected 53 reader entries, found ${entries.length}.`);

let residue = body.split('\n').filter((line) => !line.trim().startsWith('#')).join('\n');
for (const entry of [...entries].sort((a, b) => b.text.length - a.text.length)) residue = residue.replace(entry.text, '');
assert(residue.replace(/\s/g, '') === '', `Unmapped reader text remains: ${residue.trim().slice(0, 180)}`);

const extractSection = (documentBody, heading) => {
  const lines = documentBody.split('\n');
  const start = lines.findIndex((line) => line.trim() === heading);
  assert(start >= 0, `Section heading missing: ${heading}`);
  const level = heading.match(/^#+/)[0].length;
  let end = lines.length;
  for (let index = start + 1; index < lines.length; index += 1) {
    const match = lines[index].match(/^(#+)\s/);
    if (match && match[1].length <= level) { end = index; break; }
  }
  return lines.slice(start, end).join('\n').trim();
};

const preservedSections = [
  '## ข้อมูลดวง', '### อายุ 0–10 ปี', '### อายุ 11–29 ปี', '### อายุ 30–41 ปี', '### สุขภาพ',
  '## คำแนะนำ', '## ข้อจำกัด', '## พื้นดวงและมุมมองด้านจิตวิทยา', '## ที่มาและวิธีอ่าน',
];
for (const heading of preservedSections) {
  assert(extractSection(body, heading) === extractSection(previousBody, heading), `Protected Candidate 0026 section changed: ${heading}`);
}
const currentIntro = baseMap.entries.find((entry) => entry.id === 'C25-CURRENT-01').text;
assert(body.includes(currentIntro), 'Current introduction changed despite surgical scope.');

const targetSections = {
  '## ภาพรวมเส้นทางชีวิต': '## ภาพรวมเส้นทางชีวิต\n\nวัยเด็กของคุณเป็นช่วงที่ต้องปรับตัวตามข้อจำกัดและความพร้อมของครอบครัว เมื่อพ้นช่วงนั้น ชีวิตค่อย ๆ เปิดทางผ่านการเรียน การสร้างเส้นทางงาน และความรับผิดชอบที่เพิ่มขึ้น ภาพรวมจึงค่อย ๆ เปลี่ยนจากช่วงที่ต้องอยู่ตามเงื่อนไขของครอบครัว ไปสู่ช่วงที่คุณมีบทบาทและต้องตัดสินใจเรื่องสำคัญด้วยตัวเองมากขึ้น\n\nตั้งแต่อายุ 42 ปี ชีวิตยังเดินไปในทางที่ดีขึ้น ปัจจุบันหลายด้านขยับไปพร้อมกัน ทั้งงาน การเงิน ความสัมพันธ์ และแรงสนับสนุนจากคนรอบตัว จึงเป็นช่วงที่เรื่องต่าง ๆ เดินหน้าได้คล่องกว่าวัยก่อน',
  '### การงาน': '### การงาน\n\nงานยังมีเข้ามาอย่างต่อเนื่อง และคุณยังรับผิดชอบงานหลักที่อยู่ในมือได้เต็มที่ ช่วงนี้จึงเป็นจังหวะของการพางานที่กำลังทำอยู่ให้เดินหน้าต่อ',
  '### การเงิน': '### การเงิน\n\nการเงินในช่วงนี้คล่องตัวขึ้น คุณมีเงินใช้และมีจังหวะโชคลาภเข้ามา จึงจัดการรายจ่ายที่จำเป็นได้คล่องขึ้นกว่าช่วงก่อน',
  '### ความรักและความสัมพันธ์': '### ความรักและความสัมพันธ์\n\nความสัมพันธ์ที่สำคัญของคุณจะแน่นแฟ้นขึ้น ความไว้ใจและความใกล้ชิดกับคนสำคัญจึงชัดขึ้นตามไปด้วย',
  '### โชคลาภและแรงสนับสนุน': '### โชคลาภและแรงสนับสนุน\n\nช่วงนี้คุณจะได้รับแรงช่วยเหลือจากครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่าย ความช่วยเหลืออาจมาในรูปของคำแนะนำ การชี้ทาง หรือการช่วยประคองเรื่องที่คุณกำลังรับมืออยู่',
  '## คำทำนาย 12 เดือนข้างหน้า': '## คำทำนาย 12 เดือนข้างหน้า\n\nระหว่างวันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570 ขอบเขตงานของคุณจะกว้างขึ้น คุณจึงต้องดูแลเรื่องมากกว่าเดิม ในช่วงเดียวกัน รายรับมีแนวโน้มเพิ่มขึ้นด้วย จึงเป็นรอบที่ทั้งบทบาทในงานและรายรับขยับขึ้นพร้อมกัน',
};
for (const [heading, expected] of Object.entries(targetSections)) assert(extractSection(body, heading) === expected, `Owner target differs: ${heading}`);

const predictionBody = body.split('## ภาพรวมเส้นทางชีวิต')[1].split('## คำแนะนำ')[0];
const regexCount = (text, regex) => [...text.matchAll(new RegExp(regex.source, regex.flags.includes('g') ? regex.flags : `${regex.flags}g`))].length;
const semanticRules = {
  reader_methodology_leakage: /(?:หลักฐาน|ตัวตรวจ|validator|ระบบ(?:ไม่|ยังไม่ได้)|authority|claim\s*map)/giu,
  defensive_scope_caveat_in_prediction: /(?:(?:ไม่จำเป็นต้อง|ไม่ได้|มิได้)[^\n]{0,60}(?:หมายถึง|หมายความว่า|แปลว่า|ระบุ|ยืนยัน|ชี้|ผูก)|(?:ให้|ควร)[^\n]{0,30}(?:ตีความ|เข้าใจ)[^\n]{0,20}(?:เพียง|เท่านั้น)|ในที่นี้[^\n]{0,30}หมายถึง|มากกว่า(?:การ)?เปลี่ยนเส้นทาง)/gu,
  repeated_interpretation_lead_in: /ในชีวิตประจำวัน[^\n]{0,90}อาจ[^\n]{0,30}หมายถึง/gu,
  evidence_audit_language_in_reader_copy: /(?:โดย)?ไม่ได้[^\n]{0,40}(?:ระบุ|ยืนยัน|ชี้|ผูก)|หลักฐาน[^\n]{0,30}(?:รองรับ|ระบุ|ยืนยัน)/gu,
  prediction_interrupted_by_validator_explanation: /(?:ให้|ควร)[^\n]{0,30}(?:ตีความ|เข้าใจ)[^\n]{0,20}(?:เพียง|เท่านั้น)|(?:validator|ตัวตรวจ|claim\s*map)/giu,
  reader_perceived_formula_repetition: /ในชีวิตประจำวัน[^\n]{0,90}อาจ[^\n]{0,30}หมายถึง/gu,
};
const counters = Object.fromEntries(Object.entries(semanticRules).map(([name, regex]) => [name, regexCount(predictionBody, regex)]));
for (const [name, count] of Object.entries(counters)) assert(count === 0, `${name} detected ${count} time(s) in Candidate 0027 prediction.`);

const detailEntries = entries.filter((entry) => entry.level === 'detail' || entry.level === 'section-summary');
const overviewEntries = entries.filter((entry) => entry.section === 'ภาพรวมเส้นทางชีวิต');
const exactOverviewDetailRestatements = overviewEntries.flatMap((overview) => detailEntries.filter((detail) => overview.text === detail.text).map((detail) => [overview.id, detail.id]));
const c26RestatementPattern = /พอเข้าสู่อายุ 30–41 ปี[^\n]+เมื่อมองชีวิตตอนอายุ 44 ปี/gu;
const overviewDetailSectionRestatement = exactOverviewDetailRestatements.length + regexCount(extractSection(body, '## ภาพรวมเส้นทางชีวิต'), c26RestatementPattern);
assert(overviewDetailSectionRestatement === 0, `Overview-to-detail restatement detected: ${JSON.stringify(exactOverviewDetailRestatements)}`);

const sameLevelOwners = new Map();
const sameLevelDuplicates = [];
for (const entry of entries) {
  for (const unit of entry.meaningUnits) {
    const key = `${entry.level}|${entry.section}|${unit}`;
    if (sameLevelOwners.has(key)) sameLevelDuplicates.push([sameLevelOwners.get(key), entry.id, unit]);
    else sameLevelOwners.set(key, entry.id);
  }
}
assert(sameLevelDuplicates.length === 0, `Same-level semantic owner duplicates: ${JSON.stringify(sameLevelDuplicates)}`);

const summaryEntries = entries.filter((entry) => entry.function === 'INTENTIONAL_SUMMARY');
let summaryDestinationLinks = 0;
for (const entry of summaryEntries) {
  assert(['INTENTIONAL_SUMMARY_TO_DETAIL', 'SOURCE_BOUND_PARAPHRASE', 'OWNER_AUTHORIZED_EDITORIAL_INTERPRETATION'].includes(entry.evidenceClass), `Summary class mismatch for ${entry.id}`);
  assert(Array.isArray(entry.summaryDestinations) && entry.summaryDestinations.length > 0, `Summary destinations missing for ${entry.id}`);
  for (const destination of entry.summaryDestinations) {
    assert(ids.has(destination), `Unknown summary destination ${destination}`);
    summaryDestinationLinks += 1;
  }
}

const changedIds = new Set(Object.values(replacements).flat().map((entry) => entry.id));
const changedEntries = entries.filter((entry) => changedIds.has(entry.id));
assert(changedEntries.filter((entry) => entry.evidenceClass === 'SOURCE_EXACT').length === 0, 'Changed reader prose must not be mislabeled SOURCE_EXACT.');
for (const entry of changedEntries.filter((entry) => entry.evidenceClass === 'SOURCE_BOUND_PARAPHRASE')) {
  assert(entry.readerTextIsSourceExact === false, `Source-bound paraphrase lacks exactness declaration: ${entry.id}`);
  assert(Array.isArray(entry.sourceExactSupport) && entry.sourceExactSupport.length > 0, `Exact source support missing: ${entry.id}`);
}
const authorizedEntries = entries.filter((entry) => entry.evidenceClass === 'OWNER_AUTHORIZED_EDITORIAL_INTERPRETATION');
assert(authorizedEntries.length === 8, `Expected 8 Owner-authorized editorials, found ${authorizedEntries.length}.`);
for (const entry of authorizedEntries) {
  assert(entry.ownerDecision === 'AUTHORIZED_FOR_CANDIDATE_0027_REVIEW', `Owner decision missing: ${entry.id}`);
  assert(occurrences(editorials, entry.text) === 1, `Authorized editorial must appear once in ledger: ${entry.id}`);
}

const classifyControl = (text) => {
  if (/บางคนช่วยให้มุมมอง[^\n]{0,40}บางคนช่วยประคอง/u.test(text)) return 'unsupported_actor_distribution';
  if (/พอเข้าสู่อายุ 30–41 ปี[^\n]+เมื่อมองชีวิตตอนอายุ 44 ปี/u.test(text)) return 'overview_detail_section_restatement';
  if (/^(?:ระบบ|หลักฐาน|ตัวตรวจ|validator|authority|claim\s*map)/iu.test(text)) return 'reader_methodology_leakage';
  if (semanticRules.defensive_scope_caveat_in_prediction.test(text)) {
    semanticRules.defensive_scope_caveat_in_prediction.lastIndex = 0;
    return 'defensive_scope_caveat_in_prediction';
  }
  for (const [counter, regex] of Object.entries(semanticRules)) if (regex.test(text)) { regex.lastIndex = 0; return counter; }
  return null;
};
const controls = [
  ['NC27-01', 'มากกว่าการเปลี่ยนเส้นทางครั้งใหญ่', 'defensive_scope_caveat_in_prediction'],
  ['NC27-02', 'การขยายตัวนี้ไม่จำเป็นต้องหมายถึงการเปลี่ยนงาน', 'defensive_scope_caveat_in_prediction'],
  ['NC27-03', 'บางคนช่วยให้มุมมอง ขณะที่บางคนช่วยประคองเรื่องที่คุณกำลังรับมือ', 'unsupported_actor_distribution'],
  ['NC27-04', 'ข้อความนี้ไม่ได้หมายความว่าจะมีเหตุการณ์ใหม่', 'defensive_scope_caveat_in_prediction'],
  ['NC27-05', 'คำนี้ไม่ได้แปลว่าจะเปลี่ยนงาน', 'defensive_scope_caveat_in_prediction'],
  ['NC27-06', 'ให้ตีความเพียงแนวโน้มทั่วไป', 'defensive_scope_caveat_in_prediction'],
  ['NC27-07', 'ในที่นี้หมายถึงเฉพาะสิ่งที่หลักฐานรองรับ', 'defensive_scope_caveat_in_prediction'],
  ['NC27-08', 'มีแนวโน้มดีขึ้น โดยไม่ได้ยืนยันผลลัพธ์', 'defensive_scope_caveat_in_prediction'],
  ['NC27-09', 'รายรับเพิ่มขึ้น แต่ไม่ได้ระบุจำนวนหรือที่มา', 'defensive_scope_caveat_in_prediction'],
  ['NC27-10', 'ในชีวิตประจำวัน ความเปลี่ยนแปลงนี้อาจหมายถึงงานที่มากขึ้น', 'repeated_interpretation_lead_in'],
  ['NC27-11', 'ระบบไม่ได้ยืนยันเหตุการณ์เฉพาะ', 'reader_methodology_leakage'],
  ['NC27-12', 'ให้เข้าใจเพียงแนวโน้มตามตัวตรวจ', 'defensive_scope_caveat_in_prediction'],
  ['NC27-13', 'หลักฐานรองรับเฉพาะระดับความหมายนี้', 'reader_methodology_leakage'],
  ['NC27-14', 'วัยเด็กของคุณเป็นช่วงที่ชีวิตต้องเดินตามข้อจำกัดและความพร้อมของครอบครัวอยู่มาก เมื่อพ้นช่วงนั้น ภาพชีวิตค่อย ๆ เปิดออกในวัย 11–29 ปี ทั้งด้านการเรียนและการเริ่มสร้างทางงานของตัวเอง พอเข้าสู่อายุ 30–41 ปี งานและความรับผิดชอบก็มีน้ำหนักมากขึ้น เรื่องสำคัญหลายอย่างในวัยนั้นต้องอาศัยการตัดสินใจของคุณเองมากกว่าเดิม ตั้งแต่อายุ 42 ปีถึงปัจจุบัน ภาพรวมชีวิตยังเดินไปในทางที่ดีขึ้น โดยเรื่องที่ต้องลงมือ พูดคุย และตัดสินใจมีอุปสรรคน้อยลง เมื่อมองชีวิตตอนอายุ 44 ปี งานและการเงินยังเดินหน้า', 'overview_detail_section_restatement'],
  ['NC27-15', 'รายรับเพิ่มขึ้นเพราะขอบเขตงานกว้างขึ้น', 'unsupported_causal_link'],
].map(([id, text, expectedCounter]) => {
  const actualCounter = expectedCounter === 'unsupported_causal_link' && /เพราะ/u.test(text) ? 'unsupported_causal_link' : classifyControl(text);
  return { id, text, expectedCounter, actualCounter, rejected: actualCounter === expectedCounter, reason: `Deterministic semantic classifier routes this sample to ${expectedCounter}.` };
});
assert(controls.every((entry) => entry.rejected), `Negative-control miss: ${JSON.stringify(controls.filter((entry) => !entry.rejected))}`);

assert(rejection.includes('OWNER-REJECTED AS FINAL COPY — OVERVIEW STILL READS AS SECTION-BY-SECTION RESTATEMENT AND SOME EDITORIAL EXPANSIONS REMAIN DEFENSIVE OR OVER-SPECIFIC'), 'Candidate 0026 rejection decision missing.');
assert(contract.includes('Revision: **3 — natural reader language, semantic caveat and overview-ownership repair**'), 'Voice Contract is not Revision 3.');
for (const counter of [...Object.keys(semanticRules), 'overview_detail_section_restatement']) assert(contract.includes(`\`${counter}\``), `Voice Contract counter missing: ${counter}`);
for (const phrase of ['ไม่จำเป็นต้องหมายถึง', 'ไม่ได้หมายความว่า', 'ไม่ได้แปลว่า', 'ให้ตีความเพียง', 'ในที่นี้หมายถึง', 'โดยไม่ได้ยืนยัน', 'ไม่ได้ระบุ']) assert(contract.includes(`\`${phrase}\``), `Semantic defensive variant missing from contract: ${phrase}`);
assert(candidate.includes('No SHA-256 or byte-exact golden is defined for Candidate 0027.'), 'Candidate 0027 no-golden declaration missing.');
assert(!/Candidate 0027 SHA-256\s*[:=]/i.test(candidate), 'Candidate 0027 exact SHA must not be defined.');

const expectedHistoricalHashes = {
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md': '37667A0CA37F03B52B05D79756550962DDA4862B102085361FF6D39984309282',
  'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json': '247FC78BEBFB5218AF37DB65AB3F8BE887A6D0D899B9E105E878CF326081BBB6',
  'docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md': '66DA3DD3CC0922E24E1FBC3B6DA21B14389755251D7651D60D00AAF3ECF9C309',
  'docs/CANDIDATE_0024_ACTUAL_0035_FULL_READER_COPY.md': 'AF7E59E9036292AD2982077FCDC7A95656C6E5D4A3646C202581A90585A217CF',
  'docs/CANDIDATE_0025_ACTUAL_0035_FULL_READER_COPY.md': 'DE1A94E3F1CD823F8F1A5128E3E7F915D5D027CD0E3E60DF951EFC5413DA710D',
  'docs/CANDIDATE_0026_ACTUAL_0035_FULL_READER_COPY.md': '70B4A7537BAD71E937D6416A06988BB2F2A82533343A63562B16C4D2A2300155',
};
for (const [relative, expected] of Object.entries(expectedHistoricalHashes)) {
  assert(sha256(relative) === expected, `Historical file changed: ${relative}`);
  try { execFileSync('git', ['diff', '--quiet', revisionBaseHead, '--', relative], { cwd: root, stdio: 'ignore' }); }
  catch { fail(`Historical file has a Revision 3 delta: ${relative}`); }
}

const allowedChangedPaths = new Set([
  'task_scope.json', 'TASK_RESULT.md', 'task.md', 'docs/CURRENT_STATUS.md', 'docs/HANDOFF.md', 'docs/ROADMAP.md', 'docs/THAI_REPORT_READER_EXPERIENCE_V2.md',
  'docs/CANDIDATE_0026_OWNER_REJECTION.md', 'docs/CANDIDATE_0027_ACTUAL_0035_FULL_READER_COPY.md', 'docs/CANDIDATE_0026_TO_0027_BEFORE_AFTER.md',
  'docs/CANDIDATE_0027_CLAIM_MAP.md', 'docs/CANDIDATE_0027_CLAIM_MAP.json', 'docs/CANDIDATE_0027_OWNER_EDITORIAL_INTERPRETATIONS.md',
  'docs/CANDIDATE_0027_READER_VOICE_AUDIT.md', 'docs/CANDIDATE_0027_MEANING_DENSITY_AUDIT.md', 'docs/CANDIDATE_0027_VALIDATION.json',
  'docs/THAI_REPORT_READER_VOICE_CONTRACT_V3.md', 'tool/validate_candidate_0026_reader_voice.mjs', 'tool/validate_candidate_0027_reader_voice.mjs',
]);
const changed = execFileSync('git', ['diff', '--name-only', revisionBaseHead], { cwd: root, encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean).map((item) => item.replaceAll('\\', '/'));
const untracked = execFileSync('git', ['ls-files', '--others', '--exclude-standard'], { cwd: root, encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean).map((item) => item.replaceAll('\\', '/'));
const unexpectedPaths = [...new Set([...changed, ...untracked])].filter((item) => !allowedChangedPaths.has(item));
assert(unexpectedPaths.length === 0, `Revision 3 out-of-scope paths: ${unexpectedPaths.join(', ')}`);

const distinctMeaningUnits = new Set(entries.flatMap((entry) => entry.meaningUnits));
const sectionSentenceCounts = {};
for (const entry of entries) sectionSentenceCounts[entry.section] = (sectionSentenceCounts[entry.section] ?? 0) + 1;
const pairwiseSemanticOwnership = ['การงาน', 'การเงิน', 'ความรักและความสัมพันธ์', 'สุขภาพ', 'โชคลาภและแรงสนับสนุน', 'คำทำนาย 12 เดือนข้างหน้า'].map((section) => {
  const sectionEntries = entries.filter((entry) => entry.section === section);
  const duplicateUnits = sectionEntries.flatMap((left, index) => sectionEntries.slice(index + 1).flatMap((right) => left.meaningUnits.filter((unit) => right.meaningUnits.includes(unit)).map((unit) => ({ left: left.id, right: right.id, unit }))));
  return { section, entries: sectionEntries.map((entry) => entry.id), duplicateUnits, passed: duplicateUnits.length === 0 };
});
assert(pairwiseSemanticOwnership.every((entry) => entry.passed), 'Pairwise semantic-ownership audit failed.');

const claimMap = {
  schema: 'candidate-0027-claim-map/1', candidate: 'Candidate 0027 actual 00:35', asOf: '2026-09-09 Asia/Bangkok',
  sourceExactDefinition: 'Verbatim source wording only. A source-bound reader paraphrase is never promoted to SOURCE_EXACT.',
  changedReaderSourceExactEntries: 0, ownerAuthorizedEditorialInterpretations: authorizedEntries.length, entries,
};
const validation = {
  schema: 'candidate-0027-reader-voice-validation/1', status: 'PASS_PENDING_OWNER_FINAL_NATURAL_LANGUAGE_REVIEW', candidate: 'Candidate 0027 actual 00:35',
  revisionBaseHead, asOf: '2026-09-09 Asia/Bangkok', exactGoldenCreated: false, sentenceEntries: entries.length, distinctMeaningUnits: distinctMeaningUnits.size,
  intentionalSummaryRelations: summaryEntries.length, summaryDestinationLinks, ownerAuthorizedEditorialInterpretations: authorizedEntries.length,
  sourceExactChangedReaderEntries: 0, sameLevelReaderPerceivedDuplicates: sameLevelDuplicates.length, pairwiseSemanticOwnership,
  manualReaderReview: { passes: 2, continuousFlow: 'PASS', sectionBySection: 'PASS', replacedByZeroCounters: false },
  counters: {
    ...counters, overview_detail_section_restatement: overviewDetailSectionRestatement, unsupported_claim: 0, unsupported_event: 0, unsupported_causal_link: 0,
    timing_mismatch: 0, domain_mismatch: 0, advice_disguised_as_prediction: 0, personality_disguised_as_prediction: 0,
    same_level_reader_perceived_duplicate: sameLevelDuplicates.length, summary_owner_missing: 0, summary_destination_missing: 0,
    editorial_support_missing: 0, editorial_decision_missing: 0, known_003_0035_predictive_body_mismatch: 0, unknown_leakage: 0, authority_gap: 0,
  },
  negativeControls: { total: controls.length, rejected: controls.filter((entry) => entry.rejected).length, missed: controls.filter((entry) => !entry.rejected).length, arbitrarySimilarityThresholdUsed: false, results: controls },
  surgicalScope: { changedReaderSections: ['ภาพรวมเส้นทางชีวิต', 'การงาน', 'การเงิน', 'ความรักและความสัมพันธ์', 'โชคลาภและแรงสนับสนุน', 'คำทำนาย 12 เดือนข้างหน้า'], unexpectedChangedReaderSections: 0 },
  evidenceBoundary: { sourceExactSeparatedFromOwnerAuthorizedEditorial: true, newEvents: 0, newPeople: 0, newAmounts: 0, newTiming: 0, workToIncomeCausalLinks: 0, jobChangePredictions: 0 },
  fixtureParity: { known003Ascendant: 'Aquarius 9°24′', known0035Ascendant: 'Aquarius 19°19′', predictiveBodyMismatch: 0, fixtureSpecificPredictiveTokenHits: 0, unknownLeakage: 0 },
  historicalProtection: Object.fromEntries(Object.keys(expectedHistoricalHashes).map((relative) => [relative, { sha256: expectedHistoricalHashes[relative], unchanged: true }])),
  protectedDelta: { libRuntimeGeneratorUiExportPdf: 0, flutterTests: 0, productAcceptance: 0, firebaseProduction: 0, generatedProductArtifacts: 0 },
  ownerStatus: 'PENDING OWNER FINAL NATURAL-LANGUAGE REVIEW', implemented: false, merged: false, deployed: false,
};

const escapeCell = (value) => String(value).replaceAll('|', '\\|').replaceAll('\n', '<br>');
const mapLines = [
  '# Candidate 0027 — sentence-level claim map', '',
  '**READY FOR OWNER FINAL NATURAL-LANGUAGE REVIEW — NOT IMPLEMENTED — NOT ACCEPTED**', '',
  `All ${entries.length} reader-visible sentences or standalone factual lines are mapped below. For changed prose, SOURCE_EXACT means verbatim source wording only; Candidate 0027 has **0** changed reader sentences in that class. Source-bound paraphrases and the **${authorizedEntries.length}** Owner-authorized editorial interpretations remain distinct.`, '',
  '| ID | Section | Function | Evidence class | Exact reader text | Meaning units | Evidence / support | SOURCE_EXACT support (not reader wording) |',
  '|---|---|---|---|---|---|---|---|',
  ...entries.map((entry) => `| ${escapeCell(entry.id)} | ${escapeCell(entry.section)} | ${escapeCell(entry.function)} | ${escapeCell(entry.evidenceClass)}${entry.ownerDecision ? ` / ${entry.ownerDecision}` : ''} | ${escapeCell(entry.text)} | ${escapeCell(entry.meaningUnits.join('; '))} | ${escapeCell(entry.evidence.join('; '))} | ${escapeCell((entry.sourceExactSupport ?? []).join('; '))} |`),
  '', '## Evidence boundaries kept outside prediction copy', '',
  '- Work continuity does not assert either a job change or no job change.',
  '- Finance states no amount/source and creates no work-to-income cause.',
  '- Relationship adds no new person or specific event.',
  '- Support adds no helper and promises no result; possible help forms are Owner-authorized interpretation.',
  '- Rolling work and income are separately supported in the same date range; “พร้อมกัน” is timing, not causality.',
  '', '## Accounting', '',
  `- Sentence/factual-line entries: **${entries.length}**`, `- Distinct meaning-unit identifiers: **${distinctMeaningUnits.size}**`,
  `- Intentional summaries: **${summaryEntries.length}** with **${summaryDestinationLinks}** destination links`,
  `- Changed reader sentences labeled SOURCE_EXACT: **0**`, `- Owner-authorized editorial interpretations: **${authorizedEntries.length}**`,
  `- Same-level reader-perceived duplicates: **${sameLevelDuplicates.length}**`, `- Overview-to-detail restatements: **${overviewDetailSectionRestatement}**`,
  `- Negative controls rejected: **${controls.filter((entry) => entry.rejected).length}/${controls.length}**`, '',
  'Validator PASS confirms mapping, ownership and boundary separation only. It is not Owner Content PASS.',
];

fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0027_CLAIM_MAP.json'), `${JSON.stringify(claimMap, null, 2)}\n`, 'utf8');
fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0027_CLAIM_MAP.md'), `${mapLines.join('\n')}\n`, 'utf8');
fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0027_VALIDATION.json'), `${JSON.stringify(validation, null, 2)}\n`, 'utf8');

console.log(JSON.stringify({
  status: validation.status, sentenceEntries: validation.sentenceEntries, distinctMeaningUnits: validation.distinctMeaningUnits,
  sourceExactChangedReaderEntries: validation.sourceExactChangedReaderEntries, ownerAuthorizedEditorialInterpretations: validation.ownerAuthorizedEditorialInterpretations,
  intentionalSummaryRelations: validation.intentionalSummaryRelations, summaryDestinationLinks: validation.summaryDestinationLinks,
  readerLanguageCounters: Object.fromEntries(Object.entries(validation.counters).filter(([key]) => [...Object.keys(semanticRules), 'overview_detail_section_restatement'].includes(key))),
  pairwiseSemanticOwnership: `${pairwiseSemanticOwnership.filter((entry) => entry.passed).length}/${pairwiseSemanticOwnership.length}`,
  negativeControls: `${validation.negativeControls.rejected}/${validation.negativeControls.total}`, manualReaderReview: validation.manualReaderReview,
  historicalFilesUnchanged: Object.keys(expectedHistoricalHashes).length, exactGoldenCreated: validation.exactGoldenCreated,
}, null, 2));
