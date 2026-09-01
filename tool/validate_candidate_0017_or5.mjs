#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const read = (file) => JSON.parse(fs.readFileSync(path.join(root, file), 'utf8'));
const text = (file) => fs.readFileSync(path.join(root, file), 'utf8');

export function validateCandidate0017() {
  const contract = read('knowledge/canon/proposed/PRODUCT_INTERPRETATION_CONTRACT_V1.json');
  const map = read('docs/CANDIDATE_0017_RULE_CHAIN_MAP.json');
  const known = text('docs/CANDIDATE_0017_KNOWN.md');
  const unknown = text('docs/CANDIDATE_0017_UNKNOWN.md');
  const errors = [];
  const add = (code, detail) => errors.push({ code, detail });
  const roles = ['selectorRef', 'domainRef', 'directionRef', 'timingRef', 'conflictRefs'];
  if (contract.typedForecastRule.standalonePredictionAllowed !== false || contract.constraints.placementOnlyPredictionAllowed !== false) add('CONTRACT_BOUNDARY', 'typed/placement');
  if (map.typedForecastMaterials.length !== 12) add('TYPED_MATERIAL_COUNT', String(map.typedForecastMaterials.length));
  const claims = map.known.claims;
  if (claims.length !== 15) add('CLAIM_ENTRY_COUNT', String(claims.length));
  for (const claim of claims) {
    for (const role of roles) if (!Array.isArray(claim[role]) || claim[role].length === 0) add('CHAIN_COMPONENT_MISSING', `${claim.claimId}:${role}`);
    if (!known.includes(claim.fullReaderText)) add('READER_TEXT_NOT_EXACT', claim.claimId);
    if ([...claim.selectorRef, ...claim.domainRef, ...claim.directionRef, ...claim.timingRef, ...claim.conflictRefs].includes(claim.claimId)) add('SELF_REFERENCE', claim.claimId);
    if (!claim.allowedSpecificity || !claim.readerCertainty || !claim.semanticOwner || !Array.isArray(claim.prohibitedSpecificity) || !Array.isArray(claim.evidenceOwnerIds)) add('CLAIM_FIELD_MISSING', claim.claimId);
  }
  if (new Set(claims.map((claim) => claim.semanticOwner)).size !== claims.length) add('DUPLICATE_SEMANTIC_OWNER', 'Known');
  const prediction = claims.filter((claim) => claim.classification === 'PREDICTION');
  if (prediction.length !== 13) add('PREDICTION_COUNT', String(prediction.length));
  if (prediction.some((claim) => /(?:^|[.!?\n]\s*)(?:ควร|แนะนำ|ลอง|จง|ให้|รับ|เลือก|จัด|รักษา|กัน|ตกลง)(?:\s|$)/u.test(claim.fullReaderText))) add('PREDICTION_ADVICE_CONVERSION', 'Known');
  if (/มีแนวโน้ม|น่าจะ|อาจจะ|ชีวิตดีขึ้นโดยรวม|เรื่องที่อยู่ตรงหน้า|เริ่มขยับ|ลองทบทวน|ลองย้อน|คุณเป็นคน/u.test(known)) add('PROHIBITED_READER_LANGUAGE', 'Known');
  const predictionText = prediction.map((claim) => claim.fullReaderText).join('\n');
  if (/ดาว|เรือน|หลักฐาน|Rule|selector|forecast|band/u.test(predictionText)) add('METHODOLOGY_LEAK', 'Known predictions');
  const headings = ['1. ข้อมูลดวง','2. ภาพรวมชีวิต','3. อดีต อายุ 0–10 ปี','4. อดีต อายุ 11–29 ปี','5. อดีต อายุ 30–41 ปี','6. ปัจจุบัน อายุ 44 ปี','7. การงาน','8. การเงิน','9. ความรักและความสัมพันธ์','10. สุขภาพ','11. โชคลาภและแรงสนับสนุน','12. แนวโน้ม 12 เดือนข้างหน้า','13. ช่วงชีวิตถัดไป อายุ 63–79 ปี','14. คำแนะนำ','15. ข้อจำกัด'];
  let previous = -1;
  for (const heading of headings) { const at = known.indexOf(heading); if (at < 0 || at <= previous) add('SECTION_ORDER', heading); previous = at; }
  if (map.unknown.predictionClaims.length !== 0 || map.unknown.fixture.noonSubstitution !== false || map.unknown.fixture.ascendant !== null || map.unknown.fixture.houses !== null || map.unknown.fixture.thaiAstrologicalDay !== null || map.unknown.knownCopyBorrowed !== false) add('UNKNOWN_FAIL_CLOSED', 'map');
  if (!/เว้นลัคนา เรือน วันทางโหราศาสตร์/u.test(unknown) || !/ไม่แทนเวลาเกิดด้วยเวลาอื่น/u.test(unknown)) add('UNKNOWN_COPY_BOUNDARY', 'Unknown');
  const status = errors.length === 0 ? 'PASS_CONTENT_FIRST_RULE_CHAIN_PENDING_OWNER_REVIEW_NOT_RUNTIME' : 'FAIL';
  return {version: 1, status, counts: {chainEntries: claims.length, predictionEntries: prediction.length, typedForecastMaterials: map.typedForecastMaterials.length, missingComponents: errors.filter((e) => e.code === 'CHAIN_COMPONENT_MISSING').length, selfReferences: errors.filter((e) => e.code === 'SELF_REFERENCE').length, duplicateSemanticOwners: errors.filter((e) => e.code === 'DUPLICATE_SEMANTIC_OWNER').length, predictionAdviceConversions: errors.filter((e) => e.code === 'PREDICTION_ADVICE_CONVERSION').length, personalityOrProhibitedLanguage: errors.filter((e) => e.code === 'PROHIBITED_READER_LANGUAGE').length, methodologyLeaks: errors.filter((e) => e.code === 'METHODOLOGY_LEAK').length, unknownPredictionClaims: map.unknown.predictionClaims.length, errors: errors.length}, errors};
}

if (import.meta.url === `file:///${process.argv[1].replaceAll('\\', '/')}`) {
  const result = validateCandidate0017();
  fs.writeFileSync(path.join(root, 'docs/CANDIDATE_0017_VALIDATION.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
  console.log(JSON.stringify(result, null, 2));
  if (result.status === 'FAIL') process.exitCode = 1;
}
