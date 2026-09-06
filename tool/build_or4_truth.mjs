import fs from 'node:fs';
import assert from 'node:assert/strict';
import { hash, rangeIn, ageIn } from './or4_content_validator.mjs';
const old=JSON.parse(fs.readFileSync('docs/CANDIDATE_0019_49_CONTEXT_SIMULATION.json','utf8'));
const source=fs.readFileSync('tool/build_predictive_editorial_candidate_0019.mjs','utf8');
const details=[], affected=new Set();let past=0,current=0;
const reuse={};
for(const r of old.simulations){
  for(const [i,c] of r.claims.entries()){
    if(c.semanticOwner==='past'){past++;if(JSON.stringify(rangeIn(c.section))!==JSON.stringify(rangeIn(c.text))){affected.add(r.contextId);details.push({type:'past',context:r.contextId,index:i,section:c.section,body:c.text});}}
    if(c.semanticOwner==='current' && ageIn(c.section)!==ageIn(c.text)){current++;details.push({type:'current',context:r.contextId,index:i,section:c.section,body:c.text});}
    if(['work','finance','relationship','health','rolling12'].includes(c.semanticOwner)){reuse[c.semanticOwner]??={};reuse[c.semanticOwner][c.text]=(reuse[c.semanticOwner][c.text]??0)+1;}
  }
}
const report={status:'OR3_PARTIAL_MACHINE_STRUCTURE_ONLY_CONTENT_REJECTED',ownerHumanReview:'PENDING',productContentStatus:'NO_GO',runtimeStatus:'NO_GO',counts:{pastClaims:past,pastAgeMismatch:details.filter(x=>x.type==='past').length,pastAffectedContexts:affected.size,currentAgeMismatch:current},reuse:Object.fromEntries(Object.entries(reuse).map(([k,v])=>[k,{distinct:Object.keys(v).length,maxReuse:Math.max(...Object.values(v)),texts:v}])),findings:{goldenDerivedPresentation:source.includes(".replaceAll('00:03', '00:35')"),hardcodedNegativeControlResults:source.includes("rejected: true"),singlePathProof:false,elevenCountersOmittedAgeAndDomainChecks:true},details,historicalSimulationSha256:hash(fs.readFileSync('docs/CANDIDATE_0019_49_CONTEXT_SIMULATION.json')),historicalBuilderSha256:hash(fs.readFileSync('tool/build_predictive_editorial_candidate_0019.mjs'))};
const md=`# OR3 truth correction — OR4 independent recomputation\n\nOR3 machine structure work passed only in part. Candidate 0019 is Golden-derived presentation, not generalized output. The 11 former zero counters did not measure age binding or domain-language defects. Prior negative controls stored rejected=true instead of executing mutations. Owner Content Acceptance has not occurred. Product Content and Runtime remain NO_GO.\n\nPast claims ${past}; section/body mismatch ${report.counts.pastAgeMismatch}/${past}; affected contexts ${affected.size}/49; current heading/body mismatch ${current}/49.\n\n${Object.entries(report.reuse).map(([k,v])=>`- ${k}: distinct ${v.distinct}; maximum reuse ${v.maxReuse}/49`).join('\n')}\n\nHistorical OR3 files and ZIP are preserved unchanged. Exact offending text and per-claim references are in OR4_TRUTH_CORRECTION.json.\n`;
for(const [file,body] of [['docs/OR4_TRUTH_CORRECTION.json',JSON.stringify(report,null,2)+'\n'],['docs/OR4_TRUTH_CORRECTION.md',md]]){if(process.argv.includes('--check'))assert.equal(fs.readFileSync(file,'utf8').replaceAll('\r\n','\n'),body,file);else fs.writeFileSync(file,body);}
console.log(JSON.stringify({counts:report.counts,reuse:Object.fromEntries(Object.entries(report.reuse).map(([k,v])=>[k,{distinct:v.distinct,maxReuse:v.maxReuse}]))}));
