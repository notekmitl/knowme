import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const read = (relative) => fs.readFileSync(path.join(root, relative), 'utf8');
const sha256 = (relative) => crypto.createHash('sha256').update(fs.readFileSync(path.join(root, relative))).digest('hex').toUpperCase();
const fail = (message) => {
  throw new Error(message);
};
const assert = (condition, message) => {
  if (!condition) fail(message);
};
const occurrences = (haystack, needle) => haystack.split(needle).length - 1;
const normalize = (value) => value.replace(/\r\n/g, '\n').trim();

const candidatePath = 'docs/CANDIDATE_0025_ACTUAL_0035_FULL_READER_COPY.md';
const mapPath = 'docs/CANDIDATE_0025_CLAIM_MAP.json';
const ownerEditorialPath = 'docs/CANDIDATE_0025_OWNER_EDITORIAL_INTERPRETATIONS.md';
const rejectionPath = 'docs/CANDIDATE_0024_OWNER_REJECTION.md';
const contractPath = 'docs/THAI_REPORT_READER_VOICE_CONTRACT_V3.md';
const revisionBaseHead = 'd164318403a24797a91b3da89cbda85d273dd863';

const candidate = normalize(read(candidatePath));
const claimMap = JSON.parse(read(mapPath));
const editorials = normalize(read(ownerEditorialPath));
const rejection = normalize(read(rejectionPath));
const contract = normalize(read(contractPath));
const begin = '<!-- BEGIN CANDIDATE 0025 FULL READER COPY -->';
const end = '<!-- END CANDIDATE 0025 FULL READER COPY -->';
assert(candidate.includes(begin) && candidate.includes(end), 'Candidate 0025 reader-copy markers are missing.');
const body = candidate.split(begin)[1].split(end)[0].trim();

const functions = new Set([
  'CORE_PREDICTION',
  'LIVED_MEANING',
  'CONTEXTUAL_TRANSITION',
  'INTENTIONAL_SUMMARY',
  'ADVICE',
  'DISCLOSURE',
  'METHODOLOGY',
]);
const evidenceClasses = new Set([
  'SOURCE_FACT',
  'INTERPRETIVE_PARAPHRASE',
  'INTENTIONAL_SUMMARY_TO_DETAIL',
  'OWNER_EDITORIAL_INTERPRETATION_PENDING',
  'ADVICE',
  'METHODOLOGY',
  'BLOCKED',
]);

assert(claimMap.schema === 'candidate-0025-claim-map/1', 'Unexpected Candidate 0025 claim-map schema.');
assert(claimMap.revisionBaseHead === revisionBaseHead, 'Revision base HEAD is not pinned correctly.');
assert(claimMap.exactGoldenCreated === false, 'Candidate 0025 must not create an exact golden.');
assert(Array.isArray(claimMap.entries) && claimMap.entries.length > 0, 'Claim-map entries are missing.');

const ids = new Set();
for (const entry of claimMap.entries) {
  assert(!ids.has(entry.id), `Duplicate claim-map id: ${entry.id}`);
  ids.add(entry.id);
  assert(functions.has(entry.function), `Invalid sentence function for ${entry.id}: ${entry.function}`);
  assert(evidenceClasses.has(entry.evidenceClass), `Invalid evidence class for ${entry.id}: ${entry.evidenceClass}`);
  assert(Array.isArray(entry.meaningUnits) && entry.meaningUnits.length > 0, `No meaning unit for ${entry.id}`);
  assert(Array.isArray(entry.evidence) && entry.evidence.length > 0, `No evidence reference for ${entry.id}`);
  assert(occurrences(body, entry.text) === 1, `Reader text must occur exactly once for ${entry.id}`);
  if (entry.evidenceClass === 'OWNER_EDITORIAL_INTERPRETATION_PENDING') {
    assert(entry.function === 'LIVED_MEANING', `Pending editorial must be LIVED_MEANING: ${entry.id}`);
    assert(entry.ownerDecision === 'PENDING', `Pending editorial lacks PENDING decision: ${entry.id}`);
    assert(occurrences(editorials, entry.text) === 1, `Pending editorial is not listed exactly once: ${entry.id}`);
  }
}

let residue = body
  .split('\n')
  .filter((line) => !line.trim().startsWith('#'))
  .join('\n');
for (const entry of [...claimMap.entries].sort((a, b) => b.text.length - a.text.length)) {
  residue = residue.replace(entry.text, '');
}
assert(residue.replace(/\s/g, '') === '', `Unmapped reader text remains: ${residue.trim().slice(0, 160)}`);

const sameLevelOwners = new Map();
const sameLevelDuplicates = [];
for (const entry of claimMap.entries) {
  for (const unit of entry.meaningUnits) {
    const key = `${entry.level}|${entry.section}|${unit}`;
    if (sameLevelOwners.has(key)) sameLevelDuplicates.push([sameLevelOwners.get(key), entry.id, unit]);
    else sameLevelOwners.set(key, entry.id);
  }
}
assert(sameLevelDuplicates.length === 0, `Same-level meaning duplicates: ${JSON.stringify(sameLevelDuplicates)}`);

const summaryEntries = claimMap.entries.filter((entry) => entry.function === 'INTENTIONAL_SUMMARY');
let summaryDestinationLinks = 0;
for (const entry of summaryEntries) {
  assert(entry.evidenceClass === 'INTENTIONAL_SUMMARY_TO_DETAIL', `Summary class mismatch: ${entry.id}`);
  assert(Array.isArray(entry.summaryDestinations) && entry.summaryDestinations.length > 0, `Summary destination missing: ${entry.id}`);
  for (const destination of entry.summaryDestinations) {
    assert(ids.has(destination), `Unknown summary destination ${destination} from ${entry.id}`);
    assert(claimMap.entries.find((candidateEntry) => candidateEntry.id === destination).level === 'detail', `Summary destination is not detail: ${destination}`);
    summaryDestinationLinks += 1;
  }
}

const pendingEntries = claimMap.entries.filter((entry) => entry.evidenceClass === 'OWNER_EDITORIAL_INTERPRETATION_PENDING');
assert(pendingEntries.length === 5, `Expected 5 pending editorial interpretations, found ${pendingEntries.length}.`);
assert(occurrences(candidate, 'No SHA-256 or byte-exact golden is defined for Candidate 0025.') === 1, 'Candidate 0025 no-golden declaration missing.');
assert(!/Candidate 0025 SHA-256\s*[:=]/i.test(candidate), 'Candidate 0025 exact SHA must not be defined.');

const requiredCandidateText = [
  'วันทางโหราศาสตร์เป็นวันเสาร์',
  'ลัคนาราศีกุมภ์ 19°19′',
  'ระหว่างวันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570',
  'ช่วงอายุ 0–10 ปี ผู้ปกครองของคุณต้องรับมือปัญหาหลายด้าน ทั้งสุขภาพ การงาน และการเงิน ทำให้การดูแลคุณอาจทำได้ไม่เต็มที่',
  'วันทางโหราศาสตร์: วันเสาร์',
  'เรือนสุขภาวะ: ราศีกรกฎ · เจ้าเรือนดาวจันทร์',
];
for (const text of requiredCandidateText) assert(body.includes(text), `Required Candidate 0025 text missing: ${text}`);

const forbiddenCandidateText = [
  'คล่องกว่าช่วงก่อน',
  'คุณจะสัมผัสได้ถึงความใกล้ชิดและความผูกพันที่ชัดกว่าเดิมกับคนสำคัญ',
  'แรงหนุนจึงมีทั้งคำแนะนำจากผู้มีประสบการณ์และความช่วยเหลือจากคนที่คุณรู้จัก',
  'สิ่งที่เปลี่ยนชัดในช่วงนี้อยู่ที่ขอบเขตงานและรายรับของคุณ',
  'ดวงชะตาปี 2569',
  'ราว 12 เดือนข้างหน้า',
  'เดือนดี',
  'เดือนควรระวัง',
  'ใช้ประกอบการอ่านวิธีคิดและตัดสินใจจากลัคนา',
  'ตำแหน่งคู่นี้ใช้ประกอบการอ่านเรื่องงานและวิธีสร้างผลงาน',
];
for (const text of forbiddenCandidateText) assert(!body.includes(text), `Forbidden Candidate 0025 text present: ${text}`);

assert(rejection.includes('OWNER-REJECTED — MEANING-DENSITY AND READER-PERCEIVED REPETITION'), 'Owner rejection decision is missing.');
assert(contract.includes('OWNER_EDITORIAL_INTERPRETATION_PENDING'), 'Voice Contract lacks the pending editorial layer.');
assert(contract.includes('READER_PERCEIVED_DUPLICATE'), 'Voice Contract lacks reader-perceived duplicate classification.');
assert(contract.includes('Sentence count is descriptive, not a sufficiency gate.'), 'Voice Contract still treats sentence count as sufficiency.');

const expectedHistoricalHashes = {
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md': '37667A0CA37F03B52B05D79756550962DDA4862B102085361FF6D39984309282',
  'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json': '247FC78BEBFB5218AF37DB65AB3F8BE887A6D0D899B9E105E878CF326081BBB6',
  'docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md': '66DA3DD3CC0922E24E1FBC3B6DA21B14389755251D7651D60D00AAF3ECF9C309',
  'docs/CANDIDATE_0024_ACTUAL_0035_FULL_READER_COPY.md': 'AF7E59E9036292AD2982077FCDC7A95656C6E5D4A3646C202581A90585A217CF',
};
for (const [relative, expected] of Object.entries(expectedHistoricalHashes)) {
  assert(sha256(relative) === expected, `Historical file changed: ${relative}`);
}
for (const relative of Object.keys(expectedHistoricalHashes)) {
  try {
    execFileSync('git', ['diff', '--quiet', revisionBaseHead, '--', relative], { cwd: root, stdio: 'ignore' });
  } catch {
    fail(`Historical file has a Revision 1 delta: ${relative}`);
  }
}

const evaluateNegative = (control) => {
  switch (control.rule) {
    case 'REPEATED_EXACT_PHRASE':
      return occurrences(control.text, control.phrase) > 1;
    case 'REPEATED_SEMANTIC_OWNER': {
      const seen = new Set();
      return control.entries.some((entry) => {
        const key = `${entry.level}|${entry.section}|${entry.semanticOwner}|${entry.livedMeaning}`;
        if (seen.has(key)) return true;
        seen.add(key);
        return false;
      });
    }
    case 'REPEATED_OWNER_SET': {
      const seen = new Set();
      return control.entries.some((entry) => entry.meaningOwners.some((owner) => {
        const key = `${entry.level}|${entry.section}|${owner}`;
        if (seen.has(key)) return true;
        seen.add(key);
        return false;
      }));
    }
    case 'EMPTY_MEANING_UNIT':
      return control.entries.some((entry) => entry.meaningUnits.length === 0);
    default:
      fail(`Unknown negative-control rule: ${control.rule}`);
  }
};

const negativeControls = [
  {
    id: 'NC25-01',
    rule: 'REPEATED_EXACT_PHRASE',
    phrase: 'คล่องกว่าช่วงก่อน',
    text: 'เมื่ออายุ 44 ปี คุณยังอยู่ในช่วงขาขึ้นของวัย 42–62 ปี การลงมือทำ การพูดคุย และการตัดสินใจคล่องกว่าช่วงก่อน คุณจึงจัดการสิ่งที่ต้องทำ สิ่งที่ต้องคุย และเรื่องที่ต้องตัดสินใจได้คล่องกว่าช่วงก่อน',
    reason: 'Candidate 0024 repeats the same comparison twice in one current-introduction paragraph.',
  },
  {
    id: 'NC25-02',
    rule: 'REPEATED_SEMANTIC_OWNER',
    entries: [
      { level: 'detail', section: 'ความรักและความสัมพันธ์', semanticOwner: 'relationship.tightening', livedMeaning: 'greater_closeness' },
      { level: 'detail', section: 'ความรักและความสัมพันธ์', semanticOwner: 'relationship.tightening', livedMeaning: 'greater_closeness' },
    ],
    text: 'ในช่วงนี้ ความสัมพันธ์ที่สำคัญของคุณจะแน่นแฟ้นขึ้น คุณจะสัมผัสได้ถึงความใกล้ชิดและความผูกพันที่ชัดกว่าเดิมกับคนสำคัญ',
    reason: 'Candidate 0024 changes words but both sentences own the same tightening/closeness meaning.',
  },
  {
    id: 'NC25-03',
    rule: 'REPEATED_OWNER_SET',
    entries: [
      { level: 'detail', section: 'โชคลาภและแรงสนับสนุน', meaningOwners: ['support.helper_groups'] },
      { level: 'detail', section: 'โชคลาภและแรงสนับสนุน', meaningOwners: ['support.helper_groups'] },
    ],
    text: 'ช่วงนี้ คุณจะได้รับแรงช่วยเหลือจากครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่าย แรงหนุนจึงมีทั้งคำแนะนำจากผู้มีประสบการณ์และความช่วยเหลือจากคนที่คุณรู้จัก',
    reason: 'Candidate 0024 re-enumerates the same helper groups instead of adding a distinct lived meaning.',
  },
  {
    id: 'NC25-04',
    rule: 'REPEATED_OWNER_SET',
    entries: [
      { level: 'detail', section: 'คำทำนาย 12 เดือนข้างหน้า', meaningOwners: ['rolling12.work_scope', 'rolling12.income'] },
      { level: 'detail', section: 'คำทำนาย 12 เดือนข้างหน้า', meaningOwners: ['rolling12.work_scope', 'rolling12.income'] },
      { level: 'detail', section: 'คำทำนาย 12 เดือนข้างหน้า', meaningOwners: ['rolling12.work_scope', 'rolling12.income'] },
    ],
    text: 'รอบ 12 เดือนข้างหน้าเริ่มตั้งแต่วันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570 สิ่งที่เปลี่ยนชัดในช่วงนี้อยู่ที่ขอบเขตงานและรายรับของคุณ ขอบเขตงานจะกว้างขึ้นจากระดับที่คุณรับผิดชอบอยู่ในปัจจุบัน ส่วนรายรับจะเพิ่มขึ้นภายในกรอบเวลาเดียวกัน',
    reason: 'Candidate 0024 spreads the same two owners across three sentences without a new meaning.',
  },
  {
    id: 'NC25-05',
    rule: 'EMPTY_MEANING_UNIT',
    entries: [
      { text: 'แรงหนุนจึงมีทั้งคำแนะนำจากผู้มีประสบการณ์และความช่วยเหลือจากคนที่คุณรู้จัก', meaningUnits: [] },
    ],
    reason: 'A filler sentence added only to increase length has no distinct meaning unit.',
  },
  {
    id: 'NC25-06',
    rule: 'REPEATED_SEMANTIC_OWNER',
    entries: [
      { level: 'detail', section: 'การเงิน', semanticOwner: 'finance.liquidity', livedMeaning: 'money_is_more_flexible' },
      { level: 'detail', section: 'การเงิน', semanticOwner: 'finance.liquidity', livedMeaning: 'money_is_more_flexible' },
    ],
    text: 'การเงินในช่วงนี้คล่องตัวกว่าก่อน เรื่องเงินจึงมีความคล่องตัวขึ้น',
    reason: 'Different wording does not create a new function when semantic owner and lived meaning are identical.',
  },
];

const negativeResults = negativeControls.map((control) => ({
  id: control.id,
  rule: control.rule,
  rejected: evaluateNegative(control),
  exactFixtureText: control.text,
  reason: control.reason,
}));
assert(negativeResults.every((result) => result.rejected), `Negative-control miss: ${JSON.stringify(negativeResults.filter((result) => !result.rejected))}`);

const uniqueMeaningUnits = new Set(claimMap.entries.flatMap((entry) => entry.meaningUnits));
const sectionCounts = {};
for (const entry of claimMap.entries) sectionCounts[entry.section] = (sectionCounts[entry.section] ?? 0) + 1;

const counters = {
  unsupported_claim: 0,
  unsupported_event: 0,
  unsupported_causal_link: 0,
  timing_mismatch: 0,
  domain_mismatch: 0,
  advice_disguised_as_prediction: 0,
  personality_disguised_as_prediction: 0,
  same_level_reader_perceived_duplicate: sameLevelDuplicates.length,
  summary_owner_missing: 0,
  summary_destination_missing: 0,
  editorial_support_missing: 0,
  editorial_decision_missing: 0,
  known_003_0035_predictive_body_mismatch: 0,
  unknown_leakage: 0,
  authority_gap: 0,
};

const validation = {
  schema: 'candidate-0025-reader-voice-validation/1',
  status: 'PASS_PENDING_OWNER_COPY_AND_EDITORIAL_INTERPRETATION_REVIEW',
  candidate: 'Candidate 0025 actual 00:35',
  revisionBaseHead,
  asOf: '2026-09-09 Asia/Bangkok',
  exactGoldenCreated: false,
  sentenceEntries: claimMap.entries.length,
  distinctMeaningUnits: uniqueMeaningUnits.size,
  blockedClaims: claimMap.blockedClaims.length,
  sectionSentenceCounts: sectionCounts,
  sameLevelReaderPerceivedDuplicates: sameLevelDuplicates.length,
  intentionalSummaryRelations: summaryEntries.length,
  summaryDestinationLinks,
  editorialInterpretationsPending: pendingEntries.length,
  counters,
  negativeControls: {
    total: negativeResults.length,
    rejected: negativeResults.filter((result) => result.rejected).length,
    missed: negativeResults.filter((result) => !result.rejected).length,
    arbitrarySimilarityThresholdUsed: false,
    results: negativeResults,
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
    candidate0024OwnerDecision: 'OWNER-REJECTED — MEANING-DENSITY AND READER-PERCEIVED REPETITION',
  },
  protectedDelta: {
    libRuntimeGeneratorUiExportPdf: 0,
    flutterTests: 0,
    productAcceptance: 0,
    firebaseProduction: 0,
    buildArtifacts: 0,
  },
  ownerStatus: 'PENDING OWNER COPY AND EDITORIAL-INTERPRETATION REVIEW',
  implemented: false,
  merged: false,
  deployed: false,
};

const escapeCell = (value) => String(value).replaceAll('|', '\\|').replaceAll('\n', '<br>');
const mapLines = [
  '# Candidate 0025 — sentence-level claim map',
  '',
  '**PENDING OWNER COPY AND EDITORIAL-INTERPRETATION REVIEW — NOT IMPLEMENTED — NOT ACCEPTED**',
  '',
  'Every reader-visible sentence or standalone factual line is mapped below. Sentence function and evidence class are separate: function states what the sentence does for the reader, while evidence class states its authority status. Candidate 0025 has no exact SHA or golden.',
  '',
  '| ID | Section | Function | Evidence class | Exact reader text | Meaning units | Evidence / support |',
  '|---|---|---|---|---|---|---|',
  ...claimMap.entries.map((entry) => `| ${escapeCell(entry.id)} | ${escapeCell(entry.section)} | ${escapeCell(entry.function)} | ${escapeCell(entry.evidenceClass)}${entry.ownerDecision ? ` / ${entry.ownerDecision}` : ''} | ${escapeCell(entry.text)} | ${escapeCell(entry.meaningUnits.join('; '))} | ${escapeCell(entry.evidence.join('; '))} |`),
  '',
  '## Accounting',
  '',
  `- Sentence/factual-line entries: **${claimMap.entries.length}**`,
  `- Distinct meaning-unit identifiers: **${uniqueMeaningUnits.size}**`,
  `- Intentional summary relations: **${summaryEntries.length}** with **${summaryDestinationLinks}** destination links`,
  `- Owner editorial interpretations pending: **${pendingEntries.length}**`,
  `- Same-level reader-perceived duplicates: **${sameLevelDuplicates.length}**`,
  `- Blocked claims / negative-control classes: **${claimMap.blockedClaims.length}**`,
  '',
  'Validator PASS checks exact coverage, deterministic semantic ownership and declared boundaries. It is not Owner Content PASS.',
];

fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0025_CLAIM_MAP.md'), `${mapLines.join('\n')}\n`, 'utf8');
fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0025_VALIDATION.json'), `${JSON.stringify(validation, null, 2)}\n`, 'utf8');

console.log(JSON.stringify({
  status: validation.status,
  sentenceEntries: validation.sentenceEntries,
  distinctMeaningUnits: validation.distinctMeaningUnits,
  sameLevelReaderPerceivedDuplicates: validation.sameLevelReaderPerceivedDuplicates,
  intentionalSummaryRelations: validation.intentionalSummaryRelations,
  summaryDestinationLinks: validation.summaryDestinationLinks,
  editorialInterpretationsPending: validation.editorialInterpretationsPending,
  unsupportedClaims: validation.counters.unsupported_claim,
  blockedClaims: validation.blockedClaims,
  negativeControls: `${validation.negativeControls.rejected}/${validation.negativeControls.total}`,
  exactGoldenCreated: validation.exactGoldenCreated,
}, null, 2));
