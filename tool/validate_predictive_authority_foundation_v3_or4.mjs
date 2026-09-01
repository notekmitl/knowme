#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const clone = (value) => structuredClone(value);
const interval = (period) => {
  const match = String(period).match(/^(\d+)-(\d+)$/u);
  return match ? [Number(match[1]), Number(match[2])] : null;
};
const periodWithin = (claimPeriod, signalPeriod) => {
  const claim = interval(claimPeriod);
  const signal = interval(signalPeriod);
  return Boolean(claim && signal && claim[0] >= signal[0] && claim[1] <= signal[1]);
};
const signalCategory = (signal) => {
  if (signal.signalType === 'SOURCE_DIRECT_EVENT') return 'SOURCE_DIRECT_EVENT';
  if (signal.signalType === 'SOURCE_DIRECT_TREND') return 'SOURCE_DIRECT_TREND';
  if (signal.signalType === 'SOURCE_PLACEMENT_FACT') return 'SOURCE_PERIOD_OR_PLACEMENT';
  if (signal.signalType === 'RESEARCH_DOMAIN_AUTHORITY' || signal.signalType === 'CANON_DOMAIN_OR_DIRECTION') return 'DOMAIN_AUTHORITY';
  if (signal.polarity && signal.polarity !== 'NEUTRAL') return 'POLARITY_AUTHORITY';
  return signal.signalType;
};

export function evidenceIndex(ledger) {
  return new Map([...ledger.sourceSignals, ...ledger.canonSignals, ...ledger.researchSignals].map((row) => [row.signalId, row]));
}

export function recomputeEvidenceOwners(signalRefs, ledger) {
  const byId = evidenceIndex(ledger);
  const signals = signalRefs.map((ref) => byId.get(ref)).filter(Boolean);
  return [...new Set(signals.map((row) => row.evidenceOwnerId))].sort();
}

export function validateClaimAgainstRule(claim, ledger, rulebook, allClaims = []) {
  const errors = [];
  const byId = evidenceIndex(ledger);
  const rule = rulebook.rules.find((row) => row.ruleId === claim.ruleId);
  if (!rule) return ['RULE_NOT_FOUND'];
  if (rule.summaryOnly) {
    const children = (claim.composedClaimRefs ?? []).map((ref) => allClaims.find((row) => row.claimId === ref)).filter(Boolean);
    if (children.length !== (claim.composedClaimRefs ?? []).length || children.length === 0) errors.push('SUMMARY_CHILD_REF_INVALID');
    const childOwners = new Set(children.flatMap((row) => row.semanticMotifs ?? []));
    if ((claim.semanticMotifs ?? []).some((motif) => !childOwners.has(motif))) errors.push('SUMMARY_ADDS_NEW_PREDICTION');
    if (claim.classification !== 'COMPOSITIONAL_SUMMARY') errors.push('SUMMARY_CLASSIFICATION');
    return errors;
  }
  if (claim.authorityTier === 'D') return claim.fullReaderText ? ['TIER_D_READER_CLAIM'] : [];
  const signals = (claim.signalRefs ?? []).map((ref) => byId.get(ref));
  if (signals.some((row) => !row)) errors.push('SIGNAL_REF_NOT_FOUND');
  const validSignals = signals.filter(Boolean);
  const owners = recomputeEvidenceOwners(claim.signalRefs ?? [], ledger);
  if (owners.length < rule.minimumIndependentEvidenceOwners) errors.push('INSUFFICIENT_RECOMPUTED_EVIDENCE_OWNERS');
  if (claim.independentSignalCount !== undefined && claim.independentSignalCount !== owners.length) errors.push('STORED_INDEPENDENT_COUNT_MISMATCH');
  if (claim.authorityTier === 'A' && !validSignals.some((row) => row.semanticRecord && row.signalType === 'SOURCE_DIRECT_EVENT')) errors.push('TIER_A_SEMANTIC_SOURCE_RECORD_MISSING');
  if (claim.authorityTier === 'B' && !validSignals.some((row) => row.semanticRecord && row.signalType === 'SOURCE_DIRECT_TREND')) errors.push('TIER_B_SEMANTIC_SOURCE_RECORD_MISSING');
  for (const required of rule.requiredSignalTypes) {
    const matched = validSignals.some((signal) => signalCategory(signal) === required || (required === 'POLARITY_AUTHORITY' && signal.polarity !== 'NEUTRAL'));
    if (!matched) errors.push(`REQUIRED_SIGNAL_TYPE_MISSING:${required}`);
  }
  const domainSignals = validSignals.filter((row) => row.domains?.length && !row.domains.includes('life_direction'));
  if (domainSignals.length && !domainSignals.every((row) => row.domains.includes(claim.domain))) errors.push('DOMAIN_MISMATCH');
  if (validSignals.some((row) => row.period && !String(row.period).includes('|') && !periodWithin(claim.period, row.period))) errors.push('PERIOD_MISMATCH');
  const directional = validSignals.map((row) => row.polarity).filter((value) => value && value !== 'NEUTRAL');
  if (new Set(directional).size > 1 && claim.conflictResult !== 'OMIT' && claim.conflictResult !== 'NARROWED') errors.push('POLARITY_CONFLICT_NOT_HANDLED');
  if (claim.polarity && directional.length && !directional.includes(claim.polarity) && claim.conflictResult !== 'NARROWED') errors.push('POLARITY_MISMATCH');
  if (claim.timingGranularity && validSignals.some((row) => row.timingGranularity === 'LIFE_PERIOD') && ['YEAR', 'MONTH', 'DAY'].includes(claim.timingGranularity)) errors.push('TIMING_GRANULARITY_ESCALATION');
  if (claim.containsCausalWording && !validSignals.some((row) => row.causalAuthority === true)) errors.push('CAUSAL_WORDING_WITHOUT_AUTHORITY');
  if (claim.authorityTier === 'C' && validSignals.every((row) => row.signalType === 'SOURCE_PLACEMENT_FACT' || row.directOrDerived === 'DERIVED')) errors.push('PLACEMENT_ONLY_TIER_C');
  if (claim.readerStrength === 'SPECIFIC_EVENT' && rule.allowedStrength !== 'DIRECT_EVENT_PARAPHRASE_ONLY') errors.push('READER_TEXT_STRONGER_THAN_EVIDENCE');
  return [...new Set(errors)];
}

export function validateRobustnessEnvelope(value) {
  const errors = [];
  if ('knownSpecs' in value || value.generationMode !== 'COMPUTED_FROM_FIXTURE_SELECTOR_AND_DECISION_FUNCTION') errors.push('HARDCODED_ROBUSTNESS_COUNTERS_OR_SPECS');
  if (value.countsProvenance !== 'RECOMPUTED_FROM_OUTPUT_PROFILES') errors.push('HARDCODED_ROBUSTNESS_COUNTERS_OR_SPECS');
  return [...new Set(errors)];
}

export function validateAuditSeparation(value) {
  const errors = [];
  if ('completeReadPasses' in value || value.machineAudit?.some((row) => ['naturalness', 'friendliness', 'content_quality'].includes(row.dimension) && row.result === 'PASS')) errors.push('STATIC_TWO_PASS_AUDIT');
  if (value.humanReview !== 'PENDING') errors.push('HUMAN_REVIEW_NOT_PENDING');
  return errors;
}

export function runOr4NegativeControls() {
  const ledger = readJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json');
  const rulebook = readJson('knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.json');
  const base = {
    claimId: 'NC-BASE', fullReaderText: 'ช่วงอายุ 42-62 ปีมีงานทำ', classification: 'PREDICTION', authorityTier: 'A', ruleId: 'OR4-A-DIRECT-EVENT',
    signalRefs: ['T0003-SRC-42-62-WORK'], independentSignalCount: 1, domain: 'work', period: '42-62', polarity: 'POSITIVE', timingGranularity: 'LIFE_PERIOD', conflictResult: 'NONE', containsCausalWording: false, readerStrength: 'DIRECT_EVENT', semanticMotifs: ['work-available'],
  };
  const controls = [];
  const run = (id, expectedCode, prepare) => {
    const localLedger = clone(ledger);
    const claim = clone(base);
    const context = { ledger: localLedger, claim, rulebook: clone(rulebook), allClaims: [claim] };
    prepare(context);
    const observedCodes = validateClaimAgainstRule(context.claim, context.ledger, context.rulebook, context.allClaims);
    controls.push({ id, expectedCode, rejected: observedCodes.includes(expectedCode), observedCodes });
  };
  run('stored-count-99-one-owner', 'STORED_INDEPENDENT_COUNT_MISMATCH', ({ claim }) => { claim.independentSignalCount = 99; });
  run('one-clause-split-two-atoms', 'INSUFFICIENT_RECOMPUTED_EVIDENCE_OWNERS', ({ ledger: l, claim, rulebook: rb }) => { const x = clone(l.sourceSignals.find((row) => row.signalId === 'T0003-SRC-42-62-WORK')); x.signalId = 'NC-SPLIT'; l.sourceSignals.push(x); claim.authorityTier = 'C'; claim.ruleId = 'OR4-C-MULTI-OWNER'; claim.signalRefs = ['T0003-SRC-42-62-WORK', 'NC-SPLIT']; claim.independentSignalCount = 1; rb.rules.find((row) => row.ruleId === claim.ruleId).requiredSignalTypes = []; });
  run('two-derived-records-one-parent', 'INSUFFICIENT_RECOMPUTED_EVIDENCE_OWNERS', ({ ledger: l, claim, rulebook: rb }) => { const x = clone(l.canonSignals.find((row) => row.signalId === 'T0003-CANON-DET-WORK')); const y = clone(x); x.signalId = 'NC-DERIVED-1'; y.signalId = 'NC-DERIVED-2'; l.canonSignals.push(x, y); claim.authorityTier = 'C'; claim.ruleId = 'OR4-C-MULTI-OWNER'; claim.signalRefs = [x.signalId, y.signalId]; claim.independentSignalCount = 1; rb.rules.find((row) => row.ruleId === claim.ruleId).requiredSignalTypes = []; });
  run('tier-c-required-canon-missing', 'REQUIRED_SIGNAL_TYPE_MISSING:DOMAIN_AUTHORITY', ({ claim }) => { claim.authorityTier = 'C'; claim.ruleId = 'OR4-C-MULTI-OWNER'; claim.signalRefs = ['T0003-SRC-42-62-WORK', 'T0003-SRC-42-62-SUPPORT']; claim.independentSignalCount = 2; });
  run('domain-mismatch', 'DOMAIN_MISMATCH', ({ claim }) => { claim.domain = 'health'; });
  run('period-mismatch', 'PERIOD_MISMATCH', ({ claim }) => { claim.period = '63-79'; });
  run('polarity-conflict-not-omitted', 'POLARITY_CONFLICT_NOT_HANDLED', ({ ledger: l, claim }) => { const x = clone(l.sourceSignals.find((row) => row.signalId === 'T0003-SRC-42-62-WORK')); x.signalId = 'NC-NEG'; x.evidenceOwnerId = 'EO-NC-NEG'; x.polarity = 'NEGATIVE'; l.sourceSignals.push(x); claim.signalRefs.push(x.signalId); claim.independentSignalCount = 2; });
  run('placement-only-prediction', 'PLACEMENT_ONLY_TIER_C', ({ claim, rulebook: rb }) => { claim.authorityTier = 'C'; claim.ruleId = 'OR4-C-MULTI-OWNER'; claim.signalRefs = ['T0003-SRC-42-62-PLACEMENT', 'T0003-CANON-STRONG-HOUSE']; claim.independentSignalCount = 1; rb.rules.find((row) => row.ruleId === claim.ruleId).requiredSignalTypes = []; rb.rules.find((row) => row.ruleId === claim.ruleId).minimumIndependentEvidenceOwners = 1; });
  run('causal-wording-no-causal-authority', 'CAUSAL_WORDING_WITHOUT_AUTHORITY', ({ claim }) => { claim.containsCausalWording = true; });
  run('tier-a-no-semantic-source', 'TIER_A_SEMANTIC_SOURCE_RECORD_MISSING', ({ claim }) => { claim.signalRefs = ['T0003-CANON-JUPITER-LEARNING']; claim.domain = 'learning'; claim.period = '11-29'; claim.polarity = 'NEUTRAL'; });
  run('tier-b-no-semantic-source', 'TIER_B_SEMANTIC_SOURCE_RECORD_MISSING', ({ claim }) => { claim.authorityTier = 'B'; claim.ruleId = 'OR4-B-DIRECT-TREND'; claim.signalRefs = ['T0003-CANON-JUPITER-LEARNING']; claim.domain = 'learning'; claim.period = '11-29'; claim.polarity = 'NEUTRAL'; });
  run('summary-adds-new-prediction', 'SUMMARY_ADDS_NEW_PREDICTION', ({ claim, allClaims }) => { const child = clone(base); child.claimId = 'CHILD'; allClaims.push(child); claim.ruleId = 'OR4-SUMMARY-COMPOSITION'; claim.authorityTier = 'COMPOSITIONAL'; claim.classification = 'COMPOSITIONAL_SUMMARY'; claim.composedClaimRefs = ['CHILD']; claim.semanticMotifs = ['new-romance-event']; });
  const hardcodedRobustness = validateRobustnessEnvelope({ knownSpecs: [{ tier: 'A', readerText: 'preset' }], generationMode: 'PRESET', countsProvenance: 'STATIC' });
  controls.push({ id: 'hardcoded-robustness-counters', expectedCode: 'HARDCODED_ROBUSTNESS_COUNTERS_OR_SPECS', rejected: hardcodedRobustness.includes('HARDCODED_ROBUSTNESS_COUNTERS_OR_SPECS'), observedCodes: hardcodedRobustness });
  const staticAudit = validateAuditSeparation({ completeReadPasses: 2, machineAudit: [{ dimension: 'naturalness', result: 'PASS' }], humanReview: 'PENDING' });
  controls.push({ id: 'static-two-pass-audit', expectedCode: 'STATIC_TWO_PASS_AUDIT', rejected: staticAudit.includes('STATIC_TWO_PASS_AUDIT'), observedCodes: staticAudit });
  return controls;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const controls = runOr4NegativeControls();
  console.log(JSON.stringify({ status: controls.every((row) => row.rejected) ? 'PASS' : 'FAIL', controls }, null, 2));
  if (controls.some((row) => !row.rejected)) process.exitCode = 1;
}
