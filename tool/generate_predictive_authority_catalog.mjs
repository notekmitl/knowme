import { readFileSync, writeFileSync } from "node:fs";

const claimsPath =
  "knowledge/canon/proposed/mahabhut_2537_predictive_claims_v2.json";
const candidatePath =
  "knowledge/canon/proposed/mahabhut_2537_candidate_0011_reader_claims.json";
const claims = JSON.parse(readFileSync(claimsPath, "utf8"));
const candidate = JSON.parse(readFileSync(candidatePath, "utf8"));
const records = [];

for (const raw of claims.placementRecords) {
  records.push({
    id: raw.recordId,
    claimType: raw.recordType,
    contextId: raw.contextId,
    periodBinding: raw.agePeriodBinding,
    planet: raw.planet,
    taksaRole: raw.taksaRole,
    mahabhutHouse: raw.mahabhutHouse,
    periodStatus: raw.periodStatus,
    predictionClaimStatus: raw.predictionClaimStatus,
    sourceFile: claimsPath,
  });
}

for (const raw of claims.sourceGeneralRules) {
  records.push({
    id: raw.ruleId,
    claimType: "SOURCE_GENERAL_RULE",
    domain: raw.domain,
    movement: raw.movementOutcome,
    allowedConclusion: raw.allowedConclusion,
    prohibitedEscalation: raw.prohibitedEscalation ?? [],
    sourceFile: claimsPath,
  });
}

const claimRecord = (raw, evidenceRefs = raw.evidenceRefs ?? []) => ({
  id: raw.claimId,
  claimType: raw.claimType,
  contextId: raw.contextId,
  periodBinding: raw.agePeriodBinding,
  domain: raw.domain,
  subject: raw.subject,
  movement: raw.movementOutcome,
  allowedConclusion: raw.allowedConclusion,
  prohibitedEscalation: raw.prohibitedEscalation ?? [],
  conditionsSatisfied: raw.conditionsSatisfied ?? [],
  labelPolicy: raw.labelPolicy,
  evidenceRefs,
  sourceFile: claimsPath,
});

for (const raw of claims.sourceDirectClaims) records.push(claimRecord(raw));
for (const raw of claims.generalRuleApplications) {
  records.push(
    claimRecord(raw, [raw.placementRecordId, ...raw.sourceRuleRefs]),
  );
}
for (const raw of claims.productInterpretationClaims) {
  records.push(claimRecord(raw));
}

for (const surface of candidate.surfaces) {
  for (const [sourceOrder, raw] of surface.readerClaims.entries()) {
    const section = candidateSection(raw);
    records.push({
      id: raw.readerClaimId,
      claimType: raw.ownerType,
      contextId: raw.contextId,
      periodBinding: raw.periodBinding,
      domain: raw.domain,
      subject: raw.meaningKey ?? raw.ownerId,
      evidenceRefs: raw.evidenceRefs,
      readerText: raw.text,
      readerClaimId: raw.readerClaimId,
      semanticOwnerId: raw.ownerId,
      meaningKey: raw.meaningKey ?? raw.ownerId,
      readerRole: raw.claimKind,
      sectionTitle: raw.section,
      sectionId: section.id,
      sectionRole: section.role,
      sectionDisplayTitle: section.title,
      blockHeading: section.blockHeading,
      surface: surface.surface,
      templateId: "candidate-0011-exact",
      sourceOrder,
      ...(surface.surface === "Known"
        ? { acceptedCurrentAge: 44, acceptedAsOf: "2026-08-29" }
        : {}),
      sourceFile: candidatePath,
    });
  }
}

function candidateSection(raw) {
  if (raw.claimKind === "DISCLOSURE") {
    return { id: "disclaimer", role: "disclaimer", title: "" };
  }
  if (raw.claimKind === "OMISSION") {
    return { id: "report-short", role: "omission", title: "" };
  }
  if (raw.claimKind === "ADVICE") {
    return { id: "advice", role: "advice", title: "คำแนะนำสั้น ๆ" };
  }
  if (raw.section.startsWith("คำทำนายอดีต ")) {
    return {
      id: "past",
      role: "past",
      title: "คำทำนายอดีต",
      blockHeading: raw.section.replace("คำทำนายอดีต ", ""),
    };
  }
  if (raw.section.startsWith("คำทำนายปัจจุบัน ")) {
    return {
      id: "current",
      role: "current",
      title: raw.section.replace("คำทำนายปัจจุบัน ", "คำทำนายปัจจุบัน — "),
    };
  }
  if (raw.section.startsWith("ช่วงชีวิตถัดไป ")) {
    return {
      id: "next",
      role: "nextLifePeriod",
      title: raw.section.replace("ช่วงชีวิตถัดไป ", "ช่วงชีวิตถัดไป — "),
    };
  }
  const fixed = new Map([
    ["ภาพรวมเส้นทางชีวิต", ["overview", "overview"]],
    ["การงาน", ["work", "work"]],
    ["การเงิน", ["finance", "finance"]],
    ["ความรักและความสัมพันธ์", ["relationship", "relationship"]],
    ["สุขภาพ", ["health", "health"]],
    ["โชคลาภและแรงสนับสนุน", ["support", "support"]],
    ["คำทำนาย 12 เดือนข้างหน้า", ["horizon", "horizon"]],
  ]);
  const binding = fixed.get(raw.section);
  if (!binding) throw new Error(`Unsupported Candidate section: ${raw.section}`);
  return { id: binding[0], role: binding[1], title: raw.section };
}

records.push(
  {
    id: "ADVICE-K-CURRENT-01",
    claimType: "ADVICE",
    domain: "advice",
    sourceFile: candidatePath,
  },
  {
    id: "DISCLOSURE-K-01",
    claimType: "DISCLOSURE",
    domain: "disclosure",
    sourceFile: candidatePath,
  },
  {
    id: "DISCLOSURE-U-01",
    claimType: "DISCLOSURE",
    domain: "disclosure",
    sourceFile: candidatePath,
  },
  {
    id: "OMISSION-U-01",
    claimType: "OMISSION",
    domain: "omission",
    sourceFile: candidatePath,
  },
);

records.sort(
  (left, right) =>
    left.claimType.localeCompare(right.claimType) ||
    left.id.localeCompare(right.id),
);

const dartLiteral = (value) => {
  if (value === null || value === undefined) return "null";
  if (typeof value === "string") return JSON.stringify(value);
  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }
  if (Array.isArray(value)) {
    return `<Object?>[${value.map(dartLiteral).join(", ")}]`;
  }
  return `<String, Object?>{${Object.entries(value)
    .filter(([, item]) => item !== undefined)
    .map(([key, item]) => `${JSON.stringify(key)}: ${dartLiteral(item)}`)
    .join(", ")}}`;
};

const output = [
  "part of 'predictive_narrative_plan.dart';",
  "",
  "// GENERATED FILE. DO NOT EDIT BY HAND.",
  "// Source authority: claims_v2 + Candidate 0011 reader claims.",
  "const _generatedPredictiveAuthorityRecords = <Map<String, Object?>>[",
  ...records.map((record) => `  ${dartLiteral(record)},`),
  "];",
  "",
].join("\n");

writeFileSync(
  "lib/features/thai_beta/application/narrative/predictive_authority_catalog.g.dart",
  output,
  "utf8",
);
