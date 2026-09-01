#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = process.cwd();
const ocrDir = process.argv.find((arg) => arg.startsWith('--ocr-dir='))?.slice(10) ?? 'D:/MahabhutOCR/txt';
const files = [
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json',
  'knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json',
  'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md',
  'docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.json',
  'docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.md',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0013_CLAIM_EVIDENCE_MAP.json',
  'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0013.md',
  'docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW.json',
  'docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW.md',
];
const hash = (file) => crypto.createHash('sha256').update(fs.readFileSync(path.join(ROOT, file))).digest('hex').toUpperCase();
const run = () => spawnSync(process.execPath, ['tool/build_predictive_authority_foundation_v3_or1.mjs', `--ocr-dir=${ocrDir}`], { cwd: ROOT, encoding: 'utf8' });
const first = run();
const firstHashes = Object.fromEntries(files.map((file) => [file, hash(file)]));
const second = run();
const secondHashes = Object.fromEntries(files.map((file) => [file, hash(file)]));
const mismatches = files.filter((file) => firstHashes[file] !== secondHashes[file]);
const result = { version: 1, status: first.status === 0 && second.status === 0 && mismatches.length === 0 ? 'PASS' : 'FAIL', runs: 2, filesCompared: files.length, mismatchCount: mismatches.length, mismatches, firstExitCode: first.status, secondExitCode: second.status };
fs.writeFileSync(path.join(ROOT, 'docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_DETERMINISM.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
console.log(JSON.stringify(result, null, 2));
process.exitCode = result.status === 'PASS' ? 0 : 1;
