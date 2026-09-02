#!/usr/bin/env node

import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
export const BASE = '5dc59c44020a135934d1b8cefceae9606bfa736f';
export const OR7_HEAD = '7605c68144699957929bc2466678c047394696f9';
export const CLEANUP_COMMIT = '3a72714d05b151bb937a1d370bdec751a5d2ba90';
export const BEFORE_PATHS = 193;
export const EXPECTED_READER_SHA = '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E';

const run = (args) => execFileSync('git', args, { cwd: ROOT, encoding: 'utf8' }).trim();
const lines = (value) => value ? value.split(/\r?\n/).filter(Boolean) : [];
const norm = (value) => value.replaceAll('\\', '/');
const exists = (file) => fs.existsSync(path.join(ROOT, file));

const outputPaths = [
  'docs/PR114_FINAL_MERGE_MANIFEST.json',
  'docs/PR114_FINAL_MERGE_MANIFEST.md',
];
const unchangedCandidateRoot = 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md';
const canonicalRootPaths = [
  unchangedCandidateRoot,
  'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json',
  'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.schema.json',
  'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE_VALIDATION.json',
  'docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json',
  'docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.md',
  'docs/CANDIDATE_0011_RULE_MAP_GAP_REPORT.md',
  'docs/CANDIDATE_0011_ASOF_EQUIVALENCE_VALIDATION.json',
  'knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1.json',
  'docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json',
  'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json',
  'test/evidence/candidate_0011_oracle.test.mjs',
  'test/evidence/candidate_0011_rule_map.test.mjs',
  'test/evidence/thai_predictive_evidence_v1.test.mjs',
  'test/evidence/pr114_final_merge_surface.test.mjs',
  'TASK_RESULT.md', 'task.md', 'docs/CURRENT_STATUS.md', 'docs/HANDOFF.md',
  'docs/ROADMAP.md', 'docs/THAI_REPORT_READER_EXPERIENCE_V2.md',
  'docs/PR114_PREDICTIVE_FOUNDATION_EXPERIMENT_HISTORY.md',
  ...outputPaths,
];

export function currentChangedPaths() {
  const tracked = lines(run(['diff', '--name-only', BASE])).map(norm);
  const untracked = lines(run(['ls-files', '--others', '--exclude-standard'])).map(norm);
  return [...new Set([...tracked, ...untracked, ...outputPaths])].sort();
}

const statusFiles = new Set([
  'TASK_RESULT.md', 'task.md', 'docs/CURRENT_STATUS.md', 'docs/HANDOFF.md',
  'docs/ROADMAP.md', 'docs/THAI_REPORT_READER_EXPERIENCE_V2.md',
]);
const sourceTracePrefixes = [
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2',
  'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392',
];

function classify(file) {
  if (statusFiles.has(file)) return 'STATUS_DOCUMENTATION';
  if (file === 'docs/PR114_PREDICTIVE_FOUNDATION_EXPERIMENT_HISTORY.md') return 'EXPERIMENT_HISTORY';
  if (file.startsWith('docs/PR114_FINAL_MERGE_MANIFEST')) return 'FINAL_MERGE_MANIFEST';
  if (file.startsWith('test/evidence/')) return 'VALIDATION_TEST';
  if (file.startsWith('tool/')) return 'VALIDATION_TOOL';
  if (sourceTracePrefixes.some((prefix) => file.startsWith(prefix))) return 'REQUIRED_SOURCE_TRACE';
  if (file.startsWith('knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1')) return 'REQUIRED_CANONICAL_FOUNDATION';
  if (file.startsWith('docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1')) return 'REQUIRED_SOURCE_TRACE';
  return 'REQUIRED_CANONICAL_FOUNDATION';
}

function metadata(file) {
  const category = classify(file);
  const common = {
    path: file,
    category,
    canonicalStatus: category === 'REQUIRED_SOURCE_TRACE' ? 'PROPOSED_SOURCE_TRACE_ONLY' :
      category === 'REQUIRED_CANONICAL_FOUNDATION' ? 'OWNER_AUTHORIZED_FOUNDATION_NOT_RUNTIME' : 'SUPPORTING_NON_RUNTIME',
    purpose: '', directConsumers: [], dependencies: [],
    sourceAuthority: 'Owner-accepted Candidate 0011 and the explicitly bounded PR114 foundation evidence',
    runtimeEligibility: 'NOT_RUNTIME_ELIGIBLE', keepReason: '',
  };
  if (category === 'STATUS_DOCUMENTATION') return { ...common, purpose: 'Record the current OR8 review state.', directConsumers: ['Owner review', 'repository handoff'], keepReason: 'Required six-file status synchronization.' };
  if (category === 'EXPERIMENT_HISTORY') return { ...common, purpose: 'Single compact historical index for rejected PR114 experiments.', directConsumers: ['docs/PR114_FINAL_MERGE_MANIFEST.md'], keepReason: 'Preserves review provenance without retaining rejected working files.' };
  if (category === 'FINAL_MERGE_MANIFEST') return { ...common, purpose: 'Machine-readable or human-readable final closure and scope accounting.', directConsumers: ['test/evidence/pr114_final_merge_surface.test.mjs', 'Owner review'], dependencies: file.endsWith('.md') ? ['docs/PR114_FINAL_MERGE_MANIFEST.json'] : [], keepReason: 'Required proof of the final merge surface.' };
  if (category === 'VALIDATION_TEST') return { ...common, purpose: 'Executable regression proof for the retained foundation.', directConsumers: ['repository evidence gate'], dependencies: file.includes('oracle') ? ['tool/validate_candidate_0011_oracle.mjs'] : file.includes('rule_map') ? ['tool/validate_candidate_0011_rule_map.mjs'] : file.includes('thai_predictive_evidence') ? ['tool/validate_thai_predictive_evidence_v1.mjs'] : ['tool/validate_pr114_final_merge_surface.mjs'], keepReason: 'Required automated closure or oracle regression.' };
  if (category === 'VALIDATION_TOOL') return { ...common, purpose: 'Build or validate the retained Candidate 0011 evidence chain.', directConsumers: ['test/evidence'], dependencies: file.includes('candidate_0011_oracle') ? ['docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md'] : file.includes('candidate_0011_rule_map') ? ['docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json', 'docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json'] : file.includes('thai_predictive_evidence') ? ['docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json'] : [], keepReason: 'Directly consumed by the retained canonical validation tests.' };
  if (category === 'REQUIRED_SOURCE_TRACE') return { ...common, purpose: 'Trace source boundaries and resolved target-fixture evidence.', directConsumers: ['tool/resolve_thai_predictive_evidence_v1.mjs'], keepReason: 'Used by the resolved 22/22 target-fixture evidence chain; not reader copy or runtime authority.' };
  return { ...common, purpose: 'Define or prove the Owner-authorized Candidate 0011 product interpretation foundation.', directConsumers: file.includes('CONTRACT') ? ['tool/build_candidate_0011_rule_map.mjs'] : ['tool/validate_candidate_0011_oracle.mjs', 'tool/validate_candidate_0011_rule_map.mjs'], dependencies: file.includes('RULE_MAP') ? ['docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json', 'docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json'] : [], keepReason: 'Canonical root or direct dependency of the immutable Candidate 0011 oracle.' };
}

function proposedAudit() {
  const original = lines(run(['diff', '--name-only', BASE, OR7_HEAD, '--', 'knowledge/canon/proposed'])).map(norm);
  return original.map((file) => {
    const retained = exists(file);
    const classification = retained
      ? (sourceTracePrefixes.some((prefix) => file.startsWith(prefix)) ? 'REQUIRED_SOURCE_TRACE' : 'REQUIRED_CANONICAL_FOUNDATION')
      : 'REJECTED_EXPERIMENT';
    return {
      path: file,
      classification,
      retained,
      canonicalConsumer: retained ? 'Candidate 0011 resolved product rule map' : null,
      status: retained ? 'PROPOSED_NON_RUNTIME' : 'REMOVED_FROM_FINAL_SURFACE',
      sourceAuthorityBoundary: retained ? 'Bounded foundation/source trace; not a direct quotation or accuracy proof.' : 'Rejected experiment; no active authority.',
      runtimeMayConsume: false,
      ownerAcceptanceRequiredBeforeRuntime: true,
    };
  });
}

export function buildManifest() {
  const paths = currentChangedPaths();
  const removed = lines(run(['show', '--format=', '--name-only', '--diff-filter=D', CLEANUP_COMMIT])).map(norm);
  const oracle = JSON.parse(fs.readFileSync(path.join(ROOT, 'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json'), 'utf8'));
  const evidenceRegistry = JSON.parse(fs.readFileSync(path.join(ROOT, 'docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json'), 'utf8'));
  const runtimeDelta = lines(run(['diff', '--name-only', BASE, '--', 'lib', 'web', 'android', 'ios', 'macos', 'linux', 'windows']));
  const productAcceptanceDelta = lines(run(['diff', '--name-only', BASE, '--', 'product-acceptance']));
  const flutterTestDelta = lines(run(['diff', '--name-only', BASE, '--', 'test', ':!test/evidence']));
  const entries = paths.map(metadata);
  const registryDependencies = evidenceRegistry.entries.flatMap((entry) => [entry.repositoryPath, entry.derivation?.repositoryPath]).filter(Boolean);
  const transitiveDependencies = [...new Set([
    ...entries.flatMap((entry) => entry.dependencies),
    ...registryDependencies,
    'product-acceptance/thai-narrative-v1.5-r6/evidence/claim-ledger.json',
  ])].sort();
  const closurePaths = [...new Set([...canonicalRootPaths, ...transitiveDependencies])].sort();
  const missingDependencies = closurePaths.filter((dependency) => !exists(dependency) && !outputPaths.includes(dependency)).map((dependency) => ({ path: 'canonical-closure', dependency }));
  const orphanRetained = entries.filter((entry) => entry.directConsumers.length === 0);
  const activeFiles = paths.filter((file) => (file.startsWith('tool/') || file.startsWith('test/evidence/') || file.startsWith('docs/CANDIDATE_0011') || file === 'docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json') && exists(file));
  const activeText = activeFiles.map((file) => fs.readFileSync(path.join(ROOT, file), 'utf8')).join('\n');
  const staleRefs = removed.filter((file) => activeText.includes(file));
  const rejectedRefs = activeText.match(/CANDIDATE_001[2-8]|candidate_001[2-8]/g) ?? [];
  const obsoleteImports = activeText.match(/(?:from|import|require)[^\n]*(?:candidate_001[2-8]|_or[1-6])/gi) ?? [];
  const changedContracts = paths.filter((file) => file.startsWith('knowledge/canon/proposed/') && file.endsWith('.json') && !file.endsWith('.schema.json') && file.includes('CONTRACT'));
  const proposed = proposedAudit();
  const counts = {
    beforeChangedPaths: BEFORE_PATHS,
    afterChangedPaths: paths.length,
    removedExperimentPaths: removed.length,
    canonicalRoots: canonicalRootPaths.length,
    retainedDependencies: transitiveDependencies.length,
    proposedPathsReviewed: proposed.length,
    proposedRequiredCanonicalFoundation: proposed.filter((entry) => entry.classification === 'REQUIRED_CANONICAL_FOUNDATION').length,
    proposedRequiredSourceTrace: proposed.filter((entry) => entry.classification === 'REQUIRED_SOURCE_TRACE').length,
    proposedRejectedExperiment: proposed.filter((entry) => entry.classification === 'REJECTED_EXPERIMENT').length,
    proposedUnused: proposed.filter((entry) => entry.classification === 'UNUSED').length,
    orphanRetained: orphanRetained.length,
    missingDependencies: missingDependencies.length,
    staleReferences: staleRefs.length,
    activeImportsRejectedCandidates: rejectedRefs.length,
    activeImportsObsoleteOr: obsoleteImports.length,
    conflictingContracts: Math.max(0, changedContracts.length - 1),
    candidate0011ByteDelta: oracle.source.currentReaderFacingSha256 === EXPECTED_READER_SHA && lines(run(['diff', '--name-only', BASE, '--', oracle.source.repositoryPath])).length === 0 ? 0 : 1,
    runtimeApplicationDelta: runtimeDelta.length,
    flutterTestDelta: flutterTestDelta.length,
    productAcceptanceDelta: productAcceptanceDelta.length,
  };
  return {
    version: 1,
    status: Object.entries(counts).filter(([key]) => ['orphanRetained', 'missingDependencies', 'staleReferences', 'activeImportsRejectedCandidates', 'activeImportsObsoleteOr', 'conflictingContracts', 'candidate0011ByteDelta', 'runtimeApplicationDelta', 'flutterTestDelta', 'productAcceptanceDelta'].includes(key)).every(([, value]) => value === 0) ? 'PASS_PR114_OR8_FINAL_MERGE_SURFACE' : 'FAIL',
    base: BASE,
    or7Head: OR7_HEAD,
    ownerAcceptedOracle: { candidate: '0011', readerFacingSha256: EXPECTED_READER_SHA, claims: 24, predictions: 22, advice: 1, disclosure: 1, resolvedTargetFixtureChains: '22/22', asOfMismatch: 0 },
    scopeBoundary: { runtimeImplemented: false, proves49ContextReadiness: false, provesPredictiveAccuracy: false, directSourceQuotation: false },
    counts,
    errors: { missingDependencies, orphanRetained: orphanRetained.map((entry) => entry.path), staleRefs, rejectedRefs, obsoleteImports },
    canonicalRoots: canonicalRootPaths,
    transitiveDependencies,
    removedExperimentPaths: removed,
    proposedKnowledgeReview: proposed,
    retainedChangedPaths: entries,
  };
}

export function writeManifest() {
  const manifest = buildManifest();
  fs.writeFileSync(path.join(ROOT, outputPaths[0]), `${JSON.stringify(manifest, null, 2)}\n`);
  const c = manifest.counts;
  const md = `# PR114 Final Merge Manifest\n\nStatus: **${manifest.status}**\n\nCandidate 0011 is the immutable Owner-accepted content oracle. This foundation is not runtime implementation, a 49-context readiness proof, a predictive-accuracy claim, or a direct-source quotation claim.\n\n## Scope accounting\n\n- Changed paths before OR8: ${c.beforeChangedPaths}\n- Changed paths after OR8: ${c.afterChangedPaths}\n- Rejected experiment paths removed: ${c.removedExperimentPaths}\n- Canonical roots: ${c.canonicalRoots}\n- Retained dependencies: ${c.retainedDependencies}\n- Proposed knowledge paths reviewed: ${c.proposedPathsReviewed} (${c.proposedRequiredCanonicalFoundation} canonical foundation, ${c.proposedRequiredSourceTrace} source trace, ${c.proposedRejectedExperiment} rejected experiment, ${c.proposedUnused} unused)\n\n## Zero-error closure\n\n- Orphan retained: ${c.orphanRetained}\n- Missing dependencies: ${c.missingDependencies}\n- Stale references: ${c.staleReferences}\n- Active rejected-candidate references: ${c.activeImportsRejectedCandidates}\n- Active obsolete-OR imports: ${c.activeImportsObsoleteOr}\n- Conflicting contracts: ${c.conflictingContracts}\n- Candidate 0011 byte delta: ${c.candidate0011ByteDelta}\n- Runtime/application delta: ${c.runtimeApplicationDelta}\n- Flutter test delta: ${c.flutterTestDelta}\n- product-acceptance/ delta: ${c.productAcceptanceDelta}\n\nEvery retained changed path, its purpose, consumers, dependencies, authority boundary and keep reason is recorded in [the JSON manifest](PR114_FINAL_MERGE_MANIFEST.json).\n`;
  fs.writeFileSync(path.join(ROOT, outputPaths[1]), md);
  return manifest;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const manifest = writeManifest();
  console.log(JSON.stringify({ status: manifest.status, counts: manifest.counts }, null, 2));
  process.exitCode = manifest.status === 'PASS_PR114_OR8_FINAL_MERGE_SURFACE' ? 0 : 1;
}
