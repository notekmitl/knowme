import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import test from 'node:test';

const sha = value => crypto.createHash('sha256').update(value, 'utf8').digest('hex').toUpperCase();
const readJson = path => JSON.parse(fs.readFileSync(path, 'utf8'));
const runtimePath = 'lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
const catalogPath = 'lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart';
const runtime = fs.readFileSync(runtimePath, 'utf8');
const catalog = fs.readFileSync(catalogPath, 'utf8');
const candidate = readJson('docs/CANDIDATE_0023_CLAIM_MAP.json');
const baseline = readJson('test/evidence/fixtures/or5r_known_baseline.json');

function historicalOracleText() {
  const source = fs.readFileSync(
    'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md',
    'utf8',
  ).replaceAll('\r\n', '\n');
  return source
    .split('Reader-facing candidate begins below.')[1]
    .split('Reader-facing candidate ends above.')[0]
    .trim();
}

function predictiveProjection(record) {
  return record.sections
    .filter(section => section.id.includes('predictive-v2-'))
    .filter(section => !section.id.includes('report-header'))
    .filter(section => !section.id.includes('psychology'))
    .filter(section => !section.id.includes('provenance'))
    .map(section => ({id: section.id, title: section.title, paragraphs: section.paragraphs}));
}

const selectorStart = runtime.indexOf('List<RuntimePredictiveRule> _rulesForAnalysis');
const selectorEnd = runtime.indexOf('String _predictiveSignature', selectorStart);
const selectorSource = runtime.slice(selectorStart, selectorEnd);
const forbiddenSelectorNames = [
  'birthMinute',
  'birthHour',
  'birthDate',
  'province',
  'gender',
  'siderealAscendantDeg',
  'asOf',
];

function forbiddenSelectorBranches(source) {
  return forbiddenSelectorNames.filter(name =>
    new RegExp(`(?:if|switch)\\s*\\([^)]*\\b${name}\\b`, 'u').test(source),
  );
}

test('Candidate 0023 is exact for 00:35 and Candidate 0011 stays historical', () => {
  assert.equal(
    sha(candidate.fullReaderCopy),
    'FDA1DA8917CD5ADCA4650AECF87414DCFCDEE7F13019DF0794ECF76DFD91E7F2',
  );
  assert.equal(baseline['35'].sectionPlainText, candidate.fullReaderCopy);
  assert.equal(sha(baseline['35'].sectionPlainText), sha(candidate.fullReaderCopy));
  assert.equal(
    sha(historicalOracleText()),
    '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E',
  );
  assert.equal(runtime.includes('candidate-0011-exact'), false);
});

test('00:03 and 00:35 share predictive output but preserve derived identity', () => {
  const three = baseline['3'];
  const thirtyFive = baseline['35'];
  assert.deepEqual(predictiveProjection(three), predictiveProjection(thirtyFive));
  assert.match(three.sectionPlainText, /เวลา 00:03 น\./u);
  assert.match(three.sectionPlainText, /ลัคนาราศีกุมภ์ 9°24′/u);
  assert.match(thirtyFive.sectionPlainText, /เวลา 00:35 น\./u);
  assert.match(thirtyFive.sectionPlainText, /ลัคนาราศีกุมภ์ 19°19′/u);
  assert.notEqual(sha(three.sectionPlainText), sha(thirtyFive.sectionPlainText));
});

test('runtime contains no fixture override path or fixture evidence selector', () => {
  for (const stale of [
    '_isOwnerAcceptedGoldenFixture',
    'useGoldenOverride',
    'runtimePredictiveV2GoldenRules',
    'candidate-0011-exact',
    'fixture.target-0003',
  ]) {
    assert.equal(runtime.includes(stale) || catalog.includes(stale), false, stale);
  }
  assert.equal((catalog.match(/RuntimePredictivePeriodRow\(/gu) ?? []).length, 392);
  assert.equal((catalog.match(/'fixture\./gu) ?? []).length, 0);
  assert.deepEqual(forbiddenSelectorBranches(selectorSource), []);
});

test('negative controls detect every prohibited predictive-copy selector', () => {
  for (const name of forbiddenSelectorNames) {
    const mutant = `${selectorSource}\nif (${name} == null) { return const []; }`;
    assert.deepEqual(forbiddenSelectorBranches(mutant), [name], name);
  }
});

test('actual raw forecast and active signature evidence remain pinned correctly', () => {
  const actual = readJson('build/or10r-runtime-evidence/OR5_ACTUAL_0035_RUNTIME_EVIDENCE.json');
  const three = readJson('build/or10r-runtime-evidence/OR5_RAW_0003_20260829.json');
  assert.equal(
    actual.rawFuturePredictionSha256.toUpperCase(),
    '292AEA14829A29935A0B877E8A536A6557DAB43ACD68BAE535E091B7D7CD7669',
  );
  assert.equal(actual.contextId, 'mahabhut2537.rem0.saturday');
  assert.equal(actual.currentAge, 44);
  assert.equal(actual.currentPeriod.matrixApplicationId, 'mahabhut2537.rem0.saturday.venus.42_62');
  assert.equal(actual.typedMaterials.length, 12);
  assert.equal(actual.plan.predictiveSignature, three.plan.predictiveSignature);
  assert.equal(actual.plan.usesCandidate0023Components, true);
  assert.equal(three.plan.usesCandidate0023Components, true);
  for (const metric of [
    'fixtureSpecificBranches',
    'ownerAcceptedGoldenOverrideApplied',
    'unexpectedFixtureSpecificBranches',
    'fixtureReferenceLeakage',
    'evidenceBindingMismatches',
    'knownToUnknownLeakage',
  ]) {
    assert.equal(actual.plan[metric], 0, metric);
    assert.equal(three.plan[metric], 0, `00:03 ${metric}`);
  }
});
