// Evidence extraction only. Never updates a runtime oracle or changes tests.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const base = '8e6d168baf8378068260fbbb39500d5eb4491b37';
const git = (...args) => execFileSync('git', ['-c', 'core.safecrlf=false', ...args], {encoding:'utf8', maxBuffer:64*1024*1024});
const hash = text => crypto.createHash('sha256').update(text).digest('hex');
const classification = JSON.parse(fs.readFileSync('docs/OR5R_FAILURE_CLASSIFICATION.json','utf8'));
if (classification.entries.length !== 76 || new Set(classification.entries.map(e=>e.id)).size !== 76) throw Error('classification accounting');
const files = [...new Set(classification.entries.filter(e=>['STALE_UNKNOWN_CONTRACT','TEST_INFRASTRUCTURE_DEFECT'].includes(e.classification)).map(e=>e.source_test_file))].sort();
// Lexical tokens keep literal contents exact while ignoring formatter whitespace.
function tokens(source) {
  const result=[];
  const re = /\/\/[^\n]*|\/\*[\s\S]*?\*\/|r?(?:'''[\s\S]*?'''|"""[\s\S]*?"""|'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")|[A-Za-z_$][\w$]*|\d+(?:\.\d+)?|\S/g;
  for(const m of source.matchAll(re)) if(!m[0].startsWith('//')&&!m[0].startsWith('/*')) result.push({text:m[0],start:m.index,end:m.index+m[0].length});
  return result;
}
function assertions(source) {
  const ts=tokens(source), result=[];
  for(let i=0;i<ts.length;i++) {
    if(!/^expect(?:Later|UnknownContract|UnknownDocument|CanonTimePartition|OmittedCanonTimeline|CanonicalFixtureText)?$/.test(ts[i].text)||ts[i+1]?.text!=='(')continue;
    let depth=0,j=i+1;
    for(;j<ts.length;j++){if(ts[j].text==='(')depth++;if(ts[j].text===')'&&--depth===0)break; if(ts[j].text!==')')depth+=0;}
    // Count only ')' above: opening increments; other tokens leave depth intact.
    if(j===ts.length)throw Error('unclosed assertion');
    result.push({line:source.slice(0,ts[i].start).split('\n').length,full:source.slice(ts[i].start,ts[j].end),key:JSON.stringify(ts.slice(i,j+1).map(t=>t.text))});
    i=j;
  }
  return result;
}
function testCount(source){return tokens(source).filter((t,i,a)=>['test','testWidgets'].includes(t.text)&&a[i+1]?.text==='(').length;}
const helper=fs.readFileSync('test/evidence/or5r_unknown_contract.dart','utf8');
const projection=fs.readFileSync('test/evidence/or5r_unknown_projection.dart','utf8');
const rows=files.map(file=>{
  const before=git('show',`${base}:${file}`),after=fs.readFileSync(file,'utf8');
  const old=assertions(before),fresh=assertions(after),remaining=[...fresh];
  const replaced=[];let unchanged=0;
  for(const a of old){const i=remaining.findIndex(b=>b.key===a.key);if(i>=0){remaining.splice(i,1);unchanged++;}else replaced.push(a);}
  const entries=classification.entries.filter(e=>e.source_test_file===file);
  if(testCount(before)!==testCount(after))throw Error(`test count changed ${file}`);
  if(replaced.length && !remaining.length)throw Error(`removed assertion without replacement in ${file}`);
  return {file,classificationIds:entries.map(e=>e.id),contractClauses:[...new Set(entries.map(e=>e.contract_clause))],
    justifications:entries.map(e=>({id:e.id,reason:e.justification})),
    beforeSourceSha256:hash(before),afterSourceSha256:hash(after),testDeclarationsBefore:testCount(before),testDeclarationsAfter:testCount(after),
    assertionsBefore:old.length,assertionsAfter:fresh.length,unchangedExactTokenAssertions:unchanged,
    replacementGroups:replaced.map((a,i)=>({id:`${path.basename(file)}:${a.line}`,before:a.full,beforeLine:a.line,
      after:remaining.map(b=>({line:b.line,full:b.full})),
      replacementOwnership:'File-level contract replacement group, not one-to-one assertion-count equivalence. Exact common assertions are retained; all new calls are shown in full. Unknown-safe helper expands the absent-field, exact paragraph, metadata and unique-disclosure assertions. See original failure-specific clauses and complete unified diff.',
      strengthReview:'Unknown generated-output obligations replaced by explicit absence/full civil projection; Known obligations retained. Aggregate counts partition generated Known from omitted Unknown. Prose validators still run or exact projection rejects injected content.'})),
    addedCalls:remaining.map(b=>({line:b.line,full:b.full})),
    fullUnifiedDiff:git('diff','--no-ext-diff','--unified=5',base,'--',file)};
});
const report={schema:'pr115-or5r-assertion-migration/1',base,files:rows.length,
  notes:['Lexical assertion inventories are an index, not automatic proof of semantic strength. Full diff and per-failure justification are retained for Owner review.',
    'Formatting-only token differences may appear as replacement groups; no old/new text is truncated.',
    'Known hash/degree/Candidate regressions are independent runtime evidence; omission is not prediction coverage.',
    'Cross-mode sensitivity now rejects missing Unknown identities. Existing controlled generation/negative sensitivity tests remain mandatory; no fabricated Unknown block is used.'],
  originalFailureClassification:classification.classification_totals,
  removed_assertions_without_replacement:rows.filter(r=>r.replacementGroups.length&&!r.addedCalls.length).length,
  test_declaration_delta:rows.reduce((n,r)=>n+r.testDeclarationsAfter-r.testDeclarationsBefore,0),
  helper:{file:'test/evidence/or5r_unknown_contract.dart',sha256:hash(helper),fullSource:helper},
  independentProjection:{file:'test/evidence/or5r_unknown_projection.dart',sha256:hash(projection),fullSource:projection},rows};
fs.writeFileSync('docs/OR5R_ASSERTION_MIGRATION_LEDGER.json',JSON.stringify(report,null,2)+'\n');
const md=['# OR5R assertion migration ledger','',
  'This is a contract migration review index, not Owner Product Acceptance. Full Before/After assertions, source hashes, line references and diffs are in OR5R_ASSERTION_MIGRATION_LEDGER.json. No text is truncated.','',
  `Original failures: 76. Individually classified A=68, B=7, C=0, D=0, E=1. Migrated A/E test files: ${rows.length}.`,
  'The six B-only files are not migrated. Their valid assertions pass after restoring Unknown metadata/omission-banner behavior; chapter-kind metadata is repaired at the export boundary.',
  'Additional validator defect encountered while enabling the R7 prose audit: empty phase/motif counted every character boundary. Empty labels now count zero; real fourfold phase repetition, C0 text and rejected prose remain rejected by negative controls.',
  'V124 corrected enumeration: 22 fixtures = 19 Known + 3 Unknown (F09/F18/F20); 152 generated Known periods + 24 historical synthetic Unknown periods explicitly omitted. The initial 20/one rationale was corrected, not silently retained.',
  'PDF legacy test fixtures: Known 6 pages unchanged; Unknown measured 1 page with pdfinfo, rasterized and visually opened for both actual fixtures before changing expected page count. Printable-margin/body-ink gates retained.', '',
  '| Test file | Failure IDs | Before / After lexical calls | Exact retained | Test declarations |',
  '|---|---|---:|---:|---:|',
  ...rows.map(r=>`| ${r.file} | ${r.classificationIds.join(', ')} | ${r.assertionsBefore} / ${r.assertionsAfter} | ${r.unchangedExactTokenAssertions} | ${r.testDeclarationsBefore} / ${r.testDeclarationsAfter} |`), '',
  'Counting call sites alone does not measure executed assertions: shared exact Unknown contract checks run for every applicable profile. Replacement groups deliberately show every added call plus full surrounding diff. Runtime baseline and negative-control results must be read alongside this ledger.',''];
fs.writeFileSync('docs/OR5R_ASSERTION_MIGRATION.md',md.join('\n'));
console.log(JSON.stringify({files:rows.length,removed_assertions_without_replacement:report.removed_assertions_without_replacement,test_declaration_delta:report.test_declaration_delta}));
