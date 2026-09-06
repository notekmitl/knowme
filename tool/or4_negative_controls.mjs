import { auditReports, scanGenerator } from './or4_content_validator.mjs';
const period=(start,end)=>({contextId:'test.context',matrixApplicationId:`test.${start}_${end}`,ageStart:start,ageEnd:end});
export function validTestReport(){
  const periods=[period(0,10),period(11,29),period(30,41),period(42,62),period(63,79)];
  return {id:'validator-unit-only',input:{fixture:{birthDate:'1982-06-06',known:true},asOf:'2026-08-29',context:'test.context',periods},currentAge:44,claims:[
    ...periods.slice(0,3).map(p=>({owner:'past',kind:'fact',heading:`อายุ ${Math.max(1,p.ageStart)}–${p.ageEnd} ปี`,text:`ช่วงอายุ ${Math.max(1,p.ageStart)}–${p.ageEnd} ปีผ่านไปแล้ว`,sourcePeriod:p})),
    {owner:'current',kind:'fact',heading:'คำทำนายปัจจุบัน — อายุ 44 ปี',text:'ปัจจุบันอายุ 44 ปี',sourcePeriod:periods[3]},
    {owner:'next',kind:'fact',heading:'ช่วงชีวิตถัดไป — อายุ 63–79 ปี',text:'ช่วงถัดไปเริ่มที่อายุ 63–79 ปี',sourcePeriod:periods[4]},
  ]};
}
export function testPrediction(owner='work',domain='career',text='งานขยายบทบาทและอำนาจตัดสินใจ'){
  return {owner,kind:'prediction',domain,horizon:'current',direction:'strong',text,evidence:{status:'VERIFIED',authorityRefs:['synthetic-unit-test-only'],supportedSentences:[text],materialSignature:`synthetic-${domain}`,domain,horizon:'current',direction:'strong',sourcePeriodId:'test.42_62'}};
}
export function runNegativeControls(){
  const cases=[];
  const check=(name,code,mutate,library=[])=>{const r=validTestReport();r.claims.push(testPrediction());mutate(r);const a=auditReports([r],library);cases.push({name,expectedCode:code,rejected:a.counters[code]>0,observedErrors:a.details});};
  check('past section/body','past_section_body_age_mismatch',r=>r.claims[0].text='ช่วงอายุ 2–10 ปีผ่านไปแล้ว');
  check('wrong source period','past_body_source_period_mismatch',r=>r.claims[0].sourcePeriod=period(0,9));
  check('current/start-age confusion','current_heading_body_age_mismatch',r=>r.claims[3].text='อายุ 42 ปี');
  check('frozen first-binding age','frozen_literal_age_component',()=>{},[{componentId:'bad',readerTemplate:'อายุ 42 ปี'}]);
  check('period applicability','current_age_period_applicability_error',r=>r.claims[3].sourcePeriod=period(30,41));
  check('next age','next_heading_body_age_mismatch',r=>r.claims[4].text='ช่วงอายุ 64–79 ปี');
  check('missing past','missing_completed_past_period',r=>r.claims.splice(1,1));
  check('gap','chronology_overlap_or_gap',r=>r.input.periods[1].ageStart=12);
  check('past future','past_future_tense',r=>r.claims[0].text+=' จะเกิดขึ้น');
  check('domain noun substitution','cross_domain_template_leakage',r=>r.claims.push(testPrediction('finance','finance','การเงินเดินหน้าจากผลที่ส่งมอบต่อเนื่อง')));
  for(const d of ['finance','relationship','health'])check(`work vocabulary into ${d}`,'domain_vocabulary_mismatch',r=>r.claims.push(testPrediction(d,d,'ผลงานที่ส่งมอบขยายอำนาจตัดสินใจเรื่องงาน')));
  check('unsupported authority','unsupported_domain_claim',r=>r.claims.at(-1).evidence.authorityRefs=[]);
  for(const k of ['direction','domain','horizon'])check(`${k} mismatch`,`${k}_mismatch`,r=>r.claims.at(-1)[k]='corrupted');
  check('exact cross-section','exact_cross_section_duplicate',r=>r.claims.push({...structuredClone(r.claims.at(-1)),owner:'rolling12'}));
  check('near cross-section','near_cross_section_duplicate',r=>r.claims.push(testPrediction('rolling12','career','งานขยายบทบาทและอำนาจตัดสินใจเพิ่ม')));
  check('advice leakage','prediction_advice_leakage',r=>r.claims.at(-1).text+=' ควรเลือกงาน');
  check('personality leakage','personality_leakage',r=>r.claims.at(-1).text+=' คุณเป็นคนอดทน');
  check('methodology leakage','methodology_leakage',r=>r.claims.at(-1).text+=' selector ชี้ผล');
  check('material reuse','identical_sentence_different_material',r=>r.claims.push({...structuredClone(r.claims.at(-1)),evidence:{...r.claims.at(-1).evidence,materialSignature:'different'}}));
  const sources=[['Golden oracle input','golden_generation_input',"const template=readFileSync('CANDIDATE_0011.md')"],['fixture string replacement','fixture_value_replacement',"text.replaceAll('00:03','00:35')"],['fixture branch','fixture_specific_branch',"if(fixture.birthTime === '00:35') return fixed;"],['external import','generation_external_input',"import fs from 'node:fs';"]];
  for(const [name,expectedCode,source] of sources){const s=scanGenerator(source);cases.push({name,expectedCode,source,rejected:s.errors.includes(expectedCode),observedErrors:s.errors});}
  return {status:cases.every(x=>x.rejected)?'PASS':'FAIL',controls:cases.length,rejected:cases.filter(x=>x.rejected).length,positiveControl:auditReports([validTestReport()]).status,cases};
}
