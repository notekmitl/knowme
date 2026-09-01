#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { recomputeEvidenceOwners, validateAuditSeparation } from './validate_predictive_authority_foundation_v3_or4.mjs';

const ROOT = process.cwd();
const readJson = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const candidate = readJson('docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_CANDIDATE_0016_CLAIM_EVIDENCE_SYNTHESIS_MAP.json');
const ledger = readJson('docs/TARGET_0003_PREDICTIVE_EVIDENCE_OWNER_LEDGER_V1.json');
const knownText = fs.readFileSync(path.join(ROOT, 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_KNOWN.md'), 'utf8');
const unknownText = fs.readFileSync(path.join(ROOT, 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0016_UNKNOWN.md'), 'utf8');
const claims = [candidate.known.overview, ...candidate.known.predictions, candidate.known.advice];
const computed = {
  paragraphTextMissing: claims.filter((claim) => !knownText.includes(claim.fullReaderText)).map((claim) => claim.claimId),
  ownerTraceMismatch: candidate.known.predictions.filter((claim) => JSON.stringify(recomputeEvidenceOwners(claim.signalRefs, ledger)) !== JSON.stringify([...claim.evidenceOwnerIds].sort())).map((claim) => claim.claimId),
  causalClaimIds: candidate.known.predictions.filter((claim) => claim.containsCausalWording).map((claim) => claim.claimId),
  duplicateSemanticOwners: candidate.known.predictions.map((claim) => claim.semanticOwner).filter((owner, index, values) => values.indexOf(owner) !== index),
  prohibitedPhraseHits: [...knownText.matchAll(/มีแนวโน้ม|น่าจะ|ตามหลักฐาน|ข้อมูลจากเรือน|ดวงขึ้นภายใต้อิทธิพล|งานที่.*(?:ทำให้|ช่วยให้).*เงิน/gu)].map((match) => match[0]),
  disclaimerKnown: (knownText.match(/ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน/gu) ?? []).length,
  disclaimerUnknown: (unknownText.match(/ไม่ใช่ข้อยืนยันว่าเหตุการณ์จะเกิดขึ้นแน่นอน/gu) ?? []).length,
  unknownPredictionClaims: candidate.unknown.predictionClaims.length,
  summaryOmitted: candidate.known.summaryOmitted,
};
const machineAudit = {
  version: 1,
  status: Object.values({
    paragraphTextMissing: computed.paragraphTextMissing.length,
    ownerTraceMismatch: computed.ownerTraceMismatch.length,
    causalClaimIds: computed.causalClaimIds.length,
    duplicateSemanticOwners: computed.duplicateSemanticOwners.length,
    prohibitedPhraseHits: computed.prohibitedPhraseHits.length,
    disclaimerKnown: computed.disclaimerKnown === 1 ? 0 : 1,
    disclaimerUnknown: computed.disclaimerUnknown === 1 ? 0 : 1,
    unknownPredictionClaims: computed.unknownPredictionClaims,
    summaryOmitted: computed.summaryOmitted ? 0 : 1,
  }).every((value) => value === 0) ? 'PASS_COMPUTABLE_GATES_ONLY' : 'FAIL',
  generatedAt: '2026-09-01T00:00:00+07:00',
  auditType: 'DETERMINISTIC_MACHINE_AUDIT',
  humanReview: 'PENDING',
  excludedFromMachineJudgment: ['naturalness', 'friendliness', 'content quality', 'Owner acceptance'],
  computed,
};
machineAudit.separationErrors = validateAuditSeparation(machineAudit);
writeJson('docs/DETERMINISTIC_MACHINE_CONTENT_AUDIT_OR4.json', machineAudit);
writeText('docs/DETERMINISTIC_MACHINE_CONTENT_AUDIT_OR4.md', `
# Deterministic Machine Content Audit — OR4

Status: **${machineAudit.status}**

This audit computes only traceable properties: paragraph membership, evidence-owner trace, causal flags, semantic-owner duplicates, prohibited phrases, disclaimer count, Unknown leakage and Summary omission. It does not score naturalness, friendliness or content quality. Human Review remains **PENDING**.

Computed errors: paragraph ${computed.paragraphTextMissing.length}; owner trace ${computed.ownerTraceMismatch.length}; causal ${computed.causalClaimIds.length}; duplicate owner ${computed.duplicateSemanticOwners.length}; prohibited phrase ${computed.prohibitedPhraseHits.length}; Unknown predictions ${computed.unknownPredictionClaims}; separation ${machineAudit.separationErrors.length}.
`);
console.log(JSON.stringify(machineAudit, null, 2));
