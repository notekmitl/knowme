#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = process.cwd();
const outputs = [
  'docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.json',
  'docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.json',
  'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.md',
  'knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.json',
  'knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.md',
  'knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.schema.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.schema.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.schema.json',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.md',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.schema.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.schema.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_KNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_UNKNOWN.md',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.json',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.md',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.schema.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR3.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR3.md',
];
const builders = [
  'tool/build_predictive_authority_foundation_v3_or3_contract.mjs',
  'tool/build_predictive_authority_foundation_v3_or3_candidate.mjs',
  'tool/build_predictive_authority_foundation_v3_or3_robustness.mjs',
  'tool/build_predictive_authority_foundation_v3_or3_audit.mjs',
];
const hash = (file) => crypto.createHash('sha256').update(fs.readFileSync(path.join(ROOT, file))).digest('hex').toUpperCase();
const snapshot = () => Object.fromEntries(outputs.map((file) => [file, hash(file)]));
const run = () => builders.map((builder) => spawnSync(process.execPath, [builder], { cwd: ROOT, encoding: 'utf8' }));
const before = snapshot();
const firstRuns = run();
const first = snapshot();
const secondRuns = run();
const second = snapshot();
const mismatches = outputs.filter((file) => before[file] !== first[file] || first[file] !== second[file]);
const executionErrors = [...firstRuns, ...secondRuns].filter((result) => result.status !== 0).map((result) => result.stderr || result.stdout);
const result = { version: 1, status: mismatches.length === 0 && executionErrors.length === 0 ? 'PASS' : 'FAIL', generatedAt: '2026-09-01T00:00:00+07:00', runs: 2, builders: builders.length, outputs: outputs.length, mismatchCount: mismatches.length, mismatches, executionErrorCount: executionErrors.length, hashes: second };
fs.writeFileSync(path.join(ROOT, 'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_DETERMINISM.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
console.log(JSON.stringify(result, null, 2));
if (result.status !== 'PASS') process.exitCode = 1;
