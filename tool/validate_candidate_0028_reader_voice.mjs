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

const candidatePath = 'docs/CANDIDATE_0028_ACTUAL_0035_FULL_READER_COPY.md';
const candidate = read(candidatePath).replace(/\r\n/g, '\n');
const begin = '<!-- BEGIN CANDIDATE 0028 FULL READER COPY -->';
const end = '<!-- END CANDIDATE 0028 FULL READER COPY -->';
assert(candidate.includes(begin) && candidate.includes(end), 'Candidate 0028 markers are missing.');
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
  return body.slice(start + heading.length, endIndex).replace(/^\s+|\s+$/g, '');
};
for (let index = 0; index < pastHeadings.length; index += 1) {
  const paragraph = sectionText(pastHeadings[index], pastHeadings[index + 1] ?? '## คำทำนายปัจจุบัน');
  assert(paragraph.length >= 180, `Past explanation is too short: ${pastHeadings[index]}`);
}

const currentHeading = '## คำทำนายปัจจุบัน — อายุ 44 ปี · ดาวศุกร์เสวยอายุ';
assert(count(body, currentHeading) === 1, 'Current heading must include the governing planet exactly once.');
const currentBody = sectionText(currentHeading, '## คำทำนาย 12 เดือนข้างหน้า');
const currentDomains = [
  '#### การงาน',
  '#### การเงิน',
  '#### ความรักและความสัมพันธ์',
  '#### สุขภาพ',
  '#### โชคลาภและแรงสนับสนุน',
];
for (const heading of currentDomains) {
  assert(count(currentBody, heading) === 1, `Current domain is missing or split out: ${heading}`);
}
assert(!currentBody.includes('\n### การงาน'), 'Current domains must remain nested inside one current section.');
assert(currentBody.includes('สำหรับคนมีคู่'), 'Partnered-reader relationship copy is missing.');
assert(currentBody.includes('ส่วนคนโสด'), 'Single-reader relationship copy is missing.');
assert(currentBody.includes('หากกำลังทำความรู้จักใคร'), 'Single-reader copy lost its evidence-bound condition.');
assert(!currentBody.includes('คนโสดจะมีคนเข้ามาบ้างเป็นระยะ'), 'Unsupported new-person promise was introduced.');

const horizon = sectionText('## คำทำนาย 12 เดือนข้างหน้า', '## คำแนะนำ');
assert(horizon.includes('จะเด่นเรื่องการงาน'), 'Rolling horizon lacks the work emphasis.');
assert(horizon.includes('และเด่นเรื่องการเงิน'), 'Rolling horizon lacks the finance emphasis.');

const adviceIndex = body.indexOf('## คำแนะนำ');
const limitsIndex = body.indexOf('## ข้อจำกัด');
const psychologyIndex = body.indexOf('## พื้นดวงและมุมมองด้านจิตวิทยา');
assert(adviceIndex >= 0 && limitsIndex > adviceIndex, 'Limitations must follow advice.');
assert(psychologyIndex > limitsIndex, 'Limitations must be the final prediction section.');

const chart = sectionText('### โครงสร้างดวงหลัก', '### ที่มาของผลวิเคราะห์');
const chartRows = chart.split('\n').map((line) => line.trim()).filter(Boolean);
assert(chartRows.length === 7, `Main-chart structure must contain seven facts, found ${chartRows.length}.`);
assert(!chart.includes(' — '), 'Main-chart explanatory tails are still present.');
assert(!body.includes('ความหมายและข้อจำกัดของผลลัพธ์'), 'Removed chart explanation heading is still present.');

const runtime = read('lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart');
const exportDocument = read('lib/features/thai_beta/application/thai_beta_report_export_document.dart');
const sharedView = read('lib/features/thai_beta/presentation/widgets/thai_beta_shared_report_view.dart');
const pdfExporter = read('lib/features/thai_beta/application/thai_beta_report_pdf_exporter.dart');
assert(runtime.includes("'candidate-0028-reader-copy-v1'"), 'Candidate 0028 runtime realizer is missing.');
assert(runtime.includes('_lifePeriodPlanetLabel'), 'Dynamic governing-planet labeling is missing.');
assert(exportDocument.includes("id: 'report-body-predictive-v2-current'"), 'Grouped current reader section is missing.');
assert(exportDocument.includes("section.id == 'overview'"), 'Reader-surface overview omission is missing.');
assert(!sharedView.includes("'คำทำนายอดีต' => 'อดีต'"), 'Duplicate past phase label remains in the shared view.');
for (const heading of ['ความรักและความสัมพันธ์', 'โชคลาภและแรงสนับสนุน']) {
  assert(sharedView.includes(`'${heading}'`), `Shared view lacks semantic heading: ${heading}`);
  assert(pdfExporter.includes(`'${heading}'`), `PDF exporter lacks semantic heading: ${heading}`);
}

const candidate0027Hash = sha256('docs/CANDIDATE_0027_ACTUAL_0035_FULL_READER_COPY.md');
assert(
  candidate0027Hash === '0c5ee0a14b5ececef6674eb1809fe7537070a1e8ef81cbb64a017b40d5e70936',
  'Historical Candidate 0027 reader copy changed.',
);

const result = {
  status: 'PASS',
  candidate: '0028',
  candidateSha256: sha256(candidatePath),
  candidate0027HistoricalSha256: candidate0027Hash,
  overviewReaderVisible: false,
  pastHeadingLayers: 1,
  pastPeriodsWithPlanet: pastHeadings.length,
  groupedCurrentDomains: currentDomains.length,
  mainChartFactRows: chartRows.length,
};
process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
