import fs from 'node:fs';
import assert from 'node:assert/strict';
import test from 'node:test';
import { auditReports, ageAt } from '../../tool/or4_content_validator.mjs';
import { validTestReport, runNegativeControls } from '../../tool/or4_negative_controls.mjs';
test('OR3 truth is recomputed with original records preserved',()=>{
  const truth=JSON.parse(fs.readFileSync('docs/OR4_TRUTH_CORRECTION.json','utf8'));
  assert.deepEqual(truth.counts,{pastClaims:101,pastAgeMismatch:76,pastAffectedContexts:35,currentAgeMismatch:43});
  assert.equal(truth.findings.singlePathProof,false);
  assert.equal(truth.findings.hardcodedNegativeControlResults,true);
});
test('valid age-binding positive control and birthday boundary',()=>{
  assert.equal(auditReports([validTestReport()]).status,'PASS');
  assert.equal(ageAt('1982-06-06','2026-06-05'),43);
  assert.equal(ageAt('1982-06-06','2026-06-06'),44);
});
for(const control of runNegativeControls().cases)test(`OR4 rejects ${control.name}`,()=>{
  assert.equal(control.rejected,true,JSON.stringify(control));
});
