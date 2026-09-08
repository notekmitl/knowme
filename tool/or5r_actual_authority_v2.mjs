// Evidence-only: never generates or changes product text, source rules or an oracle.
import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';

export const BASE = '8325e04275d7cb58447abbf9b5dd1ff12acda2d8';
export const RUNTIME = 'lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
export const REGISTRY = 'docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json';
export const CONTRACT = 'knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1.json';
export const RAW_NAME = 'OR5_ACTUAL_0035_RUNTIME_EVIDENCE.json';
export const read = p => JSON.parse(fs.readFileSync(p, 'utf8'));
export const sha = x => crypto.createHash('sha256').update(x).digest('hex').toUpperCase();
export const fileSha = p => sha(fs.readFileSync(p));
export const pointer = (x, p) => p.split('/').slice(1).reduce((v, k) => v?.[k.replaceAll('~1', '/').replaceAll('~0', '~')], x);
export const CLASSES = ['SOURCE_CHAIN_SUPPORTED', 'OWNER_APPROVED_TEMPLATE_SUPPORTED', 'OWNER_TEMPLATE_REVIEW_REQUIRED', 'UNSUPPORTED_MISSING_COMPONENT', 'UNSUPPORTED_SEMANTIC_EXPANSION', 'OMIT'];
const ROLES = ['selector', 'domain', 'direction', 'timing', 'template', 'conflict', 'certainty'];
export const supported = e => CLASSES.slice(0, 2).includes(e.classification);

// A reference resolves data, not truth. Runtime symbols prove provenance only.
export function resolveReference(id, registry = read(REGISTRY)) {
  const e = registry.entries.find(x => x.id === id);
  if (!e) return {id, resolved: false, reason: 'Reference has no independently addressable registry entry'};
  const bytes = fs.readFileSync(e.repositoryPath);
  const value = e.locator.jsonPointer ? pointer(JSON.parse(bytes), e.locator.jsonPointer) : e.locator.symbol;
  const resolved = e.locator.jsonPointer
    ? JSON.stringify(value) === JSON.stringify(e.resolvedValue)
    : Boolean(value && bytes.toString('utf8').includes(value));
  return {id, resolved, reference: e.repositoryPath, locator: e.locator, sourceSha256: sha(bytes),
    value, historicalFixture: e.fixtureInput,
    limitation: id.startsWith('domain.runtime.') ? 'Symbol is a generation owner, not whole-claim semantic authorization' :
      id.startsWith('selector.') ? 'Selector placement only; OCR status is not event authority' : null};
}

// The trusted record is constructed from resolved source files + fresh extraction,
// separately from the candidate being checked. No caller-supplied PASS/count is used.
export function validateClaim(entry, record, peers = [entry]) {
  const missing = [], expansion = [];
  if (!entry.emitted) return {...entry, classification: 'OMIT', reasons: [entry.omissionReason || 'Not emitted'], missing, expansion};
  if (!record) return {...entry, classification: 'UNSUPPORTED_MISSING_COMPONENT', reasons: ['No authority record'], missing: ['record'], expansion};
  for (const k of ['context', 'period', 'domain', 'horizon', 'direction', 'materialFingerprint', 'semanticOwner', 'fixtureKey']) {
    if (entry[k] !== record.expected[k]) missing.push(`binding:${k}`);
  }
  if (!entry.text || sha(entry.text) !== record.textSha256) expansion.push('Emitted text differs from its own source-bound text; this is NOT Candidate equality');
  if (!entry.templateId || entry.templateId !== record.template.id) missing.push('template/rule binding');
  const ownerKey = e => [e.semanticOwner, e.context, e.period, e.horizon].join('|');
  if (peers.filter(e => e.emitted && ownerKey(e) === ownerKey(entry)).length !== 1) missing.push('duplicate semantic owner');
  if (record.evidenceOwner === entry.claimId || record.dependencies?.includes(entry.claimId)) missing.push('self-referential owner');
  if (new Set(record.dependencies || []).size !== (record.dependencies || []).length) missing.push('duplicate dependency owner');
  for (const role of ROLES) {
    const refs = record.chain[role] || [];
    if (!refs.length || refs.some(r => !r.resolved)) missing.push(role);
  }
  // Specificity review is a transparent, quoted machine editorial annotation;
  // hashes and exact spans bind the judgement, but cannot automate semantic truth.
  for (const finding of record.semanticFindings || []) {
    if (!entry.text.includes(finding.exactSpan)) missing.push('unbound semantic finding');
    else if (finding.kind === 'EXPANSION') expansion.push(finding.reason);
  }
  if (record.template.fixtureKey && record.template.fixtureKey !== entry.fixtureKey) missing.push('wrong-fixture golden/template authority');
  if (record.template.kind === 'OWNER_APPROVED' && !record.template.ownerAcceptance?.resolved) missing.push('Owner acceptance reference');
  if (record.template.kind === 'SOURCE_DIRECT' && !record.template.directSemantics?.resolved) missing.push('direct source semantic certificate');
  const classification = expansion.length ? 'UNSUPPORTED_SEMANTIC_EXPANSION' : missing.length ? 'UNSUPPORTED_MISSING_COMPONENT' :
    record.template.kind === 'SOURCE_DIRECT' ? 'SOURCE_CHAIN_SUPPORTED' :
    record.template.kind === 'OWNER_APPROVED' ? 'OWNER_APPROVED_TEMPLATE_SUPPORTED' : 'OWNER_TEMPLATE_REVIEW_REQUIRED';
  return {...entry, classification, missing, expansion,
    reasons: [...missing.map(x => `Missing/invalid: ${x}`), ...expansion,
      ...(!missing.length && !expansion.length ? [classification === 'OWNER_TEMPLATE_REVIEW_REQUIRED'
        ? 'Applicable components and actual synthesis provenance resolved. This generalized wording is an interpretation, not accepted exact copy or direct source prose. Owner template/content review remains required.'
        : 'Complete resolved chain with the stated source/Owner authority and applicable fixture scope. Not predictive accuracy or new Owner acceptance.'] : [])]};
}

export function summarize(entries, slots = []) {
  const counts = Object.fromEntries(CLASSES.map(k => [k, entries.filter(e => e.classification === k).length]));
  const required = slots.filter(s => s.required && s.applicable);
  const coverageComplete = required.length > 0 && required.every(s => s.supported && !s.missing && !s.duplicate);
  const failed = entries.some(e => e.classification.startsWith('UNSUPPORTED_'));
  const allSupported = entries.length > 0 && entries.every(supported);
  const status = failed ? 'ACTUAL 00:35 CLAIM AUTHORITY NO-GO' : allSupported && coverageComplete
    ? 'ACTUAL 00:35 AUTHORITY TECHNICALLY SUPPORTED — PENDING OWNER CONTENT REVIEW'
    : 'ACTUAL 00:35 PARTIAL AUTHORITY — PRODUCT COVERAGE NO-GO';
  return {entries: entries.length, counts, supported: entries.filter(supported).length,
    componentCompletePendingReview: counts.OWNER_TEMPLATE_REVIEW_REQUIRED, coverageComplete, status};
}

function codeReference(symbol, path = RUNTIME) {
  const text = fs.readFileSync(path, 'utf8');
  return {reference: path, symbol, sourceSha256: fileSha(path), resolved: text.includes(symbol), roleLimit: 'Generation provenance only; not independent semantic acceptance'};
}

// Explicit audit bridges to existing sources; NOT new runtime rules or Owner approval.
// Domain components can be combined under Contract V1; authors need not differ.
// None of these bridges inherit Candidate paragraph acceptance for actual 00:35.
const DOMAIN_BRIDGES = {
  overview: ['source.T0003-SRC-42-62-WORK', 'source.T0003-SRC-42-62-FINANCE', 'canon.mahabhut.p39.sri_owns_finance'],
  past: ['canon.mahabhut.p39.det_owns_career'],
  current: ['source.T0003-SRC-42-62-FLOW', 'canon.mahabhut.p39.sri_owns_finance'],
  work: ['source.T0003-SRC-42-62-WORK'],
  finance: ['source.T0003-SRC-42-62-FINANCE', 'canon.mahabhut.p39.sri_owns_finance'],
  relationship: ['canon.mahabhut.p16.venus_owns_relationship_male', 'canon.mahabhut.p28.venus_owns_relationship'],
  health: ['canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน'],
  support: ['source.T0003-SRC-42-62-SUPPORT'],
  rolling12: ['source.T0003-SRC-42-62-WORK', 'source.T0003-SRC-42-62-FINANCE'],
  // Mercury/family and speech are compatible references for parts, not an
  // established authority for the actual quiet-relationship termination clause.
  next: ['canon.mahabhut.p28.mercury_owns_family', 'canon.mahabhut.p33.mercury_relates_attribute_profession_นักพูด'],
};
const REALIZERS = {overview: '_overviewPrediction(', past: '_pastPeriodPrediction(', current: '_currentPeriodPrediction(',
  work: '_directDomainPrediction(', finance: '_directDomainPrediction(', relationship: '_directDomainPrediction(', health: '_directDomainPrediction(',
  support: '_supportPrediction(', rolling12: '_directDomainPrediction(', next: '_nextPeriodPrediction('};

export function actualAuthority(raw) {
  const registry = read(REGISTRY);
  const contract = read(CONTRACT);
  assert.equal(contract.typedForecastRule.standalonePredictionAllowed, false);
  const fixtureKey = JSON.stringify({input: raw.input, asOf: raw.asOf});
  const decisions = raw.plan.decisions.filter(d => d.kind === 'prediction');
  const entries = decisions.map(d => ({claimId: d.claimId, emitted: d.emitted, text: d.text, section: d.section,
    semanticOwner: d.semanticOwner, templateId: d.binding?.realizerId, runtimeRuleId: d.claimId,
    context: d.binding?.context, period: d.binding?.period, domain: d.domain, horizon: d.binding?.horizon,
    direction: d.binding?.directionBand, materialFingerprint: d.binding?.materialFingerprint, fixtureKey}));
  const records = entries.map((e, i) => {
    const d = decisions[i], b = d.binding;
    const row = raw.periodRows.find(p => p.matrixApplicationId === b?.selectorApplicationId);
    const selector = resolveReference(`selector.${b?.selectorApplicationId}`, registry);
    selector.resolved = selector.resolved && Boolean(row) && ['contextId', 'planet', 'taksaRole', 'mahabhutHouse', 'periodStatus'].every(k => row[k] === selector.value[k]) && `${row.ageStart}-${row.ageEnd}` === selector.value.agePeriod;
    const actualMaterials = (b?.sourceComponents || []).map(s => raw.typedMaterials.find(m => m.materialFingerprint === s)).filter(Boolean);
    const primary = raw.typedMaterials.find(m => m.materialFingerprint === b?.materialFingerprint);
    const direction = primary ? {resolved: primary.band === b.directionBand && primary.horizon === b.horizon &&
      (b.domain === 'life_path' || primary.domain === b.domain),
      reference: 'fresh runtime /typedMaterials', value: primary, sourceOwner: primary.sourceOwnership, roleLimit: 'Direction/timing only; not a standalone prediction'}
      : {resolved: Boolean(row) && row.periodStatus === b?.directionBand && b.materialFingerprint === `status=${row.periodStatus}|role=${row.taksaRole}|house=${row.mahabhutHouse}`,
        reference: selector.reference, locator: selector.locator, sourceSha256: selector.sourceSha256, value: row?.periodStatus, roleLimit: 'Period trend only; not event prose'};
    const bridges = (DOMAIN_BRIDGES[e.semanticOwner] || []).map(id => resolveReference(id, registry));
    for (const bridge of bridges) {
      const v = bridge.value;
      // General production Canon is applied to the actual planet/role, not to a fixture ID.
      if (bridge.id.startsWith('canon.')) bridge.resolved = bridge.resolved && Boolean(row) &&
        [ `planet.${row.planet}`, `taksaRole.${row.taksaRole}` ].includes(v?.subject) && (!v.condition || raw.input.gender === 'ชาย');
      if (bridge.id.startsWith('source.T0003-SRC-42-62')) bridge.resolved = bridge.resolved && row?.ageStart === 42 && row?.ageEnd === 62 && raw.contextId === 'mahabhut2537.rem0.saturday';
      bridge.auditRole = 'Compatible existing domain component; not inherited exact-Candidate acceptance';
    }
    const semanticFindings = [];
    const currentTransitionSpan = `อายุ ${raw.currentAge} ปีเป็นช่วงเปลี่ยนผ่าน`;
    if (e.text.includes(currentTransitionSpan) && row && raw.currentAge > row.ageStart && raw.currentAge < row.ageEnd &&
        raw.typedMaterials.filter(m => m.horizon === 'current').every(m => !m.spansTransition)) {
      semanticFindings.push({kind: 'EXPANSION', exactSpan: currentTransitionSpan,
        reason: `Age ${raw.currentAge} is inside ${row.ageStart}–${row.ageEnd}; current typed spansTransition=false. The unconditional current-period realizer asserts a transition without an applicable transition/timing rule. Candidate acceptance at 00:03 is not such a rule for this input.`});
    }
    if (e.semanticOwner === 'next' && primary?.domain === 'relationship' && !bridges.some(r => r.value?.object === 'domain.relationship')) {
      bridges.push({id: 'actual-next-relationship-domain-and-termination-binding', resolved: false,
        reason: 'The actual next paragraph adds a quiet-relationship change/termination branch. Its emitted aggregate domain reference has no resolved entry; the compatible Mercury family/speech references do not establish that relationship proposition. No applicable domain-to-template binding was found in the existing chain. This is a missing binding, not proof that no possible authority exists.'});
    }
    const templateRef = codeReference(REALIZERS[e.semanticOwner] || 'UNRESOLVED_REALIZER');
    templateRef.resolved = templateRef.resolved && b.realizedReaderText === d.text && b.semanticOwner === d.semanticOwner && b.domain === d.domain;
    const timing = {...selector, scope: {ageStart: row?.ageStart, ageEnd: row?.ageEnd, horizon: e.horizon}};
    if (e.horizon === 'next12Months') {
      const start = raw.asOf.slice(0, 10), endDate = new Date(`${start}T00:00:00Z`);
      endDate.setUTCFullYear(endDate.getUTCFullYear() + 1); endDate.setUTCDate(endDate.getUTCDate() - 1);
      timing.rolling = {start, end: endDate.toISOString().slice(0, 10), timeZone: 'Asia/Bangkok', basis: 'civil asOf / anniversary minus one day'};
    }
    const expected = {...e, context: raw.contextId, period: row ? `${row.ageStart}-${row.ageEnd}` : null,
      direction: primary?.band ?? row?.periodStatus};
    return {claimId: e.claimId, expected, textSha256: sha(d.text), evidenceOwner: `actual-audit:${d.semanticOwner}:${b?.selectorApplicationId}`,
      dependencies: [], rawDecision: d, actualPeriod: row, actualMaterials, template: {id: b?.realizerId, kind: 'INTERPRETATION_PENDING', ownerAcceptance: null},
      chain: {selector: [selector], domain: bridges, direction: [direction], timing: [timing], template: [templateRef],
        conflict: [resolveReference('conflict.contract-boundaries', registry)], certainty: [resolveReference('certainty.product-interpretation-contract-v1', registry)]},
      semanticFindings, limitations: ['Resolved chain roles are not predictive accuracy.', 'Machine semantic review is not Owner acceptance.',
        'Actual runtime evidenceRefs are preserved separately from these explicit audit bridges; no citation was added to runtime.',
        'Generic synthesis/cause/strength/certainty requires Owner review even when compatible component references resolve.']};
  });
  const results = entries.map((e, i) => validateClaim(e, records[i], entries));
  return {entries: results, records};
}

// Real positive control: existing Owner-accepted golden paragraph + all resolved
// chain roles, bound to its actual 00:03 scope. Never counted among actual 00:35.
export function goldenPositiveControl() {
  const map = read('docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json');
  const oracle = read('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
  const c = map.claims.find(c => c.readerClaimId === 'RC11-K-PAST-01');
  const o = oracle.claims.find(o => o.readerClaimId === c.readerClaimId);
  assert.equal(c.exactAcceptedText, o.exactText);
  const entry = {claimId: c.readerClaimId, text: c.exactAcceptedText, emitted: true, context: c.contextId,
    period: c.periodBinding, domain: c.domain, horizon: 'past-life-period', direction: 'source-family-constraints',
    materialFingerprint: 'source.T0003-SRC-0-10-FAMILY-CONSTRAINT', semanticOwner: c.ownerId,
    fixtureKey: 'Candidate0011/00:03/2026-08-29', templateId: c.readerClaimId};
  const ownerRef = {reference: 'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json', sourceSha256: fileSha('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json'),
    locator: c.ownerAcceptanceRef, resolved: c.authorityClass === 'OWNER_ACCEPTED_PRODUCT_INTERPRETATION' && o.exactText === c.exactAcceptedText};
  const chain = Object.fromEntries(['selector', 'domain', 'direction', 'timing', 'conflict', 'certainty'].map(k => [k, c[`${k}Refs`].map(id => resolveReference(id))]));
  chain.template = [ownerRef];
  return {entry, record: {expected: {...entry}, textSha256: sha(entry.text), evidenceOwner: 'Owner acceptance ' + c.ownerAcceptanceRef,
    dependencies: [], chain, template: {id: entry.templateId, kind: 'OWNER_APPROVED', ownerAcceptance: ownerRef, fixtureKey: entry.fixtureKey}, semanticFindings: []}};
}

export function semanticSlots(raw, entries) {
  const decisions = raw.plan.decisions;
  const definitions = [
    ['overview', 'ภาพรวมชีวิต'], ...raw.periodRows.filter(p => p.ageEnd < raw.currentAge).map(p => [`past:${p.ageStart}-${p.ageEnd}`, `อดีต ${p.ageStart}–${p.ageEnd}`]),
    ['current', 'ปัจจุบัน'], ['work', 'การงาน'], ['finance', 'การเงิน'], ['relationship', 'ความสัมพันธ์'], ['health', 'สุขภาพ'],
    ['support', 'โชคลาภ/แรงสนับสนุน'], ['rolling12', '12 เดือนข้างหน้า'], ['next', 'ช่วงชีวิตถัดไป'],
    ['summary', 'สรุป'], ['advice', 'คำแนะนำ'], ['disclosure', 'ข้อจำกัด']];
  return definitions.map(([id, label]) => {
    const [owner, period] = id.split(':');
    const matches = decisions.filter(d => d.emitted && d.semanticOwner === owner && (!period || d.periodBinding === period));
    const children = matches.flatMap(d => d.binding?.sourceComponents || []).map(id => entries.find(e => e.claimId === id)).filter(Boolean);
    const isPrediction = !['summary', 'advice', 'disclosure'].includes(owner);
    const ok = matches.length === 1 && (isPrediction ? entries.some(e => e.claimId === matches[0].claimId && supported(e)) :
      owner === 'summary' ? children.length > 0 && children.every(supported) :
        owner === 'advice' ? matches[0].binding?.realizerId === 'advice-owner-v2' : matches[0].binding?.realizerId === 'disclosure-contract-v1');
    return {id, label, required: true, applicable: true, emitted: matches.length, supported: ok, missing: matches.length === 0,
      duplicate: Math.max(0, matches.length - 1), claimIds: matches.map(d => d.claimId),
      supportMeaning: isPrediction ? 'Whole prediction authority classification' : owner === 'summary' ? 'Propagates parent prediction support, not a new independent authority' : 'Non-predictive composition provenance only; not predictive authority or language acceptance'};
  });
}

export function compareExtractions(a, b) {
  const names = [RAW_NAME, 'OR5_RAW_0003_20260829.json', 'OR5_RAW_0003_20260807.json', 'OR5_UNKNOWN_RUNTIME_EVIDENCE.json'];
  const comparisons = names.map(name => ({name, firstSha256: fileSha(`${a}/${name}`), secondSha256: fileSha(`${b}/${name}`)}));
  return {comparisons, pairs: comparisons.length, mismatches: comparisons.filter(x => x.firstSha256 !== x.secondSha256).length};
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const raw = read(process.argv[2] || `build/or5r-neutral-v2-run1/${RAW_NAME}`);
  const result = actualAuthority(raw), slots = semanticSlots(raw, result.entries);
  console.log(JSON.stringify({...summarize(result.entries, slots), slots}, null, 2));
}
