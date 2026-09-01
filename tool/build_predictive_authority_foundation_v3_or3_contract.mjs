#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const generatedAt = '2026-09-01T00:00:00+07:00';

const ledgerFile = 'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json';
const atomsFile = 'knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json';
const pageReviewFile = 'knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.json';
const coverageFile = 'docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json';
const candidate14File = 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json';

const ledger = readJson(ledgerFile);
const atoms = readJson(atomsFile);
const pageReview = readJson(pageReviewFile);
const coverage = readJson(coverageFile);
const candidate14 = readJson(candidate14File);

const priorEvent = ledger.rows.filter((row) => row.extractionStatus === 'DIRECT_EVENT_FOUND').length;
const priorTrend = ledger.rows.filter((row) => row.extractionStatus === 'DIRECT_TREND_FOUND').length;
const priorMarkerMiss = ledger.rows.filter((row) => row.extractionStatus === 'NO_DIRECT_STATEMENT_AFTER_FULL_REVIEW').length;
const correctedCounts = {
  periods_total: ledger.rows.length,
  heuristic_event_candidates: priorEvent,
  heuristic_trend_candidates: priorTrend,
  marker_not_found_periods: priorMarkerMiss,
  semantic_reviewed_periods: 0,
  semantic_unreviewed_periods: ledger.rows.length,
  visually_verified_periods: 0,
  source_direct_authorized_periods: 0,
  synthesized_authorized_periods: 0,
  unsupported_periods: ledger.rows.length,
};
const truthCorrection = {
  version: 1,
  status: 'OCR_HEURISTIC_EXTRACTION_COMPLETE_SEMANTIC_SOURCE_AUTHORITY_NOT_ESTABLISHED',
  generatedAt,
  ownerDecision: 'OR2_REJECTED',
  correctedCounts,
  invalidInferences: [
    'Keyword presence was treated as an event without semantic clause review.',
    'Marker absence was treated as proof that no direct statement exists.',
    'A generated visuallyReviewed flag and template observation were treated as review evidence.',
    'The first regex-matched domain was treated as the only domain in multi-domain excerpts.',
  ],
  correctedBoundaries: {
    heuristicCandidatesAreAuthority: false,
    markerMissProvesAbsence: false,
    fileOrHashPresenceProvesVisualReview: false,
    candidate0014Accepted: false,
  },
};
writeJson('docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.json', truthCorrection);
writeText('docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.md', `
# PR114 OR2 OCR heuristic reclassification

Status: **OCR HEURISTIC EXTRACTION COMPLETE — SEMANTIC SOURCE AUTHORITY NOT ESTABLISHED — CANDIDATE 0014 REJECTED**

OR2 produced ${priorEvent} keyword event candidates, ${priorTrend} marker trend candidates and ${priorMarkerMiss} marker-not-found periods. These are not semantic source-authority counts. OR2 semantic reviewed = 0/392, visual review with specific evidence = 0/392, source-direct authorized = 0 and synthesized authorized = 0. Raw ledger and atom candidates are retained for audit only.
`);

ledger.status = 'OWNER_REJECTED_OCR_HEURISTIC_EXTRACTION_NOT_SEMANTIC_AUTHORITY';
ledger.counts = correctedCounts;
ledger.or3TruthCorrection = {
  ownerDecision: 'OR2_REJECTED',
  rawDataPreserved: true,
  legacyExtractionStatusIsHeuristicOnly: true,
  markerMissDoesNotProveNoDirectStatement: true,
  keywordHitDoesNotProveEventAuthority: true,
  generatedVisualFlagDoesNotProveReview: true,
};
ledger.rows = ledger.rows.map((row) => ({
  ...row,
  heuristicExtractionStatus: row.extractionStatus,
  semanticAuthorityStatus: 'UNREVIEWED_HEURISTIC_CANDIDATE',
  pagesVisuallyChecked: [],
  semanticReviewEvidence: null,
  reviewerObservation: 'OR2 OCR/marker output preserved as raw heuristic data; no semantic authority is established by this row.',
}));
writeJson(ledgerFile, ledger);
writeText('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.md', `
# Thai Mahabhut OR2 raw OCR heuristic ledger — 392 periods

Status: **OWNER REJECTED — OCR HEURISTIC EXTRACTION, NOT SEMANTIC SOURCE AUTHORITY**

The 392 rows and their original OCR/marker labels are retained for audit. The labels are heuristic candidates only: event keyword candidates ${priorEvent}, trend-marker candidates ${priorTrend}, marker-not-found periods ${priorMarkerMiss}. Semantic reviewed 0/392, semantic unreviewed 392/392, visually verified 0/392, source-direct authorized 0 and synthesized authorized 0. A keyword hit does not authorize an event, and a missing marker does not prove absence of source prose.
`);

atoms.status = 'OWNER_REJECTED_OR2_HEURISTIC_ATOMS_NOT_AUTHORITY';
atoms.coverage = correctedCounts;
atoms.policy = {
  ...atoms.policy,
  or2KeywordClassificationIsAuthority: false,
  generatedVisualFlagIsReviewEvidence: false,
  rawAtomsRetainedForAuditOnly: true,
};
atoms.atoms = atoms.atoms.map((atom) => ({
  ...atom,
  heuristicCandidateOnly: true,
  semanticAuthorityStatus: 'UNREVIEWED_HEURISTIC_CANDIDATE',
  visualVerificationStatus: 'OR2_GENERATED_FLAG_REJECTED_NOT_REVIEW_EVIDENCE',
}));
writeJson(atomsFile, atoms);
writeText('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md', `
# Thai Mahabhut OR2 heuristic atom candidates

Status: **OWNER REJECTED — RETAINED RAW HEURISTIC CANDIDATES, NOT SOURCE-DIRECT AUTHORITY**

All ${atoms.atoms.length} records remain available for audit, but none is authorized by its OR2 keyword/marker classification or generated visual flag. Source-direct and synthesis authority must be re-established under the OR3 contract with specific semantic evidence.
`);

pageReview.status = 'OWNER_REJECTED_AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_NOT_VISUAL_REVIEW';
pageReview.counts = {
  pagesExpected: pageReview.pages.length,
  pageImagesHashed: pageReview.pages.length,
  ocrFilesHashed: pageReview.pages.length,
  semanticReviewRecords: 0,
  visuallyReviewedWithEvidence: 0,
  generatedVisualFlagsRejected: pageReview.pages.length,
};
pageReview.pages = pageReview.pages.map((page) => ({
  ...page,
  priorGeneratedVisuallyReviewedFlag: page.visuallyReviewed,
  visuallyReviewed: false,
  semanticReviewEvidence: null,
  reviewerObservation: 'OR2 generated template only; image/OCR presence and hashes are not evidence that the page was semantically reviewed.',
}));
writeJson(pageReviewFile, pageReview);
writeText('knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.md', `
# OR2 page artifact — corrected status

Status: **OWNER REJECTED — AUTOMATED IMAGE/OCR INVENTORY, NOT VISUAL SEMANTIC REVIEW**

The 181 image and OCR hashes are preserved. OR2 generated the same review flag and observation for every page; therefore visually reviewed with evidence is 0/181. Use AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181 for the non-authoritative inventory.
`);

const automatedInventory = {
  version: 1,
  status: 'AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_ONLY_NOT_REVIEW_EVIDENCE',
  generatedAt,
  source: pageReview.source,
  counts: pageReview.counts,
  authorityBoundary: {
    filePresenceIsSemanticReview: false,
    hashPresenceIsSemanticReview: false,
    generatedBooleanIsSemanticReview: false,
  },
  pages: pageReview.pages.map((page) => ({
    page: page.page,
    imageSha256: page.imageSha256,
    ocrSha256: page.ocrSha256,
    contextIds: page.contextIds,
    matrixApplicationIdsIndexed: page.matrixApplicationIdsReviewed,
    imagePresent: true,
    ocrPresent: true,
    semanticReviewEvidence: null,
    authorityStatus: 'INVENTORY_ONLY',
  })),
};
writeJson('knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.json', automatedInventory);
writeText('knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.md', `
# Automated page image and OCR inventory — 181 pages

Status: **INVENTORY ONLY — NOT VISUAL OR SEMANTIC REVIEW EVIDENCE**

This file records 181/181 image hashes and OCR hashes. It deliberately makes no claim that a human or AI read the page, understood its semantics, resolved its boundaries or authorized a prediction.
`);
writeJson('knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#',
  type: 'object',
  required: ['version', 'status', 'counts', 'authorityBoundary', 'pages'],
  properties: {
    version: { const: 1 },
    status: { const: 'AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_ONLY_NOT_REVIEW_EVIDENCE' },
    counts: { type: 'object', required: ['pagesExpected', 'pageImagesHashed', 'ocrFilesHashed', 'semanticReviewRecords', 'visuallyReviewedWithEvidence'] },
    pages: { type: 'array', minItems: 181, maxItems: 181, items: { type: 'object', required: ['page', 'imageSha256', 'ocrSha256', 'semanticReviewEvidence', 'authorityStatus'] } },
  },
});

coverage.status = 'OWNER_REJECTED_OR2_OCR_HEURISTIC_COUNTS_NOT_SEMANTIC_COVERAGE';
coverage.metrics = correctedCounts;
coverage.interpretation = {
  semanticSourceAuthorityEstablished: false,
  sourceDirectCoverage: null,
  noGoFromSourceGapEstablished: false,
  reason: '197/38/157 are OCR keyword, trend-marker and marker-miss classifications; they are not semantic authority counts.',
};
writeJson(coverageFile, coverage);
writeText('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md', `
# Thai Predictive Authority Coverage — OR2 truth correction

Status: **OCR HEURISTIC CLASSIFICATION COMPLETE — SEMANTIC SOURCE AUTHORITY NOT ESTABLISHED**

The OR2 values 197 event candidates, 38 trend candidates and 157 marker misses are not semantic source-authority coverage. All 392 periods remain semantically unreviewed under OR2; source-direct authorized = 0 until re-established with specific evidence.
`);

candidate14.status = 'OWNER_REJECTED_CANDIDATE_0014_METHODOLOGICAL_COPY_NOT_RUNTIME';
candidate14.ownerDecision = {
  accepted: false,
  reasons: [
    'OR2 atoms were promoted from OCR keyword/marker heuristics.',
    'Reader copy used planet influence and period-direction methodology instead of supported results.',
    'The copy did not meet the Owner reader-copy contract.',
  ],
};
writeJson(candidate14File, candidate14);

const contract = {
  version: 1,
  status: 'OWNER_AUTHORIZED_SYNTHESIS_CONTRACT_PROPOSED_PENDING_CONTENT_REVIEW',
  generatedAt,
  ownerAuthorization: {
    mahabhutPrimary: true,
    canonSupplementAllowed: true,
    deepResearchSupplementAllowed: true,
    astrologerRequired: false,
    multiSignalSynthesisAllowed: true,
    synthesisMayBePresentedAsSourceQuotation: false,
    predictiveAccuracyClaimAllowed: false,
  },
  authorityTiers: [
    { tier: 'A', id: 'SOURCE_DIRECT_EVENT', minimumIndependentSignals: 1, requirements: ['Specific source passage states an event or result for the exact context and period.', 'Semantic review record identifies the complete clause and its boundary.'], allowed: ['State that result directly within its original period/domain.'], prohibited: ['Add date, amount, diagnosis or event family absent from the passage.'] },
    { tier: 'B', id: 'SOURCE_DIRECT_TREND', minimumIndependentSignals: 1, requirements: ['Specific source passage states a direction for the exact context and period.', 'Semantic review record confirms that the text is a trend rather than an event.'], allowed: ['State only the supported direction.'], prohibited: ['Convert a direction into a concrete event.'] },
    { tier: 'C', id: 'OWNER_AUTHORIZED_MULTI_SIGNAL_SYNTHESIS', minimumIndependentSignals: 2, requirements: ['At least two independently sourced signals agree in domain, period and polarity.', 'Every input and synthesis rule is recorded.', 'Placement fact is never sufficient by itself.'], allowed: ['Write a direct domain prediction no stronger than the aligned inputs.'], prohibited: ['Invent an unsupported event family.', 'Hide conflict.', 'Present synthesis as a source quotation.'] },
    { tier: 'D', id: 'INSUFFICIENT', minimumIndependentSignals: 0, requirements: ['Evidence is missing, dependent, conflicting or too weak.'], allowed: ['Omit the reader claim.'], prohibited: ['Generic filler.', 'Personality substitution.', 'Advice substitution.'] },
  ],
  independencePolicy: {
    placementFactAloneQualifiesForTierC: false,
    derivedCopiesCountSeparately: false,
    sameEvidenceClauseCountSeparately: false,
    independentSignalsRequireDistinctEvidenceOwners: true,
  },
  conflictPolicy: {
    cherryPickingAllowed: false,
    arbitraryScoreThresholdAllowed: false,
    onConflict: ['reduce claim strength when a narrower common conclusion remains', 'otherwise classify Tier D and omit'],
  },
  readerCopyBoundary: {
    methodologyInPrediction: false,
    planetInfluenceAsPrediction: false,
    predictionToAdviceConversion: false,
    personalityAsPrediction: false,
    genericFiller: false,
    monthlyPredictionWithoutTimeBucketAuthority: false,
    certaintyCeiling: 'No stronger than the weakest required signal after conflict handling.',
  },
  unknownTimePolicy: { failClosed: true, noonSubstitution: false, ascendant: false, houses: false, thaiAstrologicalDay: false, knownCopyLeakage: false },
};
writeJson('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.json', contract);
writeText('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.md', `
# Thai Predictive Synthesis Contract V1

Status: **OWNER-AUTHORIZED FOUNDATION — PENDING OWNER CONTENT REVIEW**

## Authority tiers

- Tier A — SOURCE_DIRECT_EVENT: state only an event/result explicitly present for the exact context and period.
- Tier B — SOURCE_DIRECT_TREND: state only the direction explicitly present; never turn it into an event.
- Tier C — OWNER_AUTHORIZED_MULTI_SIGNAL_SYNTHESIS: require at least two independent source-backed signals aligned by domain, period and polarity. Record all inputs and the synthesis rule. Placement alone never qualifies.
- Tier D — INSUFFICIENT: omit; never replace the gap with filler, personality or advice.

Conflicts reduce strength or force omission. Synthesis is product interpretation, never a quotation or predictive-accuracy claim. Unknown birth time remains fail-closed.
`);
writeJson('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object',
  required: ['version', 'status', 'ownerAuthorization', 'authorityTiers', 'independencePolicy', 'conflictPolicy', 'readerCopyBoundary', 'unknownTimePolicy'],
  properties: { version: { const: 1 }, authorityTiers: { type: 'array', minItems: 4, maxItems: 4, items: { type: 'object', required: ['tier', 'id', 'minimumIndependentSignals', 'requirements', 'allowed', 'prohibited'] } } },
});

const common = {
  applicableContexts: ['known birth time with exact Mahabhut context and life period'],
  minimumIndependentSignalCount: 2,
  periodHorizon: 'exact matched life period only',
  prohibitedEscalation: ['specific event absent from inputs', 'specific date or month', 'specific amount', 'diagnosis', 'personality substitution', 'advice substitution'],
  conflictHandling: 'Use only the narrow common conclusion; if polarity or domain remains unresolved, classify Tier D and omit.',
  certaintyBoundary: 'Reader text cannot be stronger than the weakest required signal.',
  deepResearchReferences: [],
  ownerAuthorizationStatus: 'AUTHORIZED_FOR_EVIDENCE_CANDIDATE_NOT_RUNTIME',
};
const rules = [
  { synthesisRuleId: 'SYN-A-EXACT-EVENT', authorityTier: 'A', ...common, minimumIndependentSignalCount: 1, requiredSignals: ['semantically reviewed exact source event clause'], domain: 'source-clause domain', polarity: 'source-clause polarity', allowedConclusion: 'The exact event/result, paraphrased without extra specificity.', readerCopyExamples: ['ช่วงนี้งานเดินหน้าได้คล่องขึ้น'], negativeExamples: ['คำว่า งาน ปรากฏ จึงทำนายว่างานดี'], sourceReferences: ['target dossier semantic source record'], canonReferences: [] },
  { synthesisRuleId: 'SYN-B-EXACT-TREND', authorityTier: 'B', ...common, minimumIndependentSignalCount: 1, requiredSignals: ['semantically reviewed exact source trend clause'], domain: 'source trend domain', polarity: 'source direction', allowedConclusion: 'The stated direction only.', readerCopyExamples: ['ช่วงนี้เรื่องที่รับผิดชอบเดินหน้าได้มั่นคงขึ้น'], negativeExamples: ['ดวงขึ้นจึงจะได้เลื่อนตำแหน่ง'], sourceReferences: ['target dossier semantic source record'], canonReferences: [] },
  { synthesisRuleId: 'SYN-C-PERIOD-PLANET-TAKSA-HOUSE', authorityTier: 'C', ...common, requiredSignals: ['exact life-period placement', 'planet semantic scope from a distinct source unit', 'Taksa domain scope from a distinct source unit', 'house direction from a distinct source unit'], domain: 'intersection of planet and Taksa scopes', polarity: 'house direction after conflict handling', allowedConclusion: 'A domain direction bounded to the exact life period.', readerCopyExamples: ['การเรียนรู้และคำแนะนำจากผู้มีประสบการณ์ช่วยให้ตั้งหลักได้ดีขึ้น'], negativeExamples: ['อยู่เรือนราชาจึงได้เลื่อนตำแหน่ง'], sourceReferences: ['MAHABHUT_RULE_APPLICATION_MATRIX_392'], canonReferences: ['MH2537-PLANET-*', 'MH2537-TAKSA-*', 'MH2537-HOUSE-*-DIRECTION'] },
  { synthesisRuleId: 'SYN-C-SOURCE-EVENT-CANON-BOUNDARY', authorityTier: 'C', ...common, requiredSignals: ['exact source event', 'matching Canon domain boundary from a distinct source clause'], domain: 'exact event domain', polarity: 'source event polarity', allowedConclusion: 'A narrower plain-language result that both inputs support.', readerCopyExamples: ['เงินหมุนใช้ได้ต่อเนื่องขึ้นในช่วงนี้'], negativeExamples: ['มีเงินใช้จึงจะได้เงินก้อน'], sourceReferences: ['target dossier semantic source record'], canonReferences: ['matching production Canon unit'] },
  { synthesisRuleId: 'SYN-CONFLICT-REDUCE-OR-OMIT', authorityTier: 'D', ...common, requiredSignals: ['two or more signals with unresolved domain or polarity conflict'], domain: 'conflicted', polarity: 'conflicted', allowedConclusion: 'No reader prediction unless a narrower common conclusion survives.', readerCopyExamples: ['omit'], negativeExamples: ['เลือกเฉพาะสัญญาณด้านบวก'], sourceReferences: ['all conflicting input refs'], canonReferences: ['all conflicting Canon refs'] },
  { synthesisRuleId: 'SYN-UNKNOWN-FAIL-CLOSED', authorityTier: 'D', ...common, applicableContexts: ['unknown birth time'], requiredSignals: ['birth time unavailable'], domain: 'time-dependent fields', polarity: 'not applicable', allowedConclusion: 'Omit all time-dependent prediction sections.', readerCopyExamples: ['ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด'], negativeExamples: ['แทนเวลาเกิดด้วยเที่ยงวัน'], sourceReferences: [], canonReferences: [] },
  { synthesisRuleId: 'SYN-HORIZON-REQUIRES-TIME-BUCKET', authorityTier: 'D', ...common, requiredSignals: ['explicit source-backed horizon with start/end applicability'], domain: 'horizon', polarity: 'not applicable without the signal', allowedConclusion: 'Omit 12-month and monthly prediction when the horizon signal is absent.', readerCopyExamples: ['omit'], negativeExamples: ['นำช่วงอายุทั้งช่วงมาเขียนเป็นคำทำนาย 12 เดือน'], sourceReferences: [], canonReferences: [] },
  { synthesisRuleId: 'SYN-ADVICE-SEPARATION', authorityTier: 'D', ...common, requiredSignals: ['reader advice authored separately after predictions'], domain: 'advice', polarity: 'not a prediction', allowedConclusion: 'Advice appears only in the advice section and never supplies missing prediction content.', readerCopyExamples: ['วางแผนเงินสำรองก่อนรับภาระเพิ่ม'], negativeExamples: ['ควรวางแผน จึงถือว่าเป็นคำทำนายการเงิน'], sourceReferences: [], canonReferences: [] },
];
const rulebook = { version: 1, status: 'OWNER_AUTHORIZED_SYNTHESIS_RULEBOOK_PROPOSED_NOT_RUNTIME', generatedAt, contractRef: 'THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1', counts: { rules: rules.length, tierA: 1, tierB: 1, tierC: 2, tierDGuardrails: 4 }, rules };
writeJson('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.json', rulebook);
writeText('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.md', `
# Thai Predictive Synthesis Rulebook V1

Status: **OWNER-AUTHORIZED EVIDENCE RULEBOOK — NOT RUNTIME**

Eight rules implement exact-event, exact-trend, multi-signal domain synthesis, source-event boundary synthesis, conflict omission, Unknown fail-closed behavior, horizon gating and advice separation. Tier C always requires at least two independent evidence owners; placement alone is rejected.
`);
writeJson('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'contractRef', 'counts', 'rules'],
  properties: { version: { const: 1 }, rules: { type: 'array', minItems: 8, items: { type: 'object', required: ['synthesisRuleId', 'authorityTier', 'applicableContexts', 'requiredSignals', 'minimumIndependentSignalCount', 'domain', 'periodHorizon', 'polarity', 'allowedConclusion', 'prohibitedEscalation', 'conflictHandling', 'certaintyBoundary', 'readerCopyExamples', 'negativeExamples', 'sourceReferences', 'canonReferences', 'deepResearchReferences', 'ownerAuthorizationStatus'] } } },
});

console.log(JSON.stringify({ status: 'PASS_GENERATED', correctedCounts, automatedPages: automatedInventory.pages.length, contractTiers: contract.authorityTiers.length, synthesisRules: rules.length }, null, 2));
