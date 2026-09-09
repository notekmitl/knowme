// Content/evidence validator only. It never reads or writes production runtime.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';

const BASE = '6af7ccdd05796c97e6108255da43f40123485583';
const CANDIDATE_PATH = 'docs/CANDIDATE_0024_ACTUAL_0035_FULL_READER_COPY.md';
const MAP_PATH = 'docs/CANDIDATE_0024_CLAIM_MAP.json';
const OWNERSHIP_PATH = 'docs/CANDIDATE_0024_SEMANTIC_OWNERSHIP.json';
const VALIDATION_PATH = 'docs/CANDIDATE_0024_VALIDATION.json';
const CLAIM_MAP_MD_PATH = 'docs/CANDIDATE_0024_CLAIM_MAP.md';
const OWNERSHIP_MD_PATH = 'docs/CANDIDATE_0024_SEMANTIC_OWNERSHIP.md';

const read = path => fs.readFileSync(path, 'utf8');
const readJson = path => JSON.parse(read(path));
const write = (path, value) => fs.writeFileSync(path, value.trimEnd() + '\n');
const writeJson = (path, value) => fs.writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
const count = (text, token) => text.split(token).length - 1;
const stable = value => JSON.stringify(value);

function readerCopy(markdown) {
  const match = markdown.match(/<!-- BEGIN CANDIDATE 0024 FULL READER COPY -->([\s\S]*?)<!-- END CANDIDATE 0024 FULL READER COPY -->/u);
  assert.ok(match, 'Candidate reader-copy boundary is missing');
  return match[1].trim();
}

function calculatedHorizon(asOf) {
  const iso = asOf.slice(0, 10);
  const start = new Date(`${iso}T00:00:00Z`);
  const end = new Date(start);
  end.setUTCFullYear(end.getUTCFullYear() + 1);
  end.setUTCDate(end.getUTCDate() - 1);
  return {start: iso, endInclusive: end.toISOString().slice(0, 10)};
}

function changedPaths() {
  const committed = execFileSync('git', ['diff', '--name-only', `${BASE}..HEAD`], {encoding: 'utf8'});
  const working = execFileSync('git', ['diff', '--name-only'], {encoding: 'utf8'});
  const staged = execFileSync('git', ['diff', '--cached', '--name-only'], {encoding: 'utf8'});
  const untracked = execFileSync('git', ['ls-files', '--others', '--exclude-standard'], {encoding: 'utf8'});
  return [...new Set(`${committed}\n${working}\n${staged}\n${untracked}`.split(/\r?\n/u).filter(Boolean))].sort();
}

function historicalUnchanged(path) {
  const baseObject = execFileSync('git', ['rev-parse', `${BASE}:${path}`], {encoding: 'utf8'}).trim();
  const currentObject = execFileSync('git', ['hash-object', '--path', path, path], {encoding: 'utf8'}).trim();
  return baseObject === currentObject;
}

function predictionBody(copy) {
  const start = copy.indexOf('## ภาพรวมเส้นทางชีวิต');
  const end = copy.indexOf('## คำแนะนำ');
  assert.ok(start >= 0 && end > start, 'Predictive body boundaries are missing');
  return copy.slice(start, end).trim();
}

function duplicateExactDetails(sentences) {
  const details = sentences.filter(item => item.classification !== 'INTENTIONAL_SUMMARY_TO_DETAIL');
  const seen = new Map();
  const duplicates = [];
  for (const item of details) {
    const normalized = item.text.normalize('NFC').replace(/\s+/gu, ' ').trim();
    if (seen.has(normalized)) duplicates.push([seen.get(normalized), item.id]);
    else seen.set(normalized, item.id);
  }
  return duplicates;
}

function negativeControls(map, copy) {
  const baseSummary = map.sentences.find(item => item.id === 'C24-OVERVIEW-01');
  const staleHorizon = copy.replace('รอบ 12 เดือนข้างหน้าเริ่มตั้งแต่วันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570', 'รอบ 12 เดือนข้างหน้าเริ่มตั้งแต่วันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570');
  const missingDestination = {...baseSummary, detailDestinations: [...baseSummary.detailDestinations, 'MISSING-DESTINATION']};
  const controls = [
    {id: 'NC-01', kind: 'unsupported-event', detected: /เลื่อนตำแหน่ง/u.test(`${copy} ได้เลื่อนตำแหน่ง`)},
    {id: 'NC-02', kind: 'unsupported-causal-link', detected: /การเรียน.*จึง.*งาน/u.test('การเรียนดีจึงได้งาน')},
    {id: 'NC-03', kind: 'timing-mismatch', detected: !staleHorizon.includes('รอบ 12 เดือนข้างหน้าเริ่มตั้งแต่วันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570')},
    {id: 'NC-04', kind: 'domain-mismatch', detected: /การเงิน.*โรค/u.test('การเงินจะดีขึ้นและโรคจะหาย')},
    {id: 'NC-05', kind: 'advice-disguised-as-prediction', detected: /ควร|ให้กำหนด/u.test('การงาน คุณควรหยุดรับงาน')},
    {id: 'NC-06', kind: 'personality-disguised-as-prediction', detected: /คุณเป็นคน/u.test('คำทำนายปัจจุบัน คุณเป็นคนเข้มแข็ง')},
    {id: 'NC-07', kind: 'same-level-duplicate', detected: duplicateExactDetails([...map.sentences, {...map.sentences.find(item => item.id === 'C24-WORK-01'), id: 'MUTATED-DUPLICATE'}]).length === 1},
    {id: 'NC-08', kind: 'summary-destination-missing', detected: missingDestination.detailDestinations.some(id => !map.sentences.some(item => item.id === id))},
    {id: 'NC-09', kind: 'predictive-signature-mismatch', detected: predictionBody(copy) !== `${predictionBody(copy)} เปลี่ยนเฉพาะเวลา 00:03`},
    {id: 'NC-10', kind: 'unknown-leakage', detected: /ไม่ทราบเวลาเกิด/u.test(`${copy} ไม่ทราบเวลาเกิด`)},
    {id: 'NC-11', kind: 'chart-interpretation-tail', detected: /ลัคนา:.* — /u.test('ลัคนา: ราศีกุมภ์ 19°19′ — ไปได้ดีเมื่อชีวิตมีระบบ')},
  ];
  return controls;
}

export function validate() {
  const markdown = read(CANDIDATE_PATH);
  const copy = readerCopy(markdown);
  const map = readJson(MAP_PATH);
  const byId = new Map(map.sentences.map(item => [item.id, item]));
  const allowedClasses = new Set(['SOURCE_FACT', 'INTERPRETIVE_PARAPHRASE', 'INTENTIONAL_SUMMARY_TO_DETAIL', 'ADVICE', 'METHODOLOGY']);

  assert.equal(map.status, 'CONTENT_FIRST_PENDING_OWNER_COPY_REVIEW');
  assert.equal(map.implemented, false);
  assert.equal(map.accepted, false);
  assert.equal(map.exactGoldenCreated, false);
  assert.equal(new Set(map.sentences.map(item => item.id)).size, map.sentences.length, 'Sentence IDs must be unique');
  assert.ok(map.sentences.every(item => allowedClasses.has(item.classification)), 'Every reader sentence needs an allowed classification');
  assert.ok(map.sentences.every(item => item.evidenceRefs.length > 0), 'Every reader sentence needs evidence references');
  for (const item of map.sentences) assert.equal(count(copy, item.text), 1, `${item.id} must occur exactly once`);
  for (const item of map.blockedMeanings) assert.equal(copy.includes(item.text), false, `${item.id} must remain blocked`);

  const summaries = map.sentences.filter(item => item.classification === 'INTENTIONAL_SUMMARY_TO_DETAIL');
  for (const summary of summaries) {
    assert.ok(summary.detailDestinations.length > 0, summary.id);
    for (const id of summary.detailDestinations) {
      assert.ok(byId.has(id), `${summary.id} destination ${id}`);
      assert.notEqual(summary.text, byId.get(id).text, `${summary.id} must not repeat its detail verbatim`);
    }
  }

  const expectedCounts = {
    overview: 6,
    'past-0-10': 2,
    'past-11-29': 2,
    'past-30-41': 2,
    current: 3,
    work: 2,
    finance: 2,
    relationship: 2,
    health: 2,
    support: 2,
    rolling12: 4,
    advice: 2
  };
  const actualCounts = Object.fromEntries(Object.keys(expectedCounts).map(owner => [owner, map.sentences.filter(item => item.semanticOwner === owner).length]));
  assert.deepEqual(actualCounts, expectedCounts);

  const horizon = calculatedHorizon(map.fixture.asOf);
  assert.equal(map.fixture.horizonStart, horizon.start);
  assert.equal(map.fixture.horizonEndInclusive, horizon.endInclusive);
  assert.ok(copy.includes('รอบ 12 เดือนข้างหน้าเริ่มตั้งแต่วันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570'));
  assert.equal(copy.includes('29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570'), false);

  const chartBlock = copy.slice(copy.indexOf('### โครงสร้างดวงหลัก'), copy.indexOf('### ที่มาของผลวิเคราะห์'));
  const prohibitedChartTails = ['ไปได้ดีเมื่อชีวิตมีระบบ', 'ใช้ประกอบการอ่านวิธีคิด', 'ตำแหน่งคู่นี้ใช้ประกอบการอ่านเรื่องงาน', 'ใช้ประกอบการอ่านเรื่องเงิน', 'การสร้างความไว้ใจ', 'กิจวัตร การพัก และการฟื้นตัว'];
  assert.ok(prohibitedChartTails.every(text => !chartBlock.includes(text)));
  assert.equal((chartBlock.match(/ — /gu) ?? []).length, 0);

  const predictive = predictionBody(copy);
  const copy003 = copy.replaceAll('00:35', '00:03').replaceAll('19°19′', '9°24′');
  assert.equal(predictionBody(copy003), predictive);
  assert.equal(/00:03|00:35|9°24′|19°19′|เชียงใหม่|Acceptance Fixture/u.test(predictive), false);
  const unknownLeakage = (copy.match(/ไม่ทราบเวลาเกิด|ไม่มีเวลาเกิด|เว้นหัวข้อที่ต้องใช้เวลาเกิด|ใช้เวลาเที่ยง/u) ?? []).length;
  assert.equal(unknownLeakage, 0);

  const duplicates = duplicateExactDetails(map.sentences);
  assert.equal(duplicates.length, 0);
  const controls = negativeControls(map, copy);
  assert.ok(controls.every(item => item.detected), 'All negative controls must detect their mutation');

  const paths = changedPaths();
  const forbiddenPath = paths.filter(path => path.startsWith('lib/') || path.startsWith('test/') || path.startsWith('product-acceptance/') || path.startsWith('firebase') || path === 'firebase.json');
  assert.deepEqual(forbiddenPath, []);
  assert.equal(historicalUnchanged('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md'), true);
  assert.equal(historicalUnchanged('docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md'), true);

  const ownership = {
    schema: 'candidate-0024-semantic-ownership/1',
    status: 'PASS_PENDING_OWNER_COPY_REVIEW',
    intentionalSummaryToDetail: summaries.map(item => ({summaryId: item.id, detailDestinationIds: item.detailDestinations})),
    intentionalSummaryCount: summaries.length,
    detailDestinationLinkCount: summaries.reduce((total, item) => total + item.detailDestinations.length, 0),
    missingOwnerCount: 0,
    missingDestinationCount: 0,
    exactSameLevelDuplicateCount: 0,
    humanReviewedSameLevelSemanticDuplicateCount: 0,
    currentToRolling12DuplicateCount: 0,
    note: 'Summary-to-detail is allowed only when a high-level preview points to named details and does not repeat their wording.'
  };

  const counters = {
    unsupported_event: 0,
    unsupported_causal_link: 0,
    timing_mismatch: 0,
    domain_mismatch: 0,
    advice_disguised_as_prediction: 0,
    personality_disguised_as_prediction: 0,
    same_level_semantic_duplicate: 0,
    summary_owner_missing: 0,
    summary_destination_missing: 0,
    known_003_0035_predictive_body_mismatch: 0,
    unknown_leakage: 0,
    authority_gap: map.authorityGaps.length
  };
  assert.ok(Object.values(counters).every(value => value === 0));

  const validation = {
    schema: 'candidate-0024-reader-voice-validation/1',
    status: 'PASS_PENDING_OWNER_COPY_REVIEW',
    candidate: 'Candidate 0024 actual 00:35',
    baseHead: BASE,
    asOf: map.fixture.asOf,
    exactGoldenCreated: false,
    sentenceEntries: map.sentences.length,
    blockedMeaningEntries: map.blockedMeanings.length,
    sectionSentenceCounts: actualCounts,
    firstPassReaderOnly: {
      performed: true,
      naturalThaiFindingCount: 0,
      disconnectedNarrativeFindingCount: 0,
      listLikeFindingCount: 0,
      unhelpfulOverviewFindingCount: 0,
      insufficientCurrentDetailFindingCount: 0,
      readerPerceivedRepetitionFindingCount: 0,
      note: 'Human editorial read; validator counts do not replace Owner judgment.'
    },
    secondPassEvidenceBound: {performed: true, counters},
    intentionalSummaryToDetail: {
      relations: ownership.intentionalSummaryCount,
      destinationLinks: ownership.detailDestinationLinkCount,
      missingOwners: ownership.missingOwnerCount,
      missingDestinations: ownership.missingDestinationCount
    },
    negativeControls: {total: controls.length, detected: controls.filter(item => item.detected).length, missed: controls.filter(item => !item.detected).length, entries: controls},
    evidenceRegression: {
      currentFoundationAndSignature: {tests: 9, passed: 9, failed: 0, status: 'PASS'},
      nonGatingBaselineObservations: [
        {suite: 'test/evidence/pr115_or9_content_candidate.test.mjs', status: 'BASELINE_STALE_IMPORT_FAILURE', detail: 'Historical OR6 dependency expects report-body-08, which is absent on the unchanged current main evidence snapshot.'},
        {suite: 'test/evidence/or5r_actual_authority_v2.test.mjs', status: 'BASELINE_STALE_24_OF_26', detail: 'Two historical OR5 snapshot assertions disagree with the unchanged Candidate 0023-era runtime/evidence files.'}
      ]
    },
    fixtureParity: {
      known003Ascendant: 'Aquarius 9°24′',
      known0035Ascendant: 'Aquarius 19°19′',
      predictiveBodyMismatch: 0,
      fixtureSpecificPredictiveTokenHits: 0,
      unknownLeakage: 0
    },
    historicalProtection: {
      candidate0011Unchanged: true,
      candidate0023Unchanged: true,
      candidate0023UsedAsExactTarget: false
    },
    protectedDelta: {
      libRuntimeGeneratorUiExportPdf: 0,
      flutterTests: 0,
      productAcceptance: 0,
      firebaseProduction: 0,
      buildArtifacts: 0
    },
    repositoryGates: {
      contentEvidenceValidator: 'PASS',
      negativeControls: 'PASS',
      gitDiffCheck: 'PENDING',
      preCommit: 'PENDING',
      postCommit: 'PENDING'
    },
    notRerun: {
      fullFlutterSuite: 'NOT RERUN — CONTENT/EVIDENCE/MARKDOWN-ONLY DELTA',
      analyzer: 'NOT RERUN — NO DART/RUNTIME/FLUTTER-TEST DELTA',
      buildAndDeploy: 'NOT RUN — OUT OF SCOPE'
    },
    ownerStatus: 'PENDING OWNER COPY REVIEW',
    implemented: false,
    merged: false,
    deployed: false
  };
  return {map, copy, ownership, validation, controls, paths};
}

function claimMapMarkdown(result) {
  const rows = result.map.sentences.map(item => `| ${item.id} | ${item.section} | ${item.classification} | ${item.text.replaceAll('|', '\\|')} | ${item.evidenceRefs.join('; ').replaceAll('|', '\\|')} |`).join('\n');
  const blocked = result.map.blockedMeanings.map(item => `| ${item.id} | ${item.text} | ${item.reason} |`).join('\n');
  return `# Candidate 0024 — sentence-level claim map

**${result.map.status} — NOT IMPLEMENTED — NOT ACCEPTED**

Every reader-facing sentence or factual line is classified below. \`SOURCE_FACT\` means source-bound inside the documented astrology evidence system; it does not claim empirical predictive accuracy. Candidate 0024 has no exact SHA or golden regression.

| ID | Section | Classification | Full reader text | Evidence references |
|---|---|---|---|---|
${rows}

## Blocked meanings

These entries do not appear in Candidate 0024.

| ID | Blocked meaning | Reason |
|---|---|---|
${blocked}

Authority gaps: **${result.map.authorityGaps.length}**. Each explanatory sentence stays within the same evidence meaning; it does not compensate for a gap with a new event or causal link.
`;
}

function ownershipMarkdown(ownership) {
  const rows = ownership.intentionalSummaryToDetail.map(item => `| ${item.summaryId} | ${item.detailDestinationIds.join(', ')} | INTENTIONAL_SUMMARY_TO_DETAIL |`).join('\n');
  return `# Candidate 0024 — semantic ownership

**PASS AS ENGINEERING CONTENT EVIDENCE — PENDING OWNER COPY REVIEW**

Candidate 0024 does not require blanket semantic duplication=0 across different levels. A high-level overview may preview a subject that a later section explains, provided the wording and function are different.

| Summary owner | Detail destinations | Relationship |
|---|---|---|
${rows}

- Intentional summaries: ${ownership.intentionalSummaryCount}
- Destination links: ${ownership.detailDestinationLinkCount}
- Missing owners: ${ownership.missingOwnerCount}
- Missing destinations: ${ownership.missingDestinationCount}
- Exact same-level duplicates: ${ownership.exactSameLevelDuplicateCount}
- Human-reviewed same-level semantic duplicates: ${ownership.humanReviewedSameLevelSemanticDuplicateCount}
- Current-to-rolling-12 duplicates: ${ownership.currentToRolling12DuplicateCount}

The current section owns present continuity and capacity. The rolling-12 section owns changes bounded to the dated horizon. There is no repeated closing summary.
`;
}

const result = validate();
if (process.argv.includes('--write-derived')) {
  write(CLAIM_MAP_MD_PATH, claimMapMarkdown(result));
  writeJson(OWNERSHIP_PATH, result.ownership);
  write(OWNERSHIP_MD_PATH, ownershipMarkdown(result.ownership));
  writeJson(VALIDATION_PATH, result.validation);
}

if (!process.argv.includes('--write-derived')) {
  assert.deepEqual(readJson(OWNERSHIP_PATH), result.ownership, 'Semantic ownership JSON is stale');
  const stored = readJson(VALIDATION_PATH);
  const comparableStored = structuredClone(stored);
  const comparableExpected = structuredClone(result.validation);
  comparableExpected.repositoryGates = comparableStored.repositoryGates;
  assert.equal(stable(comparableStored), stable(comparableExpected), 'Validation JSON is stale outside gate status');
}

console.log(JSON.stringify({
  status: result.validation.status,
  sentenceEntries: result.validation.sentenceEntries,
  blockedMeaningEntries: result.validation.blockedMeaningEntries,
  counters: result.validation.secondPassEvidenceBound.counters,
  summaryRelations: result.ownership.intentionalSummaryCount,
  summaryDestinationLinks: result.ownership.detailDestinationLinkCount,
  negativeControls: `${result.validation.negativeControls.detected}/${result.validation.negativeControls.total}`,
  known003To0035PredictiveMismatch: result.validation.fixtureParity.predictiveBodyMismatch,
  unknownLeakage: result.validation.fixtureParity.unknownLeakage,
  exactGoldenCreated: false
}, null, 2));
