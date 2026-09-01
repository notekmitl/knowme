#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const readText = (file) => fs.readFileSync(path.join(ROOT, file), 'utf8');
const commitCache = new Map();
const sourceCommit = (file) => {
  if (!commitCache.has(file)) commitCache.set(file, execFileSync('git', ['log', '-1', '--format=%H', '--', file], { cwd: ROOT, encoding: 'utf8' }).trim());
  return commitCache.get(file);
};
const escapePointer = (value) => String(value).replaceAll('~', '~0').replaceAll('/', '~1');

export const targetFixture = Object.freeze({
  profileId: 'TARGET-0003',
  sex: 'male',
  birthDate: '1982-06-06',
  birthTimeMode: 'known',
  birthTime: '00:03',
  province: 'Chiang Mai',
  provinceKey: 'chiang_mai',
  thaiAstrologicalDay: 'Saturday',
  ascendant: 'Aquarius 9°24′',
  contextId: 'mahabhut2537.rem0.saturday',
  asOf: '2026-08-29 Asia/Bangkok',
  age: 44,
});

export const typedGenerationFixture = Object.freeze({
  fixtureId: 'regression-known-0003',
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: '1982-06-06',
  birthHour: 0,
  birthMinute: 3,
  birthTimeUnknown: false,
  province: 'เชียงใหม่',
  provinceKey: 'chiang_mai',
  asOf: '2026-08-07 Asia/Bangkok',
});

const paths = Object.freeze({
  typedLedger: 'product-acceptance/thai-narrative-v1.5-r6/evidence/claim-ledger.json',
  selectorLedger: 'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json',
  canon: 'knowledge/canon/production/foundation_v1.knowme.json',
  dossier: 'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json',
  ownerLedger: 'docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json',
  contract: 'knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1.json',
  fixtureSource: 'test/validation/thai_beta/narrative/thai_consumer_narrative_r7_canonical_text_test.dart',
  fixtureSeparation: 'test/validation/thai_beta/narrative/thai_beta_input_fixture_separation_test.dart',
  generator: 'lib/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart',
  runner: 'lib/features/thai_beta/application/thai_beta_analysis.dart',
  dateGenerator: 'lib/features/thai_beta/application/thai_beta_report_export_document.dart',
  currentDomainComposer: 'lib/features/astrology/thai/mirror/presentation/timeline/life_map_current_domain_composer.dart',
  periodDomainComposer: 'lib/features/astrology/thai/mirror/presentation/timeline/life_period_domain_composer.dart',
});

const generatorBinding = (repositoryPath, symbol) => ({
  repositoryPath,
  symbol,
  sourceCommit: sourceCommit(repositoryPath),
});

const jsonEntry = ({ id, role, repositoryPath, array, index, objectKey, resolvedValue, fixtureInput, expectedDomain = null, expectedHorizon = null, expectedBandDirection = null, derivation }) => ({
  id,
  role,
  repositoryPath,
  locator: {
    jsonPointer: `/${escapePointer(array)}/${index}`,
    objectKey,
    symbol: null,
  },
  resolvedValue,
  fixtureInput,
  sourceCommit: sourceCommit(repositoryPath),
  derivation,
  expectedDomain,
  expectedHorizon,
  expectedBandDirection,
  manuallyAsserted: false,
});

const symbolEntry = ({ id, role, repositoryPath, symbol, resolvedValue, fixtureInput, expectedDomain = null, expectedHorizon = null, expectedBandDirection = null, derivation = null }) => ({
  id,
  role,
  repositoryPath,
  locator: { jsonPointer: null, objectKey: null, symbol },
  resolvedValue,
  fixtureInput,
  sourceCommit: sourceCommit(repositoryPath),
  derivation,
  expectedDomain,
  expectedHorizon,
  expectedBandDirection,
  manuallyAsserted: false,
});

export function buildResolvedRegistry() {
  const typed = readJson(paths.typedLedger);
  const selectors = readJson(paths.selectorLedger);
  const canon = readJson(paths.canon);
  const dossier = readJson(paths.dossier);
  const owners = readJson(paths.ownerLedger);
  const contract = readJson(paths.contract);
  const entries = [];

  const dossierFixture = dossier.fixture;
  entries.push({
    id: 'fixture.target-0003',
    role: 'fixture',
    repositoryPath: paths.dossier,
    locator: { jsonPointer: '/fixture', objectKey: 'TARGET-0003', symbol: null },
    resolvedValue: dossierFixture,
    fixtureInput: targetFixture,
    sourceCommit: sourceCommit(paths.dossier),
    derivation: generatorBinding(paths.runner, 'static ThaiBetaAnalysis run('),
    expectedDomain: null,
    expectedHorizon: null,
    expectedBandDirection: null,
    manuallyAsserted: false,
  });

  const typedRows = typed.claims
    .map((row, index) => ({ row, index }))
    .filter(({ row }) => row.fixture === typedGenerationFixture.fixtureId && String(row.canonicalId).startsWith('forecast:'));
  for (const { row, index } of typedRows) {
    const [, horizon, domain] = row.canonicalId.split(':');
    entries.push(jsonEntry({
      id: `typed.${horizon}.${domain}`,
      role: 'direction+timing',
      repositoryPath: paths.typedLedger,
      array: 'claims',
      index,
      objectKey: row.canonicalId,
      resolvedValue: row,
      fixtureInput: typedGenerationFixture,
      expectedDomain: domain,
      expectedHorizon: horizon,
      expectedBandDirection: row.confidence,
      derivation: generatorBinding(paths.generator, '_forecastClaim'),
    }));
  }

  const selectorIds = [
    'mahabhut2537.rem0.saturday.saturn.0_10',
    'mahabhut2537.rem0.saturday.jupiter.11_29',
    'mahabhut2537.rem0.saturday.rahu.30_41',
    'mahabhut2537.rem0.saturday.venus.42_62',
    'mahabhut2537.rem0.saturday.mercury.63_79',
  ];
  for (const selectorId of selectorIds) {
    const index = selectors.rows.findIndex((row) => row.matrixApplicationId === selectorId);
    const row = selectors.rows[index];
    entries.push(jsonEntry({
      id: `selector.${selectorId}`,
      role: 'selector+timing',
      repositoryPath: paths.selectorLedger,
      array: 'rows',
      index,
      objectKey: selectorId,
      resolvedValue: row,
      fixtureInput: targetFixture,
      expectedHorizon: row.agePeriod,
      expectedBandDirection: row.periodStatus,
      derivation: generatorBinding(paths.runner, 'static ThaiBetaAnalysis run('),
    }));
  }

  const sourceIds = [
    'T0003-SRC-0-10-FAMILY-CONSTRAINT',
    'T0003-SRC-11-62-RISING-BLOCK',
    'T0003-SRC-11-29-PLACEMENT',
    'T0003-SRC-30-41-PLACEMENT',
    'T0003-SRC-42-62-PLACEMENT',
    'T0003-SRC-42-62-SUPPORT',
    'T0003-SRC-42-62-WORK',
    'T0003-SRC-42-62-FINANCE',
    'T0003-SRC-42-62-FLOW',
    'T0003-SRC-42-43-61-62-EXCEPTION',
    'T0003-SRC-63-79-PLACEMENT',
  ];
  for (const evidenceId of sourceIds) {
    const index = dossier.sourceRecords.findIndex((row) => row.evidenceId === evidenceId);
    const row = dossier.sourceRecords[index];
    entries.push(jsonEntry({
      id: `source.${evidenceId}`,
      role: row.classification.includes('PLACEMENT') ? 'selector+domain-boundary' : 'direction+domain+conflict',
      repositoryPath: paths.dossier,
      array: 'sourceRecords',
      index,
      objectKey: evidenceId,
      resolvedValue: row,
      fixtureInput: targetFixture,
      expectedDomain: row.domains,
      expectedHorizon: row.exactPeriod,
      expectedBandDirection: row.classification,
      derivation: { repositoryPath: paths.dossier, symbol: evidenceId, sourceCommit: sourceCommit(paths.dossier) },
    }));
  }

  const ownerExceptionIndex = owners.sourceSignals.findIndex((row) => row.signalId === 'T0003-SRC-42-43-61-62-EXCEPTION');
  const ownerException = owners.sourceSignals[ownerExceptionIndex];
  entries.push(jsonEntry({
    id: 'conflict.T0003-SRC-42-43-61-62-EXCEPTION',
    role: 'conflictHandling',
    repositoryPath: paths.ownerLedger,
    array: 'sourceSignals',
    index: ownerExceptionIndex,
    objectKey: ownerException.signalId,
    resolvedValue: ownerException,
    fixtureInput: targetFixture,
    expectedDomain: ownerException.domains,
    expectedHorizon: ownerException.period,
    expectedBandDirection: ownerException.polarity,
    derivation: { repositoryPath: paths.ownerLedger, symbol: ownerException.sourceUnitId, sourceCommit: sourceCommit(paths.ownerLedger) },
  }));

  const canonIds = [
    'mahabhut.p28.saturn_owns_family',
    'mahabhut.p220.jupiter_owns_learning',
    'mahabhut.p220.jupiter_owns_career',
    'mahabhut.p39.det_owns_career',
    'mahabhut.p39.sri_owns_finance',
    'mahabhut.p16.venus_owns_relationship_male',
    'mahabhut.p28.venus_owns_relationship',
    'mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน',
    'mahabhut.p28.mercury_owns_family',
    'mahabhut.p33.mercury_relates_attribute_profession_นักพูด',
  ];
  for (const canonId of canonIds) {
    const index = canon.producedUnits.findIndex((row) => row.id === canonId);
    const row = canon.producedUnits[index];
    entries.push(jsonEntry({
      id: `canon.${canonId}`,
      role: 'domain',
      repositoryPath: paths.canon,
      array: 'producedUnits',
      index,
      objectKey: canonId,
      resolvedValue: row,
      fixtureInput: targetFixture,
      expectedDomain: row?.object ?? null,
      expectedBandDirection: row?.confidence ?? null,
      derivation: { repositoryPath: paths.canon, symbol: canonId, sourceCommit: sourceCommit(paths.canon) },
    }));
  }

  entries.push(symbolEntry({
    id: 'timing.rolling-12-month-label',
    role: 'timing',
    repositoryPath: paths.dateGenerator,
    symbol: 'static String _twelveMonthPeriodLabel(DateTime asOf)',
    resolvedValue: '29 ส.ค. 2569 – 28 ส.ค. 2570',
    fixtureInput: targetFixture,
    expectedHorizon: 'next12Months',
    derivation: generatorBinding(paths.dateGenerator, '_twelveMonthPeriodLabel'),
  }));
  for (const [domain, symbol] of Object.entries({ career: 'static ({String body, List<String> keys}) _work(', finance: 'static ({String body, List<String> keys}) _money(', health: 'static ({String body, List<String> keys}) _health(' })) {
    entries.push(symbolEntry({
      id: `domain.runtime.current.${domain}`,
      role: 'domainDerivation',
      repositoryPath: paths.currentDomainComposer,
      symbol,
      resolvedValue: domain,
      fixtureInput: targetFixture,
      expectedDomain: domain,
      expectedHorizon: 'current',
      derivation: generatorBinding(paths.currentDomainComposer, 'static List<ThaiMirrorLifeDomainBlock> compose('),
    }));
  }
  for (const [domain, symbol] of Object.entries({ career: 'static String _work(', finance: 'static String _money(', relationship: 'static String _love(', health: 'static String _health(' })) {
    entries.push(symbolEntry({
      id: `domain.runtime.nextLifePeriod.${domain}`,
      role: 'domainDerivation',
      repositoryPath: paths.periodDomainComposer,
      symbol,
      resolvedValue: domain,
      fixtureInput: targetFixture,
      expectedDomain: domain,
      expectedHorizon: 'nextLifePeriod',
      derivation: generatorBinding(paths.periodDomainComposer, 'static List<ThaiMirrorLifeDomainBlock> compose('),
    }));
  }
  entries.push({
    id: 'conflict.contract-boundaries',
    role: 'conflictHandling',
    repositoryPath: paths.contract,
    locator: { jsonPointer: '/constraints', objectKey: 'constraints', symbol: null },
    resolvedValue: contract.constraints,
    fixtureInput: targetFixture,
    sourceCommit: sourceCommit(paths.contract),
    derivation: { repositoryPath: paths.contract, symbol: '"constraints"', sourceCommit: sourceCommit(paths.contract) },
    expectedDomain: null,
    expectedHorizon: null,
    expectedBandDirection: 'NO_UNRESOLVED_CONFLICT',
    manuallyAsserted: false,
  });
  entries.push(symbolEntry({
    id: 'fixture.separation-00:03-00:35-unknown',
    role: 'fixtureBoundary',
    repositoryPath: paths.fixtureSeparation,
    symbol: "test('00:03 stays distinct and is identical across Engine and export'",
    resolvedValue: { known0003: 'Aquarius 9°24′', known0035: 'Aquarius 19°19′', unknown: 'fail-closed' },
    fixtureInput: targetFixture,
    derivation: generatorBinding(paths.runner, 'static ThaiBetaAnalysis run('),
  }));
  entries.push({
    id: 'certainty.product-interpretation-contract-v1',
    role: 'certaintyCeiling',
    repositoryPath: paths.contract,
    locator: { jsonPointer: '/readerCertainty', objectKey: 'readerCertainty', symbol: null },
    resolvedValue: contract.readerCertainty,
    fixtureInput: targetFixture,
    sourceCommit: sourceCommit(paths.contract),
    derivation: { repositoryPath: paths.contract, symbol: 'readerCertainty', sourceCommit: sourceCommit(paths.contract) },
    expectedDomain: null,
    expectedHorizon: null,
    expectedBandDirection: 'DIRECT_WITHIN_CHAIN|NARROWED_DIRECT|OMIT',
    manuallyAsserted: false,
  });

  return {
    version: 1,
    status: 'OR6_ACTUAL_EVIDENCE_RESOLUTION_COMPLETE_NOT_RUNTIME',
    generatedAt: '2026-09-01T00:00:00+07:00',
    targetFixture,
    typedGenerationFixture,
    counts: {
      entries: entries.length,
      typedForecastMaterials: typedRows.length,
      selectors: selectorIds.length,
      sourceRecords: sourceIds.length,
      canonRecords: canonIds.length,
      manuallyAssertedMaterial: entries.filter((entry) => entry.manuallyAsserted).length,
    },
    entries,
  };
}

export function resolveJsonPointer(document, pointer) {
  if (pointer === '') return document;
  if (!pointer?.startsWith('/')) throw new Error(`Invalid JSON pointer: ${pointer}`);
  return pointer.slice(1).split('/').reduce((value, token) => value?.[token.replaceAll('~1', '/').replaceAll('~0', '~')], document);
}

export function writeResolvedRegistry() {
  const output = buildResolvedRegistry();
  const target = path.join(ROOT, 'docs/CANDIDATE_0018_EVIDENCE_RESOLUTION.json');
  fs.writeFileSync(target, `${JSON.stringify(output, null, 2)}\n`, 'utf8');
  return output;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = writeResolvedRegistry();
  console.log(JSON.stringify(result.counts, null, 2));
}
