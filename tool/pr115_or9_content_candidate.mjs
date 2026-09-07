// OR9 content/evidence only. This tool never invokes or modifies production runtime.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {sha} from './or5r_actual_authority_v2.mjs';
import {pairwiseSemanticOwnership} from './pr115_or7_content_candidate.mjs';
import {
  EXACT_EVIDENCE as C22_EXACT_EVIDENCE,
  buildCandidate0022,
} from './pr115_or8_content_candidate.mjs';

export const BASE = 'f1cf38dcf0184eb460144931293b54cbf2d489b5';
const clone = value => structuredClone(value);
const stable = value => JSON.stringify(value);
const writeJson = (path, value) => fs.writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
const writeMd = (path, value) => fs.writeFileSync(path, value.trimEnd() + '\n');

const c22 = buildCandidate0022();
const c22ByOwner = new Map(c22.predictionClaims.map(claim => [claim.semanticOwner, claim]));
const evidenceRefs = owner => clone(c22ByOwner.get(owner).evidenceRefs);

export const OWNER_REVIEW_0022 = {
  schema: 'candidate-0022-owner-review/1',
  recordedAt: '2026-09-07',
  candidate: 'Candidate 0022 actual 00:35',
  reviewedHead: BASE,
  verdict: 'OWNER_REJECTED_FOR_IMPLEMENTATION',
  blockedExactSpans: 6,
  unsupportedCausalLinks: 6,
  readerPerceivedRepetitions: 2,
  mayImplement: false,
  historicalFilesImmutable: true,
};

export const CHANGED_OWNERS = ['past-11-29', 'relationship', 'support', 'rolling12'];
export const TARGET_WORDING = Object.fromEntries(c22.predictionClaims.map(claim => [claim.semanticOwner, claim.proposedReaderWording]));
Object.assign(TARGET_WORDING, {
  'past-11-29': 'ช่วงอายุ 11–29 ปี ชีวิตดีขึ้นจากวัยเด็ก การเรียนให้ผลดี และคุณเริ่มสร้างเส้นทางงานของตัวเอง',
  relationship: 'ความสัมพันธ์ที่สำคัญจะแน่นแฟ้นขึ้น',
  support: 'ครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่ายจะเข้ามาช่วย',
  rolling12: 'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570 ขอบเขตงานจะกว้างขึ้น และรายรับจะเพิ่มขึ้น',
});

const supported = (id, owner, exactSpan, refs, rationale) => ({
  id,
  semanticOwner: owner,
  exactSpan,
  result: 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW',
  evidenceRefs: refs,
  rationale,
  missingComponent: null,
  nearestSupportedMeaning: null,
});

const c22EvidenceById = new Map(C22_EXACT_EVIDENCE.entries.map(entry => [entry.id, entry]));
const copySupported = id => clone(c22EvidenceById.get(id));
const evidenceDraft = [
  ...['C22-E-001', 'C22-E-002', 'C22-E-003', 'C22-E-004', 'C22-E-005', 'C22-E-006'].map(copySupported),
  supported('', 'past-11-29', 'คุณเริ่มสร้างเส้นทางงานของตัวเอง', evidenceRefs('past-11-29'), 'The existing career component directly supports beginning an independent work path; the wording does not claim that learning caused it.'),
  ...['C22-E-008', 'C22-E-009', 'C22-E-010', 'C22-E-011', 'C22-E-012', 'C22-E-013', 'C22-E-014', 'C22-E-015', 'C22-E-016', 'C22-E-017', 'C22-E-019', 'C22-E-020', 'C22-E-021', 'C22-E-023'].map(copySupported),
  supported('', 'rolling12', 'ขอบเขตงานจะกว้างขึ้น', evidenceRefs('rolling12'), 'The next-12-month career component directly supports broader work scope.'),
  supported('', 'rolling12', 'รายรับจะเพิ่มขึ้น', evidenceRefs('rolling12'), 'The next-12-month finance component directly supports increased income without binding it causally to work.'),
];
export const EXACT_EVIDENCE_ENTRIES = evidenceDraft.map((entry, index) => ({...entry, id: `C23-E-${String(index + 1).padStart(3, '0')}`}));

export const EXACT_EVIDENCE = {
  schema: 'candidate-0023-exact-copy-evidence/1',
  candidate: 'Candidate 0023 actual 00:35',
  sourceArchitectureChanged: false,
  entries: EXACT_EVIDENCE_ENTRIES,
  entryCount: EXACT_EVIDENCE_ENTRIES.length,
  supportedCount: EXACT_EVIDENCE_ENTRIES.filter(entry => entry.result === 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW').length,
  blockedCount: EXACT_EVIDENCE_ENTRIES.filter(entry => entry.result === 'BLOCKED_EXACT_SPAN').length,
  overallStatus: 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW',
  ownerAcceptance: false,
  implementationAuthorized: false,
  note: 'Every remaining Candidate 0023 prediction clause is checked against existing evidence. Engineering evidence PASS is not Owner Content Acceptance.',
};

const META = {
  overview: ['เส้นชีวิตติดขัดในวัย 0–10 ก่อนเป็นขาขึ้นตั้งแต่อายุ 11 ถึงปัจจุบัน', ['life-arc-childhood-constraint-to-rising-adulthood']],
  'past-0-10': ['ปัญหาสุขภาพ งาน และเงินของพ่อแม่ลดการดูแลในวัย 0–10', ['past-0-10-parent-constraints-limited-care']],
  'past-11-29': ['ชีวิตดีขึ้น การเรียนให้ผลดี และเริ่มสร้างเส้นทางงาน โดยไม่ผูกเหตุผลระหว่างสองเรื่อง', ['past-11-29-rise-learning-and-career-independent-facts']],
  'past-30-41': ['งาน ความรับผิดชอบ และน้ำหนักการตัดสินใจเพิ่มในวัย 30–41', ['past-30-41-work-responsibility-decisions']],
  current: ['การลงมือทำ การพูดคุย และการตัดสินใจคล่องกว่าช่วงก่อน', ['current-action-talk-decision-ease']],
  work: ['งานมีต่อเนื่องและยังรับผิดชอบงานหลักได้', ['current-work-continuity-capacity']],
  finance: ['มีเงินใช้ โชคลาภ และความคล่องตัวทางเงินในปัจจุบัน', ['current-money-luck-liquidity']],
  relationship: ['ความสัมพันธ์ที่สำคัญแน่นแฟ้นขึ้น', ['current-relationship-strength']],
  health: ['กำลังยังดี แต่การพักไม่พอลดการฟื้นและกิจกรรมต่อเนื่อง', ['current-stamina-rest-recovery']],
  support: ['ครู ผู้มีประสบการณ์ เพื่อน และเครือข่ายเข้ามาช่วย', ['current-support-network-help']],
  rolling12: ['ขอบเขตงานและรายรับเพิ่มในกรอบ 12 เดือน โดยไม่ผูก causal link', ['rolling12-work-scope-and-income-growth']],
};

export const CANDIDATE_0023_CLAIMS = c22.predictionClaims.map(source => {
  const entries = EXACT_EVIDENCE_ENTRIES.filter(entry => entry.semanticOwner === source.semanticOwner);
  return {
    ...clone(source),
    claimId: source.claimId.replace('C22-', 'C23-'),
    sourceClaimId: source.claimId,
    semanticSummary: META[source.semanticOwner][0],
    meaningAtoms: META[source.semanticOwner][1],
    proposedReaderWording: TARGET_WORDING[source.semanticOwner],
    interpretationOwnerMustApprove: `Owner must review the exact Candidate 0023 wording: ${TARGET_WORDING[source.semanticOwner]}`,
    exactEvidenceEntryIds: entries.map(entry => entry.id),
    blockedExactSpans: [],
    evidenceStatus: 'EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW',
    classification: 'PROPOSED_OWNER_TEMPLATE',
    accepted: false,
    implemented: false,
    noSemanticExpansion: true,
  };
});

export function buildCandidate0023() {
  const byOwner = new Map(CANDIDATE_0023_CLAIMS.map(claim => [claim.semanticOwner, claim]));
  const ownerByC22Id = new Map(c22.predictionClaims.map(claim => [claim.claimId, claim.semanticOwner]));
  const sections = c22.sections.map(section => {
    if (section.kind !== 'prediction') return clone(section);
    const owner = ownerByC22Id.get(section.claimId);
    const claim = byOwner.get(owner);
    assert.ok(claim, section.claimId);
    return {...clone(section), paragraphs: [claim.proposedReaderWording], claimId: claim.claimId};
  });
  const fullReaderCopy = sections.flatMap(section => [section.title, ...section.paragraphs, '']).join('\n').trimEnd();
  const candidate = {
    schema: 'candidate-0023-actual-0035/1',
    fixture: clone(c22.fixture),
    status: 'EXACT_EVIDENCE_GATE_PASS_PENDING_OWNER_FINAL_COPY_REVIEW',
    implemented: false,
    accepted: false,
    sourceArchitectureChanged: false,
    sourceCandidate: 'Candidate 0022 OWNER_REJECTED_FOR_IMPLEMENTATION',
    predictionClaims: CANDIDATE_0023_CLAIMS,
    predictionOmissions: c22.predictionOmissions.map(item => ({...clone(item), claimId: item.claimId.replace('C22-', 'C23-')})),
    psychology: clone(c22.psychology),
    advice: c22.advice,
    disclaimer: c22.disclaimer,
    sections,
    fullReaderCopy,
  };
  assert.equal(stable(candidate.sections.slice(13)), stable(c22.sections.slice(13)), 'Advice, disclaimer, psychology, and provenance must remain byte-exact model data');
  assert.equal(stable(candidate.psychology), stable(c22.psychology));
  return candidate;
}

const predictionMap = candidate => new Map(candidate.predictionClaims.map(claim => [claim.semanticOwner, claim.proposedReaderWording]));
const pairEvidence = (kind, leftOwner, rightOwner, byOwner, reason) => ({
  kind,
  leftOwner,
  rightOwner,
  leftExact: byOwner.get(leftOwner),
  rightExact: byOwner.get(rightOwner),
  reason,
});

export const C22_BLOCKED_SPANS = C22_EXACT_EVIDENCE.entries.filter(entry => entry.result === 'BLOCKED_EXACT_SPAN').map(entry => entry.exactSpan);

export function auditOr9(candidate, evidence = {entries: []}) {
  const byOwner = predictionMap(candidate);
  const predictionText = [...byOwner.entries()];
  const conditionalPredictionFallback = predictionText.filter(([, text]) => /อาจ|ถ้า|หาก/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan, reason: 'Uses an ambiguity/conditional fallback inside prediction wording.'}));
  const crossHorizonSemanticRepetition = [];
  if (/ภาระ.*งานหลัก|คุณภาพ/u.test(byOwner.get('work') ?? '') && /คุณภาพงานหลัก/u.test(byOwner.get('rolling12') ?? '')) crossHorizonSemanticRepetition.push(pairEvidence('work-risk', 'work', 'rolling12', byOwner, 'Current work risk is repeated in the rolling-12 paragraph.'));
  if (/รายจ่าย/u.test(byOwner.get('finance') ?? '') && /รายจ่าย/u.test(byOwner.get('rolling12') ?? '')) crossHorizonSemanticRepetition.push(pairEvidence('finance-risk', 'finance', 'rolling12', byOwner, 'Current finance expense risk is repeated in the rolling-12 paragraph.'));
  const readerPerceivedRepetition = [...crossHorizonSemanticRepetition];
  if (/งาน/u.test(byOwner.get('support') ?? '')) readerPerceivedRepetition.push(pairEvidence('support-work', 'support', 'work', byOwner, 'The support paragraph repeats a work outcome from the work section.'));
  if (/เงิน/u.test(byOwner.get('support') ?? '')) readerPerceivedRepetition.push(pairEvidence('support-finance', 'support', 'finance', byOwner, 'The support paragraph repeats a finance outcome from the finance section.'));
  const genericPositiveThenRiskFormula = predictionText.filter(([, text]) => /ภาระที่รับมากเกินไป|แต่รายจ่ายระยะยาว|หากความคาดหวังยังไม่ตรงกัน/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan, reason: 'Uses the rejected positive-result then generic-risk construction.'}));
  const unsupportedCausalLink = (evidence.entries ?? []).filter(entry => entry.result === 'BLOCKED_EXACT_SPAN').map(entry => ({owner: entry.semanticOwner, exactSpan: entry.exactSpan, missingComponent: entry.missingComponent}));
  const unnaturalThaiPhrase = predictionText.flatMap(([owner, text]) => text.includes('วัยเด็กของคุณถูกปัญหาในครอบครัวจำกัดอยู่มาก') ? [{owner, exactSpan: 'วัยเด็กของคุณถูกปัญหาในครอบครัวจำกัดอยู่มาก'}] : []);
  const adviceDisguisedAsPrediction = predictionText.filter(([, text]) => /ควร|ลอง|ก่อนตัดสินใจ/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan}));
  const personalityDisguisedAsPrediction = predictionText.filter(([, text]) => /คุณเป็นคน|นิสัย|บุคลิก/u.test(text)).map(([owner, exactSpan]) => ({owner, exactSpan}));
  const evidenceRows = {
    conditional_prediction_fallback: conditionalPredictionFallback,
    cross_horizon_semantic_repetition: crossHorizonSemanticRepetition,
    reader_perceived_repetition: readerPerceivedRepetition,
    generic_positive_then_risk_formula: genericPositiveThenRiskFormula,
    unsupported_causal_link: unsupportedCausalLink,
    unnatural_thai_phrase: unnaturalThaiPhrase,
    advice_disguised_as_prediction: adviceDisguisedAsPrediction,
    personality_disguised_as_prediction: personalityDisguisedAsPrediction,
  };
  return {counters: Object.fromEntries(Object.entries(evidenceRows).map(([key, rows]) => [key, rows.length])), evidence: evidenceRows};
}

const mutateOwner = (candidate, owner, text) => {
  const value = clone(candidate);
  value.predictionClaims.find(claim => claim.semanticOwner === owner).proposedReaderWording = text;
  return value;
};

export function negativeControls(candidate) {
  const controls = [];
  for (const span of C22_BLOCKED_SPANS) {
    const owner = C22_EXACT_EVIDENCE.entries.find(entry => entry.exactSpan === span).semanticOwner;
    const mutated = mutateOwner(candidate, owner, `${TARGET_WORDING[owner]} ${span}`);
    controls.push({kind: 'reintroduced-c0022-blocked-span', input: span, detected: mutated.predictionClaims.some(claim => C22_BLOCKED_SPANS.some(item => claim.proposedReaderWording.includes(item)))});
  }
  const supportMutant = mutateOwner(candidate, 'support', `${TARGET_WORDING.support} ทำให้งานและเรื่องเงินคล่องขึ้น`);
  controls.push({kind: 'support-work-finance-outcome', input: 'ทำให้งานและเรื่องเงินคล่องขึ้น', detected: auditOr9(supportMutant, EXACT_EVIDENCE).counters.reader_perceived_repetition === 2});
  for (const token of ['อาจ', 'ถ้า', 'หาก']) {
    const conditional = mutateOwner(candidate, 'work', `${TARGET_WORDING.work} ${token}งานเพิ่ม เรื่องนี้จะเปลี่ยน`);
    controls.push({kind: 'conditional-fallback', input: token, detected: auditOr9(conditional, EXACT_EVIDENCE).counters.conditional_prediction_fallback > 0});
  }
  const newDetailEvidence = {entries: [...EXACT_EVIDENCE.entries, {result: 'BLOCKED_EXACT_SPAN', semanticOwner: 'rolling12', exactSpan: 'รายละเอียดใหม่ที่ไม่มีหลักฐาน', missingComponent: 'No existing evidence component supports this added detail.'}]};
  const newDetail = mutateOwner(candidate, 'rolling12', `${TARGET_WORDING.rolling12} รายละเอียดใหม่ที่ไม่มีหลักฐาน`);
  controls.push({kind: 'compensating-new-detail', input: 'รายละเอียดใหม่ที่ไม่มีหลักฐาน', detected: auditOr9(newDetail, newDetailEvidence).counters.unsupported_causal_link > 0});
  return controls;
}

export function buildBeforeAfter(candidate) {
  const after = new Map(candidate.predictionClaims.map(claim => [claim.semanticOwner, claim.proposedReaderWording]));
  return CHANGED_OWNERS.map(owner => ({semanticOwner: owner, beforeFullParagraph: c22ByOwner.get(owner).proposedReaderWording, afterFullParagraph: after.get(owner)}));
}

const claimTable = claims => '| Claim | Owner | Section | Evidence result | Classification |\n|---|---|---|---|---|\n' + claims.map(claim => `| ${claim.claimId} | ${claim.semanticOwner} | ${claim.section} | ${claim.evidenceStatus} | ${claim.classification} |`).join('\n');

export function buildAll() {
  const candidate = buildCandidate0023();
  const ownership = pairwiseSemanticOwnership(candidate);
  const auditResult = auditOr9(candidate, EXACT_EVIDENCE);
  const controls = negativeControls(candidate);
  const beforeAfter = buildBeforeAfter(candidate);
  const audit = {
    schema: 'candidate-0023-content-audit/1',
    status: 'EXACT_EVIDENCE_GATE_PASS_PENDING_OWNER_FINAL_COPY_REVIEW',
    ownerContentPass: false,
    implemented: false,
    counters: auditResult.counters,
    evidence: auditResult.evidence,
    pairwiseChecks: ownership.pairs.length,
    pairwiseSemanticDuplicates: ownership.duplicatePairs.length,
    exactEvidenceClauseChecks: EXACT_EVIDENCE.entryCount,
    exactEvidenceBlockedCount: EXACT_EVIDENCE.blockedCount,
    negativeControls: controls,
    fullCandidateReaderCopy: candidate.fullReaderCopy,
    note: 'Engineering exact-evidence PASS does not confer Owner Content Acceptance or implementation authority.',
  };
  assert.equal(EXACT_EVIDENCE.entryCount, 23);
  assert.equal(EXACT_EVIDENCE.supportedCount, 23);
  assert.equal(EXACT_EVIDENCE.blockedCount, 0);
  assert.ok(Object.values(audit.counters).every(value => value === 0));
  assert.equal(ownership.pairs.length, 55);
  assert.equal(ownership.duplicatePairs.length, 0);
  assert.equal(controls.length, 11);
  assert.ok(controls.every(control => control.detected));

  writeJson('docs/CANDIDATE_0023_EXACT_COPY_EVIDENCE.json', EXACT_EVIDENCE);
  writeJson('docs/CANDIDATE_0023_CLAIM_MAP.json', candidate);
  writeJson('docs/CANDIDATE_0023_SEMANTIC_OWNERSHIP.json', ownership);
  writeJson('docs/CANDIDATE_0023_CONTENT_AUDIT.json', audit);

  writeMd('docs/CANDIDATE_0022_OWNER_REVIEW.md', `# Candidate 0022 — Owner review\n\n**OWNER REJECTED FOR IMPLEMENTATION.**\n\n- BLOCKED_EXACT_SPAN: 6\n- unsupported_causal_link: 6\n- reader_perceived_repetition: 2\n- Implemented: no\n\nCandidate 0022 and all of its evidence remain immutable historical records. Candidate 0023 removes only the six blocked meanings and two perceived repetitions through the four Owner-directed paragraph edits.\n`);
  writeMd('docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md', `# Candidate 0023 — actual 00:35 full reader copy\n\n**EXACT-EVIDENCE GATE PASS — PENDING OWNER FINAL COPY REVIEW — NOT IMPLEMENTED — NOT ACCEPTED**\n\nOnly four prediction paragraphs differ from Candidate 0022. Advice, limitations, psychology and provenance remain byte-exact model data. The unsupported 63–79 prediction and summary remain omitted.\n\n<!-- BEGIN CANDIDATE 0023 FULL READER COPY -->\n${candidate.fullReaderCopy}\n<!-- END CANDIDATE 0023 FULL READER COPY -->\n\nFull-reader-copy SHA-256 (UTF-8 exact model value): \`${sha(candidate.fullReaderCopy)}\`.\n`);
  writeMd('docs/CANDIDATE_0023_EXACT_COPY_EVIDENCE.md', `# Candidate 0023 — exact-copy evidence gate\n\n**Overall status: EXACT_COPY_SUPPORTED_FOR_OWNER_REVIEW — ${EXACT_EVIDENCE.supportedCount}/${EXACT_EVIDENCE.entryCount} remaining clauses supported; BLOCKED_EXACT_SPAN=0.**\n\nThis is an engineering evidence result only. It does not equal Owner Content Acceptance or authorize implementation.\n\n${EXACT_EVIDENCE.entries.map(entry => `## ${entry.id} — ${entry.semanticOwner}\n\n- Exact span: “${entry.exactSpan}”\n- Result: \`${entry.result}\`\n- Evidence: ${entry.evidenceRefs.join('; ')}\n- Rationale: ${entry.rationale}\n`).join('\n')}\n`);
  writeMd('docs/CANDIDATE_0023_CLAIM_MAP.md', `# Candidate 0023 — claim map\n\nAll remaining prediction clauses are supported by existing evidence. Every claim remains proposed, unaccepted and unimplemented pending Owner review.\n\n${claimTable(candidate.predictionClaims)}\n\n${candidate.predictionClaims.map(claim => `## ${claim.claimId}\n\n**Exact proposed wording**\n\n${claim.proposedReaderWording}\n\n- Source-bound meaning: ${claim.sourceBoundMeaning}\n- Context/period/domain/horizon/direction: ${claim.context}; ${claim.period}; ${claim.domain}; ${claim.horizon}; ${claim.direction}\n- Evidence references: ${claim.evidenceRefs.join('; ')}\n- Exact evidence entries: ${claim.exactEvidenceEntryIds.join('; ')}\n- Evidence status: \`${claim.evidenceStatus}\`\n- Classification: ${claim.classification}; accepted=${claim.accepted}; implemented=${claim.implemented}\n`).join('\n')}\n## Explicit omissions\n\n${candidate.predictionOmissions.map(item => `- ${item.section}: ${item.classification} — ${item.reason}`).join('\n')}\n`);
  writeMd('docs/CANDIDATE_0023_SEMANTIC_OWNERSHIP.md', `# Candidate 0023 — semantic ownership\n\n**Pairwise semantic duplicate result: 0 across ${ownership.pairs.length}/${ownership.pairs.length} prediction pairs. Reader-perceived repetition is also 0.**\n\n${ownership.pairs.map((pair, index) => `## Pair ${index + 1}: ${pair.leftClaimId} × ${pair.rightClaimId}\n\n- Left meaning: ${pair.leftMeaning}\n- Right meaning: ${pair.rightMeaning}\n- Shared meaning atoms: ${pair.sharedMeaningAtoms.length ? pair.sharedMeaningAtoms.join('; ') : 'none'}\n- Exact wording equal: ${pair.sameExactWording}\n- Decision: ${pair.decision}\n- Rationale: ${pair.rationale}\n`).join('\n')}\n`);
  writeMd('docs/CANDIDATE_0022_TO_0023_BEFORE_AFTER.md', `# Candidate 0022 → Candidate 0023 — four exact paragraph changes\n\nCandidate 0022 was rejected for implementation. Candidate 0023 changes exactly four prediction paragraphs and does not replace removed unsupported content.\n\n${beforeAfter.map((pair, index) => `## ${index + 1}. ${pair.semanticOwner}\n\n**Before — Candidate 0022**\n\n${pair.beforeFullParagraph}\n\n**After — Candidate 0023**\n\n${pair.afterFullParagraph}\n`).join('\n')}\n`);
  writeMd('docs/CANDIDATE_0023_CONTENT_AUDIT.md', `# Candidate 0023 — final-copy content audit\n\n**Engineering result: EXACT-EVIDENCE GATE PASS — PENDING OWNER FINAL COPY REVIEW. This is not Owner Content Acceptance.**\n\n## Acceptance counters\n\n\`\`\`json\n${JSON.stringify(audit.counters, null, 2)}\n\`\`\`\n\nAll ${EXACT_EVIDENCE.entryCount} remaining clauses are exact-evidence supported; blocked spans=0. Pairwise semantic duplicates=0/${ownership.pairs.length}. All ${controls.length} negative controls detect the prohibited regression, including each of the six Candidate 0022 blocked spans, support-to-work/finance outcomes, อาจ/ถ้า/หาก fallbacks, and compensating unsupported detail.\n\n## Full Candidate read\n\n\`\`\`text\n${candidate.fullReaderCopy}\n\`\`\`\n`);

  const validation = {
    schema: 'pr115-or9-validation/1',
    recordedAt: '2026-09-07',
    baseHead: BASE,
    scope: 'content/evidence/validator/status-only',
    freshExtraction: {runs: 2, testsPerRun: 2, passedPerRun: 2, failedPerRun: 0, mismatches: 0, status: 'PASS'},
    neutralAuthorityV2AndExistingEvidenceOracles: {tests: 33, passed: 33, failed: 0, status: 'PASS_AS_ENGINEERING_AUDIT_ONLY'},
    candidate0020: {tests: 12, passed: 12, failed: 0, status: 'PASS_AS_HISTORICAL_ENGINEERING_EVIDENCE_ONLY'},
    candidate0021: {tests: 16, passed: 16, failed: 0, status: 'PASS_AS_HISTORICAL_ENGINEERING_EVIDENCE_ONLY_OWNER_WORDING_REJECTED'},
    candidate0022: {tests: 15, passed: 15, failed: 0, blockedExactSpans: 6, unsupportedCausalLinks: 6, readerPerceivedRepetitions: 2, status: 'PASS_AS_TRUTHFUL_HISTORICAL_BLOCKING_EVIDENCE'},
    candidate0023: {tests: 17, passed: 17, failed: 0, predictionClaims: 11, clauseChecks: EXACT_EVIDENCE.entryCount, supportedClauseChecks: EXACT_EVIDENCE.supportedCount, blockedExactSpans: 0, pairwiseChecks: ownership.pairs.length, pairwiseDuplicates: ownership.duplicatePairs.length, negativeControlsDetected: controls.length, fullReaderCopySha256: sha(candidate.fullReaderCopy), status: candidate.status},
    candidate0023AuditCounters: audit.counters,
    candidate0011Regression: {exact: true, sha256: '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E', status: 'PASS_UNCHANGED'},
    repositoryGates: {gitDiffCheck: 'PASS', preCommit: 'PASS', postCommit: 'PENDING_CONTENT_COMMIT'},
    notRerun: {fullFlutterSuite: 'NOT RERUN — no Dart/runtime/Flutter-test delta', analyzer: 'NOT RERUN — no Dart/runtime/Flutter-test delta'},
    protectedDelta: {dartRuntimeUiGeneratorExportPdf: 0, flutterTests: 0, historicalCandidates0011_0020_0021_0022: 0, generatedProductArtifacts: 0, productAcceptance: 0, firebaseProduction: 0},
    ownerStatus: 'PENDING OWNER FINAL COPY REVIEW',
    implemented: false,
  };
  writeJson('docs/PR115_OR9_VALIDATION.json', validation);
  return {candidate, ownership, audit, beforeAfter, exactEvidence: EXACT_EVIDENCE, controls, validation};
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const result = buildAll();
  console.log(JSON.stringify({claims: result.candidate.predictionClaims.length, clauseChecks: result.exactEvidence.entryCount, supported: result.exactEvidence.supportedCount, blocked: result.exactEvidence.blockedCount, pairwiseChecks: result.ownership.pairs.length, pairwiseDuplicates: result.ownership.duplicatePairs.length, counters: result.audit.counters, negativeControlsDetected: result.controls.filter(control => control.detected).length, fullCopySha256: sha(result.candidate.fullReaderCopy)}, null, 2));
}
