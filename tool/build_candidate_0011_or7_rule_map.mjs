#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { buildResolvedRegistry } from './resolve_candidate_0018_or6.mjs';

const ROOT = process.cwd();
const load = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const sha256 = (value) => crypto.createHash('sha256').update(JSON.stringify(value)).digest('hex').toUpperCase();

const common = {
  conflictRefs: ['conflict.contract-boundaries'],
  certaintyRefs: ['certainty.product-interpretation-contract-v1'],
};
const chain = (selectorRefs, domainRefs, directionRefs, timingRefs, extra = {}) => ({ selectorRefs, domainRefs, directionRefs, timingRefs, ...common, ...extra });

const chains = {
  'RC11-K-OVERVIEW-01': chain(
    ['selector.mahabhut2537.rem0.saturday.saturn.0_10', 'selector.mahabhut2537.rem0.saturday.jupiter.11_29', 'selector.mahabhut2537.rem0.saturday.rahu.30_41', 'selector.mahabhut2537.rem0.saturday.venus.42_62'],
    ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT', 'canon.mahabhut.p220.jupiter_owns_learning', 'canon.mahabhut.p39.det_owns_career', 'source.T0003-SRC-42-62-FLOW'],
    ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT', 'source.T0003-SRC-11-62-RISING-BLOCK'],
    ['selector.mahabhut2537.rem0.saturday.saturn.0_10', 'selector.mahabhut2537.rem0.saturday.jupiter.11_29', 'selector.mahabhut2537.rem0.saturday.rahu.30_41', 'selector.mahabhut2537.rem0.saturday.venus.42_62'],
  ),
  'RC11-K-PAST-01': chain(['selector.mahabhut2537.rem0.saturday.saturn.0_10'], ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT', 'canon.mahabhut.p28.saturn_owns_family'], ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT'], ['selector.mahabhut2537.rem0.saturday.saturn.0_10']),
  'RC11-K-PAST-02': chain(['selector.mahabhut2537.rem0.saturday.jupiter.11_29'], ['canon.mahabhut.p220.jupiter_owns_learning', 'canon.mahabhut.p220.jupiter_owns_career'], ['source.T0003-SRC-11-62-RISING-BLOCK'], ['selector.mahabhut2537.rem0.saturday.jupiter.11_29']),
  'RC11-K-PAST-03': chain(['selector.mahabhut2537.rem0.saturday.jupiter.11_29'], ['canon.mahabhut.p220.jupiter_owns_career'], ['source.T0003-SRC-11-62-RISING-BLOCK'], ['selector.mahabhut2537.rem0.saturday.jupiter.11_29']),
  'RC11-K-PAST-04': chain(['selector.mahabhut2537.rem0.saturday.rahu.30_41'], ['canon.mahabhut.p39.det_owns_career', 'source.T0003-SRC-30-41-PLACEMENT'], ['source.T0003-SRC-11-62-RISING-BLOCK'], ['selector.mahabhut2537.rem0.saturday.rahu.30_41']),
  'RC11-K-PAST-05': chain(['selector.mahabhut2537.rem0.saturday.rahu.30_41'], ['canon.mahabhut.p39.det_owns_career', 'source.T0003-SRC-30-41-PLACEMENT'], ['source.T0003-SRC-11-62-RISING-BLOCK'], ['selector.mahabhut2537.rem0.saturday.rahu.30_41']),
  'RC11-K-CURRENT-01': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62', 'fixture.target-0003'], ['source.T0003-SRC-42-62-FLOW', 'domain.runtime.current.career'], ['source.T0003-SRC-42-62-FLOW', 'typed.current.career'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'fixture.target-0003'], { conflictRefs: ['conflict.T0003-SRC-42-43-61-62-EXCEPTION', 'conflict.contract-boundaries'] }),
  'RC11-K-WORK-01': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-WORK', 'domain.runtime.current.career'], ['typed.current.career'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.career']),
  'RC11-K-WORK-02': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-WORK', 'domain.runtime.current.career'], ['typed.current.career'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.career']),
  'RC11-K-FINANCE-01': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-FINANCE', 'canon.mahabhut.p39.sri_owns_finance', 'domain.runtime.current.finance'], ['typed.current.finance'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.finance']),
  'RC11-K-FINANCE-02': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-FINANCE', 'domain.runtime.current.finance'], ['typed.current.finance'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.finance']),
  'RC11-K-RELATIONSHIP-01': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['canon.mahabhut.p16.venus_owns_relationship_male', 'canon.mahabhut.p28.venus_owns_relationship'], ['typed.current.relationship'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.relationship']),
  'RC11-K-RELATIONSHIP-02': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['canon.mahabhut.p16.venus_owns_relationship_male', 'canon.mahabhut.p28.venus_owns_relationship'], ['typed.current.relationship'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.relationship']),
  'RC11-K-HEALTH-01': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน', 'domain.runtime.current.health'], ['typed.current.health', 'typed.current.career'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.health']),
  'RC11-K-HEALTH-02': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน', 'domain.runtime.current.health'], ['typed.current.health'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'typed.current.health']),
  'RC11-K-SUPPORT-01': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-SUPPORT'], ['source.T0003-SRC-42-62-SUPPORT'], ['selector.mahabhut2537.rem0.saturday.venus.42_62']),
  'RC11-K-SUPPORT-02': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-SUPPORT', 'source.T0003-SRC-42-62-WORK'], ['source.T0003-SRC-42-62-SUPPORT', 'typed.current.career'], ['selector.mahabhut2537.rem0.saturday.venus.42_62']),
  'RC11-K-HORIZON-01': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-WORK', 'domain.runtime.current.career'], ['typed.next12Months.career'], ['typed.next12Months.career', 'timing.rolling-12-month-label']),
  'RC11-K-HORIZON-02': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-FINANCE', 'canon.mahabhut.p16.venus_owns_relationship_male'], ['typed.next12Months.finance', 'typed.next12Months.relationship'], ['typed.next12Months.finance', 'typed.next12Months.relationship', 'timing.rolling-12-month-label']),
  'RC11-K-HORIZON-03': chain(['selector.mahabhut2537.rem0.saturday.venus.42_62'], ['source.T0003-SRC-42-62-SUPPORT'], ['source.T0003-SRC-42-62-SUPPORT'], ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'timing.rolling-12-month-label']),
  'RC11-K-NEXT-01': chain(['selector.mahabhut2537.rem0.saturday.mercury.63_79'], ['source.T0003-SRC-63-79-PLACEMENT', 'canon.mahabhut.p28.mercury_owns_family', 'domain.runtime.nextLifePeriod.finance'], ['typed.nextLifePeriod.finance'], ['selector.mahabhut2537.rem0.saturday.mercury.63_79', 'typed.nextLifePeriod.finance']),
  'RC11-K-NEXT-02': chain(['selector.mahabhut2537.rem0.saturday.mercury.63_79'], ['canon.mahabhut.p33.mercury_relates_attribute_profession_นักพูด', 'domain.runtime.nextLifePeriod.career'], ['typed.nextLifePeriod.career'], ['selector.mahabhut2537.rem0.saturday.mercury.63_79', 'typed.nextLifePeriod.career']),
};

function bindingSummary(entry) {
  return {
    id: entry.id,
    role: entry.role,
    repositoryPath: entry.repositoryPath,
    locator: entry.locator,
    sourceCommit: entry.sourceCommit,
    resolvedValueSha256: sha256(entry.resolvedValue),
  };
}

export function buildRuleMap() {
  const oracle = load('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
  const proposed = load('knowledge/canon/proposed/mahabhut_2537_candidate_0011_reader_claims.json').surfaces.find((surface) => surface.surface === 'Known').readerClaims;
  const proposedById = new Map(proposed.map((claim) => [claim.readerClaimId, claim]));
  const registry = buildResolvedRegistry();
  const registryById = new Map(registry.entries.map((entry) => [entry.id, entry]));
  const claims = oracle.claims.filter((claim) => claim.claimKind === 'PREDICTION').map((claim) => {
    const old = proposedById.get(claim.readerClaimId);
    const rule = chains[claim.readerClaimId];
    const roles = ['selectorRefs', 'domainRefs', 'directionRefs', 'timingRefs', 'conflictRefs', 'certaintyRefs'];
    const missingComponents = roles.filter((role) => !Array.isArray(rule?.[role]) || rule[role].length === 0);
    const unresolvedRefs = roles.flatMap((role) => rule?.[role] ?? []).filter((ref) => !registryById.has(ref));
    return {
      readerClaimId: claim.readerClaimId,
      section: claim.section,
      exactAcceptedText: claim.exactText,
      authorityClass: claim.authorityClass,
      ownerAcceptanceRef: `docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json#/claims/${oracle.claims.findIndex((row) => row.readerClaimId === claim.readerClaimId)}`,
      ownerId: old?.ownerId ?? null,
      contextId: old?.contextId ?? null,
      periodBinding: old?.periodBinding ?? null,
      domain: old?.domain ?? null,
      ...rule,
      gapStatus: missingComponents.length || unresolvedRefs.length ? 'GAP_KEEP_EXACT_ACCEPTED_TEXT' : 'COMPLETE',
      missingComponents,
      unresolvedRefs,
      interpretationBoundary: 'Owner acceptance authorizes exact product copy/interpretation only; it is not a source quotation or accuracy claim.',
    };
  });
  const usedRefs = [...new Set(claims.flatMap((claim) => ['selectorRefs', 'domainRefs', 'directionRefs', 'timingRefs', 'conflictRefs', 'certaintyRefs'].flatMap((role) => claim[role] ?? [])))].sort();
  return {
    version: 1,
    status: claims.every((claim) => claim.gapStatus === 'COMPLETE') ? 'CANDIDATE_0011_RULE_MAP_COMPLETE_NOT_RUNTIME' : 'CANDIDATE_0011_RULE_MAP_GAPS_RECORDED_NOT_RUNTIME',
    oracleRef: 'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json',
    evidenceRegistryRef: 'docs/CANDIDATE_0018_EVIDENCE_RESOLUTION.json',
    fixture: load('docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.json').fixture,
    asOfEquivalenceRef: 'docs/CANDIDATE_0011_ASOF_EQUIVALENCE_VALIDATION.json',
    counts: {
      predictionParagraphs: claims.length,
      completeChains: claims.filter((claim) => claim.gapStatus === 'COMPLETE').length,
      chainsWithGaps: claims.filter((claim) => claim.gapStatus !== 'COMPLETE').length,
      usedResolvedReferences: usedRefs.length,
    },
    resolvedReferenceIndex: Object.fromEntries(usedRefs.map((ref) => [ref, bindingSummary(registryById.get(ref))])),
    claims,
  };
}

export function buildAsOfEquivalence(rawPath = '.tmp-candidate0011-asof-raw.json') {
  const raw = load(rawPath);
  const [first, second] = raw.results;
  const invariantFields = ['thaiAstrologicalDate', 'thaiWeekdayNumber', 'ascendantSiderealDegrees', 'mahabhutaPositionKeys', 'currentAge', 'activeLifePeriod', 'contextId', 'forecastMaterials'];
  const comparisons = invariantFields.map((field) => ({ field, equivalent: JSON.stringify(first[field]) === JSON.stringify(second[field]), left: first[field], right: second[field] }));
  return {
    version: 1,
    status: comparisons.every((row) => row.equivalent) ? 'PASS_ACTUAL_GENERATOR_ASOF_EQUIVALENCE' : 'FAIL',
    generator: raw.generator,
    generatorSource: 'lib/features/thai_beta/application/thai_beta_analysis.dart#ThaiBetaAnalysisRunner.runAsync; lib/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart#ThaiBetaNarrativeComposer.narrativeView',
    fixture: raw.fixture,
    comparedAsOf: raw.results.map((row) => row.asOf),
    rollingWindowLabelsMayDiffer: true,
    rollingWindows: raw.results.map((row) => ({ asOf: row.asOf, ...row.rollingWindow })),
    counts: {
      comparedInvariantFields: comparisons.length,
      invariantMismatches: comparisons.filter((row) => !row.equivalent).length,
      forecastMaterialsPerRun: raw.results.map((row) => row.forecastMaterials.length),
      forecastMaterialMismatches: comparisons.find((row) => row.field === 'forecastMaterials').equivalent ? 0 : 1,
    },
    comparisons,
    actualGeneratorResults: raw.results,
  };
}

function markdown(map) {
  const rows = map.claims.map((claim) => `| \`${claim.readerClaimId}\` | ${claim.section} | ${claim.authorityClass} | ${claim.selectorRefs.length}/${claim.domainRefs.length}/${claim.directionRefs.length}/${claim.timingRefs.length}/${claim.conflictRefs.length}/${claim.certaintyRefs.length} | ${claim.gapStatus} |`).join('\n');
  return `# Candidate 0011 Resolved Product Rule Map\n\nStatus: **${map.status}**\n\nCandidate 0011 remains byte-exact and is not implemented by this evidence PR. Each row links the exact Owner-accepted paragraph to selector, domain, direction, timing, conflict and certainty components. Owner acceptance is product-copy and interpretation authority; it is neither a source quotation nor proof of predictive accuracy.\n\n| Reader claim | Section | Authority class | Chain S/D/R/T/C/Z | Result |\n|---|---|---|---:|---|\n${rows}\n\nComplete chains: **${map.counts.completeChains}/${map.counts.predictionParagraphs}**. Gaps: **${map.counts.chainsWithGaps}**. Exact texts and complete reference arrays are in \`CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json\`.\n`;
}

function gapMarkdown(map) {
  const gaps = map.claims.filter((claim) => claim.gapStatus !== 'COMPLETE');
  return `# Candidate 0011 Rule Map Gap Report\n\nStatus: **${gaps.length === 0 ? 'NO GAPS — 22/22 COMPLETE' : 'GAPS RECORDED — EXACT ACCEPTED COPY RETAINED'}**\n\nNo accepted paragraph may be shortened, generalized, deleted or rewritten to hide a missing evidence component.\n\n${gaps.length === 0 ? 'All 22 prediction paragraphs have non-empty, resolvable selector, domain, direction, timing, conflict and certainty chains plus an exact Owner-acceptance reference.' : gaps.map((claim) => `- \`${claim.readerClaimId}\`: missing ${[...claim.missingComponents, ...claim.unresolvedRefs].join(', ')}`).join('\n')}\n`;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const map = buildRuleMap();
  fs.writeFileSync(path.join(ROOT, 'docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json'), `${JSON.stringify(map, null, 2)}\n`, 'utf8');
  fs.writeFileSync(path.join(ROOT, 'docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.md'), markdown(map), 'utf8');
  fs.writeFileSync(path.join(ROOT, 'docs/CANDIDATE_0011_RULE_MAP_GAP_REPORT.md'), gapMarkdown(map), 'utf8');
  const rawPath = process.env.KNOWME_OR7_ASOF_RAW || '.tmp-candidate0011-asof-raw.json';
  fs.writeFileSync(path.join(ROOT, 'docs/CANDIDATE_0011_ASOF_EQUIVALENCE_VALIDATION.json'), `${JSON.stringify(buildAsOfEquivalence(rawPath), null, 2)}\n`, 'utf8');
  process.stdout.write(`${JSON.stringify(map.counts)}\n`);
}
