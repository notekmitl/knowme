import fs from 'node:fs';
import assert from 'node:assert/strict';
import { buildReaderReport } from './or4_reader_generator.mjs';
import { auditReports, scanGenerator, hash, AGE_KEYS, DOMAIN_KEYS } from './or4_content_validator.mjs';
import { runNegativeControls } from './or4_negative_controls.mjs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const outputs=new Map();
const put=(p,x)=>outputs.set(p,typeof x==='string'?x:JSON.stringify(x,null,2)+'\n');
const historic=read('docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json');
const periods=read('docs/PREDICTIVE_RUNTIME_V2_392_PERIOD_RUNTIME_MAPPING.json').rows;
const neighbor=read('docs/PREDICTIVE_RUNTIME_V2_GOLDEN_NEIGHBOR_COMPARISON.json');
const resolution=read('docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json');
const bindings=read('docs/PREDICTIVE_RUNTIME_V2_CLAIM_LEVEL_BINDINGS.json').bindings;
const months=['มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน','กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'];
const asOf='2026-08-29';
const factComponents=[
  {owner:'past',headingTemplate:'อายุ {ageStart}–{ageEnd} ปี',readerTemplate:'ช่วงอายุ {ageStart}–{ageEnd} ปีผ่านไปแล้ว'},
  {owner:'current',headingTemplate:'คำทำนายปัจจุบัน — อายุ {currentAge} ปี',readerTemplate:'ปัจจุบันอายุ {currentAge} ปี อยู่ในช่วงชีวิตที่เริ่มตั้งแต่อายุ {periodStart} ปีและสิ้นสุดเมื่ออายุ {periodEnd} ปี'},
  {owner:'next',headingTemplate:'ช่วงชีวิตถัดไป — อายุ {nextAgeStart}–{nextAgeEnd} ปี',readerTemplate:'ช่วงถัดไปครอบคลุมอายุ {nextAgeStart}–{nextAgeEnd} ปี'},
].map(c=>({...c,componentId:`OR4-FACT-${c.owner}`,kind:'fact',domain:'life_path',authorityStatus:'EXACT_PERIOD_BOUNDARY_ONLY',source:'docs/PREDICTIVE_RUNTIME_V2_392_PERIOD_RUNTIME_MAPPING.json',ageApplicability:'BOUND_AT_RENDER'}));
// Proposed domain semantics are explicit per domain, never ${domain} noun substitution.
// None is promoted to authorized prediction solely on the strength of a band or evidence-key string.
const proposed={
  work:{domain:'career',event:'role_and_delivery',result:'งานหลักขยายขอบเขตความรับผิดชอบ',risk:'ภาระงานเดิมจำกัดเวลาสำหรับบทบาทที่เพิ่มขึ้น',text:'งานหลักขยายขอบเขตความรับผิดชอบ แต่ภาระเดิมยังจำกัดเวลาสำหรับบทบาทที่เพิ่มขึ้น'},
  finance:{domain:'finance',event:'cash_and_commitments',result:'รายรับเพิ่มพื้นที่ของเงินพร้อมใช้',risk:'รายจ่ายผูกพันลดเงินที่เหลือเก็บ',text:'รายรับเพิ่มพื้นที่ของเงินพร้อมใช้ ขณะที่รายจ่ายผูกพันลดเงินที่เหลือเก็บ'},
  relationship:{domain:'relationship',event:'agreement_and_distance',result:'ข้อตกลงชัดขึ้นจากการกระทำ',risk:'เวลาและหน้าที่ร่วมกันยังไม่ลงตัว',text:'ข้อตกลงชัดขึ้นจากการกระทำ แต่เวลาและหน้าที่ร่วมกันยังไม่ลงตัว'},
  health:{domain:'health',event:'rest_and_recovery',result:'กำลังฟื้นกลับจากการพัก',risk:'ภาระต่อเนื่องใช้เวลาฟื้นตัวมากขึ้น',text:'กำลังฟื้นกลับจากการพัก แต่ภาระต่อเนื่องทำให้ใช้เวลาฟื้นตัวมากขึ้น'},
  support:{domain:'support',event:'support_from_people',result:'ผู้ใหญ่และคนร่วมงานช่วยเปิดทาง',risk:'ขอบเขตความช่วยเหลือต้องมีหลักฐานรองรับ',text:'ผู้ใหญ่และคนร่วมงานช่วยเปิดทางให้เรื่องที่ติดขัดเดินต่อ'},
};
const seen=new Set(),components=[...factComponents];
for(const b of bindings){
  if(!proposed[b.semanticOwner])continue;
  const key=JSON.stringify([b.semanticOwner,b.materialFingerprint]);if(seen.has(key))continue;seen.add(key);
  const p=proposed[b.semanticOwner];
  components.push({componentId:`OR4-PROPOSAL-${hash(key).slice(0,12)}`,kind:'prediction',owner:b.semanticOwner,domain:p.domain,horizon:b.horizon,direction:b.directionBand,materialSignature:b.materialFingerprint,headingTemplate:b.semanticOwner,readerTemplate:p.text,event:p.event,result:p.result,risk:p.risk,authorityStatus:'UNVERIFIED_NOT_EMITTABLE',sourceBinding:{repositoryPath:'docs/PREDICTIVE_RUNTIME_V2_CLAIM_LEVEL_BINDINGS.json',evidenceKey:b.evidenceKey,sourceComponents:b.sourceComponents,limitation:'Historical serialized key is not a resolved full-sentence interpretation chain.'},ageApplicability:'BOUND_AT_RENDER',forbiddenCombinations:['material-only authorization','cross-domain noun replacement','unresolved conflict','stronger event outcome than source']});
}
const library={status:'FACT_RENDERER_READY_DOMAIN_COMPONENTS_UNVERIFIED',components,counts:{factComponents:factComponents.length,proposedDomainComponents:components.length-factComponents.length,verifiedPredictionComponents:0},boundary:'Proposed reader templates are review material only; not emitted, not counted as supported coverage.'};
put('docs/OR4_COMPONENT_LIBRARY.json',library);
put('docs/OR4_COMPONENT_LIBRARY.md','# OR4 Component Library\n\nDomain text below is UNVERIFIED and not emitted. No component embeds an age literal. Fact placeholders are bound from the current source period.\n\n'+components.map(c=>`## ${c.componentId}\n\nOwner: ${c.owner}; domain: ${c.domain}; status: ${c.authorityStatus}\n\n${c.readerTemplate}\n`).join('\n'));
const profiles=[];
for(const [context,c] of Object.entries(historic.contexts)){
  const line=c.readerLines.find(x=>x.startsWith('เกิดวันที่'));
  const m=line.match(/เกิดวันที่ (\d+) (\S+) (\d+) เวลา (\d+:\d+) น\. จังหวัด(.+)/u);assert(m,context);
  const fixture={known:true,birthDate:`${Number(m[3])-543}-${String(months.indexOf(m[2])+1).padStart(2,'0')}-${m[1].padStart(2,'0')}`,time:m[4],location:m[5],ascendant:c.readerLines.find(x=>x.startsWith('ลัคนา'))};
  const typedMaterials=c.claims.filter(x=>x.binding?.materialFingerprint).map(x=>({owner:x.semanticOwner,signature:x.binding.materialFingerprint,sourceComponents:x.binding.sourceComponents,origin:'historical-OR2-export'}));
  const input={fixture,asOf,context,periods:periods.filter(p=>p.contextId===context),typedMaterials,evidenceBindings:[],componentLibrary:components};
  profiles.push(buildReaderReport(input));
}
const targetInput={fixture:{known:true,birthDate:'1982-06-06',time:'00:35',location:'เชียงใหม่',sex:'ชาย',ascendant:'ลัคนาราศีกุมภ์ 19°19′'},asOf,context:neighbor.generalized00_35.contextId,periods:periods.filter(p=>p.contextId===neighbor.generalized00_35.contextId),typedMaterials:[],evidenceBindings:[],componentLibrary:components};
const target=buildReaderReport(targetInput),again=buildReaderReport(structuredClone(targetInput));
assert.deepEqual(target,again);
assert.equal(target.resolved.current.matrixApplicationId,neighbor.generalized00_35.currentPeriod);
const unknown=buildReaderReport({...targetInput,fixture:{known:false,birthDate:'1982-06-06'},context:null,periods:[],typedMaterials:[],evidenceBindings:[]});
const weekdays=['sunday','monday','tuesday','wednesday','thursday','friday','saturday'];
const reps=weekdays.map(d=>profiles.find(r=>r.input.context.endsWith('.'+d)));
for(const p of [...profiles].sort((a,b)=>a.currentAge-b.currentAge))if(reps.length<11&&!reps.includes(p))reps.push(p);
reps.push(unknown);
const all=[...profiles,target,unknown];
const audit=auditReports(all,components);
const sourceScan=scanGenerator(fs.readFileSync('tool/or4_reader_generator.mjs','utf8'));
assert.equal(sourceScan.status,'PASS',JSON.stringify(sourceScan));
// The reference is first read here, strictly after all report generation. It is never an input.
const oracleFile='docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md';
const oracle=fs.readFileSync(oracleFile,'utf8').replaceAll('\r\n','\n');
const block=oracle.split('Reader-facing candidate begins below.')[1].split('Reader-facing candidate ends above.')[0].trim();
assert.equal(hash(block),'6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
const claims=[...block.matchAll(/<!-- readerClaimId: ([^ ]+) -->\n([^\n]+)/g)].map(m=>({id:m[1],expected:m[2],present:target.claims.some(c=>c.text===m[2])}));
const comparison={comparisonOnly:true,readAfterGeneration:true,referencePath:oracleFile,readerSha256:hash(block),generatedReportSha256:hash(target.readerText),predictionParagraphsExpected:22,predictionParagraphsGenerated:target.claims.filter(c=>c.kind==='prediction').length,exactPredictionMatches:claims.filter(c=>!c.id.includes('ADVICE')&&!c.id.includes('DISCLOSURE')&&c.present).length,claims,conclusion:'NOT_EQUIVALENT_OMITTED_INSUFFICIENT_INPUT_BOUND_AUTHORITY'};
const artifactReport=r=>({id:r.id,input:{...r.input,componentLibrary:undefined},componentLibraryRef:'docs/OR4_COMPONENT_LIBRARY.json#/components',componentLibrarySha256:hash(r.input.componentLibrary),currentAge:r.currentAge,resolved:r.resolved,claims:r.claims,omissions:r.omissions,readerText:r.readerText,generator:r.generator,inputHash:r.inputHash,rollingHorizon:r.rollingHorizon});
put('docs/CANDIDATE_0020_ACTUAL_0035.json',artifactReport(target));
put('docs/CANDIDATE_0020_ACTUAL_0035.md','# Candidate 0020 Actual 00:35 — incomplete, NO-GO\n\nGenerated by buildReaderReport, same function as all 49 contexts. Prediction paragraphs: 0/22. Only exact age/period facts are rendered. Domain predictions, overview, summary and advice are omitted because a complete interpretation chain bound to this input is unavailable. This is a blocker reproduction, not the requested complete predictive report.\n\n'+target.readerText+'\n\n## Omission ledger\n\n'+target.omissions.map(x=>`- ${x.owner}: ${x.reason}`).join('\n')+'\n');
put('docs/OR4_GOLDEN_COMPARISON.json',comparison);
put('docs/OR4_49_CONTEXT_SIMULATION.json',{machineContentAudit:'FAIL',structuralValidation:audit.status,ownerHumanReview:'PENDING',productContentStatus:'NO_GO',contexts:profiles.length,profiles:profiles.map(artifactReport)});
put('docs/OR4_REPRESENTATIVE_FULL_COPY.md','# OR4 Representative Full Output — NO-GO\n\nThese are the complete generated outputs, including all omissions; not complete predictive reports. Known 11, Unknown 1.\n\n'+reps.map(r=>`## ${r.input.context??'Unknown'} · age ${r.currentAge}\n\n${r.readerText}\n\nOmissions: ${r.omissions.map(o=>`${o.owner} (${o.reason})`).join('; ')}\n`).join('\n'));
put('docs/OR4_REPRESENTATIVE_FULL_COPY.json',{known:11,unknown:1,profiles:reps.map(artifactReport)});
const subset=keys=>({counters:Object.fromEntries(keys.map(k=>[k,audit.counters[k]])),details:audit.details.filter(d=>keys.includes(d.code)),inspected:audit.inspected,interpretation:'Zero invalid emitted claims; not evidence that omitted claims are supported.'});
put('docs/OR4_AGE_BINDING_AUDIT.json',subset(AGE_KEYS));
const ownerReuse={};for(const r of profiles)for(const c of r.claims){ownerReuse[c.owner]??={};ownerReuse[c.owner][c.text]=(ownerReuse[c.owner][c.text]??0)+1;}
put('docs/OR4_DOMAIN_LANGUAGE_AUDIT.json',{...subset(DOMAIN_KEYS),predictionClaimsChecked:audit.predictionClaimsChecked,omissionCount:all.reduce((n,r)=>n+r.omissions.length,0),reuse:Object.fromEntries(['past','current','next','work','finance','relationship','health','support','rolling12'].map(k=>[k,{distinct:Object.keys(ownerReuse[k]??{}).length,maxReuse:Math.max(0,...Object.values(ownerReuse[k]??{})),emittedPredictionTexts:0,texts:ownerReuse[k]??{}}])),proposedTemplatesStatus:'UNVERIFIED; intentionally excluded from emitted-claim counters'});
put('docs/OR4_CONTENT_AUDIT.json',{...audit,machineContentAudit:'FAIL',ownerHumanReview:'PENDING',productContentStatus:'NO_GO',reason:'Prediction coverage is 0; source-complete content not demonstrated.',known49FullPredictionCoverage:0,expectedKnownContexts:49,candidate0020FullPredictionCoverage:0,sourceScan,determinism:{runs:2,identical:JSON.stringify(target)===JSON.stringify(again),hashes:[hash(target),hash(again)]}});
put('docs/OR4_NEGATIVE_CONTROLS.json',runNegativeControls());
const typed=resolution.entries.filter(e=>e.id.startsWith('typed.'));
const feasibility={status:'CONTENT_FOUNDATION_NO_GO',machineContentAudit:'FAIL',ownerHumanReview:'PENDING',productContentStatus:'NO_GO',runtime:'NO_GO',singlePathRenderer:true,completeCandidate0020:false,findings:[
  {code:'ACTUAL_0035_BINDINGS_NOT_EXPORTED',source:'test/evidence/predictive_runtime_v2_or1_evidence_test.dart',symbol:'_goldenNeighborComparison.item',jsonPointer:'/generalized00_35',availableFields:Object.keys(neighbor.generalized00_35),missing:['typedMaterials','claim bindings','resolved Canon domain refs'],consequence:'Do not infer material equality from similar reader text or shared context.'},
  {code:'AVAILABLE_TYPED_FIXTURE_DIFFERENT',source:'docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json',typedGenerationFixture:resolution.typedGenerationFixture,required:{birthTime:'00:35',asOf},consequence:'Existing 00:03 / 2026-08-07 typed records cannot be relabelled as 00:35 / 2026-08-29.'},
  {code:'CONTEXT_REPRESENTATIVE_NOT_TARGET',source:'docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json',context:targetInput.context,representativeCurrentPeriod:historic.contexts[targetInput.context].currentPeriod,targetCurrentPeriod:target.resolved.current,consequence:'Same context alone is not profile/material equivalence.'},
  {code:'DOMAIN_TEMPLATE_UNVERIFIED',source:'docs/OR4_COMPONENT_LIBRARY.json',proposedComponents:components.length-3,verified:0,consequence:'The interpretation contract permits composed claims but requires resolved domain, direction, timing, conflict and certainty. OR3 prose/band metadata do not prove that chain.'},
],existingAuthorityRecognized:'Owner-authorized Product Interpretation Contract V1 and Candidate 0011 acceptance are retained. No claim is made that all Canon domain authority is absent.',typedRecordsReviewed:typed.map(e=>({id:e.id,fixture:e.fixtureInput,domain:e.expectedDomain,horizon:e.expectedHorizon})),requiredNextEvidence:['Export actual input-bound typed materials and resolved claim chains for 00:35 at 2026-08-29; use existing runtime read-only in a separately scoped extraction step.','Resolve Canon domain + material direction/timing + conflict/certainty into approved full-sentence meanings for every emitted component.','Then regenerate with this one renderer and compare to the immutable oracle; do not fill gaps by copying accepted text.']};
put('docs/OR4_SEMANTIC_FEASIBILITY.json',feasibility);
put('docs/OR4_SEMANTIC_FEASIBILITY.md','# OR4 Semantic Feasibility — NO-GO\n\nThe pure renderer runs on all 49 contexts and on Actual 00:35. It emits period facts and omits unsupported predictions. Candidate 0020 therefore does not meet the requested full predictive report or 22-paragraph oracle.\n\n'+feasibility.findings.map(x=>`- ${x.code}: ${x.consequence}`).join('\n')+'\n\nExisting Owner-authorized interpretation and Canon authorities remain valid within their boundaries. Missing exported profile-bound chains must be supplied and semantically resolved before the reader template can be authorized. Runtime source remains unchanged, with the old golden special case still present on this PR branch; this run does not establish what Production executes.\n');
put('docs/OR4_GENERATION_TRACE.json',{function:'buildReaderReport',implementation:'tool/or4_reader_generator.mjs',sourceSha256:hash(fs.readFileSync('tool/or4_reader_generator.mjs')),externalReads:sourceScan,inputs:all.map(r=>({reportId:r.id,inputHash:r.inputHash,fixture:r.input.fixture,asOf:r.input.asOf,context:r.input.context,currentAge:r.currentAge,resolved:r.resolved,typedMaterials:r.input.typedMaterials,claimComponents:r.claims.map(c=>({id:c.componentId,args:c.renderArguments,source:c.sourcePeriod})),omissions:r.omissions})),oracleComparedAfterGeneration:true});
for(const [p,body] of outputs)if(process.argv.includes('--check'))assert.equal(fs.readFileSync(p,'utf8').replaceAll('\r\n','\n'),body,p);else fs.writeFileSync(p,body);
console.log(JSON.stringify({status:feasibility.status,files:outputs.size,contexts:profiles.length,candidatePredictions:comparison.predictionParagraphsGenerated,ageCounters:subset(AGE_KEYS).counters,domainCounters:subset(DOMAIN_KEYS).counters,negativeControls:runNegativeControls().rejected,structural:audit.status}));
