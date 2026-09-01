#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { buildOracle, ORACLE_PATH, parseClaims, readerBlock, SOURCE_PATH } from './build_candidate_0011_or7_oracle.mjs';

const ROOT = process.cwd();
const clone = (value) => structuredClone(value);
const load = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));

export function validateOracle(candidate = load(ORACLE_PATH), options = {}) {
  const expected = buildOracle();
  const errors = [];
  const add = (code, detail = '') => errors.push({ code, detail });
  if (candidate.source?.repositoryPath !== SOURCE_PATH) add('SOURCE_PATH_MISMATCH');
  if (candidate.source?.acceptedHead !== expected.source.acceptedHead || candidate.source?.mergeSha !== expected.source.mergeSha) add('ACCEPTANCE_REFERENCE_MISMATCH');
  if (candidate.source?.acceptedReaderFacingSha256 !== expected.source.acceptedReaderFacingSha256) add('READER_HASH_MISMATCH');
  if (JSON.stringify(candidate.sectionOrder) !== JSON.stringify(expected.sectionOrder)) add('SECTION_ORDER_MISMATCH');
  if (JSON.stringify(candidate.claimOrder) !== JSON.stringify(expected.claimOrder)) add('CLAIM_ORDER_MISMATCH');
  if (JSON.stringify((candidate.claims ?? []).map((claim) => claim.readerClaimId)) !== JSON.stringify(candidate.claimOrder)) add('CLAIM_ARRAY_ORDER_MISMATCH');
  if (candidate.counts?.predictionParagraphs !== 22 || candidate.counts?.claims !== 24 || candidate.counts?.adviceAndDisclosure !== 2) add('CLAIM_COUNT_MISMATCH');
  const expectedById = new Map(expected.claims.map((claim) => [claim.readerClaimId, claim]));
  for (const claim of candidate.claims ?? []) {
    const reference = expectedById.get(claim.readerClaimId);
    if (!reference) { add('READER_CLAIM_ID_MISMATCH', claim.readerClaimId); continue; }
    if (claim.exactText !== reference.exactText) add('EXACT_TEXT_MISMATCH', claim.readerClaimId);
    if (claim.section !== reference.section || claim.surface !== reference.surface) add('CLAIM_LOCATION_MISMATCH', claim.readerClaimId);
    if (claim.claimKind !== reference.claimKind) add('CLAIM_KIND_MISMATCH', claim.readerClaimId);
    const allowed = ['SOURCE_DIRECT', 'SOURCE_DIRECTION_WITH_CANON_DOMAIN', 'OWNER_ACCEPTED_PRODUCT_INTERPRETATION', 'ADVICE', 'DISCLOSURE'];
    if (!allowed.includes(claim.authorityClass)) add('AUTHORITY_CLASS_INVALID', claim.readerClaimId);
    if (claim.authorityClass === 'OWNER_ACCEPTED_PRODUCT_INTERPRETATION' && !claim.acceptanceReference?.acceptedHead) add('OWNER_ACCEPTANCE_REFERENCE_MISSING', claim.readerClaimId);
    if ((claim.authorityClass === 'SOURCE_DIRECT' || claim.authorityClass === 'SOURCE_DIRECTION_WITH_CANON_DOMAIN') && !claim.sourceAuthorityReference) add('SOURCE_AUTHORITY_REFERENCE_MISSING', claim.readerClaimId);
    if (claim.authorityClass === 'ADVICE' && claim.claimKind !== 'ADVICE') add('PREDICTION_RECLASSIFIED_AS_ADVICE', claim.readerClaimId);
  }
  if ((candidate.claims ?? []).length !== expected.claims.length) add('CLAIM_COUNT_MISMATCH');
  if (options.candidateId && options.candidateId !== '0011') add('WRONG_ORACLE_CANDIDATE', options.candidateId);
  if (options.typedAsOfMismatch === true && options.hasEquivalenceProof !== true) add('ASOF_EQUIVALENCE_PROOF_MISSING');
  return { status: errors.length === 0 ? 'PASS_CANDIDATE_0011_EXACT_ORACLE' : 'FAIL', errors };
}

export function runOr7NegativeControls() {
  const base = load(ORACLE_PATH);
  const controls = [];
  const run = (id, expectedCode, mutate, options = {}) => {
    const candidate = clone(base);
    mutate(candidate);
    const result = validateOracle(candidate, options);
    controls.push({ id, expectedCode, rejected: result.errors.some((error) => error.code === expectedCode), observedCodes: [...new Set(result.errors.map((error) => error.code))] });
  };
  run('delete-paragraph', 'CLAIM_COUNT_MISMATCH', (value) => { value.claims.splice(3, 1); });
  run('paraphrase-paragraph', 'EXACT_TEXT_MISMATCH', (value) => { value.claims[1].exactText += ' '; });
  run('reorder-claims', 'CLAIM_ARRAY_ORDER_MISMATCH', (value) => { [value.claims[1], value.claims[2]] = [value.claims[2], value.claims[1]]; });
  run('reorder-sections', 'SECTION_ORDER_MISMATCH', (value) => { [value.sectionOrder[1], value.sectionOrder[2]] = [value.sectionOrder[2], value.sectionOrder[1]]; });
  run('date-change', 'EXACT_TEXT_MISMATCH', (value) => { const claim = value.claims.find((row) => row.readerClaimId === 'RC11-K-HORIZON-01'); claim.exactText = claim.exactText.replace('29 สิงหาคม 2569', '30 สิงหาคม 2569'); });
  run('reader-claim-id-change', 'READER_CLAIM_ID_MISMATCH', (value) => { value.claims[0].readerClaimId = 'RC11-K-ALTERED'; });
  run('candidate-0018-as-oracle', 'CLAIM_COUNT_MISMATCH', (value) => {
    const candidate18 = load('docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.json').known.claims.filter((claim) => claim.classification === 'PREDICTION');
    value.candidateId = '0018';
    value.claims = candidate18.map((claim) => ({ readerClaimId: claim.claimId, surface: 'Known', section: claim.section, claimKind: 'PREDICTION', authorityClass: 'OWNER_ACCEPTED_PRODUCT_INTERPRETATION', exactText: claim.fullReaderText, acceptanceReference: null }));
    value.claimOrder = value.claims.map((claim) => claim.readerClaimId);
    value.counts.claims = value.claims.length;
    value.counts.predictionParagraphs = value.claims.length;
  });
  run('prediction-to-common-sense-measurement', 'EXACT_TEXT_MISMATCH', (value) => { value.claims[8].exactText = 'ให้ดูผลลัพธ์ที่เกิดขึ้นจริงก่อนตัดสินใจ'; });
  run('prediction-to-advice', 'PREDICTION_RECLASSIFIED_AS_ADVICE', (value) => { value.claims[2].authorityClass = 'ADVICE'; });
  run('authority-without-acceptance-reference', 'OWNER_ACCEPTANCE_REFERENCE_MISSING', (value) => { value.claims[4].acceptanceReference = null; });
  run('unsupported-source-authority-class', 'SOURCE_AUTHORITY_REFERENCE_MISSING', (value) => { value.claims[5].authorityClass = 'SOURCE_DIRECT'; value.claims[5].acceptanceReference = null; });
  run('owner-unaccepted-added-text', 'CLAIM_COUNT_MISMATCH', (value) => { value.claims.push({ ...value.claims[0], readerClaimId: 'RC11-K-ADDED-UNACCEPTED' }); });
  run('typed-asof-mismatch-without-proof', 'ASOF_EQUIVALENCE_PROOF_MISSING', () => {}, { typedAsOfMismatch: true, hasEquivalenceProof: false });
  return controls;
}

export function validateCurrentSourceBoundary() {
  const source = fs.readFileSync(path.join(ROOT, SOURCE_PATH), 'utf8');
  const parsed = parseClaims(source);
  return { readerFacingCharacters: readerBlock(source).length, claims: parsed.claims.length, sections: parsed.sectionOrder.length };
}

export function validationReport() {
  const result = validateOracle();
  const controls = runOr7NegativeControls();
  return {
    status: result.status === 'PASS_CANDIDATE_0011_EXACT_ORACLE' && controls.every((control) => control.rejected) ? 'PASS_CANDIDATE_0011_OR7_ORACLE_AND_NEGATIVE_CONTROLS' : 'FAIL',
    counts: {
      claims: load(ORACLE_PATH).counts.claims,
      predictionParagraphs: load(ORACLE_PATH).counts.predictionParagraphs,
      negativeControls: controls.length,
      negativeControlsRejected: controls.filter((control) => control.rejected).length,
      errors: result.errors.length,
    },
    sourceBoundary: validateCurrentSourceBoundary(),
    errors: result.errors,
    negativeControls: controls,
  };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const report = validationReport();
  fs.writeFileSync(path.join(ROOT, 'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE_VALIDATION.json'), `${JSON.stringify(report, null, 2)}\n`, 'utf8');
  process.stdout.write(`${JSON.stringify(report.counts)}\n`);
  if (report.status === 'FAIL') process.exitCode = 1;
}
