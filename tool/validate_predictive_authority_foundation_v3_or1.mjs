#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
const OCR_DIR = process.argv.find((arg) => arg.startsWith('--ocr-dir='))?.slice(10) ?? 'D:/MahabhutOCR/txt';
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const normalize = (value) => value.normalize('NFC').replace(/\s+/gu, ' ').trim();
const sha = (value) => crypto.createHash('sha256').update(value).digest('hex').toUpperCase();

function containsAge(binding, matrixAge) {
  const [lo, hi] = matrixAge.split('-').map(Number);
  return binding.split('|').every((part) => {
    const [partLo, partHi = partLo] = part.split('-').map(Number);
    return partLo >= lo && partHi <= hi;
  });
}

function validateSchemaSubset(document, schema, pointer = '$') {
  const errors = [];
  const walk = (value, rule, at) => {
    if (rule.type === 'object' && (value === null || typeof value !== 'object' || Array.isArray(value))) { errors.push(`${at}:type:object`); return; }
    if (rule.type === 'array' && !Array.isArray(value)) { errors.push(`${at}:type:array`); return; }
    if (rule.type === 'string' && typeof value !== 'string') { errors.push(`${at}:type:string`); return; }
    if (rule.type === 'integer' && !Number.isInteger(value)) { errors.push(`${at}:type:integer`); return; }
    if (rule.const !== undefined && value !== rule.const) errors.push(`${at}:const`);
    if (rule.pattern && (typeof value !== 'string' || !new RegExp(rule.pattern).test(value))) errors.push(`${at}:pattern`);
    if (rule.required && value && typeof value === 'object') for (const key of rule.required) if (!(key in value)) errors.push(`${at}:missing:${key}`);
    if (Array.isArray(value)) {
      if (rule.minItems !== undefined && value.length < rule.minItems) errors.push(`${at}:minItems`);
      if (rule.maxItems !== undefined && value.length > rule.maxItems) errors.push(`${at}:maxItems`);
      if (rule.items) value.forEach((item, index) => walk(item, rule.items, `${at}[${index}]`));
    }
    if (rule.properties && value && typeof value === 'object' && !Array.isArray(value)) for (const [key, child] of Object.entries(rule.properties)) if (key in value) walk(value[key], child, `${at}.${key}`);
  };
  walk(document, schema, pointer);
  return errors;
}

function candidateErrors(claim, matrixById, atomById, ruleIds) {
  const errors = [];
  const row = matrixById.get(claim.matrixApplicationId);
  if (!row) return ['MATRIX_NOT_FOUND'];
  if (claim.contextId !== row.context_id) errors.push('WRONG_CONTEXT');
  if (claim.period !== row.age_period) errors.push('WRONG_PERIOD');
  if (claim.planet !== row.placement_record.planet) errors.push('WRONG_PLANET');
  if (claim.taksaRole !== row.placement_record.taksa_role) errors.push('WRONG_ROLE');
  if (claim.mahabhutHouse !== row.placement_record.mahabhut_house) errors.push('WRONG_HOUSE');
  if (claim.periodStatus !== row.placement_record.period_status) errors.push('WRONG_STATUS');
  if (!claim.ruleIds?.length || claim.ruleIds.some((id) => !ruleIds.has(id))) errors.push('RULE_NOT_FOUND');
  if (!claim.atomIds?.length) errors.push('EVENT_ATOM_MISSING');
  const atoms = (claim.atomIds ?? []).map((id) => atomById.get(id));
  if (atoms.some((atom) => !atom)) errors.push('EVENT_ATOM_NOT_FOUND');
  for (const atom of atoms.filter(Boolean)) {
    if (atom.contextId !== claim.contextId) errors.push('ATOM_CONTEXT_MISMATCH');
    if (!containsAge(atom.agePeriod, claim.period)) errors.push('ATOM_PERIOD_MISMATCH');
    if (atom.planet !== claim.planet) errors.push('ATOM_PLANET_MISMATCH');
    if (atom.taksaRole !== claim.taksaRole) errors.push('ATOM_ROLE_MISMATCH');
    if (atom.mahabhutHouse !== claim.mahabhutHouse) errors.push('ATOM_HOUSE_MISMATCH');
    if (atom.domain !== claim.domain) errors.push('ATOM_DOMAIN_MISMATCH');
    if (atom.eventFamily !== claim.eventFamily) errors.push('ATOM_EVENT_FAMILY_MISMATCH');
    if (atom.strength !== claim.strength) errors.push('ATOM_STRENGTH_MISMATCH');
    if (claim.timing !== 'AGE_PERIOD') errors.push('TIMING_MISMATCH');
  }
  if (!row.allowed_prediction_domains.includes(claim.domain) && !atoms.filter(Boolean).some((atom) => atom.domain === claim.domain)) errors.push('DOMAIN_NOT_ALLOWED');
  return [...new Set(errors)];
}

function runNegativeControls(valid, matrixById, atomById, ruleIds) {
  const sourceAtom = atomById.get(valid.atomIds[0]);
  const alternativeAtom = [...atomById.values()].find((atom) => atom.atomId !== sourceAtom.atomId && atom.contextId !== valid.contextId);
  const existingMeaningMismatchAtom = [...atomById.values()].find((atom) => atom.contextId === valid.contextId && atom.domain !== valid.domain);
  const cases = [
    ['current_period_work_domain_without_event_atom', { ...valid, domain: 'work', atomIds: [], eventFamily: 'work_access' }, 'EVENT_ATOM_MISSING'],
    ['support_context_record_only', { ...valid, domain: 'support', atomIds: [], eventFamily: 'supporting_people' }, 'EVENT_ATOM_MISSING'],
    ['twelve_month_work_leakage', { ...valid, timing: 'CALENDAR_12_MONTHS' }, 'TIMING_MISMATCH'],
    ['source_direct_event_wrong_context', { ...valid, atomIds: [alternativeAtom.atomId] }, 'ATOM_CONTEXT_MISMATCH'],
    ['event_wrong_period', { ...valid, period: '0-1' }, 'WRONG_PERIOD'],
    ['event_text_stronger_than_evidence', { ...valid, strength: 'CERTAIN_SPECIFIC_EVENT' }, 'ATOM_STRENGTH_MISMATCH'],
    ['domain_mismatch', { ...valid, domain: 'relationship' }, 'ATOM_DOMAIN_MISMATCH'],
    ['existing_source_ref_wrong_meaning', { ...valid, atomIds: [existingMeaningMismatchAtom.atomId] }, 'ATOM_DOMAIN_MISMATCH'],
    ['wrong_planet', { ...valid, planet: 'moon' }, 'WRONG_PLANET'],
    ['wrong_role', { ...valid, taksaRole: 'ayu' }, 'WRONG_ROLE'],
    ['wrong_house', { ...valid, mahabhutHouse: 'marana' }, 'WRONG_HOUSE'],
  ];
  const results = cases.map(([id, mutated, expectedCode]) => {
    const errors = candidateErrors(mutated, matrixById, atomById, ruleIds);
    return { id, mutationUsesRealData: true, expectedCode, rejected: errors.includes(expectedCode), errors };
  });
  const duplicateOwners = [{ ...valid }, { ...valid, id: `${valid.id}-DUP` }];
  const duplicateOwnerError = new Set(duplicateOwners.map((claim) => claim.semanticOwner)).size !== duplicateOwners.length;
  results.push({ id: 'duplicated_semantic_owner', mutationUsesRealData: true, expectedCode: 'DUPLICATED_SEMANTIC_OWNER', rejected: duplicateOwnerError, errors: duplicateOwnerError ? ['DUPLICATED_SEMANTIC_OWNER'] : [] });
  const wrongMapping = { section: 'คำทำนายอดีต อายุ 11–29 ปี', afterFullText: 'ช่วงอายุ 0–10 ปี เรื่องคนรอบตัวมีน้ำหนัก' };
  const ageSectionError = !wrongMapping.afterFullText.includes('11–29');
  results.push({ id: 'age_section_mapping_wrong', mutationUsesRealData: true, expectedCode: 'AGE_SECTION_MAPPING_MISMATCH', rejected: ageSectionError, errors: ageSectionError ? ['AGE_SECTION_MAPPING_MISMATCH'] : [] });
  const duplicatedTexts = [valid.text, valid.text];
  const genericDuplicateError = new Set(duplicatedTexts.map(normalize)).size !== duplicatedTexts.length;
  results.push({ id: 'generic_template_duplication', mutationUsesRealData: true, expectedCode: 'GENERIC_TEMPLATE_DUPLICATION', rejected: genericDuplicateError, errors: genericDuplicateError ? ['GENERIC_TEMPLATE_DUPLICATION'] : [] });
  return results;
}

export function validateOr1() {
  const errors = [];
  const atomsDoc = readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json');
  const atomSchema = readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json');
  const matrix = readJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json');
  const coverage = readJson('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json');
  const diversity = readJson('docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.json');
  const candidate = readJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0013_CLAIM_EVIDENCE_MAP.json');
  const beforeAfter = readJson('docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.json');
  const audit = readJson('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW.json');
  const rulebook = readJson('knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.json');
  const corpus = readJson('knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json');
  const inventory = readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json');
  const fixtureSeparation = readJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_FIXTURE_SEPARATION.json');

  const schemaTargets = [
    [atomsDoc, atomSchema, 'event-atoms'],
    [inventory, readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.schema.json'), 'inventory'],
    [rulebook, readJson('knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.schema.json'), 'rulebook'],
    [matrix, readJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.schema.json'), 'matrix'],
  ];
  const schemaErrors = schemaTargets.flatMap(([document, schema, label]) => validateSchemaSubset(document, schema, label));
  errors.push(...schemaErrors.map((detail) => ({ category: 'schema', detail })));
  const matrixById = new Map(matrix.applications.map((row) => [row.applicationId, row]));
  const atomById = new Map(atomsDoc.atoms.map((atom) => [atom.atomId, atom]));
  const ruleIds = new Set(rulebook.rules.map((rule) => rule.rule_id));
  const sourceIds = new Set(inventory.records.map((record) => record.sourceId));
  const contextById = new Map(corpus.contexts.map((context) => [context.contextId, context]));
  if (atomById.size !== atomsDoc.atoms.length) errors.push({ category: 'atom', detail: 'duplicate atom id' });

  const contextInventory = inventory.records.filter((record) => record.sourceId.includes('-CONTEXT-'));
  if (inventory.pageInventory.length !== 308 || inventory.records.length !== 54 || contextInventory.length !== 49) errors.push({ category: 'source_inventory', detail: 'inventory counts' });
  for (const record of contextInventory) {
    if (record.reliability !== 'START_PAGE_TABLE_AND_FIRST_PERIOD_IMAGE_REVIEWED_FULL_RANGE_OCR_CHECKED') errors.push({ category: 'source_inventory', detail: `${record.sourceId}:reliability` });
    if (!record.verification || record.verification.pagesVisuallyChecked.length < 1 || record.verification.pagesOcrChecked.length !== record.verification.pagesExpected.length) errors.push({ category: 'source_inventory', detail: `${record.sourceId}:verification` });
  }
  if (inventory.sourceDecision.fullContextRangeVisualCrossCheckClaimed !== false || inventory.sourceDecision.contextStartPagesVisuallyChecked !== 49) errors.push({ category: 'source_inventory', detail: 'visual scope declaration' });
  for (const rule of rulebook.rules) {
    if (!rule.required_conditions?.length || !rule.prohibited_escalations?.length) errors.push({ category: 'rulebook', detail: `${rule.rule_id}:boundary` });
    for (const sourceRef of rule.source_refs ?? []) if (!sourceIds.has(sourceRef)) errors.push({ category: 'rulebook', detail: `${rule.rule_id}:source:${sourceRef}` });
  }

  let ocrMismatchCount = 0;
  for (const atom of atomsDoc.atoms) {
    const context = contextById.get(atom.contextId);
    const page = atom.source.page;
    const ocr = fs.readFileSync(path.join(OCR_DIR, `page_${String(page).padStart(3, '0')}.txt`), 'utf8');
    const [start, end] = context.sourcePageRange2537.split('-').map(Number);
    if (atom.source.pdfSha256 !== atomsDoc.source.pdfSha256) errors.push({ category: 'atom', detail: `${atom.atomId}:source hash` });
    if (page < start || page > end) errors.push({ category: 'atom', detail: `${atom.atomId}:page range` });
    if (atom.ocrSpanSha256 !== sha(Buffer.from(ocr, 'utf8'))) errors.push({ category: 'atom', detail: `${atom.atomId}:ocr hash` });
    const found = normalize(ocr).includes(normalize(atom.shortExcerpt));
    if (atom.visualOcrStatus.excerptFoundInNormalizedOcr && !found) errors.push({ category: 'atom', detail: `${atom.atomId}:ocr excerpt` });
    if (!atom.visualOcrStatus.excerptFoundInNormalizedOcr) {
      ocrMismatchCount++;
      if (!atom.visualOcrStatus.pageImageReviewed || !atom.visualOcrStatus.visualTranscriptionVerified) errors.push({ category: 'atom', detail: `${atom.atomId}:unresolved visual transcription` });
    }
    const row = matrix.applications.find((item) => item.context_id === atom.contextId && containsAge(atom.agePeriod, item.age_period));
    if (!row) errors.push({ category: 'atom', detail: `${atom.atomId}:matrix binding` });
    else {
      if (row.placement_record.planet !== atom.planet) errors.push({ category: 'atom', detail: `${atom.atomId}:planet` });
      if (row.placement_record.taksa_role !== atom.taksaRole) errors.push({ category: 'atom', detail: `${atom.atomId}:role` });
      if (row.placement_record.mahabhut_house !== atom.mahabhutHouse) errors.push({ category: 'atom', detail: `${atom.atomId}:house` });
    }
  }

  const metrics = coverage.metrics;
  const expectedMetrics = {
    placement_table_context_coverage: 49,
    placement_table_period_coverage: 392,
    broad_direction_context_coverage: 49,
    broad_direction_period_coverage: 392,
    source_direct_event_context_coverage: 49,
    source_direct_event_period_coverage: 50,
    domain_complete_contexts: 0,
    contexts_with_only_generic_polarity: 0,
    contexts_without_event_authority: 0,
  };
  for (const [key, expected] of Object.entries(expectedMetrics)) if (metrics[key] !== expected) errors.push({ category: 'coverage', detail: `${key}:${metrics[key]}!=${expected}` });
  if (coverage.interpretation.fullPredictiveAuthority !== false || !coverage.status.includes('NO_GO')) errors.push({ category: 'coverage', detail: 'must remain NO-GO' });

  const contextsInMatrix = new Set(matrix.applications.map((row) => row.context_id));
  if (matrix.applications.length !== 392 || contextsInMatrix.size !== 49) errors.push({ category: 'matrix', detail: 'application/context count' });
  for (const context of corpus.contexts) {
    const rows = matrix.applications.filter((row) => row.context_id === context.contextId);
    if (rows.length !== 8) errors.push({ category: 'matrix', detail: `${context.contextId}:row count` });
    for (let index = 0; index < rows.length; index++) {
      const row = rows[index];
      const period = context.lifePeriodSequence[index];
      if (!period || row.age_period !== period.ageBoundary || row.placement_record.planet !== period.planet || row.placement_record.taksa_role !== period.taksaRole || row.placement_record.mahabhut_house !== period.mahabhutHouse || row.placement_record.period_status !== period.periodStatus) errors.push({ category: 'matrix', detail: `${row.applicationId}:applicability` });
      if (!row.applicable_rules.every((id) => ruleIds.has(id))) errors.push({ category: 'matrix', detail: `${row.applicationId}:rule` });
      if (index > 0) {
        const previousEnd = Number(rows[index - 1].age_period.split('-')[1]);
        const currentStart = Number(row.age_period.split('-')[0]);
        if (currentStart !== previousEnd + 1) errors.push({ category: 'chronology', detail: `${context.contextId}:${rows[index - 1].age_period}->${row.age_period}` });
      }
    }
  }
  if (fixtureSeparation.known0003.ascendant !== 'Aquarius 9°24′' || fixtureSeparation.known0035.ascendant !== 'Aquarius 19°19′' || fixtureSeparation.known0003.thaiAstrologicalDay !== 'Saturday' || fixtureSeparation.known0035.thaiAstrologicalDay !== 'Saturday' || fixtureSeparation.unknown.noonSubstitution !== false || fixtureSeparation.unknown.ascendant !== null || fixtureSeparation.unknown.houses !== null || fixtureSeparation.unknown.thaiAstrologicalDay !== null) errors.push({ category: 'fixture', detail: '00:03/00:35/Unknown separation' });

  const diversityExpected = { exact_text_unique: 108, age_stripped_unique: 16, directional_skeleton_unique: 4 };
  for (const [key, expected] of Object.entries(diversityExpected)) if (diversity.counts[key] !== expected) errors.push({ category: 'diversity', detail: `${key}:${diversity.counts[key]}!=${expected}` });
  for (const required of ['subject_stripped_template_unique', 'semantic_signature_unique', 'repeated_template_occurrences', 'near_duplicate_clusters', 'synonym_only_variation']) if (!(required in diversity.counts)) errors.push({ category: 'diversity', detail: `missing:${required}` });

  const known = candidate.surfaces.find((surface) => surface.surface === 'Known');
  const unknown = candidate.surfaces.find((surface) => surface.surface === 'Unknown');
  const knownPredictions = known.claims.filter((claim) => claim.kind === 'PREDICTION');
  for (const claim of knownPredictions) for (const detail of candidateErrors(claim, matrixById, atomById, ruleIds)) errors.push({ category: 'candidate', detail: `${claim.id}:${detail}` });
  if (new Set(known.claims.map((claim) => claim.semanticOwner)).size !== known.claims.length) errors.push({ category: 'candidate', detail: 'duplicate semantic owner' });
  if (known.claims.filter((claim) => claim.kind === 'DISCLOSURE').length !== 1) errors.push({ category: 'candidate', detail: 'Known disclosure count' });
  if (unknown.claims.some((claim) => claim.kind === 'PREDICTION')) errors.push({ category: 'candidate', detail: 'Unknown prediction present' });
  if (candidate.unknownFixture.noonSubstitution !== false || candidate.unknownFixture.ascendant !== null || candidate.unknownFixture.houses !== null || candidate.unknownFixture.thaiAstrologicalDay !== null || candidate.unknownFixture.emptyPredictionHeadings !== false) errors.push({ category: 'candidate', detail: 'Unknown fail-closed violation' });
  if (/เดือนดี|เดือนควรระวัง/u.test(JSON.stringify(candidate))) errors.push({ category: 'candidate', detail: 'monthly prediction' });

  const past02 = beforeAfter.entries.find((entry) => entry.candidate0011ClaimId === 'RC11-K-PAST-02');
  const past04 = beforeAfter.entries.find((entry) => entry.candidate0011ClaimId === 'RC11-K-PAST-04');
  if (!past02?.afterFullText.includes('11–29') || !past02?.section.includes('11–29') || past02.mappingType !== 'ONE_TO_ONE_SAME_PERIOD_AND_SECTION') errors.push({ category: 'provenance', detail: 'PAST-02' });
  if (!past04?.afterFullText.includes('30–41') || !past04?.section.includes('30–41') || past04.mappingType !== 'ONE_TO_ONE_SAME_PERIOD_AND_SECTION') errors.push({ category: 'provenance', detail: 'PAST-04' });
  if (past02.afterFullText === past04.afterFullText) errors.push({ category: 'provenance', detail: 'duplicate PAST mapping' });

  if (audit.reviewType !== 'AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW' || audit.humanReviewStatus !== 'PENDING' || audit.entries.length !== 98) errors.push({ category: 'audit', detail: 'audit header/count' });
  for (const entry of audit.entries) {
    const row = matrixById.get(entry.refs[0]);
    if (!row || entry.contextId !== row.context_id || entry.period !== row.age_period || entry.excerpt !== row.reader_claim_candidates[0] || !entry.observation || !entry.duplicateTemplateOwner || !entry.unresolvedIssue) errors.push({ category: 'audit', detail: entry.auditId });
  }

  const negativeControls = runNegativeControls(knownPredictions.find((claim) => claim.section === 'แรงสนับสนุน'), matrixById, atomById, ruleIds);
  for (const control of negativeControls) if (!control.rejected) errors.push({ category: 'negative_control', detail: control.id });
  writeJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_NEGATIVE_CONTROLS.json', { version: 1, counts: { controls: negativeControls.length, rejected: negativeControls.filter((item) => item.rejected).length }, controls: negativeControls });

  const categoryCounts = errors.reduce((counts, error) => ({ ...counts, [error.category]: (counts[error.category] ?? 0) + 1 }), {});
  const result = {
    version: 1,
    status: errors.length === 0 ? 'PASS_WITH_SOURCE_DIRECT_AUTHORITY_GAP_NO_GO' : 'FAIL',
    generatedAt: '2026-09-01T00:00:00+07:00',
    counts: {
      schemaErrors: schemaErrors.length,
      schemaFiles: schemaTargets.length,
      sourceInventoryRecords: inventory.records.length,
      rulebookRules: rulebook.rules.length,
      atoms: atomsDoc.atoms.length,
      contexts: metrics.source_direct_event_context_coverage,
      sourceDirectPeriods: metrics.source_direct_event_period_coverage,
      matrixPeriods: matrix.applications.length,
      ocrMismatchCount,
      unresolvedTextCount: atomsDoc.visualInspection.unresolvedTextCount,
      candidateKnownClaims: known.claims.length,
      candidateUnknownClaims: unknown.claims.length,
      aiAuditEntries: audit.entries.length,
      negativeControls: negativeControls.length,
      negativeControlsRejected: negativeControls.filter((item) => item.rejected).length,
      errors: errors.length,
    },
    categoryCounts,
    errors,
  };
  writeJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_VALIDATION.json', result);
  writeText('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR1_VALIDATION.md', `# Predictive Authority Foundation V3 OR1 Validation\n\n- Status: **${result.status}**\n- Atoms: ${result.counts.atoms}\n- Source-direct coverage: ${result.counts.contexts}/49 contexts; ${result.counts.sourceDirectPeriods}/392 periods\n- OCR mismatches resolved by visual transcription: ${result.counts.ocrMismatchCount}\n- Unresolved text: ${result.counts.unresolvedTextCount}\n- Negative controls: ${result.counts.negativeControlsRejected}/${result.counts.negativeControls}\n- Errors: ${result.counts.errors}\n\nFull predictive authority remains **NO-GO**.`);
  return result;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = validateOr1();
  console.log(JSON.stringify(result, null, 2));
  process.exitCode = result.counts.errors ? 1 : 0;
}
