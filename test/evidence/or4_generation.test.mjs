import fs from 'node:fs';
import assert from 'node:assert/strict';
import test from 'node:test';
import { buildReaderReport } from '../../tool/or4_reader_generator.mjs';
import { auditReports, scanGenerator, hash } from '../../tool/or4_content_validator.mjs';
const read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const candidate=read('docs/CANDIDATE_0020_ACTUAL_0035.json');
const simulation=read('docs/OR4_49_CONTEXT_SIMULATION.json');
const componentLibrary=read('docs/OR4_COMPONENT_LIBRARY.json').components;
const hydrate=input=>({...input,componentLibrary});
test('Candidate0020 and all 49 reports regenerate through the identical pure function',()=>{
  for(const report of [candidate,...simulation.profiles]){
    assert.equal(report.componentLibrarySha256,hash(componentLibrary));
    const actual=buildReaderReport(hydrate(report.input));
    assert.deepEqual(actual.claims,report.claims);
    assert.deepEqual(actual.omissions,report.omissions);
    assert.equal(actual.readerText,report.readerText);
    assert.equal(actual.inputHash,report.inputHash);
  }
});
test('age body, heading and selector remain independently validated over all outputs',()=>{
  const library=read('docs/OR4_COMPONENT_LIBRARY.json');
  const audit=auditReports([candidate,...simulation.profiles],library.components);
  assert.equal(audit.status,'PASS');
  assert.equal(candidate.currentAge,44);
  assert.deepEqual(candidate.resolved.completed.map(x=>[x.ageStart,x.ageEnd]),[[0,10],[11,29],[30,41]]);
  assert.deepEqual(candidate.claims.filter(c=>c.owner==='past').map(c=>c.heading),['อายุ 1–10 ปี','อายุ 11–29 ปี','อายุ 30–41 ปี']);
  assert.equal(candidate.claims.find(c=>c.owner==='current').heading,'คำทำนายปัจจุบัน — อายุ 44 ปี');
  assert.equal(candidate.claims.find(c=>c.owner==='next').heading,'ช่วงชีวิตถัดไป — อายุ 63–79 ปี');
});
test('actual fixture changes cannot select a fixed narrative',()=>{
  const base=buildReaderReport(hydrate(candidate.input));
  for(const field of ['time','location','sex','name','fixtureId']){
    const input=structuredClone(hydrate(candidate.input));input.fixture[field]='arbitrary-mutation';
    assert.deepEqual(buildReaderReport(input).claims,base.claims,field);
  }
});
test('Golden provided as generation input is rejected, and source has no oracle/file import',()=>{
  assert.throws(()=>buildReaderReport({...candidate.input,oracle:'forbidden'}),/UNDECLARED_GENERATION_INPUT/);
  assert.equal(scanGenerator(fs.readFileSync('tool/or4_reader_generator.mjs','utf8')).status,'PASS');
});
test('different birth date/asOf dynamically changes age without freezing the component',()=>{
  const input=structuredClone(hydrate(candidate.input));input.asOf='2027-08-29';
  const output=buildReaderReport(input);
  assert.equal(output.currentAge,45);
  assert.equal(output.claims.find(c=>c.owner==='current').heading,'คำทำนายปัจจุบัน — อายุ 45 ปี');
  assert.equal(auditReports([output]).status,'PASS');
  assert.deepEqual(output.rollingHorizon,{start:'2027-08-29',end:'2028-08-28'});
});
test('representatives include 7 weekdays and Unknown has no time-dependent claims',()=>{
  const reps=read('docs/OR4_REPRESENTATIVE_FULL_COPY.json');
  assert.equal(reps.profiles.length,12);
  assert.equal(new Set(reps.profiles.filter(x=>x.input.fixture.known).map(x=>x.input.context.split('.').at(-1))).size,7);
  const unknown=reps.profiles.find(x=>!x.input.fixture.known);
  assert.equal(unknown.claims.length,0);
  assert.equal(unknown.input.context,null);
  assert.equal(unknown.resolved.current,null);
});
test('domain omission and zero prediction coverage are reported as NO-GO',()=>{
  const audit=read('docs/OR4_CONTENT_AUDIT.json'),domain=read('docs/OR4_DOMAIN_LANGUAGE_AUDIT.json');
  assert.equal(audit.machineContentAudit,'FAIL');
  assert.equal(audit.productContentStatus,'NO_GO');
  assert.equal(audit.ownerHumanReview,'PENDING');
  assert.equal(audit.predictionClaimsChecked,0);
  assert.equal(domain.reuse.finance.distinct,0);
  for(const owner of ['work','finance','relationship','health','support','rolling12'])assert.ok(candidate.omissions.some(x=>x.owner===owner));
});
test('candidate generation two passes produces identical bytes and reference is comparison-only',()=>{
  const a=buildReaderReport(structuredClone(hydrate(candidate.input))),b=buildReaderReport(structuredClone(hydrate(candidate.input)));
  assert.equal(hash(a),hash(b));
  const comparison=read('docs/OR4_GOLDEN_COMPARISON.json');
  assert.equal(comparison.readAfterGeneration,true);
  assert.equal(comparison.exactPredictionMatches,0);
  assert.equal(comparison.readerSha256,'6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
});
