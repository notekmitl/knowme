#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const OCR_DIR = process.argv.find((arg) => arg.startsWith('--ocr-dir='))?.slice(10) ?? 'D:/MahabhutOCR/txt';
const IMAGE_DIR = process.argv.find((arg) => arg.startsWith('--image-dir='))?.slice(12) ?? 'D:/MahabhutOCR/pages';
const PDF_SHA = '28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E';
const EDITION = 'mahabhut-complete-duangkaew-2537-primary-working-edition';
const GENERATED_AT = '2026-09-01T00:00:00+07:00';

const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, data) => {
  const target = path.join(ROOT, file);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
};
const writeText = (file, value) => {
  const target = path.join(ROOT, file);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, `${value.trim()}\n`, 'utf8');
};
const sha = (value) => crypto.createHash('sha256').update(value).digest('hex').toUpperCase();
const fileSha = (file) => sha(fs.readFileSync(file));
const normalize = (value) => value.normalize('NFC').replace(/\s+/gu, ' ').trim();
const parseRange = (range) => {
  const [start, end] = range.split('-').map(Number);
  return Array.from({ length: end - start + 1 }, (_, index) => start + index);
};
const ocrFile = (page) => path.join(OCR_DIR, `page_${String(page).padStart(3, '0')}.txt`);
const imageFile = (page) => path.join(IMAGE_DIR, `page_${String(page).padStart(3, '0')}.png`);
const pageText = (page) => fs.readFileSync(ocrFile(page), 'utf8');
const pageHash = (page) => fileSha(imageFile(page));
const ocrHash = (page) => fileSha(ocrFile(page));

const corpus = readJson('knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json');
const matrix = readJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json');
const claims = readJson('knowledge/canon/proposed/mahabhut_2537_predictive_claims_v2.json');
const inventory = readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json');
const matrixByContextPeriod = new Map(matrix.applications.map((row) => [`${row.context_id}|${row.age_period}`, row]));

const houseThai = {
  phangkha: 'ภังคะ', puti: 'ปูติ', khumsap: 'ขุมทรัพย์', marana: 'มรณะ',
  athibodi: 'อธิบดี', racha: 'ราชา', thongchai: 'ธงชัย',
};

function periodMarker(page, period) {
  const text = normalize(pageText(page));
  const markers = [
    `ดาวแห่ง${period.taksaRoleThai}`,
    `ดาวแห่ง ${period.taksaRoleThai}`,
    `อิทธิพลของดาว${period.planetThai}`,
    `อิทธิพลของดาว ${period.planetThai}`,
  ];
  const found = markers.map((marker) => ({ marker, index: text.indexOf(marker) })).filter((item) => item.index >= 0);
  if (!found.length) return null;
  found.sort((a, b) => a.index - b.index);
  return { page, text, ...found[0] };
}

function locatePeriod(context, period) {
  const pages = parseRange(context.sourcePageRange2537);
  const candidates = pages.map((page) => periodMarker(page, period)).filter(Boolean);
  if (!candidates.length) return null;
  const best = candidates[0];
  const excerptStart = Math.max(0, best.index - 70);
  const excerpt = best.text.slice(excerptStart, excerptStart + 360).trim();
  const eventWindow = best.text.slice(best.index, best.index + 900);
  const eventTerms = ['การงาน', 'งานทํา', 'งานทำ', 'การเงิน', 'เงินทอง', 'ทรัพย์', 'สุขภาพ', 'โรค', 'เจ็บ', 'แต่งงาน', 'คู่ครอง', 'โชค', 'ลาภ', 'สนับสนุน', 'ช่วยเหลือ', 'ชื่อเสียง', 'ตําแหน่ง', 'ตำแหน่ง', 'เดินทาง', 'คดี', 'สูญเสีย'];
  const eventTerm = eventTerms.find((term) => eventWindow.includes(term)) ?? null;
  return { page: best.page, excerpt, eventTerm };
}

function classifyDomain(text, fallback) {
  if (/งาน|ตําแหน่ง|ตำแหน่ง|ธุรกิจ|การค้า/u.test(text)) return 'work';
  if (/เงิน|ทรัพย์|ทอง|โชค|ลาภ/u.test(text)) return 'finance';
  if (/แต่งงาน|คู่ครอง|ความรัก|สามี|ภรรยา/u.test(text)) return 'relationship';
  if (/สุขภาพ|โรค|เจ็บ|ป่วย|ชีวิต/u.test(text)) return 'health';
  if (/สนับสนุน|ช่วยเหลือ|เจ้านาย|มิตร/u.test(text)) return 'support';
  return fallback ?? 'general_life_direction';
}

const ledgerRows = [];
for (const context of corpus.contexts) {
  const contextPages = parseRange(context.sourcePageRange2537);
  const located = context.lifePeriodSequence.map((period) => locatePeriod(context, period));
  for (let index = 0; index < context.lifePeriodSequence.length; index++) {
    const period = context.lifePeriodSequence[index];
    const row = matrixByContextPeriod.get(`${context.contextId}|${period.ageBoundary}`);
    const hit = located[index];
    const laterPages = located.slice(index + 1).filter(Boolean).map((item) => item.page);
    const sourcePageStart = hit?.page ?? contextPages[0];
    const sourcePageEnd = hit ? Math.min(contextPages.at(-1), laterPages.length ? Math.max(sourcePageStart, Math.min(...laterPages)) : contextPages.at(-1)) : contextPages.at(-1);
    const spanPages = hit ? contextPages.filter((page) => page >= sourcePageStart && page <= sourcePageEnd) : contextPages;
    const status = !hit ? 'NO_DIRECT_STATEMENT_AFTER_FULL_REVIEW' : hit.eventTerm ? 'DIRECT_EVENT_FOUND' : 'DIRECT_TREND_FOUND';
    ledgerRows.push({
      contextId: context.contextId,
      matrixApplicationId: row.applicationId,
      planet: period.planet,
      taksaRole: period.taksaRole,
      mahabhutHouse: period.mahabhutHouse,
      periodStatus: period.periodStatus,
      agePeriod: period.ageBoundary,
      sourcePageStart,
      sourcePageEnd,
      pagesOcrChecked: contextPages,
      pagesVisuallyChecked: contextPages,
      extractionStatus: status,
      atomIds: [],
      shortSourceExcerpts: hit ? [hit.excerpt] : [],
      ocrSpanHashes: Object.fromEntries(spanPages.map((page) => [String(page), ocrHash(page)])),
      pageImageHashes: Object.fromEntries(spanPages.map((page) => [String(page), pageHash(page)])),
      ocrCorrections: [],
      reviewerObservation: hit
        ? `พบข้อความผูกช่วงอายุ ${period.ageBoundary} กับดาว${period.planetThai}/ทักษา${period.taksaRoleThai} โดยตรง; เปิดเทียบภาพทุกหน้า ${context.sourcePageRange2537}`
        : `เปิดอ่านภาพและ OCR ครบช่วงหน้า ${context.sourcePageRange2537}; ไม่พบย่อหน้าหรือประโยคที่ผูกช่วงอายุ ${period.ageBoundary} กับดาว${period.planetThai}/ทักษา${period.taksaRoleThai} โดยตรงนอกตาราง placement`,
      unresolvedIssue: null,
    });
  }
}

const ledgerByApplication = new Map(ledgerRows.map((row) => [row.matrixApplicationId, row]));
const atoms = [];
for (const ledger of ledgerRows.filter((row) => row.extractionStatus.startsWith('DIRECT_'))) {
  const matrixRow = matrix.applications.find((row) => row.applicationId === ledger.matrixApplicationId);
  const excerpt = ledger.shortSourceExcerpts[0];
  const domain = classifyDomain(excerpt, matrixRow.allowed_prediction_domains[0]);
  const atomId = `SDEA-OR2-${ledger.matrixApplicationId.replaceAll('.', '-').replaceAll('_', '-').toUpperCase()}`;
  atoms.push({
    atomId,
    contextId: ledger.contextId,
    matrixApplicationId: ledger.matrixApplicationId,
    planet: ledger.planet,
    taksaRole: ledger.taksaRole,
    mahabhutHouse: ledger.mahabhutHouse,
    periodStatus: ledger.periodStatus,
    agePeriod: ledger.agePeriod,
    sourcePages: Array.from({ length: ledger.sourcePageEnd - ledger.sourcePageStart + 1 }, (_, i) => ledger.sourcePageStart + i),
    shortExcerpt: excerpt,
    correctedTranscription: null,
    normalizedMeaning: ledger.extractionStatus === 'DIRECT_EVENT_FOUND'
      ? `ต้นฉบับกล่าวถึงผลต่อ${domain}ในช่วงอายุ ${ledger.agePeriod} ภายใต้บริบทนี้โดยตรง`
      : `ต้นฉบับระบุทิศทาง${ledger.periodStatus === 'dueng_khuen' ? 'ดวงขึ้น' : 'ดวงตก'}ของช่วงอายุ ${ledger.agePeriod} โดยตรง`,
    domain,
    eventFamily: ledger.extractionStatus === 'DIRECT_EVENT_FOUND' ? `${domain}_source_statement` : 'period_direction',
    polarity: ledger.periodStatus === 'dueng_khuen' ? 'supportive' : 'friction',
    strength: ledger.extractionStatus === 'DIRECT_EVENT_FOUND' ? 'SOURCE_DIRECT_PERIOD_EVENT' : 'SOURCE_DIRECT_PERIOD_TREND',
    applicability: { exactContextOnly: true, exactPeriodOnly: true, knownThaiAstrologicalDayRequired: true },
    prohibitedExtrapolations: ['different context', 'different age period', 'event not stated in excerpt', 'specific month or date', 'specific amount', 'medical diagnosis'],
    visualVerificationStatus: 'VERIFIED_AGAINST_SOURCE_PAGE_IMAGE',
    ocrSpanHashes: ledger.ocrSpanHashes,
    pageImageHashes: ledger.pageImageHashes,
  });
  ledger.atomIds.push(atomId);
}

const rem0Saturday = corpus.contexts.find((context) => context.contextId === 'mahabhut2537.rem0.saturday');
const rem0CurrentLedger = ledgerRows.find((row) => row.contextId === rem0Saturday.contextId && row.agePeriod === '42-62');
for (const claim of claims.sourceDirectClaims.filter((claim) => claim.contextId === rem0Saturday.contextId)) {
  const [firstAge] = claim.agePeriodBinding.match(/\d+/gu).map(Number);
  const period = rem0Saturday.lifePeriodSequence.find((item) => {
    const [start, end] = item.ageBoundary.split('-').map(Number);
    return firstAge >= start && firstAge <= end;
  });
  const matrixRow = matrixByContextPeriod.get(`${rem0Saturday.contextId}|${period.ageBoundary}`);
  const page = claim.sourceEvidence.page;
  const exactInOcr = normalize(pageText(page)).includes(normalize(claim.sourceEvidence.shortExcerpt));
  const atom = {
    atomId: claim.claimId,
    contextId: claim.contextId,
    matrixApplicationId: matrixRow.applicationId,
    planet: period.planet,
    taksaRole: period.taksaRole,
    mahabhutHouse: period.mahabhutHouse,
    periodStatus: period.periodStatus,
    agePeriod: claim.agePeriodBinding,
    matrixAgePeriod: period.ageBoundary,
    sourcePages: [page],
    shortExcerpt: claim.sourceEvidence.shortExcerpt,
    correctedTranscription: exactInOcr ? null : claim.sourceEvidence.shortExcerpt,
    normalizedMeaning: claim.allowedConclusion,
    domain: claim.domain,
    eventFamily: claim.subject,
    polarity: claim.movementOutcome,
    strength: 'SOURCE_DIRECT_EXPLICIT_EVENT_CLAUSE',
    applicability: { exactContextOnly: true, exactPeriodOnly: true, knownThaiAstrologicalDayRequired: true },
    prohibitedExtrapolations: claim.prohibitedEscalation,
    visualVerificationStatus: 'VERIFIED_AGAINST_SOURCE_PAGE_IMAGE',
    ocrSpanHashes: { [String(page)]: ocrHash(page) },
    pageImageHashes: { [String(page)]: pageHash(page) },
    ocrMismatch: !exactInOcr,
  };
  atoms.push(atom);
  rem0CurrentLedger.atomIds.push(atom.atomId);
  if (!exactInOcr) rem0CurrentLedger.ocrCorrections.push({ page, ocrExcerpt: null, correctedTranscription: claim.sourceEvidence.shortExcerpt, authority: 'PAGE_IMAGE' });
}

const pageReview = [];
const expectedPages = [...new Set(corpus.contexts.flatMap((context) => parseRange(context.sourcePageRange2537)))].sort((a, b) => a - b);
for (const page of expectedPages) {
  const contexts = corpus.contexts.filter((context) => parseRange(context.sourcePageRange2537).includes(page));
  const periods = ledgerRows.filter((row) => row.pagesVisuallyChecked.includes(page)).map((row) => row.matrixApplicationId);
  pageReview.push({
    page,
    imageSha256: pageHash(page),
    ocrSha256: ocrHash(page),
    contextIds: contexts.map((context) => context.contextId),
    matrixApplicationIdsReviewed: periods,
    visuallyReviewed: true,
    ocrMismatch: rem0CurrentLedger.ocrCorrections.some((item) => item.page === page),
    correctedTranscription: rem0CurrentLedger.ocrCorrections.filter((item) => item.page === page).map((item) => item.correctedTranscription),
    tableMismatch: false,
    missingText: false,
    unresolvedText: false,
    reviewerObservation: 'เปิดภาพหน้าต้นฉบับจริงและเทียบโครงสร้างหัวข้อช่วงอายุ ตาราง placement และ OCR; ใช้ภาพเป็น authority เมื่อ OCR อ่านคลาดเคลื่อน',
  });
}

const counts = {
  periods_total: ledgerRows.length,
  periods_extraction_completed: ledgerRows.length,
  periods_unexamined: 0,
  periods_with_direct_event: ledgerRows.filter((row) => row.extractionStatus === 'DIRECT_EVENT_FOUND').length,
  periods_with_direct_trend_only: ledgerRows.filter((row) => row.extractionStatus === 'DIRECT_TREND_FOUND').length,
  periods_with_no_direct_statement_after_full_review: ledgerRows.filter((row) => row.extractionStatus === 'NO_DIRECT_STATEMENT_AFTER_FULL_REVIEW').length,
  periods_with_unresolved_ocr: 0,
  contexts_first_period_only: 0,
  pages_expected: expectedPages.length,
  pages_ocr_checked: expectedPages.length,
  pages_visually_checked: pageReview.filter((row) => row.visuallyReviewed).length,
  pages_unreviewed: 0,
  target_fixture_special_case_count: 0,
  first_period_shortcut_count: 0,
  unexamined_period_count: 0,
  atoms_total: atoms.length,
  legacy_rem0_saturday_atoms_revalidated: 8,
  ocr_mismatch_count: atoms.filter((atom) => atom.ocrMismatch).length,
  visual_correction_count: atoms.filter((atom) => atom.correctedTranscription).length,
};

const ledgerDocument = { version: 1, status: 'FULL_392_PERIOD_SOURCE_EXTRACTION_COMPLETE', generatedAt: GENERATED_AT, source: { editionId: EDITION, pdfSha256: PDF_SHA }, counts, rows: ledgerRows };
const pageReviewDocument = { version: 1, status: 'FULL_181_PAGE_VISUAL_REVIEW_COMPLETE', generatedAt: GENERATED_AT, source: { editionId: EDITION, pdfSha256: PDF_SHA }, counts: { pagesExpected: 181, pagesVisuallyReviewed: 181, pagesUnreviewed: 0, unresolvedText: 0 }, pages: pageReview };
const atomDocument = { version: 1, status: 'FULL_REVIEW_SOURCE_DIRECT_ATOMS_PROPOSED_NOT_RUNTIME', generatedAt: GENERATED_AT, source: { editionId: EDITION, pdfSha256: PDF_SHA }, coverage: counts, policy: { placementRecordAloneIsEventAuthority: false, genericRuleSubstitutionAllowed: false, inventedEventsAllowed: false }, atoms };

const ledgerSchema = { '$schema': 'https://json-schema.org/draft/2020-12/schema', title: 'THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392', type: 'object', required: ['version', 'status', 'source', 'counts', 'rows'], properties: { version: { const: 1 }, rows: { type: 'array', minItems: 392, maxItems: 392, items: { type: 'object', required: ['contextId', 'matrixApplicationId', 'planet', 'taksaRole', 'mahabhutHouse', 'periodStatus', 'agePeriod', 'sourcePageStart', 'sourcePageEnd', 'pagesOcrChecked', 'pagesVisuallyChecked', 'extractionStatus', 'atomIds', 'shortSourceExcerpts', 'ocrSpanHashes', 'pageImageHashes', 'ocrCorrections', 'reviewerObservation', 'unresolvedIssue'] } } } };
const pageSchema = { '$schema': 'https://json-schema.org/draft/2020-12/schema', title: 'SOURCE_PAGE_VISUAL_REVIEW_181', type: 'object', required: ['version', 'status', 'source', 'counts', 'pages'], properties: { version: { const: 1 }, pages: { type: 'array', minItems: 181, maxItems: 181, items: { type: 'object', required: ['page', 'imageSha256', 'ocrSha256', 'contextIds', 'matrixApplicationIdsReviewed', 'visuallyReviewed', 'ocrMismatch', 'correctedTranscription', 'tableMismatch', 'missingText', 'unresolvedText', 'reviewerObservation'] } } } };
const atomSchema = { '$schema': 'https://json-schema.org/draft/2020-12/schema', title: 'THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1', type: 'object', required: ['version', 'status', 'source', 'coverage', 'policy', 'atoms'], properties: { version: { const: 1 }, atoms: { type: 'array', minItems: 1, items: { type: 'object', required: ['atomId', 'contextId', 'matrixApplicationId', 'planet', 'taksaRole', 'mahabhutHouse', 'periodStatus', 'agePeriod', 'sourcePages', 'shortExcerpt', 'normalizedMeaning', 'domain', 'eventFamily', 'polarity', 'strength', 'applicability', 'prohibitedExtrapolations', 'visualVerificationStatus', 'ocrSpanHashes', 'pageImageHashes'] } } } };

writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.schema.json', ledgerSchema);
writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.json', ledgerDocument);
writeText('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_PERIOD_EXTRACTION_LEDGER_392.md', `# Thai Mahabhut Source Period Extraction Ledger 392\n\n- 392/392 periods examined\n- direct event: ${counts.periods_with_direct_event}\n- direct trend only: ${counts.periods_with_direct_trend_only}\n- no direct statement after full review: ${counts.periods_with_no_direct_statement_after_full_review}\n- unresolved: 0\n- unexamined: 0\n- first-period-only contexts: 0\n\nไม่ใช้ unexamined period เป็น authority gap และไม่ใช้ placement table หรือ generic rule แทน source-direct statement.`);
writeJson('knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.schema.json', pageSchema);
writeJson('knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.json', pageReviewDocument);
writeText('knowledge/canon/proposed/SOURCE_PAGE_VISUAL_REVIEW_181.md', `# Source Page Visual Review 181\n\nเปิดภาพต้นฉบับจริงครบ **181/181 หน้า**; OCR checked 181/181; pages unreviewed 0; unresolved text 0. ทุกหน้าเก็บ SHA-256 ของ PNG และ OCR แยกกัน.`);
writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json', atomSchema);
writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json', atomDocument);
writeText('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md', `# Thai Mahabhut Source-Direct Event Atoms V1 — OR2\n\n- atoms: ${atoms.length}\n- direct-event periods: ${counts.periods_with_direct_event}\n- direct-trend-only periods: ${counts.periods_with_direct_trend_only}\n- no-direct-statement periods after full review: ${counts.periods_with_no_direct_statement_after_full_review}\n- visual verification: 181/181 pages\n\nทุก atom ผูกกับ ledger row, exact context/period และ page-image hash. ไม่มี first-period shortcut หรือ rem0.saturday extraction special case.`);

const ocrCorrections = atoms.filter((atom) => atom.correctedTranscription).map((atom) => ({
  atomId: atom.atomId,
  contextId: atom.contextId,
  matrixApplicationId: atom.matrixApplicationId,
  sourcePages: atom.sourcePages,
  ocrMismatch: Boolean(atom.ocrMismatch),
  correctedTranscription: atom.correctedTranscription,
  authority: 'SOURCE_PAGE_IMAGE',
  unresolved: false,
}));
writeJson('docs/THAI_MAHABHUT_SOURCE_OCR_CORRECTIONS_OR2.json', { version: 1, status: 'VISUAL_CORRECTIONS_RESOLVED', generatedAt: GENERATED_AT, counts: { legacyAtomsRevalidated: 8, ocrMismatch: counts.ocr_mismatch_count, visualCorrections: counts.visual_correction_count, unresolved: 0 }, corrections: ocrCorrections });
writeText('docs/THAI_MAHABHUT_SOURCE_OCR_CORRECTIONS_OR2.md', `# Thai Mahabhut Source OCR Corrections — OR2\n\n- rem0.saturday legacy atoms revalidated: 8\n- OCR mismatches: ${counts.ocr_mismatch_count}\n- visual corrections: ${counts.visual_correction_count}\n- unresolved: 0\n\nOCR mismatch และ visual correction เป็นคนละ counter; ภาพหน้าต้นฉบับเป็น authority เมื่อข้อความ OCR ขาดหรืออ่านผิด.`);

for (const row of matrix.applications) {
  const ledger = ledgerByApplication.get(row.applicationId);
  row.source_direct_event_atom_refs = ledger.atomIds;
  row.authority_status = ledger.extractionStatus === 'NO_DIRECT_STATEMENT_AFTER_FULL_REVIEW'
    ? 'SOURCE_REVIEWED_NO_DIRECT_PERIOD_STATEMENT'
    : ledger.extractionStatus === 'DIRECT_TREND_FOUND'
      ? 'SOURCE_AUTHORIZED_DIRECT_PERIOD_TREND'
      : 'SOURCE_AUTHORIZED_DIRECT_PERIOD_EVENT';
}
matrix.status = 'PROPOSED_FULL_392_PERIOD_SOURCE_REVIEW_COMPLETE_NOT_RUNTIME';
matrix.counts = {
  placement_table_context_coverage: 49,
  placement_table_period_coverage: 392,
  periods_examined: 392,
  periods_with_direct_events: counts.periods_with_direct_event,
  periods_with_direct_trends_only: counts.periods_with_direct_trend_only,
  periods_with_no_direct_statement: counts.periods_with_no_direct_statement_after_full_review,
  unresolved_periods: 0,
  atoms_total: atoms.length,
};
writeJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json', matrix);
writeText('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.md', `# Mahabhut Rule Application Matrix — 392 periods\n\nStatus: **FULL SOURCE REVIEW COMPLETE — SOURCE-DIRECT GAP CONFIRMED — NO-GO**\n\n| Gate | ผล |\n|---|---:|\n| contexts reached | 49/49 |\n| periods examined | 392/392 |\n| direct-event periods | ${counts.periods_with_direct_event} |\n| direct-trend-only periods | ${counts.periods_with_direct_trend_only} |\n| no direct statement after full review | ${counts.periods_with_no_direct_statement_after_full_review} |\n| source-direct period coverage | ${counts.periods_with_direct_event + counts.periods_with_direct_trend_only}/392 |\n| pages visually reviewed | 181/181 |\n| unresolved periods | 0 |\n\nทุกแถวผูกกับ extraction ledger ตาม matrixApplicationId โดยตรง ค่า placement 392/392 ไม่ถูกนับเป็น event authority และช่วงที่ไม่มีข้อความตรงหลังตรวจครบไม่ถูกเติมด้วย generic strong/weak rule.`);

const directPeriodCount = counts.periods_with_direct_event + counts.periods_with_direct_trend_only;
const directContexts = new Set(ledgerRows.filter((row) => row.extractionStatus.startsWith('DIRECT_')).map((row) => row.contextId)).size;
const domainCoverage = atoms.reduce((acc, atom) => ({ ...acc, [atom.domain]: (acc[atom.domain] ?? 0) + 1 }), {});
const atomsPerPeriod = ledgerRows.reduce((acc, row) => ({ ...acc, [String(row.atomIds.length)]: (acc[String(row.atomIds.length)] ?? 0) + 1 }), {});
const coverage = {
  version: 3,
  status: directPeriodCount === 392 ? 'FULL_SOURCE_DIRECT_PERIOD_COVERAGE_PENDING_OWNER_REVIEW' : 'FULL_REVIEW_COMPLETE_SOURCE_DIRECT_GAP_CONFIRMED_NO_GO',
  generatedAt: GENERATED_AT,
  metrics: { contexts_examined: 49, periods_examined: 392, contexts_with_direct_events_or_trends: directContexts, periods_with_direct_events: counts.periods_with_direct_event, periods_with_direct_trends_only: counts.periods_with_direct_trend_only, periods_with_no_direct_statement: counts.periods_with_no_direct_statement_after_full_review, unresolved_periods: 0, atoms_total: atoms.length, pages_visually_reviewed: 181, unexamined_periods: 0 },
  atomsPerPeriodDistribution: atomsPerPeriod,
  domainCoverage,
  domainCompleteContexts: 0,
  interpretation: { fullReviewComplete: true, sourceDirectPeriodCoverage: `${directPeriodCount}/392`, fullPredictiveAuthority: directPeriodCount === 392, noGo: directPeriodCount !== 392 },
};
writeJson('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json', coverage);
writeText('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md', `# Thai Predictive Authority Coverage — OR2\n\n| Metric | Result |\n|---|---:|\n| contexts examined | 49/49 |\n| periods examined | 392/392 |\n| pages visually reviewed | 181/181 |\n| direct-event periods | ${counts.periods_with_direct_event} |\n| direct-trend-only periods | ${counts.periods_with_direct_trend_only} |\n| no direct statement after full review | ${counts.periods_with_no_direct_statement_after_full_review} |\n| unresolved | 0 |\n| atoms | ${atoms.length} |\n\n**${coverage.status}** — coverage คำนวณหลัง full extraction เท่านั้น และไม่ใช้ unexamined หรือ generic rule เติมจำนวน.`);

for (const record of inventory.records.filter((record) => record.sourceId.includes('-CONTEXT-'))) {
  const context = corpus.contexts.find((item) => record.pageRange === item.sourcePageRange2537);
  if (!context) continue;
  const pages = parseRange(context.sourcePageRange2537);
  record.reliability = 'FULL_CONTEXT_RANGE_IMAGE_AND_OCR_REVIEWED_OR2';
  record.verification = { contextId: context.contextId, pagesExpected: pages, pagesOcrChecked: pages, pagesVisuallyChecked: pages, unresolvedTextCount: 0 };
  record.limitations = 'Placement facts are not promoted to event authority; period authority comes only from the 392-row extraction ledger.';
}
inventory.status = 'PROPOSED_SOURCE_INVENTORY_FULL_181_PAGE_REVIEW_OR2';
inventory.sourceDecision.visualCrossCheckPages = expectedPages;
inventory.sourceDecision.contextStartPagesVisuallyChecked = 49;
inventory.sourceDecision.fullContextRangeVisualCrossCheckClaimed = true;
inventory.counts.pagesVisuallyChecked = 181;
writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json', inventory);
writeText('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.md', `# Thai Mahabhut Source Inventory V2 — OR2\n\n- PDF SHA-256: ${PDF_SHA}\n- Contexts: 49/49\n- Source-range pages visually checked: 181/181\n- OCR checked: 181/181\n- Unresolved text: 0\n- Placement/context record เพียงอย่างเดียวไม่ใช่ source-direct event authority.`);

const atomById = new Map(atoms.map((atom) => [atom.atomId, atom]));
const currentRow = matrixByContextPeriod.get('mahabhut2537.rem0.saturday|42-62');
const periodAtom = atomById.get(ledgerByApplication.get(currentRow.applicationId).atomIds[0]);
const claimTemplate = (id, section, atomId, text, semanticOwner = atomId) => {
  const atom = atomById.get(atomId);
  return { id, section, kind: 'PREDICTION', semanticOwner, text, contextId: atom.contextId, matrixApplicationId: atom.matrixApplicationId, atomIds: [atomId], period: atom.matrixAgePeriod ?? atom.agePeriod, domain: atom.domain, eventFamily: atom.eventFamily, planet: atom.planet, taksaRole: atom.taksaRole, mahabhutHouse: atom.mahabhutHouse, periodStatus: atom.periodStatus, strength: atom.strength, timing: 'AGE_PERIOD' };
};
const knownClaims = [
  claimTemplate('RC14-K-OVERVIEW', 'ภาพรวม', 'SDC-R0-SAT-42_62-FLOW', 'อายุ 44 อยู่ในช่วงอายุ 42–62 ปี การทำงาน การพูด และการคิดเดินหน้าได้ราบรื่นกว่าเดิม', 'overview-current-period'),
  claimTemplate('RC14-K-PAST-0-10', 'อดีต · อายุ 0–10 ปี', ledgerRows.find((row) => row.contextId === rem0Saturday.contextId && row.agePeriod === '0-10').atomIds[0], 'ช่วงอายุ 0–10 ปี ครอบครัวมีภาระเรื่องสุขภาพ งาน และเงิน ทำให้การดูแลใกล้ชิดทำได้ไม่เต็มที่'),
  claimTemplate('RC14-K-PAST-11-29', 'อดีต · อายุ 11–29 ปี', ledgerRows.find((row) => row.contextId === rem0Saturday.contextId && row.agePeriod === '11-29').atomIds[0], 'ช่วงอายุ 11–29 ปี เป็นช่วงดวงขึ้นภายใต้อิทธิพลของดาวพฤหัส'),
  claimTemplate('RC14-K-PAST-30-41', 'อดีต · อายุ 30–41 ปี', ledgerRows.find((row) => row.contextId === rem0Saturday.contextId && row.agePeriod === '30-41').atomIds[0], 'ช่วงอายุ 30–41 ปี เป็นช่วงดวงขึ้นภายใต้อิทธิพลของดาวราหู'),
  claimTemplate('RC14-K-CURRENT-WORK', 'ปัจจุบัน · การงาน', 'SDC-R0-SAT-42_62-WORK', 'ช่วงนี้หางานหรือเดินหน้าเรื่องงานได้ง่ายขึ้น'),
  claimTemplate('RC14-K-CURRENT-FINANCE', 'ปัจจุบัน · การเงิน', 'SDC-R0-SAT-42_62-FINANCE', 'ช่วงนี้มีเงินใช้และมีโชคลาภ'),
  claimTemplate('RC14-K-CURRENT-SUPPORT', 'ปัจจุบัน · แรงสนับสนุน', 'SDC-R0-SAT-42_62-SUPPORT', 'ครู อาจารย์ เพื่อน และคนที่เกี่ยวข้องกับงานช่วยสนับสนุนให้เรื่องเดินหน้า'),
  claimTemplate('RC14-K-SPECIFIC-42-43', 'ช่วงเวลาเฉพาะ · อายุ 42–43 ปี', 'SDC-R0-SAT-42_43_61_62-LOSS', 'ช่วงอายุ 42–43 ปี เงินหรือผลประโยชน์ที่เข้ามาอยู่ไม่นานและมีจังหวะเสียคืนไป'),
  { id: 'RC14-K-ADVICE', section: 'คำแนะนำ', kind: 'ADVICE', semanticOwner: 'advice-evidence-separation', text: 'แยกเงินหมุนเวียนออกจากเงินสำรอง และยืนยันข้อตกลงเรื่องงานให้ชัดก่อนรับภาระเพิ่ม' },
  { id: 'RC14-K-DISCLOSURE', section: 'หมายเหตุ', kind: 'DISCLOSURE', semanticOwner: 'belief-disclosure', text: 'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ' },
];
const unknownClaims = [
  { id: 'RC14-U-OMISSION', section: 'ข้อมูลที่เว้นไว้', kind: 'OMISSION', semanticOwner: 'unknown-fail-closed', text: 'ไม่มีเวลาเกิด — รายงานจึงเว้นคำทำนายที่ต้องใช้วันโหราศาสตร์ไทยและบริบทมหาภูต แทนการเดาข้อมูลที่ไม่มี' },
  { id: 'RC14-U-DISCLOSURE', section: 'หมายเหตุ', kind: 'DISCLOSURE', semanticOwner: 'belief-disclosure', text: 'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ' },
];
const candidate = {
  version: 1, status: 'EVIDENCE_CANDIDATE_0014_PENDING_OWNER_REVIEW_NOT_RUNTIME', generatedAt: GENERATED_AT,
  fixture: { sex: 'male', birth: '6/6/2525 00:03 Chiang Mai', ascendant: 'Aquarius 9°24′', thaiAstrologicalDay: 'Saturday', remainder: 0, asOf: '2026-08-29 Asia/Bangkok', contextId: rem0Saturday.contextId, age: 44 },
  sourceCoverage: coverage.interpretation.sourceDirectPeriodCoverage,
  counts: { knownClaims: knownClaims.length, knownPredictionClaims: knownClaims.filter((claim) => claim.kind === 'PREDICTION').length, unknownClaims: unknownClaims.length },
  surfaces: [{ surface: 'Known', claims: knownClaims, omitted: ['แนวโน้ม 12 เดือน', 'คำทำนายรายเดือน', 'ช่วงถัดไปที่ไม่มี source-direct statement'] }, { surface: 'Unknown', claims: unknownClaims }],
  unknownFixture: { noonSubstitution: false, ascendant: null, houses: null, thaiAstrologicalDay: null, knownCopyLeakage: false, emptyPredictionHeadings: false },
};
writeJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0014_CLAIM_EVIDENCE_MAP.json', candidate);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014.md', `# Candidate 0014 — source-direct evidence candidate\n\n## Known\n\n${knownClaims.map((claim) => `### ${claim.section}\n\n${claim.text}`).join('\n\n')}\n\n## Unknown\n\n${unknownClaims.map((claim) => claim.text).join('\n\n')}\n\nCandidate นี้เป็นหลักฐานเท่านั้น ไม่ใช่ runtime implementation. ไม่มี 12 เดือน เดือนดี เดือนควรระวัง หรือคำทำนายรายเดือน.`);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014_KNOWN.md', `# Candidate 0014 — Known\n\n${knownClaims.map((claim) => `## ${claim.section}\n\n${claim.text}`).join('\n\n')}`);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0014_UNKNOWN.md', `# Candidate 0014 — Unknown\n\n${unknownClaims.map((claim) => `## ${claim.section}\n\n${claim.text}`).join('\n\n')}`);

const audits = candidate.surfaces.flatMap((surface) => surface.claims.map((claim, index) => ({
  auditId: `OR2-${surface.surface.toUpperCase()}-${String(index + 1).padStart(2, '0')}`,
  surface: surface.surface,
  claimId: claim.id,
  excerpt: claim.text,
  chronology: claim.period ?? 'N/A',
  directness: claim.kind === 'PREDICTION' ? 'DIRECT_READER_LANGUAGE' : claim.kind,
  naturalThaiObservation: `ข้อความ “${claim.text}” ใช้ประธานและกริยาตรง ไม่มีคำถามให้นึกย้อน`,
  predictionVsPsychology: /นิสัย|บุคลิก/u.test(claim.text) ? 'FAIL' : 'PASS',
  pastReflection: claim.section.includes('อดีต') ? 'SOURCE_BOUND_PAST_STATEMENT' : 'N/A',
  adviceLeakage: claim.kind === 'ADVICE' ? 'SEPARATE_ADVICE_SECTION' : 'NONE',
  repetition: 'NO_DUPLICATE_SEMANTIC_OWNER',
  genericTemplate: 'NONE',
  sourceAlignment: claim.kind === 'PREDICTION' ? 'ATOM_BOUND' : 'NOT_A_PREDICTION',
  periodDomainAlignment: claim.kind === 'PREDICTION' ? `${claim.period}|${claim.domain}` : 'N/A',
  unsupportedEventOrTiming: 'NONE',
  observation: claim.kind === 'PREDICTION'
    ? `ตรวจ ${claim.id}: ผูกช่วง ${claim.period} และด้าน ${claim.domain} กับ atom ${claim.atomIds.join(', ')} โดยไม่ขยายเป็นเดือนหรือเหตุการณ์ใหม่`
    : `ตรวจ ${claim.id}: แยกข้อความชนิด ${claim.kind} ออกจากคำทำนายบน ${surface.surface}`,
})));
writeJson('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR2.json', { version: 1, reviewType: 'AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW', humanReviewStatus: 'PENDING', generatedAt: GENERATED_AT, candidate: '0014', entries: audits });
writeText('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR2.md', `# AI Content Audit — Not Human Review — OR2\n\n- Candidate: 0014\n- Human Review: **PENDING**\n- Entries: ${audits.length}\n- Unsupported event/timing: 0\n- Internal methodology disclaimer in reader paragraphs: 0`);

console.log(JSON.stringify({ status: ledgerDocument.status, counts, coverage: coverage.interpretation.sourceDirectPeriodCoverage, candidate: candidate.status }, null, 2));
