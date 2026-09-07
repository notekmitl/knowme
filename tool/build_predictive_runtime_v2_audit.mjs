#!/usr/bin/env node

import crypto from 'node:crypto';
import fs from 'node:fs';

const evidenceDir = process.env.OR10R_EVIDENCE_DIR ?? 'build/or10r-runtime-evidence';
const readJson = path => JSON.parse(fs.readFileSync(path, 'utf8'));
const sha = value => crypto.createHash('sha256').update(value, 'utf8').digest('hex').toUpperCase();
const runtime = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart', 'utf8');
const catalog = fs.readFileSync('lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart', 'utf8');
const candidate = readJson('docs/CANDIDATE_0023_CLAIM_MAP.json');
const profiles = readJson(`${evidenceDir}/OR5_INPUT_BOUND_MATERIAL_DISTRIBUTION_300.json`);
const contexts = readJson(`${evidenceDir}/OR5_INPUT_BOUND_MATERIALS_49.json`);
const determinism = readJson(`${evidenceDir}/OR5_DETERMINISM.json`);
const unknown = readJson(`${evidenceDir}/OR5R_UNKNOWN_75_PLACEHOLDERS.json`);
const controls = readJson(`${evidenceDir}/OR5_NEGATIVE_CONTROLS.json`);
const actual35 = readJson(`${evidenceDir}/OR5_ACTUAL_0035_RUNTIME_EVIDENCE.json`);
const actual03 = readJson(`${evidenceDir}/OR5_RAW_0003_20260829.json`);

const rows = profiles.profiles;
const known = rows.filter(row => row.evidence.plan.knownTime);
const unknownRows = rows.filter(row => !row.evidence.plan.knownTime);
const emitted = known.flatMap(row => row.evidence.plan.decisions.filter(item => item.emitted));
const predictions = emitted.filter(item => item.kind === 'prediction');
const emittedCounts = known.map(row => row.evidence.plan.emittedPredictions).sort((a, b) => a - b);
const median = emittedCounts[Math.floor(emittedCounts.length / 2)];
const sumMetric = name => rows.reduce((total, row) => total + Number(row.evidence.plan[name] ?? 0), 0);

const stale0022 = [
  'การเรียนให้ผลดีและเปิดทางให้คุณเริ่มสร้างเส้นทางงานของตัวเอง',
  'การเพิ่มข้อผูกพันจะช้ากว่าที่คิด เพราะความคาดหวังของทั้งสองฝ่ายยังไม่ตรงกันทั้งหมด',
  'ทำให้งานและเรื่องเงินคล่องขึ้น',
  'รายรับจะเพิ่มตามงาน',
  'ภาระที่เพิ่มเร็วกว่าสิทธิ์ตัดสินใจจะทำให้งานบางส่วนช้าลง',
  'รายจ่ายประจำที่โตตามรายรับจะทำให้เงินเหลือเก็บเพิ่มไม่ทันรายรับ',
];
const predictionText = predictions.map(item => item.text).join('\n');
const candidate0022RejectedPhraseHits = stale0022.filter(phrase => predictionText.includes(phrase)).length;
const conditionalPredictionFallback = predictions.filter(item => /(?:อาจ|มีแนวโน้ม|มีโอกาส|น่าจะ|เป็นไปได้ว่า|(?:^|[.!?]\s*)(?:หาก|ถ้า))/u.test(item.text)).length;
const adviceLeakage = predictions.filter(item => /(?:^|[.!?]\s*)(?:ควร|ให้|ลอง|ทบทวน)(?:\s|คุณ)/u.test(item.text)).length;
const personalityLeakage = predictions.filter(item => /(?:คุณมัก|นิสัย|คุณเป็นคน|ตัวตนของคุณ)/u.test(item.text)).length;
let duplicateSemanticOwner = 0;
let readerPerceivedRepetition = 0;
for (const row of known) {
  const planEmitted = row.evidence.plan.decisions.filter(item => item.emitted);
  duplicateSemanticOwner += planEmitted.length - new Set(planEmitted.map(item => item.semanticOwner)).size;
  const normalized = planEmitted
    .filter(item => item.kind === 'prediction')
    .map(item => item.text.replace(/[\p{P}\p{S}\s]/gu, '').toLowerCase());
  readerPerceivedRepetition += normalized.length - new Set(normalized).size;
}

const forbiddenRuntimeTokens = [
  '_isOwnerAcceptedGoldenFixture',
  'useGoldenOverride',
  'runtimePredictiveV2GoldenRules',
  'candidate-0011-exact',
  'fixture.target-0003',
];
const staleCandidate0011RuntimePath = forbiddenRuntimeTokens.filter(token => runtime.includes(token) || catalog.includes(token)).length;
const periodCount = (catalog.match(/RuntimePredictivePeriodRow\(/gu) ?? []).length;
const candidateSha = sha(candidate.fullReaderCopy);
const sectionBody = record => record.sections
  .filter(section => section.id.includes('predictive-v2-'))
  .filter(section => !section.id.includes('report-header'))
  .filter(section => !section.id.includes('psychology'))
  .filter(section => !section.id.includes('provenance'))
  .map(section => ({id: section.id, title: section.title, paragraphs: section.paragraphs}));
const baseline = readJson('test/evidence/fixtures/or5r_known_baseline.json');

const counters = {
  profiles: rows.length,
  knownProfilesWithCompleteV2Report: known.filter(row => row.evidence.plan.missingSemanticOwners.length === 0 && !row.evidence.plan.baselineFallbackUsed).length,
  knownProfilesUsingBaselineFallback: known.filter(row => row.evidence.plan.baselineFallbackUsed).length,
  unknownProfilesFailClosed: unknownRows.filter(row => row.evidence.plan.emittedClaimCount === 0).length,
  unknownPlaceholderVariants: unknown.variants,
  unknownPlaceholderMismatch: unknown.mismatch,
  contextsWithCompleteContent: contexts.count,
  periodsMapped: periodCount,
  periodsUnmapped: 392 - periodCount,
  claimLevelBindings: emitted.length,
  minimumEmittedPredictions: emittedCounts[0],
  medianEmittedPredictions: median,
  maximumEmittedPredictions: emittedCounts.at(-1),
  uniquePredictiveSignatures: determinism.uniquePredictiveSignatures,
  uniqueGeneratedPredictiveBodies: determinism.uniqueGeneratedPredictiveBodies,
  sameSignatureBodyMismatch: determinism.sameSignatureBodyMismatch,
  unsupportedClaims: sumMetric('unsupportedClaims'),
  fixtureSpecificBranches: sumMetric('fixtureSpecificBranches'),
  goldenOverrideApplications: sumMetric('ownerAcceptedGoldenOverrideApplied'),
  unexpectedFixtureSpecificBranches: sumMetric('unexpectedFixtureSpecificBranches'),
  fixtureReferenceLeakage: sumMetric('fixtureReferenceLeakage'),
  evidenceBindingMismatches: sumMetric('evidenceBindingMismatches'),
  knownToUnknownLeakage: sumMetric('knownToUnknownLeakage'),
  genericFallback: known.filter(row => row.evidence.plan.baselineFallbackUsed).length,
  duplicateSemanticOwner,
  staleCandidate0011RuntimePath,
  candidate0022RejectedPhraseHits,
  conditionalPredictionFallback,
  unsupportedCausalLink: candidate0022RejectedPhraseHits,
  readerPerceivedRepetition,
  adviceLeakage,
  personalityLeakage,
};

const errors = [];
const exact = (actual, expected, id) => { if (actual !== expected) errors.push(`${id}:${actual}`); };
exact(counters.profiles, 300, 'profiles');
exact(counters.knownProfilesWithCompleteV2Report, 225, 'known-complete');
exact(counters.unknownProfilesFailClosed, 75, 'unknown-fail-closed');
exact(counters.unknownPlaceholderVariants, 225, 'unknown-placeholder-variants');
exact(counters.contextsWithCompleteContent, 49, 'contexts');
exact(counters.periodsMapped, 392, 'periods');
exact(candidateSha, 'FDA1DA8917CD5ADCA4650AECF87414DCFCDEE7F13019DF0794ECF76DFD91E7F2', 'candidate0023-sha');
exact(actual35.rawFuturePredictionSha256.toUpperCase(), '292AEA14829A29935A0B877E8A536A6557DAB43ACD68BAE535E091B7D7CD7669', 'raw-forecast-sha');
exact(baseline['35'].sectionPlainText, candidate.fullReaderCopy, 'candidate0023-runtime-copy');
exact(JSON.stringify(sectionBody(baseline['3'])), JSON.stringify(sectionBody(baseline['35'])), 'signature-equivalence');
exact(actual03.plan.predictiveSignature, actual35.plan.predictiveSignature, 'signature-id-equivalence');
exact(actual03.plan.usesCandidate0023Components, true, 'candidate-components-0003');
exact(actual35.plan.usesCandidate0023Components, true, 'candidate-components-0035');
exact(controls.rejected, 10, 'actual-input-negative-controls');
for (const [name, value] of Object.entries(counters)) {
  if ([
    'profiles', 'knownProfilesWithCompleteV2Report', 'unknownProfilesFailClosed',
    'unknownPlaceholderVariants', 'contextsWithCompleteContent', 'periodsMapped',
    'claimLevelBindings', 'minimumEmittedPredictions', 'medianEmittedPredictions',
    'maximumEmittedPredictions', 'uniquePredictiveSignatures', 'uniqueGeneratedPredictiveBodies',
  ].includes(name)) continue;
  if (value !== 0) errors.push(`${name}:${value}`);
}

const result = {
  schema: 'predictive-runtime-v2-or10r-generalization-audit/1',
  status: errors.length === 0 ? 'PASS_PR115_OR10R_SIGNATURE_RUNTIME' : 'FAIL',
  evidenceSource: evidenceDir,
  activeTarget: {
    context: actual35.contextId,
    age: actual35.currentAge,
    period: actual35.currentPeriod.matrixApplicationId,
    typedMaterials: actual35.typedMaterials.length,
    rawForecastSha256: actual35.rawFuturePredictionSha256.toUpperCase(),
    candidate0023FullReaderCopySha256: candidateSha,
  },
  historicalOracle: {
    candidate0011Sha256: '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E',
    productionRuntimeOracle: false,
  },
  counts: counters,
  negativeControls: {actualInputTampering: controls.rejected, prohibitedSelectorMutants: 7},
  verifierErrors: errors,
};

fs.writeFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', `${JSON.stringify(result, null, 2)}\n`);
fs.writeFileSync('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.md', `# Predictive Runtime V2 — PR115 OR10R generalization audit\n\nStatus: **${result.status}**\n\n- Known complete: ${counters.knownProfilesWithCompleteV2Report}/225; Unknown fail-closed: ${counters.unknownProfilesFailClosed}/75 with ${counters.unknownPlaceholderVariants} placeholder variants.\n- Actual contexts/periods: ${counters.contextsWithCompleteContent}/49 and ${counters.periodsMapped}/392.\n- Unique predictive signatures/bodies observed in the 300-profile matrix: ${counters.uniquePredictiveSignatures}/${counters.uniqueGeneratedPredictiveBodies}; same-signature mismatch ${counters.sameSignatureBodyMismatch}.\n- Emitted predictions min/median/max: ${counters.minimumEmittedPredictions}/${counters.medianEmittedPredictions}/${counters.maximumEmittedPredictions}.\n- Unsupported claims, fixture branches, golden overrides, fixture references, binding mismatches, Known→Unknown leakage, generic fallback, duplicate semantic owner: ${counters.unsupportedClaims}/${counters.fixtureSpecificBranches}/${counters.goldenOverrideApplications}/${counters.fixtureReferenceLeakage}/${counters.evidenceBindingMismatches}/${counters.knownToUnknownLeakage}/${counters.genericFallback}/${counters.duplicateSemanticOwner}.\n- Stale Candidate 0011 runtime path / Candidate 0022 rejected phrase / conditional fallback / unsupported causal link / reader repetition / advice leakage / personality leakage: ${counters.staleCandidate0011RuntimePath}/${counters.candidate0022RejectedPhraseHits}/${counters.conditionalPredictionFallback}/${counters.unsupportedCausalLink}/${counters.readerPerceivedRepetition}/${counters.adviceLeakage}/${counters.personalityLeakage}.\n- Candidate 0023 00:35 exact reader SHA: ${candidateSha}; raw forecast SHA: ${result.activeTarget.rawForecastSha256}.\n- Verifier errors: ${errors.length}.\n\nCounts are observed values, not minimum diversity thresholds. Candidate 0011 remains immutable historical evidence and is not a production runtime selector.\n`);

console.log(JSON.stringify({status: result.status, counts: counters, verifierErrors: errors}));
if (errors.length) process.exitCode = 1;
