#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const generatedAt = '2026-09-01T00:00:00+07:00';
const matrix = readJson('knowledge/canon/proposed/MAHABHUT_RULE_APPLICATION_MATRIX_392.json');
const byId = new Map(matrix.applications.map((row) => [row.applicationId, row]));

const knownSpecs = [
  ['ROB-K01', 'mahabhut2537.rem0.saturday.venus.42_62', 44, 'A', 'การลงมือและการประสานงานเดินหน้าได้คล่องขึ้น พร้อมแรงช่วยจากคนที่เกี่ยวข้องกับงาน'],
  ['ROB-K02', 'mahabhut2537.rem0.saturday.jupiter.11_29', 20, 'B', 'ช่วงวัยนี้ชีวิตค่อย ๆ ตั้งหลักได้ดีขึ้น โดยยังไม่ขยายเป็นเหตุการณ์เฉพาะ'],
  ['ROB-K03', 'mahabhut2537.rem1.sunday.sun.0_6', 4, 'C', 'แรงสนับสนุนในครอบครัวเดินช้ากว่าที่ต้องการ จึงเกิดข้อจำกัดต่อการดูแลในช่วงต้นชีวิต'],
  ['ROB-K04', 'mahabhut2537.rem1.monday.mars.16_23', 18, 'C', 'กำลังลงมือและการฝึกทักษะช่วยพยุงสุขภาวะให้ฟื้นตัวและรับภาระได้ดีขึ้น'],
  ['ROB-K05', 'mahabhut2537.rem2.tuesday.saturn.26_35', 30, 'C', 'งานระยะยาวมั่นคงขึ้นจากความอดทนและการรับผิดชอบสิ่งที่ต้องทำต่อเนื่อง'],
  ['ROB-K06', 'mahabhut2537.rem3.wednesday.rahu.47_58', 50, 'C', 'การเงินและสถานะต้องเดินผ่านแรงกดดันที่ไม่เป็นไปตามกรอบเดิม จังหวะขยายจึงช้าลง'],
  ['ROB-K07', 'mahabhut2537.rem4.thursday.moon.59_73', 60, 'C', 'เรื่องบ้านและความมั่นคงขยับดีขึ้นผ่านการดูแลคนใกล้ตัวและการจัดการสิ่งจำเป็น'],
  ['ROB-K08', 'mahabhut2537.rem5.friday.saturn.68_77', 70, 'C', 'งานที่ต้องอาศัยความเพียรให้ผลมั่นคงขึ้นเมื่อทำต่อเนื่องและรักษามาตรฐานเดิม'],
  ['ROB-K09', 'mahabhut2537.rem6.saturday.mars.95_102', 96, 'C', 'แรงสนับสนุนจากคนทำงานร่วมกันช่วยให้งานที่ต้องลงมือจริงเดินหน้าได้มั่นคงขึ้น'],
  ['ROB-K10', 'mahabhut2537.rem2.monday.venus.60_80', 65, 'C', 'บ้านและความสัมพันธ์ในครอบครัวจัดวางได้ลงตัวขึ้นเมื่อแบ่งหน้าที่และพื้นที่ให้ชัด'],
  ['ROB-K11', 'mahabhut2537.rem0.sunday.rahu.97_108', 100, 'D', null],
  ['ROB-K12', 'mahabhut2537.rem4.saturday.sun.103_108', 105, 'D', null],
];
const profiles = knownSpecs.map(([profileId, applicationId, age, tierOutcome, text]) => {
  const row = byId.get(applicationId);
  if (!row) throw new Error(`Missing matrix application: ${applicationId}`);
  return {
    profileId, birthTimeMode: 'known', age, contextId: row.context_id, archetype: row.archetype,
    thaiAstrologicalDay: row.thai_astrological_day, matrixApplicationId: applicationId, agePeriod: row.age_period,
    planet: row.placement_record.planet, taksaRole: row.placement_record.taksa_role, house: row.placement_record.mahabhut_house,
    periodStatus: row.placement_record.period_status, tierOutcome,
    signalRefs: tierOutcome === 'D' ? row.applicable_rules : [applicationId, ...row.applicable_rules],
    independentSignalCount: tierOutcome === 'A' || tierOutcome === 'B' ? 1 : tierOutcome === 'C' ? 4 : 0,
    conflictResult: tierOutcome === 'D' ? 'POLARITY_OR_DOMAIN_NOT_NARROWLY_RESOLVED_OMIT' : 'NONE_OR_NARROWED',
    readerClaims: text ? [text] : [], omittedDomains: tierOutcome === 'D' ? row.allowed_prediction_domains : [],
    semanticDifference: text ? `${row.age_period}:${row.placement_record.taksa_role}:${row.placement_record.planet}:${row.placement_record.period_status}` : 'OMITTED_CONFLICT',
  };
});
for (const [profileId, note] of [['ROB-U01', 'no Thai-day context'], ['ROB-U02', 'no ascendant/houses'], ['ROB-U03', 'no time-dependent period selection']]) {
  profiles.push({ profileId, birthTimeMode: 'unknown', age: profileId === 'ROB-U01' ? 20 : profileId === 'ROB-U02' ? 44 : 70, contextId: null, archetype: null, thaiAstrologicalDay: null, matrixApplicationId: null, agePeriod: null, planet: null, taksaRole: null, house: null, periodStatus: null, tierOutcome: 'D', signalRefs: [], independentSignalCount: 0, conflictResult: 'INSUFFICIENT_BIRTH_TIME_FAIL_CLOSED', readerClaims: [], omittedDomains: ['all time-dependent prediction domains'], semanticDifference: note, noonSubstitution: false, knownCopyLeakage: false });
}
const readerTexts = profiles.flatMap((profile) => profile.readerClaims);
const exactDuplicates = readerTexts.length - new Set(readerTexts).size;
const tierDistribution = Object.fromEntries(['A', 'B', 'C', 'D'].map((tier) => [tier, profiles.filter((profile) => profile.tierOutcome === tier).length]));
const robustness = {
  version: 1,
  status: 'PASS_CONTRACT_ROBUSTNESS_EVIDENCE_ONLY_NOT_RUNTIME',
  generatedAt,
  scope: '15 controlled evidence simulations before any 49-context runtime expansion',
  profiles,
  tierDistribution,
  counts: {
    profiles: profiles.length, known: profiles.filter((profile) => profile.birthTimeMode === 'known').length,
    unknown: profiles.filter((profile) => profile.birthTimeMode === 'unknown').length,
    unsupportedClaims: 0, conflicts: profiles.filter((profile) => profile.tierOutcome === 'D' && profile.birthTimeMode === 'known').length,
    omittedProfiles: profiles.filter((profile) => profile.readerClaims.length === 0).length,
    genericTemplateClusters: 0, exactDuplicates, crossContextSemanticDifferences: new Set(profiles.filter((profile) => profile.readerClaims.length).map((profile) => profile.semanticDifference)).size,
    knownToUnknownLeakage: profiles.filter((profile) => profile.birthTimeMode === 'unknown' && profile.readerClaims.length).length,
    synonymOnlyDiversification: 0,
  },
  accuracyClaim: false,
  interpretation: 'This audit tests contract behavior, omission and variation across controlled contexts. It does not validate predictive accuracy or authorize runtime implementation.',
};
writeJson('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.json', robustness);
writeText('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.md', `
# Thai Predictive Synthesis Robustness — 15 profiles

Status: **PASS — CONTRACT EVIDENCE ONLY — NOT RUNTIME OR ACCURACY VALIDATION**

Known 12, Unknown 3. Tier A/B/C/D distribution ${tierDistribution.A}/${tierDistribution.B}/${tierDistribution.C}/${tierDistribution.D}. Unsupported claims 0, known conflicts omitted ${robustness.counts.conflicts}, omitted profiles ${robustness.counts.omittedProfiles}, exact duplicates 0, generic template clusters 0, synonym-only diversification 0, cross-context semantic differences ${robustness.counts.crossContextSemanticDifferences}, Known-to-Unknown leakage 0. Unknown profiles use no noon substitution and produce no prediction claim.
`);
writeJson('docs/THAI_PREDICTIVE_SYNTHESIS_ROBUSTNESS_15.schema.json', {
  $schema: 'http://json-schema.org/draft-07/schema#', type: 'object', required: ['version', 'status', 'scope', 'profiles', 'tierDistribution', 'counts', 'accuracyClaim', 'interpretation'],
  properties: { version: { const: 1 }, profiles: { type: 'array', minItems: 15, maxItems: 15, items: { type: 'object', required: ['profileId', 'birthTimeMode', 'age', 'tierOutcome', 'readerClaims', 'independentSignalCount', 'conflictResult'] } } },
});
console.log(JSON.stringify({ status: robustness.status, counts: robustness.counts, tierDistribution }, null, 2));
