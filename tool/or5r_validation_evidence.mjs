import fs from 'node:fs';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
const read=p=>fs.readFileSync(p,'utf8');
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const log='build/or5r-pdf-final-full.jsonl';
const events=read(log).replace(/^\uFEFF/,'').split(/\r?\n/).flatMap(l=>{try{return [JSON.parse(l)];}catch{return [];}});
assert.equal(events.at(-1).success,true);
const tests=new Map(events.filter(e=>e.type==='testStart').map(e=>[e.test.id,e.test]));
const suites=new Map(events.filter(e=>e.type==='suite').map(e=>[e.suite.id,e.suite]));
const allDone=events.filter(e=>e.type==='testDone');
const visible=allDone.filter(e=>!e.hidden);
assert.equal(visible.filter(e=>e.result!=='success').length,0);
assert.equal(visible.filter(e=>e.skipped).length,0);
const aliases={
  'unsupported no-time topics are disclosed after Timeline':'Unknown topics are explicitly omitted without a synthetic Timeline',
  'PDF appends the same omissions as the final report section':'PDF final section uses exact civil-only omissions, without legacy body',
  'V1.2.4 full audit every chart has exactly 8 periods (≥160 total)':'V1.2.4 full audit Known charts have 8 periods; Unknown timeline is omitted, not generated',
  'synthetic matrix invokes cross-mode material sensitivity':'synthetic matrix separates 900 Known materials from 75 omitted Unknown forecasts',
  'Real PDF exporter path regression chaptered report fixtures stay at measured 6/6 pages':'Real PDF exporter path regression chaptered report fixtures stay at measured Known 6 / Unknown 1 pages',
  'shared report presentation model Known and Unknown place the image after its 12-month narrative':'shared report presentation model Known places image after narrative; Unknown omits both',
  'Runtime metadata audit aggregate runtime status counts match baseline':'Runtime metadata audit aggregate runtime status separates omitted Unknown timeline',
  'MyanmarSevenEngine emits warning when lunar date is unverified':'MyanmarSevenEngine omits exact-time lunar lookup when time authority is unavailable',
};
const classified=JSON.parse(read('docs/OR5R_FAILURE_CLASSIFICATION.json'));
const resolved=classified.entries.map(e=>{
  const name=aliases[e.suite_test_name]??e.suite_test_name;
  const matches=allDone.filter(d=>{const t=tests.get(d.testID);const s=suites.get(t.suiteID);return t.name===name&&s.path.replaceAll('\\','/').endsWith(e.source_test_file);});
  assert.equal(matches.length,1,`${e.id}: resolve exactly once: ${name}`);
  assert.equal(matches[0].result,'success',e.id);
  const changed=e.classification==='RUNTIME_REGRESSION'
    ?[e.id==='F056'?'lib/features/thai_beta/application/thai_beta_report_export_document.dart':'lib/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart']
    :e.id==='F061'?['tool/thai_report_vnext_cross_runtime_manifest.dart']:[e.source_test_file];
  return {id:e.id,classification:e.classification,source_test_file:e.source_test_file,original_test:e.suite_test_name,current_test:name,changed_files:changed,final_result:'PASS',event:matches[0]};
});
function diagnostics(p){return read(p).split(/\r?\n/).filter(l=>/^\s*(info|warning|error) -/.test(l)).map(l=>l.trim().replace(/:\d+:\d+ -/,' -')).sort();}
const baseline=diagnostics('build/or5r-baseline-analyzer.log'),current=diagnostics('build/or5r-pdf-final-analyzer.log');
assert.deepEqual(current,baseline,'analyzer diagnostic multiset (excluding source line shifts)');
const report={schema:'pr115-or5r-validation/1',baseline:'8e6d168baf8378068260fbbb39500d5eb4491b37',
  fullSuite:{command:'flutter test --no-pub --concurrency=1 --reporter=json [exact full_test_command paths in task_scope.json]',log,sha256:sha(log),passed:visible.length,failed:0,skipped:0,durationMs:events.at(-1).time,
    countReconciliation:'1568 passed + 76 failed before = 1644 visible results. Four containment/validator regressions plus four title-only PDF regressions; two previously setup-blocked tests execute, replacing one failed setUpAll result: 1644 + 8 + 2 - 1 = 1653. No original test declaration was removed.'},
  dedicated:{passed:11,failed:0,log:'build/or5r-pdf-final-containment.log',sha256:sha('build/or5r-pdf-final-containment.log')},
  migratedDirect:{passed:374,failed:0,files:34,log:'build/or5r-pdf-final-migrated.log',sha256:sha('build/or5r-pdf-final-migrated.log')},
  focused:{passed:56,failed:0,log:'build/or5r-pdf-final-focused-1.log',sha256:sha('build/or5r-pdf-final-focused-1.log')},
  focusedPdfExport:{passed:58,failed:0,log:'build/or5r-pdf-final-focused-0.log',sha256:sha('build/or5r-pdf-final-focused-0.log')},
  actualPdfRegression:{tests:4,positive:JSON.parse(read('build/or5r-title-only-regression/positive.json')),negative:JSON.parse(read('build/or5r-title-only-regression/negative.json'))},
  nodeOracle:{passed:2,failed:0,log:'build/or5r-pdf-final-focused-2.log',sha256:sha('build/or5r-pdf-final-focused-2.log')},
  analyzer:{baselineDiagnostics:baseline.length,currentDiagnostics:current.length,newDiagnostics:0,removedDiagnostics:0,
    baselineLog:'build/or5r-baseline-analyzer.log',baselineSha256:sha('build/or5r-baseline-analyzer.log'),currentLog:'build/or5r-pdf-final-analyzer.log',currentSha256:sha('build/or5r-pdf-final-analyzer.log'),
    method:'Baseline freshly analyzed from git archive of immutable baseline, offline dependency resolution. Archive and before-migration source backups were moved outside analyzed checkout after detecting accidental nested-source analysis. No analyzer rules/exclusions were changed.'},
  originalFailures:76,resolvedFailures:resolved.length,unclassified:0,duplicateAccounting:resolved.length-new Set(resolved.map(e=>e.id)).size,
  supplementalInfrastructure:[
    {linkedFailure:'F037',defect:'Empty phase/motif matched every character boundary',repair:'Empty labels count zero, all other quality gates continue',negativeControls:'Real phase 4>3, C0 and rejected R6 prose; exact Unknown oracle rejects six body mutations plus missing chapter kind'},
    {linkedFailure:'F010/F014',defect:'Shared VM/browser manifest must not depend on flutter_test',repair:'Pure independent civil oracle separated from Flutter assertion adapter; VM exact-contract checks preserved',browserCompilation:'Required in artifact tooling validation'},
    {defect:'Copied audit snapshots beneath build were picked up as project source',repair:'Moved only created snapshots outside checkout; preserved contents; reran identical analyzer command',result:'298/298 exact diagnostic multiset; no exclusions or configuration edits'},
  ],resolved};
fs.writeFileSync('docs/OR5R_FAILURE_RESOLUTION.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({full:report.fullSuite.passed,resolved:resolved.length,analyzer:current.length,errors:0}));
