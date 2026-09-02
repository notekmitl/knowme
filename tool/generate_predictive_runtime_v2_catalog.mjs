#!/usr/bin/env node

import fs from 'node:fs';

const oracle = JSON.parse(fs.readFileSync('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json', 'utf8'));
const ruleMap = JSON.parse(fs.readFileSync('docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json', 'utf8'));
const candidate = fs.readFileSync('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md', 'utf8').replaceAll('\r\n', '\n');
const mapped = new Map(ruleMap.claims.map((claim) => [claim.readerClaimId, claim]));
const contextId = ruleMap.claims[0].contextId;
const summary = candidate.match(/## สรุปคำทำนาย\n\n([^\n]+)\n/u)?.[1];
if (!summary) throw new Error('Candidate 0011 summary was not found');

const claims = oracle.claims.map((claim) => {
  const map = mapped.get(claim.readerClaimId);
  return {
    id: claim.readerClaimId,
    section: claim.section,
    kind: claim.claimKind.toLowerCase(),
    text: claim.exactText,
    contextId,
    periodBinding: map?.periodBinding ?? '42-62',
    domain: map?.domain ?? claim.claimKind.toLowerCase(),
    selectorRefs: map?.selectorRefs ?? [], domainRefs: map?.domainRefs ?? [],
    directionRefs: map?.directionRefs ?? [], timingRefs: map?.timingRefs ?? [],
    conflictRefs: map?.conflictRefs ?? [], certaintyRefs: map?.certaintyRefs ?? [],
  };
});
const adviceIndex = claims.findIndex((claim) => claim.kind === 'advice');
claims.splice(adviceIndex, 0, {
  id: 'RC11-K-SUMMARY-01',
  section: 'สรุปคำทำนาย',
  kind: 'summary',
  text: summary,
  contextId,
  periodBinding: '42-62',
  domain: 'life_path',
  selectorRefs: [], domainRefs: [], directionRefs: [], timingRefs: [],
  conflictRefs: [], certaintyRefs: [],
});

const q = (value) => JSON.stringify(value);
const tokenize = (value) => value
  .replaceAll('29 สิงหาคม 2569', '{{horizonStart}}')
  .replaceAll('28 สิงหาคม 2570', '{{horizonEnd}}')
  .replaceAll('อายุ 44', 'อายุ {{currentAge}}');
const out = [
  '// GENERATED FILE — source: Candidate 0011 immutable oracle + resolved rule map.',
  '// Regenerate with: node tool/generate_predictive_runtime_v2_catalog.mjs',
  'part of \'predictive_runtime_v2.dart\';',
  '',
  `const runtimePredictiveV2OracleSha256 = ${q(oracle.source.acceptedReaderFacingSha256)};`,
  `const runtimePredictiveV2AcceptedContext = ${q(contextId)};`,
  'const runtimePredictiveV2EvidenceIds = <String>{',
  ...Object.keys(ruleMap.resolvedReferenceIndex).sort().map((id) => `  ${q(id)},`),
  ...ruleMap.claims.map((claim) => `  ${q(claim.readerClaimId)},`),
  '};',
  '',
  'const runtimePredictiveV2Rules = <RuntimePredictiveRule>[',
  ...claims.flatMap((claim) => [
    '  RuntimePredictiveRule(',
    `    id: ${q(claim.id)},`,
    `    section: ${q(tokenize(claim.section))},`,
    `    kind: RuntimePredictiveKind.${claim.kind},`,
    `    textTemplate: ${q(tokenize(claim.text))},`,
    `    contextId: ${q(claim.contextId)},`,
    `    periodBinding: ${q(claim.periodBinding)},`,
    `    domain: ${q(claim.domain)},`,
    ...['selectorRefs', 'domainRefs', 'directionRefs', 'timingRefs', 'conflictRefs', 'certaintyRefs'].flatMap((field) => [
      `    ${field}: <String>[`,
      ...[...new Set(claim[field])].map((ref) => `      ${q(ref)},`),
      '    ],',
    ]),
    '  ),',
  ]),
  '];',
  '',
].join('\n');

fs.writeFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart', out);
console.log(JSON.stringify({ rules: claims.length, predictions: claims.filter((claim) => claim.kind === 'prediction').length, oracleSha256: oracle.source.acceptedReaderFacingSha256 }));
