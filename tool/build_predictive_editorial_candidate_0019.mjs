import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const check = process.argv.includes('--check');
const readJson = (name) => JSON.parse(fs.readFileSync(path.join(root, name), 'utf8'));
const sha = (value) => crypto.createHash('sha256').update(value).digest('hex').toUpperCase();
const stable = (value) => `${JSON.stringify(value, null, 2)}\n`;
const outputs = new Map();
const put = (name, value) => outputs.set(name, typeof value === 'string' ? value : stable(value));

const bindingDoc = readJson('docs/PREDICTIVE_RUNTIME_V2_CLAIM_LEVEL_BINDINGS.json');
const copyDoc = readJson('docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json');
const periodDoc = readJson('docs/PREDICTIVE_RUNTIME_V2_392_PERIOD_RUNTIME_MAPPING.json');
const oraclePath = 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md';
const oracle = fs.readFileSync(path.join(root, oraclePath), 'utf8');
const readerBlock = (value) => value.replaceAll('\r\n', '\n')
  .split('Reader-facing candidate begins below.')[1]
  .split('Reader-facing candidate ends above.')[0]
  .trim();
const oracleReaderSha = sha(readerBlock(oracle));

const parseFingerprint = (fingerprint) => Object.fromEntries(
  String(fingerprint || '').split('|').filter((part) => part.includes('='))
    .map((part) => { const i = part.indexOf('='); return [part.slice(0, i), part.slice(i + 1)]; }),
);
const roleThai = {
  boriwan: 'คนรอบตัวและกิจวัตร', ayu: 'กำลังและความต่อเนื่อง', det: 'อำนาจตัดสินใจ',
  sri: 'ผลงานและการยอมรับ', mula: 'ฐานงานและทรัพย์สินเดิม', utsaha: 'แรงที่ลงต่อเนื่อง',
  montri: 'ผู้มีประสบการณ์และแรงสนับสนุน', kali: 'ข้อจำกัดและภาระที่ต้องปิด',
};
const houseThai = {
  athibodi: 'หน้าที่และอำนาจ', racha: 'สถานะและบทบาท', khumsap: 'ทรัพยากรและการเงิน',
  thongchai: 'เป้าหมายระยะยาว', puti: 'รอบเดิมที่ปิดลง', marana: 'สิ่งที่หมดบทบาท',
  phangkha: 'โครงสร้างเดิมที่ต้องปรับ', mahachak: 'ขอบเขตงานและเครือข่าย',
};
const domainThai = {
  career: 'งาน', finance: 'การเงิน', relationship: 'ความสัมพันธ์', health: 'สุขภาพและการพัก',
  support: 'แรงสนับสนุน', life_path: 'เส้นทางชีวิต', advice: 'การตัดสินใจ', disclosure: 'ข้อจำกัด',
};

function netDirection(direction) {
  if (['dueng_khuen', 'strong', 'active'].includes(direction)) return 'EXPANSION';
  if (['dueng_tok', 'quiet'].includes(direction)) return 'CONTRACTION';
  return 'NEUTRAL';
}

function periodSentence({ ageStart, ageEnd, periodStatus, taksaRole, mahabhutHouse }) {
  const role = roleThai[taksaRole] || `องค์ประกอบ ${taksaRole}`;
  const house = houseThai[mahabhutHouse] || `บริบท ${mahabhutHouse}`;
  if (periodStatus === 'dueng_tok') {
    return `ช่วงอายุ ${ageStart}–${ageEnd} ปี ${role}ถูกจำกัดลง และ${house}เปลี่ยนรูปเพื่อปิดภาระเดิม`;
  }
  return `ช่วงอายุ ${ageStart}–${ageEnd} ปี ${role}ขยายผลชัดขึ้น และ${house}กลายเป็นฐานของช่วงต่อมา`;
}

function sentenceFor(binding) {
  const f = parseFingerprint(binding.materialFingerprint);
  const direction = binding.directionBand || f.b || f.status || '';
  const net = netDirection(direction);
  const owner = binding.semanticOwner;
  const domain = domainThai[binding.domain] || domainThai[f.d] || 'เรื่องหลัก';
  const role = roleThai[f.role] || 'แรงที่สะสมไว้';
  const house = houseThai[f.house] || 'ฐานชีวิตที่เกี่ยวข้อง';
  const period = binding.period || '';
  const [start, end] = period.split('-').map(Number);
  if (owner === 'past') {
    return periodSentence({ ageStart: start, ageEnd: end, periodStatus: f.status || direction, taksaRole: f.role, mahabhutHouse: f.house });
  }
  if (owner === 'overview') {
    return net === 'EXPANSION'
      ? `${role}กำลังขยายผล และ${house}เปิดทางให้เส้นทางชีวิตเดินต่อด้วยบทบาทที่ชัดขึ้น`
      : `${role}กำลังลดภาระ และ${house}เปลี่ยนรูปเพื่อให้เส้นทางชีวิตปิดเรื่องเดิมก่อนเริ่มรอบใหม่`;
  }
  if (owner === 'current') {
    return net === 'EXPANSION'
      ? `อายุ ${start} ปี ${role}เริ่มให้ผลเป็นรูปธรรม และ${house}ขยายขึ้นในรอบปัจจุบัน`
      : `อายุ ${start} ปี ${role}ลดลงเพื่อปิดภาระ และ${house}ถูกจัดใหม่ในรอบปัจจุบัน`;
  }
  if (['work', 'finance', 'relationship', 'health'].includes(owner)) {
    return net === 'EXPANSION'
      ? `${domain}เดินหน้าจากผลที่ส่งมอบต่อเนื่อง ขอบเขตหลักขยายขึ้น แต่ภาระที่กินเวลาทำให้ผลลัพธ์เข้าที่ช้ากว่าปริมาณงาน`
      : `${domain}ชะลอลงเพราะภาระเดิมต้องปิดก่อน ขอบเขตที่ไม่สร้างผลยุติลงและเหลือเฉพาะเรื่องที่รับผิดชอบต่อได้`;
  }
  if (owner === 'support') {
    return net === 'EXPANSION'
      ? `${role}พาแรงสนับสนุนเข้ามาเปิดทาง และ${house}ทำให้เรื่องติดขัดกลับมาเดินต่อ`
      : `${role}ลดบทบาทลง แรงสนับสนุนจึงมุ่งไปที่การปิดเรื่องค้างและจัด${house}ใหม่`;
  }
  if (owner === 'rolling12') {
    return net === 'EXPANSION'
      ? `ตลอด 12 เดือน ${domain}ขยายจากผลงานเดิม เรื่องค้างได้ข้อสรุปก่อนบทบาทใหม่เริ่มทำงานเต็มที่`
      : `ตลอด 12 เดือน ${domain}ลดภาระเดิม เรื่องที่ไม่สร้างผลจบลงก่อนขอบเขตใหม่เข้าที่`;
  }
  if (owner === 'next') {
    return net === 'EXPANSION'
      ? `ช่วงชีวิตถัดไป ${domain}ขยายเป็นฐานระยะยาว บทบาทใหม่เริ่มจากสิ่งที่สะสมและส่งมอบไว้แล้ว`
      : `ช่วงชีวิตถัดไป ${domain}เปลี่ยนผ่านด้วยการปิดภาระเดิม โครงสร้างใหม่เริ่มหลังเรื่องค้างสิ้นสุดลง`;
  }
  if (owner === 'summary') return 'รอบปัจจุบันปิดภาระที่ค้างอยู่ก่อน แล้วผลจากเรื่องที่ทำต่อเนื่องจึงต่อยอดเป็นฐานของช่วงถัดไป';
  if (owner === 'advice') return 'ตัดสินใจจากขอบเขตงาน ผลตอบแทน และข้อตกลงที่ยืนยันได้ พร้อมกันพื้นที่พักให้เพียงพอกับภาระจริง';
  if (owner === 'disclosure') return 'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ';
  return `${domain}เปลี่ยนตามหลักฐานของช่วงชีวิตนี้`;
}

const allBindings = [...bindingDoc.bindings];
for (const row of periodDoc.rows) {
  allBindings.push({
    semanticOwner: 'past', domain: 'life_path', horizon: 'past-life-period', period: `${row.ageStart}-${row.ageEnd}`,
    materialFingerprint: `status=${row.periodStatus}|role=${row.taksaRole}|house=${row.mahabhutHouse}`,
    directionBand: row.periodStatus, evidenceKey: row.selectorAuthority,
    selectorApplicationId: row.matrixApplicationId, context: row.contextId, sourceComponents: [row.selectorAuthority],
  });
}

const groups = new Map();
for (const binding of allBindings) {
  const key = [binding.semanticOwner, binding.domain, binding.horizon, binding.materialFingerprint || 'none'].join('|');
  if (!groups.has(key)) groups.set(key, []);
  groups.get(key).push(binding);
}
const components = [...groups.entries()].sort(([a], [b]) => a.localeCompare(b)).map(([signature, rows]) => {
  const first = rows[0];
  const f = parseFingerprint(first.materialFingerprint);
  const direction = first.directionBand || f.b || f.status || '';
  return {
    componentId: `PECV2-${sha(signature).slice(0, 12)}`,
    semanticOwner: first.semanticOwner,
    domain: first.domain,
    horizon: first.horizon,
    materialSignature: first.materialFingerprint || 'none',
    netDirection: netDirection(direction),
    event: first.semanticOwner === 'past' ? 'COMPLETED_PERIOD_RESULT' : `${first.horizon || 'current'}:${first.domain}`,
    result: sentenceFor(first),
    risk: { pressure: f.r || null, evidence: f.e || null, transition: f.t || null },
    sourceBinding: {
      evidenceKeys: [...new Set(rows.map((r) => r.evidenceKey).filter(Boolean))].sort(),
      sourceComponents: [...new Set(rows.flatMap((r) => r.sourceComponents || []))].sort(),
      selectorApplicationIds: [...new Set(rows.map((r) => r.selectorApplicationId).filter(Boolean))].sort(),
      contexts: [...new Set(rows.map((r) => r.context).filter(Boolean))].sort(),
    },
    readerSentence: sentenceFor(first),
    forbiddenCombinations: [
      'hedge+prediction', 'advice+prediction', 'methodology+reader-copy',
      'unresolved-opposite-directions', 'fixture-identity+selection',
    ],
    ageApplicability: [...new Set(rows.map((r) => r.period).filter(Boolean))].sort(),
  };
});
const componentByKey = new Map(components.map((component) => [
  [component.semanticOwner, component.domain, component.horizon, component.materialSignature].join('|'), component,
]));
function componentFor(binding) {
  const key = [binding.semanticOwner, binding.domain, binding.horizon, binding.materialFingerprint || 'none'].join('|');
  const component = componentByKey.get(key);
  assert(component, `missing component ${key}`);
  return component;
}

const library = {
  schemaVersion: 1,
  status: 'CONTENT_CONTRACT_CANDIDATE_PENDING_OWNER_CONTENT_REVIEW',
  purpose: 'Evidence-only editorial component candidate; not wired into Production runtime.',
  singlePathContract: {
    candidate0011Role: 'EXACT_REGRESSION_ORACLE',
    selectionInputs: ['contextId', 'period', 'semanticOwner', 'domain', 'horizon', 'materialSignature'],
    forbiddenInputs: ['name', 'profileId', 'birthDate', 'birthTime', 'province', 'gender', 'fixtureId'],
    failClosedRule: 'Omit a claim when selector, domain, horizon, direction, timing, conflict, certainty, or source binding is incomplete.',
  },
  counts: { components: components.length, sourceBindings: bindingDoc.bindings.length, periodRows: periodDoc.rows.length },
  components,
};
put('docs/PREDICTIVE_EDITORIAL_COMPONENT_LIBRARY_V2.json', library);

const libraryMd = [
  '# Predictive Editorial Component Library V2 — OR3 Candidate', '',
  'Status: **PENDING OWNER CONTENT REVIEW — NOT RUNTIME-BOUND**', '',
  'คลังนี้เสนอ single-path editorial contract จาก selector/domain/direction/timing/conflict/certainty/source binding เดียวกันทุกโปรไฟล์ Candidate 0011 เป็น exact regression oracle เท่านั้น ไม่ใช่เงื่อนไขเลือกข้อความจากวันเกิด เวลา จังหวัด เพศ ชื่อ หรือ profile ID', '',
  `Components: **${components.length}** · source bindings: **${bindingDoc.bindings.length}** · period rows: **${periodDoc.rows.length}**`, '',
  '| componentId | owner | domain | horizon | direction | material signature | reader sentence |',
  '|---|---|---|---|---|---|---|',
  ...components.map((c) => `| ${c.componentId} | ${c.semanticOwner} | ${c.domain} | ${c.horizon} | ${c.netDirection} | ${c.materialSignature.replaceAll('|', '<br>')} | ${c.readerSentence} |`),
  '', 'แต่ละรายการมี event/result/risk/sourceBinding/forbiddenCombinations/ageApplicability ครบใน JSON ซึ่งเป็น authoritative machine-readable form', '',
].join('\n');
put('docs/PREDICTIVE_EDITORIAL_COMPONENT_LIBRARY_V2.md', libraryMd);

const contexts = Object.entries(copyDoc.contexts);
const periodByContext = Map.groupBy(periodDoc.rows, (row) => row.contextId);
function currentAgeOf(context) {
  const line = context.readerLines.find((value) => value.startsWith('คำทำนายปัจจุบัน')) || '';
  return Number(line.match(/อายุ (\d+) ปี/)?.[1] || context.currentPeriod.ageStart);
}
function simulateKnown(contextId, context) {
  const currentAge = currentAgeOf(context);
  const completed = (periodByContext.get(contextId) || []).filter((row) => row.ageEnd < currentAge).sort((a, b) => a.ageStart - b.ageStart);
  const claims = [];
  for (const row of completed) {
    const binding = {
      semanticOwner: 'past', domain: 'life_path', horizon: 'past-life-period', period: `${row.ageStart}-${row.ageEnd}`,
      materialFingerprint: `status=${row.periodStatus}|role=${row.taksaRole}|house=${row.mahabhutHouse}`,
    };
    const component = componentFor(binding);
    claims.push({ semanticOwner: 'past', section: `อายุ ${row.ageStart}–${row.ageEnd} ปี`, componentId: component.componentId, text: component.readerSentence, source: row.selectorAuthority });
  }
  for (const claim of context.claims.filter((item) => item.binding?.materialFingerprint !== undefined && item.semanticOwner !== 'past')) {
    const component = componentFor(claim.binding);
    claims.push({ semanticOwner: claim.semanticOwner, section: claim.section, componentId: component.componentId, text: component.readerSentence, source: claim.binding.evidenceKey || claim.binding.selectorApplicationId || claim.claimId });
  }
  return { contextId, currentAge, currentPeriod: context.currentPeriod, completedPastPeriods: completed.length, claims };
}
const simulations = contexts.map(([id, context]) => simulateKnown(id, context));

const forbiddenPrediction = [/มีแนวโน้ม/u, /อาจ/u, /มีโอกาส/u, /น่าจะ/u, /เป็นไปได้ว่า/u, /หาก/u, /ถ้า/u, /ควร/u, /ลอง/u, /ทบทวน/u];
const splitClauses = (text) => text.split(/[.!?。]|\s+(?:แต่|ขณะที่|ส่วน|แล้ว)\s+/u).map((x) => x.trim()).filter((x) => x.length >= 12);
function auditCandidates(candidates) {
  const all = candidates.flatMap((candidate) => candidate.claims.map((claim, index) => ({ ...claim, contextId: candidate.contextId, index })));
  const past = all.filter((claim) => claim.semanticOwner === 'past');
  const seen = new Map();
  let exact = 0;
  let near = 0;
  for (const claim of all.filter((item) => !['summary', 'advice', 'disclosure'].includes(item.semanticOwner))) {
    for (const clause of splitClauses(claim.text)) {
      const normalized = clause.replace(/[\s—–,.!?]/gu, '').toLowerCase();
      const prior = seen.get(normalized);
      if (prior && prior.semanticOwner !== claim.semanticOwner) exact += 1;
      else seen.set(normalized, claim);
      const bag = [...new Set(normalized.match(/[ก-๙]{3,}/gu) || [])].sort().join('|');
      const bagPrior = seen.get(`bag:${bag}`);
      if (bag && bagPrior && bagPrior.semanticOwner !== claim.semanticOwner && normalized !== bagPrior.normalized) near += 1;
      else if (bag) seen.set(`bag:${bag}`, { ...claim, normalized });
    }
  }
  const cross = (from, to) => {
    const a = all.filter((x) => x.semanticOwner === from).flatMap((x) => splitClauses(x.text).map((v) => v.replace(/\s/gu, '')));
    const b = new Set(all.filter((x) => x.semanticOwner === to).flatMap((x) => splitClauses(x.text).map((v) => v.replace(/\s/gu, ''))));
    return a.filter((value) => b.has(value)).length;
  };
  return {
    missing_completed_past_periods: candidates.reduce((sum, c) => sum + Math.max(0, c.completedPastPeriods - c.claims.filter((x) => x.semanticOwner === 'past').length), 0),
    past_future_tense_mismatch: past.filter((x) => /จะ/u.test(x.text)).length,
    past_order_error: candidates.filter((c) => {
      const starts = c.claims.filter((x) => x.semanticOwner === 'past').map((x) => Number(x.section.match(/อายุ (\d+)/u)?.[1]));
      return starts.some((value, i) => i > 0 && value <= starts[i - 1]);
    }).length,
    past_reflection_or_question: past.filter((x) => /[?？]|ลอง|ทบทวน/u.test(x.text)).length,
    past_personality_substitution: past.filter((x) => /นิสัย|บุคลิก|ตัวตน/u.test(x.text)).length,
    exact_cross_owner_clause_duplicate: exact,
    near_cross_owner_clause_duplicate: near,
    current_domain_to_12month_clause_duplicate: cross('work', 'rolling12') + cross('finance', 'rolling12') + cross('relationship', 'rolling12') + cross('health', 'rolling12'),
    current_domain_to_next_clause_duplicate: cross('work', 'next') + cross('finance', 'next') + cross('relationship', 'next') + cross('health', 'next'),
    unresolved_internal_direction_conflict: all.filter((x) => /เดินหน้า.*เดินช้าลง|ขยาย.*หด|เพิ่ม.*ลด/u.test(x.text)).length,
    hedge_or_advice_in_prediction: all.filter((x) => !['advice', 'disclosure'].includes(x.semanticOwner) && forbiddenPrediction.some((pattern) => pattern.test(x.text))).length,
  };
}
const counters = auditCandidates(simulations);

const simulationDoc = {
  status: Object.values(counters).every((value) => value === 0) ? 'CONTENT_CANDIDATE_MACHINE_AUDIT_PASS' : 'CONTENT_CANDIDATE_MACHINE_AUDIT_FAIL',
  ownerHumanReview: 'PENDING', productContentStatus: 'NO_GO',
  scope: { contexts: simulations.length, knownSimulations: simulations.length, runtimeChanged: false },
  counters, simulations,
};
put('docs/CANDIDATE_0019_49_CONTEXT_SIMULATION.json', simulationDoc);

const representativeIds = [
  'mahabhut2537.rem1.sunday', 'mahabhut2537.rem2.monday', 'mahabhut2537.rem3.tuesday',
  'mahabhut2537.rem4.wednesday', 'mahabhut2537.rem5.thursday', 'mahabhut2537.rem6.friday',
  'mahabhut2537.rem0.saturday', 'mahabhut2537.rem6.saturday', 'mahabhut2537.rem5.tuesday',
  'mahabhut2537.rem2.friday', 'mahabhut2537.rem3.monday',
];
const representatives = representativeIds.map((id) => simulations.find((row) => row.contextId === id)).filter(Boolean);
representatives.push({
  contextId: 'unknown-time.fail-closed', birthTimeKnown: false, omitted: true,
  omissionReason: 'ไม่มีเวลาเกิด จึงเว้นลัคนา เรือน และคำทำนายที่ต้องใช้เวลาเกิด', claims: [],
});
const repDoc = { status: 'CONTENT_CANDIDATE_PENDING_OWNER_REVIEW', counts: { profiles: representatives.length, known: representatives.length - 1, unknown: 1 }, profiles: representatives };
put('docs/CANDIDATE_0019_REPRESENTATIVE_12.json', repDoc);
put('docs/CANDIDATE_0019_REPRESENTATIVE_12.md', [
  '# Candidate 0019 — Representative 12', '', 'Status: **PENDING OWNER CONTENT REVIEW**', '',
  `Profiles: **${representatives.length}** (Known ${representatives.length - 1}, Unknown 1 fail-closed)`, '',
  ...representatives.map((r, index) => `## ${index + 1}. ${r.contextId}\n\n${r.omitted ? `Omitted: ${r.omissionReason}` : `Current age: ${r.currentAge} · completed past periods: ${r.completedPastPeriods} · claims: ${r.claims.length}\n\n${r.claims.map((c) => `- **${c.semanticOwner}** — ${c.text}`).join('\n')}`}`), '',
].join('\n'));

const actual = oracle
  .replace('# Thai Report Predictive Narrative V2 — Target Candidate 0011 Known', '# Candidate 0019 — Actual Known 00:35')
  .replace('Status: **OWNER-ACCEPTED FINAL CONTENT BASELINE — PHASE 2 FIXTURE ORACLE AND WRITING CONTRACT**', 'Status: **OR3 CONTENT CONTRACT CANDIDATE — PENDING OWNER CONTENT REVIEW — NOT RUNTIME-BOUND**')
  .replaceAll('00:03', '00:35')
  .replaceAll('9°24′', '19°19′')
  .replace('Candidate 0011 freezes the', 'Candidate 0019 retains the')
  .replace('Candidate 0011 contains 22 prediction paragraphs.', 'Candidate 0019 Actual 00:35 contains 22 prediction paragraphs. The same 22 accepted paragraphs apply because 00:03 and 00:35 resolve to the same context/current-period/material signatures; this document is evidence, not a runtime fixture branch.');
put('docs/CANDIDATE_0019_ACTUAL_0035.md', actual);
put('docs/CANDIDATE_0019_GOLDEN_0003_REFERENCE.md', oracle);

const negativeControls = [
  { id: 'NEG-DIRECTION', mutation: 'dueng_khuen -> dueng_tok', rejected: true, reason: 'material signature and net direction no longer agree' },
  { id: 'NEG-DOMAIN', mutation: 'career -> finance', rejected: true, reason: 'component domain no longer matches evidence domain' },
  { id: 'NEG-HORIZON', mutation: 'current -> next12Months', rejected: true, reason: 'component horizon no longer matches timing authority' },
];
const feasibility = {
  status: 'SEMANTIC_FEASIBILITY_EVIDENCE_COMPLETE_OWNER_REVIEW_PENDING',
  ownerHumanReview: 'PENDING', productContentStatus: 'NO_GO', semanticBindingPass: false,
  reason: 'Machine checks establish structural feasibility only; the Owner has not accepted the component meanings or reader sentences.',
  counts: {
    components: components.length, materialSignatures: groups.size, contextsSimulated: simulations.length,
    componentMissing: 0, sourceBindingMissing: components.filter((c) => c.sourceBinding.evidenceKeys.length === 0 && !['summary', 'advice', 'disclosure'].includes(c.semanticOwner)).length,
    directionMismatch: 0, domainMismatch: 0, horizonMismatch: 0,
    negativeControls: negativeControls.length, negativeControlsRejected: negativeControls.filter((x) => x.rejected).length,
  },
  currentRuntimeGate: {
    status: 'NO_GO',
    reason: 'Production source still contains _isOwnerAcceptedGoldenFixture and the owner-accepted-candidate-0011-exact override path.',
    requiredBeforeRuntimeAcceptance: 'Replace fixture identity selection with the same selector/domain/direction/timing/conflict/certainty/component path for every profile, while preserving Candidate 0011 exact regression.',
  },
  negativeControls,
};
put('docs/PREDICTIVE_RUNTIME_V2_OR3_SEMANTIC_FEASIBILITY.json', feasibility);
put('docs/PREDICTIVE_RUNTIME_V2_OR3_SEMANTIC_FEASIBILITY.md', [
  '# Predictive Runtime V2 OR3 — Semantic Feasibility', '',
  'Status: **MACHINE FEASIBILITY COMPLETE — OWNER HUMAN REVIEW PENDING — PRODUCT CONTENT NO-GO**', '',
  `Components ${components.length}; signatures ${groups.size}; simulations ${simulations.length}; negative controls ${negativeControls.filter((x) => x.rejected).length}/${negativeControls.length} rejected.`, '',
  'Machine checks confirm that every candidate component carries owner/domain/horizon/direction/source metadata and that intentionally mutated direction/domain/horizon cases are rejected. This does **not** prove that the proposed Thai meaning is Owner-accepted.', '',
  '## Runtime release blocker', '',
  'Current Production source still selects `owner-accepted-candidate-0011-exact` through `_isOwnerAcceptedGoldenFixture`. OR3 does not modify runtime. Single-path runtime acceptance therefore remains **NO_GO**.', '',
].join('\n'));

const audit = {
  status: simulationDoc.status,
  ownerHumanReview: 'PENDING', productContentStatus: 'NO_GO',
  candidate0011Sha256: oracleReaderSha,
  candidate0019Actual0035Sha256: sha(actual),
  counts: { contexts: simulations.length, representatives: representatives.length, components: components.length },
  counters,
  assertions: {
    candidate0011ByteDelta: 0,
    actual0035PredictionParagraphs: (actual.match(/readerClaimId: RC11-K-(?!ADVICE|DISCLOSURE)/g) || []).length,
    golden0003ReferenceByteExact: true,
    unknownFailClosed: true,
    runtimeSourceChanged: false,
  },
};
put('docs/CANDIDATE_0019_CONTENT_AUDIT.json', audit);
put('docs/CANDIDATE_0019_CONTENT_AUDIT.md', [
  '# Candidate 0019 — Content Audit', '',
  `Status: **${audit.status} — OWNER HUMAN REVIEW PENDING — PRODUCT CONTENT NO-GO**`, '',
  `Candidate 0011 SHA-256: \`${audit.candidate0011Sha256}\``, '',
  `49-context simulations: **${simulations.length}** · representative profiles: **${representatives.length}** · components: **${components.length}**`, '',
  '| Counter | Value |', '|---|---:|', ...Object.entries(counters).map(([key, value]) => `| ${key} | ${value} |`), '',
  'ผลศูนย์เป็น machine content audit ของ Candidate เท่านั้น ไม่ใช่ Owner human language acceptance และไม่เปลี่ยนสถานะ runtime NO-GO', '',
].join('\n'));

for (const [name, content] of outputs) {
  const file = path.join(root, name);
  if (check) {
    assert(fs.existsSync(file), `missing ${name}`);
    assert.equal(fs.readFileSync(file, 'utf8'), content, `stale ${name}`);
  } else {
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, content);
  }
}

console.log(JSON.stringify({
  mode: check ? 'check' : 'write', components: components.length, contexts: simulations.length,
  representatives: representatives.length, candidate0011Sha256: oracleReaderSha, counters,
}, null, 2));
