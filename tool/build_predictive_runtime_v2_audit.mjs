#!/usr/bin/env node

import fs from 'node:fs';

const raw = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_RAW_300_PROFILE_AUDIT.json', 'utf8'));
const contexts = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json', 'utf8'));
const periods = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_392_PERIOD_RUNTIME_MAPPING.json', 'utf8'));
const bindings = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_CLAIM_LEVEL_BINDINGS.json', 'utf8'));
const quality = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_CONTENT_QUALITY_AUDIT.json', 'utf8'));
const reuse = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_OWNER_REUSE_AUDIT.json', 'utf8'));
const comparison = JSON.parse(fs.readFileSync('docs/PREDICTIVE_RUNTIME_V2_GOLDEN_NEIGHBOR_COMPARISON.json', 'utf8'));
const runtimeSource = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart', 'utf8');
const generated = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart', 'utf8');
const summary = raw.summary;

const errors = [];
if (raw.profiles.length !== 300) errors.push(`profiles=${raw.profiles.length}`);
if (Object.keys(contexts.contexts).length !== 49) errors.push(`contexts=${Object.keys(contexts.contexts).length}`);
if (periods.rows.length !== 392) errors.push(`periods=${periods.rows.length}`);
if (summary.counts.knownProfilesWithCompleteV2Report !== 225) errors.push('known-complete');
if (summary.counts.knownProfilesUsingBaselineFallback !== 0) errors.push('baseline-fallback');
if (summary.counts.unknownProfilesFailClosed !== 75) errors.push('unknown-fail-closed');
if (summary.counts.contextsWithCompleteContent !== 49) errors.push('context-content');
if (summary.counts.periodsMapped !== 392 || summary.counts.periodsUnmapped !== 0) errors.push('period-mapping');
for (const key of ['unsupportedClaims', 'unexpectedFixtureSpecificBranches', 'fixtureReferenceLeakage', 'evidenceBindingMismatches', 'knownToUnknownLeakage', 'integrityErrors']) {
  if (summary.counts[key] !== 0) errors.push(`${key}=${summary.counts[key]}`);
}
for (const [key, value] of Object.entries(summary.contentQualityCounters)) {
  if (value !== 0) errors.push(`quality.${key}=${value}`);
}
for (const key of ['missing', 'mismatch', 'manualAssertionWithoutBinding', 'fixtureReferenceLeakage']) {
  if (bindings.summary[key] !== 0) errors.push(`bindings.${key}=${bindings.summary[key]}`);
}
if (bindings.summary.entries !== summary.counts.claimLevelBindings) errors.push('binding-entry-count');
if (quality.summary.humanReviewContexts !== 49 || quality.summary.humanReviewFailures !== 0) errors.push('human-review');
if (reuse.summary.evidenceMismatchedReuse !== 0) errors.push('evidence-mismatched-reuse');
if (comparison.status !== 'PASS') errors.push('golden-neighbor-comparison');
if (runtimeSource.includes('int get fixtureSpecificBranches => 0')) errors.push('hardcoded-fixture-metric');
if (generated.includes('runtimePredictiveV2AcceptedContext')) errors.push('single-accepted-context-constant');
if ((generated.match(/RuntimePredictivePeriodRow\(/gu) ?? []).length !== 392) errors.push('generated-period-count');
if (summary.status !== 'PASS_PREDICTIVE_RUNTIME_V2_OR2_EDITORIAL_AND_EVIDENCE') errors.push(`status=${summary.status}`);

const finalSummary = {
  ...summary,
  status: errors.length === 0 ? summary.status : 'FAIL',
  verifierErrors: errors,
};
fs.writeFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', `${JSON.stringify(finalSummary, null, 2)}\n`);
fs.writeFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.md', `# Predictive Runtime V2 OR2 Editorial and Evidence Audit

Status: **${finalSummary.status}**

- Actual representative context reports: ${summary.counts.contextsWithCompleteContent}/49
- 300-profile Known complete V2: ${summary.counts.knownProfilesWithCompleteV2Report}/225
- Known baseline fallback: ${summary.counts.knownProfilesUsingBaselineFallback}
- Unknown fail-closed: ${summary.counts.unknownProfilesFailClosed}/75
- Actual 392-period resolver mapping: ${summary.counts.periodsMapped}/392
- Unsupported claims / unexpected fixture branches / fixture-reference leakage / binding mismatches / Known→Unknown leakage: ${summary.counts.unsupportedClaims} / ${summary.counts.unexpectedFixtureSpecificBranches} / ${summary.counts.fixtureReferenceLeakage} / ${summary.counts.evidenceBindingMismatches} / ${summary.counts.knownToUnknownLeakage}
- Claim-level evidence bindings: ${summary.counts.claimLevelBindings}
- Two-round human review: ${summary.humanReviewContexts}/49 contexts; failures ${summary.humanReviewFailures}
- Reused paragraphs with mismatched evidence: ${reuse.summary.evidenceMismatchedReuse}
- Emitted predictions min/median/max: ${summary.counts.minimumEmittedPredictions}/${summary.counts.medianEmittedPredictions}/${summary.counts.maximumEmittedPredictions}
- Evidence verifier errors: ${errors.length}

The 392-row ledger is selector/timing authority only. Reader direction is bound to Production Canon and typed forecast material under Product Interpretation Contract V1; raw OCR heuristics are never promoted.
`);

if (errors.length > 0) {
  console.error(JSON.stringify({ status: 'FAIL', errors }));
  process.exitCode = 1;
} else {
  console.log(JSON.stringify({ status: finalSummary.status, counts: finalSummary.counts }));
}
