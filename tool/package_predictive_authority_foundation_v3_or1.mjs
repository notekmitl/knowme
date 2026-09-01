#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = process.cwd();
const shortSha = process.argv.find((arg) => arg.startsWith('--short-sha='))?.slice(12);
if (!shortSha || !/^[a-f0-9]{7,12}$/u.test(shortSha)) throw new Error('Pass --short-sha=<7-12 lowercase hex>');
const packageName = `OWNER_REVIEW_THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_${shortSha}`;
const staging = path.join(ROOT, `.tmp_${packageName}`);
const zipPath = path.resolve(ROOT, '..', `${packageName}.zip`);
if (fs.existsSync(zipPath)) throw new Error(`Refusing to overwrite existing package: ${zipPath}`);
if (fs.existsSync(staging)) fs.rmSync(staging, { recursive: true, force: true });
fs.mkdirSync(staging, { recursive: true });

const payload = [
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0013.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0013_CLAIM_EVIDENCE_MAP.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.schema.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.schema.json',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.schema.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md',
  'docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.json',
  'docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_NEGATIVE_CONTROLS.json',
  'docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.json',
  'docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.md',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_VALIDATION.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_VALIDATION.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_DETERMINISM.json',
];
const sha = (buffer) => crypto.createHash('sha256').update(buffer).digest('hex').toUpperCase();
for (const source of payload) {
  const destination = path.join(staging, source);
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.copyFileSync(path.join(ROOT, source), destination);
}

const ownerReview = `# PR114 OR1 Owner Review

Status: **SOURCE-DIRECT AUTHORITY GAP CONFIRMED — NO-GO**

## ข้อเท็จจริงสำคัญ

- placement table: 49/49 contexts, 392/392 periods
- broad direction: 49/49 contexts, 392/392 periods
- source-direct event: 49/49 contexts, 50/392 periods
- domain-complete contexts: 0/49
- source-direct atoms: 56
- PDF source SHA-256: 28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E
- เปิดตรวจภาพหน้าตั้งต้นครบ 49 contexts และหน้า 291–292; ไม่อ้างว่าเปิดภาพครบทุกหน้าในช่วง
- OCR mismatch 8 รายการได้รับการยืนยัน transcription จากภาพ; unresolved text = 0
- Candidate 0013 เป็น evidence candidate เท่านั้น ไม่ใช่ runtime implementation
- Owner Human Review: PENDING

## สิ่งที่ต้องตรวจ

1. ตัวเลข 392/392 ถูกเรียกเฉพาะ placement/broad-direction ไม่ใช่ full predictive authority
2. event atoms ผูก source/page/OCR span/context/period/planet/role/house/domain/event family จริง
3. Candidate 0013 ตัด generic filler และเว้น heading ที่ authority ไม่รองรับ
4. Unknown ไม่แทนเวลาเที่ยง ไม่สร้างลัคนา เรือน หรือวันโหราศาสตร์ไทย
5. Before/After PAST-02 และ PAST-04 ตรงอายุและ section
6. AI audit ระบุชัดว่าไม่ใช่ Human Review

ไม่แก้ runtime, Flutter, Firebase, Production หรือ product-acceptance/ และยังไม่ Merge/Deploy
`;
fs.writeFileSync(path.join(staging, 'OWNER_REVIEW.md'), ownerReview, 'utf8');

const allPayload = ['OWNER_REVIEW.md', ...payload];
const entries = allPayload.map((file) => {
  const buffer = fs.readFileSync(path.join(staging, file));
  return { path: file.replaceAll('\\', '/'), size: buffer.length, sha256: sha(buffer) };
});
const manifest = { version: 1, packageName, status: 'NO_GO_PENDING_OWNER_REVIEW', fileCount: entries.length, entries };
fs.writeFileSync(path.join(staging, 'MANIFEST.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
const sumsEntries = [...entries, { path: 'MANIFEST.json', size: fs.statSync(path.join(staging, 'MANIFEST.json')).size, sha256: sha(fs.readFileSync(path.join(staging, 'MANIFEST.json'))) }];
fs.writeFileSync(path.join(staging, 'SHA256SUMS.txt'), `${sumsEntries.map((entry) => `${entry.sha256}  ${entry.path}`).join('\n')}\n`, 'utf8');

const files = [];
const walk = (dir, prefix = '') => {
  for (const name of fs.readdirSync(dir).sort()) {
    const absolute = path.join(dir, name);
    const relative = path.join(prefix, name).replaceAll('\\', '/');
    if (fs.statSync(absolute).isDirectory()) walk(absolute, relative); else files.push(relative);
  }
};
walk(staging);
const expected = [...allPayload, 'MANIFEST.json', 'SHA256SUMS.txt'].map((file) => file.replaceAll('\\', '/')).sort();
const missing = expected.filter((file) => !files.includes(file));
const extra = files.filter((file) => !expected.includes(file));
const hashMismatches = entries.filter((entry) => sha(fs.readFileSync(path.join(staging, entry.path))) !== entry.sha256);
const text = files.filter((file) => /\.(?:md|json|txt)$/u.test(file)).map((file) => fs.readFileSync(path.join(staging, file), 'utf8')).join('\n');
const secretPatterns = [/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/u, /AIza[0-9A-Za-z_-]{30,}/u, /password\s*[:=]\s*[^\s]+/iu];
const secretHits = secretPatterns.filter((pattern) => pattern.test(text)).length;
const placeholderHits = (text.match(/\b(?:TODO|TBD|PLACEHOLDER)\b/giu) ?? []).length;
const absolutePathHits = (text.match(/\b[A-Z]:\\[^\s"']+/gu) ?? []).length;
const preZip = { missingCount: missing.length, extraCount: extra.length, hashMismatchCount: hashMismatches.length, secretHitCount: secretHits, placeholderHitCount: placeholderHits, absolutePathErrorCount: absolutePathHits };
if (Object.values(preZip).some((value) => value !== 0)) throw new Error(`Package preflight failed: ${JSON.stringify(preZip)}`);

const archive = spawnSync('tar.exe', ['-a', '-c', '-f', zipPath, '-C', staging, '.'], { encoding: 'utf8' });
if (archive.status !== 0) throw new Error(`ZIP creation failed: ${archive.stderr}`);

const extract = `${staging}_extract`;
if (fs.existsSync(extract)) fs.rmSync(extract, { recursive: true, force: true });
fs.mkdirSync(extract, { recursive: true });
const extraction = spawnSync('tar.exe', ['-x', '-f', zipPath, '-C', extract], { encoding: 'utf8' });
if (extraction.status !== 0) throw new Error(`ZIP CRC/extraction failed: ${extraction.stderr}`);
const extractedFiles = [];
const walkExtract = (dir, prefix = '') => {
  for (const name of fs.readdirSync(dir).sort()) {
    const absolute = path.join(dir, name);
    const relative = path.join(prefix, name).replaceAll('\\', '/');
    if (fs.statSync(absolute).isDirectory()) walkExtract(absolute, relative); else extractedFiles.push(relative);
  }
};
walkExtract(extract);
const extractedMissing = expected.filter((file) => !extractedFiles.includes(file));
const extractedExtra = extractedFiles.filter((file) => !expected.includes(file));
const extractedHashMismatch = entries.filter((entry) => sha(fs.readFileSync(path.join(extract, entry.path))) !== entry.sha256);
const result = {
  version: 1,
  status: extractedMissing.length === 0 && extractedExtra.length === 0 && extractedHashMismatch.length === 0 ? 'PASS' : 'FAIL',
  packageName,
  zipPath,
  zipSha256: sha(fs.readFileSync(zipPath)),
  zipSize: fs.statSync(zipPath).size,
  crcExtractionPass: extraction.status === 0,
  manifestEntries: entries.length,
  missingCount: extractedMissing.length,
  extraCount: extractedExtra.length,
  hashMismatchCount: extractedHashMismatch.length,
  secretHitCount: secretHits,
  placeholderHitCount: placeholderHits,
  absolutePathErrorCount: absolutePathHits,
};
fs.writeFileSync(path.join(ROOT, 'docs/OWNER_REVIEW_PR114_OR1_PACKAGE_VALIDATION.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
fs.rmSync(staging, { recursive: true, force: true });
fs.rmSync(extract, { recursive: true, force: true });
console.log(JSON.stringify(result, null, 2));
process.exitCode = result.status === 'PASS' ? 0 : 1;
