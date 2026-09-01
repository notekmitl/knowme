#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
const OCR_DIR = process.argv.find((arg) => arg.startsWith('--ocr-dir='))?.slice(10) ?? 'D:/MahabhutOCR/txt';
const IMAGE_DIR = process.argv.find((arg) => arg.startsWith('--image-dir='))?.slice(12) ?? 'D:/MahabhutOCR/pages';
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const normalize = (value) => String(value ?? '').normalize('NFC').replace(/\s+/gu, ' ').trim();
const shaFile = (file) => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').toUpperCase();
const clone = (value) => structuredClone(value);
const statuses = new Set(['DIRECT_EVENT_FOUND', 'DIRECT_TREND_FOUND', 'NO_DIRECT_STATEMENT_AFTER_FULL_REVIEW', 'UNRESOLVED_SOURCE_TEXT']);

function schemaErrors(document, schema, label) {
  const errors = [];
  const walk = (value, rule, pointer) => {
    if (rule.type === 'object' && (value === null || typeof value !== 'object' || Array.isArray(value))) return errors.push(`${pointer}:type`);
    if (rule.type === 'array' && !Array.isArray(value)) return errors.push(`${pointer}:type`);
    if (rule.const !== undefined && value !== rule.const) errors.push(`${pointer}:const`);
    if (rule.required && value && typeof value === 'object') for (const key of rule.required) if (!(key in value)) errors.push(`${pointer}:missing:${key}`);
    if (Array.isArray(value)) {
      if (rule.minItems !== undefined && value.length < rule.minItems) errors.push(`${pointer}:minItems`);
      if (rule.maxItems !== undefined && value.length > rule.maxItems) errors.push(`${pointer}:maxItems`);
      if (rule.items) value.forEach((item, index) => walk(item, rule.items, `${pointer}[${index}]`));
    }
    if (rule.properties && value && typeof value === 'object' && !Array.isArray(value)) for (const [key, child] of Object.entries(rule.properties)) if (key in value) walk(value[key], child, `${pointer}.${key}`);
  };
  walk(document, schema, label);
  return errors;
}

function validateData(data, { scanShortcuts = true } = {}) {
  const errors = [];
  const add = (category, detail) => errors.push({ category, detail });
  const { ledger, pages, atoms, matrix, corpus, coverage, candidate, audit, inventory, rulebook } = data;
  const matrixById = new Map(matrix.applications.map((row) => [row.applicationId, row]));
  const ledgerById = new Map(ledger.rows.map((row) => [row.matrixApplicationId, row]));
  const atomById = new Map(atoms.atoms.map((atom) => [atom.atomId, atom]));

  if (ledger.rows.length !== 392) add('ledger', `rows:${ledger.rows.length}`);
  if (ledgerById.size !== 392) add('ledger', `uniqueMatrixApplicationIds:${ledgerById.size}`);
  if (matrix.applications.length !== 392 || matrixById.size !== 392) add('matrix', 'application count/uniqueness');
  for (const row of ledger.rows) {
    const matrixRow = matrixById.get(row.matrixApplicationId);
    if (!matrixRow) { add('ledger', `${row.matrixApplicationId}:missing matrix`); continue; }
    if (!statuses.has(row.extractionStatus)) add('ledger', `${row.matrixApplicationId}:invalid status`);
    if (row.extractionStatus === 'UNRESOLVED_SOURCE_TEXT') add('ledger', `${row.matrixApplicationId}:unresolved`);
    if (row.contextId !== matrixRow.context_id || row.agePeriod !== matrixRow.age_period) add('ledger', `${row.matrixApplicationId}:context/period mismatch`);
    if (row.planet !== matrixRow.placement_record.planet || row.taksaRole !== matrixRow.placement_record.taksa_role || row.mahabhutHouse !== matrixRow.placement_record.mahabhut_house || row.periodStatus !== matrixRow.placement_record.period_status) add('ledger', `${row.matrixApplicationId}:matrix binding mismatch`);
    if (!row.pagesOcrChecked.length || !row.pagesVisuallyChecked.length) add('ledger', `${row.matrixApplicationId}:review pages empty`);
    if (row.sourcePageStart > row.sourcePageEnd) add('ledger', `${row.matrixApplicationId}:page range`);
    const direct = row.extractionStatus === 'DIRECT_EVENT_FOUND' || row.extractionStatus === 'DIRECT_TREND_FOUND';
    if (direct && (!row.atomIds.length || !row.shortSourceExcerpts.length)) add('ledger', `${row.matrixApplicationId}:direct row missing evidence`);
    if (!direct && row.atomIds.length) add('ledger', `${row.matrixApplicationId}:non-direct row owns atom`);
    for (const atomId of row.atomIds) if (!atomById.has(atomId)) add('ledger', `${row.matrixApplicationId}:missing atom:${atomId}`);
  }
  if (ledger.counts.periods_total !== 392 || ledger.counts.periods_extraction_completed !== 392 || ledger.counts.periods_unexamined !== 0 || ledger.counts.contexts_first_period_only !== 0 || ledger.counts.first_period_shortcut_count !== 0 || ledger.counts.target_fixture_special_case_count !== 0 || ledger.counts.unexamined_period_count !== 0) add('ledger', 'required counters');

  const expectedPages = [...new Set(corpus.contexts.flatMap((context) => {
    const [start, end] = context.sourcePageRange2537.split('-').map(Number);
    return Array.from({ length: end - start + 1 }, (_, index) => start + index);
  }))].sort((a, b) => a - b);
  if (expectedPages.length !== 181 || pages.pages.length !== 181 || new Set(pages.pages.map((row) => row.page)).size !== 181) add('page_review', '181-page count/uniqueness');
  if (expectedPages.some((page, index) => pages.pages[index]?.page !== page)) add('page_review', 'page sequence mismatch');
  for (const row of pages.pages) {
    if (!row.visuallyReviewed || row.unresolvedText || row.missingText) add('page_review', `page ${row.page}:not fully resolved`);
    const image = path.join(IMAGE_DIR, `page_${String(row.page).padStart(3, '0')}.png`);
    const ocr = path.join(OCR_DIR, `page_${String(row.page).padStart(3, '0')}.txt`);
    if (!fs.existsSync(image) || !fs.existsSync(ocr)) add('page_review', `page ${row.page}:source file missing`);
    else if (shaFile(image) !== row.imageSha256 || shaFile(ocr) !== row.ocrSha256) add('page_review', `page ${row.page}:hash mismatch`);
  }
  if (pages.counts.pagesExpected !== 181 || pages.counts.pagesVisuallyReviewed !== 181 || pages.counts.pagesUnreviewed !== 0 || pages.counts.unresolvedText !== 0) add('page_review', 'required counters');

  if (atomById.size !== atoms.atoms.length) add('atom', 'duplicate atom id');
  for (const atom of atoms.atoms) {
    const ledgerRow = ledgerById.get(atom.matrixApplicationId);
    const matrixRow = matrixById.get(atom.matrixApplicationId);
    if (!ledgerRow || !matrixRow) { add('atom', `${atom.atomId}:missing binding`); continue; }
    if (!ledgerRow.atomIds.includes(atom.atomId)) add('atom', `${atom.atomId}:not owned by ledger`);
    if (atom.contextId !== ledgerRow.contextId) add('atom', `${atom.atomId}:context`);
    const matrixPeriod = atom.matrixAgePeriod ?? atom.agePeriod;
    if (matrixPeriod !== ledgerRow.agePeriod) add('atom', `${atom.atomId}:period`);
    if (atom.visualVerificationStatus !== 'VERIFIED_AGAINST_SOURCE_PAGE_IMAGE' || !Object.keys(atom.pageImageHashes ?? {}).length) add('atom', `${atom.atomId}:visual verification`);
    if (!atom.shortExcerpt || !atom.normalizedMeaning || !atom.domain || !atom.eventFamily || !atom.prohibitedExtrapolations?.length) add('atom', `${atom.atomId}:content fields`);
    let excerptFound = false;
    for (const page of atom.sourcePages) {
      if (!pages.pages.some((entry) => entry.page === page && entry.visuallyReviewed)) add('atom', `${atom.atomId}:unreviewed page ${page}`);
      const ocrText = fs.readFileSync(path.join(OCR_DIR, `page_${String(page).padStart(3, '0')}.txt`), 'utf8');
      if (normalize(ocrText).includes(normalize(atom.shortExcerpt))) excerptFound = true;
    }
    if (!excerptFound && !atom.correctedTranscription) add('atom', `${atom.atomId}:excerpt absent without visual correction`);
  }

  for (const context of corpus.contexts) {
    const rows = matrix.applications.filter((row) => row.context_id === context.contextId);
    if (rows.length !== 8) add('chronology', `${context.contextId}:row count`);
    for (let index = 1; index < rows.length; index++) {
      const previousEnd = Number(rows[index - 1].age_period.split('-')[1]);
      const currentStart = Number(rows[index].age_period.split('-')[0]);
      if (currentStart !== previousEnd + 1) add('chronology', `${context.contextId}:${rows[index - 1].age_period}->${rows[index].age_period}`);
    }
  }

  const directEvent = ledger.rows.filter((row) => row.extractionStatus === 'DIRECT_EVENT_FOUND').length;
  const directTrend = ledger.rows.filter((row) => row.extractionStatus === 'DIRECT_TREND_FOUND').length;
  const noDirect = ledger.rows.filter((row) => row.extractionStatus === 'NO_DIRECT_STATEMENT_AFTER_FULL_REVIEW').length;
  if (directEvent + directTrend + noDirect !== 392) add('coverage', 'period classification total');
  if (coverage.metrics.periods_examined !== 392 || coverage.metrics.unexamined_periods !== 0 || coverage.metrics.pages_visually_reviewed !== 181 || coverage.metrics.periods_with_direct_events !== directEvent || coverage.metrics.periods_with_direct_trends_only !== directTrend || coverage.metrics.periods_with_no_direct_statement !== noDirect || coverage.metrics.unresolved_periods !== 0) add('coverage', 'derived metrics mismatch');
  if (coverage.interpretation.sourceDirectPeriodCoverage !== `${directEvent + directTrend}/392`) add('coverage', 'source-direct ratio');
  if (noDirect > 0 && (!coverage.interpretation.noGo || coverage.interpretation.fullPredictiveAuthority)) add('coverage', 'NO-GO declaration');

  const known = candidate.surfaces.find((surface) => surface.surface === 'Known');
  const unknown = candidate.surfaces.find((surface) => surface.surface === 'Unknown');
  if (!known || !unknown) add('candidate', 'Known/Unknown surfaces');
  for (const claim of known?.claims.filter((item) => item.kind === 'PREDICTION') ?? []) {
    if (!claim.atomIds?.length) add('candidate', `${claim.id}:no atom`);
    for (const atomId of claim.atomIds ?? []) {
      const atom = atomById.get(atomId);
      if (!atom) add('candidate', `${claim.id}:missing atom ${atomId}`);
      else if (atom.contextId !== claim.contextId || atom.matrixApplicationId !== claim.matrixApplicationId || (atom.matrixAgePeriod ?? atom.agePeriod) !== claim.period) add('candidate', `${claim.id}:atom context/period`);
    }
  }
  const readerCopy = [...(known?.claims ?? []), ...(unknown?.claims ?? [])].map((claim) => claim.text).join('\n');
  if (/OCR|ledger|atom|หลักฐานภายใน|methodolog/iu.test(readerCopy)) add('candidate', 'internal evidence disclaimer in reader copy');
  if (/เดือนดี|เดือนควรระวัง|12 เดือน|รายเดือน/u.test(readerCopy)) add('candidate', 'unsupported calendar prediction');
  if (new Set(known?.claims.map((claim) => claim.semanticOwner)).size !== known?.claims.length) add('candidate', 'duplicate semantic owner');
  if (unknown?.claims.some((claim) => claim.kind === 'PREDICTION') || candidate.unknownFixture.noonSubstitution !== false || candidate.unknownFixture.ascendant !== null || candidate.unknownFixture.houses !== null || candidate.unknownFixture.thaiAstrologicalDay !== null || candidate.unknownFixture.knownCopyLeakage !== false || candidate.unknownFixture.emptyPredictionHeadings !== false) add('fixture', 'Unknown fail-closed');
  if (candidate.fixture.ascendant !== 'Aquarius 9°24′' || candidate.fixture.thaiAstrologicalDay !== 'Saturday' || candidate.fixture.contextId !== 'mahabhut2537.rem0.saturday') add('fixture', '00:03 fixture');
  const fixtureSeparation = readJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_FIXTURE_SEPARATION.json');
  if (fixtureSeparation.known0003.ascendant !== 'Aquarius 9°24′' || fixtureSeparation.known0035.ascendant !== 'Aquarius 19°19′' || fixtureSeparation.unknown.noonSubstitution !== false || fixtureSeparation.unknown.ascendant !== null || fixtureSeparation.unknown.houses !== null || fixtureSeparation.unknown.thaiAstrologicalDay !== null) add('fixture', '00:03/00:35/Unknown separation');

  if (audit.reviewType !== 'AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW' || audit.humanReviewStatus !== 'PENDING' || audit.entries.length !== (known?.claims.length ?? 0) + (unknown?.claims.length ?? 0)) add('audit', 'header/count');
  for (const entry of audit.entries) if (!entry.excerpt || !entry.observation || !entry.chronology || !entry.directness || !entry.naturalThaiObservation || !entry.periodDomainAlignment) add('audit', `${entry.auditId}:required fields`);
  if (inventory.sourceDecision.fullContextRangeVisualCrossCheckClaimed !== true || inventory.counts.pagesVisuallyChecked !== 181) add('inventory', 'full visual review declaration');
  if (rulebook.rules.length !== 21) add('rulebook', `rules:${rulebook.rules.length}`);

  if (scanShortcuts) {
    const toolFiles = fs.readdirSync(path.join(ROOT, 'tool')).filter((file) => file.endsWith('.mjs') && !file.includes('validate_predictive_authority_foundation_v3_or2'));
    for (const file of toolFiles) {
      const source = fs.readFileSync(path.join(ROOT, 'tool', file), 'utf8');
      if (/lifePeriodSequence\s*\[\s*0\s*\]|firstPeriodAtoms/u.test(source)) add('shortcut', file);
    }
  }
  return errors;
}

function negativeControls(base) {
  const controls = [];
  const run = (id, mutation, expectedCategory) => {
    const data = clone(base);
    mutation(data);
    const errors = validateData(data, { scanShortcuts: false });
    controls.push({ id, mutationUsesRealEvidenceData: true, expectedCategory, rejected: errors.some((error) => error.category === expectedCategory), observedCategories: [...new Set(errors.map((error) => error.category))] });
  };
  run('drop-real-ledger-row', (d) => d.ledger.rows.pop(), 'ledger');
  run('duplicate-real-matrix-id', (d) => { d.ledger.rows[1].matrixApplicationId = d.ledger.rows[0].matrixApplicationId; }, 'ledger');
  run('mark-real-period-unresolved', (d) => { d.ledger.rows[0].extractionStatus = 'UNRESOLVED_SOURCE_TEXT'; }, 'ledger');
  run('erase-real-direct-evidence', (d) => { const row = d.ledger.rows.find((item) => item.atomIds.length); row.atomIds = []; row.shortSourceExcerpts = []; }, 'ledger');
  run('assign-atom-to-no-direct-row', (d) => { const row = d.ledger.rows.find((item) => item.extractionStatus === 'NO_DIRECT_STATEMENT_AFTER_FULL_REVIEW'); row.atomIds = [d.atoms.atoms[0].atomId]; }, 'ledger');
  run('drop-real-page-review', (d) => d.pages.pages.pop(), 'page_review');
  run('mark-real-page-unreviewed', (d) => { d.pages.pages[0].visuallyReviewed = false; }, 'page_review');
  run('corrupt-real-page-hash', (d) => { d.pages.pages[0].imageSha256 = '0'.repeat(64); }, 'page_review');
  run('remove-real-atom-visual-proof', (d) => { d.atoms.atoms[0].pageImageHashes = {}; }, 'atom');
  run('move-real-atom-to-wrong-period', (d) => { d.atoms.atoms[0].matrixAgePeriod = '999-1000'; }, 'atom');
  run('remove-real-ocr-correction', (d) => { const atom = d.atoms.atoms.find((item) => item.correctedTranscription); atom.correctedTranscription = null; }, 'atom');
  run('count-unexamined-as-no-authority', (d) => { d.coverage.metrics.unexamined_periods = 1; }, 'coverage');
  run('claim-false-full-authority', (d) => { d.coverage.interpretation.fullPredictiveAuthority = true; d.coverage.interpretation.noGo = false; }, 'coverage');
  run('candidate-cross-context-atom', (d) => { const claim = d.candidate.surfaces[0].claims.find((item) => item.kind === 'PREDICTION'); claim.atomIds = [d.atoms.atoms.find((item) => item.contextId !== claim.contextId).atomId]; }, 'candidate');
  run('candidate-internal-evidence-copy', (d) => { d.candidate.surfaces[0].claims[0].text += ' ตรวจจาก OCR ledger'; }, 'candidate');
  run('candidate-monthly-invention', (d) => { d.candidate.surfaces[0].claims[0].text += ' เดือนดี'; }, 'candidate');
  run('unknown-known-copy-leakage', (d) => { d.candidate.unknownFixture.knownCopyLeakage = true; }, 'fixture');
  run('audit-remove-real-excerpt', (d) => { d.audit.entries[0].excerpt = ''; }, 'audit');
  return controls;
}

export function validateOr2() {
  const data = {
    ledger: readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json'),
    pages: readJson('knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.json'),
    atoms: readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json'),
    matrix: readJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json'),
    corpus: readJson('knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json'),
    coverage: readJson('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json'),
    candidate: readJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json'),
    audit: readJson('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR2.json'),
    inventory: readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json'),
    rulebook: readJson('knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.json'),
  };
  const schemaTargets = [
    [data.ledger, readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.schema.json'), 'ledger'],
    [data.pages, readJson('knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.schema.json'), 'pages'],
    [data.atoms, readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json'), 'atoms'],
    [data.matrix, readJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.schema.json'), 'matrix'],
    [data.inventory, readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.schema.json'), 'inventory'],
    [data.rulebook, readJson('knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.schema.json'), 'rulebook'],
  ];
  const schema = schemaTargets.flatMap(([document, shape, label]) => schemaErrors(document, shape, label));
  const errors = validateData(data);
  const controls = negativeControls(data);
  for (const control of controls) if (!control.rejected) errors.push({ category: 'negative_control', detail: control.id });
  const categoryCounts = errors.reduce((acc, error) => ({ ...acc, [error.category]: (acc[error.category] ?? 0) + 1 }), {});
  const direct = data.ledger.rows.filter((row) => row.extractionStatus === 'DIRECT_EVENT_FOUND' || row.extractionStatus === 'DIRECT_TREND_FOUND').length;
  const result = {
    version: 1,
    status: schema.length === 0 && errors.length === 0 ? 'PASS_FULL_REVIEW_SOURCE_DIRECT_GAP_CONFIRMED_NO_GO' : 'FAIL',
    generatedAt: '2026-09-01T00:00:00+07:00',
    counts: { schemaFiles: schemaTargets.length, schemaErrors: schema.length, ledgerRows: data.ledger.rows.length, pagesVisuallyReviewed: data.pages.pages.filter((row) => row.visuallyReviewed).length, atoms: data.atoms.atoms.length, matrixApplications: data.matrix.applications.length, sourceDirectPeriods: direct, noDirectPeriods: 392 - direct, candidateKnownClaims: data.candidate.surfaces[0].claims.length, candidateUnknownClaims: data.candidate.surfaces[1].claims.length, auditEntries: data.audit.entries.length, negativeControls: controls.length, negativeControlsRejected: controls.filter((control) => control.rejected).length, errors: errors.length },
    categoryCounts,
    schemaErrors: schema,
    errors,
  };
  writeJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_NEGATIVE_CONTROLS.json', { version: 1, counts: { controls: controls.length, rejected: controls.filter((control) => control.rejected).length }, controls });
  writeJson('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_VALIDATION.json', result);
  writeText('docs/THAI_PREDICTIVE_AUTHORITY_FOUNDATION_V3_OR2_VALIDATION.md', `# Predictive Authority Foundation V3 OR2 Validation\n\n- Status: **${result.status}**\n- Schemas: ${result.counts.schemaFiles}; errors ${result.counts.schemaErrors}\n- Ledger: ${result.counts.ledgerRows}/392\n- Visual pages: ${result.counts.pagesVisuallyReviewed}/181\n- Source-direct periods: ${result.counts.sourceDirectPeriods}/392\n- No-direct periods after full review: ${result.counts.noDirectPeriods}\n- Atoms: ${result.counts.atoms}\n- Candidate Known/Unknown: ${result.counts.candidateKnownClaims}/${result.counts.candidateUnknownClaims}\n- Negative controls: ${result.counts.negativeControlsRejected}/${result.counts.negativeControls} rejected\n- Errors: ${result.counts.errors}`);
  return result;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = validateOr2();
  console.log(JSON.stringify(result, null, 2));
  process.exitCode = result.status === 'FAIL' ? 1 : 0;
}
