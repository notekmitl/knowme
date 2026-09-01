#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const generatedAt = '2026-09-01T00:00:00+07:00';

const dossier = readJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json');
const sourceMeta = {
  'T0003-SRC-0-10-FAMILY-CONSTRAINT': ['EO-MH2537-P290-EARLY-FAMILY', 'MH2537-P290-PARA-EARLY-FAMILY', 'MH2537-P290-PARA-EARLY-FAMILY', 'NEGATIVE'],
  'T0003-SRC-11-62-RISING-BLOCK': ['EO-MH2537-P290-RISING-11-62', 'MH2537-P290-HEADING-11-62', 'MH2537-P290-HEADING-11-62', 'POSITIVE'],
  'T0003-SRC-11-29-PLACEMENT': ['EO-MH2537-P290-PLACEMENT-11-29', 'MH2537-P290-ROW-11-29', 'MH2537-P290-ROW-11-29', 'NEUTRAL'],
  'T0003-SRC-30-41-PLACEMENT': ['EO-MH2537-P290-291-PLACEMENT-30-41', 'MH2537-P290-291-ROW-30-41', 'MH2537-P290-291-ROW-30-41', 'NEUTRAL'],
  'T0003-SRC-42-62-PLACEMENT': ['EO-MH2537-P291-PLACEMENT-42-62', 'MH2537-P291-ROW-42-62', 'MH2537-P291-ROW-42-62', 'NEUTRAL'],
  'T0003-SRC-42-62-SUPPORT': ['EO-MH2537-P291-SUPPORT-42-62', 'MH2537-P291-CLAUSE-SUPPORT', 'MH2537-P291-RESULTS-42-62', 'POSITIVE'],
  'T0003-SRC-42-62-WORK': ['EO-MH2537-P291-WORK-42-62', 'MH2537-P291-CLAUSE-WORK', 'MH2537-P291-RESULTS-42-62', 'POSITIVE'],
  'T0003-SRC-42-62-FINANCE': ['EO-MH2537-P291-FINANCE-LUCK-42-62', 'MH2537-P291-CLAUSE-FINANCE-LUCK', 'MH2537-P291-RESULTS-42-62', 'POSITIVE'],
  'T0003-SRC-42-62-FLOW': ['EO-MH2537-P291-FLOW-42-62', 'MH2537-P291-CLAUSE-FLOW', 'MH2537-P291-RESULTS-42-62', 'POSITIVE'],
  'T0003-SRC-42-43-61-62-EXCEPTION': ['EO-MH2537-P291-292-EXCEPTION', 'MH2537-P291-292-CLAUSE-EXCEPTION', 'MH2537-P291-292-EXCEPTION', 'NEGATIVE'],
  'T0003-SRC-63-79-PLACEMENT': ['EO-MH2537-P290-PLACEMENT-63-79', 'MH2537-P290-ROW-63-79', 'MH2537-P290-ROW-63-79', 'NEUTRAL'],
};

const sourceSignals = dossier.sourceRecords.map((row) => {
  const [evidenceOwnerId, sourceUnitId, derivationGroupId, polarity] = sourceMeta[row.evidenceId];
  return {
    signalId: row.evidenceId,
    signalType: row.classification,
    semanticRecord: true,
    evidenceOwnerId,
    sourceUnitId,
    derivationGroupId,
    sourceAuthorityId: 'MAHABHUT_2537_PRIMARY_WORKING_EDITION',
    directOrDerived: 'DIRECT',
    parentRefs: [],
    domains: row.domains,
    period: row.exactPeriod,
    polarity,
    timingGranularity: 'LIFE_PERIOD',
    sourceLocation: {
      kind: 'PDF_PAGE_CLAUSE',
      editionId: dossier.source.editionId,
      pdfSha256: dossier.source.pdfSha256,
      pages: row.pages,
      exactPassage: row.correctedTranscription,
    },
    prohibitedExtrapolations: row.prohibitedExtrapolations,
  };
});

const canonMeta = {
  'T0003-CANON-JUPITER-LEARNING': ['EO-CANON-P220-JUPITER-SCOPE', 'CANON-P220-JUPITER-SCOPE', 'CANON-P220-JUPITER-SCOPE', 'PRODUCTION_CANON', 'DIRECT', [], ['learning'], 'NEUTRAL'],
  'T0003-CANON-JUPITER-CAREER': ['EO-CANON-P220-JUPITER-SCOPE', 'CANON-P220-JUPITER-SCOPE', 'CANON-P220-JUPITER-SCOPE', 'PRODUCTION_CANON', 'DERIVED', ['T0003-CANON-JUPITER-LEARNING'], ['work'], 'NEUTRAL'],
  'T0003-CANON-RAHU-SCOPE': ['EO-MH2537-P290-291-PLACEMENT-30-41', 'MH2537-P290-291-ROW-30-41', 'MH2537-P290-291-ROW-30-41', 'MAHABHUT_2537_RULEBOOK_DERIVATION', 'DERIVED', ['T0003-SRC-30-41-PLACEMENT'], ['pressure'], 'NEUTRAL'],
  'T0003-CANON-DET-WORK': ['EO-MH2537-P290-291-PLACEMENT-30-41', 'MH2537-P290-291-ROW-30-41', 'MH2537-P290-291-ROW-30-41', 'MAHABHUT_2537_RULEBOOK_DERIVATION', 'DERIVED', ['T0003-SRC-30-41-PLACEMENT'], ['work'], 'NEUTRAL'],
  'T0003-CANON-MERCURY-FAMILY': ['EO-CANON-P28-MERCURY-SCOPE', 'CANON-P28-MERCURY-SCOPE', 'CANON-P28-MERCURY-SCOPE', 'PRODUCTION_CANON', 'DIRECT', [], ['family'], 'NEUTRAL'],
  'T0003-CANON-MERCURY-COMMUNICATION': ['EO-MH2537-P290-PLACEMENT-63-79', 'MH2537-P290-ROW-63-79', 'MH2537-P290-ROW-63-79', 'MAHABHUT_2537_RULEBOOK_DERIVATION', 'DERIVED', ['T0003-SRC-63-79-PLACEMENT'], ['communication'], 'NEUTRAL'],
  'T0003-CANON-MULA-FOUNDATION': ['EO-MH2537-P290-PLACEMENT-63-79', 'MH2537-P290-ROW-63-79', 'MH2537-P290-ROW-63-79', 'MAHABHUT_2537_RULEBOOK_DERIVATION', 'DERIVED', ['T0003-SRC-63-79-PLACEMENT'], ['home'], 'NEUTRAL'],
  'T0003-CANON-STRONG-HOUSE': ['EO-MH2537-P291-PLACEMENT-42-62', 'MH2537-P291-ROW-42-62', 'MH2537-P291-ROW-42-62', 'MAHABHUT_2537_RULEBOOK_DERIVATION', 'DERIVED', ['T0003-SRC-42-62-PLACEMENT'], ['life_direction'], 'POSITIVE'],
};

const canonSignals = dossier.canonSignals.map((row) => {
  const [evidenceOwnerId, sourceUnitId, derivationGroupId, sourceAuthorityId, directOrDerived, parentRefs, domains, polarity] = canonMeta[row.signalId];
  return {
    signalId: row.signalId,
    signalType: 'CANON_DOMAIN_OR_DIRECTION',
    semanticRecord: true,
    evidenceOwnerId,
    sourceUnitId,
    derivationGroupId,
    sourceAuthorityId,
    directOrDerived,
    parentRefs,
    domains,
    period: row.period,
    polarity,
    timingGranularity: 'LIFE_PERIOD',
    sourceLocation: { kind: 'REPOSITORY_CANON_RULE', ruleId: row.rule, repositoryRef: row.source },
    prohibitedExtrapolations: ['do not treat placement-derived facets as independent owners', 'no event inference from domain mapping alone'],
  };
});

const ledger = {
  version: 1,
  status: 'OR4_REAL_EVIDENCE_OWNER_MODEL_NOT_RUNTIME',
  generatedAt,
  candidate: '0016',
  ownerCountingPolicy: {
    countedFrom: 'distinct evidenceOwnerId resolved from referenced ledger records',
    storedIndependentSignalCountTrusted: false,
    sameClauseAtomsCollapse: true,
    derivedCopiesCollapseToParentOwner: true,
    placementPlanetTaksaHouseAutoIndependent: false,
    placementAloneTierC: false,
    independenceRequires: ['distinct semantic owner', 'distinct source unit or independently authored authority'],
  },
  sourceSignals,
  canonSignals,
  researchSignals: [],
  counts: {
    sourceSignals: sourceSignals.length,
    canonSignals: canonSignals.length,
    researchSignals: 0,
    distinctEvidenceOwners: new Set([...sourceSignals, ...canonSignals].map((row) => row.evidenceOwnerId)).size,
    derivedSignals: canonSignals.filter((row) => row.directOrDerived === 'DERIVED').length,
  },
};

const rulebook = {
  version: 1,
  status: 'OR4_RULE_SPECIFIC_VALIDATION_CONTRACT_NOT_RUNTIME',
  generatedAt,
  rules: [
    {
      ruleId: 'OR4-A-DIRECT-EVENT', authorityTier: 'A', requiredSignalTypes: ['SOURCE_DIRECT_EVENT'], minimumIndependentEvidenceOwners: 1,
      domainRule: 'CLAIM_DOMAIN_MUST_INTERSECT_EVERY_REQUIRED_SIGNAL', periodRule: 'CLAIM_PERIOD_MUST_BE_WITHIN_SIGNAL_PERIOD', polarityRule: 'CLAIM_POLARITY_MUST_MATCH', timingRule: 'CLAIM_MUST_NOT_BE_MORE_PRECISE_THAN_SIGNAL',
      causalAuthorityRequired: false, allowedStrength: 'DIRECT_EVENT_PARAPHRASE_ONLY', conflictHandling: 'OMIT_IF_UNRESOLVED', summaryOnly: false,
    },
    {
      ruleId: 'OR4-B-DIRECT-TREND', authorityTier: 'B', requiredSignalTypes: ['SOURCE_DIRECT_TREND'], minimumIndependentEvidenceOwners: 1,
      domainRule: 'CLAIM_DOMAIN_MUST_INTERSECT_EVERY_REQUIRED_SIGNAL', periodRule: 'CLAIM_PERIOD_MUST_BE_WITHIN_SIGNAL_PERIOD', polarityRule: 'CLAIM_POLARITY_MUST_MATCH', timingRule: 'CLAIM_MUST_NOT_BE_MORE_PRECISE_THAN_SIGNAL',
      causalAuthorityRequired: false, allowedStrength: 'DIRECTION_ONLY_NO_SPECIFIC_EVENT', conflictHandling: 'OMIT_IF_UNRESOLVED', summaryOnly: false,
    },
    {
      ruleId: 'OR4-C-MULTI-OWNER', authorityTier: 'C', requiredSignalTypes: ['SOURCE_PERIOD_OR_PLACEMENT', 'DOMAIN_AUTHORITY', 'POLARITY_AUTHORITY'], minimumIndependentEvidenceOwners: 2,
      domainRule: 'COMMON_DOMAIN_REQUIRED', periodRule: 'COMMON_APPLICABLE_PERIOD_REQUIRED', polarityRule: 'COMPATIBLE_POLARITY_REQUIRED', timingRule: 'COARSEST_INPUT_GRANULARITY_WINS',
      causalAuthorityRequired: false, allowedStrength: 'COMMON_DIRECTION_ONLY', conflictHandling: 'REDUCE_OR_OMIT', summaryOnly: false,
    },
    {
      ruleId: 'OR4-SUMMARY-COMPOSITION', authorityTier: 'COMPOSITIONAL', requiredSignalTypes: [], minimumIndependentEvidenceOwners: 0,
      domainRule: 'NO_NEW_DOMAIN', periodRule: 'NO_NEW_PERIOD', polarityRule: 'NO_NEW_POLARITY', timingRule: 'NO_NEW_TIMING',
      causalAuthorityRequired: false, allowedStrength: 'ONLY_COMPOSE_REFERENCED_VALIDATED_CLAIMS', conflictHandling: 'OMIT_NEW_OR_CONFLICTING_MOTIF', summaryOnly: true,
    },
    {
      ruleId: 'OR4-D-OMIT', authorityTier: 'D', requiredSignalTypes: [], minimumIndependentEvidenceOwners: 0,
      domainRule: 'NO_READER_PREDICTION', periodRule: 'NO_READER_PREDICTION', polarityRule: 'NO_READER_PREDICTION', timingRule: 'NO_READER_PREDICTION',
      causalAuthorityRequired: false, allowedStrength: 'OMIT', conflictHandling: 'OMIT', summaryOnly: false,
    },
  ],
  globalRules: {
    storedIndependentCountIgnored: true,
    causalWordingRequiresSignalWithCausalAuthority: true,
    semanticSourceRecordRequiredForTierAB: true,
    unknownTimeFailClosed: true,
    predictionAccuracyClaimAllowed: false,
  },
};

writeJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json', ledger);
writeText('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.md', `
# Target 0003 Predictive Evidence-owner Ledger V1

Status: **REAL OWNER IDENTITIES RECORDED — NOT RUNTIME**

The ledger contains ${ledger.counts.sourceSignals} source signals and ${ledger.counts.canonSignals} Canon signals resolving to ${ledger.counts.distinctEvidenceOwners} evidence owners. Counts are recomputed from distinct \`evidenceOwnerId\`; stored \`independentSignalCount\` is never trusted. Atoms from one clause and derived placement/planet/Taksa/house copies collapse to their shared owner. Placement alone cannot qualify for Tier C.
`);
writeJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'ownerCountingPolicy', 'sourceSignals', 'canonSignals', 'researchSignals', 'counts'],
  properties: {
    version: { const: 1 },
    sourceSignals: { type: 'array', minItems: 11, items: { $ref: '#/definitions/signal' } },
    canonSignals: { type: 'array', minItems: 8, items: { $ref: '#/definitions/signal' } },
    researchSignals: { type: 'array', items: { $ref: '#/definitions/signal' } },
  },
  definitions: { signal: { type: 'object', required: ['signalId', 'signalType', 'semanticRecord', 'evidenceOwnerId', 'sourceUnitId', 'derivationGroupId', 'sourceAuthorityId', 'directOrDerived', 'parentRefs', 'domains', 'period', 'polarity', 'timingGranularity', 'sourceLocation'] } },
});
writeJson('knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.json', rulebook);
writeText('knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.md', `
# Thai Predictive Rule-specific Validation V1

Status: **OWNER-EVIDENCE VALIDATION CONTRACT — NOT RUNTIME**

Tier A and B require a real semantic source record. Tier C must satisfy each referenced rule's signal types, common domain, applicable period, compatible polarity and coarsest timing granularity, using a recomputed set of evidence owners. Rule existence and a stored count never establish authority. Causal language requires an explicit causal signal. Overview and summary use \`OR4-SUMMARY-COMPOSITION\` and may only compose already validated claims without adding a domain, period, polarity, event or causal link.
`);
writeJson('knowledge/canon/proposed/THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'rules', 'globalRules'],
  properties: { version: { const: 1 }, rules: { type: 'array', minItems: 5, items: { type: 'object', required: ['ruleId', 'authorityTier', 'requiredSignalTypes', 'minimumIndependentEvidenceOwners', 'domainRule', 'periodRule', 'polarityRule', 'timingRule', 'causalAuthorityRequired', 'allowedStrength', 'conflictHandling', 'summaryOnly'] } } },
});

console.log(JSON.stringify({ status: 'PASS_MODEL_GENERATED', counts: ledger.counts, rules: rulebook.rules.length }, null, 2));
