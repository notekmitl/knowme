#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const clone = (value) => JSON.parse(JSON.stringify(value));
const add = (errors, category, code, detail) => errors.push({ category, code, detail });

const requiredRuleFields = [
  'synthesisRuleId', 'applicableContexts', 'requiredSignals', 'minimumIndependentSignalCount', 'domain', 'periodHorizon',
  'polarity', 'allowedConclusion', 'prohibitedEscalation', 'conflictHandling', 'certaintyBoundary', 'readerCopyExamples',
  'negativeExamples', 'sourceReferences', 'canonReferences', 'deepResearchReferences', 'ownerAuthorizationStatus',
];
const bannedReader = /ดวง(?:ขึ้น|ตก)ภายใต้อิทธิพลของดาว|ตามหลักฐาน|ข้อมูลจากเรือน|\b(?:source|evidence|methodology)\b|เดือนดี|เดือนควรระวัง|ลองย้อน|มีแนวโน้ม|มีโอกาส|อาจ|น่าจะ/iu;
const adviceLanguage = /(?:ควร|แนะนำให้|ลอง|อย่าลืม)/u;
const psychologyLanguage = /(?:นิสัย|เป็นคนที่|บุคลิก)/u;

function validateSchemaShape(data, schema, label, errors) {
  if (schema.type === 'object' && (data === null || Array.isArray(data) || typeof data !== 'object')) add(errors, 'schema', 'TYPE', label);
  for (const field of schema.required ?? []) if (!(field in data)) add(errors, 'schema', 'REQUIRED', `${label}:${field}`);
  for (const [field, definition] of Object.entries(schema.properties ?? {})) {
    if (!(field in data)) continue;
    if ('const' in definition && data[field] !== definition.const) add(errors, 'schema', 'CONST', `${label}:${field}`);
    if (definition.type === 'array') {
      if (!Array.isArray(data[field])) add(errors, 'schema', 'ARRAY', `${label}:${field}`);
      else {
        if (definition.minItems !== undefined && data[field].length < definition.minItems) add(errors, 'schema', 'MIN_ITEMS', `${label}:${field}`);
        if (definition.maxItems !== undefined && data[field].length > definition.maxItems) add(errors, 'schema', 'MAX_ITEMS', `${label}:${field}`);
      }
    }
  }
}

function sourceRecordErrors(record) {
  const errors = [];
  if (!record.evidenceId || !record.excerpt || !record.correctedTranscription || !record.normalizedMeaning) errors.push('SOURCE_SEMANTIC_RECORD_INCOMPLETE');
  if (!Array.isArray(record.pages) || record.pages.length === 0) errors.push('SOURCE_PAGE_MISSING');
  if (!Array.isArray(record.domains) || record.domains.length === 0) errors.push('SOURCE_DOMAIN_MISSING');
  if (record.semanticPurpose === 'EXAMPLE_OR_GENERAL_EXPLANATION' && /^SOURCE_DIRECT_/u.test(record.classification)) errors.push('EXAMPLE_PROMOTED_TO_PREDICTION');
  if (record.classification === 'OCR_KEYWORD_HIT') errors.push('KEYWORD_HIT_NOT_AUTHORITY');
  if (record.markerFound === false && record.classification === 'NO_DIRECT_STATEMENT') errors.push('MARKER_MISS_NOT_NO_DIRECT_PROOF');
  if (record.detectedDomains?.length > 1 && record.domains?.length === 1) errors.push('MULTI_DOMAIN_COLLAPSED_BY_REGEX_ORDER');
  return errors;
}

function claimErrors(claim, sourceById, ruleIds) {
  const errors = [];
  if (bannedReader.test(claim.fullReaderText)) errors.push('METHODOLOGICAL_OR_HEDGED_READER_COPY');
  if (adviceLanguage.test(claim.fullReaderText)) errors.push('ADVICE_LEAKAGE');
  if (psychologyLanguage.test(claim.fullReaderText)) errors.push('PERSONALITY_SUBSTITUTION');
  if (!['A', 'B', 'C'].includes(claim.authorityTier)) errors.push('TIER_D_READER_CLAIM');
  if (claim.classification !== 'PREDICTION') errors.push('PREDICTION_CLASSIFICATION_REQUIRED');
  if (!Array.isArray(claim.sourceDirectAtomRefs) || claim.sourceDirectAtomRefs.length === 0) errors.push('SOURCE_REF_MISSING');
  for (const ref of claim.sourceDirectAtomRefs ?? []) if (!sourceById.has(ref)) errors.push('SOURCE_REF_NOT_DOSSIER_SEMANTIC_RECORD');
  if (claim.authorityTier === 'A' && !(claim.sourceDirectAtomRefs ?? []).some((ref) => sourceById.get(ref)?.classification === 'SOURCE_DIRECT_EVENT')) errors.push('TIER_A_EVENT_SOURCE_MISSING');
  if (claim.authorityTier === 'B' && !(claim.sourceDirectAtomRefs ?? []).some((ref) => sourceById.get(ref)?.classification === 'SOURCE_DIRECT_TREND')) errors.push('TIER_B_TREND_SOURCE_MISSING');
  if (claim.authorityTier === 'C') {
    if (claim.independentSignalCount < 2) errors.push('TIER_C_INDEPENDENT_SIGNAL_COUNT');
    if (!claim.synthesisRuleRefs?.length) errors.push('TIER_C_SYNTHESIS_RULE_MISSING');
    for (const ref of claim.synthesisRuleRefs ?? []) if (!ruleIds.has(ref)) errors.push('SYNTHESIS_RULE_REF_NOT_FOUND');
  }
  if (claim.prohibitedEscalationCheck !== 'PASS') errors.push('PROHIBITED_ESCALATION');
  if (claim.conflictResult === 'UNRESOLVED') errors.push('UNRESOLVED_CONFLICT');
  return errors;
}

function datasetErrors(data, options = {}) {
  const errors = [];
  const { correction, inventory, contract, rulebook, dossier, candidate14, candidate15, knownText, unknownText, robustness } = data;
  if (correction.correctedCounts.heuristic_event_candidates !== 197 || correction.correctedCounts.heuristic_trend_candidates !== 38 || correction.correctedCounts.marker_not_found_periods !== 157) add(errors, 'truth', 'OR2_HEURISTIC_COUNTERS', JSON.stringify(correction.correctedCounts));
  if (correction.correctedCounts.semantic_reviewed_periods !== 0 || correction.correctedCounts.visually_verified_periods !== 0 || correction.correctedCounts.source_direct_authorized_periods !== 0) add(errors, 'truth', 'OR2_FALSE_AUTHORITY_REMAINS', JSON.stringify(correction.correctedCounts));
  if (inventory.pages.length !== 181 || inventory.pages.some((page) => page.semanticReviewEvidence !== null || page.authorityStatus !== 'INVENTORY_ONLY')) add(errors, 'inventory', 'AUTOMATED_INVENTORY_PROMOTED_TO_REVIEW', '181-page inventory');
  if (inventory.injectedVisuallyReviewed === true && !inventory.injectedReviewRecord) add(errors, 'inventory', 'VISUAL_FLAG_WITHOUT_REVIEW_RECORD', 'negative-control mutation');
  if (contract.authorityTiers.map((tier) => tier.tier).join('') !== 'ABCD') add(errors, 'contract', 'AUTHORITY_TIERS', contract.authorityTiers.map((tier) => tier.tier).join(','));
  if (contract.independencePolicy.placementFactAloneQualifiesForTierC !== false || contract.ownerAuthorization.predictiveAccuracyClaimAllowed !== false) add(errors, 'contract', 'CONTRACT_BOUNDARY', 'placement/accuracy');
  const ruleIds = new Set(rulebook.rules.map((rule) => rule.synthesisRuleId));
  if (ruleIds.size !== rulebook.rules.length || rulebook.rules.length !== 8) add(errors, 'rulebook', 'RULE_COUNT_OR_DUPLICATE', String(rulebook.rules.length));
  for (const rule of rulebook.rules) {
    for (const field of requiredRuleFields) if (!(field in rule)) add(errors, 'rulebook', 'RULE_FIELD_MISSING', `${rule.synthesisRuleId}:${field}`);
    if (rule.authorityTier === 'C' && rule.minimumIndependentSignalCount < 2) add(errors, 'rulebook', 'TIER_C_MINIMUM', rule.synthesisRuleId);
  }
  if (dossier.reviewRecords.length !== 3 || dossier.reviewRecords.some((record) => record.reviewMethod !== 'AI_VISUAL_SEMANTIC_REVIEW' || !record.observation || record.observation.length < 80)) add(errors, 'dossier', 'VISUAL_SEMANTIC_REVIEW_RECORD', 'pages 290-292');
  if (dossier.reviewType !== 'AI_VISUAL_SEMANTIC_REVIEW_NOT_HUMAN_REVIEW' || dossier.humanReview !== 'PENDING') add(errors, 'dossier', 'HUMAN_REVIEW_LABEL', dossier.reviewType);
  for (const record of dossier.sourceRecords) for (const code of sourceRecordErrors(record)) add(errors, 'dossier', code, record.evidenceId);
  if (dossier.deepResearchSignals.length !== 0 || !/zero records/u.test(dossier.deepResearchBoundary)) add(errors, 'dossier', 'UNSUPPORTED_DEEP_RESEARCH', 'deep research');
  if (dossier.periodAssessments.length !== 8) add(errors, 'dossier', 'PERIOD_ASSESSMENT_COUNT', String(dossier.periodAssessments.length));
  if (dossier.periodAssessments.some((row) => row.tier === 'C' && ((row.canonRefs?.length ?? 0) < 2 || (row.synthesisRefs?.length ?? 0) === 0))) add(errors, 'dossier', 'TIER_C_EVIDENCE_GAP', 'period assessment');
  if (dossier.periodAssessments.some((row) => row.markerFound === false && row.tier === 'D' && row.resultBoundary === 'MARKER_MISS_ONLY')) add(errors, 'dossier', 'MARKER_MISS_PROMOTED_TO_NO_DIRECT', 'period assessment');
  const sourceById = new Map(dossier.sourceRecords.map((record) => [record.evidenceId, record]));
  const semanticOwners = candidate15.known.predictions.map((claim) => claim.semanticOwner);
  if (new Set(semanticOwners).size !== semanticOwners.length) add(errors, 'candidate', 'DUPLICATE_SEMANTIC_OWNER', 'Candidate 0015');
  for (const claim of candidate15.known.predictions) for (const code of claimErrors(claim, sourceById, ruleIds)) add(errors, 'candidate', code, claim.claimId);
  if (candidate15.known.predictions.some((claim) => claim.period.includes('42-43') || claim.period.includes('61-62'))) add(errors, 'candidate', 'BOUNDARY_EXCEPTION_APPLIED_AT_AGE_44', 'Candidate 0015');
  if (candidate15.known.omissions.length !== 3 || !candidate15.known.omissions.some((row) => row.section === 'ช่วง 12 เดือน')) add(errors, 'candidate', 'TIER_D_OMISSION_GAP', 'Candidate 0015');
  if (candidate15.unknown.predictionClaims.length !== 0 || candidate15.unknown.fixture.noonSubstitution !== false || candidate15.unknown.fixture.ascendant !== null || candidate15.unknown.fixture.houses !== null || candidate15.unknown.fixture.thaiAstrologicalDay !== null) add(errors, 'fixture', 'UNKNOWN_FAIL_CLOSED', 'Candidate 0015');
  if (candidate15.fixture.ascendant !== 'Aquarius 9°24′' || candidate15.fixture.thaiAstrologicalDay !== 'Saturday' || candidate15.fixture.birthTime !== '00:03') add(errors, 'fixture', 'KNOWN_0003_IDENTITY', JSON.stringify(candidate15.fixture));
  if ((knownText.match(/ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน/gu) ?? []).length !== 1 || (unknownText.match(/ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน/gu) ?? []).length !== 1) add(errors, 'candidate', 'DISCLAIMER_COUNT', 'Known/Unknown');
  if (/## (?:ความรักและความสัมพันธ์|สุขภาพ|ช่วง 12 เดือน)/u.test(knownText)) add(errors, 'candidate', 'TIER_D_HEADING_RENDERED', 'Known');
  if (/## (?:การงาน|การเงิน|คำทำนายปัจจุบัน|ช่วงชีวิตถัดไป)/u.test(unknownText)) add(errors, 'fixture', 'KNOWN_TO_UNKNOWN_LEAKAGE', 'Unknown');
  const candidate14Text = candidate14.surfaces?.flatMap((surface) => surface.claims ?? []).map((claim) => claim.text).join('\n') ?? '';
  if (!/OWNER_REJECTED/u.test(candidate14.status) || !/ดวงขึ้นภายใต้อิทธิพลของดาว/u.test(candidate14Text)) add(errors, 'regression', 'CANDIDATE_0014_REJECTION_NOT_PROVEN', candidate14.status);
  if (options.requireRobustness) {
    if (!robustness || robustness.profiles.length !== 15 || robustness.counts.known !== 12 || robustness.counts.unknown !== 3) add(errors, 'robustness', 'PROFILE_COUNT', robustness ? JSON.stringify(robustness.counts) : 'missing');
    else {
      if (robustness.counts.unsupportedClaims !== 0 || robustness.counts.knownToUnknownLeakage !== 0 || robustness.counts.exactDuplicates !== 0 || robustness.counts.synonymOnlyDiversification !== 0) add(errors, 'robustness', 'ROBUSTNESS_GATE', JSON.stringify(robustness.counts));
      if (robustness.profiles.filter((profile) => profile.birthTimeMode === 'unknown').some((profile) => profile.readerClaims.length !== 0)) add(errors, 'robustness', 'UNKNOWN_READER_CLAIM', '15 profiles');
    }
  }
  return errors;
}

function loadDataset() {
  const robustnessFile = path.join(ROOT, 'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.json');
  return {
    correction: readJson('docs/PR114_OR2_OCR_HEURISTIC_RECLASSIFICATION.json'),
    inventory: readJson('knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.json'),
    contract: readJson('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.json'),
    rulebook: readJson('knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.json'),
    dossier: readJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json'),
    candidate14: readJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json'),
    candidate15: readJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.json'),
    knownText: fs.readFileSync(path.join(ROOT, 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_KNOWN.md'), 'utf8'),
    unknownText: fs.readFileSync(path.join(ROOT, 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_UNKNOWN.md'), 'utf8'),
    robustness: fs.existsSync(robustnessFile) ? readJson('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.json') : null,
  };
}

function runNegativeControls(base) {
  const controls = [];
  const run = (id, expectedCode, mutate) => {
    const data = clone(base);
    mutate(data);
    const errors = datasetErrors(data, { requireRobustness: false });
    controls.push({ id, mutationUsesRealEvidenceData: true, expectedCode, rejected: errors.some((error) => error.code === expectedCode), observedCodes: [...new Set(errors.map((error) => error.code))] });
  };
  run('keyword-work-in-non-prediction', 'EXAMPLE_PROMOTED_TO_PREDICTION', (data) => { const row = data.dossier.sourceRecords[0]; row.excerpt = 'คำว่า งาน อยู่ในตัวอย่างทั่วไป ไม่ใช่คำทำนาย'; row.semanticPurpose = 'EXAMPLE_OR_GENERAL_EXPLANATION'; row.classification = 'SOURCE_DIRECT_EVENT'; });
  run('disease-word-in-general-explanation', 'EXAMPLE_PROMOTED_TO_PREDICTION', (data) => { const row = data.dossier.sourceRecords[1]; row.excerpt = 'โรค เป็นคำอธิบายทั่วไป'; row.semanticPurpose = 'EXAMPLE_OR_GENERAL_EXPLANATION'; row.classification = 'SOURCE_DIRECT_TREND'; });
  run('marker-misread-with-existing-prose', 'MARKER_MISS_PROMOTED_TO_NO_DIRECT', (data) => { const row = data.dossier.periodAssessments[1]; row.markerFound = false; row.tier = 'D'; row.resultBoundary = 'MARKER_MISS_ONLY'; });
  run('multi-domain-collapsed-to-work', 'MULTI_DOMAIN_COLLAPSED_BY_REGEX_ORDER', (data) => { const row = data.dossier.sourceRecords[0]; row.detectedDomains = ['health', 'work', 'finance']; row.domains = ['work']; });
  run('visual-flag-without-review-record', 'VISUAL_FLAG_WITHOUT_REVIEW_RECORD', (data) => { data.inventory.injectedVisuallyReviewed = true; data.inventory.injectedReviewRecord = null; });
  run('planet-name-used-as-result', 'METHODOLOGICAL_OR_HEDGED_READER_COPY', (data) => { data.candidate15.known.predictions[2].fullReaderText = 'ช่วงนี้ดวงขึ้นภายใต้อิทธิพลของดาวพฤหัส'; });
  run('heuristic-hit-promoted-to-source-direct', 'SOURCE_REF_NOT_DOSSIER_SEMANTIC_RECORD', (data) => { data.candidate15.known.predictions[0].sourceDirectAtomRefs = ['SDEA-OR2-MAHABHUT2537-REM0-SATURDAY-SATURN-0-10']; });
  run('no-direct-from-marker-miss', 'MARKER_MISS_NOT_NO_DIRECT_PROOF', (data) => { const row = data.dossier.sourceRecords[0]; row.markerFound = false; row.classification = 'NO_DIRECT_STATEMENT'; });
  return controls;
}

export function validateOr3(options = {}) {
  const data = loadDataset();
  const errors = [];
  const schemaPairs = [
    ['knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.json', 'knowledge/canon/proposed/AUTOMATED_PAGE_IMAGE_AND_OCR_INVENTORY_181.schema.json'],
    ['knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.json', 'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1.schema.json'],
    ['knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.json', 'knowledge/canon/proposed/THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1.schema.json'],
    ['docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json', 'docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.schema.json'],
    ['docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.json', 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.schema.json'],
  ];
  if (options.requireRobustness) schemaPairs.push(['docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.json', 'docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.schema.json']);
  for (const [dataFile, schemaFile] of schemaPairs) validateSchemaShape(readJson(dataFile), readJson(schemaFile), dataFile, errors);
  errors.push(...datasetErrors(data, options));
  const controls = runNegativeControls(data);
  for (const control of controls) if (!control.rejected) add(errors, 'negative_control', 'CONTROL_NOT_REJECTED', control.id);
  const counts = {
    schemaFiles: schemaPairs.length, schemaErrors: errors.filter((error) => error.category === 'schema').length,
    pagesWithSemanticReviewEvidence: data.dossier.reviewRecords.length, dossierSourceRecords: data.dossier.sourceRecords.length,
    dossierCanonSignals: data.dossier.canonSignals.length, synthesisRules: data.rulebook.rules.length,
    candidateKnownPredictions: data.candidate15.known.predictions.length, candidateUnknownPredictions: data.candidate15.unknown.predictionClaims.length,
    negativeControls: controls.length, negativeControlsRejected: controls.filter((control) => control.rejected).length,
    robustnessProfiles: data.robustness?.profiles.length ?? 0, errors: errors.length,
  };
  return { version: 1, status: errors.length === 0 ? (options.requireRobustness ? 'PASS_OR3_PENDING_OWNER_CONTENT_REVIEW_NOT_RUNTIME' : 'PASS_OR3_PHASE2') : 'FAIL', generatedAt: '2026-09-01T00:00:00+07:00', counts, controls, errors };
}

function main() {
  const args = new Set(process.argv.slice(2));
  const requireRobustness = !args.has('--phase2');
  const result = validateOr3({ requireRobustness });
  if (!args.has('--no-write')) {
    writeJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_NEGATIVE_CONTROLS.json', { version: 1, status: result.controls.every((control) => control.rejected) ? 'PASS' : 'FAIL', counts: { controls: result.controls.length, rejected: result.controls.filter((control) => control.rejected).length, failures: result.controls.filter((control) => !control.rejected).length }, controls: result.controls });
    writeJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_VALIDATION.json', result);
    writeText('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR3_VALIDATION.md', `
# Thai Predictive Authority Foundation V3 OR3 Validation

Status: **${result.status}**

Schemas ${result.counts.schemaFiles}, semantic page records ${result.counts.pagesWithSemanticReviewEvidence}, dossier source/Canon signals ${result.counts.dossierSourceRecords}/${result.counts.dossierCanonSignals}, synthesis rules ${result.counts.synthesisRules}, Candidate 0015 Known/Unknown predictions ${result.counts.candidateKnownPredictions}/${result.counts.candidateUnknownPredictions}, negative controls ${result.counts.negativeControlsRejected}/${result.counts.negativeControls}, robustness profiles ${result.counts.robustnessProfiles}, errors ${result.counts.errors}.
`);
  }
  console.log(JSON.stringify(result, null, 2));
  if (result.status === 'FAIL') process.exitCode = 1;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main();
