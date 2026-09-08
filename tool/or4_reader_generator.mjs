import { ageAt, displayRange, hash } from './or4_content_validator.mjs';

// Pure evidence renderer: no file/network access. Inputs are explicit and traced.
export function buildReaderReport(input) {
  const allowed=['fixture','asOf','context','periods','typedMaterials','evidenceBindings','componentLibrary'];
  if(Object.keys(input).some(k=>!allowed.includes(k)))throw new Error('UNDECLARED_GENERATION_INPUT');
  const {fixture,asOf,context,periods,typedMaterials,evidenceBindings,componentLibrary}=input;
  const currentAge=ageAt(fixture.birthDate,asOf);
  const report={id:hash([fixture,asOf,context]).slice(0,16),generator:'buildReaderReport-v1',inputHash:hash(input),input,currentAge,claims:[],omissions:[],resolved:{completed:[],current:null,next:null},monthlyTimelineAvailable:false};
  const render=(owner,p,values)=>{
    const c=componentLibrary.find(x=>x.owner===owner && x.kind==='fact');
    if(!c)throw new Error('MISSING_FACT_COMPONENT');
    const bind=t=>t.replace(/\{(\w+)\}/g,(_,k)=>{if(!(k in values))throw new Error('UNBOUND_PLACEHOLDER');return String(values[k]);});
    report.claims.push({owner,kind:'fact',heading:bind(c.headingTemplate),text:bind(c.readerTemplate),componentId:c.componentId,sourcePeriod:p,renderArguments:values});
  };
  if(!fixture.known){
    report.omissions.push({owner:'all-time-dependent',reason:'UNKNOWN_TIME',source:'birthTimeKnown=false'});
    report.readerText='รายงานกรณีไม่ทราบเวลาเกิด\n\nไม่มีเวลาเกิด รายงานจึงเว้นลัคนา เรือน และคำทำนายที่ต้องใช้เวลาเกิด\n\nคำทำนายเป็นมุมมองตามความเชื่อ ใช้ประกอบข้อมูลจริงก่อนตัดสินใจเรื่องสำคัญ';
    return report;
  }
  const rows=periods.filter(p=>p.contextId===context).sort((a,b)=>a.ageStart-b.ageStart);
  const current=rows.find(p=>p.ageStart<=currentAge && currentAge<=p.ageEnd);
  if(!current)throw new Error('CURRENT_PERIOD_NOT_RESOLVED');
  const completed=rows.filter(p=>p.ageEnd<currentAge),next=rows.find(p=>p.ageStart===current.ageEnd+1);
  report.resolved={completed,current,next:next??null};
  for(const p of completed){const [ageStart,ageEnd]=displayRange(p);render('past',p,{ageStart,ageEnd});}
  render('current',current,{currentAge,periodStart:current.ageStart,periodEnd:current.ageEnd});
  if(next){const [nextAgeStart,nextAgeEnd]=displayRange(next);render('next',next,{nextAgeStart,nextAgeEnd});}
  // A serialized forecast band is insufficient: full interpretation and current input binding are required.
  for(const owner of ['overview','past','current','work','finance','relationship','health','support','rolling12','next','summary','advice']){
    const materials=typedMaterials.filter(m=>m.owner===owner);
    const matches=materials.flatMap(m=>componentLibrary.filter(c=>c.kind==='prediction' && c.owner===owner && c.materialSignature===m.signature).map(c=>({m,c})));
    let emitted=0;
    for(const {m,c} of matches){
      const b=evidenceBindings.find(b=>b.componentId===c.componentId && b.context===context && b.age===currentAge && b.asOf===asOf && b.materialSignature===m.signature);
      if(c.authorityStatus!=='VERIFIED' || !b || b.status!=='VERIFIED' || !b.supportedSentences?.includes(c.readerTemplate) || !b.authorityRefs?.length)continue;
      report.claims.push({owner,kind:'prediction',heading:c.headingTemplate,text:c.readerTemplate,componentId:c.componentId,domain:c.domain,direction:c.direction,horizon:c.horizon,evidence:b});emitted++;
    }
    if(!emitted)report.omissions.push({owner,reason:materials.length?'MISSING_RESOLVED_DOMAIN_DIRECTION_TIMING_INTERPRETATION_CHAIN':'NO_INPUT_BOUND_TYPED_MATERIAL',attemptedMaterialSignatures:materials.map(m=>m.signature),proposedComponentIds:matches.map(x=>x.c.componentId),required:'selector + Canon domain + direction + timing + conflict + certainty + full-sentence interpretation; bound to this input'});
  }
  const rangeStart=asOf.slice(0,10),end=new Date(`${rangeStart}T00:00:00Z`);end.setUTCFullYear(end.getUTCFullYear()+1);end.setUTCDate(end.getUTCDate()-1);
  report.rollingHorizon={start:rangeStart,end:end.toISOString().slice(0,10)};
  report.readerText=[
    'ข้อมูลช่วงชีวิต',`วันเกิด ${fixture.birthDate} · เวลา ${fixture.time} · ${fixture.location}`,
    fixture.ascendant??'', 'คำทำนายที่ยังไม่มีหลักฐานครบถูกเว้นไว้ในรายงานนี้',
    ...report.claims.flatMap(c=>[c.heading,c.text]),
    `ช่วง 12 เดือนข้างหน้า: ${report.rollingHorizon.start} – ${report.rollingHorizon.end}`,
    'คำทำนายเป็นมุมมองตามความเชื่อ ใช้ประกอบข้อมูลจริงก่อนตัดสินใจเรื่องสำคัญ',
  ].filter(Boolean).join('\n\n');
  return report;
}
