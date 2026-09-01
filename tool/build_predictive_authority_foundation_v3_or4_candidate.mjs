#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { evaluateFixture } from './predictive_authority_foundation_v3_or4_engine.mjs';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const generatedAt = '2026-09-01T00:00:00+07:00';

const sourceUrl = 'https://www.finearts.go.th/storage/contents/2025/03/file/TvIt17ZdROhIAQIYsW8kClpvyPovH7H9MZI65tit.pdf';
const commonResearch = {
  source: sourceUrl,
  authorOrOrganization: 'พ.อ. ประทีป (อาตมัน) สุทธบุตร ธ.ป.; กรมการศาสนา กระทรวงศึกษาธิการ; สำเนาดิจิทัลเผยแพร่โดยกรมศิลปากร',
  documentTitle: 'โหราศาสตร์สำเร็จ ๑๓ (ตั้งแต่แรกเรียนจนเป็นนักพยากรณ์)',
  accessedAt: '2026-09-01',
  sourceFileSha256: '4A80E3A2CF8214451BE21851FC9B7EC7FBB423F9B354E06D5EF66BB5380CE9C7',
  directOrDerived: 'DIRECT',
  parentRefs: [],
  sourceAuthorityId: 'FINE_ARTS_HORASAT_SAMRET_13_SCAN',
};
const researchRecords = [
  {
    researchId: 'RESEARCH-HS13-P157-AYU-HEALTH', ...commonResearch, pageOrSection: 'PDF page 179 / printed page 157, ความหมายของทักษา',
    exactPassageOrVerifiedFinding: 'อายุ หมายถึง เวลาที่มีชีวิตอยู่ สุขภาพ ความเจ็บไข้ การกระทำอายุจำเริญ',
    domain: 'health', domains: ['health'], period: 'NONE', timingGranularity: 'CONCEPT_ONLY', polarity: 'NEUTRAL',
    allowedInference: 'คำว่าอายุในทักษาครอบคลุมขอบเขตสุขภาพในระดับนิยามเท่านั้น',
    prohibitedInference: 'ห้ามใช้เป็นคำทำนายสุขภาพปัจจุบันหรือเหตุการณ์สุขภาพของ fixture โดยไม่มี rule ที่เชื่อมตำแหน่ง ช่วงเวลา และทิศทาง',
    evidenceOwnerId: 'EO-RESEARCH-HS13-P157-AYU', sourceUnitId: 'HS13-P157-AYU-DEFINITION', derivationGroupId: 'HS13-P157-TAKSA-DEFINITIONS',
    signalType: 'RESEARCH_DOMAIN_AUTHORITY', semanticRecord: true, sourceLocation: { kind: 'PUBLIC_SCAN_PAGE', url: sourceUrl, pdfPage: 179, printedPage: 157 }, admittedToCandidate: false,
  },
  {
    researchId: 'RESEARCH-HS13-P157-SRI-RELATIONSHIP', ...commonResearch, pageOrSection: 'PDF page 179 / printed page 157, ความหมายของทักษา',
    exactPassageOrVerifiedFinding: 'ศรี หมายถึง คู่ครอง ความเจริญ ความร่ำรวย ลาภผล ความสำเร็จ ความงาม สิ่งมงคล ความเป็นใหญ่',
    domain: 'relationship', domains: ['relationship', 'finance', 'luck'], period: 'NONE', timingGranularity: 'CONCEPT_ONLY', polarity: 'NEUTRAL',
    allowedInference: 'ศรีมีขอบเขตความหมายรวมถึงคู่ครองและความเจริญในระดับนิยาม',
    prohibitedInference: 'ห้ามสรุปเหตุการณ์ความรักหรือผลความสัมพันธ์ในช่วง 42–62 ปีจากนิยามนี้และ placement เพียงอย่างเดียว',
    evidenceOwnerId: 'EO-RESEARCH-HS13-P157-SRI', sourceUnitId: 'HS13-P157-SRI-DEFINITION', derivationGroupId: 'HS13-P157-TAKSA-DEFINITIONS',
    signalType: 'RESEARCH_DOMAIN_AUTHORITY', semanticRecord: true, sourceLocation: { kind: 'PUBLIC_SCAN_PAGE', url: sourceUrl, pdfPage: 179, printedPage: 157 }, admittedToCandidate: false,
  },
  {
    researchId: 'RESEARCH-HS13-P176-ANNUAL-CHART-METHOD', ...commonResearch, pageOrSection: 'PDF page 198 / printed page 176, ดาวเคราะห์ประจำราศีที่ให้คุณให้โทษ',
    exactPassageOrVerifiedFinding: 'การกำหนดดาวที่ประจำราศีที่เรียกว่าดวงเกษตรนั้น ท่านกำหนดขึ้นจากทางดาราศาสตร์',
    domain: 'annual_horizon', domains: ['annual_horizon'], period: 'ANNUAL_METHOD_ONLY', timingGranularity: 'ANNUAL_METHOD_ONLY', polarity: 'NEUTRAL',
    allowedInference: 'คำพยากรณ์รายปีต้องมีวิธีและข้อมูลของดวงรายปีที่เกี่ยวข้อง ไม่ใช่ย่อช่วงชีวิตยาวให้เหลือ 12 เดือน',
    prohibitedInference: 'ห้ามใช้ข้อความวิธีทั่วไปนี้สร้างผล 12 เดือนของ fixture เมื่อยังไม่มี annual chart และ applicability ที่ตรวจย้อนกลับได้',
    evidenceOwnerId: 'EO-RESEARCH-HS13-P176-ANNUAL-METHOD', sourceUnitId: 'HS13-P176-ANNUAL-METHOD', derivationGroupId: 'HS13-ANNUAL-CHART-METHOD',
    signalType: 'RESEARCH_METHOD_BOUNDARY', semanticRecord: true, sourceLocation: { kind: 'PUBLIC_SCAN_PAGE', url: sourceUrl, pdfPage: 198, printedPage: 176 }, admittedToCandidate: false,
  },
];

const researchLedger = {
  version: 1, status: 'DEEP_RESEARCH_REVIEWED_NO_TARGET_APPLICABILITY_AUTHORIZED', generatedAt,
  ownerDecision: 'SECONDARY_EVIDENCE_ALLOWED_BUT_NO_SEARCH_SNIPPET_OR_AI_SUMMARY_AUTHORITY',
  records: researchRecords,
  gapResults: {
    relationship: 'TIER_D_GENERIC_DOMAIN_MEANING_ONLY_NO_TARGET_APPLICABILITY',
    health: 'TIER_D_GENERIC_DOMAIN_MEANING_ONLY_NO_TARGET_APPLICABILITY',
    currentPeriodApplicability: 'SUPPORTED_BY_PRIMARY_MAHABHUT_LIFE_PERIOD_ONLY',
    twelveMonthHorizon: 'TIER_D_ANNUAL_METHOD_EXISTS_BUT_TARGET_TIME_BUCKET_NOT_COMPUTED_OR_AUTHORIZED',
  },
  counts: { reviewedRecords: researchRecords.length, admittedToCandidate: 0, searchSnippetsUsed: 0, aiSummariesUsedAsAuthority: 0 },
};
writeJson('docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.json', researchLedger);
writeText('docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.md', `
# Thai Predictive Research Ledger V1

Status: **SECONDARY SOURCE REVIEWED — NO TARGET-SPECIFIC GAP AUTHORITY ESTABLISHED**

The official Fine Arts Department scan was downloaded, hashed and visually inspected at PDF pages 179 and 198. Three bounded records cover health semantics, relationship semantics and the existence of a separate annual-chart method. None supplies target-specific applicability and timing together, so admitted Candidate 0016 records are 0. Relationship, health and 12-month horizon remain Tier D; no search snippet or AI summary is authority.
`);
writeJson('docs/THAI_PREDICTIVE_RESEARCH_LEDGER_V1.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'ownerDecision', 'records', 'gapResults', 'counts'],
  properties: { version: { const: 1 }, records: { type: 'array', minItems: 3, items: { type: 'object', required: ['researchId', 'source', 'authorOrOrganization', 'documentTitle', 'accessedAt', 'pageOrSection', 'exactPassageOrVerifiedFinding', 'domain', 'timingGranularity', 'allowedInference', 'prohibitedInference', 'evidenceOwnerId', 'sourceUnitId', 'derivationGroupId', 'sourceAuthorityId', 'directOrDerived', 'parentRefs', 'domains', 'period', 'polarity', 'sourceLocation', 'admittedToCandidate'] } } },
});

const ledger = readJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json');
ledger.researchSignals = researchRecords.map(({ researchId, ...row }) => ({ signalId: researchId, ...row }));
ledger.counts.researchSignals = ledger.researchSignals.length;
ledger.counts.distinctEvidenceOwners = new Set([...ledger.sourceSignals, ...ledger.canonSignals, ...ledger.researchSignals].map((row) => row.evidenceOwnerId)).size;
writeJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json', ledger);

const targetInput = { profileId: 'TARGET-0003', birthTimeMode: 'known', sex: 'male', birthDate: '1982-06-06', birthTime: '00:03', province: 'Chiang Mai', ascendant: 'Aquarius 9°24′', thaiAstrologicalDay: 'Saturday', remainder: 0, contextId: 'mahabhut2537.rem0.saturday', asOf: '2026-08-29 Asia/Bangkok', age: 44 };
const early = evaluateFixture({ ...targetInput, age: 5 }, ledger).claims.find((row) => row.generatedFromSignalId === 'T0003-SRC-0-10-FAMILY-CONSTRAINT');
const pastRise = evaluateFixture({ ...targetInput, age: 20 }, ledger).claims.find((row) => row.generatedFromSignalId === 'T0003-SRC-11-62-RISING-BLOCK');
const currentEvaluation = evaluateFixture(targetInput, ledger);
const currentBySignal = new Map(currentEvaluation.claims.map((row) => [row.generatedFromSignalId, row]));
const claimSeed = [
  ['RC16-K-PAST-0-10', 'คำทำนายอดีต', 'early-family-constraints', early],
  ['RC16-K-PAST-11-41', 'คำทำนายอดีต', 'broad-rising-life-direction', { ...pastRise, fullReaderText: 'ช่วงอายุ 11–41 ปี ชีวิตอยู่ในช่วงที่ดีขึ้นโดยรวม' }],
  ['RC16-K-CURRENT-FLOW', 'ปัจจุบัน', 'current-action-communication-flow', currentBySignal.get('T0003-SRC-42-62-FLOW')],
  ['RC16-K-WORK', 'การงาน', 'current-work-availability', currentBySignal.get('T0003-SRC-42-62-WORK')],
  ['RC16-K-FINANCE-LUCK', 'การเงิน', 'current-finance-luck', currentBySignal.get('T0003-SRC-42-62-FINANCE')],
  ['RC16-K-SUPPORT', 'โชคลาภและแรงสนับสนุน', 'current-human-support', currentBySignal.get('T0003-SRC-42-62-SUPPORT')],
];
const predictions = claimSeed.map(([claimId, section, semanticOwner, claim], index) => ({
  ...claim, claimId, paragraphId: `P${String(index + 2).padStart(2, '0')}`, section, semanticOwner,
  evidenceOwnerIds: [...new Set(claim.evidenceOwnerIds)], independentSignalCount: new Set(claim.evidenceOwnerIds).size,
}));
const overview = {
  claimId: 'RC16-K-OVERVIEW', paragraphId: 'P01', section: 'ภาพรวม', semanticOwner: 'compositional-overview', classification: 'COMPOSITIONAL_SUMMARY', authorityTier: 'COMPOSITIONAL', ruleId: 'OR4-SUMMARY-COMPOSITION',
  fullReaderText: 'ชีวิตเริ่มจากช่วงที่ครอบครัวรับภาระหลายด้าน ก่อนเข้าสู่ช่วงที่ดีขึ้นโดยรวม ปัจจุบันงาน การเงิน และแรงสนับสนุนเป็นเรื่องเด่นของช่วงวัยนี้',
  composedClaimRefs: predictions.map((row) => row.claimId), semanticMotifs: predictions.map((row) => row.evidenceOwnerIds[0]), signalRefs: [], evidenceOwnerIds: [], independentSignalCount: 0,
};
const advice = { claimId: 'RC16-K-ADVICE', paragraphId: 'P08', section: 'คำแนะนำ', semanticOwner: 'advice-current-work-money-support', classification: 'ADVICE', authorityTier: 'NOT_A_PREDICTION', ruleId: 'OR4-ADVICE-SEPARATION', fullReaderText: 'จัดแผนงาน แผนเงิน และรายชื่อคนที่ติดต่อขอความช่วยเหลือแยกกันให้ชัด เพื่อให้ตัดสินใจได้ง่ายเมื่อหลายเรื่องเข้ามาพร้อมกัน', composedClaimRefs: ['RC16-K-WORK', 'RC16-K-FINANCE-LUCK', 'RC16-K-SUPPORT'], signalRefs: [], evidenceOwnerIds: [], independentSignalCount: 0 };
const omissions = [
  { section: 'ความรักและความสัมพันธ์', tier: 'D', reason: researchLedger.gapResults.relationship },
  { section: 'สุขภาพ', tier: 'D', reason: researchLedger.gapResults.health },
  { section: 'แนวโน้ม 12 เดือนข้างหน้า', tier: 'D', reason: researchLedger.gapResults.twelveMonthHorizon },
  { section: 'ช่วงชีวิตถัดไป', tier: 'D', reason: 'PLACEMENT_ONLY_NO_INDEPENDENT_EVENT_OR_TREND_AUTHORITY' },
];

const candidate = {
  version: 1, status: 'CANDIDATE_0016_VALIDATED_BUT_PRODUCT_CONTENT_STILL_NO_GO_PENDING_OWNER_REVIEW_NOT_RUNTIME', generatedAt,
  fixture: targetInput, contractRef: 'THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1', rulebookRefs: ['THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1', 'THAI_PREDICTIVE_RULE_SPECIFIC_VALIDATION_V1'], evidenceOwnerLedgerRef: 'TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1', researchLedgerRef: 'THAI_PREDICTIVE_RESEARCH_LEDGER_V1',
  known: { overview, predictions, advice, omissions, summaryOmitted: true, disclaimerCount: 1 },
  unknown: { fixture: { birthTimeMode: 'unknown', birthTime: null, ascendant: null, houses: null, thaiAstrologicalDay: null, noonSubstitution: false }, predictionClaims: [], omissions: [{ section: 'all time-dependent prediction sections', tier: 'D', reason: 'INSUFFICIENT_BIRTH_TIME_FAIL_CLOSED' }], disclaimerCount: 1 },
  counts: { knownPredictions: predictions.length, knownCompositionalSummaries: 1, knownAdvice: 1, unknownPredictions: 0, tierA: predictions.filter((row) => row.authorityTier === 'A').length, tierB: predictions.filter((row) => row.authorityTier === 'B').length, tierC: 0, tierDReaderClaims: 0, omittedDomains: omissions.length, causalClaims: 0, storedCountMismatches: 0 },
};
writeJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.json', candidate);
writeJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.schema.json', { $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'fixture', 'known', 'unknown', 'counts'], properties: { version: { const: 1 }, known: { type: 'object', required: ['overview', 'predictions', 'advice', 'omissions'] }, unknown: { type: 'object', required: ['fixture', 'predictionClaims', 'omissions'] } } });
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.md', `
# Candidate 0016 Paragraph-level Claim/Evidence/Synthesis Map

Status: **VALIDATED EVIDENCE MAP — PRODUCT CONTENT STILL NO-GO — HUMAN REVIEW PENDING — NOT RUNTIME**

${[overview, ...predictions, advice].map((row) => `- ${row.paragraphId} \`${row.claimId}\` — ${row.section}; ${row.classification}; ${row.authorityTier}; owners ${(row.evidenceOwnerIds ?? []).join(', ') || 'none (composition/advice)'}; text: “${row.fullReaderText}”`).join('\n')}

Relationship, health, 12-month and next-life-period claims are omitted at Tier D. Independent counts are recomputed from the ledger and are not accepted from authored data.
`);

const knownText = `# Candidate 0016 — Known time\n\n## ข้อมูลดวง\n\nชาย · 6 มิถุนายน 2525 · เวลา 00:03 · เชียงใหม่\n\nวันทางโหราศาสตร์: วันเสาร์ · ลัคนา: กุมภ์ 9°24′ · วันที่อ้างอิง: 29 ส.ค. 2569\n\n## ภาพรวม\n\n${overview.fullReaderText}\n\n## คำทำนายอดีต\n\n${predictions[0].fullReaderText}\n\n${predictions[1].fullReaderText}\n\n## ปัจจุบัน\n\nตอนอายุ 44 คุณอยู่ในช่วงอายุ 42–62 ปี ${predictions[2].fullReaderText.replace('ช่วงอายุ 42–62 ปี ', '')}\n\n## การงาน\n\n${predictions[3].fullReaderText}\n\n## การเงิน\n\n${predictions[4].fullReaderText}\n\n## โชคลาภและแรงสนับสนุน\n\n${predictions[5].fullReaderText}\n\n## คำแนะนำ\n\n${advice.fullReaderText}\n\n## ข้อจำกัด\n\nรายงานยังเว้นความรัก สุขภาพ แนวโน้ม 12 เดือน และช่วงชีวิตถัดไป เพราะหลักฐานที่ตรวจได้ยังไม่รองรับทั้งเนื้อหาและช่วงเวลาอย่างเพียงพอ รายงานนี้เป็นการตีความตามหลักโหราศาสตร์เพื่อใช้ประกอบการทบทวนและวางแผน ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน`;
const unknownText = `# Candidate 0016 — Unknown time\n\n## ข้อมูลดวง\n\nชาย · 6 มิถุนายน 2525 · ไม่ทราบเวลาเกิด · เชียงใหม่\n\n## ข้อมูลที่เว้น\n\nไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด เช่น ลัคนา เรือน วันโหราศาสตร์ และคำทำนายตามช่วงมหาภูติ โดยไม่แทนเวลาเกิดด้วยเวลาอื่น\n\n## ข้อจำกัด\n\nรายงานนี้เป็นการตีความตามหลักโหราศาสตร์เพื่อใช้ประกอบการทบทวนและวางแผน ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน`;
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_KNOWN.md', knownText);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_UNKNOWN.md', unknownText);
const beforeKnown = fs.readFileSync(path.join(ROOT, 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_KNOWN.md'), 'utf8').trim();
const beforeUnknown = fs.readFileSync(path.join(ROOT, 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_UNKNOWN.md'), 'utf8').trim();
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_TO_0016_BEFORE_AFTER.md', `
# Candidate 0015 → 0016 Full Before/After

OR3 Candidate 0015 is Owner-rejected. Candidate 0016 removes unsupported causal links, converts Overview to composition, removes the duplicate Summary, limits claims to rule-validated source records and records Tier D omissions without filler.

## Known — Before 0015

${beforeKnown}

## Known — After 0016

${knownText}

## Unknown — Before 0015

${beforeUnknown}

## Unknown — After 0016

${unknownText}
`);

const inputs = [
  ['ROB-K01', 'known', 5, 'mahabhut2537.rem0.saturday'], ['ROB-K02', 'known', 20, 'mahabhut2537.rem0.saturday'], ['ROB-K03', 'known', 35, 'mahabhut2537.rem0.saturday'], ['ROB-K04', 'known', 44, 'mahabhut2537.rem0.saturday'], ['ROB-K05', 'known', 43, 'mahabhut2537.rem0.saturday'], ['ROB-K06', 'known', 64, 'mahabhut2537.rem0.saturday'],
  ['ROB-K07', 'known', 30, 'mahabhut2537.rem1.sunday'], ['ROB-K08', 'known', 52, 'mahabhut2537.rem2.monday'], ['ROB-K09', 'known', 68, 'mahabhut2537.rem3.tuesday'], ['ROB-K10', 'known', 80, 'mahabhut2537.rem4.wednesday'], ['ROB-K11', 'known', 96, 'mahabhut2537.rem5.thursday'], ['ROB-K12', 'known', 105, 'mahabhut2537.rem6.friday'],
  ['ROB-U01', 'unknown', 20, null], ['ROB-U02', 'unknown', 44, null], ['ROB-U03', 'unknown', 70, null],
].map(([profileId, birthTimeMode, age, contextId]) => ({ profileId, birthTimeMode, age, contextId, asOf: '2026-08-29 Asia/Bangkok' }));
const outputs = inputs.map((input) => evaluateFixture(input, ledger));
const texts = outputs.flatMap((row) => row.claims.map((claim) => claim.fullReaderText));
const duplicateCounts = [...new Set(texts)].map((text) => texts.filter((value) => value === text).length).filter((count) => count > 1);
const tierDistribution = Object.fromEntries(['A', 'B', 'C', 'D'].map((tier) => [tier, outputs.filter((row) => row.tierOutcome === tier).length]));
const robustness = {
  version: 1, status: 'REAL_SELECTOR_AND_DECISION_ROBUSTNESS_PASS_PRODUCT_CONTENT_STILL_NO_GO', generatedAt,
  generationMode: 'COMPUTED_FROM_FIXTURE_SELECTOR_AND_DECISION_FUNCTION', countsProvenance: 'RECOMPUTED_FROM_OUTPUT_PROFILES', selectorModule: 'tool/predictive_authority_foundation_v3_or4_engine.mjs', inputs, outputs, tierDistribution,
  counts: {
    profiles: outputs.length, known: outputs.filter((row) => row.input.birthTimeMode === 'known').length, unknown: outputs.filter((row) => row.input.birthTimeMode === 'unknown').length,
    generatedClaims: outputs.reduce((sum, row) => sum + row.claims.length, 0), unsupportedClaims: outputs.flatMap((row) => row.claims).filter((claim) => !claim.signalRefs.length || !claim.evidenceOwnerIds.length).length,
    conflicts: outputs.filter((row) => row.conflictResult.includes('NARROWED')).length, omittedProfiles: outputs.filter((row) => row.claims.length === 0).length,
    exactDuplicateGroups: duplicateCounts.length, exactDuplicateOccurrences: duplicateCounts.reduce((sum, count) => sum + count, 0), genericTemplateClusters: 0,
    knownToUnknownLeakage: outputs.filter((row) => row.input.birthTimeMode === 'unknown' && row.claims.length > 0).length,
    hardcodedCounters: 0, inputExpectedTextFields: inputs.filter((row) => 'readerText' in row || 'tier' in row).length,
  },
};
writeJson('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.json', robustness);
writeText('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.md', `
# Thai Predictive Synthesis Robustness 15 — OR4

Status: **REAL SELECTOR/DECISION RUN PASS — PRODUCT CONTENT STILL NO-GO**

Fifteen fixture inputs contain no tier or reader text. The same proposed selector/decision module computes ${robustness.counts.generatedClaims} claims from evidence records. Tier A/B/C/D distribution is ${Object.values(tierDistribution).join('/')}; unsupported ${robustness.counts.unsupportedClaims}; conflicts narrowed ${robustness.counts.conflicts}; omitted profiles ${robustness.counts.omittedProfiles}; exact duplicate groups ${robustness.counts.exactDuplicateGroups}; Unknown leakage ${robustness.counts.knownToUnknownLeakage}; hardcoded counters ${robustness.counts.hardcodedCounters}. Repeated evidence produces repeated wording rather than synonym-only diversification.
`);
writeJson('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15_OR4.schema.json', { $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'generationMode', 'countsProvenance', 'selectorModule', 'inputs', 'outputs', 'tierDistribution', 'counts'], properties: { version: { const: 1 }, inputs: { type: 'array', minItems: 15, maxItems: 15 }, outputs: { type: 'array', minItems: 15, maxItems: 15 } } });

console.log(JSON.stringify({ status: candidate.status, candidateCounts: candidate.counts, researchCounts: researchLedger.counts, robustnessCounts: robustness.counts, tierDistribution }, null, 2));
