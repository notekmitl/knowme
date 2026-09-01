#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const generatedAt = '2026-09-01T00:00:00+07:00';
const fixture = {
  sex: 'male', birthDate: '1982-06-06', birthTime: '00:03', province: 'Chiang Mai',
  ascendant: 'Aquarius 9°24′', thaiAstrologicalDay: 'Saturday', remainder: 0,
  contextId: 'mahabhut2537.rem0.saturday', asOf: '2026-08-29 Asia/Bangkok', age: 44,
};
const imageHashes = {
  290: 'A688214454A2972DC20165C89DC6B10688A311855FC5E8928A574A1C7D7935E2',
  291: '35796FA054A48793434FE8657A31F228A1C2DD6756D960BD818583DDC411C2C8',
  292: '87D344740A69CD0F039B2898AE9A74AA6E6A7438430F0B4A0E92B7E6F7D368D9',
};
const ocrHashes = {
  290: 'D2230BDDBBE986A3F4462B0D687216546426BBBD163F8239235C22AC83098A06',
  291: 'F04EB974146C5F49491CAE8A3EC8D1E16A21DADF2F1E434FAC7EAB2A1020F53A',
  292: '01817A64D42EBD58F5BDC4CAAD44BF1521819C86E886C987385A1A707200E451',
};

const reviewRecords = [
  { page: 290, imageSha256: imageHashes[290], ocrSha256: ocrHashes[290], reviewMethod: 'AI_VISUAL_SEMANTIC_REVIEW', humanReview: 'PENDING', observation: 'The page identifies rem0 Saturday, gives the full eight-row placement table, describes birth through age 10, and starts the 11–62 rising-period block. OCR corrupts several Thai numerals and the age heading.' },
  { page: 291, imageSha256: imageHashes[291], ocrSha256: ocrHashes[291], reviewMethod: 'AI_VISUAL_SEMANTIC_REVIEW', humanReview: 'PENDING', observation: 'The page continues the 30–41 and 42–62 placements, then directly states support, access to work, available money/luck and smoother action/speech/thought. The closing paragraph starts the 42–43 and 61–62 exception.' },
  { page: 292, imageSha256: imageHashes[292], ocrSha256: ocrHashes[292], reviewMethod: 'AI_VISUAL_SEMANTIC_REVIEW', humanReview: 'PENDING', observation: 'The page completes the 42–43 and 61–62 exception: gains may be short-lived and speech needs caution. It then closes the rem0 Saturday chapter; it contains no 12-month or monthly horizon.' },
];

const sourceRecords = [
  { evidenceId: 'T0003-SRC-0-10-FAMILY-CONSTRAINT', pages: [290], exactPeriod: '0-10', classification: 'SOURCE_DIRECT_EVENT', domains: ['family', 'health', 'work', 'finance'], excerpt: 'พ่อแม่มีสุขภาพร่างกายอ่อนแอ มีการงานย่ำแย่ มีการเงินติดขัด', correctedTranscription: 'พ่อแม่มีสุขภาพร่างกายอ่อนแอ มีการงานย่ำแย่ มีการเงินติดขัด', normalizedMeaning: 'Early family health, work and money constraints limited close care.', sourceDirectStrength: 'EXPLICIT_MULTI_DOMAIN_EVENT_CLAUSE', prohibitedExtrapolations: ['specific diagnosis', 'specific parent', 'exact financial amount', 'permanent childhood outcome'] },
  { evidenceId: 'T0003-SRC-11-62-RISING-BLOCK', pages: [290, 291], exactPeriod: '11-62', classification: 'SOURCE_DIRECT_TREND', domains: ['life_direction'], excerpt: 'อายุ ๑๑ ขวบถึง ๖๒ ปี (ดวงขึ้นสุด ๆ)', correctedTranscription: 'อายุ 11 ขวบถึง 62 ปี (ดวงขึ้นสุด ๆ)', normalizedMeaning: 'The source explicitly marks ages 11–62 as a broadly rising phase.', sourceDirectStrength: 'EXPLICIT_DIRECTION_HEADING', prohibitedExtrapolations: ['specific promotion', 'specific relationship event', 'specific health event', 'specific month'] },
  { evidenceId: 'T0003-SRC-11-29-PLACEMENT', pages: [290], exactPeriod: '11-29', classification: 'SOURCE_PLACEMENT_FACT', domains: ['health', 'learning'], excerpt: 'อายุ ๑๑ ถึง ๒๙ ... ดาวพฤหัส ดาวแห่งอายุ สถิตเรือนราชา', correctedTranscription: 'อายุ 11 ถึง 29 ปี ดาวพฤหัส ดาวแห่งอายุ สถิตเรือนราชา', normalizedMeaning: 'Jupiter/Ayu/Racha placement for ages 11–29.', sourceDirectStrength: 'PLACEMENT_NOT_EVENT', prohibitedExtrapolations: ['placement alone as prediction', 'specific education event', 'specific mentor event'] },
  { evidenceId: 'T0003-SRC-30-41-PLACEMENT', pages: [290, 291], exactPeriod: '30-41', classification: 'SOURCE_PLACEMENT_FACT', domains: ['work', 'authority', 'pressure'], excerpt: 'อายุ ๓๐ ถึง ๔๑ ... ดาวราหู ดาวแห่งเดช สถิตเรือนอธิบดี', correctedTranscription: 'อายุ 30 ถึง 41 ปี ดาวราหู ดาวแห่งเดช สถิตเรือนอธิบดี', normalizedMeaning: 'Rahu/Det/Athibodi placement for ages 30–41.', sourceDirectStrength: 'PLACEMENT_NOT_EVENT', prohibitedExtrapolations: ['placement alone as prediction', 'specific title', 'specific job change'] },
  { evidenceId: 'T0003-SRC-42-62-PLACEMENT', pages: [291], exactPeriod: '42-62', classification: 'SOURCE_PLACEMENT_FACT', domains: ['finance', 'status'], excerpt: 'อายุ ๔๒ ถึง ๖๒ ... ดาวศุกร์ ดาวแห่งศรี สถิตเรือนธงชัย', correctedTranscription: 'อายุ 42 ถึง 62 ปี ดาวศุกร์ ดาวแห่งศรี สถิตเรือนธงชัย', normalizedMeaning: 'Venus/Sri/Thongchai placement for ages 42–62.', sourceDirectStrength: 'PLACEMENT_NOT_EVENT', prohibitedExtrapolations: ['placement alone as prediction'] },
  { evidenceId: 'T0003-SRC-42-62-SUPPORT', pages: [291], exactPeriod: '42-62', classification: 'SOURCE_DIRECT_EVENT', domains: ['support'], excerpt: 'ได้รับการช่วยเหลือสนับสนุน ... จากครูบาอาจารย์และพรรคพวกเพื่อนฝูง', correctedTranscription: 'ได้รับการช่วยเหลือสนับสนุนจากครูบาอาจารย์และพรรคพวกเพื่อนฝูง', normalizedMeaning: 'Teachers, peers and connected people provide support.', sourceDirectStrength: 'EXPLICIT_EVENT_CLAUSE', prohibitedExtrapolations: ['named person', 'guaranteed patron', 'romantic relationship'] },
  { evidenceId: 'T0003-SRC-42-62-WORK', pages: [291], exactPeriod: '42-62', classification: 'SOURCE_DIRECT_EVENT', domains: ['work'], excerpt: 'ให้มีงานทำ', correctedTranscription: 'ให้มีงานทำ', normalizedMeaning: 'Access to work is supported.', sourceDirectStrength: 'EXPLICIT_EVENT_CLAUSE', prohibitedExtrapolations: ['promotion', 'specific employer', 'specific date'] },
  { evidenceId: 'T0003-SRC-42-62-FINANCE', pages: [291], exactPeriod: '42-62', classification: 'SOURCE_DIRECT_EVENT', domains: ['finance', 'luck'], excerpt: 'ให้มีเงินใช้ ให้มีโชคมีลาภ', correctedTranscription: 'ให้มีเงินใช้ ให้มีโชคมีลาภ', normalizedMeaning: 'Money is available and favorable gains are supported.', sourceDirectStrength: 'EXPLICIT_MULTI_DOMAIN_EVENT_CLAUSE', prohibitedExtrapolations: ['amount', 'windfall size', 'specific date'] },
  { evidenceId: 'T0003-SRC-42-62-FLOW', pages: [291], exactPeriod: '42-62', classification: 'SOURCE_DIRECT_TREND', domains: ['work', 'communication', 'decision'], excerpt: 'การทำการพูดการคิด ทุกอย่างจะราบรื่นลื่นไหลไร้อุปสรรค', correctedTranscription: 'การทำ การพูด การคิด ทุกอย่างจะราบรื่นลื่นไหลไร้อุปสรรค', normalizedMeaning: 'Action, communication and thought move more smoothly.', sourceDirectStrength: 'EXPLICIT_DIRECTION_CLAUSE', prohibitedExtrapolations: ['guaranteed outcome', 'zero risk', 'specific decision result'] },
  { evidenceId: 'T0003-SRC-42-43-61-62-EXCEPTION', pages: [291, 292], exactPeriod: '42-43|61-62', classification: 'SOURCE_DIRECT_EVENT', domains: ['finance', 'communication'], excerpt: 'ได้มาแล้วก็สูญเสียคืนไป ... ควรระวังคำพูดคำจา', correctedTranscription: 'ได้มาแล้วก็สูญเสียคืนไป เจ้าชะตาควรระวังคำพูดคำจา', normalizedMeaning: 'Only at ages 42–43 and 61–62, gains may be short-lived and speech needs caution.', sourceDirectStrength: 'EXPLICIT_BOUNDARY_EXCEPTION', prohibitedExtrapolations: ['apply to age 44', 'apply to all ages 42–62', 'specific loss amount'] },
  { evidenceId: 'T0003-SRC-63-79-PLACEMENT', pages: [290], exactPeriod: '63-79', classification: 'SOURCE_PLACEMENT_FACT', domains: ['home', 'family', 'documents', 'communication'], excerpt: 'พุธ สถิตเรือนอธิบดี', correctedTranscription: 'ดาวพุธ ดาวแห่งมูละ สถิตเรือนอธิบดี', normalizedMeaning: 'Mercury/Mula/Athibodi placement for ages 63–79 from the eight-row table.', sourceDirectStrength: 'PLACEMENT_NOT_EVENT', prohibitedExtrapolations: ['placement alone as prediction', 'property purchase', 'inheritance event'] },
];

const canonSignals = [
  { signalId: 'T0003-CANON-JUPITER-LEARNING', source: 'production Canon', rule: 'mahabhut.p220.jupiter_owns_learning', domain: 'learning', period: '11-29', independent: true, derived: false, conflict: null, synthesisEligibility: 'ELIGIBLE_WITH_PERIOD_PLACEMENT_AND_HOUSE_DIRECTION' },
  { signalId: 'T0003-CANON-JUPITER-CAREER', source: 'production Canon', rule: 'mahabhut.p220.jupiter_owns_career', domain: 'work', period: '11-29', independent: true, derived: false, conflict: null, synthesisEligibility: 'ELIGIBLE_WITH_PERIOD_PLACEMENT_AND_HOUSE_DIRECTION' },
  { signalId: 'T0003-CANON-RAHU-SCOPE', source: 'proposed source rulebook', rule: 'MH2537-PLANET-RAHU', domain: 'pressure', period: '30-41', independent: true, derived: false, conflict: null, synthesisEligibility: 'ELIGIBLE_WITH_DET_AND_ATHIBODI' },
  { signalId: 'T0003-CANON-DET-WORK', source: 'proposed source rulebook', rule: 'MH2537-TAKSA-DET', domain: 'work', period: '30-41', independent: true, derived: false, conflict: null, synthesisEligibility: 'ELIGIBLE_WITH_RAHU_AND_ATHIBODI' },
  { signalId: 'T0003-CANON-MERCURY-FAMILY', source: 'production Canon', rule: 'mahabhut.p28.mercury_owns_family', domain: 'family', period: '63-79', independent: true, derived: false, conflict: null, synthesisEligibility: 'ELIGIBLE_WITH_MULA_AND_ATHIBODI' },
  { signalId: 'T0003-CANON-MERCURY-COMMUNICATION', source: 'proposed source rulebook', rule: 'MH2537-PLANET-MERCURY', domain: 'communication', period: '63-79', independent: true, derived: false, conflict: null, synthesisEligibility: 'ELIGIBLE_WITH_FAMILY_SIGNAL_AND_PLACEMENT' },
  { signalId: 'T0003-CANON-MULA-FOUNDATION', source: 'proposed source rulebook', rule: 'MH2537-TAKSA-MULA', domain: 'home', period: '63-79', independent: true, derived: false, conflict: null, synthesisEligibility: 'ELIGIBLE_WITH_MERCURY_FAMILY_AND_ATHIBODI' },
  { signalId: 'T0003-CANON-STRONG-HOUSE', source: 'proposed source rulebook', rule: 'MH2537-HOUSE-STRONG-DIRECTION', domain: 'direction', period: '11-29|30-41|42-62|63-79', independent: true, derived: false, conflict: null, synthesisEligibility: 'DIRECTION_ONLY_NOT_EVENT' },
];

const periodAssessments = [
  { period: '0-10', tier: 'A', authorized: true, sourceRefs: ['T0003-SRC-0-10-FAMILY-CONSTRAINT'], synthesisRefs: [], resultBoundary: 'Direct early-family constraints only.' },
  { period: '11-29', tier: 'C', authorized: true, sourceRefs: ['T0003-SRC-11-62-RISING-BLOCK', 'T0003-SRC-11-29-PLACEMENT'], canonRefs: ['T0003-CANON-JUPITER-LEARNING', 'T0003-CANON-JUPITER-CAREER', 'T0003-CANON-STRONG-HOUSE'], synthesisRefs: ['SYN-C-PERIOD-PLANET-TAKSA-HOUSE'], resultBoundary: 'Learning and professional foundation improve; no specific education or job event.' },
  { period: '30-41', tier: 'C', authorized: true, sourceRefs: ['T0003-SRC-11-62-RISING-BLOCK', 'T0003-SRC-30-41-PLACEMENT'], canonRefs: ['T0003-CANON-RAHU-SCOPE', 'T0003-CANON-DET-WORK', 'T0003-CANON-STRONG-HOUSE'], synthesisRefs: ['SYN-C-PERIOD-PLANET-TAKSA-HOUSE'], resultBoundary: 'Work responsibility and decisions progress amid non-routine pressure; no title or job-change event.' },
  { period: '42-62', tier: 'A', authorized: true, sourceRefs: ['T0003-SRC-42-62-SUPPORT', 'T0003-SRC-42-62-WORK', 'T0003-SRC-42-62-FINANCE', 'T0003-SRC-42-62-FLOW'], synthesisRefs: [], resultBoundary: 'Direct work, finance, support and flow clauses; boundary exception excluded at age 44.' },
  { period: '63-79', tier: 'C', authorized: true, sourceRefs: ['T0003-SRC-63-79-PLACEMENT'], canonRefs: ['T0003-CANON-MERCURY-FAMILY', 'T0003-CANON-MERCURY-COMMUNICATION', 'T0003-CANON-MULA-FOUNDATION', 'T0003-CANON-STRONG-HOUSE'], synthesisRefs: ['SYN-C-PERIOD-PLANET-TAKSA-HOUSE'], resultBoundary: 'Home/family foundations and communication/document handling improve; no property transaction or inheritance event.' },
  { period: '80-94', tier: 'D', authorized: false, sourceRefs: [], canonRefs: [], synthesisRefs: [], resultBoundary: 'Outside the target candidate horizon and no semantically reviewed event clause.' },
  { period: '95-102', tier: 'D', authorized: false, sourceRefs: [], canonRefs: [], synthesisRefs: [], resultBoundary: 'Outside the target candidate horizon and no semantically reviewed event clause.' },
  { period: '103-108', tier: 'D', authorized: false, sourceRefs: [], canonRefs: [], synthesisRefs: [], resultBoundary: 'Outside the target candidate horizon and no semantically reviewed event clause.' },
];

const dossier = {
  version: 1, status: 'TARGET_0003_EVIDENCE_DOSSIER_COMPLETE_AI_REVIEW_HUMAN_PENDING', generatedAt, fixture,
  source: { editionId: 'mahabhut-complete-duangkaew-2537-primary-working-edition', pdfSha256: '28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E', pages: [290, 291, 292] },
  reviewType: 'AI_VISUAL_SEMANTIC_REVIEW_NOT_HUMAN_REVIEW', humanReview: 'PENDING', reviewRecords, sourceRecords, canonSignals,
  deepResearchSignals: [], deepResearchBoundary: 'knowledge/research/research.knowme.json has zero records; no search snippet or AI summary is used as authority.',
  periodAssessments,
  counts: { pagesReviewed: reviewRecords.length, sourceRecords: sourceRecords.length, canonSignals: canonSignals.length, deepResearchSignals: 0, tierA: 2, tierB: 0, tierC: 3, tierD: 3, conflicts: 0 },
};
writeJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.json', dossier);
writeText('docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.md', `
# Target 0003 Predictive Evidence Dossier V1

Status: **AI VISUAL SEMANTIC REVIEW COMPLETE — HUMAN REVIEW PENDING — NOT RUNTIME**

Fixture: male, 6 June 1982, 00:03, Chiang Mai; Aquarius 9°24′; Saturday; rem0; asOf 2026-08-29 Asia/Bangkok.

Pages 290–292 were read from the page images. Eleven bounded source records and eight Canon signals are recorded. Ages 0–10 and 42–62 support Tier A direct events; ages 11–29, 30–41 and 63–79 support Tier C synthesis under the contract; later periods are Tier D for this candidate. The 42–43/61–62 gain-loss exception is not applied at age 44. Deep-research records are empty, and no search snippet or AI summary is authority.
`);
writeJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'fixture', 'source', 'reviewType', 'humanReview', 'reviewRecords', 'sourceRecords', 'canonSignals', 'periodAssessments', 'counts'],
  properties: { version: { const: 1 }, reviewRecords: { type: 'array', minItems: 3, maxItems: 3 }, sourceRecords: { type: 'array', minItems: 11 }, periodAssessments: { type: 'array', minItems: 8, maxItems: 8 } },
});

const claims = [
  { claimId: 'RC15-K-OVERVIEW', fullReaderText: 'เส้นทางชีวิตเริ่มจากข้อจำกัดในครอบครัว ก่อนค่อย ๆ ตั้งหลักได้ดีขึ้น และวัย 42–62 ปีเป็นช่วงที่งาน เงิน และแรงสนับสนุนเปิดทางพร้อมกัน', section: 'ภาพรวมเส้นทางชีวิต', semanticOwner: 'life-path-directional-arc', domain: 'life_direction', period: '0-62', authorityTier: 'C', sourceDirectAtomRefs: ['T0003-SRC-0-10-FAMILY-CONSTRAINT', 'T0003-SRC-11-62-RISING-BLOCK', 'T0003-SRC-42-62-WORK', 'T0003-SRC-42-62-FINANCE', 'T0003-SRC-42-62-SUPPORT'], canonRuleRefs: [], deepResearchRefs: [], synthesisRuleRefs: ['SYN-C-SOURCE-EVENT-CANON-BOUNDARY'], independentSignalCount: 5, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-PAST-0-10', fullReaderText: 'ช่วงอายุ 0–10 ปี ครอบครัวต้องรับภาระเรื่องสุขภาพ งาน และเงินพร้อมกัน การดูแลใกล้ชิดจึงทำได้ไม่เต็มที่', section: 'คำทำนายอดีต · อายุ 0–10 ปี', semanticOwner: 'early-family-capacity-constraint', domain: 'family', period: '0-10', authorityTier: 'A', sourceDirectAtomRefs: ['T0003-SRC-0-10-FAMILY-CONSTRAINT'], canonRuleRefs: [], deepResearchRefs: [], synthesisRuleRefs: ['SYN-A-EXACT-EVENT'], independentSignalCount: 1, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-PAST-11-29', fullReaderText: 'ช่วงอายุ 11–29 ปี การเรียนรู้และประสบการณ์จากงานช่วยให้ตั้งหลักได้ดีขึ้น และค่อย ๆ เปิดทางออกจากข้อจำกัดเดิม', section: 'คำทำนายอดีต · อายุ 11–29 ปี', semanticOwner: 'learning-builds-foundation', domain: 'learning', period: '11-29', authorityTier: 'C', sourceDirectAtomRefs: ['T0003-SRC-11-62-RISING-BLOCK', 'T0003-SRC-11-29-PLACEMENT'], canonRuleRefs: ['mahabhut.p220.jupiter_owns_learning', 'mahabhut.p220.jupiter_owns_career', 'MH2537-HOUSE-STRONG-DIRECTION'], deepResearchRefs: [], synthesisRuleRefs: ['SYN-C-PERIOD-PLANET-TAKSA-HOUSE'], independentSignalCount: 4, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-PAST-30-41', fullReaderText: 'ช่วงอายุ 30–41 ปี งานที่ต้องตัดสินใจเองและรับผิดชอบมากขึ้นพาให้ก้าวหน้า พร้อมกับแรงกดดันจากเรื่องที่ไม่เป็นไปตามกรอบเดิม', section: 'คำทำนายอดีต · อายุ 30–41 ปี', semanticOwner: 'responsibility-progress-under-pressure', domain: 'work', period: '30-41', authorityTier: 'C', sourceDirectAtomRefs: ['T0003-SRC-11-62-RISING-BLOCK', 'T0003-SRC-30-41-PLACEMENT'], canonRuleRefs: ['MH2537-PLANET-RAHU', 'MH2537-TAKSA-DET', 'MH2537-HOUSE-STRONG-DIRECTION'], deepResearchRefs: [], synthesisRuleRefs: ['SYN-C-PERIOD-PLANET-TAKSA-HOUSE'], independentSignalCount: 4, conflictResult: 'NARROWED_TO_WORK_PROGRESS_WITH_PRESSURE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-CURRENT', fullReaderText: 'ตอนอายุ 44 การลงมือ พูดคุย และตัดสินใจเดินหน้าได้คล่องขึ้น เรื่องที่เคยติดขัดจึงจัดการต่อได้ง่ายกว่าเดิม', section: 'คำทำนายปัจจุบัน', semanticOwner: 'current-execution-flow', domain: 'work', period: '42-62', authorityTier: 'B', sourceDirectAtomRefs: ['T0003-SRC-42-62-FLOW'], canonRuleRefs: [], deepResearchRefs: [], synthesisRuleRefs: ['SYN-B-EXACT-TREND'], independentSignalCount: 1, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-WORK', fullReaderText: 'การงานเปิดทางให้เดินหน้าต่อได้ เรื่องที่อยู่ตรงหน้ามีคนช่วยเชื่อมต่อจนเริ่มขยับ', section: 'การงาน', semanticOwner: 'work-access-and-connection', domain: 'work', period: '42-62', authorityTier: 'A', sourceDirectAtomRefs: ['T0003-SRC-42-62-WORK', 'T0003-SRC-42-62-SUPPORT'], canonRuleRefs: [], deepResearchRefs: [], synthesisRuleRefs: ['SYN-A-EXACT-EVENT'], independentSignalCount: 2, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-FINANCE', fullReaderText: 'การเงินหมุนใช้ได้ต่อเนื่องขึ้น งานที่เดินหน้าช่วยให้มีเงินรองรับค่าใช้จ่ายมากกว่าเดิม', section: 'การเงิน', semanticOwner: 'available-money-from-work', domain: 'finance', period: '42-62', authorityTier: 'C', sourceDirectAtomRefs: ['T0003-SRC-42-62-FINANCE', 'T0003-SRC-42-62-WORK'], canonRuleRefs: [], deepResearchRefs: [], synthesisRuleRefs: ['SYN-C-SOURCE-EVENT-CANON-BOUNDARY'], independentSignalCount: 2, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-SUPPORT', fullReaderText: 'ครู ผู้มีประสบการณ์ เพื่อน และคนที่ทำงานเกี่ยวข้องกันยื่นมือช่วยในจังหวะสำคัญ ทำให้เรื่องที่ต้องประสานงานเดินต่อได้', section: 'โชคลาภและแรงสนับสนุน', semanticOwner: 'experienced-network-support', domain: 'support', period: '42-62', authorityTier: 'A', sourceDirectAtomRefs: ['T0003-SRC-42-62-SUPPORT'], canonRuleRefs: [], deepResearchRefs: [], synthesisRuleRefs: ['SYN-A-EXACT-EVENT'], independentSignalCount: 1, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
  { claimId: 'RC15-K-NEXT', fullReaderText: 'ช่วงอายุ 63–79 ปี เรื่องบ้าน ครอบครัว และหลักฐานสำคัญจัดการได้เป็นระบบขึ้น การพูดคุยและเอกสารช่วยให้เรื่องค้างเดินหน้า', section: 'ช่วงชีวิตถัดไป', semanticOwner: 'family-foundation-through-communication', domain: 'home', period: '63-79', authorityTier: 'C', sourceDirectAtomRefs: ['T0003-SRC-63-79-PLACEMENT'], canonRuleRefs: ['mahabhut.p28.mercury_owns_family', 'MH2537-PLANET-MERCURY', 'MH2537-TAKSA-MULA', 'MH2537-HOUSE-STRONG-DIRECTION'], deepResearchRefs: [], synthesisRuleRefs: ['SYN-C-PERIOD-PLANET-TAKSA-HOUSE'], independentSignalCount: 4, conflictResult: 'NONE', prohibitedEscalationCheck: 'PASS', classification: 'PREDICTION' },
];
const nonPrediction = [
  { claimId: 'RC15-K-SUMMARY', fullReaderText: 'วัย 42–62 ปี งาน เงิน และแรงสนับสนุนเดินหน้าไปพร้อมกัน ส่วนช่วง 63–79 ปี จุดสำคัญย้ายไปอยู่ที่บ้าน ครอบครัว และการจัดการเอกสาร', section: 'สรุป', semanticOwner: 'summary-bridge-no-new-specificity', classification: 'SUMMARY' },
  { claimId: 'RC15-K-ADVICE', fullReaderText: 'แยกเงินที่ใช้ได้ตอนนี้ออกจากภาระระยะยาว และบันทึกข้อตกลงสำคัญให้ชัดก่อนรับงานหรือภาระเพิ่ม', section: 'คำแนะนำ', semanticOwner: 'advice-finance-documentation', classification: 'ADVICE' },
  { claimId: 'RC15-K-DISCLAIMER', fullReaderText: 'รายงานนี้เป็นการตีความตามหลักโหราศาสตร์เพื่อใช้ประกอบการทบทวนและวางแผน ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน', section: 'ข้อจำกัด', semanticOwner: 'belief-disclaimer', classification: 'DISCLAIMER' },
];
const omissions = [
  { section: 'ความรักและความสัมพันธ์', tier: 'D', reason: 'Current-period Venus scope does not intersect the Sri domain strongly enough to authorize a relationship result.' },
  { section: 'สุขภาพ', tier: 'D', reason: 'No current-period semantically reviewed health event and no aligned multi-signal health synthesis.' },
  { section: 'ช่วง 12 เดือน', tier: 'D', reason: 'No source-backed horizon with start/end applicability; age-period evidence is not converted into a 12-month prediction.' },
];
const unknownClaims = [
  { claimId: 'RC15-U-OMISSION', fullReaderText: 'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด เช่น ลัคนา เรือน วันโหราศาสตร์ และคำทำนายตามช่วงมหาภูติ', section: 'ข้อมูลที่เว้น', semanticOwner: 'unknown-fail-closed', classification: 'OMISSION_NOTICE' },
  { claimId: 'RC15-U-DISCLAIMER', fullReaderText: 'รายงานนี้เป็นการตีความตามหลักโหราศาสตร์เพื่อใช้ประกอบการทบทวนและวางแผน ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน', section: 'ข้อจำกัด', semanticOwner: 'belief-disclaimer-unknown', classification: 'DISCLAIMER' },
];
const claimMap = {
  version: 1, status: 'CANDIDATE_0015_PENDING_OWNER_CONTENT_REVIEW_NOT_RUNTIME', generatedAt, fixture,
  contractRef: 'THAI_PREDICTIVE_SYNTHESIS_CONTRACT_V1', rulebookRef: 'THAI_PREDICTIVE_SYNTHESIS_RULEBOOK_V1', dossierRef: 'TARGET_0003_PREDICTIVE_EVIDENCE_DOSSIER_V1',
  counts: { knownPredictionClaims: claims.length, knownNonPredictionClaims: nonPrediction.length, unknownClaims: unknownClaims.length, tierA: claims.filter((x) => x.authorityTier === 'A').length, tierB: claims.filter((x) => x.authorityTier === 'B').length, tierC: claims.filter((x) => x.authorityTier === 'C').length, tierDReaderClaims: 0, unsupportedClaims: 0, methodologicalReaderClaims: 0, duplicateSemanticOwners: 0, predictionAdviceConversions: 0 },
  known: { predictions: claims, nonPrediction, omissions },
  unknown: { fixture: { birthTime: null, noonSubstitution: false, ascendant: null, houses: null, thaiAstrologicalDay: null }, claims: unknownClaims, predictionClaims: [] },
};
writeJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.json', claimMap);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.md', `
# Candidate 0015 Claim / Evidence / Synthesis Map

Status: **PENDING OWNER CONTENT REVIEW — NOT RUNTIME**

Known predictions ${claims.length}: Tier A ${claimMap.counts.tierA}, Tier B ${claimMap.counts.tierB}, Tier C ${claimMap.counts.tierC}. Tier D reader claims, unsupported claims, methodological claims, duplicate semantic owners and prediction/advice conversions are all 0. Relationship, current health and 12-month sections are omitted as Tier D. Unknown has no prediction claims and remains fail-closed.
`);
writeJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0015_CLAIM_EVIDENCE_SYNTHESIS_MAP.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'fixture', 'contractRef', 'rulebookRef', 'dossierRef', 'counts', 'known', 'unknown'],
  properties: { version: { const: 1 }, known: { type: 'object', required: ['predictions', 'nonPrediction', 'omissions'] }, unknown: { type: 'object', required: ['fixture', 'claims', 'predictionClaims'] } },
});

const sectionText = (title, body) => `## ${title}\n\n${body}`;
const knownSections = [
  sectionText('ภาพรวมเส้นทางชีวิต', claims[0].fullReaderText),
  sectionText('คำทำนายอดีต', [claims[1], claims[2], claims[3]].map((x) => x.fullReaderText).join('\n\n')),
  sectionText('คำทำนายปัจจุบัน', claims[4].fullReaderText),
  sectionText('การงาน', claims[5].fullReaderText),
  sectionText('การเงิน', claims[6].fullReaderText),
  sectionText('โชคลาภและแรงสนับสนุน', claims[7].fullReaderText),
  sectionText('ช่วงชีวิตถัดไป', claims[8].fullReaderText),
  ...nonPrediction.map((x) => sectionText(x.section, x.fullReaderText)),
];
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_KNOWN.md', `
# Candidate 0015 — Known time

${knownSections.join('\n\n')}
`);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015_UNKNOWN.md', `
# Candidate 0015 — Unknown time

${unknownClaims.map((x) => sectionText(x.section, x.fullReaderText)).join('\n\n')}
`);
writeText('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0015.md', `
# Thai Report Predictive Narrative V2 — Candidate 0015

Status: **PENDING OWNER CONTENT REVIEW — EVIDENCE ONLY — NOT RUNTIME**

Known and Unknown reader copies are stored in the adjacent files. Relationship, current health and 12-month prediction are omitted because they are Tier D for this fixture. Candidate 0014 is rejected and is not a copy source.
`);

console.log(JSON.stringify({ status: 'PASS_GENERATED', dossierSourceRecords: sourceRecords.length, dossierCanonSignals: canonSignals.length, knownPredictionClaims: claims.length, unknownPredictionClaims: 0, omissions: omissions.length }, null, 2));
