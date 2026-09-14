import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const read = (relative) => fs.readFileSync(path.join(root, relative), 'utf8');
const sha256 = (relative) => crypto
  .createHash('sha256')
  .update(fs.readFileSync(path.join(root, relative)))
  .digest('hex');
const assert = (condition, message) => {
  if (!condition) throw new Error(message);
};
const count = (text, needle) => text.split(needle).length - 1;

const candidatePath = 'docs/CANDIDATE_0029_ACTUAL_0035_FULL_READER_COPY.md';
const candidate = read(candidatePath).replace(/\r\n/g, '\n');
const begin = '<!-- BEGIN CANDIDATE 0029 FULL READER COPY -->';
const end = '<!-- END CANDIDATE 0029 FULL READER COPY -->';
assert(candidate.includes(begin) && candidate.includes(end), 'Candidate 0029 markers are missing.');
const body = candidate.split(begin)[1].split(end)[0].trim();

assert(!body.includes('## ภาพรวมเส้นทางชีวิต'), 'The redundant life-path overview is reader-visible.');
assert(count(body, '## คำทำนายอดีต') === 1, 'Past prediction must have exactly one heading layer.');
assert(!body.includes('อายุ 0–10 ปี'), 'The rejected 0–10 label is still reader-visible.');

const pastHeadings = [
  '### ตั้งแต่เกิดจนถึง 10 ปี · ดาวเสาร์เสวยอายุ',
  '### อายุ 11–29 ปี · ดาวพฤหัสบดีเสวยอายุ',
  '### อายุ 30–41 ปี · ดาวราหูเสวยอายุ',
];
for (const heading of pastHeadings) {
  assert(count(body, heading) === 1, `Missing or duplicate past heading: ${heading}`);
}

const sectionText = (heading, nextHeading) => {
  const start = body.indexOf(heading);
  assert(start >= 0, `Missing section: ${heading}`);
  const endIndex = nextHeading ? body.indexOf(nextHeading, start + heading.length) : body.length;
  assert(endIndex > start, `Invalid section boundary: ${heading}`);
  return body.slice(start + heading.length, endIndex).trim();
};
for (let index = 0; index < pastHeadings.length; index += 1) {
  const paragraph = sectionText(pastHeadings[index], pastHeadings[index + 1] ?? '## คำทำนายปัจจุบัน');
  assert(paragraph.length >= 180, `Past explanation is too short: ${pastHeadings[index]}`);
}

const currentHeading = '## คำทำนายปัจจุบัน — อายุ 44 ปี · ดาวศุกร์เสวยอายุ';
assert(count(body, currentHeading) === 1, 'Current heading must include the governing planet exactly once.');
const currentBody = sectionText(currentHeading, '## คำทำนาย 12 เดือนข้างหน้า');
assert(!/^#{3,4}\s/m.test(currentBody), 'Current prediction must not contain domain subheadings.');
const currentParagraphs = currentBody.split(/\n\s*\n/).map((paragraph) => paragraph.trim()).filter(Boolean);
const currentLeads = [
  'ปัจจุบันอายุ 44 ปี',
  'ด้านการงาน',
  'ด้านการเงิน',
  'ด้านความรักและความสัมพันธ์',
  'ด้านสุขภาพ',
  'ด้านโชคลาภและแรงสนับสนุน',
];
assert(currentParagraphs.length === currentLeads.length, `Current prediction must contain six paragraphs, found ${currentParagraphs.length}.`);
for (let index = 0; index < currentLeads.length; index += 1) {
  assert(currentParagraphs[index].startsWith(currentLeads[index]), `Current paragraph ${index + 1} must start with: ${currentLeads[index]}`);
}
assert(currentBody.includes('สำหรับคนมีคู่'), 'Partnered-reader relationship copy is missing.');
assert(currentBody.includes('ส่วนคนโสด'), 'Single-reader relationship copy is missing.');
assert(currentBody.includes('หากกำลังทำความรู้จักใคร'), 'Single-reader copy lost its evidence-bound condition.');
assert(!currentBody.includes('คนโสดจะมีคนเข้ามาบ้างเป็นระยะ'), 'Unsupported new-person promise was introduced.');

const horizon = sectionText('## คำทำนาย 12 เดือนข้างหน้า', '## คำแนะนำ');
assert(horizon.includes('จะเด่นเรื่องการงาน'), 'Rolling horizon lacks the work emphasis.');
assert(horizon.includes('และเด่นเรื่องการเงิน'), 'Rolling horizon lacks the finance emphasis.');

const orderedHeadings = [
  '## คำแนะนำ',
  '## พื้นดวงและมุมมองด้านจิตวิทยา',
  '## ที่มาและวิธีอ่าน',
  '### รายงานนี้ดูจากอะไร',
  '### โครงสร้างดวงหลัก',
  '### ที่มาของผลวิเคราะห์',
  '## ข้อจำกัด',
];
let previousIndex = -1;
for (const heading of orderedHeadings) {
  const index = body.indexOf(heading);
  assert(index > previousIndex, `Report section is missing or out of order: ${heading}`);
  previousIndex = index;
}
const limitsIndex = body.indexOf('## ข้อจำกัด');
assert(body.lastIndexOf('\n## ') + 1 === limitsIndex, 'Limitations must be the final report section.');
const healthDisclaimer = 'ข้อความด้านสุขภาพใช้เพื่อการทบทวนทั่วไป ไม่ใช่การวินิจฉัยโรคหรือคำแนะนำทางการแพทย์';
assert(body.endsWith(healthDisclaimer), 'The final report line must be the health disclaimer.');

const chart = sectionText('### โครงสร้างดวงหลัก', '### ที่มาของผลวิเคราะห์');
const chartRows = chart.split('\n').map((line) => line.trim()).filter(Boolean);
assert(chartRows.length === 7, `Main-chart structure must contain seven facts, found ${chartRows.length}.`);
assert(!chart.includes(' — '), 'Main-chart explanatory tails are still present.');
assert(!body.includes('ความหมายและข้อจำกัดของผลลัพธ์'), 'Removed chart explanation heading is still present.');

const runtime = read('lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart');
const exportDocument = read('lib/features/thai_beta/application/thai_beta_report_export_document.dart');
assert(runtime.includes("'candidate-0029-reader-copy-v1'"), 'Candidate 0029 runtime realizer is missing.');
assert(runtime.includes('_lifePeriodPlanetLabel'), 'Dynamic governing-planet labeling is missing.');
assert(exportDocument.includes('_applyCandidate0029ReaderSurface'), 'Candidate 0029 reader surface is missing.');
assert(exportDocument.includes('_currentDomainParagraph'), 'Continuous current-domain paragraph projection is missing.');
assert(exportDocument.includes('runtimeSection(disclosure)'), 'Final limitations projection is missing.');

const candidate0028Hash = sha256('docs/CANDIDATE_0028_ACTUAL_0035_FULL_READER_COPY.md');
assert(
  candidate0028Hash === '53f4a8dea71caae7ec19cbdc3e359b560c3b260285631804932ed3b40a1c1798',
  'Historical Candidate 0028 reader copy changed.',
);

const result = {
  status: 'PASS',
  candidate: '0029',
  candidateSha256: sha256(candidatePath),
  candidate0028HistoricalSha256: candidate0028Hash,
  overviewReaderVisible: false,
  pastHeadingLayers: 1,
  pastPeriodsWithPlanet: pastHeadings.length,
  currentParagraphs: currentParagraphs.length,
  currentDomainSubheadings: 0,
  mainChartFactRows: chartRows.length,
  limitationsFinal: true,
};
process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
