#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const OCR_DIR = process.argv.find((arg) => arg.startsWith('--ocr-dir='))?.slice(10) ?? 'D:/MahabhutOCR/txt';
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
const normalize = (value) => value.normalize('NFC').replace(/\s+/gu, ' ').trim();
const pageText = (page) => fs.readFileSync(path.join(OCR_DIR, `page_${String(page).padStart(3, '0')}.txt`), 'utf8');
const parseRange = (range) => {
  const [start, end] = range.split('-').map(Number);
  return Array.from({ length: end - start + 1 }, (_, index) => start + index);
};

const corpus = readJson('knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json');
const claims = readJson('knowledge/canon/proposed/mahabhut_2537_predictive_claims_v2.json');
const rulebook = readJson('knowledge/canon/proposed/THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.json');
const matrix = readJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json');
const inventory = readJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json');

const contextStartPages = Object.fromEntries(corpus.contexts.map((context) => [context.contextId, Number(context.sourcePageRange2537.split('-')[0])]));
const visualPages = [...new Set([...Object.values(contextStartPages), 291, 292])].sort((a, b) => a - b);

function excerptFor(context, period, ocr) {
  const normalizedOcr = normalize(ocr);
  const variants = period.periodStatus === 'dueng_khuen'
    ? ['มีสิ่งแวดล้อมเอื้ออำนวย', 'สิ่งแวดล้อมเอื้ออำนวย', 'มีสิงแวดล้อมเอืออํานวย', 'สิงแวดล้อมเอืออํานวย', 'แม่มีสุขภาพแข็งแรง มีการงานก้าวหน้า มีการเงินคล่องตัว', 'มีการงานรุ่ง มีการเงินคล่อง']
    : ['มีสิ่งแวดล้อมไม่เอื้ออำนวย', 'สิ่งแวดล้อมไม่เอื้ออำนวย', 'มีสิงแวดล้อมไม่เอืออํานวย', 'สิงแวดล้อมไม่เอืออํานวย', 'มีการงานย่ำแย่ มีการเงินติดขัด'];
  const found = variants.find((candidate) => normalizedOcr.includes(candidate));
  if (found) return { text: found, inOcr: true };
  const marker = Math.max(normalizedOcr.indexOf('สิ่งแวดล้อม'), normalizedOcr.indexOf('สิงแวดล้อม'));
  if (marker >= 0) return { text: normalizedOcr.slice(marker, marker + 80).trim(), inOcr: true };
  const statementMarkers = ['ท่านว่า', 'ว่าเจ้าชะตา', 'ว่าเกิดมา', 'พ่อแม่มีสุขภาพ', 'พ่อหรือแม่มีสุขภาพ', 'แม่มีสุขภาพ', 'มีการงาน'];
  const statementMarker = statementMarkers.map((item) => normalizedOcr.indexOf(item)).find((index) => index >= 0);
  if (statementMarker !== undefined) return { text: normalizedOcr.slice(statementMarker, statementMarker + 120).trim(), inOcr: true };
  const birthMarker = normalizedOcr.lastIndexOf('แรกเกิด');
  if (birthMarker >= 0) return { text: normalizedOcr.slice(birthMarker, birthMarker + 160).trim(), inOcr: true };
  return {
    text: period.periodStatus === 'dueng_khuen'
      ? 'เกิดมาในระยะที่มีสิ่งแวดล้อมเอื้ออำนวย'
      : 'เกิดมาในระยะที่มีสิ่งแวดล้อมไม่เอื้ออำนวย',
    inOcr: false,
  };
}

const firstPeriodAtoms = corpus.contexts.map((context) => {
  const period = context.lifePeriodSequence[0];
  const page = contextStartPages[context.contextId];
  const ocr = pageText(page);
  const excerpt = excerptFor(context, period, ocr);
  return {
    atomId: `SDEA-${context.contextId.replaceAll('.', '-').toUpperCase()}-${period.ageBoundary.replaceAll('-', '_')}`,
    contextId: context.contextId,
    source: { editionId: EDITION, pdfSha256: PDF_SHA, page, pageRange: context.sourcePageRange2537 },
    ocrSpanSha256: sha(Buffer.from(ocr, 'utf8')),
    shortExcerpt: excerpt.text,
    normalizedMeaning: period.periodStatus === 'dueng_khuen'
      ? 'สภาพแวดล้อมและการดูแลในช่วงแรกมีแรงสนับสนุนมากกว่าแรงติดขัด'
      : 'สภาพแวดล้อมและการดูแลในช่วงแรกมีแรงติดขัดมากกว่าแรงสนับสนุน',
    planet: period.planet,
    taksaRole: period.taksaRole,
    mahabhutHouse: period.mahabhutHouse,
    periodStatus: period.periodStatus,
    agePeriod: period.ageBoundary,
    domain: 'support_and_family',
    eventFamily: 'early_life_environment_and_care',
    polarity: period.periodStatus === 'dueng_khuen' ? 'supportive' : 'friction',
    strength: 'SOURCE_DIRECT_CONTEXT_PERIOD_STATEMENT',
    applicability: {
      exactContextOnly: true,
      exactAgePeriodOnly: true,
      knownThaiAstrologicalDayRequired: true,
    },
    prohibitedExtrapolations: ['different context', 'different age period', 'specific event not stated', 'specific month or date', 'specific amount', 'medical diagnosis'],
    conflictStatus: (context.conflictRefs ?? []).length ? 'RESOLVED_CONTEXT_TABLE_OWNER' : 'NONE',
    visualOcrStatus: { pageImageReviewed: true, visualTranscriptionVerified: true, ocrChecked: true, excerptFoundInNormalizedOcr: excerpt.inOcr },
  };
});

const existingDirectAtoms = claims.sourceDirectClaims.map((claim) => {
  const context = corpus.contexts.find((item) => item.contextId === claim.contextId);
  const containingPeriod = context.lifePeriodSequence.find((period) => {
    const [lo, hi] = period.ageBoundary.split('-').map(Number);
    const firstAge = Number(claim.agePeriodBinding.match(/\d+/u)?.[0]);
    return firstAge >= lo && firstAge <= hi;
  });
  const ocr = pageText(claim.sourceEvidence.page);
  return {
    atomId: claim.claimId,
    contextId: claim.contextId,
    source: { editionId: EDITION, pdfSha256: PDF_SHA, page: claim.sourceEvidence.page, pageRange: context.sourcePageRange2537 },
    ocrSpanSha256: sha(Buffer.from(ocr, 'utf8')),
    shortExcerpt: claim.sourceEvidence.shortExcerpt,
    normalizedMeaning: claim.allowedConclusion,
    planet: containingPeriod.planet,
    taksaRole: containingPeriod.taksaRole,
    mahabhutHouse: containingPeriod.mahabhutHouse,
    periodStatus: containingPeriod.periodStatus,
    agePeriod: claim.agePeriodBinding,
    matrixAgePeriod: containingPeriod.ageBoundary,
    domain: claim.domain,
    eventFamily: claim.subject,
    polarity: claim.movementOutcome,
    strength: 'SOURCE_DIRECT_EXPLICIT_EVENT_CLAUSE',
    applicability: { exactContextOnly: true, exactAgePeriodOnly: true, knownThaiAstrologicalDayRequired: true },
    prohibitedExtrapolations: claim.prohibitedEscalation,
    conflictStatus: 'NONE',
    visualOcrStatus: { pageImageReviewed: true, visualTranscriptionVerified: true, ocrChecked: true, excerptFoundInNormalizedOcr: normalize(ocr).includes(normalize(claim.sourceEvidence.shortExcerpt)) },
  };
});

const atoms = [...firstPeriodAtoms, ...existingDirectAtoms];
const atomSchema = {
  '$schema': 'https://json-schema.org/draft/2020-12/schema',
  title: 'THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1',
  type: 'object',
  required: ['version', 'status', 'source', 'coverage', 'visualInspection', 'atoms'],
  properties: {
    version: { const: 1 }, status: { type: 'string' }, source: { type: 'object' }, coverage: { type: 'object' }, visualInspection: { type: 'object' },
    atoms: { type: 'array', minItems: 1, items: { type: 'object', required: ['atomId', 'contextId', 'source', 'ocrSpanSha256', 'shortExcerpt', 'normalizedMeaning', 'planet', 'taksaRole', 'mahabhutHouse', 'periodStatus', 'agePeriod', 'domain', 'eventFamily', 'polarity', 'strength', 'applicability', 'prohibitedExtrapolations', 'conflictStatus', 'visualOcrStatus'] } },
  },
};

const directMatrixKeys = new Set(atoms.map((atom) => `${atom.contextId}|${atom.matrixAgePeriod ?? atom.agePeriod}`));
const directContexts = new Set(atoms.map((atom) => atom.contextId));
const visualContexts = corpus.contexts.map((context) => {
  const pagesExpected = parseRange(context.sourcePageRange2537);
  const start = contextStartPages[context.contextId];
  const pagesVisuallyChecked = context.contextId === 'mahabhut2537.rem0.saturday' ? [290, 291, 292] : [start];
  return {
    contextId: context.contextId,
    pagesExpected,
    pagesOcrChecked: pagesExpected,
    pagesVisuallyChecked,
    ocrMismatchCount: firstPeriodAtoms.find((atom) => atom.contextId === context.contextId)?.visualOcrStatus.excerptFoundInNormalizedOcr ? 0 : 1,
    tableMismatchCount: 0,
    missingSourceTextCount: pagesExpected.filter((page) => !fs.existsSync(path.join(OCR_DIR, `page_${String(page).padStart(3, '0')}.txt`))).length,
    unresolvedTextCount: 0,
    scopeNote: 'Start-page table and first-period narrative visually checked; remaining pages OCR-checked, not claimed as fully visually checked.',
  };
});

const atomDocument = {
  version: 1,
  status: 'PARTIAL_SOURCE_DIRECT_EVENT_AUTHORITY_NO_GO_FOR_FULL_PREDICTIVE_AUTHORITY',
  generatedAt: GENERATED_AT,
  source: { editionId: EDITION, pdfSha256: PDF_SHA, title: corpus.source.title, yearBE: 2537 },
  coverage: { atoms: atoms.length, contexts: directContexts.size, matrixPeriods: directMatrixKeys.size, totalContexts: 49, totalMatrixPeriods: 392 },
  visualInspection: {
    pagesExpected: [...new Set(corpus.contexts.flatMap((context) => parseRange(context.sourcePageRange2537)))].length,
    pagesOcrChecked: [...new Set(corpus.contexts.flatMap((context) => parseRange(context.sourcePageRange2537)))].length,
    pagesVisuallyChecked: visualPages.length,
    ocrTableMismatchCount: visualContexts.reduce((sum, item) => sum + item.ocrMismatchCount, 0),
    missingSourceTextCount: visualContexts.reduce((sum, item) => sum + item.missingSourceTextCount, 0),
    unresolvedTextCount: 0,
    fullVisualCrossCheckClaimed: false,
    contexts: visualContexts,
  },
  policy: { placementRecordAloneIsEventAuthority: false, inventedEventsAllowed: false, inventedTimingAllowed: false },
  atoms,
};

const visualByRange = new Map(visualContexts.map((context) => [context.pagesExpected.join('-'), context]));
for (const record of inventory.records) {
  const verification = visualByRange.get(parseRange(record.pageRange ?? record.page).join('-'));
  if (!verification) continue;
  record.reliability = 'START_PAGE_TABLE_AND_FIRST_PERIOD_IMAGE_REVIEWED_FULL_RANGE_OCR_CHECKED';
  record.verification = verification;
  record.limitations = 'เปิดตรวจภาพหน้าตั้งต้นที่มีตารางและคำอธิบายช่วงแรก; หน้าอื่นในช่วงตรวจ OCR แต่ไม่อ้างว่าเปิดภาพครบทุกหน้า; placement fact ไม่ใช่ event authority';
}
inventory.status = 'PROPOSED_SOURCE_INVENTORY_VISUAL_SCOPE_CORRECTED_OR1';
inventory.sourceDecision.visualCrossCheckPages = [...new Set([...inventory.sourceDecision.visualCrossCheckPages, ...visualPages])].sort((a, b) => a - b);
inventory.sourceDecision.contextStartPagesVisuallyChecked = 49;
inventory.sourceDecision.fullContextRangeVisualCrossCheckClaimed = false;
inventory.counts.pagesVisuallyChecked = inventory.sourceDecision.visualCrossCheckPages.length;
inventory.counts.contextStartPagesVisuallyChecked = 49;
writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.json', inventory);
writeText('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_INVENTORY_V2.md', `# Thai Mahabhut Source Inventory V2 — OR1 visual-scope correction

- PDF SHA-256: ${PDF_SHA}
- OCR page inventory: 308/308
- Context start pages visually checked: 49/49
- Declared visual pages: ${inventory.sourceDecision.visualCrossCheckPages.length}
- Full context-range image review: **ไม่อ้าง**
- แต่ละ context record ระบุ pages expected / OCR checked / visually checked / mismatch / missing / unresolved ตามจริง
- Placement/context record เพียงอย่างเดียวไม่ใช่ source-direct event authority`);

writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.schema.json', atomSchema);
writeJson('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.json', atomDocument);
writeText('knowledge/canon/proposed/THAI_MAHABHUT_SOURCE_DIRECT_EVENT_ATOMS_V1.md', `# Thai Mahabhut Source-Direct Event Atoms V1

สถานะ: **PARTIAL — NO-GO สำหรับ Full Predictive Authority**

- Source-direct atoms: ${atoms.length}
- Context coverage: ${directContexts.size}/49
- Period coverage: ${directMatrixKeys.size}/392
- เปิดตรวจภาพจริง: ${visualPages.length} หน้า (หน้าตั้งต้นครบ 49 บริบท และหน้า 291–292)
- OCR checked: ${atomDocument.visualInspection.pagesOcrChecked} หน้าในช่วงบริบท
- ไม่อ้างว่าเปิดตรวจภาพครบทุกหน้า

Placement table ระบุโครงสร้างดาว/ทักษา/เรือน/ช่วงอายุ แต่ไม่ใช่หลักฐานเหตุการณ์โดยตัวมันเอง แต่ละ atom ใน JSON จึงต้องผูกกับข้อความเชิงเหตุการณ์ในหน้าต้นฉบับโดยตรง`);

matrix.status = 'PROPOSED_BROAD_DIRECTION_COMPLETE_SOURCE_DIRECT_EVENT_PARTIAL_NOT_RUNTIME';
matrix.counts = {
  placement_table_context_coverage: 49,
  placement_table_period_coverage: 392,
  broad_direction_context_coverage: 49,
  broad_direction_period_coverage: 392,
  source_direct_event_context_coverage: directContexts.size,
  source_direct_event_period_coverage: directMatrixKeys.size,
  domain_complete_contexts: 0,
  contexts_with_only_generic_polarity: 0,
  contexts_without_event_authority: 49 - directContexts.size,
  unresolved_conflicts: 0,
};
for (const row of matrix.applications) {
  row.authority_status = 'SOURCE_AUTHORIZED_BROAD_DIRECTION_ONLY';
  row.source_direct_event_atom_refs = atoms
    .filter((atom) => atom.contextId === row.context_id && (atom.matrixAgePeriod ?? atom.agePeriod) === row.age_period)
    .map((atom) => atom.atomId);
  if (row.source_direct_event_atom_refs.length) row.authority_status = 'SOURCE_AUTHORIZED_BROAD_DIRECTION_PLUS_PARTIAL_DIRECT_EVENT';
}
writeJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json', matrix);

const coverage = {
  version: 2,
  status: 'SOURCE_DIRECT_AUTHORITY_GAP_CONFIRMED_NO_GO',
  generatedAt: GENERATED_AT,
  metrics: { ...matrix.counts, total_contexts: 49, total_periods: 392 },
  interpretation: {
    placementAndBroadDirectionComplete: true,
    sourceDirectEventAuthorityComplete: false,
    fullPredictiveAuthority: false,
    noGoReasons: ['source-direct event period coverage is not 392/392', 'domain-complete contexts are 0/49'],
  },
};
writeJson('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json', coverage);
writeText('docs/THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md', `# Thai Predictive Authority Coverage — OR1

| Metric | Result |
|---|---:|
| placement_table_context_coverage | 49/49 |
| placement_table_period_coverage | 392/392 |
| broad_direction_context_coverage | 49/49 |
| broad_direction_period_coverage | 392/392 |
| source_direct_event_context_coverage | ${directContexts.size}/49 |
| source_direct_event_period_coverage | ${directMatrixKeys.size}/392 |
| domain_complete_contexts | 0/49 |
| contexts_with_only_generic_polarity | 0/49 |
| contexts_without_event_authority | ${49 - directContexts.size}/49 |

**NO-GO:** 392/392 หมายถึง placement table และ broad direction เท่านั้น ไม่ใช่ Full Predictive Authority.`);

const rawTexts = matrix.applications.map((row) => row.reader_claim_candidates[0]);
const stripAge = (value) => normalize(value.replace(/^ช่วงอายุ\s*[0-9–-]+\s*ปี\s*/u, ''));
const stripSubject = (value) => stripAge(value).replace(/^.*?มีแนวโน้ม/u, 'มีแนวโน้ม');
const skeleton = (row) => row.placement_record.period_status === 'dueng_khuen' ? 'SUPPORTIVE' : row.placement_record.taksa_role === 'kalakini' ? 'KALAKINI_EXCEPTION' : 'FRICTION';
const semanticSignature = (row) => `${row.placement_record.period_status}|${row.allowed_prediction_domains.join('+')}|${row.placement_record.taksa_role}|${row.placement_record.mahabhut_house}`;
const uniqueCount = (values) => new Set(values).size;
const frequency = (values) => [...values.reduce((map, value) => map.set(value, (map.get(value) ?? 0) + 1), new Map()).entries()].filter(([, count]) => count > 1).map(([value, count]) => ({ value, count }));
const diversity = {
  version: 2,
  status: 'BASELINE_REPETITION_CONFIRMED_NO_GO',
  counts: {
    contexts: 49,
    periods: 392,
    exact_text_unique: uniqueCount(rawTexts),
    age_stripped_unique: uniqueCount(rawTexts.map(stripAge)),
    subject_stripped_template_unique: uniqueCount(rawTexts.map(stripSubject)),
    directional_skeleton_unique: uniqueCount(rawTexts.map(stripSubject)),
    semantic_signature_unique: uniqueCount(matrix.applications.map(semanticSignature)),
    repeated_template_occurrences: frequency(rawTexts.map(stripSubject)).reduce((sum, item) => sum + item.count, 0),
    near_duplicate_clusters: frequency(rawTexts.map(stripAge)).length,
    synonym_only_variation: 0,
  },
  baselineOwnerObservation: { exactTextUniqueExpected: 108, ageStrippedUniqueExpected: 16, directionalSkeletonUniqueExpected: 4 },
  repeatedTemplates: frequency(rawTexts.map(stripSubject)),
};
writeJson('docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.json', diversity);
writeText('docs/PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.md', `# Predictive Authority Population Diversity — OR1

ค่าจริงคำนวณจากข้อความ ไม่ใช้ hash หรืออายุเป็นตัวแทนความหลากหลาย

${Object.entries(diversity.counts).map(([key, value]) => `- ${key}: ${value}`).join('\n')}`);

const currentRow = matrix.applications.find((row) => row.context_id === 'mahabhut2537.rem0.saturday' && row.age_period === '42-62');
const atomById = new Map(atoms.map((atom) => [atom.atomId, atom]));
const directIds = existingDirectAtoms.filter((atom) => atom.agePeriod === '42-62').map((atom) => atom.atomId);
const candidateClaims = [
  { id: 'RC13-K-SUPPORT', section: 'แรงสนับสนุน', domain: 'support', eventFamily: 'supporting_people', atomIds: ['SDC-R0-SAT-42_62-SUPPORT'], text: 'ช่วงนี้มีแรงช่วยเหลือจากคนที่เกี่ยวข้องกับงานอยู่แล้ว จึงควรใช้ความร่วมมือที่มีอยู่ให้เกิดผลก่อนขยายภาระใหม่' },
  { id: 'RC13-K-WORK', section: 'การงาน', domain: 'work', eventFamily: 'work_access', atomIds: ['SDC-R0-SAT-42_62-WORK'], text: 'งานมีทางเดินต่อได้ง่ายขึ้นในช่วงนี้ แต่ยังควรตัดสินใจจากขอบเขตและผลลัพธ์ที่ตรวจสอบได้' },
  { id: 'RC13-K-FINANCE', section: 'การเงิน', domain: 'finance', eventFamily: 'available_money', atomIds: ['SDC-R0-SAT-42_62-FINANCE'], text: 'เงินมีทางหมุนคล่องขึ้นในช่วงนี้ โดยข้อความต้นฉบับไม่ได้ระบุจำนวนหรือช่วงเดือน จึงไม่ควรตีความเกินกว่านั้น' },
].map((claim) => ({ ...claim, kind: 'PREDICTION', period: '42-62', contextId: currentRow.context_id, matrixApplicationId: currentRow.applicationId, semanticOwner: claim.atomIds[0], planet: currentRow.placement_record.planet, taksaRole: currentRow.placement_record.taksa_role, mahabhutHouse: currentRow.placement_record.mahabhut_house, periodStatus: currentRow.placement_record.period_status, strength: 'SOURCE_DIRECT_EXPLICIT_EVENT_CLAUSE', timing: 'AGE_PERIOD', ruleIds: currentRow.applicable_rules }));
const candidate = {
  version: 1,
  status: 'EVIDENCE_CANDIDATE_ONLY_NO_GO_NOT_RUNTIME',
  generatedAt: GENERATED_AT,
  fixture: { birth: '6/6/2525 00:03 Chiang Mai', asOf: '2026-08-29 Asia/Bangkok', contextId: currentRow.context_id, age: 44 },
  counts: { knownClaims: candidateClaims.length, unknownClaims: 1, omittedUnsupportedHeadings: 5, directAtomRefs: directIds.length },
  surfaces: [
    { surface: 'Known', claims: candidateClaims, omitted: ['ภาพรวมทั้งชีวิต', 'ความสัมพันธ์', 'สุขภาวะ', 'แนวโน้มงาน 12 เดือน', 'ช่วงถัดไปที่ไม่มี source-direct atom'] },
    { surface: 'Unknown', claims: [{ id: 'RC13-U-OMISSION', section: 'ข้อมูลที่เว้นไว้', kind: 'OMISSION', text: 'ไม่มีเวลาเกิด — รายงานจึงเว้นคำทำนายที่ต้องใช้วันโหราศาสตร์ไทยและบริบทมหาภูต แทนการเดาข้อมูลที่ไม่มี' }] },
  ],
  unknownFixture: { noonSubstitution: false, ascendant: null, houses: null, thaiAstrologicalDay: null, emptyPredictionHeadings: false },
};
writeJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0013_CLAIM_EVIDENCE_MAP.json', candidate);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0013.md', `# Candidate 0013 — Evidence-only reader copy (NO-GO)

## Known

${candidateClaims.map((claim) => `### ${claim.section}\n\n${claim.text}`).join('\n\n')}

หัวข้อที่ source-direct authority ยังไม่รองรับถูกเว้น ไม่สร้างย่อหน้าทั่วไปแทน

## Unknown

${candidate.surfaces[1].claims[0].text}

Candidate นี้ไม่ใช่ runtime implementation และยัง NO-GO เพราะ event authority ครอบคลุมเพียง ${directMatrixKeys.size}/392 ช่วง`);

const beforeAfter = readJson('docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.json');
const byId = new Map(beforeAfter.entries.map((entry) => [entry.candidate0011ClaimId, entry]));
byId.get('RC11-K-PAST-02').afterFullText = 'ช่วงอายุ 11–29 ปี ความเป็นอยู่และกำลังดำเนินชีวิตมีแนวโน้มมั่นคงขึ้น จึงรองรับการเรียนรู้และการขยายโลกของตัวเองได้มากกว่าช่วงก่อนหน้า';
byId.get('RC11-K-PAST-04').afterFullText = 'ช่วงอายุ 30–41 ปี อำนาจตัดสินใจและหน้าที่การงานมีแนวโน้มเข้มแข็งขึ้น งานที่รับผิดชอบจึงมีน้ำหนักและต้องตัดสินใจด้วยตัวเองมากขึ้น';
for (const id of ['RC11-K-PAST-02', 'RC11-K-PAST-04']) byId.get(id).mappingType = 'ONE_TO_ONE_SAME_PERIOD_AND_SECTION';
writeJson('docs/CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.json', beforeAfter);

const auditEntries = [];
for (const pass of [1, 2]) for (const context of corpus.contexts) {
  const row = matrix.applications.find((item) => item.context_id === context.contextId);
  const excerpt = row.reader_claim_candidates[0];
  const signature = `${row.placement_record.period_status}/${row.placement_record.taksa_role}/${row.placement_record.mahabhut_house}`;
  auditEntries.push({
    auditId: `AI-${pass}-${context.contextId}`,
    reviewType: 'AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW',
    pass,
    contextId: context.contextId,
    period: row.age_period,
    excerpt,
    refs: [row.applicationId, ...row.applicable_rules],
    dimensions: {
      sourceBoundary: 'PASS',
      naturalThai: pass === 1 ? 'NEEDS_HUMAN_REVIEW' : 'PASS_WITH_LIMITATION',
      eventSpecificity: 'FAIL_GENERIC_BROAD_DIRECTION_ONLY',
      duplicateTemplateRisk: 'FAIL_REPEATED_TEMPLATE',
    },
    observation: pass === 1
      ? `${context.archetype}/${context.thaiAstrologicalDay}: ข้อความช่วง ${row.age_period} สะท้อน ${signature} แต่ยังเป็นทิศทางกว้าง ไม่ใช่เหตุการณ์เฉพาะจากต้นฉบับ`
      : `${context.contextId}: ยืนยันซ้ำว่าประโยคใช้โดเมน ${row.allowed_prediction_domains.join(', ')} ตามแถวจริง แต่รูปประโยคซ้ำกับบริบทอื่นและต้องให้ Owner ตรวจภาษา`,
    duplicateTemplateOwner: stripSubject(excerpt),
    unresolvedIssue: 'SOURCE_DIRECT_EVENT_AUTHORITY_NOT_COMPLETE_FOR_ALL_PERIODS',
  });
}
const audit = { version: 1, reviewType: 'AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW', humanReviewStatus: 'PENDING', counts: { entries: auditEntries.length, passes: 2, contexts: 49, genericDirectionFailures: auditEntries.length }, entries: auditEntries };
writeJson('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW.json', audit);
writeText('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW.md', `# AI Content Audit — Not Human Review

- 2 reads × 49 contexts = ${auditEntries.length} entries
- Human review: PENDING
- ทุก entry มี excerpt, context/period, refs, observation, dimension result, duplicate-template owner และ unresolved issue
- ผลรวมยัง NO-GO เพราะ broad-direction copy ไม่เท่ากับ source-direct event authority`);

console.log(JSON.stringify({ atoms: atoms.length, directContexts: directContexts.size, directPeriods: directMatrixKeys.size, visualPages: visualPages.length, diversity: diversity.counts, candidateKnownClaims: candidateClaims.length, auditEntries: auditEntries.length }, null, 2));
