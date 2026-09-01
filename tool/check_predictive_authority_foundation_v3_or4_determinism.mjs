#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = process.cwd();
const outputs = [
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.md',
  'knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.json',
  'knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.md',
  'docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.json',
  'docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_KNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_UNKNOWN.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_TO_0016_BEFORE_AFTER.md',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.json',
  'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.md',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_NEGATIVE_CONTROLS.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_VALIDATION.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_VALIDATION.md',
  'docs/DETERMINISTIC_MACHINE_CONTENT_AUDIT_OR4.json',
  'docs/DETERMINISTIC_MACHINE_CONTENT_AUDIT_OR4.md',
];
const builders = [
  ['tool/build_predictive_authority_foundation_v3_or4_model.mjs'],
  ['tool/build_predictive_authority_foundation_v3_or4_candidate.mjs'],
  ['tool/build_predictive_authority_foundation_v3_or4_audit.mjs'],
  ['tool/validate_predictive_authority_foundation_v3_or4.mjs', '--full'],
];
const hash = (file) => crypto.createHash('sha256').update(fs.readFileSync(path.join(ROOT, file))).digest('hex').toUpperCase();
const snapshot = () => Object.fromEntries(outputs.map((file) => [file, hash(file)]));
const execute = () => builders.map(([script, ...args]) => spawnSync(process.execPath, [script, ...args], { cwd: ROOT, encoding: 'utf8' }));
const before = snapshot();
const firstRuns = execute();
const first = snapshot();
const secondRuns = execute();
const second = snapshot();
const mismatches = outputs.filter((file) => before[file] !== first[file] || first[file] !== second[file]);
const executionErrors = [...firstRuns, ...secondRuns].filter((result) => result.status !== 0).map((result) => result.stderr || result.stdout);
const result = { version: 1, status: mismatches.length === 0 && executionErrors.length === 0 ? 'PASS' : 'FAIL', generatedAt: '2026-09-01T00:00:00+07:00', runs: 2, builders: builders.length, outputs: outputs.length, mismatchCount: mismatches.length, mismatches, executionErrorCount: executionErrors.length, hashes: second };
fs.writeFileSync(path.join(ROOT, 'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR4_DETERMINISM.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
console.log(JSON.stringify(result, null, 2));
if (result.status !== 'PASS') process.exitCode = 1;
