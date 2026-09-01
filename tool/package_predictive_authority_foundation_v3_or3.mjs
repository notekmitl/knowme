#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const args = Object.fromEntries(process.argv.slice(2).map((arg) => { const [key, ...rest] = arg.replace(/^--/u, '').split('='); return [key, rest.join('=') || true]; }));
const payload = [
  'docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.json',
  'docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.schema.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.schema.json',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.md',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.schema.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_KNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_UNKNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.schema.json',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.json',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.md',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.schema.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_NEGATIVE_CONTROLS.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR3.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR3.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_VALIDATION.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_VALIDATION.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_DETERMINISM.json',
];
const sha = (file) => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').toUpperCase();
const listFiles = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => { const absolute = path.join(dir, entry.name); return entry.isDirectory() ? listFiles(absolute).map((name) => `${entry.name}/${name}`) : [entry.name]; });

function ownerReview(shortSha) {
  return `# Owner Review — Thai Predictive Authority Foundation V3 OR3

Status: **OWNER-AUTHORIZED SYNTHESIS FOUNDATION COMPLETE — CANDIDATE 0015 PENDING OWNER CONTENT REVIEW — DRAFT — NOT RUNTIME**

Evidence HEAD before status closeout: \`${shortSha}\`

OR2 is corrected to OCR heuristic extraction only: 197 keyword event candidates, 38 trend-marker candidates and 157 marker misses are not semantic authority counts. Generated 181-page flags are not visual review evidence. Candidate 0014 is rejected.

OR3 defines Tier A direct event, Tier B direct trend, Tier C Owner-authorized synthesis with at least two independent source-backed signals, and Tier D omission. Target 0003 pages 290–292 have specific AI visual-semantic review records; Human Review remains pending. Candidate 0015 Known has 9 prediction claims and Unknown has 0. Relationship, current health and 12-month prediction are omitted as Tier D.

Validation: 6 schemas, 8/8 real-data negative controls, 15 robustness profiles (Known 12 / Unknown 3), Tier A/B/C/D = 1/1/8/5, unsupported claims 0, exact duplicates 0, generic-template clusters 0, Known-to-Unknown leakage 0, deterministic generation 2 runs × 31 outputs mismatch 0. This package does not claim Owner Acceptance or predictive accuracy and contains no runtime, merge or deploy work.
`;
}

function validate(dir) {
  const files = listFiles(dir).sort();
  const manifest = JSON.parse(fs.readFileSync(path.join(dir, 'MANIFEST.json'), 'utf8'));
  const expected = manifest.entries.map((entry) => entry.name).sort();
  const actual = files.filter((name) => !manifest.manifestScopeExcludes.includes(name));
  const missing = expected.filter((name) => !actual.includes(name));
  const extra = actual.filter((name) => !expected.includes(name));
  const hashSizeMismatch = manifest.entries.filter((entry) => { const file = path.join(dir, entry.name); return !fs.existsSync(file) || sha(file) !== entry.sha256 || fs.statSync(file).size !== entry.size; }).map((entry) => entry.name);
  const sumMismatch = fs.readFileSync(path.join(dir, 'SHA256SUMS.txt'), 'utf8').trim().split(/\r?\n/u).filter((line) => { const match = line.match(/^([A-F0-9]{64})  (.+)$/u); return !match || !fs.existsSync(path.join(dir, match[2])) || sha(path.join(dir, match[2])) !== match[1]; });
  const secretHits = [];
  const placeholderHits = [];
  const absolutePathHits = [];
  for (const name of files.filter((file) => /\.(?:json|md|txt)$/u.test(file))) {
    const text = fs.readFileSync(path.join(dir, name), 'utf8');
    if (/(?:api[_-]?key|password|credential|secret)\s*[:=]\s*["'][^"']+["']|-----BEGIN [A-Z ]+PRIVATE KEY-----/iu.test(text)) secretHits.push(name);
    if (!name.endsWith('.json') && /(?:\bTODO\b|\bTBD\b|<shortsha>|\.\.\.|…)/iu.test(text)) placeholderHits.push(name);
    if (/(?:[A-Z]:\\|[A-Z]:\/Users\/)/u.test(text)) absolutePathHits.push(name);
  }
  const errors = { missing, extra, hashSizeMismatch, sumMismatch, secretHits, placeholderHits, absolutePathHits };
  return { status: Object.values(errors).every((items) => items.length === 0) ? 'PASS' : 'FAIL', files: files.length, manifestEntries: manifest.entries.length, missing: missing.length, extra: extra.length, hashSizeMismatch: hashSizeMismatch.length, sha256SumsMismatch: sumMismatch.length, secretHits: secretHits.length, placeholderHits: placeholderHits.length, absolutePathHits: absolutePathHits.length, errors };
}

if (args.stage) {
  if (!args['short-sha']) throw new Error('--short-sha required');
  const stage = path.resolve(args.stage);
  fs.mkdirSync(stage, { recursive: false });
  fs.writeFileSync(path.join(stage, 'OWNER_REVIEW.md'), ownerReview(String(args['short-sha'])), 'utf8');
  for (const relative of payload) { const source = path.join(ROOT, relative); if (!fs.existsSync(source)) throw new Error(`Missing payload: ${relative}`); fs.copyFileSync(source, path.join(stage, path.basename(relative))); }
  const entries = listFiles(stage).sort().map((name) => ({ name, size: fs.statSync(path.join(stage, name)).size, sha256: sha(path.join(stage, name)) }));
  const manifest = { version: 1, package: `OWNER_REVIEW_THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_${args['short-sha']}.zip`, status: 'PENDING_OWNER_CONTENT_REVIEW_NOT_RUNTIME', manifestScopeExcludes: ['MANIFEST.json', 'SHA256SUMS.txt'], entries };
  fs.writeFileSync(path.join(stage, 'MANIFEST.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
  const sums = [...entries, { name: 'MANIFEST.json', sha256: sha(path.join(stage, 'MANIFEST.json')) }];
  fs.writeFileSync(path.join(stage, 'SHA256SUMS.txt'), `${sums.map((entry) => `${entry.sha256}  ${entry.name}`).join('\n')}\n`, 'utf8');
}
if (args['validate-dir'] ?? args.stage) {
  const result = validate(path.resolve(args['validate-dir'] ?? args.stage));
  console.log(JSON.stringify(result, null, 2));
  if (result.status !== 'PASS') process.exitCode = 1;
}
