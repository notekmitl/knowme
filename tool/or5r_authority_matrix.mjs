// Read-only evidence adjudication. Does not generate reader copy or alter an oracle.
import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {resolveJsonPointer} from './resolve_thai_predictive_evidence_v1.mjs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const rawPath=process.argv[2]??'build/or5r-pdf-final-runtime/OR5_ACTUAL_0035_RUNTIME_EVIDENCE.json';
const raw=read(rawPath), map=read('docs/CANDIDATE_0011_RESOLVED_PRODUCT_RULE_MAP.json');
const registry=read('docs/THAI_PREDICTIVE_EVIDENCE_RESOLUTION_V1.json');
const oracle=read('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
assert.equal(raw.input.birthMinute,35); assert.equal(raw.input.gender,'ชาย');
assert.equal(raw.asOf,'2026-08-29T00:00:00.000'); assert.equal(raw.typedMaterials.length,12);
assert.equal(map.claims.length,22);
const byId=new Map(registry.entries.map(e=>[e.id,e]));
function component(id,input=raw){
  const e=byId.get(id); assert.ok(e,id);
  const source=fs.readFileSync(e.repositoryPath,'utf8');
  if(e.locator.jsonPointer) assert.deepEqual(resolveJsonPointer(JSON.parse(source),e.locator.jsonPointer),e.resolvedValue,id);
  else assert.ok(source.includes(e.locator.symbol),id);
  const row={id,role:e.role,reference:e.repositoryPath,locator:e.locator,sourceSha256:hash(e.repositoryPath),historicalFixture:e.fixtureInput,manuallyAsserted:e.manuallyAsserted,sourceResolution:'EXACT_POINTER_OR_EXISTING_SYMBOL',actualBinding:null,componentApplicability:'REFERENCE_ONLY',domainMismatch:0,horizonMismatch:0,directionMismatch:0,fixtureMismatch:0};
  if(id.startsWith('typed.')){
    const found=input.typedMaterials.find(m=>m.domain===e.expectedDomain&&m.horizon===e.expectedHorizon);
    row.actualBinding=found??null;
    row.componentApplicability=found?.materialFingerprint===e.resolvedValue.completeEvidenceSignature?'EXACT_FRESH_MATERIAL_SIGNATURE':'MATERIAL_MISMATCH';
    row.domainMismatch=found?Number(found.domain!==e.expectedDomain):1;
    row.horizonMismatch=found?Number(found.horizon!==e.expectedHorizon):1;
    row.directionMismatch=found?Number(found.band!==e.expectedBandDirection):1;
  }else if(id.startsWith('selector.')){
    const found=input.periodRows.find(p=>p.matrixApplicationId===e.resolvedValue.matrixApplicationId);
    row.actualBinding=found??null;
    row.componentApplicability=found&&['contextId','planet','taksaRole','mahabhutHouse','periodStatus'].every(k=>found[k]===e.resolvedValue[k])?'EXACT_FRESH_SELECTOR':'SELECTOR_MISMATCH';
  }else if(id==='fixture.target-0003'){
    row.actualBinding=input.input;row.fixtureMismatch=Number(input.input.birthMinute!==3);
    row.componentApplicability=row.fixtureMismatch?'EXPLICIT_0003_FIXTURE_DOES_NOT_EQUAL_0035':'FIXTURE_MATCH';
  }else if(id==='timing.rolling-12-month-label'){
    row.actualBinding={start:input.asOf.slice(0,10),end:'2027-08-28'};
    row.componentApplicability=input.asOf.slice(0,10)==='2026-08-29'?'PINNED_HORIZON_MATCH':'HORIZON_MISMATCH';
  }else if(id==='conflict.T0003-SRC-42-43-61-62-EXCEPTION'){
    row.actualBinding={age:input.currentAge,exceptionApplies:[42,43,61,62].includes(input.currentAge)};
    row.componentApplicability=row.actualBinding.exceptionApplies?'EXCEPTION_APPLIES':'EXCEPTION_NOT_APPLICABLE_AT_44_NO_TRANSITION_AUTHORITY';
  }
  return row;
}
const entries=map.claims.map(c=>{
  const refs=[...new Set(['selectorRefs','domainRefs','directionRefs','timingRefs','conflictRefs','certaintyRefs'].flatMap(k=>c[k]))];
  const components=refs.map(id=>component(id));
  const owner=oracle.claims.find(o=>o.readerClaimId===c.readerClaimId);
  assert.equal(c.exactAcceptedText,owner.exactText);
  // Exact whole-claim owner/text binding, not substring and not material-count inference.
  const actual=raw.plan.decisions.filter(d=>d.kind==='prediction'&&d.emitted&&d.text===c.exactAcceptedText&&d.binding?.realizedReaderText===c.exactAcceptedText);
  const fixtureMismatch=components.some(e=>e.fixtureMismatch);
  const typed=components.filter(e=>e.id.startsWith('typed.'));
  const periods=components.filter(e=>e.id.startsWith('selector.')).map(e=>e.actualBinding);
  const reason=fixtureMismatch
    ?'The accepted chain explicitly uses fixture.target-0003 for selector/timing. Actual 00:35 is a different input. Age 44 is outside the source exception ages 42–43/61–62; matching period/materials does not independently prove this exact transition claim. No replacement authority was invented.'
    :'Existing accepted source/Canon/interpretation references remain available and their applicable selector/material components are resolved below. Actual 00:35 runtime has no exact paragraph plus semantic-owner binding for this Candidate claim. Component compatibility is not counted as a complete input-bound claim or as new Owner acceptance. This does not declare the accepted 00:03 paragraph false or revoke its authority.';
  return {claimId:c.readerClaimId,exactClaimText:c.exactAcceptedText,semanticOwner:c.domain,section:c.section,
    evidenceOwnerId:c.ownerId,ownerAcceptanceReference:c.ownerAcceptanceRef,context:raw.contextId,
    acceptedPeriodBinding:c.periodBinding,resolvedLifePeriods:periods,domain:c.domain,
    horizon:c.readerClaimId.includes('PAST')?'past':c.readerClaimId.includes('HORIZON')?'next12Months':c.readerClaimId.includes('NEXT')?'nextLifePeriod':c.readerClaimId.includes('OVERVIEW')?'multi-period':'current',
    direction:typed.length?typed.map(t=>({reference:t.id,band:t.actualBinding?.band,risk:t.actualBinding?.riskDomain})):c.directionRefs.map(id=>({reference:id,sourceDirection:byId.get(id).resolvedValue})),
    typedMaterialSignatures:typed.map(t=>t.actualBinding?.materialFingerprint??null),
    evidenceReferences:components,conflictResolution:components.filter(e=>e.id.startsWith('conflict.')),
    applicabilityResult:fixtureMismatch?'EXPLICIT_FIXTURE_MISMATCH_AND_MISSING_ACTUAL_CLAIM_BINDING':'COMPONENTS_RESOLVED_BUT_WHOLE_CLAIM_BINDING_NOT_ESTABLISHED',
    actualExactClaimBindings:actual,missingBinding:actual.length===0,
    authorityClassification:actual.length===0?'MISSING_ACTUAL_INPUT_BOUND_AUTHORITY':'REQUIRES_SEMANTIC_REVIEW',
    sourceBoundSupported:false,ownerAuthorizedInterpretationSupportedForActualInput:false,
    accepted0003InterpretationPreserved:true,supportedUnsupportedReason:reason};
});
const unique=[...new Set(map.claims.flatMap(c=>['selectorRefs','domainRefs','directionRefs','timingRefs','conflictRefs','certaintyRefs'].flatMap(k=>c[k])))].map(id=>component(id));
const negativeControls=[];
for(const [name,mutate,id,expected] of [
  ['wrong-band',r=>r.typedMaterials[0].band='quiet','typed.current.career','directionMismatch'],
  ['wrong-domain',r=>r.typedMaterials[0].domain='unsupported','typed.current.career','domainMismatch'],
  ['wrong-horizon',r=>r.typedMaterials[0].horizon='unsupported','typed.current.career','horizonMismatch'],
]){const r=structuredClone(raw);mutate(r);const got=component(id,r);assert.equal(got[expected],1);negativeControls.push({name,rejected:true});}
const totals={claimsExamined:entries.length,sourceBoundSupported:0,ownerAuthorizedInterpretationSupported:0,adviceDisclosureWithin22:0,adviceDisclosureOutsideMatrix:oracle.counts.adviceAndDisclosure,
  unsupportedOrNotEstablished:entries.filter(e=>e.missingBinding).length,missingBinding:entries.filter(e=>e.missingBinding).length,
  domainMismatch:unique.reduce((n,e)=>n+e.domainMismatch,0),horizonMismatch:unique.reduce((n,e)=>n+e.horizonMismatch,0),directionMismatch:unique.reduce((n,e)=>n+e.directionMismatch,0),
  duplicateEvidenceOwner:entries.length-new Set(entries.map(e=>e.evidenceOwnerId)).size,fixtureMismatch:unique.filter(e=>e.fixtureMismatch).length,
  manualAssertion:unique.filter(e=>e.manuallyAsserted).length,freshTypedSignatureMatches:unique.filter(e=>e.componentApplicability==='EXACT_FRESH_MATERIAL_SIGNATURE').length,
  freshSelectorMatches:unique.filter(e=>e.componentApplicability==='EXACT_FRESH_SELECTOR').length,actualRuntimePredictions:raw.plan.emittedPredictions};
const result={schema:'pr115-or5r-actual-authority/1',status:'ACTUAL_INPUT_BOUND_AUTHORITY_NO_GO',rawEvidence:{path:rawPath,sha256:hash(rawPath),input:raw.input,asOf:raw.asOf,context:raw.contextId},
  method:'Resolve every historical reference, compare fresh selector/material components, then separately test exact whole-claim text/owner realization from actual pre-override evidence. This is a conservative actual-runtime authority proof gate, NOT a claim that all compatible historical interpretations are intrinsically unsupported. Zero complete bindings must not be confused with zero compatible components. No requirement for a direct source sentence per paragraph is imposed.',
  totals,negativeControls,entries};
fs.writeFileSync('docs/OR5R_ACTUAL_0035_AUTHORITY_MATRIX.json',JSON.stringify(result,null,2)+'\n');
fs.writeFileSync('docs/OR5R_ACTUAL_0035_AUTHORITY_MATRIX.md','# OR5R actual 00:35 authority — NO-GO\n\n'+result.method+'\n\n```json\n'+JSON.stringify(totals,null,2)+'\n```\n\n'+entries.map(e=>`## ${e.claimId} / ${e.evidenceOwnerId}\n\n${e.exactClaimText}\n\n${e.applicabilityResult}\n\n${e.supportedUnsupportedReason}\n`).join('\n'));
console.log(JSON.stringify(totals));
