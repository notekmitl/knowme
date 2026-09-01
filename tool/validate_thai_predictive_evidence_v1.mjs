#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { buildResolvedRegistry, resolveJsonPointer, targetFixture, typedGenerationFixture } from './resolve_thai_predictive_evidence_v1.mjs';

const ROOT = process.cwd();
const clone = (value) => structuredClone(value);
const deepEqual = (left, right) => JSON.stringify(left) === JSON.stringify(right);
const sourceCommit = (file) => execFileSync('git', ['log', '-1', '--format=%H', '--', file], { cwd: ROOT, encoding: 'utf8' }).trim();

function fixtureMatches(entry) {
  if (entry.id.startsWith('typed.')) return deepEqual(entry.fixtureInput, typedGenerationFixture);
  return entry.fixtureInput?.birthTime === targetFixture.birthTime && entry.fixtureInput?.birthDate === targetFixture.birthDate && entry.fixtureInput?.contextId === targetFixture.contextId;
}

export function validateEvidenceRegistry(registry = buildResolvedRegistry()) {
  const errors = [];
  const add = (code, entry, detail = '') => errors.push({ code, entry: entry?.id ?? null, detail });
  for (const entry of registry.entries) {
    const fullPath = path.join(ROOT, entry.repositoryPath ?? '');
    if (!entry.repositoryPath || !fs.existsSync(fullPath)) {
      add('NONEXISTENT_REFERENCE', entry, entry.repositoryPath);
      continue;
    }
    if (!entry.sourceCommit || sourceCommit(entry.repositoryPath) !== entry.sourceCommit) add('SOURCE_COMMIT_MISMATCH', entry);
    if (entry.manuallyAsserted === true) add('MANUALLY_ASSERTED_MATERIAL', entry);
    let actual;
    if (entry.locator?.jsonPointer) {
      try {
        actual = resolveJsonPointer(JSON.parse(fs.readFileSync(fullPath, 'utf8')), entry.locator.jsonPointer);
      } catch (error) {
        add('UNRESOLVED_REFERENCE', entry, String(error));
        continue;
      }
      if (actual === undefined) add('UNRESOLVED_REFERENCE', entry, entry.locator.jsonPointer);
      else if (!deepEqual(actual, entry.resolvedValue)) add('RESOLVED_VALUE_MISMATCH', entry);
    } else if (entry.locator?.symbol) {
      if (!fs.readFileSync(fullPath, 'utf8').includes(entry.locator.symbol)) add('UNRESOLVED_REFERENCE', entry, entry.locator.symbol);
      actual = entry.resolvedValue;
    } else {
      add('UNRESOLVED_REFERENCE', entry, 'missing pointer/symbol');
    }
    if (!fixtureMatches(entry)) add('FIXTURE_VALUE_MISMATCH', entry);
    if (entry.id.startsWith('typed.') && !entry.locator?.jsonPointer) add('TYPED_SOURCE_POINTER_MISSING', entry);
    if (entry.id.startsWith('typed.') && actual) {
      if (actual.domain !== entry.expectedDomain) add('DOMAIN_MISMATCH', entry);
      if (actual.horizon !== entry.expectedHorizon) add('HORIZON_MISMATCH', entry);
      if (actual.confidence !== entry.expectedBandDirection) add('DIRECTION_MISMATCH', entry);
      if (actual.fixture !== typedGenerationFixture.fixtureId) add('FIXTURE_VALUE_MISMATCH', entry);
    }
    if (entry.derivation) {
      const derivationPath = path.join(ROOT, entry.derivation.repositoryPath ?? '');
      if (!fs.existsSync(derivationPath) || !fs.readFileSync(derivationPath, 'utf8').includes(entry.derivation.symbol)) add('UNRESOLVED_DERIVATION', entry);
      else if (sourceCommit(entry.derivation.repositoryPath) !== entry.derivation.sourceCommit) add('DERIVATION_COMMIT_MISMATCH', entry);
    }
  }
  const count = (code) => errors.filter((error) => error.code === code).length;
  return {
    status: errors.length === 0 ? 'PASS_THAI_PREDICTIVE_EVIDENCE_V1' : 'FAIL',
    counts: {
      entries: registry.entries.length,
      typedForecastMaterials: registry.entries.filter((entry) => entry.id.startsWith('typed.')).length,
      unresolvedReference: count('UNRESOLVED_REFERENCE') + count('UNRESOLVED_DERIVATION'),
      nonexistentReference: count('NONEXISTENT_REFERENCE'),
      fixtureValueMismatch: count('FIXTURE_VALUE_MISMATCH'),
      domainMismatch: count('DOMAIN_MISMATCH'),
      horizonMismatch: count('HORIZON_MISMATCH'),
      directionMismatch: count('DIRECTION_MISMATCH'),
      manuallyAssertedMaterial: count('MANUALLY_ASSERTED_MATERIAL'),
      errors: errors.length,
    },
    errors,
  };
}

export function runEvidenceNegativeControls() {
  const base = buildResolvedRegistry();
  const controls = [];
  const run = (id, expectedCode, mutate) => {
    const registry = clone(base);
    mutate(registry);
    const result = validateEvidenceRegistry(registry);
    controls.push({ id, expectedCode, rejected: result.errors.some((error) => error.code === expectedCode), observedCodes: [...new Set(result.errors.map((error) => error.code))] });
  };
  run('nonexistent-reference', 'NONEXISTENT_REFERENCE', (registry) => { registry.entries[0].repositoryPath = 'docs/DOES_NOT_EXIST.json'; });
  run('typed-pointer-missing', 'TYPED_SOURCE_POINTER_MISSING', (registry) => { registry.entries.find((entry) => entry.id.startsWith('typed.')).locator = { jsonPointer: null, objectKey: null, symbol: '_forecastClaim' }; });
  run('wrong-fixture', 'FIXTURE_VALUE_MISMATCH', (registry) => { registry.entries.find((entry) => entry.id.startsWith('typed.')).fixtureInput.birthMinute = 35; });
  run('wrong-domain', 'DOMAIN_MISMATCH', (registry) => { registry.entries.find((entry) => entry.id === 'typed.current.career').expectedDomain = 'finance'; });
  run('wrong-horizon', 'HORIZON_MISMATCH', (registry) => { registry.entries.find((entry) => entry.id === 'typed.current.career').expectedHorizon = 'next12Months'; });
  run('resolved-value-mismatch', 'RESOLVED_VALUE_MISMATCH', (registry) => { registry.entries.find((entry) => entry.id === 'typed.current.career').resolvedValue.confidence = 'quiet'; });
  run('source-commit-mismatch', 'SOURCE_COMMIT_MISMATCH', (registry) => { registry.entries[0].sourceCommit = '0'.repeat(40); });
  run('derivation-commit-mismatch', 'DERIVATION_COMMIT_MISMATCH', (registry) => { registry.entries[0].derivation.sourceCommit = '0'.repeat(40); });
  run('manual-material', 'MANUALLY_ASSERTED_MATERIAL', (registry) => { registry.entries[0].manuallyAsserted = true; });
  return controls;
}

export function validationReport() {
  const resolution = validateEvidenceRegistry();
  const controls = runEvidenceNegativeControls();
  return {
    version: 1,
    status: resolution.status === 'PASS_THAI_PREDICTIVE_EVIDENCE_V1' && controls.every((control) => control.rejected) ? 'PASS_THAI_PREDICTIVE_EVIDENCE_V1_AND_NEGATIVE_CONTROLS' : 'FAIL',
    resolution,
    negativeControls: {
      total: controls.length,
      rejected: controls.filter((control) => control.rejected).length,
      failures: controls.filter((control) => !control.rejected).length,
      controls,
    },
  };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const report = validationReport();
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
  if (report.status === 'FAIL') process.exitCode = 1;
}
