#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const args = Object.fromEntries(process.argv.slice(2).map((arg) => {
  const [key, ...rest] = arg.replace(/^--/, '').split('=');
  return [key, rest.join('=') || true];
}));

const payload = [
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.md',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md',
  'docs/THAI_PREDICTIVE_CONFLICT_REPORT_V3.json',
  'docs/THAI_PREDICTIVE_CONFLICT_REPORT_V3.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0012.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0012_UNKNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0012_CLAIM_EVIDENCE_MAP.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0012_CLAIM_EVIDENCE_MAP.md',
  'docs/CANDIDATE_0011_RECLASSIFICATION_V3.json',
  'docs/CANDIDATE_0011_RECLASSIFICATION_V3.md',
  'docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.json',
  'docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.md',
  'docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.json',
  'docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.md',
  'docs/MANUAL_AI_CONTENT_AUDIT_V3.json',
  'docs/MANUAL_AI_CONTENT_AUDIT_V3.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_NEGATIVE_CONTROLS.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_FIXTURE_SEPARATION.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_VALIDATION.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_VALIDATION.md',
];

function sha256(file) {
  return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').toUpperCase();
}

function listFiles(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const absolute = path.join(dir, entry.name);
    return entry.isDirectory()
      ? listFiles(absolute)
      : [path.relative(dir, absolute).replaceAll('\\', '/')];
  });
}

function ownerReview(shortSha) {
  return `# Owner Review — Thai Predictive Authority Foundation V3

Status: **PENDING OWNER RULEBOOK AND CONTENT REVIEW — NOT IMPLEMENTED — NOT MERGED — NOT DEPLOYED**

Evidence commit: \`${shortSha}\`

## Decision requested

ตรวจว่า Rulebook V2 ใช้หลักจากฉบับ พ.ศ. 2537 อย่างจำกัดขอบเขตและเพียงพอสำหรับ broad trend ครบ 49 contexts / 392 periods หรือไม่ จากนั้นตรวจ Candidate 0012 Known/Unknown ว่าภาษาตรง เป็นธรรมชาติ แยก prediction กับ advice และไม่ยกระดับเป็นเหตุการณ์หรือเวลาเฉพาะ

## Gate result

- source inventory 54 records และ OCR hash 308 หน้า
- reusable rules 21
- contexts with authority 49/49
- periods with authority 392/392
- forecast-only contexts 0
- contexts without authority 0
- placement promoted to prediction 0
- unresolved conflicts 0
- hidden conflicts 0
- unsupported approved claims 0
- negative controls rejected 16/16
- Candidate 0011 reclassified 26/26 reader claims
- population fixtures 49; exact and near duplicate clusters 0/0
- Manual AI Content Audit 2 รอบ × 49 contexts = 98 entries; นี่ไม่ใช่ Human Review

## Boundary

Candidate 0011 ยังคงเป็น style and structure reference ตามประวัติเดิม แต่ไม่ใช่ prediction authority, exact runtime golden หรือ fixture oracle งานนี้ไม่แก้ runtime, UI, report/export, infographic, PDF, Firebase, Production หรือ product-acceptance และไม่อ้าง predictive accuracy หรือ Owner Acceptance
`;
}

function prepare(stage, shortSha) {
  fs.mkdirSync(stage, { recursive: true });
  const owner = path.join(stage, 'OWNER_REVIEW.md');
  fs.writeFileSync(owner, ownerReview(shortSha), 'utf8');
  for (const relative of payload) {
    const source = path.join(ROOT, relative);
    const target = path.join(stage, path.basename(relative));
    if (!fs.existsSync(source)) throw new Error(`Missing payload source: ${relative}`);
    fs.copyFileSync(source, target);
  }
  const entries = listFiles(stage).sort().map((name) => {
    const absolute = path.join(stage, name);
    return { name, size: fs.statSync(absolute).size, sha256: sha256(absolute) };
  });
  const manifest = {
    version: 1,
    package: `OWNER_REVIEW_THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_${shortSha}.zip`,
    status: 'PENDING_OWNER_RULEBOOK_AND_CONTENT_REVIEW',
    manifestScopeExcludes: ['MANIFEST.json', 'SHA256SUMS.txt'],
    entries,
  };
  fs.writeFileSync(path.join(stage, 'MANIFEST.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
  const sumEntries = [...entries, {
    name: 'MANIFEST.json',
    sha256: sha256(path.join(stage, 'MANIFEST.json')),
  }];
  fs.writeFileSync(path.join(stage, 'SHA256SUMS.txt'), `${sumEntries.map((entry) => `${entry.sha256}  ${entry.name}`).join('\n')}\n`, 'utf8');
}

function validate(dir) {
  const errors = [];
  const files = listFiles(dir).sort();
  const manifest = JSON.parse(fs.readFileSync(path.join(dir, 'MANIFEST.json'), 'utf8'));
  const expected = manifest.entries.map((entry) => entry.name).sort();
  const actualScoped = files.filter((name) => !manifest.manifestScopeExcludes.includes(name));
  const missing = expected.filter((name) => !actualScoped.includes(name));
  const extra = actualScoped.filter((name) => !expected.includes(name));
  const hashSizeMismatch = [];
  for (const entry of manifest.entries) {
    const file = path.join(dir, entry.name);
    if (!fs.existsSync(file)) continue;
    if (sha256(file) !== entry.sha256 || fs.statSync(file).size !== entry.size) hashSizeMismatch.push(entry.name);
  }
  const sums = fs.readFileSync(path.join(dir, 'SHA256SUMS.txt'), 'utf8').trim().split(/\r?\n/u).map((line) => {
    const match = line.match(/^([A-F0-9]{64})  (.+)$/u);
    return match ? { sha256: match[1], name: match[2] } : null;
  });
  const sumsMismatch = sums.filter((entry) => !entry || !fs.existsSync(path.join(dir, entry.name)) || sha256(path.join(dir, entry.name)) !== entry.sha256).map((entry) => entry?.name ?? 'INVALID_LINE');
  const textFiles = files.filter((name) => /\.(?:md|json|txt)$/iu.test(name));
  const secretPatterns = [/(?:api[_-]?key|secret|password|credential)\s*[:=]\s*["'][^"']+["']/iu, /-----BEGIN [A-Z ]+PRIVATE KEY-----/u];
  const secretHits = [];
  const absolutePathHits = [];
  const placeholderHits = [];
  for (const name of textFiles) {
    const text = fs.readFileSync(path.join(dir, name), 'utf8');
    if (secretPatterns.some((pattern) => pattern.test(text))) secretHits.push(name);
    if (/(?:[A-Z]:\\|[A-Z]:\/Users\/)/u.test(text)) absolutePathHits.push(name);
    if (/(?:\.\.\.|…|\bTODO\b|\bTBD\b|<shortsha>)/iu.test(text)) placeholderHits.push(name);
  }
  errors.push(...missing.map((name) => ({ type: 'missing', name })));
  errors.push(...extra.map((name) => ({ type: 'extra', name })));
  errors.push(...hashSizeMismatch.map((name) => ({ type: 'hash_size', name })));
  errors.push(...sumsMismatch.map((name) => ({ type: 'sha256sums', name })));
  errors.push(...secretHits.map((name) => ({ type: 'secret', name })));
  errors.push(...absolutePathHits.map((name) => ({ type: 'absolute_path', name })));
  errors.push(...placeholderHits.map((name) => ({ type: 'placeholder', name })));
  return {
    status: errors.length === 0 ? 'PASS' : 'FAIL',
    files: files.length,
    manifestEntries: manifest.entries.length,
    missing: missing.length,
    extra: extra.length,
    hashSizeMismatch: hashSizeMismatch.length,
    sha256SumsMismatch: sumsMismatch.length,
    secretHits: secretHits.length,
    absoluteWindowsPathHits: absolutePathHits.length,
    placeholderOrEllipsisHits: placeholderHits.length,
    errors,
  };
}

if (args.stage) {
  if (!args['short-sha']) throw new Error('--short-sha is required with --stage');
  prepare(path.resolve(args.stage), String(args['short-sha']));
}
const validateDir = args['validate-dir'] ?? args.stage;
if (validateDir) {
  const result = validate(path.resolve(validateDir));
  console.log(JSON.stringify(result, null, 2));
  if (result.status !== 'PASS') process.exitCode = 1;
}
