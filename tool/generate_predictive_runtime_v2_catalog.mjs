#!/usr/bin/env node

import fs from 'node:fs';

const oracle = JSON.parse(fs.readFileSync('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json', 'utf8'));
const ruleMap = JSON.parse(fs.readFileSync('docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json', 'utf8'));
const ledger = JSON.parse(fs.readFileSync('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json', 'utf8'));
const candidate = fs.readFileSync('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md', 'utf8').replaceAll('\r\n', '\n');
const mapped = new Map(ruleMap.claims.map((claim) => [claim.readerClaimId, claim]));
const goldenContextId = ruleMap.claims[0].contextId;
const summary = candidate.match(/## สรุปคำทำนาย\n\n([^\n]+)\n/u)?.[1];
if (!summary) throw new Error('Candidate 0011 summary was not found');

const claims = oracle.claims.map((claim) => {
  const map = mapped.get(claim.readerClaimId);
  return {
    id: claim.readerClaimId,
    semanticOwner: ownerFor(claim.readerClaimId),
    section: claim.section,
    kind: claim.claimKind.toLowerCase(),
    text: claim.exactText,
    contextId: goldenContextId,
    periodBinding: map?.periodBinding ?? '42-62',
    domain: map?.domain ?? claim.claimKind.toLowerCase(),
    selectorRefs: map?.selectorRefs ?? [], domainRefs: map?.domainRefs ?? [],
    directionRefs: map?.directionRefs ?? [], timingRefs: map?.timingRefs ?? [],
    conflictRefs: map?.conflictRefs ?? [], certaintyRefs: map?.certaintyRefs ?? [],
    compositionRefs: [],
  };
});
const adviceIndex = claims.findIndex((claim) => claim.kind === 'advice');
claims.splice(adviceIndex, 0, {
  id: 'RC11-K-SUMMARY-01',
  semanticOwner: 'summary',
  section: 'สรุปคำทำนาย',
  kind: 'summary',
  text: summary,
  contextId: goldenContextId,
  periodBinding: '42-62',
  domain: 'life_path',
  selectorRefs: [], domainRefs: [], directionRefs: [], timingRefs: [],
  conflictRefs: [], certaintyRefs: [],
  compositionRefs: ['RC11-K-CURRENT-01', 'RC11-K-HORIZON-01', 'RC11-K-NEXT-01'],
});

const weekdays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
const contexts = Array.from({ length: 7 }, (_, remainder) =>
  weekdays.map((weekday) => `mahabhut2537.rem${remainder}.${weekday}`)).flat();
if (contexts.length !== 49 || ledger.rows.length !== 392) {
  throw new Error(`Unexpected foundation size: ${contexts.length} contexts / ${ledger.rows.length} rows`);
}
for (const contextId of contexts) {
  const rows = ledger.rows.filter((row) => row.contextId === contextId);
  if (rows.length !== 8) throw new Error(`${contextId} has ${rows.length} period rows`);
}

const q = (value) => JSON.stringify(value);
const tokenize = (value) => value
  .replaceAll('29 สิงหาคม 2569', '{{horizonStart}}')
  .replaceAll('28 สิงหาคม 2570', '{{horizonEnd}}')
  .replaceAll('อายุ 44', 'อายุ {{currentAge}}');
const evidenceIds = new Set(Object.keys(ruleMap.resolvedReferenceIndex));
for (const row of ledger.rows) evidenceIds.add(`selector.${row.matrixApplicationId}`);
for (const horizon of ['current', 'next12Months', 'nextLifePeriod']) {
  for (const domain of ['career', 'finance', 'relationship', 'health', 'aggregate']) {
    evidenceIds.add(`typed.${horizon}.${domain}`);
    evidenceIds.add(`domain.runtime.${horizon}.${domain}`);
  }
}
evidenceIds.add('domain.runtime.life-period');
evidenceIds.add('direction.runtime.life-period');
evidenceIds.add('conflict.contract-boundaries');
evidenceIds.add('certainty.product-interpretation-contract-v1');
evidenceIds.add('timing.rolling-12-month-label');
for (const claim of claims) evidenceIds.add(claim.id);

const out = [
  '// GENERATED FILE — Candidate 0011 oracle + Contract V1 + 392-period selector ledger.',
  '// Regenerate with: node tool/generate_predictive_runtime_v2_catalog.mjs',
  'part of \'predictive_runtime_v2.dart\';',
  '',
  `const runtimePredictiveV2OracleSha256 = ${q(oracle.source.acceptedReaderFacingSha256)};`,
  `const runtimePredictiveV2GoldenOracleContextId = ${q(goldenContextId)};`,
  `const runtimePredictiveV2GoldenCurrentPeriodId = ${q(ledger.rows.find((row) => row.contextId === goldenContextId && row.agePeriod === '42-62').matrixApplicationId)};`,
  'const runtimePredictiveV2ContextIds = <String>{',
  ...contexts.map((id) => `  ${q(id)},`),
  '};',
  'const runtimePredictiveV2EvidenceIds = <String>{',
  ...[...evidenceIds].sort().map((id) => `  ${q(id)},`),
  '};',
  '',
  'const runtimePredictiveV2PeriodRows = <RuntimePredictivePeriodRow>[',
  ...ledger.rows.flatMap((row) => {
    const [ageStart, ageEnd] = row.agePeriod.split('-').map(Number);
    return [
      '  RuntimePredictivePeriodRow(',
      `    contextId: ${q(row.contextId)},`,
      `    matrixApplicationId: ${q(row.matrixApplicationId)},`,
      `    planet: ${q(row.planet)},`,
      `    taksaRole: ${q(row.taksaRole)},`,
      `    mahabhutHouse: ${q(row.mahabhutHouse)},`,
      `    periodStatus: ${q(row.periodStatus)},`,
      `    ageStart: ${ageStart},`,
      `    ageEnd: ${ageEnd},`,
      '  ),',
    ];
  }),
  '];',
  '',
  'const runtimePredictiveV2GoldenRules = <RuntimePredictiveRule>[',
  ...claims.flatMap((claim) => [
    '  RuntimePredictiveRule(',
    `    id: ${q(claim.id)},`,
    `    semanticOwner: ${q(claim.semanticOwner)},`,
    `    section: ${q(tokenize(claim.section))},`,
    `    kind: RuntimePredictiveKind.${claim.kind},`,
    `    textTemplate: ${q(tokenize(claim.text))},`,
    `    infographicTextTemplate: ${q(tokenize(compactInfographicText(claim)))},`,
    `    contextId: ${q(claim.contextId)},`,
    `    periodBinding: ${q(claim.periodBinding)},`,
    `    domain: ${q(claim.domain)},`,
    ...['selectorRefs', 'domainRefs', 'directionRefs', 'timingRefs', 'conflictRefs', 'certaintyRefs', 'compositionRefs'].flatMap((field) => [
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
console.log(JSON.stringify({
  contexts: contexts.length,
  periods: ledger.rows.length,
  goldenRules: claims.length,
  predictions: claims.filter((claim) => claim.kind === 'prediction').length,
  oracleSha256: oracle.source.acceptedReaderFacingSha256,
}));

function ownerFor(id) {
  if (id.includes('-OVERVIEW-')) return 'overview';
  if (id.includes('-PAST-')) return 'past';
  if (id.includes('-CURRENT-')) return 'current';
  if (id.includes('-WORK-')) return 'work';
  if (id.includes('-FINANCE-')) return 'finance';
  if (id.includes('-RELATIONSHIP-')) return 'relationship';
  if (id.includes('-HEALTH-')) return 'health';
  if (id.includes('-SUPPORT-')) return 'support';
  if (id.includes('-HORIZON-')) return 'rolling12';
  if (id.includes('-NEXT-')) return 'next';
  if (id.includes('-ADVICE-')) return 'advice';
  if (id.includes('-DISCLOSURE-')) return 'disclosure';
  return 'unclassified';
}

function compactInfographicText(claim) {
  const text = claim.text.trim();
  const owner = claim.semanticOwner;
  if (owner === 'rolling12' || ['work', 'finance', 'relationship', 'health'].includes(owner)) {
    return text
      .replace(/^ช่วงนี้[,.]?\s*/, '')
      .split(/(?: ผลงาน| ความมั่นคง| ความสม่ำเสมอ| ควร| แต่| โดย)/, 1)[0]
      .trim();
  }
  if (owner === 'support') {
    return text.split(/(?: จังหวะ| โอกาส| การ)/, 1)[0].trim();
  }
  if (owner === 'advice') {
    return text.split(/(?<=ชัด|สำคัญ|สำรอง)\s/, 1)[0].trim();
  }
  if (owner === 'disclosure') {
    return text.split(/(?<=ความเชื่อ)\s/, 1)[0].trim();
  }
  return text;
}
