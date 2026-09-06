// Serializes already-emitted, twice-verified text and explicit machine review.
// Does not call a product generator or write any historical evidence/artifact.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {BASE, RAW_NAME, actualAuthority, compareExtractions, fileSha, read, semanticSlots, sha, summarize} from './or5r_actual_authority_v2.mjs';

const dir1 = 'build/or5r-neutral-v2-run1', dir2 = 'build/or5r-neutral-v2-run2';
// Frozen passing logs: later PreCommit repetitions must not stale manifest hashes.
const logDir = fs.existsSync('build/or5r-neutral-review-validation') ? 'build/or5r-neutral-review-validation' : 'build/or5r-neutral-validation';
const rawPath = `${dir1}/${RAW_NAME}`, raw = read(rawPath);
const determinism = compareExtractions(dir1, dir2);
assert.equal(determinism.mismatches, 0);
const baselinePath = 'test/evidence/fixtures/or5r_known_baseline.json';
const boundary = read(baselinePath)['35'];
assert.deepEqual(raw.plan.decisions, boundary.decisions);
assert.equal(raw.input.birthMinute, 35);
assert.equal(raw.asOf, '2026-08-29T00:00:00.000');
const logText = p => { const b = fs.readFileSync(p); return b[0] === 255 && b[1] === 254 ? b.toString('utf16le') : b.toString('utf8'); };
for (const i of [1, 2]) assert.match(logText(`${logDir}/extraction-${i}.log`), /\+2: All tests passed!/);
const tap = logText(`${logDir}/node-tests.tap`);
const tapCount = name => Number(tap.match(new RegExp(`# ${name} (\\d+)`))?.[1]);
assert.equal(tapCount('fail'), 0); assert.equal(tapCount('tests'), tapCount('pass'));
assert.equal(tapCount('skipped'), 0);
const {entries, records} = actualAuthority(raw);
const slots = semanticSlots(raw, entries), totals = summarize(entries, slots);
const fullText = boundary.publicExportText;
for (const e of entries) assert.ok(fullText.split('\n').includes(e.text));
const provenance = {runtimeSourceBase: BASE, rawPath, rawSha256: fileSha(rawPath), input: raw.input, asOf: raw.asOf,
  timeZone: 'Asia/Bangkok', contextId: raw.contextId, currentAge: raw.currentAge,
  fullTextPath: baselinePath, fullTextPointer: '/35/publicExportText', baselineSha256: fileSha(baselinePath),
  fullTextSha256: sha(fullText), sections: boundary.sections.length,
  method: 'The existing extraction test executes publicBoundary for fresh 00:03 and 00:35, asserting exact deep equality with this preserved baseline, including full export text/sections/snapshot/decisions. Both independent runs passed. Full text is copied from that freshly revalidated baseline, not claimed to be a field in the raw extraction JSON.',
  freshnessTest: 'test/evidence/predictive_runtime_v2_or5_actual_input_export_test.dart: OR5 actual raw extraction precedes golden override and preserves input',
  determinism};
const writeJson = (p, x) => fs.writeFileSync(p, JSON.stringify(x, null, 2) + '\n');
const writeMd = (p, x) => fs.writeFileSync(p, x.endsWith('\n') ? x : x + '\n');
const code = x => '```json\n' + JSON.stringify(x, null, 2) + '\n```\n';
const fullBlock = '<!-- BEGIN EXACT ACTUAL 0035 FULL READER COPY -->\n```text\n' + fullText + (fullText.endsWith('\n') ? '' : '\n') + '```\n<!-- END EXACT ACTUAL 0035 FULL READER COPY -->\n';
const sourceNote = 'Fixture: male 1982-06-06 00:35 Chiang Mai; asOf 2026-08-29 Asia/Bangkok; Aquarius 19°19′. No copy was rewritten. See JSON provenance for fresh-runtime/baseline equality and SHA-256. Golden 00:03 is a separate contract.\n';
writeJson('docs/ACTUAL_0035_EMITTED_PREDICTIONS.json', {schema: 'actual-0035-emitted/2', provenance, count: entries.length,
  entries: entries.map((e, i) => ({...e, rawDecisionPointer: `/plan/decisions/${raw.plan.decisions.findIndex(d => d.claimId === e.claimId)}`,
    authorityRecord: records[i]}))});
writeMd('docs/ACTUAL_0035_EMITTED_PREDICTIONS.md', '# Actual 00:35 — all emitted predictions, exact\n\n' + sourceNote + '\n' +
  entries.map((e, i) => `## ${i + 1}. ${e.section} / ${e.semanticOwner}\n\n${e.text}\n\nRule: \`${e.claimId}\`; template: \`${e.templateId}\`. Context: \`${e.context}\`; period ${e.period}; domain ${e.domain}; horizon ${e.horizon}; direction ${e.direction}.\n\n${e.classification}\n\n${e.reasons.join('\n\n')}\n\nComplete material fingerprints, selector/domain/timing/conflict/certainty evidence and source owner: ACTUAL_0035_AUTHORITY_MATRIX_V2.json records[${i}].\n`).join('\n'));
writeJson('docs/ACTUAL_0035_AUTHORITY_MATRIX_V2.json', {schema: 'actual-0035-neutral-authority/2', provenance, ...totals,
  methodology: 'Generation provenance plus explicitly identified compatible source/Canon audit bridges. Pending template review does not count as supported. Machine semantic annotations are reviewable judgements, not automated semantic truth. Neither runtime emission nor Candidate paragraph equality confers non-golden authority.',
  entries, records});
writeMd('docs/ACTUAL_0035_AUTHORITY_MATRIX_V2.md', '# Actual 00:35 — neutral authority matrix V2\n\n' + sourceNote + '\n' + code(totals) + '\n' +
  'The eight review-required entries are not eight supported claims. No Owner acceptance is inferred. The two different unsupported classifications concern actual timing and domain/template binding, not Candidate text inequality. Compatible source bridges below are evidence-review annotations, not citations inserted into runtime.\n\n' +
  entries.map((e, i) => `## ${e.section} — ${e.claimId}\n\n${e.text}\n\n**${e.classification}**\n\n${e.reasons.join('\n\n')}\n\n` + code({semanticOwner: e.semanticOwner, domain: e.domain, horizon: e.horizon,
    period: records[i].actualPeriod, direction: e.direction, materialFingerprint: e.materialFingerprint,
    template: records[i].template, evidenceOwner: records[i].evidenceOwner, actualRuntimeReferences: records[i].rawDecision.evidenceRefs,
    auditChain: records[i].chain, semanticFindings: records[i].semanticFindings})).join('\n'));
writeMd('docs/ACTUAL_0035_FULL_READER_COPY.md', '# Actual 00:35 — full exact canonical reader copy\n\n' + sourceNote + '\n' +
  'All 29 section blocks plus report header/footer are included. The preserved full text was revalidated by two fresh runtime executions, not regenerated for this audit. This is the canonical plain-text surface; no new Web/PDF visual QA is claimed.\n\n' + fullBlock + '\n## Provenance\n\n' + code(provenance));
const slotTotals = {required: slots.filter(s => s.required).length, applicable: slots.filter(s => s.applicable).length,
  emitted: slots.filter(s => s.emitted > 0).length, supported: slots.filter(s => s.supported).length,
  predictionSupported: entries.filter(e => ['SOURCE_CHAIN_SUPPORTED', 'OWNER_APPROVED_TEMPLATE_SUPPORTED'].includes(e.classification)).length,
  nonPredictiveProvenanceSupported: slots.filter(s => ['advice', 'disclosure'].includes(s.id) && s.supported).length,
  missing: slots.filter(s => s.missing).length, duplicate: slots.reduce((n, s) => n + s.duplicate, 0)};
writeJson('docs/ACTUAL_0035_SEMANTIC_SLOT_COVERAGE.json', {schema: 'actual-0035-semantic-slots/2', provenance, totals: slotTotals,
  method: 'One slot per actual completed engine period, then requested current/domain/future/composition slots. Engine first period is 0–10; the accepted golden reader labels it 1–10. This audit preserves the actual engine range and does not impose golden paragraph count. Non-predictive provenance support is separate from prediction authority.', slots});
writeMd('docs/ACTUAL_0035_SEMANTIC_SLOT_COVERAGE.md', '# Actual 00:35 — semantic slot coverage\n\n' + code(slotTotals) +
  '\nRequired/applicable = 15 slots, not 22 paragraphs. Two non-predictive provenance-supported slots are advice/disclosure, not supported predictions. Past 0–10 and 11–29 are absent; actual 30–41 is emitted. First period 0–10 is the raw engine range, not a change to Candidate0011’s accepted 1–10 reader label.\n\n' +
  '| Slot | Required | Applicable | Emitted | Supported | Missing | Duplicate |\n|---|---|---|---:|---|---|---:|\n' + slots.map(s => `| ${s.label} | ${s.required} | ${s.applicable} | ${s.emitted} | ${s.supported} | ${s.missing} | ${s.duplicate} |`).join('\n') + '\n\nSummary inherits parent authority; it cannot rescue unresolved predictions. No missing slot was filled or runtime output changed.\n');

// Main-agent editorial observations from two full reads, not a banned-phrase-only scan.
const findings = [
  {id: 'CR-01', category: 'chronology', blocks: [13], exactSpans: ['ช่วงที่ผ่านมา — อายุ 30–41 ปี'],
    finding: 'อดีตเริ่มที่ 30–41 ปี โดยไม่มีช่วง 0–10 และ 11–29 ที่มีอยู่ใน period rows จึงยังอ่านเส้นทางชีวิตไม่ครบ ไม่ได้ตัดสินจากจำนวน 22 ย่อหน้าของ golden'},
  {id: 'CR-02', category: 'tense-and-repetition', blocks: [13], exactSpans: ['อำนาจตัดสินใจและความรับผิดชอบจะเพิ่มขึ้น', 'หน้าที่และอำนาจรับผิดชอบจะชัดขึ้น'],
    finding: 'หัวข้อเป็นอดีตแต่ใช้ “จะ” และสองวลีพูดเรื่องอำนาจ/ความรับผิดชอบซ้ำกัน ไม่มีคำถามชวนย้อนอดีตในย่อหน้าคำทำนายนี้ แต่ tense ยังไม่สอดคล้อง'},
  {id: 'CR-03', category: 'timing-authority', blocks: [14], exactSpans: ['อายุ 44 ปีเป็นช่วงเปลี่ยนผ่านของหน้าที่ ฐานชีวิต และเรื่องที่ต้องรับผิดชอบ'],
    finding: 'การเรียกอายุ 44 ว่าช่วงเปลี่ยนผ่านไม่มี timing binding ที่ใช้ได้กับ input นี้: อยู่กลางช่วง 42–62 และ current materials spansTransition=false; ไม่ใช้ accepted 00:03 มารับรองข้อนี้'},
  {id: 'CR-04', category: 'natural-language-and-ambiguity', blocks: [11,15,18], exactSpans: ['ชีวิตกำลังเข้าสู่รอบขยายผล', 'หน้าที่และการมองเห็นผลงานจะเพิ่มขึ้น', 'ลดแรงที่ใช้ประคองด้านสุขภาพและการพัก'],
    finding: 'คำว่า “รอบขยายผล”, “การมองเห็นผลงาน” และ “ประคองด้านสุขภาพและการพัก” ฟังเป็นภาษาประกอบแม่แบบมากกว่าภาษาพูด และไม่ได้ทำให้ผู้อ่านเห็นเหตุการณ์ชัดขึ้น'},
  {id: 'CR-05', category: 'semantic-duplication', blocks: [11,14,15,16,19,21,23], exactSpans: ['งานจะเดินหน้าและหน้าที่จะเพิ่มขึ้น', 'รายรับในช่วงปัจจุบันจะขยายตามงานและหน้าที่ที่เพิ่มขึ้น', 'รอบปัจจุบันกำลังขยายผลจากสิ่งที่ทำต่อเนื่อง'],
    finding: 'ภาพรวม ปัจจุบัน รายด้าน แรงสนับสนุน 12 เดือน และสรุปวนเรื่องงานขยาย/รายรับเพิ่ม/เห็นผลจากงานเดิม บางการย่อในสรุปมีหน้าที่ชัด แต่ภาพรวมกับรายด้านยังซ้ำเชิงความหมาย; ไม่พบย่อหน้าคำทำนายทั้งก้อนซ้ำแบบ exact'},
  {id: 'CR-06', category: 'conflict-and-certainty', blocks: [15,16,17,18,21], exactSpans: ['งานในช่วงปัจจุบันจะเดินหน้า', 'ทำให้จังหวะด้านงานเดินช้าลง', 'การฟื้นตัวหลังวันหนักจะกลับมาเร็วและสม่ำเสมอ'],
    finding: 'ย่อหน้าเริ่มด้วยผลเชิงบวกแน่นอนแล้วต่อแรงกดดันแบบกว้าง ๆ โดยไม่ชัดว่าเงื่อนไขใดทำให้ทิศทางใดเด่นกว่า โดยเฉพาะการยืนยันความเร็วการฟื้นตัวต้องให้ Owner ตรวจความหมายและ certainty; band/pressure ไม่ใช่หลักฐานความแม่นยำ'},
  {id: 'CR-07', category: 'generic-copy', blocks: [15,16,17,18], exactSpans: ['ในช่วงเดียวกัน', 'ความสัมพันธ์ในช่วงปัจจุบันจะชัดขึ้นจากการกระทำที่สม่ำเสมอ'],
    finding: 'คำเชื่อมและแรงกดดันใช้โครงเดียวกันหลายด้าน จึงมีความเสี่ยงอ่านเป็นข้อความที่ใช้ได้กว้าง ไม่ได้ทดสอบความซ้ำข้าม 300 profiles ในรอบนี้ และไม่อ้างว่าพิสูจน์ generic ทุกดวงแล้ว'},
  {id: 'CR-08', category: 'next-period-domain', blocks: [22,23], exactSpans: ['ความสัมพันธ์ที่รองรับภาระใหม่ไม่ได้จะเปลี่ยนระยะหรือยุติบทบาทเดิม', 'ส่วนช่วงชีวิตถัดไปจะย้ายแกนหลักไปที่ความสัมพันธ์'],
    finding: 'เนื้อหาช่วงถัดไปกระโดดจากฐานงาน/ทรัพย์สินสู่การยุติบทบาทความสัมพันธ์ สรุปย้ำผลนั้นอีกครั้ง หลักฐาน Mercury/family/speech และ relationship quiet ไม่ทำให้ missing relationship-to-template binding หายไป'},
  {id: 'CR-09', category: 'personality-and-advice-scope', blocks: [2,3,4,5,7,8,24], exactSpans: ['คุณเป็นคนคิดเป็นระบบ', 'ควรถามตัวเองเป็นระยะว่าวิธีนั้นยังเหมาะอยู่หรือไม่', 'สิ่งสำคัญตอนนี้ไม่ใช่รับงานเพิ่ม'],
    finding: 'ส่วนที่ 1 ยังคงเป็นบุคลิก/คำแนะนำของรายงานเดิม ไม่ใช่สิบ emitted predictions; จึงต้องให้ Owner เห็น full-report scope ไม่แอบนับเป็นคำทำนายที่ครบ ในสิบย่อหน้าพยากรณ์ไม่พบการชวนถามย้อนอดีตหรือคำแนะนำปลอมเป็น prediction โดยตรง'},
  {id: 'CR-10', category: 'methodology-leakage', blocks: [20,26], exactSpans: ['ดูแนวโน้ม 12 เดือนและช่วงชีวิตถัดไปจากกฎที่มีหลักฐานครบ'],
    finding: 'คำโปรยส่วนที่ 3 ประกาศว่ากฎมีหลักฐานครบ ทั้งที่ neutral gate ยังมี gap จึงเป็นข้อความเชิงระบบที่สื่อเกินผลตรวจ ส่วนวิธีนับวันและเรือนในส่วนที่ 4 อยู่ในหัวข้อที่มาโดยตั้งใจ ไม่ใช่ leak ทุกกรณี'},
  {id: 'CR-11', category: 'full-report-contract-contradiction', blocks: [10,28], exactSpans: ['คำทำนายดวงชะตา', 'ผลลัพธ์นี้เป็นมุมมองเพื่อทำความเข้าใจตัวเอง ไม่ใช่คำทำนาย'],
    finding: 'หัวข้อกลางรายงานเป็นคำทำนาย แต่ข้อจำกัดท้ายรายงานบอกว่าไม่ใช่คำทำนาย เป็นความขัดกันของ full-report contract ที่ต้องให้ Owner ตัดสิน ไม่แก้เองใน evidence-only รอบนี้'},
];
for (const f of findings) for (const span of f.exactSpans) assert.ok(f.blocks.some(i => [boundary.sections[i].title, ...boundary.sections[i].paragraphs].join('\n').includes(span)), `${f.id}: unbound quote`);
const review = {schema: 'actual-0035-content-review/2', status: 'AI/Machine Content Audit — PENDING OWNER CONTENT REVIEW', provenance,
  reviewer: 'Main agent; two complete reads of actual verified canonical output; no secondary agent',
  passes: [{pass: 1, scope: 'Full 29 blocks + report header/footer in reading order', focus: 'Chronology, meaning, certainty, full-report contract'},
    {pass: 2, scope: 'All 29 numbered blocks reread against ten actual decisions', focus: 'Natural Thai, duplication, personality/advice scope, methodology and applicability'}],
  testsAreNotSemanticProof: true, ownerAcceptance: 'PENDING', findings, findingsCount: findings.length,
  duplicateExactPredictionParagraphs: entries.length - new Set(entries.map(e => e.text)).size,
  fullExactReaderText: fullText, fullSectionBlocks: boundary.sections};
writeJson('docs/ACTUAL_0035_CONTENT_REVIEW.json', review);
writeMd('docs/ACTUAL_0035_CONTENT_REVIEW.md', '# Actual 00:35 — full content review\n\n**' + review.status + '**\n\n' + sourceNote +
  '\nอ่านจริงสองรอบครบ 29 blocks: รอบแรกดูเส้นเรื่อง/ความหมาย/ความแน่นอน; รอบสองอ่านแบบ numbered blocks เทียบกับสิบ decisions เพื่อตรวจภาษา/คำซ้ำ/ขอบเขตเนื้อหา การ audit นี้ไม่ใช่ Owner Acceptance และไม่ได้แก้ข้อความใด\n\n' +
  findings.map(f => `## ${f.id} — ${f.category}\n\nBlocks (zero-based): ${f.blocks.join(', ')}\n\n${f.exactSpans.map(s => `> ${s}`).join('\n\n')}\n\n${f.finding}\n`).join('\n') +
  '\n## Full exact reader copy — ไม่ย่อ/ไม่ตัดข้อความ\n\n' + fullBlock);
const historical = read('docs/OR5R_AUTHORITY_GATE_TRUTH_CORRECTION.json').preservedFiles.map(x => ({...x,
  currentSha256: fileSha(x.path), baseSha256: sha(execFileSync('git', ['show', `${BASE}:${x.path}`]))}));
for (const x of historical) { assert.equal(x.sha256, x.currentSha256); assert.equal(x.sha256, x.baseSha256); }
const oracle = read('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
assert.equal(oracle.source.acceptedReaderFacingSha256.toUpperCase(), '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E');
const validation = {schema: 'or5r-neutral-validation/2', sourceBase: BASE, validatorCommit: execFileSync('git', ['log', '-1', '--format=%H', '--', 'tool/or5r_actual_authority_v2.mjs'], {encoding: 'utf8'}).trim(),
  extraction: {runs: [1,2].map(i => ({run: i, passed: 2, failed: 0, log: `${logDir}/extraction-${i}.log`, sha256: fileSha(`${logDir}/extraction-${i}.log`)})), determinism},
  node: {tests: tapCount('tests'), passed: tapCount('pass'), failed: tapCount('fail'), skipped: tapCount('skipped'),
    log: `${logDir}/node-tests.tap`, logSha256: fileSha(`${logDir}/node-tests.tap`),
    controls: {realOwnerAcceptedPositive: 'PASS; excluded from actual totals', sourceFieldPositive: 'PASS; test-only fact, not product prediction',
      namedNegativeControls: 12, duplicateSemanticOwnerControl: 1, additionalMissingRoleControls: 5,
      candidateOracleNegativeControls: 13, existingEvidenceResolverNegativeControls: 9}},
  historicalEvidence: historical, candidateReaderSha256: oracle.source.acceptedReaderFacingSha256.toUpperCase(),
  actualAuthority: totals, semanticSlots: slotTotals, contentReview: review.status,
  commands: ['powershell -ExecutionPolicy Bypass -File tool/or5r_neutral_validation.ps1 -Extract',
    'node tool/or5r_actual_authority_v2.mjs', 'node tool/or5r_neutral_evidence.mjs',
    'powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PreCommit',
    'powershell -ExecutionPolicy Bypass -File scripts/knowme_task_gate.ps1 -ScopeFile task_scope.json -Phase PostCommit', 'git diff --check'],
  firstPreCommitLog: 'build/or5r-neutral-precommit-1.log', firstPostCommitLog: 'build/or5r-neutral-postcommit-1.log',
  fullFlutterAndAnalyzer: 'NOT RERUN: user-authorized evidence/tool-only task, no Dart/runtime/Flutter-test delta. Existing focused Dart extraction/oracle tests only. No new PDF/Web generation.'};
writeJson('docs/OR5R_NEUTRAL_V2_VALIDATION.json', validation);
// Validate the actual emitted files, including full block boundaries, not just memory.
assert.equal(read('docs/ACTUAL_0035_CONTENT_REVIEW.json').fullExactReaderText, fullText);
for (const p of ['docs/ACTUAL_0035_FULL_READER_COPY.md', 'docs/ACTUAL_0035_CONTENT_REVIEW.md']) assert.ok(fs.readFileSync(p, 'utf8').includes(fullBlock));
assert.deepEqual(read('docs/ACTUAL_0035_EMITTED_PREDICTIONS.json').entries.map(e => e.text), entries.map(e => e.text));
console.log(JSON.stringify({authority: totals, slots: slotTotals, contentFindings: findings.length, determinism, fullTextSha256: sha(fullText)}, null, 2));
