#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const args = Object.fromEntries(process.argv.slice(2).map((arg) => {
  const [key, ...rest] = arg.replace(/^--/u, '').split('=');
  return [key, rest.join('=') || true];
}));
const payload = [
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014_KNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014_UNKNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.schema.json',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.json',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.md',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.schema.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md',
  'docs/THAI_MAHABHUT_SOURCE_OCR_CORRECTIONS_OR2.json',
  'docs/THAI_MAHABHUT_SOURCE_OCR_CORRECTIONS_OR2.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.md',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.md',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR2.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR2.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_NEGATIVE_CONTROLS.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_VALIDATION.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_VALIDATION.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_DETERMINISM.json',
];
const sha = (file) => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').toUpperCase();
const listFiles = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
  const absolute = path.join(dir, entry.name);
  return entry.isDirectory() ? listFiles(absolute).map((name) => `${entry.name}/${name}`) : [entry.name];
});

function ownerReview(shortSha) {
  return `# Owner Review — Thai Predictive Authority Foundation V3 OR2

Status: **FULL 392-PERIOD REVIEW COMPLETE — SOURCE-DIRECT GAP CONFIRMED 235/392 — NO-GO — PENDING OWNER REVIEW**

Evidence HEAD before status closeout: \`${shortSha}\`

## What changed after OR1 rejection

OR1 extracted 50/392 periods, left 342 unexamined, inspected only the first period in 48 contexts, and visually checked 51/181 pages. It did not prove a source-direct gap. OR2 removes that shortcut, reviews all 392 periods and all 181 source pages, and reports only the result supported after complete review.

## Verified result

- periods examined: 392/392
- pages visually reviewed: 181/181
- direct-event periods: 197
- direct-trend-only periods: 38
- no direct statement after full review: 157
- unresolved periods/text: 0
- source-direct period coverage: 235/392
- atoms: 242
- Candidate 0014 Known/Unknown: 10/2 claims
- schemas: 6; errors 0
- negative controls: 18/18 rejected
- deterministic outputs: 23; mismatch 0

## Owner decision requested

ตรวจ ledger 392 แถว, page-review 181 หน้า, source-direct atoms และ Candidate 0014 ว่าการแบ่งช่วง/บริบทตรงต้นฉบับและไม่มีการขยายความเกินหลักฐานหรือไม่ ผล 235/392 เป็น NO-GO สำหรับ runtime implementation; งานนี้ยังไม่ implement, merge หรือ deploy และไม่อ้าง predictive accuracy หรือ Owner Acceptance.
`;
}

function prepare(stage, shortSha) {
  fs.mkdirSync(stage, { recursive: false });
  fs.writeFileSync(path.join(stage, 'OWNER_REVIEW.md'), ownerReview(shortSha), 'utf8');
  for (const relative of payload) {
    const source = path.join(ROOT, relative);
    if (!fs.existsSync(source)) throw new Error(`Missing payload: ${relative}`);
    fs.copyFileSync(source, path.join(stage, path.basename(relative)));
  }
  const entries = listFiles(stage).sort().map((name) => ({ name, size: fs.statSync(path.join(stage, name)).size, sha256: sha(path.join(stage, name)) }));
  const manifest = { version: 1, package: `OWNER_REVIEW_THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_${shortSha}.zip`, status: 'PENDING_OWNER_REVIEW_SOURCE_DIRECT_GAP_NO_GO', manifestScopeExcludes: ['MANIFEST.json', 'SHA256SUMS.txt'], entries };
  fs.writeFileSync(path.join(stage, 'MANIFEST.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
  const sums = [...entries, { name: 'MANIFEST.json', sha256: sha(path.join(stage, 'MANIFEST.json')) }];
  fs.writeFileSync(path.join(stage, 'SHA256SUMS.txt'), `${sums.map((entry) => `${entry.sha256}  ${entry.name}`).join('\n')}\n`, 'utf8');
}

function validate(dir) {
  const files = listFiles(dir).sort();
  const manifest = JSON.parse(fs.readFileSync(path.join(dir, 'MANIFEST.json'), 'utf8'));
  const expected = manifest.entries.map((entry) => entry.name).sort();
  const actual = files.filter((name) => !manifest.manifestScopeExcludes.includes(name));
  const missing = expected.filter((name) => !actual.includes(name));
  const extra = actual.filter((name) => !expected.includes(name));
  const hashSizeMismatch = manifest.entries.filter((entry) => {
    const file = path.join(dir, entry.name);
    return !fs.existsSync(file) || sha(file) !== entry.sha256 || fs.statSync(file).size !== entry.size;
  }).map((entry) => entry.name);
  const sumLines = fs.readFileSync(path.join(dir, 'SHA256SUMS.txt'), 'utf8').trim().split(/\r?\n/u);
  const sha256SumsMismatch = sumLines.filter((line) => {
    const match = line.match(/^([A-F0-9]{64})  (.+)$/u);
    return !match || !fs.existsSync(path.join(dir, match[2])) || sha(path.join(dir, match[2])) !== match[1];
  });
  const textFiles = files.filter((name) => /\.(?:json|md|txt)$/iu.test(name));
  const secretHits = [];
  const placeholderHits = [];
  const absolutePathHits = [];
  for (const name of textFiles) {
    const text = fs.readFileSync(path.join(dir, name), 'utf8');
    if (/(?:api[_-]?key|password|credential|secret)\s*[:=]\s*["'][^"']+["']|-----BEGIN [A-Z ]+PRIVATE KEY-----/iu.test(text)) secretHits.push(name);
    if (/(?:[A-Z]:\\|[A-Z]:\/Users\/)/u.test(text)) absolutePathHits.push(name);
    if (!name.endsWith('.json') && /(?:\bTODO\b|\bTBD\b|<shortsha>|\.\.\.|…)/iu.test(text)) placeholderHits.push(name);
  }
  const result = { status: 'PASS', files: files.length, manifestEntries: manifest.entries.length, missing: missing.length, extra: extra.length, hashSizeMismatch: hashSizeMismatch.length, sha256SumsMismatch: sha256SumsMismatch.length, secretHits: secretHits.length, placeholderHits: placeholderHits.length, absolutePathHits: absolutePathHits.length, errors: [] };
  for (const [type, values] of Object.entries({ missing, extra, hashSizeMismatch, sha256SumsMismatch, secretHits, placeholderHits, absolutePathHits })) result.errors.push(...values.map((name) => ({ type, name })));
  if (result.errors.length) result.status = 'FAIL';
  return result;
}

if (args.stage) {
  if (!args['short-sha']) throw new Error('--short-sha required');
  prepare(path.resolve(args.stage), String(args['short-sha']));
}
if (args['validate-dir'] ?? args.stage) {
  const result = validate(path.resolve(args['validate-dir'] ?? args.stage));
  console.log(JSON.stringify(result, null, 2));
  if (result.status !== 'PASS') process.exitCode = 1;
}
