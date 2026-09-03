import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import test from 'node:test';

const json = (name) => JSON.parse(fs.readFileSync(name, 'utf8'));
const sha = (value) => crypto.createHash('sha256').update(value).digest('hex').toUpperCase();
const library = json('docs/PREDICTIVE_EDITORIAL_COMPONENT_LIBRARY_V2.json');
const simulation = json('docs/CANDIDATE_0019_49_CONTEXT_SIMULATION.json');
const representatives = json('docs/CANDIDATE_0019_REPRESENTATIVE_12.json');
const audit = json('docs/CANDIDATE_0019_CONTENT_AUDIT.json');
const feasibility = json('docs/PREDICTIVE_RUNTIME_V2_OR3_SEMANTIC_FEASIBILITY.json');
const oracle = fs.readFileSync('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md', 'utf8');
const reference = fs.readFileSync('docs/CANDIDATE_0019_GOLDEN_0003_REFERENCE.md', 'utf8');
const actual = fs.readFileSync('docs/CANDIDATE_0019_ACTUAL_0035.md', 'utf8');
const readerBlock = (value) => value.replaceAll('\r\n', '\n')
  .split('Reader-facing candidate begins below.')[1]
  .split('Reader-facing candidate ends above.')[0]
  .trim();

test('component library has complete schema and source-bound material signatures', () => {
  assert.ok(library.components.length >= 151);
  const required = ['componentId', 'semanticOwner', 'domain', 'horizon', 'materialSignature', 'netDirection', 'event', 'result', 'risk', 'sourceBinding', 'readerSentence', 'forbiddenCombinations', 'ageApplicability'];
  for (const component of library.components) {
    for (const key of required) assert.ok(Object.hasOwn(component, key), `${component.componentId}:${key}`);
    assert.ok(component.readerSentence.trim());
    assert.ok(component.forbiddenCombinations.length >= 5);
  }
  assert.deepEqual(library.singlePathContract.forbiddenInputs, ['name', 'profileId', 'birthDate', 'birthTime', 'province', 'gender', 'fixtureId']);
});

test('Candidate 0011 is byte-exact and Candidate 0019 Actual 00:35 preserves 22 prediction paragraphs', () => {
  assert.equal(reference, oracle);
  assert.equal(sha(readerBlock(oracle)), '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
  assert.match(actual, /เวลา 00:35/u);
  assert.match(actual, /ลัคนาราศีกุมภ์ 19°19′/u);
  assert.equal(audit.assertions.actual0035PredictionParagraphs, 22);
  assert.equal(audit.assertions.candidate0011ByteDelta, 0);
});

test('49 Known contexts and 12 representatives are complete with Unknown fail-closed', () => {
  assert.equal(simulation.scope.contexts, 49);
  assert.equal(simulation.simulations.length, 49);
  assert.equal(representatives.counts.profiles, 12);
  assert.equal(representatives.counts.known, 11);
  assert.equal(representatives.counts.unknown, 1);
  const unknown = representatives.profiles.find((profile) => profile.birthTimeKnown === false);
  assert.ok(unknown?.omitted);
  assert.equal(unknown.claims.length, 0);
});

test('chronology, duplication, conflict and predictive-language counters are zero', () => {
  for (const [key, value] of Object.entries(simulation.counters)) assert.equal(value, 0, key);
  assert.equal(simulation.status, 'CONTENT_CANDIDATE_MACHINE_AUDIT_PASS');
});

test('semantic feasibility is honest and all negative controls reject mismatches', () => {
  assert.equal(feasibility.semanticBindingPass, false);
  assert.equal(feasibility.ownerHumanReview, 'PENDING');
  assert.equal(feasibility.productContentStatus, 'NO_GO');
  assert.equal(feasibility.currentRuntimeGate.status, 'NO_GO');
  assert.equal(feasibility.counts.negativeControlsRejected, feasibility.counts.negativeControls);
  assert.ok(feasibility.negativeControls.every((control) => control.rejected));
});

test('generation is deterministic', () => {
  assert.equal(audit.candidate0011Sha256, sha(readerBlock(reference)));
  assert.equal(audit.candidate0019Actual0035Sha256, sha(actual));
});
