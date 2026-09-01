#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const args = Object.fromEntries(process.argv.slice(2).map((arg) => { const [key, ...rest] = arg.replace(/^--/u, '').split('='); return [key, rest.join('=') || true]; }));
const payload = [
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_KNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_UNKNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_KNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_UNKNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_TO_0016_BEFORE_AFTER.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.md',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.md',
  'docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.json',
  'docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.md',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.json',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_NEGATIVE_CONTROLS.json',
  'docs/DETERMINISTIC_MACHINE_CONTENT_AUDIT_OR4.json',
  'docs/DETERMINISTIC_MACHINE_CONTENT_AUDIT_OR4.md',
  'docs/CODEX_EDITORIAL_REVIEW_CANDIDATE_0016_OR4.json',
  'docs/CODEX_EDITORIAL_REVIEW_CANDIDATE_0016_OR4.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_VALIDATION.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_VALIDATION.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_DETERMINISM.json',
];
const sha = (file) => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').toUpperCase();
const listFiles = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => { const absolute = path.join(dir, entry.name); return entry.isDirectory() ? listFiles(absolute).map((name) => `${entry.name}/${name}`) : [entry.name]; });

const ownerReview = (shortSha) => `# Owner Review — Thai Predictive Authority Foundation V3 OR4\n\nStatus: **EVIDENCE MODEL REPAIRED — PRODUCT CONTENT STILL NO-GO — CANDIDATE 0016 PENDING OWNER CONTENT REVIEW — DRAFT — NOT RUNTIME**\n\nEvidence HEAD before audit/status closeout: \`${shortSha}\`. OR3 architecture direction remains accepted, but Candidate 0015, its authored independent counts, preset robustness and static two-pass audit are rejected.\n\nOR4 recomputes evidence owners, applies rule-specific domain/period/polarity/timing/causal gates and rejects 14/14 controls. Candidate 0016 Known has 6 predictions (Tier A/B/C = 4/2/0); Unknown has 0 and remains fail-closed. The full secondary-source review found domain definitions and an annual method but no target-specific applicability for relationship, health or 12 months, so those sections and the placement-only next period remain Tier D.\n\nReal robustness uses 15 fixture inputs without expected tier or copy. The selector generated 13 claims; A/B/C/D = 3/2/0/10; unsupported 0; conflict narrowed 1; Unknown leakage 0; hardcoded counters 0. The machine audit covers only computable properties. The Codex editorial review is paragraph-level; Owner Human Review remains PENDING. No runtime, merge, deploy, Firebase/Production, predictive-accuracy or product-acceptance change is included.\n`;

function validate(dir) {
  const files = listFiles(dir).sort();
  const manifest = JSON.parse(fs.readFileSync(path.join(dir, 'MANIFEST.json'), 'utf8'));
  const expected = manifest.entries.map((entry) => entry.name).sort();
  const actual = files.filter((name) => !manifest.manifestScopeExcludes.includes(name));
  const missing = expected.filter((name) => !actual.includes(name));
  const extra = actual.filter((name) => !expected.includes(name));
  const hashSizeMismatch = manifest.entries.filter((entry) => { const file = path.join(dir, entry.name); return !fs.existsSync(file) || sha(file) !== entry.sha256 || fs.statSync(file).size !== entry.size; }).map((entry) => entry.name);
  const sumMismatch = fs.readFileSync(path.join(dir, 'SHA256SUMS.txt'), 'utf8').trim().split(/\r?\n/u).filter((line) => { const match = line.match(/^([A-F0-9]{64})  (.+)$/u); return !match || !fs.existsSync(path.join(dir, match[2])) || sha(path.join(dir, match[2])) !== match[1]; });
  const secretHits = [], placeholderHits = [], absolutePathHits = [];
  for (const name of files.filter((file) => /\.(?:json|md|txt)$/u.test(file))) {
    const text = fs.readFileSync(path.join(dir, name), 'utf8');
    if (/(?:api[_-]?key|password|credential|secret)\s*[:=]\s*["'][^"']+["']|-----BEGIN [A-Z ]+PRIVATE KEY-----/iu.test(text)) secretHits.push(name);
    if (!name.endsWith('.json') && /(?:\bTODO\b|\bTBD\b|<shortsha>|\.\.\.|…)/iu.test(text)) placeholderHits.push(name);
    if (/(?:[A-Z]:\\|[A-Z]:\/Users\/)/u.test(text)) absolutePathHits.push(name);
  }
  const errors = { missing, extra, hashSizeMismatch, sumMismatch, secretHits, placeholderHits, absolutePathHits };
  return { status: Object.values(errors).every((items) => items.length === 0) ? 'PASS' : 'FAIL', files: files.length, manifestEntries: manifest.entries.length, counts: { missing: missing.length, extra: extra.length, hashSizeMismatch: hashSizeMismatch.length, sha256SumsMismatch: sumMismatch.length, secretHits: secretHits.length, placeholderHits: placeholderHits.length, absolutePathHits: absolutePathHits.length }, errors };
}

if (args.stage) {
  if (!args['short-sha']) throw new Error('--short-sha required');
  const stage = path.resolve(args.stage);
  fs.mkdirSync(stage, { recursive: false });
  fs.writeFileSync(path.join(stage, 'OWNER_REVIEW.md'), ownerReview(String(args['short-sha'])), 'utf8');
  for (const relative of payload) { const source = path.join(ROOT, relative); if (!fs.existsSync(source)) throw new Error(`Missing payload: ${relative}`); fs.copyFileSync(source, path.join(stage, path.basename(relative))); }
  const entries = listFiles(stage).sort().map((name) => ({ name, size: fs.statSync(path.join(stage, name)).size, sha256: sha(path.join(stage, name)) }));
  const manifest = { version: 1, package: `OWNER_REVIEW_THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_${args['short-sha']}.zip`, status: 'PRODUCT_CONTENT_STILL_NO_GO_PENDING_OWNER_CONTENT_REVIEW_NOT_RUNTIME', manifestScopeExcludes: ['MANIFEST.json', 'SHA256SUMS.txt'], entries };
  fs.writeFileSync(path.join(stage, 'MANIFEST.json'), `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
  const sums = [...entries, { name: 'MANIFEST.json', sha256: sha(path.join(stage, 'MANIFEST.json')) }];
  fs.writeFileSync(path.join(stage, 'SHA256SUMS.txt'), `${sums.map((entry) => `${entry.sha256}  ${entry.name}`).join('\n')}\n`, 'utf8');
}
if (args['validate-dir'] ?? args.stage) {
  const result = validate(path.resolve(args['validate-dir'] ?? args.stage));
  console.log(JSON.stringify(result, null, 2));
  if (result.status !== 'PASS') process.exitCode = 1;
}
