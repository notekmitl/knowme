#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { buildResolvedRegistry, targetFixture } from './resolve_candidate_0018_or6.mjs';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const write = (file, value) => fs.writeFileSync(path.join(ROOT, file), value.endsWith('\n') ? value : `${value}\n`, 'utf8');
const certainty = ['certainty.product-interpretation-contract-v1'];
const noConflict = ['conflict.contract-boundaries'];

const claims = [
  {
    claimId: 'RC18-K-OVERVIEW', classification: 'OVERVIEW', section: 'ภาพรวมชีวิต',
    fullReaderText: 'ชีวิตมีสามจังหวะใหญ่ วัยเด็กเป็นช่วงติดขัด ชีวิตค่อย ๆ ดีขึ้นตั้งแต่อายุ 11 ปี และรอบอายุ 42–62 ปีเป็นช่วงที่ทำเรื่องต่าง ๆ ได้คล่องกว่าเดิม',
    composedClaimRefs: ['RC18-K-PAST-0-10', 'RC18-K-PAST-11-29', 'RC18-K-PAST-30-41', 'RC18-K-CURRENT'],
    semanticOwner: 'whole-life-three-stage-chronology', semanticMotifs: ['whole-life-three-stage-chronology'],
  },
  {
    claimId: 'RC18-K-PAST-0-10', classification: 'PREDICTION', section: 'อดีต อายุ 0–10 ปี',
    fullReaderText: 'ช่วงอายุ 0–10 ปี พ่อแม่มีปัญหาสุขภาพ งานของครอบครัวไม่ราบรื่น และเงินในบ้านติดขัด ความเป็นอยู่จึงมีข้อจำกัด',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.saturn.0_10'],
    domainRefs: ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT', 'canon.mahabhut.p28.saturn_owns_family'],
    directionRefs: ['source.T0003-SRC-0-10-FAMILY-CONSTRAINT'], timingRefs: ['selector.mahabhut2537.rem0.saturday.saturn.0_10'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'family', expectedHorizon: '0-10', expectedBandDirection: 'SOURCE_DIRECT_EVENT', materialStrength: 'DIRECT_EVENT',
    allowedSpecificity: 'Source-direct family health/work/finance constraint only', prohibitedSpecificity: ['diagnosis', 'which_parent', 'amount', 'permanent_outcome'],
    semanticOwner: 'early-family-constraints', semanticMotifs: ['early-family-constraints'],
  },
  {
    claimId: 'RC18-K-PAST-11-29', classification: 'PREDICTION', section: 'อดีต อายุ 11–29 ปี',
    fullReaderText: 'ช่วงอายุ 11–29 ปี ชีวิตค่อย ๆ ดีขึ้น การเรียนเปิดทางให้คุณมีความรู้และโอกาสทำงานมากกว่าวัยเด็ก',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.jupiter.11_29'],
    domainRefs: ['canon.mahabhut.p220.jupiter_owns_learning', 'canon.mahabhut.p220.jupiter_owns_career'],
    directionRefs: ['source.T0003-SRC-11-62-RISING-BLOCK'], timingRefs: ['selector.mahabhut2537.rem0.saturday.jupiter.11_29'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'learning+career', expectedHorizon: '11-29', expectedBandDirection: 'POSITIVE_WITHIN_RISING_BLOCK', materialStrength: 'DIRECT_TREND_WITH_DOMAIN',
    allowedSpecificity: 'Positive learning and work direction without named event', prohibitedSpecificity: ['school_name', 'job_title', 'event_count', 'causal_outcome'],
    semanticOwner: 'past-learning-work-opening', semanticMotifs: ['past-learning-work-opening'],
  },
  {
    claimId: 'RC18-K-PAST-30-41', classification: 'PREDICTION', section: 'อดีต อายุ 30–41 ปี',
    fullReaderText: 'ช่วงอายุ 30–41 ปี งานมีบทบาทมากขึ้น คุณรับผิดชอบผลลัพธ์และตัดสินใจเรื่องยากมากกว่าช่วงก่อน',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.rahu.30_41'],
    domainRefs: ['canon.mahabhut.p39.det_owns_career', 'source.T0003-SRC-30-41-PLACEMENT'],
    directionRefs: ['source.T0003-SRC-11-62-RISING-BLOCK'], timingRefs: ['selector.mahabhut2537.rem0.saturday.rahu.30_41'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'career', expectedHorizon: '30-41', expectedBandDirection: 'POSITIVE_WITHIN_RISING_BLOCK', materialStrength: 'DIRECT_TREND_WITH_DOMAIN',
    allowedSpecificity: 'Work responsibility direction without named event', prohibitedSpecificity: ['employer', 'job_title', 'event_count', 'termination'],
    semanticOwner: 'past-work-responsibility', semanticMotifs: ['past-work-responsibility'],
  },
  {
    claimId: 'RC18-K-CURRENT', classification: 'PREDICTION', section: 'ปัจจุบัน อายุ 44 ปี',
    fullReaderText: 'อายุ 44 อยู่ในช่วงที่การลงมือ การพูด และการคิดคล่องกว่าวัยก่อน คุณตัดสินใจเรื่องสำคัญได้ชัดขึ้น',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'fixture.target-0003'],
    domainRefs: ['source.T0003-SRC-42-62-FLOW'], directionRefs: ['source.T0003-SRC-42-62-FLOW'],
    timingRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62', 'fixture.target-0003'],
    conflictRefs: ['conflict.T0003-SRC-42-43-61-62-EXCEPTION', ...noConflict], certaintyRefs: certainty,
    expectedDomain: 'action+communication+decision', expectedHorizon: 'current-age-44', expectedBandDirection: 'POSITIVE_FLOW_EXCEPTION_NOT_APPLICABLE', materialStrength: 'DIRECT_TREND',
    allowedSpecificity: 'Age-44 flow only; no domain details', prohibitedSpecificity: ['work_detail', 'finance_detail', 'support_detail', 'guaranteed_outcome'],
    semanticOwner: 'current-age44-flow', semanticMotifs: ['current-age44-flow'],
  },
  {
    claimId: 'RC18-K-WORK-CURRENT-NEXT12', classification: 'PREDICTION', section: 'การงาน — ปัจจุบันถึง 12 เดือนข้างหน้า',
    fullReaderText: 'ตอนนี้งานก้อนใหม่จะเพิ่มหน้าที่และเรื่องที่คุณต้องตัดสินใจ ตลอดช่วงวันที่ 29 ส.ค. 2569 – 28 ส.ค. 2570 ผลงานที่ส่งมอบจะบอกชัดว่างานหลักยังรักษาคุณภาพได้แค่ไหน การรับผิดชอบมากกว่าอำนาจที่คุณมีจะทำให้งานหลักเสียคุณภาพ',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62'],
    domainRefs: ['source.T0003-SRC-42-62-WORK', 'domain.runtime.current.career'],
    directionRefs: ['typed.current.career', 'typed.next12Months.career'],
    timingRefs: ['typed.current.career', 'typed.next12Months.career', 'timing.rolling-12-month-label'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'career', expectedHorizon: 'current+next12Months', expectedBandDirection: 'strong+strong', materialStrength: 'TYPED_OUTPUT_WITH_SOURCE_DOMAIN',
    allowedSpecificity: 'Current role expansion and annual delivery-quality boundary from actual output', prohibitedSpecificity: ['job_title', 'employer', 'salary', 'specific_event_date'],
    semanticOwner: 'work-current-through-next12', semanticMotifs: ['work-role-delivery-quality'],
  },
  {
    claimId: 'RC18-K-FINANCE-CURRENT-NEXT12', classification: 'PREDICTION', section: 'การเงิน — ปัจจุบันถึง 12 เดือนข้างหน้า',
    fullReaderText: 'ตอนนี้เงินพร้อมใช้ยังพอให้คุณจัดการเรื่องจำเป็นได้ ตลอดช่วงวันที่ 29 ส.ค. 2569 – 28 ส.ค. 2570 เงินที่เหลือหลังจ่ายเรื่องจำเป็นจะกำหนดว่าคุณเริ่มเรื่องใหม่ได้มากแค่ไหน รายจ่ายประจำที่โตตามรายรับจะทำให้เงินเหลือน้อยลง',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62'],
    domainRefs: ['source.T0003-SRC-42-62-FINANCE', 'canon.mahabhut.p39.sri_owns_finance', 'domain.runtime.current.finance'],
    directionRefs: ['typed.current.finance', 'typed.next12Months.finance'],
    timingRefs: ['typed.current.finance', 'typed.next12Months.finance', 'timing.rolling-12-month-label'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'finance', expectedHorizon: 'current+next12Months', expectedBandDirection: 'strong+strong', materialStrength: 'TYPED_OUTPUT_WITH_SOURCE_DOMAIN',
    allowedSpecificity: 'Current liquidity and annual remaining-cash boundary from actual output', prohibitedSpecificity: ['amount', 'investment_return', 'windfall_size', 'specific_event_date'],
    semanticOwner: 'finance-current-through-next12', semanticMotifs: ['finance-remaining-cash'],
  },
  {
    claimId: 'RC18-K-RELATIONSHIP-CURRENT-NEXT12', classification: 'PREDICTION', section: 'ความรักและความสัมพันธ์ — ปัจจุบันถึง 12 เดือนข้างหน้า',
    fullReaderText: 'ตั้งแต่ตอนนี้ถึง 28 ส.ค. 2570 ความสัมพันธ์จะชัดจากสิ่งที่แต่ละฝ่ายทำซ้ำ ข้อตกลงที่ทำจริงต่อเนื่องจะพาความสัมพันธ์ไปต่อ ส่วนคำพูดเพียงครั้งเดียวจะไม่มีน้ำหนักพอ',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62'],
    domainRefs: ['canon.mahabhut.p16.venus_owns_relationship_male', 'canon.mahabhut.p28.venus_owns_relationship'],
    directionRefs: ['typed.current.relationship', 'typed.next12Months.relationship'],
    timingRefs: ['typed.current.relationship', 'typed.next12Months.relationship', 'timing.rolling-12-month-label'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'relationship', expectedHorizon: 'current+next12Months', expectedBandDirection: 'strong+strong', materialStrength: 'TYPED_OUTPUT_WITH_CANON_DOMAIN',
    allowedSpecificity: 'Repeated action and agreement clarity from actual output', prohibitedSpecificity: ['new_partner', 'breakup', 'marriage', 'identity_of_person'],
    semanticOwner: 'relationship-current-through-next12', semanticMotifs: ['relationship-repeated-action'],
  },
  {
    claimId: 'RC18-K-HEALTH-CURRENT-NEXT12', classification: 'PREDICTION', section: 'สุขภาพ — ปัจจุบันถึง 12 เดือนข้างหน้า',
    fullReaderText: 'ตั้งแต่ตอนนี้ถึง 28 ส.ค. 2570 เวลาพักจะกำหนดว่าคุณทำกิจกรรมต่อได้มากแค่ไหน งานหนักต่อเนื่องจะทำให้ร่างกายใช้เวลาคืนแรงนานขึ้น',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62'],
    domainRefs: ['canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน', 'domain.runtime.current.health'],
    directionRefs: ['typed.current.health', 'typed.next12Months.health'],
    timingRefs: ['typed.current.health', 'typed.next12Months.health', 'timing.rolling-12-month-label'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'health', expectedHorizon: 'current+next12Months', expectedBandDirection: 'strong+strong', materialStrength: 'TYPED_OUTPUT_WITH_CANON_DOMAIN',
    allowedSpecificity: 'Rest and recovery-time direction only', prohibitedSpecificity: ['diagnosis', 'disease', 'treatment', 'recovery_days'],
    semanticOwner: 'health-current-through-next12', semanticMotifs: ['health-rest-recovery'],
  },
  {
    claimId: 'RC18-K-SUPPORT', classification: 'PREDICTION', section: 'โชคลาภและแรงสนับสนุน',
    fullReaderText: 'ในช่วงอายุ 42–62 ปี ครู ผู้มีประสบการณ์ เพื่อน และคนรอบตัวจะช่วยให้งานและเรื่องสำคัญเดินต่อได้ง่ายขึ้น',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62'], domainRefs: ['source.T0003-SRC-42-62-SUPPORT'], directionRefs: ['source.T0003-SRC-42-62-SUPPORT'],
    timingRefs: ['selector.mahabhut2537.rem0.saturday.venus.42_62'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'support', expectedHorizon: '42-62', expectedBandDirection: 'SOURCE_DIRECT_EVENT', materialStrength: 'DIRECT_EVENT',
    allowedSpecificity: 'Named support classes from source without named individual', prohibitedSpecificity: ['person_name', 'guaranteed_opportunity', 'gambling', 'amount'],
    semanticOwner: 'current-human-support', semanticMotifs: ['current-human-support'],
  },
  {
    claimId: 'RC18-K-NEXT-CAREER', classification: 'PREDICTION', section: 'ช่วงชีวิตถัดไป อายุ 63–79 ปี — การงาน',
    fullReaderText: 'เมื่ออายุ 63 ปี งานจะเปลี่ยนจากการรับเพิ่มไปสู่การคุมคุณภาพ คุณจะเก็บงานที่ใช้ประสบการณ์ไว้กับตัวและส่งต่องานที่กระจายแรง',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79'],
    domainRefs: ['canon.mahabhut.p33.mercury_relates_attribute_profession_นักพูด', 'domain.runtime.nextLifePeriod.career'], directionRefs: ['typed.nextLifePeriod.career'],
    timingRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79', 'typed.nextLifePeriod.career'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'career', expectedHorizon: 'nextLifePeriod|63-79', expectedBandDirection: 'strong', materialStrength: 'TYPED_OUTPUT_WITH_CANON_DOMAIN',
    allowedSpecificity: 'Work-quality direction from actual output', prohibitedSpecificity: ['job_title', 'employer', 'retirement_date', 'guaranteed_income'],
    semanticOwner: 'next-career-quality', semanticMotifs: ['next-career-quality'],
  },
  {
    claimId: 'RC18-K-NEXT-FINANCE', classification: 'PREDICTION', section: 'ช่วงชีวิตถัดไป อายุ 63–79 ปี — การเงิน',
    fullReaderText: 'เรื่องเงินจะเปลี่ยนตามบทบาทใหม่',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79'], domainRefs: ['domain.runtime.nextLifePeriod.finance'], directionRefs: ['typed.nextLifePeriod.finance'],
    timingRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79', 'typed.nextLifePeriod.finance'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'finance', expectedHorizon: 'nextLifePeriod|63-79', expectedBandDirection: 'active', materialStrength: 'BAND_ONLY',
    allowedSpecificity: 'Active finance direction only', prohibitedSpecificity: ['amount', 'property_purchase', 'inheritance', 'debt_event', 'specific_obligation'],
    semanticOwner: 'next-finance-active', semanticMotifs: ['next-finance-active'],
  },
  {
    claimId: 'RC18-K-NEXT-RELATIONSHIP', classification: 'PREDICTION', section: 'ช่วงชีวิตถัดไป อายุ 63–79 ปี — ความสัมพันธ์',
    fullReaderText: 'ความสัมพันธ์จะเดินช้าลงและต้องการความชัดเรื่องเวลา หน้าที่ และพื้นที่ส่วนตัว',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79'], domainRefs: ['canon.mahabhut.p28.mercury_owns_family', 'domain.runtime.nextLifePeriod.relationship'], directionRefs: ['typed.nextLifePeriod.relationship'],
    timingRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79', 'typed.nextLifePeriod.relationship'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'relationship', expectedHorizon: 'nextLifePeriod|63-79', expectedBandDirection: 'quiet', materialStrength: 'TYPED_OUTPUT_NARROWED',
    allowedSpecificity: 'Quiet relationship direction and the actual output boundary only', prohibitedSpecificity: ['new_partner', 'breakup', 'marriage', 'identity_of_person'],
    semanticOwner: 'next-relationship-quiet', semanticMotifs: ['next-relationship-quiet'],
  },
  {
    claimId: 'RC18-K-NEXT-HEALTH', classification: 'PREDICTION', section: 'ช่วงชีวิตถัดไป อายุ 63–79 ปี — สุขภาพ',
    fullReaderText: 'ตารางชีวิตใหม่จะเปลี่ยนจังหวะพัก และการคืนแรงจะเป็นส่วนสำคัญของชีวิตประจำวัน',
    selectorRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79'], domainRefs: ['domain.runtime.nextLifePeriod.health'], directionRefs: ['typed.nextLifePeriod.health'],
    timingRefs: ['selector.mahabhut2537.rem0.saturday.mercury.63_79', 'typed.nextLifePeriod.health'], conflictRefs: noConflict, certaintyRefs: certainty,
    expectedDomain: 'health', expectedHorizon: 'nextLifePeriod|63-79', expectedBandDirection: 'active', materialStrength: 'TYPED_OUTPUT_NARROWED',
    allowedSpecificity: 'Active recovery-routine direction from actual output', prohibitedSpecificity: ['diagnosis', 'disease', 'treatment', 'recovery_days'],
    semanticOwner: 'next-health-active', semanticMotifs: ['next-health-active'],
  },
  {
    claimId: 'RC18-K-ADVICE', classification: 'ADVICE', section: 'คำแนะนำ',
    fullReaderText: 'กำหนดงานหลักหนึ่งเรื่อง แยกเงินพร้อมใช้ออกจากรายจ่ายประจำ ดูการกระทำที่เกิดซ้ำ และกันเวลาพักไว้ในตาราง',
    sourceClaimRefs: ['RC18-K-WORK-CURRENT-NEXT12', 'RC18-K-FINANCE-CURRENT-NEXT12', 'RC18-K-RELATIONSHIP-CURRENT-NEXT12', 'RC18-K-HEALTH-CURRENT-NEXT12'],
    semanticOwner: 'action-only-closing', semanticMotifs: ['action-only-closing'],
  },
];

const known = `# Candidate 0018 — Known time

Status: **OR6 EVIDENCE-BOUND COPY — PENDING OWNER CONTENT REVIEW — NOT RUNTIME**

## 1. ข้อมูลดวง

ผู้ชาย · 6 มิถุนายน 2525 · เวลา 00:03 · เชียงใหม่

วันทางโหราศาสตร์: วันเสาร์ · ลัคนา: กุมภ์ 9°24′ · วันที่อ้างอิง: 29 สิงหาคม 2569

## 2. ภาพรวมชีวิต

${claims[0].fullReaderText}

## 3. อดีต อายุ 0–10 ปี

${claims[1].fullReaderText}

## 4. อดีต อายุ 11–29 ปี

${claims[2].fullReaderText}

## 5. อดีต อายุ 30–41 ปี

${claims[3].fullReaderText}

## 6. ปัจจุบัน อายุ 44 ปี

${claims[4].fullReaderText}

## 7. การงาน — ปัจจุบันถึง 12 เดือนข้างหน้า

${claims[5].fullReaderText}

## 8. การเงิน — ปัจจุบันถึง 12 เดือนข้างหน้า

${claims[6].fullReaderText}

## 9. ความรักและความสัมพันธ์ — ปัจจุบันถึง 12 เดือนข้างหน้า

${claims[7].fullReaderText}

## 10. สุขภาพ — ปัจจุบันถึง 12 เดือนข้างหน้า

${claims[8].fullReaderText}

## 11. โชคลาภและแรงสนับสนุน

${claims[9].fullReaderText}

## 12. ช่วงชีวิตถัดไป อายุ 63–79 ปี

### การงาน

${claims[10].fullReaderText}

### การเงิน

${claims[11].fullReaderText}

### ความรักและความสัมพันธ์

${claims[12].fullReaderText}

### สุขภาพ

${claims[13].fullReaderText}

## 13. คำแนะนำ

${claims[14].fullReaderText}

## 14. ข้อจำกัด

คำทำนายนี้เป็นการตีความตามหลักโหราศาสตร์ซึ่งเป็นความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ ไม่ใช่การรับรองความแม่นยำหรือยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน
`;

const unknown = `# Candidate 0018 — Unknown time

Status: **OR6 FAIL-CLOSED COMPANION — PENDING OWNER CONTENT REVIEW — NOT RUNTIME**

## ข้อมูลดวง

ผู้ชาย · 6 มิถุนายน 2525 · ไม่ทราบเวลาเกิด · เชียงใหม่

## ข้อมูลที่เว้น

ไม่มีเวลาเกิด — รายงานจึงเว้นลัคนา เรือน วันทางโหราศาสตร์ และคำทำนายตามช่วงมหาภูติที่ต้องใช้เวลาเกิด ระบบไม่แทนเวลาเกิดด้วยเวลาอื่นและไม่ยืมคำทำนายจากกรณี Known time

หัวข้อภาพรวม อดีต ปัจจุบัน การงาน การเงิน ความรักและความสัมพันธ์ สุขภาพ โชคลาภและแรงสนับสนุน ช่วง 12 เดือนข้างหน้า ช่วงชีวิตถัดไป และคำแนะนำจึงไม่แสดง เพราะยังยืนยันตัวเลือกช่วงมหาภูติของกรณีนี้ไม่ได้

## ข้อจำกัด

รายงานนี้เว้นข้อมูลที่คำนวณไม่ได้แทนการเดา คำทำนายทางโหราศาสตร์เป็นความเชื่อ ไม่ใช่การรับรองความแม่นยำหรือยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน
`;

const oldMap = readJson('docs/CANDIDATE_0017_RULE_CHAIN_MAP.json');
const oldById = new Map(oldMap.known.claims.map((claim) => [claim.claimId, claim]));
const beforeAfter = [
  ['RC17-K-OVERVIEW', 'RC18-K-OVERVIEW', 'ย่อภาพรวมให้เหลือเส้นเวลาและย้ายรายละเอียดงาน เงิน และผู้ช่วยไปยังหัวข้อเจ้าของ'],
  ['RC17-K-PAST-0-10', 'RC18-K-PAST-0-10', 'คงเหตุการณ์จากต้นฉบับและลดถ้อยคำแบบรายงาน'],
  ['RC17-K-PAST-11-29', 'RC18-K-PAST-11-29', 'ใช้ประโยคสั้นและบอกผลของการเรียนต่อโอกาสทำงานตรง ๆ'],
  ['RC17-K-PAST-30-41', 'RC18-K-PAST-30-41', 'ตัดคำอธิบายบทบาทซ้ำและเหลือผลด้านงานที่หลักฐานรองรับ'],
  ['RC17-K-CURRENT', 'RC18-K-CURRENT', 'ให้ปัจจุบันเป็นเจ้าของจุดเปลี่ยนวัย 44 เท่านั้น'],
  ['RC17-K-WORK|RC17-K-NEXT12-WORK-FINANCE', 'RC18-K-WORK-CURRENT-NEXT12', 'รวม current กับ next12 ที่ใช้ band เดียวกัน แล้วเก็บเฉพาะรายละเอียดงานไว้ตำแหน่งเดียว'],
  ['RC17-K-FINANCE|RC17-K-NEXT12-WORK-FINANCE', 'RC18-K-FINANCE-CURRENT-NEXT12', 'รวม current กับ next12 และให้หัวข้อนี้เป็นเจ้าของเรื่องเงินเพียงตำแหน่งเดียว'],
  ['RC17-K-RELATIONSHIP|RC17-K-NEXT12-RELATIONSHIP-HEALTH', 'RC18-K-RELATIONSHIP-CURRENT-NEXT12', 'รวมข้อความข้อตกลงและการกระทำที่ซ้ำกันเป็นคำทำนายเดียว'],
  ['RC17-K-HEALTH|RC17-K-NEXT12-RELATIONSHIP-HEALTH', 'RC18-K-HEALTH-CURRENT-NEXT12', 'รวมเรื่องเวลาพักและการคืนแรงเป็นตำแหน่งเดียวโดยไม่ใช้เงื่อนไขแฝง'],
  ['RC17-K-SUPPORT', 'RC18-K-SUPPORT', 'คงผู้ช่วยตามข้อความต้นทางและตัดภาษารายงาน'],
  ['RC17-K-NEXT-WORK', 'RC18-K-NEXT-CAREER', 'คงทิศทาง strong และตัดถ้อยคำที่เกินจำเป็น'],
  ['RC17-K-NEXT-LIFE-DOMAINS', 'RC18-K-NEXT-FINANCE|RC18-K-NEXT-RELATIONSHIP|RC18-K-NEXT-HEALTH', 'แยกสาม domain เพื่อไม่ขยาย active/quiet เป็นเหตุการณ์ผูกพันก้อนเดียว'],
  ['RC17-K-ADVICE', 'RC18-K-ADVICE', 'เหลือ action สั้น ๆ และไม่เล่าคำทำนายซ้ำ'],
];

const escapeTable = (value) => String(value).replaceAll('|', '\\|').replaceAll('\n', '<br>');
const getTexts = (ids, map) => ids.split('|').map((id) => map.get(id)?.fullReaderText ?? claims.find((claim) => claim.claimId === id)?.fullReaderText ?? '').join('\n\n');
const candidateById = new Map(claims.map((claim) => [claim.claimId, claim]));

const beforeAfterMd = `# Candidate 0017 → 0018 Before/After

Status: **FULL READER TEXT — COPY/STRUCTURE ONLY — NO NEW PREDICTION**

ทุกแถวใช้ข้อความเต็ม ไม่มี ellipsis และไม่ตัดกลางประโยค Candidate 0018 เปลี่ยนการจัดเจ้าของเนื้อหาและภาษาเท่านั้น ไม่เพิ่มความหมาย ช่วงเวลา หรือระดับความแน่นอน

| Before claim | Before — Candidate 0017 | After claim | After — Candidate 0018 | เหตุผล |
|---|---|---|---|---|
${beforeAfter.map(([beforeIds, afterIds, reason]) => `| ${escapeTable(beforeIds)} | ${escapeTable(getTexts(beforeIds, oldById))} | ${escapeTable(afterIds)} | ${escapeTable(getTexts(afterIds, candidateById))} | ${reason} |`).join('\n')}
`;

const duplicatePairsBefore = [
  ['RC17-K-OVERVIEW', 'RC17-K-CURRENT', 'งาน เงิน และแรงช่วยเหลือในช่วง 42–62'],
  ['RC17-K-CURRENT', 'RC17-K-WORK', 'งานเดินต่อและการตัดสินใจ'],
  ['RC17-K-CURRENT', 'RC17-K-FINANCE', 'เงินหมุนและเงินพร้อมใช้'],
  ['RC17-K-CURRENT', 'RC17-K-SUPPORT', 'แรงช่วยเหลือ'],
  ['RC17-K-WORK', 'RC17-K-NEXT12-WORK-FINANCE', 'งานก้อนใหม่ หน้าที่กว้าง และคุณภาพงานหลัก'],
  ['RC17-K-FINANCE', 'RC17-K-NEXT12-WORK-FINANCE', 'เงินพร้อมใช้ รายจ่าย และพื้นที่ทำแผน'],
  ['RC17-K-RELATIONSHIP', 'RC17-K-NEXT12-RELATIONSHIP-HEALTH', 'ข้อตกลงที่ทำจริงเทียบกับคำพูด'],
  ['RC17-K-HEALTH', 'RC17-K-NEXT12-RELATIONSHIP-HEALTH', 'เวลาพักไม่พอและคืนแรงช้า'],
  ['RC17-K-WORK', 'RC17-K-ADVICE', 'ขอบเขตงานและคุณภาพงานหลัก'],
  ['RC17-K-FINANCE', 'RC17-K-ADVICE', 'เงินพร้อมใช้ก่อนภาระระยะยาว'],
  ['RC17-K-HEALTH', 'RC17-K-ADVICE', 'กันเวลาพักก่อนตารางเต็ม'],
];
const semanticAudit = `# Candidate 0018 Semantic Duplication Audit

Status: **TWO-PASS FULL-TEXT REVIEW COMPLETE — OWNER CONTENT REVIEW PENDING**

## Candidate 0017 findings before repair

ตรวจข้อความเต็ม 15 entries แบบ pairwise 105 คู่ พบความซ้ำที่ไม่จำเป็น 11 คู่:

| คู่ | Motif ที่ซ้ำ | ข้อความเต็มฝั่ง A | ข้อความเต็มฝั่ง B |
|---|---|---|---|
${duplicatePairsBefore.map(([left, right, motif]) => `| ${left} ↔ ${right} | ${motif} | ${escapeTable(oldById.get(left).fullReaderText)} | ${escapeTable(oldById.get(right).fullReaderText)} |`).join('\n')}

## Candidate 0018 result after repair

ตรวจข้อความเต็ม 15 entries แบบ pairwise 105 คู่ซ้ำอีกครั้ง รายละเอียดแต่ละเรื่องมีเจ้าของตำแหน่งเดียว Current เหลือจุดเปลี่ยนวัย 44; current และ next12 ของงาน เงิน ความสัมพันธ์ และสุขภาพถูกรวมในหัวข้อเดียว; ช่วง 63–79 แยก domain; Advice เหลือ action เท่านั้น

- unnecessary semantic duplication: **0**
- normalized full-text duplicate: **0**
- date-only current→next12 duplicate: **0**
- duplicate pair remaining: **0**

ภาพรวมชีวิตยังทำหน้าที่สรุปเส้นเวลาโดยไม่แจกแจงรายละเอียด domain จึงเป็น hierarchy ที่จำเป็น ไม่ใช่การครอบครองรายละเอียดซ้ำ
`;

const contentReview = `# Candidate 0018 Content Review

Status: **CODEX TWO-PASS CONTENT REVIEW COMPLETE — PENDING OWNER CONTENT REVIEW — NOT HUMAN/OWNER PASS**

## รอบที่ 1 — อ่านตั้งแต่ต้นจนจบ

- chronology: ข้อมูลดวง → ภาพรวม → 0–10 → 11–29 → 30–41 → อายุ 44 → current+12m ราย domain → support → 63–79 → advice → disclaimer
- natural Thai: ประโยคสั้น บอกผลก่อน ตัดภาษาระบบ ภาษาหลักฐาน และภาษาที่ปรึกษาธุรกิจ
- firmness: ไม่ใช้ มีแนวโน้ม, น่าจะ, อาจ, อาจจะ หรือ conditional advice ใน prediction
- past directness: อดีตทั้งสามช่วงเป็นประโยคบอกเล่า ไม่มีคำถามหรือคำชวนให้นึกย้อน
- psychology: ไม่มีการสรุปบุคลิก นิสัย แรงจูงใจ หรือตัวตนแทนคำทำนาย
- methodology: prediction ไม่มี selector, Rule Chain, forecast, band, Canon, JSON หรือภาษาหลักฐาน
- Unknown: prediction claims 0; ไม่แทนเวลาเกิด ไม่ยืม Known copy

## รอบที่ 2 — เปรียบเทียบทุกคู่

ตรวจ 15 entries รวม 105 คู่จากข้อความเต็ม ไม่ใช้ชื่อ semanticOwner เป็นหลักฐาน ผลหลังแก้ unnecessary duplicate 0 รายละเอียดงาน เงิน ความสัมพันธ์ สุขภาพ และแรงสนับสนุนมีเจ้าของตำแหน่งเดียว เอกสารคู่ฉบับเต็มอยู่ที่ CANDIDATE_0018_SEMANTIC_DUPLICATION_AUDIT.md

## ขอบเขตคำตัดสิน

การตรวจนี้เป็น Codex content review เท่านั้น Candidate 0018 ยังไม่ใช่ runtime/expected output และยังไม่ผ่าน Owner Content Review
`;

export function buildCandidate0018() {
  const registry = buildResolvedRegistry();
  const byId = new Map(registry.entries.map((entry) => [entry.id, entry]));
  const refs = (claim) => [...(claim.selectorRefs ?? []), ...(claim.domainRefs ?? []), ...(claim.directionRefs ?? []), ...(claim.timingRefs ?? []), ...(claim.conflictRefs ?? []), ...(claim.certaintyRefs ?? [])];
  const usedIds = [...new Set(claims.flatMap(refs))];
  const map = {
    version: 1,
    status: 'OR6_RESOLVED_RULE_CHAIN_MAP_PENDING_OWNER_CONTENT_REVIEW_NOT_RUNTIME',
    fixture: targetFixture,
    evidenceResolutionRef: 'docs/CANDIDATE_0018_EVIDENCE_RESOLUTION.json',
    contractRef: 'knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1.json',
    typedForecastMaterials: registry.entries.filter((entry) => entry.id.startsWith('typed.')).map((entry) => ({ id: entry.id, jsonPointer: entry.locator.jsonPointer, canonicalId: entry.resolvedValue.canonicalId, fixture: entry.resolvedValue.fixture, domain: entry.expectedDomain, horizon: entry.expectedHorizon, band: entry.expectedBandDirection, sourceCommit: entry.sourceCommit })),
    resolvedBindings: Object.fromEntries(usedIds.map((id) => [id, byId.get(id)])),
    known: { claims },
    unknown: { fixture: { birthTimeMode: 'unknown', birthTime: null, ascendant: null, houses: null, thaiAstrologicalDay: null, noonSubstitution: false }, predictionClaims: [], omissionReason: 'MAHABHUT_CONTEXT_SELECTOR_UNAVAILABLE_FAIL_CLOSED', knownCopyBorrowed: false },
    counts: { contentEntries: claims.length, predictionEntries: claims.filter((claim) => claim.classification === 'PREDICTION').length, overviewEntries: 1, adviceEntries: 1, typedForecastMaterials: 12, resolvedBindings: usedIds.length, unknownPredictions: 0 },
  };
  write('docs/CANDIDATE_0018_KNOWN.md', known);
  write('docs/CANDIDATE_0018_UNKNOWN.md', unknown);
  write('docs/CANDIDATE_0017_TO_0018_BEFORE_AFTER.md', beforeAfterMd);
  write('docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.json', `${JSON.stringify(map, null, 2)}\n`);
  write('docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.md', `# Candidate 0018 Resolved Rule-chain Map

Status: **${map.status}**

Every prediction resolves Selector, Domain, Direction, Timing, Conflict handling and Certainty ceiling to CANDIDATE_0018_EVIDENCE_RESOLUTION.json. The map uses ${map.counts.resolvedBindings} actual bindings, including 12 typed forecast rows. Unknown prediction claims remain 0.

| Claim | Section | Domain | Horizon | Band/direction | Reader text |
|---|---|---|---|---|---|
${claims.map((claim) => `| ${claim.claimId} | ${claim.section} | ${claim.expectedDomain ?? 'composed/action'} | ${claim.expectedHorizon ?? 'composed/action'} | ${claim.expectedBandDirection ?? claim.classification} | ${escapeTable(claim.fullReaderText)} |`).join('\n')}
`);
  write('docs/CANDIDATE_0018_SEMANTIC_DUPLICATION_AUDIT.md', semanticAudit);
  write('docs/CANDIDATE_0018_CONTENT_REVIEW.md', contentReview);
  return map;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = buildCandidate0018();
  console.log(JSON.stringify(result.counts, null, 2));
}
