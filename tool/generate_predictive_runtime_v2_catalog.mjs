#!/usr/bin/env node

import fs from 'node:fs';

const ruleMap = JSON.parse(fs.readFileSync('docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json', 'utf8'));
const ledger = JSON.parse(fs.readFileSync('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json', 'utf8'));

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
const evidenceIds = new Set(Object.keys(ruleMap.resolvedReferenceIndex));
for (const id of [...evidenceIds]) if (id.startsWith('fixture.')) evidenceIds.delete(id);
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

const out = [
  '// GENERATED FILE — Contract V1 evidence registry + 392-period selector ledger.',
  '// Regenerate with: node tool/generate_predictive_runtime_v2_catalog.mjs',
  'part of \'predictive_runtime_v2.dart\';',
  '',
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
].join('\n');

fs.writeFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart', out);
console.log(JSON.stringify({
  contexts: contexts.length,
  periods: ledger.rows.length,
  fixtureEvidenceIds: [...evidenceIds].filter((id) => id.startsWith('fixture.')).length,
}));
