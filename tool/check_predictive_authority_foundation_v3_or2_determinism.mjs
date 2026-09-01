#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = process.cwd();
const outputs = [
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.schema.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.md',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.schema.json',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.json',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014_KNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014_UNKNOWN.md',
  'docs/THAI_MAHABHUT_SOURCE_OCR_CORRECTIONS_OR2.json',
  'docs/THAI_MAHABHUT_SOURCE_OCR_CORRECTIONS_OR2.md',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR2.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR2.md',
];
const sha = (file) => crypto.createHash('sha256').update(fs.readFileSync(path.join(ROOT, file))).digest('hex').toUpperCase();
const run = () => {
  const result = spawnSync(process.execPath, ['tool/build_predictive_authority_foundation_v3_or2.mjs'], { cwd: ROOT, encoding: 'utf8' });
  if (result.status !== 0) throw new Error(result.stderr || result.stdout);
  return Object.fromEntries(outputs.map((file) => [file, sha(file)]));
};
const first = run();
const second = run();
const mismatches = outputs.filter((file) => first[file] !== second[file]);
const report = { version: 1, status: mismatches.length ? 'FAIL' : 'PASS', generatedAt: '2026-09-01T00:00:00+07:00', outputs: outputs.length, mismatches, hashes: second };
fs.writeFileSync(path.join(ROOT, 'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_DETERMINISM.json'), `${JSON.stringify(report, null, 2)}\n`, 'utf8');
console.log(JSON.stringify(report, null, 2));
process.exitCode = mismatches.length ? 1 : 0;
