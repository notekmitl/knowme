#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { validateEvidenceRegistry } from './validate_thai_predictive_evidence_v1.mjs';

const ROOT = process.cwd();
const load = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));

export function validateCandidate0011RuleMap() {
  const map = load('docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json');
  const oracle = load('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
  const asOf = load('docs/CANDIDATE_0011_ASOF_EQUIVALENCE_VALIDATION.json');
  const errors = [];
  const add = (code, detail = '') => errors.push({ code, detail });
  const oraclePredictions = oracle.claims.filter((claim) => claim.claimKind === 'PREDICTION');
  if (map.claims.length !== 22 || oraclePredictions.length !== 22) add('PREDICTION_COUNT_MISMATCH');
  const roles = ['selectorRefs', 'domainRefs', 'directionRefs', 'timingRefs', 'conflictRefs', 'certaintyRefs'];
  for (let index = 0; index < oraclePredictions.length; index += 1) {
    const claim = map.claims[index];
    const expected = oraclePredictions[index];
    if (claim.readerClaimId !== expected.readerClaimId) add('CLAIM_ORDER_MISMATCH', expected.readerClaimId);
    if (claim.exactAcceptedText !== expected.exactText) add('EXACT_ACCEPTED_TEXT_MISMATCH', expected.readerClaimId);
    if (!claim.ownerAcceptanceRef || claim.authorityClass !== 'OWNER_ACCEPTED_PRODUCT_INTERPRETATION') add('ACCEPTANCE_AUTHORITY_MISSING', expected.readerClaimId);
    if (!Array.isArray(claim.prohibitedExtrapolations) || claim.prohibitedExtrapolations.length === 0) add('PROHIBITED_EXTRAPOLATIONS_MISSING', expected.readerClaimId);
    for (const role of roles) {
      if (!Array.isArray(claim[role]) || claim[role].length === 0) add('CHAIN_COMPONENT_MISSING', `${expected.readerClaimId}:${role}`);
      for (const ref of claim[role] ?? []) if (!map.resolvedReferenceIndex[ref]) add('UNRESOLVED_REFERENCE', `${expected.readerClaimId}:${ref}`);
    }
    if (claim.gapStatus !== 'COMPLETE') add('RULE_MAP_GAP', expected.readerClaimId);
  }
  const registry = validateEvidenceRegistry();
  if (registry.status !== 'PASS_THAI_PREDICTIVE_EVIDENCE_V1') add('EVIDENCE_RESOLVER_REGRESSION', registry.status);
  if (asOf.status !== 'PASS_ACTUAL_GENERATOR_ASOF_EQUIVALENCE' || asOf.counts.invariantMismatches !== 0 || asOf.counts.forecastMaterialMismatches !== 0) add('ASOF_EQUIVALENCE_FAILED');
  return {
    status: errors.length === 0 ? 'PASS_CANDIDATE_0011_RULE_MAP_AND_ASOF' : 'FAIL',
    counts: {
      predictionParagraphs: map.claims.length,
      completeChains: map.claims.filter((claim) => claim.gapStatus === 'COMPLETE').length,
      chainsWithGaps: map.claims.filter((claim) => claim.gapStatus !== 'COMPLETE').length,
      asOfInvariantMismatches: asOf.counts.invariantMismatches,
      forecastMaterialMismatches: asOf.counts.forecastMaterialMismatches,
      evidenceResolverErrors: registry.counts.errors,
      errors: errors.length,
    },
    errors,
  };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = validateCandidate0011RuleMap();
  process.stdout.write(`${JSON.stringify(result)}\n`);
  if (result.status === 'FAIL') process.exitCode = 1;
}
