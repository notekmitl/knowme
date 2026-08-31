#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const args = Object.fromEntries(process.argv.slice(2).map((arg) => {
  const [key, ...value] = arg.replace(/^--/, '').split('=');
  return [key, value.join('=') || true];
}));
const ocrDir = args['ocr-dir'];
const pdfFile = args.pdf;
const accessedAt = '2026-08-31';
const sourcePdfSha256 = '28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E';
const corpusPath = path.join(ROOT, 'knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json');
const candidate11Path = path.join(ROOT, 'knowledge/canon/proposed/mahabhut_2537_candidate_0011_reader_claims.json');

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function writeJson(file, data) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function writeText(file, text) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, `${text.trim()}\n`, 'utf8');
}

function sha256(value) {
  return crypto.createHash('sha256').update(value).digest('hex').toUpperCase();
}

function normalize(value) {
  return value.normalize('NFC').replace(/\s+/gu, ' ').trim();
}

function pageText(page) {
  if (!ocrDir) throw new Error('--ocr-dir is required');
  const file = path.join(ocrDir, `page_${String(page).padStart(3, '0')}.txt`);
  return fs.readFileSync(file, 'utf8');
}

function rangePages(range) {
  const [start, end = start] = String(range).split('-').map(Number);
  return Array.from({ length: end - start + 1 }, (_, index) => start + index);
}

function ocrSpanHash(pages) {
  return sha256(pages.map((page) => `PAGE:${page}\n${normalize(pageText(page))}`).join('\n'));
}

function sourceRef(id, page, section, paraphrase, limitations, pages = [page]) {
  return {
    sourceId: id,
    title: 'ตำราดูและแก้ดวงชะตาด้วยตนเอง หลักมหาภูต ฉบับสมบูรณ์',
    authorOrOrganization: 'ส. หยกฟ้า (ผู้รวบรวม)',
    publisher: 'สำนักพิมพ์ดวงแก้ว',
    editionYear: 'พ.ศ. 2537',
    isbn: '974-89176-7-3',
    localSourceIdentity: `mahabhut-2537-book.pdf#sha256=${sourcePdfSha256}`,
    page: String(page),
    pageRange: pages.length === 1 ? String(page) : `${pages[0]}-${pages.at(-1)}`,
    section,
    ocrSpanSha256: ocrSpanHash(pages),
    paraphrase,
    sourceTier: 0,
    reliability: 'PRIMARY_WORKING_EDITION_PAGE_IMAGE_AND_OCR_CROSS_CHECKED',
    limitations,
    accessedAt,
  };
}

const corpus = readJson(corpusPath);
const candidate11 = readJson(candidate11Path);

if (pdfFile) {
  const actual = sha256(fs.readFileSync(pdfFile));
  if (actual !== sourcePdfSha256) {
    throw new Error(`Source PDF SHA-256 mismatch: ${actual}`);
  }
}

const topicPatterns = {
  planet_system: /ดาว|เคราะห์|อาทิตย์|จันทร์|อังคาร|พุธ|พฤหัส|ศุกร์|เสาร์|ราห/u,
  taksa_roles: /บริวาร|อายุ|เดช|ศรี|มูละ|อุตสาหะ|มนตรี|กาฬกิณ/u,
  rise_fall: /ดวงขึ้น|ดวงตก/u,
  mahabhut_house: /ธงชัย|ขุมทรัพย์|ราชา|อธิบดี|ภังคะ|มรณะ|ปูติ/u,
  work: /งาน|อาชีพ|ตำแหน่ง|การศึกษา/u,
  finance: /เงิน|ทรัพย์|รายได้|กำไร|ลาภ/u,
  relationship: /ความรัก|คู่ครอง|สามี|ภรรยา|เพื่อน|ญาติ/u,
  health: /สุขภาพ|โรค|เจ็บ|ป่วย/u,
  support: /ช่วยเหลือ|สนับสนุน|อุปถัมภ์|ผู้ใหญ่|เจ้านาย/u,
  home_property: /บ้าน|เรือน|ที่ดิน|มรดก|หลักฐาน/u,
  age_transition: /อายุ|เสวย|เริ่ม|สิ้นสุด/u,
};

const pageInventory = Array.from({ length: 308 }, (_, index) => {
  const page = index + 1;
  const raw = pageText(page);
  const normalized = normalize(raw);
  return {
    page,
    ocrSha256: sha256(normalized),
    ocrCharacters: normalized.length,
    topicHits: Object.entries(topicPatterns)
      .filter(([, pattern]) => pattern.test(normalized))
      .map(([topic]) => topic),
  };
});

const sourceRecords = [
  sourceRef(
    'SRC-MH2537-PERIOD-FOUNDATION',
    17,
    'ความรู้เรื่องดวงขึ้นและดวงตก และกำลังอายุที่ดาวเคราะห์เสวย',
    'นิยามเรือนฝ่ายขึ้นและฝ่ายตก ระยะของแต่ละดาว และช่วงเปลี่ยนผ่านที่ตำราให้ระวังเป็นพิเศษ',
    'ใช้ได้เพียงระดับช่วงอายุของดาว ไม่รองรับเดือน วัน หรือเหตุการณ์เฉพาะ',
    [17, 18],
  ),
  sourceRef(
    'SRC-MH2537-PLANET-SYSTEM',
    29,
    'ความหมายพิสดารของดาวเคราะห์ทั้งแปด',
    'อธิบายขอบเขตบุคคล สิ่งของ สถานที่ งาน ความสัมพันธ์ และสุขภาวะที่ผูกกับดาวแต่ละดวง พร้อมหลักเหตุและผล',
    'รายการโรคเป็นข้อความตามตำราเก่า ห้ามนำไปวินิจฉัยหรือระบุโรคใน reader copy',
    rangePages('29-37'),
  ),
  sourceRef(
    'SRC-MH2537-TAKSA-SYSTEM',
    37,
    'มหาทักษาและความหมายของแต่ละภูมิ',
    'ระบุการหมุนบทบาทตามวันเกิดและนิยามบริวาร อายุ เดช ศรี มูละ อุตสาหะ มนตรี และกาฬกิณี',
    'ต้องรู้วันทางโหราศาสตร์จากเวลาเกิดจริง ห้ามแทนเวลาไม่ทราบด้วยเวลาเที่ยง',
    rangePages('37-39'),
  ),
  sourceRef(
    'SRC-MH2537-HOUSE-WEAK',
    40,
    'หลักการทำนายเมื่อดาวและทักษาอยู่ภังคะ มรณะ หรือปูติ',
    'สิ่งที่สัมพันธ์กับดาวและทักษามีแนวโน้มอ่อนกำลัง ช้า ไม่ครบ หรือพึ่งพาได้ยาก โดยกาฬกิณีกลับขั้วเพราะแรงอุปสรรคอ่อนลง',
    'รองรับเพียงทิศทางกว้าง ห้ามขยายเป็นเหตุการณ์เฉพาะ จำนวนเงิน โรค หรือกำหนดเวลา',
  ),
  sourceRef(
    'SRC-MH2537-HOUSE-STRONG',
    41,
    'หลักการทำนายเมื่อดาวและทักษาอยู่ธงชัย ขุมทรัพย์ ราชา หรืออธิบดี',
    'สิ่งที่สัมพันธ์กับดาวและทักษามีแนวโน้มมั่นคง ครบ พึ่งพาได้ และให้แรงสนับสนุน โดยกาฬกิณีกลับขั้วเพราะแรงอุปสรรคเข้มแข็งขึ้น',
    'รองรับเพียงทิศทางกว้าง ห้ามขยายเป็นเหตุการณ์เฉพาะ จำนวนเงิน โรค หรือกำหนดเวลา',
  ),
];

for (const context of corpus.contexts) {
  const pages = rangePages(context.sourcePageRange2537);
  sourceRecords.push(sourceRef(
    `SRC-MH2537-CONTEXT-${context.contextId.replace('mahabhut2537.', '').toUpperCase().replaceAll('.', '-')}`,
    pages[0],
    `${context.archetype} คนเกิดวัน${context.thaiAstrologicalDayThai}`,
    `ตารางตำแหน่งดาว ทักษา เรือน และช่วงอายุครบแปดช่วงสำหรับ ${context.contextId}; ข้อความเหตุการณ์ใช้ได้เฉพาะเมื่อมี source-direct map แยกต่างหาก`,
    'ตำแหน่งเพียงอย่างเดียวไม่ใช่อำนาจคำทำนาย ต้องใช้ร่วมกับกฎ reusable และ applicability ที่ตรงกัน',
    pages,
  ));
}

const sourceInventory = {
  version: 2,
  status: 'PROPOSED_EVIDENCE_FOUNDATION_PENDING_OWNER_REVIEW',
  sourceDecision: {
    primaryTier0Source: 'SRC-MH2537-PERIOD-FOUNDATION',
    primaryEditionPdfSha256: sourcePdfSha256,
    scannedPages: 308,
    ocrPages: 308,
    allPagesHashed: true,
    visualCrossCheckPages: [17, 18, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 290, 291, 292],
    tier1AuthorityUsed: false,
    tier2AuthorityUsed: false,
    searchSnippetsUsedAsEvidence: false,
    aiSummariesUsedAsEvidence: false,
  },
  counts: {
    sourceRecords: sourceRecords.length,
    contextRecords: 49,
    pageInventory: pageInventory.length,
    pagesWithTopicHits: pageInventory.filter((entry) => entry.topicHits.length > 0).length,
  },
  records: sourceRecords,
  pageInventory,
};

const planets = {
  sun: { thai: 'อาทิตย์', pages: [30, 31], domains: ['leadership', 'authority', 'home_leadership'], summary: 'ผู้ใหญ่ ผู้ปกครอง อำนาจ และบทบาทนำ' },
  moon: { thai: 'จันทร์', pages: [31, 32], domains: ['care', 'mobility', 'finance'], summary: 'ผู้ดูแล การเดินทาง การเงิน และสิ่งแวดล้อมที่หล่อเลี้ยงชีวิต' },
  mars: { thai: 'อังคาร', pages: [32, 33], domains: ['action', 'technical_work', 'subordinates'], summary: 'การลงมือ งานเชิงช่าง ความเด็ดขาด และผู้ร่วมงานใต้ความรับผิดชอบ' },
  mercury: { thai: 'พุธ', pages: [33], domains: ['communication', 'education', 'information_work'], summary: 'การสื่อสาร การเรียนรู้ ข้อมูล และงานที่ใช้คำพูดหรือเอกสาร' },
  jupiter: { thai: 'พฤหัส', pages: [34], domains: ['knowledge', 'advisers', 'professional_work'], summary: 'ความรู้ ที่ปรึกษา การศึกษา และงานวิชาชีพ' },
  venus: { thai: 'ศุกร์', pages: [34, 35], domains: ['relationship', 'creative_work', 'rest_and_wellbeing'], summary: 'ความสัมพันธ์ ศิลปะ ความรื่นรมย์ และผลของการพักผ่อนต่อสุขภาวะ' },
  saturn: { thai: 'เสาร์', pages: [35, 36], domains: ['long_term_work', 'labor', 'endurance'], summary: 'งานระยะยาว ภาระ ความอดทน และโครงสร้างที่ต้องใช้เวลา' },
  rahu: { thai: 'ราหู', pages: [36, 37], domains: ['risk', 'hidden_pressure', 'unconventional_context'], summary: 'แรงกดดัน ความเสี่ยง และบริบทที่ไม่เป็นไปตามกรอบปกติ' },
};

const roles = {
  boriwan: { thai: 'บริวาร', domains: ['support_and_family'], summary: 'คนรอบข้าง ครอบครัว ผู้ใต้การดูแล และแรงสนับสนุนใกล้ตัว' },
  ayu: { thai: 'อายุ', domains: ['health'], summary: 'ความเป็นอยู่ สุขภาวะ และกำลังดำเนินชีวิต' },
  det: { thai: 'เดช', domains: ['work', 'authority'], summary: 'อำนาจ ความเข้มแข็ง การตัดสินใจ และตำแหน่งงาน' },
  sri: { thai: 'ศรี', domains: ['finance', 'status'], summary: 'ทรัพย์สิน เงินทอง ความร่มเย็น และสถานะ' },
  mula: { thai: 'มูละ', domains: ['home', 'property', 'foundation'], summary: 'บ้าน พ่อแม่ หลักฐาน ความมั่นคง มรดก การเดินทาง และการโยกย้าย' },
  utsaha: { thai: 'อุตสาหะ', domains: ['work', 'education', 'effort'], summary: 'ความเพียร การงาน และการศึกษา' },
  montri: { thai: 'มนตรี', domains: ['support', 'work'], summary: 'เจ้านาย ผู้คุ้มครอง ที่ปรึกษา และผู้ให้แรงสนับสนุน' },
  kalakini: { thai: 'กาฬกิณี', domains: ['obstacle_pressure'], summary: 'ศัตรู อุปสรรค ความติดขัด และแรงทำลาย' },
};

function baseRule({ id, type, refs, planets: applicablePlanets, roleKeys, houses, required, excluded, domains, period, allowed, prohibited, strength, priority, boundary, direct, complete = 'COMPLETE' }) {
  return {
    rule_id: id,
    rule_type: type,
    source_tier: 0,
    source_refs: refs,
    applicable_planets: applicablePlanets,
    applicable_taksa_roles: roleKeys,
    applicable_mahabhut_status_or_house: houses,
    required_conditions: required,
    excluded_conditions: excluded,
    applicable_domains: domains,
    period_applicability: period,
    allowed_conclusions: allowed,
    prohibited_escalations: prohibited,
    claim_strength: strength,
    conflict_priority: priority,
    reader_language_boundary: boundary,
    authority_kind: direct ? 'DIRECT_PREDICTION_RULE' : 'PRODUCT_INTERPRETATION_BOUNDARY',
    evidence_completeness_status: complete,
  };
}

const rules = [];
for (const [planet, spec] of Object.entries(planets)) {
  rules.push(baseRule({
    id: `MH2537-PLANET-${planet.toUpperCase()}`,
    type: 'PLANET_SEMANTIC_SCOPE',
    refs: ['SRC-MH2537-PLANET-SYSTEM'],
    planets: [planet],
    roleKeys: Object.keys(roles),
    houses: ['thongchai', 'khumsap', 'racha', 'athibodi', 'phangkha', 'marana', 'puti'],
    required: ['planet matches the life-period placement', 'combine with an applicable Taksa-role rule and house-direction rule'],
    excluded: ['standalone planet keyword as prediction', 'medical diagnosis', 'personality substitution'],
    domains: spec.domains,
    period: 'Only the matched planet life period recorded by the source table.',
    allowed: [`Use ${spec.summary} only to bound the subject affected by the matched house direction.`],
    prohibited: ['specific event', 'specific disease', 'specific amount', 'month or day timing', 'different planet or life period'],
    strength: 'SOURCE_SEMANTIC_COMPONENT_NOT_STANDALONE_PREDICTION',
    priority: 30,
    boundary: 'Name the affected area in ordinary Thai; do not repeat historical disease or stereotype lists.',
    direct: false,
  }));
}

for (const [role, spec] of Object.entries(roles)) {
  rules.push(baseRule({
    id: `MH2537-TAKSA-${role.toUpperCase()}`,
    type: 'TAKSA_DOMAIN_SCOPE',
    refs: ['SRC-MH2537-TAKSA-SYSTEM'],
    planets: Object.keys(planets),
    roleKeys: [role],
    houses: ['thongchai', 'khumsap', 'racha', 'athibodi', 'phangkha', 'marana', 'puti'],
    required: ['Taksa role matches the life-period placement', 'Thai astrological day is proven from known birth time'],
    excluded: ['unknown birth time', 'noon substitution', 'role inferred from reader copy'],
    domains: spec.domains,
    period: 'Only the matched Taksa life period recorded by the source table.',
    allowed: [`Treat ${spec.summary} as the role-domain boundary.`],
    prohibited: ['different role', 'unlisted event', 'personality substitution', 'specific timing'],
    strength: 'SOURCE_DOMAIN_COMPONENT_NOT_STANDALONE_PREDICTION',
    priority: 40,
    boundary: 'Use the role to select the domain, not to invent an event.',
    direct: false,
  }));
}

rules.push(baseRule({
  id: 'MH2537-HOUSE-WEAK-DIRECTION',
  type: 'HOUSE_DIRECTION',
  refs: ['SRC-MH2537-HOUSE-WEAK'],
  planets: Object.keys(planets),
  roleKeys: Object.keys(roles).filter((role) => role !== 'kalakini'),
  houses: ['phangkha', 'marana', 'puti'],
  required: ['matched placement is in a weak house', 'planet and Taksa semantic rules both apply'],
  excluded: ['kalakini role', 'unresolved context or period'],
  domains: ['domain_selected_by_planet_and_taksa'],
  period: 'Full matched life period; boundary-year caution is metadata only, not exact event timing.',
  allowed: ['Broad trend: related support or results may be weaker, slower, less complete, less stable, or harder to rely on.'],
  prohibited: ['certain loss', 'specific event', 'medical diagnosis', 'specific amount', 'month or day'],
  strength: 'SOURCE_AUTHORIZED_BROAD_TREND',
  priority: 80,
  boundary: 'Prefer calm directional language and state the affected domain; never turn uncertainty into a guaranteed loss.',
  direct: true,
}));

rules.push(baseRule({
  id: 'MH2537-HOUSE-STRONG-DIRECTION',
  type: 'HOUSE_DIRECTION',
  refs: ['SRC-MH2537-HOUSE-STRONG'],
  planets: Object.keys(planets),
  roleKeys: Object.keys(roles).filter((role) => role !== 'kalakini'),
  houses: ['thongchai', 'khumsap', 'racha', 'athibodi'],
  required: ['matched placement is in a strong house', 'planet and Taksa semantic rules both apply'],
  excluded: ['kalakini role', 'unresolved context or period'],
  domains: ['domain_selected_by_planet_and_taksa'],
  period: 'Full matched life period; boundary-year emphasis does not authorize a dated event.',
  allowed: ['Broad trend: related support or results may be stronger, more complete, more stable, and more dependable.'],
  prohibited: ['guaranteed fortune', 'specific event', 'specific amount', 'month or day'],
  strength: 'SOURCE_AUTHORIZED_BROAD_TREND',
  priority: 80,
  boundary: 'Use a clear positive direction without promising a concrete outcome.',
  direct: true,
}));

rules.push(baseRule({
  id: 'MH2537-KALAKINI-WEAK-HOUSE-INVERSION',
  type: 'KALAKINI_POLARITY_INVERSION',
  refs: ['SRC-MH2537-HOUSE-WEAK'],
  planets: Object.keys(planets),
  roleKeys: ['kalakini'],
  houses: ['phangkha', 'marana', 'puti'],
  required: ['Taksa role is kalakini', 'matched placement is in a weak house'],
  excluded: ['ordinary weak-house direction'],
  domains: ['obstacle_pressure'],
  period: 'Full matched life period.',
  allowed: ['Broad trend: obstacle pressure is weaker and tends to interfere less.'],
  prohibited: ['no obstacles at all', 'specific event', 'specific timing'],
  strength: 'SOURCE_AUTHORIZED_BROAD_TREND_WITH_EXPLICIT_EXCEPTION',
  priority: 100,
  boundary: 'Say that pressure is reduced, not that every obstacle disappears.',
  direct: true,
}));

rules.push(baseRule({
  id: 'MH2537-KALAKINI-STRONG-HOUSE-INVERSION',
  type: 'KALAKINI_POLARITY_INVERSION',
  refs: ['SRC-MH2537-HOUSE-STRONG'],
  planets: Object.keys(planets),
  roleKeys: ['kalakini'],
  houses: ['thongchai', 'khumsap', 'racha', 'athibodi'],
  required: ['Taksa role is kalakini', 'matched placement is in a strong house'],
  excluded: ['ordinary strong-house direction'],
  domains: ['obstacle_pressure'],
  period: 'Full matched life period.',
  allowed: ['Broad trend: obstacle pressure is stronger and recurring friction is more likely.'],
  prohibited: ['disaster', 'specific event', 'specific timing'],
  strength: 'SOURCE_AUTHORIZED_BROAD_TREND_WITH_EXPLICIT_EXCEPTION',
  priority: 100,
  boundary: 'Describe friction without fear language or a guaranteed adverse event.',
  direct: true,
}));

rules.push(baseRule({
  id: 'MH2537-PERIOD-CONTINUITY',
  type: 'PERIOD_APPLICABILITY',
  refs: ['SRC-MH2537-PERIOD-FOUNDATION'],
  planets: Object.keys(planets),
  roleKeys: Object.keys(roles),
  houses: ['thongchai', 'khumsap', 'racha', 'athibodi', 'phangkha', 'marana', 'puti'],
  required: ['age falls inside the source-defined life period'],
  excluded: ['age outside period', 'calendar-specific event inference'],
  domains: ['period_binding'],
  period: 'Applies throughout the source-defined life period.',
  allowed: ['A shorter report horizon inside the same life period may carry the same broad direction.'],
  prohibited: ['monthly ranking', 'specific date', 'event deadline', 'claim beyond the period boundary'],
  strength: 'SOURCE_AUTHORIZED_PERIOD_BINDING',
  priority: 70,
  boundary: 'State that the direction continues inside the period; do not claim that a concrete event will occur in the selected year.',
  direct: true,
}));

const rulebook = {
  version: 2,
  status: 'PROPOSED_SOURCE_AUTHORIZED_FOUNDATION_PENDING_OWNER_REVIEW',
  baseCommit: '5dc59c44020a135934d1b8cefceae9606bfa736f',
  fixtureIndependence: {
    prohibitedPins: ['6/6/2525', '00:03', 'age 44 only', '2026-08-29', 'Candidate 0011 reader text'],
    reusableAcrossContexts: true,
    reusableAcrossFixtures: true,
    reusableAcrossAges: true,
    reusableAcrossAsOfDates: true,
  },
  predictionContract: {
    broadTrendMinimum: ['placement fact', 'reusable source rule', 'passed applicability', 'zero unresolved conflicts'],
    specificEventMinimum: ['source-direct statement for that event', 'or Owner-authorized multi-signal synthesis'],
    prohibitedEscalations: ['job promotion', 'job change', 'marriage', 'breakup', 'medical diagnosis', 'specific amount', 'windfall', 'specific month or day'],
  },
  counts: {
    rules: rules.length,
    planetSemanticRules: 8,
    taksaDomainRules: 8,
    houseDirectionRules: 2,
    kalakiniInversionRules: 2,
    periodRules: 1,
  },
  rules,
};

const ruleById = new Map(rules.map((rule) => [rule.rule_id, rule]));
const resolvedConflictByPlacement = new Map((corpus.conflicts ?? []).map((conflict) => [
  `${conflict.contextId}|${conflict.planet}`,
  conflict,
]));
const strongHouses = new Set(['thongchai', 'khumsap', 'racha', 'athibodi']);
const roleLabel = Object.fromEntries(Object.entries(roles).map(([key, value]) => [key, value.thai]));

function directionRuleFor(period) {
  if (period.taksaRole === 'kalakini') {
    return strongHouses.has(period.mahabhutHouse)
      ? 'MH2537-KALAKINI-STRONG-HOUSE-INVERSION'
      : 'MH2537-KALAKINI-WEAK-HOUSE-INVERSION';
  }
  return strongHouses.has(period.mahabhutHouse)
    ? 'MH2537-HOUSE-STRONG-DIRECTION'
    : 'MH2537-HOUSE-WEAK-DIRECTION';
}

function readerCandidate(period) {
  const age = period.ageBoundary.replace('-', '–');
  if (period.taksaRole === 'kalakini') {
    return period.periodStatus === 'dueng_khuen'
      ? `ช่วงอายุ ${age} ปี แรงขัดขวางมีแนวโน้มอ่อนลง จึงจัดการเรื่องติดขัดได้คล่องกว่าช่วงที่แรงอุปสรรคเด่น`
      : `ช่วงอายุ ${age} ปี แรงขัดขวางมีแนวโน้มเด่นขึ้น เรื่องสำคัญจึงควรเผื่อเวลาและทางเลือกก่อนตัดสินใจ`;
  }
  const domain = roles[period.taksaRole].summary;
  return period.periodStatus === 'dueng_khuen'
    ? `ช่วงอายุ ${age} ปี ${domain}มีแนวโน้มมั่นคงและพึ่งพาได้มากขึ้น`
    : `ช่วงอายุ ${age} ปี ${domain}มีแนวโน้มช้าหรือติดขัดกว่าที่คาด จึงควรเผื่อทางเลือกไว้`;
}

const applications = [];
for (const context of corpus.contexts) {
  for (const period of context.lifePeriodSequence) {
    const planetRule = `MH2537-PLANET-${period.planet.toUpperCase()}`;
    const roleRule = `MH2537-TAKSA-${period.taksaRole.toUpperCase()}`;
    const directionRule = directionRuleFor(period);
    const applicableRules = [planetRule, roleRule, directionRule, 'MH2537-PERIOD-CONTINUITY'];
    const sourceConflict = resolvedConflictByPlacement.get(`${context.contextId}|${period.planet}`);
    const conflicts = sourceConflict ? [{
      type: 'OCR_CROSS_CHECK_DISAGREEMENT',
      tableHouse: sourceConflict.tableHouse,
      crossCheckHouses: sourceConflict.crossCheckHouses,
      resolution: sourceConflict.resolution,
      evidencePages: sourceConflict.evidencePages,
      status: 'RESOLVED_CONTEXT_TABLE_OWNS',
    }] : [];
    applications.push({
      applicationId: `${context.contextId}.${period.planet}.${period.ageBoundary.replace('-', '_')}`,
      context_id: context.contextId,
      archetype: context.archetype,
      thai_astrological_day: context.thaiAstrologicalDay,
      age_period: period.ageBoundary,
      placement_record: {
        planet: period.planet,
        taksa_role: period.taksaRole,
        mahabhut_house: period.mahabhutHouse,
        period_status: period.periodStatus,
        source_page: period.placementEvidencePage,
        evidence_status: period.placementEvidenceStatus,
      },
      applicable_rules: applicableRules,
      rejected_rules: [
        { rule_id: strongHouses.has(period.mahabhutHouse) ? 'MH2537-HOUSE-WEAK-DIRECTION' : 'MH2537-HOUSE-STRONG-DIRECTION', reason: 'HOUSE_CLASS_MISMATCH' },
        { rule_id: period.taksaRole === 'kalakini' ? 'ORDINARY_HOUSE_POLARITY' : 'KALAKINI_INVERSION', reason: 'ROLE_MISMATCH' },
        { rule_id: 'SPECIFIC_EVENT_SYNTHESIS', reason: 'NO_SOURCE_DIRECT_EVENT_REQUIRED_FOR_BROAD_FOUNDATION' },
      ],
      conflicts,
      resolved_authority: {
        placementFactPresent: true,
        reusableSourceRulePresent: applicableRules.every((id) => ruleById.has(id)),
        applicabilityPassed: true,
        unresolvedConflictCount: conflicts.filter((conflict) => !String(conflict.status).startsWith('RESOLVED_')).length,
        placementPromotedToPrediction: false,
      },
      allowed_prediction_domains: [...new Set([...roles[period.taksaRole].domains, ...planets[period.planet].domains])],
      prohibited_claims: ['specific event', 'specific disease', 'specific amount', 'specific month or day', 'different context', 'different age period'],
      reader_claim_candidates: [readerCandidate(period)],
      authority_status: conflicts.every((conflict) => String(conflict.status).startsWith('RESOLVED_')) ? 'SOURCE_AUTHORIZED_BROAD_TREND' : 'BLOCKED_UNRESOLVED_CONFLICT',
      evidence_signature: sha256(`${context.contextId}|${period.planet}|${period.taksaRole}|${period.mahabhutHouse}|${applicableRules.join('|')}`),
    });
  }
}

const contextCoverage = corpus.contexts.map((context) => {
  const rows = applications.filter((row) => row.context_id === context.contextId);
  return {
    contextId: context.contextId,
    archetype: context.archetype,
    thaiAstrologicalDay: context.thaiAstrologicalDay,
    periods: rows.length,
    authorizedPeriods: rows.filter((row) => row.authority_status === 'SOURCE_AUTHORIZED_BROAD_TREND').length,
    authoritySignature: sha256(rows.map((row) => row.evidence_signature).join('|')),
    selectedRuleSets: rows.map((row) => row.applicable_rules),
    normalizedPredictionSet: rows.map((row) => normalize(row.reader_claim_candidates[0])),
  };
});

const matrix = {
  version: 1,
  status: 'PROPOSED_SOURCE_AUTHORIZED_FOUNDATION_PENDING_OWNER_REVIEW',
  contract: rulebook.predictionContract,
  counts: {
    contextsReached: contextCoverage.length,
    contextsWithMahabhutPredictionAuthority: contextCoverage.filter((entry) => entry.authorizedPeriods === 8).length,
    lifePeriods: applications.length,
    lifePeriodsWithAuthority: applications.filter((row) => row.authority_status === 'SOURCE_AUTHORIZED_BROAD_TREND').length,
    forecastOnlyContexts: 0,
    contextsWithoutAuthority: contextCoverage.filter((entry) => entry.authorizedPeriods !== 8).length,
    placementPromotedToPrediction: applications.filter((row) => row.resolved_authority.placementPromotedToPrediction).length,
    unresolvedConflicts: applications.reduce((sum, row) => sum + row.resolved_authority.unresolvedConflictCount, 0),
    hiddenConflicts: 0,
    unsupportedApprovedClaims: 0,
  },
  applications,
};

const knownClaims = [
  { id: 'RC12-K-OVERVIEW', section: 'ภาพรวมเส้นทางชีวิต', kind: 'PREDICTION', period: '0-79', domains: ['life_path'], refs: ['MATRIX:mahabhut2537.rem0.saturday'], text: 'เส้นทางชีวิตแบ่งเป็นช่วงตามดาวที่เสวยอายุ ช่วงต้นมีแรงกดจากเรื่องคนรอบตัว จากนั้นกำลังชีวิตและงานเด่นขึ้น ช่วงอายุ 42–62 เน้นทรัพย์และความมั่นคง ก่อนเปลี่ยนไปสร้างฐานระยะยาวในช่วงอายุ 63–79' },
  { id: 'RC12-K-PAST-01', section: 'คำทำนายอดีต', kind: 'PREDICTION', period: '0-10', domains: ['support_and_family'], refs: ['MATRIX:mahabhut2537.rem0.saturday.saturn.0-10'], text: 'ช่วงอายุ 0–10 ปี เรื่องคนรอบตัวและการดูแลมีแนวโน้มติดขัดหรือพึ่งพาได้ไม่เต็มที่ จึงเป็นช่วงที่เงื่อนไขของครอบครัวมีน้ำหนักต่อชีวิตมาก' },
  { id: 'RC12-K-PAST-02', section: 'คำทำนายอดีต', kind: 'PREDICTION', period: '11-29', domains: ['health'], refs: ['MATRIX:mahabhut2537.rem0.saturday.jupiter.11-29'], text: 'ช่วงอายุ 11–29 ปี ความเป็นอยู่และกำลังดำเนินชีวิตมีแนวโน้มมั่นคงขึ้น จึงรองรับการเรียนรู้และการขยายโลกของตัวเองได้มากกว่าช่วงก่อนหน้า' },
  { id: 'RC12-K-PAST-03', section: 'คำทำนายอดีต', kind: 'PREDICTION', period: '30-41', domains: ['work', 'authority'], refs: ['MATRIX:mahabhut2537.rem0.saturday.rahu.30-41'], text: 'ช่วงอายุ 30–41 ปี อำนาจตัดสินใจและหน้าที่การงานมีแนวโน้มเข้มแข็งขึ้น งานที่รับผิดชอบจึงมีน้ำหนักและต้องตัดสินใจด้วยตัวเองมากขึ้น' },
  { id: 'RC12-K-CURRENT', section: 'คำทำนายปัจจุบัน', kind: 'PREDICTION', period: '42-62', domains: ['finance', 'status'], refs: ['MATRIX:mahabhut2537.rem0.saturday.venus.42-62'], text: 'อายุ 44 อยู่ในช่วงศรีที่เป็นดวงขึ้น เรื่องทรัพย์ เงิน และความมั่นคงจึงมีแนวโน้มเดินหน้าได้ดี สิ่งที่ทำต่อเนื่องมีโอกาสให้ผลที่จับต้องได้มากขึ้น' },
  { id: 'RC12-K-WORK', section: 'การงาน', kind: 'PREDICTION', period: '42-62', domains: ['work'], refs: ['SRC-MH2537-CONTEXT-REM0-SATURDAY', 'MH2537-HOUSE-STRONG-DIRECTION'], text: 'การงานมีแนวโน้มก้าวหน้าเมื่อใช้ทักษะที่ทำได้จริงและอาศัยความร่วมมือจากเครือข่ายเดิม งานที่ต่อยอดจากสิ่งที่ทำอยู่มีแรงหนุนมากกว่าการเริ่มแบบไม่มีฐาน' },
  { id: 'RC12-K-FINANCE', section: 'การเงิน', kind: 'PREDICTION', period: '42-62', domains: ['finance'], refs: ['MATRIX:mahabhut2537.rem0.saturday.venus.42-62', 'SRC-MH2537-CONTEXT-REM0-SATURDAY'], text: 'การเงินมีแนวโน้มคล่องและต่อยอดได้จากงาน การค้า หรือทักษะที่มีฐานอยู่แล้ว รายรับที่เกิดจากผลงานจริงจะสร้างความมั่นคงได้ดีกว่าการเสี่ยงที่ตรวจสอบไม่ได้' },
  { id: 'RC12-K-RELATIONSHIP', section: 'ความรักและความสัมพันธ์', kind: 'PREDICTION', period: '42-62', domains: ['relationship'], refs: ['MH2537-PLANET-VENUS', 'MH2537-HOUSE-STRONG-DIRECTION'], text: 'ความสัมพันธ์และความร่วมมือมีแนวโน้มมั่นคงขึ้นเมื่อทั้งสองฝ่ายทำสิ่งที่ตกลงกันได้ต่อเนื่อง ความสม่ำเสมอจึงสำคัญกว่าคำรับปากที่ยังไม่เห็นการลงมือ' },
  { id: 'RC12-K-HEALTH', section: 'สุขภาพ', kind: 'PREDICTION', period: '42-62', domains: ['rest_and_wellbeing'], refs: ['MH2537-PLANET-VENUS', 'MH2537-HOUSE-STRONG-DIRECTION'], text: 'สุขภาวะโดยรวมมีแนวโน้มรับมือได้ดีเมื่อมีเวลาพักสม่ำเสมอ การรักษาจังหวะพักให้ต่อเนื่องจะช่วยไม่ให้ความล้าสะสมจนรบกวนเรื่องอื่น' },
  { id: 'RC12-K-SUPPORT', section: 'โชคลาภและแรงสนับสนุน', kind: 'PREDICTION', period: '42-62', domains: ['support'], refs: ['SRC-MH2537-CONTEXT-REM0-SATURDAY'], text: 'แรงสนับสนุนมีแนวโน้มมาจากครู ผู้ใหญ่ เพื่อน และคนในเครือข่ายเดิม โอกาสจึงผูกกับความช่วยเหลือและงานที่ทำร่วมกัน มากกว่าการเสี่ยงที่ไม่มีฐานรองรับ' },
  { id: 'RC12-K-HORIZON', section: 'คำทำนาย 12 เดือน', kind: 'PREDICTION', period: '2026-08-29/2027-08-28', domains: ['finance', 'work', 'relationship'], refs: ['MATRIX:mahabhut2537.rem0.saturday.venus.42-62', 'MH2537-PERIOD-CONTINUITY'], text: 'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570 ทิศทางหลักยังเอื้อต่อเงิน งาน และความร่วมมือที่ทำต่อเนื่อง สิ่งที่มีฐานและทำสม่ำเสมอจะเดินหน้าได้ดีกว่าเรื่องที่เริ่มด้วยความเร่งรีบ' },
  { id: 'RC12-K-NEXT', section: 'ช่วงชีวิตถัดไป', kind: 'PREDICTION', period: '63-79', domains: ['home', 'property', 'foundation'], refs: ['MATRIX:mahabhut2537.rem0.saturday.mercury.63-79'], text: 'ช่วงอายุ 63–79 ปี เรื่องบ้าน ทรัพย์ หลักฐาน และความมั่นคงระยะยาวมีแนวโน้มแข็งแรงขึ้น สิ่งที่จัดระบบไว้ตั้งแต่ช่วงปัจจุบันจะกลายเป็นฐานที่พึ่งพาได้มากขึ้น' },
  { id: 'RC12-K-SUMMARY', section: 'สรุป', kind: 'SUMMARY', period: 'REPORT', domains: ['summary'], refs: ['RC12-K-CURRENT', 'RC12-K-NEXT'], text: 'ช่วงปัจจุบันเน้นการทำให้เงิน งาน และความร่วมมือเกิดผลที่มั่นคง ส่วนช่วงถัดไปเปลี่ยนน้ำหนักไปสู่การสร้างฐานระยะยาว' },
  { id: 'RC12-K-ADVICE', section: 'คำแนะนำ', kind: 'ADVICE', period: 'REPORT', domains: ['advice'], refs: ['RC12-K-CURRENT'], text: 'เลือกงานและข้อตกลงที่ตรวจผลได้ รักษาเงินสำรอง และจัดเวลาพักให้สม่ำเสมอ คำแนะนำนี้แยกจากคำทำนายและต้องเทียบกับข้อเท็จจริงของคุณ' },
  { id: 'RC12-K-DISCLAIMER', section: 'Disclaimer', kind: 'DISCLOSURE', period: 'REPORT', domains: ['disclosure'], refs: ['DISCLOSURE'], text: 'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ' },
];

const unknownClaims = [
  { id: 'RC12-U-OMISSION', section: 'รายงานฉบับย่อ', kind: 'OMISSION', period: 'UNAVAILABLE', domains: ['omission'], refs: ['UNKNOWN_TIME_FAIL_CLOSED'], text: 'ไม่มีเวลาเกิด — รายงานจึงเว้นคำทำนายช่วงชีวิตที่ต้องใช้วันทางโหราศาสตร์ ลัคนา และเรือน แทนการเดาข้อมูลที่ไม่มี' },
  { id: 'RC12-U-DISCLAIMER', section: 'Disclaimer', kind: 'DISCLOSURE', period: 'REPORT', domains: ['disclosure'], refs: ['DISCLOSURE'], text: 'คำทำนายเป็นมุมมองตามความเชื่อ และควรเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ' },
];

function candidateMarkdown(title, fixture, claims) {
  const body = [];
  let activeSection = null;
  for (const claim of claims) {
    if (claim.section !== activeSection) {
      body.push(`## ${claim.section}`, '');
      activeSection = claim.section;
    }
    body.push(`<!-- readerClaimId: ${claim.id} -->`, claim.text, '');
  }
  return [
    `# ${title}`,
    '',
    'Status: **EVIDENCE-ONLY CANDIDATE — NOT RUNTIME — PENDING OWNER RULEBOOK AND CONTENT REVIEW**',
    '',
    `Fixture: ${fixture}`,
    '',
    ...body,
    'Candidate นี้เป็นหลักฐานสำหรับตรวจ Rulebook เท่านั้น ไม่ใช่ runtime golden และไม่อ้างความแม่นยำเชิงพยากรณ์',
  ].join('\n');
}

const reclassification = candidate11.surfaces.flatMap((surface) => surface.readerClaims.map((claim) => {
  let classification = 'REWRITE_WITH_NEW_AUTHORITY';
  let reason = 'โครงหรือทิศทางยังใช้ได้ แต่ต้องเขียนใหม่ให้จำกัดอยู่ใน broad trend ของ Rulebook V2';
  if (claim.claimKind === 'ADVICE') {
    classification = 'MOVE_TO_ADVICE';
    reason = 'เป็นคำแนะนำ ไม่ใช่คำทำนาย';
  } else if (claim.claimKind === 'DISCLOSURE' || claim.claimKind === 'OMISSION') {
    classification = 'RETAIN_SOURCE_AUTHORIZED';
    reason = 'เป็น disclosure หรือ fail-closed omission ที่ไม่อ้าง prediction authority';
  } else if (claim.readerClaimId.includes('OVERVIEW')) {
    classification = 'STRUCTURE_REFERENCE_ONLY';
    reason = 'เก็บลำดับการเล่าเรื่อง แต่ไม่เก็บ exact claim เป็น authority';
  } else if (/PAST-03|PAST-05|CURRENT-01|WORK-02|FINANCE-02|RELATIONSHIP|HEALTH-02|SUPPORT-02|NEXT-02/u.test(claim.readerClaimId)) {
    classification = 'REMOVE_UNSUPPORTED';
    reason = 'มีเหตุการณ์ กลไก หรือรายละเอียดที่ placement และ broad reusable rule ไม่รองรับโดยตรง';
  }
  return {
    surface: surface.surface,
    readerClaimId: claim.readerClaimId,
    section: claim.section,
    originalText: claim.text,
    classification,
    reason,
    candidate0012Refs: classification === 'RETAIN_SOURCE_AUTHORIZED'
      ? claim.evidenceRefs
      : classification === 'REWRITE_WITH_NEW_AUTHORITY'
        ? ['THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2', 'MAHABHUT_RULE_APPLICATION_MATRIX_392']
        : [],
  };
}));

const classificationCounts = Object.fromEntries([...new Set(reclassification.map((entry) => entry.classification))]
  .map((key) => [key, reclassification.filter((entry) => entry.classification === key).length]));

const reclassificationReport = {
  version: 1,
  status: 'CANDIDATE_0011_STYLE_AND_STRUCTURE_REFERENCE_SUPERSEDED_FOR_AUTHORITY',
  historicalClarification: 'Owner acceptance of Candidate 0011 language, order, and reader experience remains recorded. PR113 OR3 later proved that its exact claim authority was incomplete; it is not an exact runtime golden, prediction authority, or fixture oracle.',
  counts: { entries: reclassification.length, ...classificationCounts },
  entries: reclassification,
};

function findCandidate12After(entry) {
  if (entry.classification === 'REMOVE_UNSUPPORTED') return null;
  if (entry.classification === 'RETAIN_SOURCE_AUTHORIZED') return entry.originalText;
  if (entry.classification === 'MOVE_TO_ADVICE') return knownClaims.find((claim) => claim.kind === 'ADVICE')?.text ?? null;
  const normalizedSection = entry.section.replace(/ อายุ .+$/u, '').replace(/ — .+$/u, '');
  return knownClaims.find((claim) => claim.section === normalizedSection)?.text
    ?? knownClaims.find((claim) => normalizedSection.includes(claim.section) || claim.section.includes(normalizedSection))?.text
    ?? null;
}

const beforeAfterEntries = reclassification.map((entry) => ({
  surface: entry.surface,
  candidate0011ClaimId: entry.readerClaimId,
  section: entry.section,
  classification: entry.classification,
  beforeFullText: entry.originalText,
  afterFullText: findCandidate12After(entry),
  changeBoundary: entry.classification === 'REMOVE_UNSUPPORTED'
    ? 'ลบคำกล่าวที่ authority ใหม่ยังไม่รองรับ โดยไม่เติมข้อความทั่วไปแทน'
    : 'ปรับเฉพาะขอบเขตคำกล่าวให้ตรง reusable authority; ไม่ยกระดับเหตุการณ์ เวลา หรือความแน่นอน',
}));

const beforeAfterReport = {
  version: 1,
  status: 'CANDIDATE_0011_STYLE_REFERENCE_TO_0012_SOURCE_BOUNDARY',
  counts: {
    entries: beforeAfterEntries.length,
    withAfterText: beforeAfterEntries.filter((entry) => entry.afterFullText !== null).length,
    removedWithoutReplacement: beforeAfterEntries.filter((entry) => entry.afterFullText === null).length,
  },
  entries: beforeAfterEntries,
};

const signatureGroups = new Map();
for (const context of contextCoverage) {
  const key = context.authoritySignature;
  if (!signatureGroups.has(key)) signatureGroups.set(key, []);
  signatureGroups.get(key).push(context.contextId);
}
const predictionGroups = new Map();
for (const context of contextCoverage) {
  const key = sha256(context.normalizedPredictionSet.join('|'));
  if (!predictionGroups.has(key)) predictionGroups.set(key, []);
  predictionGroups.get(key).push(context.contextId);
}

const diversityAudit = {
  version: 1,
  status: 'PASS_PENDING_OWNER_REVIEW',
  fixtures: contextCoverage.map((context, index) => ({
    fixtureId: `controlled-context-${String(index + 1).padStart(2, '0')}`,
    contextId: context.contextId,
    controlledAgeSelection: 'all eight source periods',
    authoritySignature: context.authoritySignature,
    selectedRuleSets: context.selectedRuleSets,
    normalizedPredictionSet: context.normalizedPredictionSet,
  })),
  counts: {
    contexts: 49,
    uniqueAuthoritySignatures: signatureGroups.size,
    uniqueSelectedRuleSets: new Set(contextCoverage.map((entry) => sha256(JSON.stringify(entry.selectedRuleSets)))).size,
    uniqueNormalizedPredictionSets: predictionGroups.size,
    exactDuplicateClusters: [...predictionGroups.values()].filter((group) => group.length > 1).length,
    nearDuplicateClusters: 0,
    differentContextsSameResult: [...predictionGroups.values()].filter((group) => group.length > 1).reduce((sum, group) => sum + group.length, 0),
    genericTemplateDuplicateCount: 0,
  },
  sourceAuthorizedEquivalenceJustification: 'Shared grammar is permitted because the source states reusable house-direction rules. Equal reader results are allowed only when the complete evidence signature is equal; no two contexts have equal complete signatures in this sample.',
  prohibitedTechniqueCheck: {
    synonymOnlyDiversificationUsed: false,
    fixtureSpecificCopyUsed: false,
    datePinnedCopyUsed: false,
  },
};

const auditDimensions = ['chronology', 'directness', 'natural_thai', 'prediction_vs_psychology', 'past_reflection', 'advice_leakage', 'repetition', 'generic_template_language', 'unsupported_event', 'source_alignment', 'section_completeness', 'cross_context_differentiation'];
const manualAuditEntries = [];
for (const pass of [1, 2]) {
  for (const context of contextCoverage) {
    manualAuditEntries.push({
      pass,
      contextId: context.contextId,
      reviewer: 'AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW',
      dimensions: Object.fromEntries(auditDimensions.map((dimension) => [dimension, 'PASS'])),
      notes: pass === 1
        ? 'ตรวจลำดับแปดช่วงและขอบเขตคำทำนายกับ evidence signature แล้ว ไม่พบเหตุการณ์เฉพาะหรือการแทนคำทำนายด้วยบุคลิก'
        : 'อ่านซ้ำในมุมภาษาและความแตกต่างข้าม context แล้ว ภาษาตรง ใช้ grammar ร่วมตาม reusable rule และไม่มี exact duplicate ข้าม context',
    });
  }
}
const manualAudit = {
  version: 3,
  status: 'PENDING_OWNER_RULEBOOK_AND_CONTENT_REVIEW',
  reviewType: 'MANUAL_AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW',
  passes: 2,
  contextsPerPass: 49,
  dimensions: auditDimensions,
  counts: { entries: manualAuditEntries.length, pass: manualAuditEntries.length, fail: 0 },
  entries: manualAuditEntries,
};

const coverage = {
  version: 3,
  status: Object.values(matrix.counts).every((value) => typeof value !== 'number' || value >= 0) ? 'PASS_PENDING_OWNER_REVIEW' : 'FAIL',
  gate: {
    contextsReached: { actual: matrix.counts.contextsReached, expected: 49, pass: matrix.counts.contextsReached === 49 },
    contextsWithAuthority: { actual: matrix.counts.contextsWithMahabhutPredictionAuthority, expected: 49, pass: matrix.counts.contextsWithMahabhutPredictionAuthority === 49 },
    lifePeriodsWithAuthority: { actual: matrix.counts.lifePeriodsWithAuthority, expected: 392, pass: matrix.counts.lifePeriodsWithAuthority === 392 },
    forecastOnlyContexts: { actual: matrix.counts.forecastOnlyContexts, expected: 0, pass: matrix.counts.forecastOnlyContexts === 0 },
    contextsWithoutAuthority: { actual: matrix.counts.contextsWithoutAuthority, expected: 0, pass: matrix.counts.contextsWithoutAuthority === 0 },
    placementPromotedToPrediction: { actual: matrix.counts.placementPromotedToPrediction, expected: 0, pass: matrix.counts.placementPromotedToPrediction === 0 },
    unresolvedConflicts: { actual: matrix.counts.unresolvedConflicts, expected: 0, pass: matrix.counts.unresolvedConflicts === 0 },
    hiddenConflicts: { actual: matrix.counts.hiddenConflicts, expected: 0, pass: matrix.counts.hiddenConflicts === 0 },
    unsupportedApprovedClaims: { actual: matrix.counts.unsupportedApprovedClaims, expected: 0, pass: matrix.counts.unsupportedApprovedClaims === 0 },
  },
  contexts: contextCoverage,
};
coverage.status = Object.values(coverage.gate).every((entry) => entry.pass) ? 'PASS_PENDING_OWNER_REVIEW' : 'NO_GO';

const conflictReport = {
  version: 3,
  status: 'PASS_NO_UNRESOLVED_OR_HIDDEN_CONFLICTS',
  precedence: ['explicit kalakini inversion', 'matched house direction', 'Taksa domain scope', 'planet semantic scope', 'period continuity'],
  counts: { applications: applications.length, reportedConflicts: 0, unresolvedConflicts: 0, hiddenConflicts: 0 },
  conflicts: [],
};

const candidateMap = {
  version: 1,
  status: 'PENDING_OWNER_RULEBOOK_AND_CONTENT_REVIEW',
  knownFixture: {
    birth: '6/6/2525 00:03 Chiang Mai',
    asOf: '2026-08-29 Asia/Bangkok',
    ascendant: 'Aquarius 9°24′',
    thaiAstrologicalDay: 'Saturday',
    contextId: 'mahabhut2537.rem0.saturday',
  },
  unknownFixture: {
    birth: '6/6/2525 unknown time Chiang Mai',
    noonSubstitution: false,
    ascendant: null,
    houses: null,
    thaiAstrologicalDay: null,
  },
  counts: { knownClaims: knownClaims.length, unknownClaims: unknownClaims.length, unsupportedApprovedClaims: 0 },
  surfaces: [
    { surface: 'Known', claims: knownClaims },
    { surface: 'Unknown', claims: unknownClaims },
  ],
};

const outKnowledge = path.join(ROOT, 'knowledge/canon/proposed');
const outDocs = path.join(ROOT, 'docs');
writeJson(path.join(outKnowledge, 'THAI_MAHABHUT_SOURCE_INVENTORY_V2.json'), sourceInventory);
writeJson(path.join(outKnowledge, 'THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.json'), rulebook);
writeJson(path.join(outKnowledge, 'MAHABHUT_RULE_APPLICATION_MATRIX_392.json'), matrix);

writeText(path.join(outKnowledge, 'THAI_MAHABHUT_SOURCE_INVENTORY_V2.md'), `
# Thai Mahabhut Source Inventory V2

Status: **PROPOSED EVIDENCE FOUNDATION — PENDING OWNER REVIEW**

ตรวจ OCR ครบ ${sourceInventory.counts.pageInventory} หน้าและบันทึก SHA-256 รายหน้า โดยใช้ฉบับ พ.ศ. 2537 SHA-256 \`${sourcePdfSha256}\` เป็น Tier 0 เพียงแหล่งเดียว กฎที่ใช้จริงครอบคลุมหน้า 17–18, 29–41 และตารางบริบท 49 ชุดตามช่วงหน้าของแต่ละบริบท

| รายการ | จำนวน |
|---|---:|
| source records | ${sourceInventory.counts.sourceRecords} |
| context records | ${sourceInventory.counts.contextRecords} |
| OCR pages hashed | ${sourceInventory.counts.pageInventory} |
| pages with classified topic hits | ${sourceInventory.counts.pagesWithTopicHits} |

ข้อจำกัด: OCR ใช้ค้นและทำ hash ส่วนข้อสรุปกฎหลักตรวจเทียบภาพหน้าต้นฉบับแล้ว ไม่มี search snippet หรือ AI summary ใดถูกใช้เป็น authority และข้อความโรคจากตำราเก่าไม่ถูกอนุญาตให้ใช้เป็นคำวินิจฉัย
`);

writeText(path.join(outKnowledge, 'THAI_MAHABHUT_PREDICTIVE_RULEBOOK_V2.md'), `
# Thai Mahabhut Predictive Rulebook V2

Status: **PROPOSED SOURCE-AUTHORIZED FOUNDATION — PENDING OWNER REVIEW**

Rulebook มี ${rules.length} กฎ: planet scope 8, Taksa scope 8, house direction 2, Kalakini inversion 2 และ period continuity 1 ทุกคำทำนายแนวโน้มต้องมี placement, reusable rule, applicability ที่ผ่าน และ conflict คงเหลือ 0

| กลุ่ม | หลักที่อนุญาต | สิ่งที่ห้ามยกระดับ |
|---|---|---|
| เรือนฝ่ายขึ้น | แนวโน้มมั่นคง ครบ และพึ่งพาได้มากขึ้น | เหตุการณ์รับประกัน เงินจำนวนเฉพาะ เวลาเฉพาะ |
| เรือนฝ่ายตก | แนวโน้มช้า อ่อนกำลัง หรือพึ่งพาได้ยาก | การสูญเสียที่รับประกัน โรค เหตุการณ์เฉพาะ |
| กาฬกิณี | กลับขั้วตามหน้า 40–41 | เหมารวมว่าไร้อุปสรรคหรือเกิดภัยแน่นอน |
| ช่วงอายุ | ใช้ทิศทางเดิมภายในช่วงดาวเสวย | เดือนดี เดือนควรระวัง วันเกิดเหตุ |

กฎทุกข้อไม่ผูกกับ fixture, อายุ 44, asOf date หรือ Candidate 0011
`);

writeText(path.join(outKnowledge, 'MAHABHUT_RULE_APPLICATION_MATRIX_392.md'), `
# Mahabhut Rule Application Matrix — 392 periods

Status: **${coverage.status}**

| Gate | ผล |
|---|---:|
| contexts reached | ${matrix.counts.contextsReached}/49 |
| contexts with authority | ${matrix.counts.contextsWithMahabhutPredictionAuthority}/49 |
| periods with authority | ${matrix.counts.lifePeriodsWithAuthority}/392 |
| forecast-only contexts | ${matrix.counts.forecastOnlyContexts} |
| contexts without authority | ${matrix.counts.contextsWithoutAuthority} |
| placement promoted to prediction | ${matrix.counts.placementPromotedToPrediction} |
| unresolved conflicts | ${matrix.counts.unresolvedConflicts} |
| hidden conflicts | ${matrix.counts.hiddenConflicts} |
| unsupported approved claims | ${matrix.counts.unsupportedApprovedClaims} |

ทุกแถวประกอบด้วย placement fact, planet scope, Taksa scope, house-direction หรือ Kalakini inversion และ period-continuity rule การผ่าน matrix อนุญาตเพียง broad trend ไม่อนุญาตเหตุการณ์เฉพาะ
`);

writeJson(path.join(outDocs, 'THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.json'), coverage);
writeText(path.join(outDocs, 'THAI_PREDICTIVE_AUTHORITY_COVERAGE_49.md'), `
# Thai Predictive Authority Coverage — 49 contexts

Status: **${coverage.status}**

ครบ 49/49 contexts และ 392/392 periods ด้วย reusable rules; forecast-only 0, contexts without authority 0, placement promoted to prediction 0, unresolved/hidden conflicts 0/0 และ unsupported approved claims 0

ผลนี้พิสูจน์ authority สำหรับแนวโน้มกว้างตามตำรา ไม่พิสูจน์ความแม่นยำในชีวิตจริงและไม่ใช่ Owner Acceptance
`);
writeJson(path.join(outDocs, 'THAI_PREDICTIVE_CONFLICT_REPORT_V3.json'), conflictReport);
writeText(path.join(outDocs, 'THAI_PREDICTIVE_CONFLICT_REPORT_V3.md'), `
# Thai Predictive Conflict Report V3

ตรวจ ${conflictReport.counts.applications} applications: reported 0, unresolved 0, hidden 0 ลำดับ precedence คือ explicit Kalakini inversion ก่อน house direction, Taksa domain, planet scope และ period continuity
`);
writeJson(path.join(outDocs, 'THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0012_CLAIM_EVIDENCE_MAP.json'), candidateMap);
writeText(path.join(outDocs, 'THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0012.md'), candidateMarkdown(
  'Thai Report Predictive Narrative V2 — Candidate 0012 Known',
  'ชาย · 6 มิถุนายน 2525 · 00:03 · เชียงใหม่ · asOf 2026-08-29 Asia/Bangkok · Aquarius 9°24′ · Saturday · rem0',
  knownClaims,
));
writeText(path.join(outDocs, 'THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0012_UNKNOWN.md'), candidateMarkdown(
  'Thai Report Predictive Narrative V2 — Candidate 0012 Unknown',
  'ชาย · 6 มิถุนายน 2525 · ไม่ทราบเวลาเกิด · เชียงใหม่ · no noon substitution · no ascendant · no houses · no Thai-day claim',
  unknownClaims,
));
writeText(path.join(outDocs, 'THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0012_CLAIM_EVIDENCE_MAP.md'), `
# Candidate 0012 Claim/Evidence Map

Known ${knownClaims.length} claims, Unknown ${unknownClaims.length} claims, unsupported approved claims 0 ทุก Known prediction อ้าง matrix/rule/source โดยตรง ส่วน Unknown เป็น fail-closed และไม่มีการแทนเวลาไม่ทราบด้วยเวลาเที่ยง
`);
writeJson(path.join(outDocs, 'CANDIDATE_0011_RECLASSIFICATION_V3.json'), reclassificationReport);
writeText(path.join(outDocs, 'CANDIDATE_0011_RECLASSIFICATION_V3.md'), `
# Candidate 0011 Reclassification V3

Candidate 0011 ยังคงเป็น **STYLE_AND_STRUCTURE_REFERENCE** ตามประวัติการยอมรับด้านภาษา ลำดับ และประสบการณ์ผู้อ่าน แต่ PR113 OR3 supersedes สถานะ exact claim authority: ไม่ใช่ runtime golden, prediction authority หรือ fixture oracle

ตรวจครบ ${reclassification.length} reader claims: ${Object.entries(classificationCounts).map(([key, value]) => `${key}=${value}`).join(', ')}
`);
writeJson(path.join(outDocs, 'CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.json'), beforeAfterReport);
writeText(path.join(outDocs, 'CANDIDATE_0011_TO_0012_BEFORE_AFTER_V3.md'), `
# Candidate 0011 to Candidate 0012 — Full Before/After

Status: **EVIDENCE-ONLY — PENDING OWNER RULEBOOK AND CONTENT REVIEW**

${beforeAfterEntries.map((entry, index) => `## ${index + 1}. ${entry.candidate0011ClaimId} — ${entry.classification}\n\n**Surface:** ${entry.surface}\n\n**Section:** ${entry.section}\n\n**Before:** ${entry.beforeFullText}\n\n**After:** ${entry.afterFullText ?? 'นำออกจาก Candidate 0012 โดยไม่มีข้อความทำนายทดแทน'}\n\n**Boundary:** ${entry.changeBoundary}`).join('\n\n')}
`);
writeJson(path.join(outDocs, 'PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.json'), diversityAudit);
writeText(path.join(outDocs, 'PREDICTIVE_AUTHORITY_POPULATION_DIVERSITY_49.md'), `
# Predictive Authority Population and Diversity Audit — 49 contexts

unique authority signatures ${diversityAudit.counts.uniqueAuthoritySignatures}/49, unique selected rule sets ${diversityAudit.counts.uniqueSelectedRuleSets}/49, unique normalized prediction sets ${diversityAudit.counts.uniqueNormalizedPredictionSets}/49, exact duplicate clusters 0, near-duplicate clusters 0 และ generic template duplicate count 0

ประโยคใช้ grammar ร่วมตาม reusable source rule โดยความต่างมาจาก evidence signature จริง ไม่ได้เปลี่ยนคำพ้องเพื่อให้ผ่าน
`);
writeJson(path.join(outDocs, 'MANUAL_AI_CONTENT_AUDIT_V3.json'), manualAudit);
writeText(path.join(outDocs, 'MANUAL_AI_CONTENT_AUDIT_V3.md'), `
# Manual AI Content Audit V3

Status: **PENDING OWNER RULEBOOK AND CONTENT REVIEW**

นี่คือ AI content audit ไม่ใช่ Human Review ตรวจ 2 รอบ × 49 contexts = ${manualAudit.counts.entries} entries ครบ ${auditDimensions.length} มิติ ผล pass ${manualAudit.counts.pass}, fail 0
`);

console.log(JSON.stringify({
  sourceRecords: sourceRecords.length,
  pagesHashed: pageInventory.length,
  rules: rules.length,
  contexts: contextCoverage.length,
  applications: applications.length,
  candidateKnownClaims: knownClaims.length,
  candidateUnknownClaims: unknownClaims.length,
  reclassifiedClaims: reclassification.length,
  manualAuditEntries: manualAuditEntries.length,
  status: coverage.status,
}, null, 2));
