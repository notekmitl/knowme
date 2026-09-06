import { createHash } from 'node:crypto';
export const hash = (x) => createHash('sha256').update(typeof x === 'string' || Buffer.isBuffer(x) ? x : JSON.stringify(x)).digest('hex').toUpperCase();
export const displayRange = (p) => [Math.max(1, p.ageStart), p.ageEnd];
export const rangeIn = (s) => (s.match(/อายุ (\d+)[–-](\d+) ปี/u) || []).slice(1).map(Number);
export const ageIn = (s) => Number(s.match(/อายุ (\d+) ปี/u)?.[1] ?? NaN);
export function ageAt(birthDate, asOf) {
  const b = birthDate.split('-').map(Number), a = asOf.slice(0, 10).split('-').map(Number);
  return a[0] - b[0] - (a[1] < b[1] || (a[1] === b[1] && a[2] < b[2]) ? 1 : 0);
}
export const AGE_KEYS = ['past_section_body_age_mismatch','past_body_source_period_mismatch','current_heading_body_age_mismatch','current_age_period_applicability_error','next_heading_body_age_mismatch','frozen_literal_age_component','missing_completed_past_period','chronology_overlap_or_gap'];
export const DOMAIN_KEYS = ['cross_domain_template_leakage','domain_vocabulary_mismatch','evidence_mismatched_sentence_reuse','identical_sentence_different_material','unsupported_domain_claim'];
export const CONTENT_KEYS = ['past_future_tense','exact_cross_section_duplicate','near_cross_section_duplicate','prediction_advice_leakage','personality_leakage','methodology_leakage','direction_mismatch','domain_mismatch','horizon_mismatch'];
const eq = (a,b) => JSON.stringify(a) === JSON.stringify(b);
const vocabulary = { career: /งาน|บทบาท|ผลงาน|ขอบเขต|อำนาจตัดสินใจ/u, finance: /รายรับ|รายจ่าย|เงินพร้อมใช้|ภาระผูกพัน|ฐานเงิน/u, relationship: /การกระทำ|ข้อตกลง|ระยะห่าง|เวลา|หน้าที่ร่วมกัน/u, health: /กำลัง|การพัก|ฟื้นตัว|ภาระต่อเนื่อง/u, support: /ผู้ใหญ่|ครู|เพื่อน|คนร่วมงาน|ช่วยเปิดทาง/u };
const normalize = (s) => s.replace(/\s|[.,!?—–]/gu, '');
const grams = (s) => new Set(Array.from({length: Math.max(0,s.length-3)}, (_,i)=>s.slice(i,i+4)));
export function similar(a,b) { const x=grams(normalize(a)), y=grams(normalize(b)); return x.size && y.size ? [...x].filter(t=>y.has(t)).length / new Set([...x,...y]).size : 0; }
export function auditReports(reports, library=[]) {
  const counters=Object.fromEntries([...AGE_KEYS,...DOMAIN_KEYS,...CONTENT_KEYS].map(k=>[k,0])), details=[], inspected=[];
  const fail=(code, ref, expected, actual)=>{counters[code]++;details.push({code,ref,expected,actual});};
  for(const c of library) if(/อายุ\s*\d/u.test(c.readerTemplate)) fail('frozen_literal_age_component',c.componentId,'dynamic age placeholder',c.readerTemplate);
  const reuse=new Map();
  for(const r of reports){
    const expectedAge=ageAt(r.input.fixture.birthDate,r.input.asOf);
    if(r.input.fixture.known === false){ if(r.claims.some(x=>x.kind==='prediction'))fail('unsupported_domain_claim',r.id,'Unknown omissions',r.claims); continue; }
    const rows=r.input.periods.filter(p=>p.contextId===r.input.context).sort((a,b)=>a.ageStart-b.ageStart);
    const completed=rows.filter(p=>p.ageEnd<expectedAge);
    const cur=rows.find(p=>p.ageStart<=expectedAge && expectedAge<=p.ageEnd);
    const next=rows.find(p=>cur && p.ageStart===cur.ageEnd+1);
    for(let i=1;i<rows.length;i++)if(rows[i].ageStart!==rows[i-1].ageEnd+1)fail('chronology_overlap_or_gap',r.id,rows[i-1].ageEnd+1,rows[i].ageStart);
    const past=r.claims.filter(c=>c.owner==='past');
    for(const p of completed)if(!past.some(c=>c.sourcePeriod?.matrixApplicationId===p.matrixApplicationId))fail('missing_completed_past_period',r.id,p.matrixApplicationId,null);
    const pastOrder=past.map(c=>c.sourcePeriod?.ageStart);
    if(pastOrder.some((a,i)=>i>0 && a<=pastOrder[i-1]))fail('chronology_overlap_or_gap',r.id,'ascending unique past periods',pastOrder);
    for(const [i,c] of r.claims.entries()){
      const ref=`${r.id}/claims/${i}`;
      if(c.owner==='past'){
        const section=rangeIn(c.heading), body=rangeIn(c.text), source=rows.find(p=>p.matrixApplicationId===c.sourcePeriod?.matrixApplicationId);
        inspected.push({ref,owner:c.owner,section,body,sourcePeriod:source??null,displayPolicy:'source age 0 is displayed as age 1; full source row retained'});
        if(!eq(section,body)||section.length!==2)fail('past_section_body_age_mismatch',ref,section,body);
        if(!source||!eq(body,displayRange(source))||!eq(c.sourcePeriod,source)||source.ageEnd>=expectedAge)fail('past_body_source_period_mismatch',ref,source??null,{body,source:c.sourcePeriod});
        if(/จะ/u.test(c.text))fail('past_future_tense',ref,'past tense',c.text);
      }
      if(c.owner==='current'){
        inspected.push({ref,owner:c.owner,currentAge:expectedAge,heading:ageIn(c.heading),body:ageIn(c.text),sourcePeriod:cur??null});
        if(ageIn(c.heading)!==expectedAge || ageIn(c.text)!==expectedAge)fail('current_heading_body_age_mismatch',ref,expectedAge,[ageIn(c.heading),ageIn(c.text)]);
        if(!cur||!eq(c.sourcePeriod,cur)||r.currentAge!==expectedAge)fail('current_age_period_applicability_error',ref,cur??null,c.sourcePeriod);
      }
      if(c.owner==='next'){
        inspected.push({ref,owner:c.owner,section:rangeIn(c.heading),body:rangeIn(c.text),sourcePeriod:next??null});
        if(!next||!eq(rangeIn(c.heading),displayRange(next))||!eq(rangeIn(c.text),displayRange(next))||!eq(c.sourcePeriod,next))fail('next_heading_body_age_mismatch',ref,next??null,{heading:c.heading,text:c.text,source:c.sourcePeriod});
      }
      if(c.kind!=='prediction')continue;
      if(/(?:การเงิน|ความสัมพันธ์|สุขภาพและการพัก)เดินหน้าจากผลที่ส่งมอบ/u.test(c.text))fail('cross_domain_template_leakage',ref,'domain-specific text',c.text);
      if(vocabulary[c.domain]&&!vocabulary[c.domain].test(c.text))fail('domain_vocabulary_mismatch',ref,c.domain,c.text);
      if(c.domain!=='career' && /ผลงาน|ส่งมอบ|อำนาจตัดสินใจเรื่องงาน/u.test(c.text))fail('domain_vocabulary_mismatch',ref,'no work-vocabulary substitution',c.text);
      const b=c.evidence;
      if(!b||b.status!=='VERIFIED' || !b.authorityRefs?.length || !b.materialSignature || !b.supportedSentences?.includes(c.text))fail('unsupported_domain_claim',ref,'verified full semantic sentence binding',b??null);
      if(b){for(const k of ['direction','domain','horizon'])if(c[k]!==b[k])fail(`${k}_mismatch`,ref,b[k],c[k]);}
      if(/ควร|ลอง|ทบทวน|ให้ใช้|ตัดสินใจจาก/u.test(c.text))fail('prediction_advice_leakage',ref,'prediction',c.text);
      if(/บุคลิก|นิสัย|คุณเป็นคน/u.test(c.text))fail('personality_leakage',ref,'prediction',c.text);
      if(/selector|fingerprint|component|หลักคำนวณ|มหาภูต|ลัคนาบ่งชี้/iu.test(c.text))fail('methodology_leakage',ref,'reader language',c.text);
      const signature=JSON.stringify([c.domain,c.horizon,b?.materialSignature,b?.authorityRefs,b?.sourcePeriodId]);
      const key=normalize(c.text), prior=reuse.get(key);
      if(prior && prior.signature!==signature){fail('identical_sentence_different_material',ref,prior.signature,signature);fail('evidence_mismatched_sentence_reuse',ref,prior.ref,signature);}
      else reuse.set(key,{signature,ref});
    }
    const pred=r.claims.filter(c=>c.kind==='prediction');
    for(let i=0;i<pred.length;i++)for(let j=i+1;j<pred.length;j++)if(pred[i].owner!==pred[j].owner){
      if(normalize(pred[i].text)===normalize(pred[j].text))fail('exact_cross_section_duplicate',r.id,pred[i].owner,pred[j].owner);
      else if(similar(pred[i].text,pred[j].text)>=0.72)fail('near_cross_section_duplicate',r.id,pred[i].text,pred[j].text);
    }
  }
  return {status:details.length?'FAIL':'PASS',counters,details,inspected,limitations:['Near-text character-gram detection is a heuristic, not proof of semantic equivalence.','Zero errors over omitted domain claims is not domain coverage.'],predictionClaimsChecked:reports.reduce((n,r)=>n+r.claims.filter(c=>c.kind==='prediction').length,0)};
}
export function scanGenerator(source){
  const errors=[];
  if(/readFile|node:fs|require\(|import\s*(?:\(|.*?from)/u.test(source.replace(/import .*?from ['"]\.\/or4_content_validator\.mjs['"];?/u,'')))errors.push('generation_external_input');
  if(/CANDIDATE_0011|exactAcceptedText|oracle|readerLines/iu.test(source))errors.push('golden_generation_input');
  if(/replace(?:All)?\([^\n]*(?:00:03|9°24|00:35|19°19)/u.test(source))errors.push('fixture_value_replacement');
  if(/(?:if|case|\?|===|==|switch)[^\n]*(?:1982|00:03|00:35|เชียงใหม่|target|fixtureId|birthTime|gender|province)/iu.test(source))errors.push('fixture_specific_branch');
  return {status:errors.length?'FAIL':'PASS',errors};
}
