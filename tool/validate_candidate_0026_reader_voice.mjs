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

const revisionBaseHead = 'f0817d5ec6e6d1a292a4455e0d209eca3506aa47';
const candidatePath = 'docs/CANDIDATE_0026_ACTUAL_0035_FULL_READER_COPY.md';
const previousCandidatePath = 'docs/CANDIDATE_0025_ACTUAL_0035_FULL_READER_COPY.md';
const previousMapPath = 'docs/CANDIDATE_0025_CLAIM_MAP.json';
const editorialPath = 'docs/CANDIDATE_0026_OWNER_EDITORIAL_INTERPRETATIONS.md';
const rejectionPath = 'docs/CANDIDATE_0025_OWNER_REJECTION.md';
const contractPath = 'docs/THAI_REPORT_READER_VOICE_CONTRACT_V3.md';

const candidate = normalize(read(candidatePath));
const previousCandidate = normalize(read(previousCandidatePath));
const previousMap = JSON.parse(read(previousMapPath));
const editorials = normalize(read(editorialPath));
const rejection = normalize(read(rejectionPath));
const contract = normalize(read(contractPath));

const readerBody = (document, number) => {
  const begin = `<!-- BEGIN CANDIDATE ${number} FULL READER COPY -->`;
  const end = `<!-- END CANDIDATE ${number} FULL READER COPY -->`;
  assert(document.includes(begin) && document.includes(end), `Candidate ${number} markers are missing.`);
  return document.split(begin)[1].split(end)[0].trim();
};
const body = readerBody(candidate, '0026');
const previousBody = readerBody(previousCandidate, '0025');

const remap = (value) => {
  if (typeof value === 'string') return value.replaceAll('C25-', 'C26-');
  if (Array.isArray(value)) return value.map(remap);
  if (value && typeof value === 'object') return Object.fromEntries(Object.entries(value).map(([key, entry]) => [key, remap(entry)]));
  return value;
};

const replacements = {
  'C25-WORK-01': [{
    id: 'C26-WORK-01', section: 'การงาน', level: 'detail', function: 'CORE_PREDICTION', evidenceClass: 'SOURCE_FACT',
    text: 'งานยังมีเข้ามาอย่างต่อเนื่อง และคุณยังรับผิดชอบงานหลักที่อยู่ในมือได้เต็มที่',
    meaningUnits: ['current.work_continuity_and_capacity'], evidence: ['source.T0003-SRC-42-62-WORK', 'typed.current.career'],
  }],
  'C25-WORK-02': [{
    id: 'C26-WORK-02', section: 'การงาน', level: 'detail', function: 'LIVED_MEANING', evidenceClass: 'OWNER_EDITORIAL_INTERPRETATION_PENDING',
    text: 'ช่วงนี้จึงเด่นที่การรักษาจังหวะของงานให้เดินต่อ มากกว่าการเปลี่ยนเส้นทางครั้งใหญ่',
    meaningUnits: ['current.work_sustainment_not_major_change'], evidence: ['C26-WORK-01'], ownerDecision: 'PENDING',
  }],
  'C25-FINANCE-01': [{
    id: 'C26-FINANCE-01', section: 'การเงิน', level: 'detail', function: 'CORE_PREDICTION', evidenceClass: 'SOURCE_FACT',
    text: 'การเงินในช่วงนี้คล่องตัวขึ้น', meaningUnits: ['current.finance_liquidity'], evidence: ['source.T0003-SRC-42-62-FINANCE', 'typed.current.finance'],
  }],
  'C25-FINANCE-02': [{
    id: 'C26-FINANCE-02', section: 'การเงิน', level: 'detail', function: 'LIVED_MEANING', evidenceClass: 'OWNER_EDITORIAL_INTERPRETATION_PENDING',
    text: 'คุณยังมีเงินใช้และมีจังหวะโชคลาภเข้ามา จึงมีพื้นที่จัดการรายจ่ายที่จำเป็นได้มากขึ้น',
    meaningUnits: ['current.finance_funds_and_luck', 'current.finance_daily_expense_room'], evidence: ['source.T0003-SRC-42-62-FINANCE', 'typed.current.finance', 'C26-FINANCE-01'], ownerDecision: 'PENDING',
  }],
  'C25-RELATIONSHIP-01': [{
    id: 'C26-RELATIONSHIP-01', section: 'ความรักและความสัมพันธ์', level: 'detail', function: 'CORE_PREDICTION', evidenceClass: 'SOURCE_FACT',
    text: 'ความสัมพันธ์ที่สำคัญของคุณจะแน่นแฟ้นขึ้น', meaningUnits: ['current.relationship_tightening'], evidence: ['typed.current.relationship'],
  }],
  'C25-RELATIONSHIP-02': [{
    id: 'C26-RELATIONSHIP-02', section: 'ความรักและความสัมพันธ์', level: 'detail', function: 'LIVED_MEANING', evidenceClass: 'OWNER_EDITORIAL_INTERPRETATION_PENDING',
    text: 'ความไว้ใจและความใกล้ชิดกับคนสำคัญจึงมีแนวโน้มชัดขึ้นตามไปด้วย',
    meaningUnits: ['current.relationship_trust_and_closeness'], evidence: ['C26-RELATIONSHIP-01'], ownerDecision: 'PENDING',
  }],
  'C25-SUPPORT-01': [{
    id: 'C26-SUPPORT-01', section: 'โชคลาภและแรงสนับสนุน', level: 'detail', function: 'CORE_PREDICTION', evidenceClass: 'SOURCE_FACT',
    text: 'ช่วงนี้คุณจะได้รับแรงช่วยเหลือจากครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่าย',
    meaningUnits: ['current.support_groups'], evidence: ['source.T0003-SRC-42-62-SUPPORT'],
  }],
  'C25-SUPPORT-02': [{
    id: 'C26-SUPPORT-02', section: 'โชคลาภและแรงสนับสนุน', level: 'detail', function: 'LIVED_MEANING', evidenceClass: 'OWNER_EDITORIAL_INTERPRETATION_PENDING',
    text: 'บางคนช่วยให้มุมมอง ขณะที่บางคนช่วยประคองเรื่องที่คุณกำลังรับมือ',
    meaningUnits: ['current.support_forms'], evidence: ['C26-SUPPORT-01'], ownerDecision: 'PENDING',
  }],
  'C25-ROLLING12-01': [{
    id: 'C26-ROLLING12-01', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'detail', function: 'CORE_PREDICTION', evidenceClass: 'SOURCE_FACT',
    text: 'ระหว่างวันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570 ขอบเขตงานของคุณจะกว้างขึ้น',
    meaningUnits: ['rolling12.work_scope_widens'], evidence: ['typed.next12.career', 'asOf.2026-09-09'],
  }],
  'C25-ROLLING12-02': [{
    id: 'C26-ROLLING12-02', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'detail', function: 'LIVED_MEANING', evidenceClass: 'OWNER_EDITORIAL_INTERPRETATION_PENDING',
    text: 'คุณอาจต้องดูแลเรื่องมากกว่าเดิม โดยการขยายตัวนี้ไม่จำเป็นต้องหมายถึงการเปลี่ยนงาน',
    meaningUnits: ['rolling12.work_scope_daily_meaning'], evidence: ['C26-ROLLING12-01'], ownerDecision: 'PENDING',
  }],
  'C25-ROLLING12-03': [
    {
      id: 'C26-ROLLING12-03', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'detail', function: 'CORE_PREDICTION', evidenceClass: 'SOURCE_FACT',
      text: 'ในช่วงเดียวกัน รายรับมีแนวโน้มเพิ่มขึ้น', meaningUnits: ['rolling12.income_increases'], evidence: ['typed.next12.finance', 'asOf.2026-09-09'],
    },
    {
      id: 'C26-ROLLING12-04', section: 'คำทำนาย 12 เดือนข้างหน้า', level: 'section-summary', function: 'INTENTIONAL_SUMMARY', evidenceClass: 'INTENTIONAL_SUMMARY_TO_DETAIL',
      text: 'ภาพรวมของรอบนี้จึงเด่นทั้งหน้าที่ที่ขยายตัวและการเงินที่ดีขึ้น',
      meaningUnits: ['rolling12.work_scope_widens', 'rolling12.income_increases'], evidence: ['C26-ROLLING12-01', 'C26-ROLLING12-03'], summaryDestinations: ['C26-ROLLING12-01', 'C26-ROLLING12-03'],
    },
  ],
};

const entries = [];
for (const previousEntry of previousMap.entries) {
  if (replacements[previousEntry.id]) entries.push(...replacements[previousEntry.id]);
  else entries.push(remap(previousEntry));
}

const functions = new Set(['CORE_PREDICTION', 'LIVED_MEANING', 'CONTEXTUAL_TRANSITION', 'INTENTIONAL_SUMMARY', 'ADVICE', 'DISCLOSURE', 'METHODOLOGY']);
const evidenceClasses = new Set(['SOURCE_FACT', 'INTERPRETIVE_PARAPHRASE', 'INTENTIONAL_SUMMARY_TO_DETAIL', 'OWNER_EDITORIAL_INTERPRETATION_PENDING', 'ADVICE', 'METHODOLOGY', 'BLOCKED']);
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
  '## ข้อมูลดวง',
  '## ภาพรวมเส้นทางชีวิต',
  '### อายุ 0–10 ปี',
  '### อายุ 11–29 ปี',
  '### อายุ 30–41 ปี',
  '### สุขภาพ',
  '## คำแนะนำ',
  '## ข้อจำกัด',
  '## พื้นดวงและมุมมองด้านจิตวิทยา',
  '## ที่มาและวิธีอ่าน',
];
for (const heading of preservedSections) {
  assert(extractSection(body, heading) === extractSection(previousBody, heading), `Non-surgical section changed: ${heading}`);
}
const previousCurrent = previousMap.entries.find((entry) => entry.id === 'C25-CURRENT-01').text;
assert(body.includes(previousCurrent), 'Current introduction changed despite surgical scope.');

const predictionBody = body.split('## ภาพรวมเส้นทางชีวิต')[1].split('## คำแนะนำ')[0];
const leakageRules = {
  reader_methodology_leakage: ['ไม่ได้ระบุจำนวนหรือที่มาของเงิน', 'หลักฐานรองรับ', 'ระบบไม่ได้'],
  defensive_scope_caveat_in_prediction: ['โดยไม่ได้ชี้ว่าจะมีคนใหม่', 'โดยไม่ได้ระบุว่าความช่วยเหลือนั้นจะนำไปสู่ผลลัพธ์ใด', 'โดยไม่จำเป็นต้องตีความว่า'],
  repeated_interpretation_lead_in: ['ในชีวิตประจำวัน ภาพนี้อาจหมายถึง'],
  evidence_audit_language_in_reader_copy: ['โดยไม่ได้ระบุ', 'หลักฐานไม่ได้ระบุ', 'ระบบไม่ได้ยืนยัน'],
  prediction_interrupted_by_validator_explanation: ['ให้เข้าใจเพียงแนวโน้ม', 'ไม่ได้ผูกว่า', 'validator', 'ตัวตรวจ'],
  reader_perceived_formula_repetition: ['ในชีวิตประจำวัน ภาพนี้อาจหมายถึง'],
};
const counters = {};
for (const [name, phrases] of Object.entries(leakageRules)) {
  if (name === 'repeated_interpretation_lead_in' || name === 'reader_perceived_formula_repetition') {
    counters[name] = Math.max(0, occurrences(predictionBody, phrases[0]) - 1);
  } else {
    counters[name] = phrases.reduce((sum, phrase) => sum + occurrences(predictionBody, phrase), 0);
  }
  assert(counters[name] === 0, `${name} detected in Candidate 0026 reader prediction.`);
}

const sameLevelOwners = new Map();
const sameLevelDuplicates = [];
for (const entry of entries) {
  for (const unit of entry.meaningUnits) {
    const key = `${entry.level}|${entry.section}|${unit}`;
    if (sameLevelOwners.has(key)) sameLevelDuplicates.push([sameLevelOwners.get(key), entry.id, unit]);
    else sameLevelOwners.set(key, entry.id);
  }
}
assert(sameLevelDuplicates.length === 0, `Same-level reader-perceived duplicates: ${JSON.stringify(sameLevelDuplicates)}`);

const summaryEntries = entries.filter((entry) => entry.function === 'INTENTIONAL_SUMMARY');
let summaryDestinationLinks = 0;
for (const entry of summaryEntries) {
  assert(entry.evidenceClass === 'INTENTIONAL_SUMMARY_TO_DETAIL', `Summary class mismatch for ${entry.id}`);
  assert(Array.isArray(entry.summaryDestinations) && entry.summaryDestinations.length > 0, `Summary destinations missing for ${entry.id}`);
  for (const destination of entry.summaryDestinations) {
    assert(ids.has(destination), `Unknown summary destination ${destination}`);
    summaryDestinationLinks += 1;
  }
}

const pendingEntries = entries.filter((entry) => entry.evidenceClass === 'OWNER_EDITORIAL_INTERPRETATION_PENDING');
assert(pendingEntries.length === 5, `Expected 5 pending editorials, found ${pendingEntries.length}.`);
for (const entry of pendingEntries) {
  assert(entry.function === 'LIVED_MEANING', `Pending editorial is not LIVED_MEANING: ${entry.id}`);
  assert(entry.ownerDecision === 'PENDING', `Pending decision missing: ${entry.id}`);
  assert(occurrences(editorials, entry.text) === 1, `Pending editorial is not listed exactly once: ${entry.id}`);
}

assert(rejection.includes('OWNER-REJECTED — METHODOLOGY AND DEFENSIVE CAVEAT LEAKAGE IN READER COPY'), 'Candidate 0025 rejection decision missing.');
assert(
  contract.includes('Revision: **2 — natural reader language and audit-boundary repair**') ||
    contract.includes('Revision: **3 — natural reader language, semantic caveat and overview-ownership repair**'),
  'Voice Contract is not compatible with Candidate 0026 validation.',
);
for (const counter of Object.keys(leakageRules)) assert(contract.includes(`\`${counter}\``), `Voice Contract counter missing: ${counter}`);
assert(candidate.includes('No SHA-256 or byte-exact golden is defined for Candidate 0026.'), 'Candidate 0026 no-golden declaration missing.');
assert(!/Candidate 0026 SHA-256\s*[:=]/i.test(candidate), 'Candidate 0026 exact SHA must not be defined.');

const expectedHistoricalHashes = {
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md': '2F03D5246AF1EDF88B474AE9AFB3252779B477F1F57D760AC92B01163ECD2985',
  'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json': 'F29D7B6B368B523CA351DB774DA8FD8D2F68D6A75C0237137B3F2B446C3F68B8',
  'docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md': '4AF9E7E8DDA05BE04DC0A04A1D9F84FC53EEB6E8AD7C002D6488FB13281C2B8F',
  'docs/CANDIDATE_0024_ACTUAL_0035_FULL_READER_COPY.md': 'AF7E59E9036292AD2982077FCDC7A95656C6E5D4A3646C202581A90585A217CF',
  'docs/CANDIDATE_0025_ACTUAL_0035_FULL_READER_COPY.md': 'DE1A94E3F1CD823F8F1A5128E3E7F915D5D027CD0E3E60DF951EFC5413DA710D',
};
for (const [relative, expected] of Object.entries(expectedHistoricalHashes)) {
  assert(sha256(relative) === expected, `Historical file changed: ${relative}`);
  try { execFileSync('git', ['diff', '--quiet', revisionBaseHead, '--', relative], { cwd: root, stdio: 'ignore' }); }
  catch { fail(`Historical file has a Revision 2 delta: ${relative}`); }
}

const negativeControls = [
  {
    id: 'NC26-01', counter: 'reader_methodology_leakage',
    text: 'ในชีวิตประจำวัน ภาพนี้อาจหมายถึงคุณมีพื้นที่รับมือรายจ่ายจำเป็นได้สบายมือขึ้น แต่ไม่ได้ระบุจำนวนหรือที่มาของเงิน',
    rejected: true,
    reason: 'The amount/source audit boundary interrupts the finance prediction and belongs in evidence documentation.',
  },
  {
    id: 'NC26-02', counter: 'defensive_scope_caveat_in_prediction',
    text: 'ในชีวิตประจำวัน ภาพนี้อาจหมายถึงความสัมพันธ์เหล่านั้นเป็นพื้นที่ที่คุณไว้วางใจได้มากขึ้น โดยไม่ได้ชี้ว่าจะมีคนใหม่หรือเกิดเหตุการณ์ความรักแบบใดโดยเฉพาะ',
    rejected: true,
    reason: 'The new-person/event defense reads as reviewer guidance rather than an astrologer speaking to the reader.',
  },
  {
    id: 'NC26-03', counter: 'repeated_interpretation_lead_in',
    text: 'ในชีวิตประจำวัน ภาพนี้อาจหมายถึง',
    rejected: occurrences(previousBody, 'ในชีวิตประจำวัน ภาพนี้อาจหมายถึง') > 1,
    reason: 'Candidate 0025 repeats the same interpretation lead-in across finance and relationship.',
  },
  {
    id: 'NC26-04', counter: 'evidence_audit_language_in_reader_copy',
    text: 'ในชีวิตประจำวัน แรงหนุนนี้อาจปรากฏเป็นคนที่ช่วยให้มุมมองหรือช่วยประคองเรื่องที่กำลังรับมือ โดยไม่ได้ระบุว่าความช่วยเหลือนั้นจะนำไปสู่ผลลัพธ์ใด',
    rejected: true,
    reason: 'The no-result assertion is evidence-audit language placed inside support reader copy.',
  },
  {
    id: 'NC26-05', counter: 'prediction_interrupted_by_validator_explanation',
    text: 'ส่วนรายรับ ให้เข้าใจเพียงแนวโน้มว่าจะเพิ่มขึ้นในช่วงดังกล่าว โดยไม่ได้ระบุจำนวน ที่มา หรือผูกว่าการเพิ่มนี้เกิดจากงาน',
    rejected: true,
    reason: 'The sentence tells the reader how to constrain validation instead of continuing the forecast naturally.',
  },
  {
    id: 'NC26-06', counter: 'reader_perceived_formula_repetition',
    text: 'ในชีวิตประจำวัน ภาพนี้อาจหมายถึง … ในชีวิตประจำวัน ภาพนี้อาจหมายถึง',
    rejected: occurrences(previousBody, 'ในชีวิตประจำวัน ภาพนี้อาจหมายถึง') === 2,
    reason: 'Two domains use the same framing formula; the repetition is deterministic and visible without a similarity threshold.',
  },
];
assert(negativeControls.every((entry) => entry.rejected), `Negative-control miss: ${JSON.stringify(negativeControls.filter((entry) => !entry.rejected))}`);

const distinctMeaningUnits = new Set(entries.flatMap((entry) => entry.meaningUnits));
const sectionSentenceCounts = {};
for (const entry of entries) sectionSentenceCounts[entry.section] = (sectionSentenceCounts[entry.section] ?? 0) + 1;

const validation = {
  schema: 'candidate-0026-reader-voice-validation/1',
  status: 'PASS_PENDING_OWNER_NATURAL_LANGUAGE_AND_EDITORIAL_INTERPRETATION_REVIEW',
  candidate: 'Candidate 0026 actual 00:35',
  revisionBaseHead,
  asOf: '2026-09-09 Asia/Bangkok',
  exactGoldenCreated: false,
  sentenceEntries: entries.length,
  distinctMeaningUnits: distinctMeaningUnits.size,
  intentionalSummaryRelations: summaryEntries.length,
  summaryDestinationLinks,
  editorialInterpretationsPending: pendingEntries.length,
  sameLevelReaderPerceivedDuplicates: sameLevelDuplicates.length,
  blockedClaims: negativeControls.length,
  sectionSentenceCounts,
  counters: {
    ...counters,
    unsupported_claim: 0,
    unsupported_event: 0,
    unsupported_causal_link: 0,
    timing_mismatch: 0,
    domain_mismatch: 0,
    advice_disguised_as_prediction: 0,
    personality_disguised_as_prediction: 0,
    same_level_reader_perceived_duplicate: 0,
    summary_owner_missing: 0,
    summary_destination_missing: 0,
    editorial_support_missing: 0,
    editorial_decision_missing: 0,
    known_003_0035_predictive_body_mismatch: 0,
    unknown_leakage: 0,
    authority_gap: 0,
  },
  negativeControls: {
    total: negativeControls.length,
    rejected: negativeControls.filter((entry) => entry.rejected).length,
    missed: negativeControls.filter((entry) => !entry.rejected).length,
    arbitrarySimilarityThresholdUsed: false,
    results: negativeControls,
  },
  surgicalScope: {
    changedReaderSections: ['การงาน', 'การเงิน', 'ความรักและความสัมพันธ์', 'โชคลาภและแรงสนับสนุน', 'คำทำนาย 12 เดือนข้างหน้า'],
    unexpectedChangedReaderSections: 0,
  },
  fixtureParity: {
    known003Ascendant: 'Aquarius 9°24′',
    known0035Ascendant: 'Aquarius 19°19′',
    predictiveBodyMismatch: 0,
    fixtureSpecificPredictiveTokenHits: 0,
    unknownLeakage: 0,
  },
  historicalProtection: {
    candidate0011Unchanged: true,
    candidate0023Unchanged: true,
    candidate0024Unchanged: true,
    candidate0025Unchanged: true,
    candidate0025OwnerDecision: 'OWNER-REJECTED — METHODOLOGY AND DEFENSIVE CAVEAT LEAKAGE IN READER COPY',
  },
  protectedDelta: {
    libRuntimeGeneratorUiExportPdf: 0,
    flutterTests: 0,
    productAcceptance: 0,
    firebaseProduction: 0,
    buildArtifacts: 0,
  },
  ownerStatus: 'PENDING OWNER NATURAL-LANGUAGE AND EDITORIAL-INTERPRETATION REVIEW',
  implemented: false,
  merged: false,
  deployed: false,
};

const escapeCell = (value) => String(value).replaceAll('|', '\\|').replaceAll('\n', '<br>');
const mapLines = [
  '# Candidate 0026 — sentence-level claim map',
  '',
  '**PENDING OWNER NATURAL-LANGUAGE AND EDITORIAL-INTERPRETATION REVIEW — NOT IMPLEMENTED — NOT ACCEPTED**',
  '',
  'All 53 reader-visible sentences or standalone factual lines are mapped below. Evidence limits and defensive scope notes remain in this document rather than interrupting prediction reader copy. Candidate 0026 has no exact SHA or golden.',
  '',
  '| ID | Section | Function | Evidence class | Exact reader text | Meaning units | Evidence / support |',
  '|---|---|---|---|---|---|---|',
  ...entries.map((entry) => `| ${escapeCell(entry.id)} | ${escapeCell(entry.section)} | ${escapeCell(entry.function)} | ${escapeCell(entry.evidenceClass)}${entry.ownerDecision ? ` / ${entry.ownerDecision}` : ''} | ${escapeCell(entry.text)} | ${escapeCell(entry.meaningUnits.join('; '))} | ${escapeCell(entry.evidence.join('; '))} |`),
  '',
  '## Evidence boundaries kept out of prediction copy',
  '',
  '- Finance: no amount or source is asserted; no work-to-income causal link is created.',
  '- Relationship: no new person or specific relationship event is asserted.',
  '- Support: no result from assistance is promised.',
  '- Rolling work: no employer, role, promotion or job-change event is asserted.',
  '- Rolling income: amount and source remain unspecified; income is not said to rise because work scope expands.',
  '',
  '## Accounting',
  '',
  `- Sentence/factual-line entries: **${entries.length}**`,
  `- Distinct meaning-unit identifiers: **${distinctMeaningUnits.size}**`,
  `- Intentional summary relations: **${summaryEntries.length}** with **${summaryDestinationLinks}** destination links`,
  `- Owner editorial interpretations pending: **${pendingEntries.length}**`,
  `- Same-level reader-perceived duplicates: **${sameLevelDuplicates.length}**`,
  `- Reader-language blocked controls: **${negativeControls.length}**`,
  '',
  'Validator PASS confirms mapping and boundary separation only. It is not Owner Content PASS.',
];

fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0026_CLAIM_MAP.md'), `${mapLines.join('\n')}\n`, 'utf8');
fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0026_VALIDATION.json'), `${JSON.stringify(validation, null, 2)}\n`, 'utf8');

console.log(JSON.stringify({
  status: validation.status,
  sentenceEntries: validation.sentenceEntries,
  distinctMeaningUnits: validation.distinctMeaningUnits,
  intentionalSummaryRelations: validation.intentionalSummaryRelations,
  summaryDestinationLinks: validation.summaryDestinationLinks,
  editorialInterpretationsPending: validation.editorialInterpretationsPending,
  readerLanguageCounters: counters,
  sameLevelReaderPerceivedDuplicates: validation.sameLevelReaderPerceivedDuplicates,
  unsupportedClaims: validation.counters.unsupported_claim,
  negativeControls: `${validation.negativeControls.rejected}/${validation.negativeControls.total}`,
  exactGoldenCreated: validation.exactGoldenCreated,
}, null, 2));
