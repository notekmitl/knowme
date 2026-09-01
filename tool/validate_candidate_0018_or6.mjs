#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { buildResolvedRegistry, resolveJsonPointer, targetFixture, typedGenerationFixture } from './resolve_candidate_0018_or6.mjs';

const ROOT = process.cwd();
const clone = (value) => structuredClone(value);
const deepEqual = (left, right) => JSON.stringify(left) === JSON.stringify(right);
const commitCache = new Map();
const sourceCommit = (file) => {
  if (!commitCache.has(file)) commitCache.set(file, execFileSync('git', ['log', '-1', '--format=%H', '--', file], { cwd: ROOT, encoding: 'utf8' }).trim());
  return commitCache.get(file);
};
const normalize = (value) => String(value).normalize('NFC').toLowerCase().replace(/ช่วงวันที่\s+\d{1,2}\s+\S+\s+\d{4}\s+[–-]\s+\d{1,2}\s+\S+\s+\d{4}/gu, '').replace(/\s+/gu, ' ').replace(/[.,!?;:()“”"'`]/gu, '').trim();

function fixtureMatches(entry) {
  if (entry.id.startsWith('typed.')) return deepEqual(entry.fixtureInput, typedGenerationFixture);
  return entry.fixtureInput?.birthTime === targetFixture.birthTime && entry.fixtureInput?.birthDate === targetFixture.birthDate && entry.fixtureInput?.contextId === targetFixture.contextId;
}

export function validateRegistry(registry = buildResolvedRegistry()) {
  const errors = [];
  const add = (code, entry, detail = '') => errors.push({ code, entry: entry?.id ?? null, detail });
  for (const entry of registry.entries) {
    const fullPath = path.join(ROOT, entry.repositoryPath ?? '');
    if (!entry.repositoryPath || !fs.existsSync(fullPath)) {
      add('NONEXISTENT_REFERENCE', entry, entry.repositoryPath);
      continue;
    }
    if (!entry.sourceCommit || sourceCommit(entry.repositoryPath) !== entry.sourceCommit) add('SOURCE_COMMIT_MISMATCH', entry, entry.sourceCommit);
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
      const source = fs.readFileSync(fullPath, 'utf8');
      if (!source.includes(entry.locator.symbol)) add('UNRESOLVED_REFERENCE', entry, entry.locator.symbol);
      actual = entry.resolvedValue;
    } else {
      add('UNRESOLVED_REFERENCE', entry, 'missing pointer/symbol');
    }
    if (!fixtureMatches(entry)) add('FIXTURE_VALUE_MISMATCH', entry, JSON.stringify(entry.fixtureInput));
    if (entry.id.startsWith('typed.') && !entry.locator?.jsonPointer) add('TYPED_SOURCE_POINTER_MISSING', entry);
    if (entry.id.startsWith('typed.') && actual) {
      if (actual.domain !== entry.expectedDomain) add('DOMAIN_MISMATCH', entry, `${actual.domain} != ${entry.expectedDomain}`);
      if (actual.horizon !== entry.expectedHorizon) add('HORIZON_MISMATCH', entry, `${actual.horizon} != ${entry.expectedHorizon}`);
      if (actual.confidence !== entry.expectedBandDirection) add('DIRECTION_MISMATCH', entry, `${actual.confidence} != ${entry.expectedBandDirection}`);
      if (actual.fixture !== typedGenerationFixture.fixtureId) add('FIXTURE_VALUE_MISMATCH', entry, actual.fixture);
    }
    if (entry.derivation) {
      const derivationPath = path.join(ROOT, entry.derivation.repositoryPath ?? '');
      if (!fs.existsSync(derivationPath) || !fs.readFileSync(derivationPath, 'utf8').includes(entry.derivation.symbol)) add('UNRESOLVED_DERIVATION', entry, entry.derivation.symbol);
      else if (sourceCommit(entry.derivation.repositoryPath) !== entry.derivation.sourceCommit) add('DERIVATION_COMMIT_MISMATCH', entry);
    }
  }
  const count = (code) => errors.filter((error) => error.code === code).length;
  return {
    status: errors.length === 0 ? 'PASS_OR6_ACTUAL_EVIDENCE_RESOLUTION' : 'FAIL',
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

export function semanticDuplicatePairs(claims) {
  const pairs = [];
  for (let leftIndex = 0; leftIndex < claims.length; leftIndex++) {
    for (let rightIndex = leftIndex + 1; rightIndex < claims.length; rightIndex++) {
      const left = claims[leftIndex];
      const right = claims[rightIndex];
      const leftText = normalize(left.fullReaderText);
      const rightText = normalize(right.fullReaderText);
      const exactMeaning = leftText === rightText;
      const leftMotifs = new Set(left.semanticMotifs ?? []);
      const sharedMotifs = (right.semanticMotifs ?? []).filter((motif) => leftMotifs.has(motif));
      if (exactMeaning || sharedMotifs.length > 0) pairs.push({ left: left.claimId, right: right.claimId, reason: exactMeaning ? 'NORMALIZED_FULL_TEXT' : `SHARED_MOTIF:${sharedMotifs.join(',')}` });
    }
  }
  return pairs;
}

export function validateReaderClaims(claims) {
  const errors = [];
  const prohibited = /มีแนวโน้ม|น่าจะ|อาจจะ|อาจ|เดินได้ดีเมื่อ|มีแรงส่ง|พื้นที่ทางการเงิน|ขยับแผน|ฐานเดิม|กำลังรองรับ|ภาระที่รับไม่เบียดคุณภาพ/u;
  const specificEvents = /เลื่อนตำแหน่ง|ซื้อบ้าน|แต่งงาน|หย่าร้าง|วินิจฉัย|เข้าโรงพยาบาล|ได้เงินจำนวน|วันที่\s+\d/u;
  for (const claim of claims) {
    if (claim.classification !== 'PREDICTION') continue;
    if (prohibited.test(claim.fullReaderText)) errors.push({ code: 'PROHIBITED_READER_LANGUAGE', claimId: claim.claimId });
    const conditionalMatches = [...claim.fullReaderText.matchAll(/เมื่อ|หาก|ถ้า/gu)].map((match) => ({ token: match[0], index: match.index ?? -1 }));
    for (const match of conditionalMatches) {
      const allowedTiming = match.token === 'เมื่อ' && claim.fullReaderText.slice(match.index).startsWith('เมื่ออายุ 63 ปี');
      if (!allowedTiming) errors.push({ code: 'ADVICE_INSIDE_PREDICTION', claimId: claim.claimId, token: match.token });
    }
    if (claim.materialStrength === 'BAND_ONLY' && specificEvents.test(claim.fullReaderText)) errors.push({ code: 'UNSUPPORTED_BAND_EXPANSION', claimId: claim.claimId });
    if (/ลองทบทวน|ลองย้อน|นึกย้อน|\?/u.test(claim.fullReaderText)) errors.push({ code: 'PAST_REFLECTION_OR_QUESTION', claimId: claim.claimId });
    if (/คุณเป็นคน|นิสัย|บุคลิก|ตัวตนของคุณ/u.test(claim.fullReaderText)) errors.push({ code: 'PERSONALITY_SUBSTITUTION', claimId: claim.claimId });
    if (/selector|forecast|band|Rule Chain|หลักฐาน|JSON|Canon/u.test(claim.fullReaderText)) errors.push({ code: 'METHODOLOGY_LEAKAGE', claimId: claim.claimId });
  }
  for (const pair of semanticDuplicatePairs(claims)) errors.push({ code: 'UNNECESSARY_SEMANTIC_DUPLICATE', ...pair });
  return errors;
}

export function runOr6NegativeControls() {
  const baseRegistry = buildResolvedRegistry();
  const controls = [];
  const runRegistry = (id, expectedCode, mutate) => {
    const registry = clone(baseRegistry);
    mutate(registry);
    const result = validateRegistry(registry);
    controls.push({ id, expectedCode, rejected: result.errors.some((error) => error.code === expectedCode), observedCodes: [...new Set(result.errors.map((error) => error.code))] });
  };
  runRegistry('nonexistent-reference', 'NONEXISTENT_REFERENCE', (registry) => { registry.entries[0].repositoryPath = 'docs/DOES_NOT_EXIST_OR6.json'; });
  runRegistry('typed-material-without-source-pointer', 'TYPED_SOURCE_POINTER_MISSING', (registry) => { registry.entries.find((entry) => entry.id.startsWith('typed.')).locator = { jsonPointer: null, objectKey: null, symbol: '_forecastClaim' }; });
  runRegistry('wrong-fixture-profile', 'FIXTURE_VALUE_MISMATCH', (registry) => { registry.entries.find((entry) => entry.id.startsWith('typed.')).fixtureInput.birthMinute = 35; });
  runRegistry('wrong-domain', 'DOMAIN_MISMATCH', (registry) => { registry.entries.find((entry) => entry.id === 'typed.current.career').expectedDomain = 'finance'; });
  runRegistry('wrong-horizon', 'HORIZON_MISMATCH', (registry) => { registry.entries.find((entry) => entry.id === 'typed.current.career').expectedHorizon = 'next12Months'; });
  const semantic = validateReaderClaims([
    { claimId: 'NC-SAME-1', classification: 'PREDICTION', fullReaderText: 'งานชัดขึ้นจากผลงานที่ส่งมอบ', semanticMotifs: [], materialStrength: 'DIRECT' },
    { claimId: 'NC-SAME-2', classification: 'PREDICTION', fullReaderText: 'งานชัดขึ้นจากผลงานที่ส่งมอบ', semanticMotifs: [], materialStrength: 'DIRECT' },
  ]);
  controls.push({ id: 'same-meaning-different-owner', expectedCode: 'UNNECESSARY_SEMANTIC_DUPLICATE', rejected: semantic.some((error) => error.code === 'UNNECESSARY_SEMANTIC_DUPLICATE'), observedCodes: [...new Set(semantic.map((error) => error.code))] });
  const dateOnly = validateReaderClaims([
    { claimId: 'NC-CURRENT', classification: 'PREDICTION', fullReaderText: 'งานจะชัดขึ้นจากผลงานที่ส่งมอบ', semanticMotifs: [], materialStrength: 'DIRECT' },
    { claimId: 'NC-NEXT12', classification: 'PREDICTION', fullReaderText: 'ช่วงวันที่ 29 ส.ค. 2569 – 28 ส.ค. 2570 งานจะชัดขึ้นจากผลงานที่ส่งมอบ', semanticMotifs: [], materialStrength: 'DIRECT' },
  ]);
  controls.push({ id: 'current-copy-moved-to-next12-with-date-only', expectedCode: 'UNNECESSARY_SEMANTIC_DUPLICATE', rejected: dateOnly.some((error) => error.code === 'UNNECESSARY_SEMANTIC_DUPLICATE'), observedCodes: [...new Set(dateOnly.map((error) => error.code))] });
  const conditional = validateReaderClaims([{ claimId: 'NC-CONDITIONAL', classification: 'PREDICTION', fullReaderText: 'งานจะเดินต่อได้เมื่อคุณรับภาระเพิ่ม', semanticMotifs: [], materialStrength: 'DIRECT' }]);
  controls.push({ id: 'hidden-advice-conditional', expectedCode: 'ADVICE_INSIDE_PREDICTION', rejected: conditional.some((error) => error.code === 'ADVICE_INSIDE_PREDICTION'), observedCodes: [...new Set(conditional.map((error) => error.code))] });
  const expansion = validateReaderClaims([{ claimId: 'NC-BAND-EVENT', classification: 'PREDICTION', fullReaderText: 'คุณจะได้เลื่อนตำแหน่งในวันที่ 1 มกราคม', semanticMotifs: [], materialStrength: 'BAND_ONLY' }]);
  controls.push({ id: 'band-expanded-to-specific-event', expectedCode: 'UNSUPPORTED_BAND_EXPANSION', rejected: expansion.some((error) => error.code === 'UNSUPPORTED_BAND_EXPANSION'), observedCodes: [...new Set(expansion.map((error) => error.code))] });
  return controls;
}

export function validateCandidate0018() {
  const registry = buildResolvedRegistry();
  const registryResult = validateRegistry(registry);
  const map = JSON.parse(fs.readFileSync(path.join(ROOT, 'docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.json'), 'utf8'));
  const known = fs.readFileSync(path.join(ROOT, 'docs/CANDIDATE_0018_KNOWN.md'), 'utf8');
  const unknown = fs.readFileSync(path.join(ROOT, 'docs/CANDIDATE_0018_UNKNOWN.md'), 'utf8');
  const errors = [...registryResult.errors];
  const add = (code, detail = '') => errors.push({ code, detail });
  const predictions = map.known.claims.filter((claim) => claim.classification === 'PREDICTION');
  const roles = ['selectorRefs', 'domainRefs', 'directionRefs', 'timingRefs', 'conflictRefs', 'certaintyRefs'];
  const bindingIds = new Set(Object.keys(map.resolvedBindings));
  const registryById = new Map(registry.entries.map((entry) => [entry.id, entry]));
  const allRefs = [];
  for (const claim of predictions) {
    for (const role of roles) {
      if (!Array.isArray(claim[role]) || claim[role].length === 0) add('CHAIN_COMPONENT_MISSING', `${claim.claimId}:${role}`);
      for (const ref of claim[role] ?? []) {
        allRefs.push(ref);
        if (!bindingIds.has(ref) || !registryById.has(ref)) add('CLAIM_REFERENCE_UNRESOLVED', `${claim.claimId}:${role}:${ref}`);
        else if (!deepEqual(map.resolvedBindings[ref], registryById.get(ref))) add('CLAIM_BINDING_VALUE_MISMATCH', `${claim.claimId}:${ref}`);
      }
    }
    if (!known.includes(claim.fullReaderText)) add('READER_TEXT_NOT_EXACT', claim.claimId);
    if (!claim.allowedSpecificity || !Array.isArray(claim.prohibitedSpecificity) || !claim.expectedDomain || !claim.expectedHorizon || !claim.expectedBandDirection || !claim.materialStrength) add('CLAIM_FIELD_MISSING', claim.claimId);
  }
  for (const error of validateReaderClaims(map.known.claims)) add(error.code, JSON.stringify(error));
  const typedIds = registry.entries.filter((entry) => entry.id.startsWith('typed.')).map((entry) => entry.id).sort();
  const usedTypedIds = [...new Set(allRefs.filter((ref) => ref.startsWith('typed.')))];
  if (!deepEqual(usedTypedIds.sort(), typedIds)) add('TYPED_MATERIAL_COVERAGE', JSON.stringify({ typedIds, usedTypedIds }));
  if (map.typedForecastMaterials.length !== 12 || map.typedForecastMaterials.some((row) => !row.jsonPointer?.startsWith('/claims/') || row.fixture !== typedGenerationFixture.fixtureId)) add('TYPED_MATERIAL_NOT_ACTUAL_OUTPUT', String(map.typedForecastMaterials.length));
  if (map.known.claims.length !== 15 || predictions.length !== 13) add('CLAIM_COUNT', `${map.known.claims.length}/${predictions.length}`);
  if (map.unknown.predictionClaims.length !== 0 || map.unknown.fixture.noonSubstitution !== false || map.unknown.fixture.ascendant !== null || map.unknown.fixture.houses !== null || map.unknown.fixture.thaiAstrologicalDay !== null || map.unknown.knownCopyBorrowed !== false) add('UNKNOWN_FAIL_CLOSED', JSON.stringify(map.unknown));
  if (predictions.some((claim) => unknown.includes(claim.fullReaderText)) || /กุมภ์|9°24′|วันทางโหราศาสตร์:\s*วันเสาร์|เวลา 00:03/u.test(unknown)) add('KNOWN_TO_UNKNOWN_LEAKAGE', 'Unknown');
  if (!known.includes('29 ส.ค. 2569 – 28 ส.ค. 2570') || !deepEqual(map.fixture, targetFixture)) add('FIXTURE_TIMING_MISMATCH', JSON.stringify(map.fixture));
  if (/เดือนดี|เดือนควรระวัง|คำทำนายรายเดือน/u.test(known)) add('MONTHLY_PREDICTION_PRESENT', 'Known');
  const current = map.known.claims.find((claim) => claim.claimId === 'RC18-K-CURRENT');
  if (!current?.conflictRefs.includes('conflict.T0003-SRC-42-43-61-62-EXCEPTION') || [42, 43, 61, 62].includes(targetFixture.age)) add('CONFLICT_EXCEPTION_MISAPPLIED', 'age44');
  const controls = runOr6NegativeControls();
  for (const control of controls) if (!control.rejected) add('NEGATIVE_CONTROL_NOT_REJECTED', control.id);
  const count = (code) => errors.filter((error) => error.code === code).length;
  const counts = {
    contentEntries: map.known.claims.length,
    predictionEntries: predictions.length,
    typedForecastMaterials: typedIds.length,
    typedForecastMaterialsUsed: usedTypedIds.length,
    resolvedBindings: bindingIds.size,
    evidenceRegistryEntries: registry.entries.length,
    negativeControls: controls.length,
    negativeControlsRejected: controls.filter((control) => control.rejected).length,
    unresolvedReference: registryResult.counts.unresolvedReference + count('CLAIM_REFERENCE_UNRESOLVED'),
    nonexistentReference: registryResult.counts.nonexistentReference,
    fixtureValueMismatch: registryResult.counts.fixtureValueMismatch,
    domainMismatch: registryResult.counts.domainMismatch,
    horizonMismatch: registryResult.counts.horizonMismatch,
    directionMismatch: registryResult.counts.directionMismatch,
    manuallyAssertedMaterial: registryResult.counts.manuallyAssertedMaterial,
    unsupportedExpansion: count('UNSUPPORTED_BAND_EXPANSION'),
    adviceInsidePrediction: count('ADVICE_INSIDE_PREDICTION'),
    personalitySubstitution: count('PERSONALITY_SUBSTITUTION'),
    pastReflectionQuestion: count('PAST_REFLECTION_OR_QUESTION'),
    methodologyLeakage: count('METHODOLOGY_LEAKAGE'),
    unnecessarySemanticDuplicate: count('UNNECESSARY_SEMANTIC_DUPLICATE'),
    knownToUnknownLeakage: count('KNOWN_TO_UNKNOWN_LEAKAGE'),
    unknownPredictionClaims: map.unknown.predictionClaims.length,
    errors: errors.length,
  };
  return {
    version: 1,
    status: errors.length === 0 ? 'PASS_OR6_EVIDENCE_BINDING_AND_READER_COPY_REPAIR_PENDING_OWNER_CONTENT_REVIEW_NOT_RUNTIME' : 'FAIL',
    generatedAt: '2026-09-01T00:00:00+07:00',
    counts,
    removedStandaloneCandidate0017Claims: ['RC17-K-NEXT12-WORK-FINANCE', 'RC17-K-NEXT12-RELATIONSHIP-HEALTH', 'RC17-K-NEXT-LIFE-DOMAINS'],
    removedForUnresolvableEvidence: [],
    controls,
    errors,
  };
}

export function writeOr6ResolutionValidation() {
  const resolution = validateRegistry();
  const controls = runOr6NegativeControls();
  const output = {
    version: 1,
    status: resolution.status === 'PASS_OR6_ACTUAL_EVIDENCE_RESOLUTION' && controls.every((control) => control.rejected) ? 'PASS_OR6_RESOLUTION_AND_NEGATIVE_CONTROLS' : 'FAIL',
    generatedAt: '2026-09-01T00:00:00+07:00',
    resolution,
    negativeControls: {
      total: controls.length,
      rejected: controls.filter((control) => control.rejected).length,
      failures: controls.filter((control) => !control.rejected).length,
      controls,
    },
  };
  fs.writeFileSync(path.join(ROOT, 'docs/CANDIDATE_0018_OR6_NEGATIVE_CONTROLS.json'), `${JSON.stringify(output, null, 2)}\n`, 'utf8');
  return output;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const resolutionOnly = !process.argv.includes('--full');
  const result = resolutionOnly ? writeOr6ResolutionValidation() : validateCandidate0018();
  if (!resolutionOnly) fs.writeFileSync(path.join(ROOT, 'docs/CANDIDATE_0018_VALIDATION.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
  console.log(JSON.stringify(result, null, 2));
  if (result.status === 'FAIL') process.exitCode = 1;
}
