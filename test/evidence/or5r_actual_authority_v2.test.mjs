import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {BASE, RAW_NAME, actualAuthority, compareExtractions, goldenPositiveControl, read, semanticSlots, sha, summarize, validateClaim} from '../../tool/or5r_actual_authority_v2.mjs';

test('real accepted Candidate positive control passes its full chain at its own fixture', () => {
  const {entry, record} = goldenPositiveControl();
  const result = validateClaim(entry, record);
  assert.equal(result.classification, 'OWNER_APPROVED_TEMPLATE_SUPPORTED');
  assert.deepEqual(result.missing, []);
  assert.deepEqual(result.expansion, []);
  assert.equal(summarize([result], [{required: true, applicable: true, supported: true}]).supported, 1);
});

const negatives = [
  ['wrong context', e => e.context = 'different-context'],
  ['wrong period', e => e.period = '63-79'],
  ['wrong domain', e => e.domain = 'finance'],
  ['wrong horizon', e => e.horizon = 'next12Months'],
  ['wrong direction/band', e => e.direction = 'quiet'],
  ['missing selector', (e, r) => r.chain.selector = []],
  ['missing timing', (e, r) => r.chain.timing = []],
  ['self-referential owner', (e, r) => r.evidenceOwner = e.claimId],
  ['duplicate dependency owner', (e, r) => r.dependencies = ['parent', 'parent']],
  ['semantic expansion in text', e => e.text += ' จะได้เงินจำนวนแน่นอน'],
  ['Candidate0011 used for wrong fixture', (e, r) => { e.fixtureKey = 'actual/00:35'; r.expected.fixtureKey = e.fixtureKey; }],
  ['emitted without template binding', e => delete e.templateId],
];
for (const [name, mutate] of negatives) test(`neutral negative: ${name}`, () => {
  const {entry, record} = goldenPositiveControl();
  mutate(entry, record);
  const result = validateClaim(entry, record);
  assert.ok(result.classification.startsWith('UNSUPPORTED_'), JSON.stringify(result));
  assert.equal(summarize([result]).supported, 0);
});

test('duplicate semantic owners are rejected; shared source authors are not duplicate owners', () => {
  const {entry, record} = goldenPositiveControl();
  assert.equal(validateClaim(entry, record).classification, 'OWNER_APPROVED_TEMPLATE_SUPPORTED');
  assert.ok(validateClaim(entry, record, [entry, {...entry, claimId: 'second'}]).missing.includes('duplicate semantic owner'));
});

for (const role of ['domain', 'direction', 'template', 'conflict', 'certainty']) test(`no pass when ${role} role is missing`, () => {
  const {entry, record} = goldenPositiveControl();
  record.chain[role] = [];
  assert.ok(validateClaim(entry, record).missing.includes(role));
});

test('non-golden interpretation is review-required, not rejected by Candidate equality', () => {
  const {entry, record} = goldenPositiveControl();
  entry.fixtureKey = 'test-only-non-golden';
  entry.text = 'Test-only paraphrase; not generated product copy.';
  record.expected = {...entry}; record.textSha256 = sha(entry.text);
  record.template = {id: entry.templateId, kind: 'INTERPRETATION_PENDING'};
  assert.equal(validateClaim(entry, record).classification, 'OWNER_TEMPLATE_REVIEW_REQUIRED');
});

test('source-direct certificate path is passable (test-only source-field control, not a product prediction)', () => {
  const {entry, record} = goldenPositiveControl();
  const canon = record.chain.domain.find(r => r.id.startsWith('canon.'));
  entry.text = JSON.stringify(canon.value);
  record.textSha256 = sha(entry.text);
  record.template = {id: entry.templateId, kind: 'SOURCE_DIRECT', directSemantics: canon};
  assert.equal(validateClaim(entry, record).classification, 'SOURCE_CHAIN_SUPPORTED');
  record.template.directSemantics = null;
  assert.equal(validateClaim(entry, record).classification, 'UNSUPPORTED_MISSING_COMPONENT');
});

test('all final statuses and totals change with evidence and slot coverage, not constants', () => {
  const {entry, record} = goldenPositiveControl();
  const good = validateClaim(entry, record);
  const slots = [{required: true, applicable: true, supported: true, missing: false, duplicate: 0}];
  assert.equal(summarize([good], slots).status, 'ACTUAL 00:35 AUTHORITY TECHNICALLY SUPPORTED — PENDING OWNER CONTENT REVIEW');
  assert.equal(summarize([good], [{...slots[0], missing: true}]).status, 'ACTUAL 00:35 PARTIAL AUTHORITY — PRODUCT COVERAGE NO-GO');
  const bad = validateClaim({...entry, domain: 'wrong'}, record);
  assert.equal(summarize([bad], slots).status, 'ACTUAL 00:35 CLAIM AUTHORITY NO-GO');
});

test('two fresh extraction sets are byte-deterministic, and actual emitted text has no golden override', () => {
  const comparison = compareExtractions('build/or5r-neutral-v2-run1', 'build/or5r-neutral-v2-run2');
  assert.equal(comparison.pairs, 4); assert.equal(comparison.mismatches, 0);
  const raw = read(`build/or5r-neutral-v2-run1/${RAW_NAME}`);
  assert.equal(raw.input.birthMinute, 35);
  assert.equal(raw.asOf, '2026-08-29T00:00:00.000');
  const baseline = read('test/evidence/fixtures/or5r_known_baseline.json')['35'];
  assert.deepEqual(raw.plan.decisions, baseline.decisions);
  const a = actualAuthority(raw), b = actualAuthority(read(`build/or5r-neutral-v2-run2/${RAW_NAME}`));
  assert.deepEqual(a, b);
  assert.equal(a.entries.length, raw.plan.decisions.filter(d => d.kind === 'prediction' && d.emitted).length);
  assert.equal(a.entries.length, 10);
  for (const e of a.entries) {
    const d = raw.plan.decisions.find(d => d.claimId === e.claimId);
    assert.equal(e.text, d.text); assert.equal(d.binding.goldenOverride, false);
    assert.ok(baseline.publicExportText.split('\n').includes(e.text));
  }
});

test('actual component audits distinguish pending review, missing authority and timing expansion', () => {
  const raw = read(`build/or5r-neutral-v2-run1/${RAW_NAME}`), a = actualAuthority(raw);
  const result = summarize(a.entries, semanticSlots(raw, a.entries));
  assert.deepEqual(result.counts, {SOURCE_CHAIN_SUPPORTED: 0, OWNER_APPROVED_TEMPLATE_SUPPORTED: 0,
    OWNER_TEMPLATE_REVIEW_REQUIRED: 8, UNSUPPORTED_MISSING_COMPONENT: 1, UNSUPPORTED_SEMANTIC_EXPANSION: 1, OMIT: 0});
  assert.equal(a.entries.find(e => e.semanticOwner === 'current').classification, 'UNSUPPORTED_SEMANTIC_EXPANSION');
  assert.equal(a.entries.find(e => e.semanticOwner === 'next').classification, 'UNSUPPORTED_MISSING_COMPONENT');
  const record = a.records.find(r => r.expected.semanticOwner === 'relationship');
  const entry = a.entries.find(e => e.semanticOwner === 'relationship');
  const broken = structuredClone(record); broken.chain.domain = [];
  assert.equal(validateClaim(entry, broken).classification, 'UNSUPPORTED_MISSING_COMPONENT');
});

test('semantic slots use three actual completed periods, not universal 22 paragraphs', () => {
  const raw = read(`build/or5r-neutral-v2-run1/${RAW_NAME}`), a = actualAuthority(raw);
  const slots = semanticSlots(raw, a.entries);
  assert.equal(slots.length, 15);
  assert.deepEqual(slots.filter(s => s.missing).map(s => s.id), ['past:0-10', 'past:11-29']);
  assert.equal(slots.reduce((n, s) => n + s.emitted, 0), 13);
  assert.equal(slots.reduce((n, s) => n + s.duplicate, 0), 0);
  assert.equal(slots.find(s => s.id === 'summary').supported, false);
});

test('historical defective validator and both old reports remain byte-identical', () => {
  for (const p of ['tool/or5r_authority_matrix.mjs', 'docs/OR5R_ACTUAL_0035_AUTHORITY_MATRIX.md', 'docs/OR5R_ACTUAL_0035_AUTHORITY_MATRIX.json']) {
    assert.equal(sha(fs.readFileSync(p)), sha(execFileSync('git', ['show', `${BASE}:${p}`])));
  }
});
