import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';

const check = process.argv.includes('--check');
const readJson = (path) => JSON.parse(readFileSync(path, 'utf8'));
const sha256 = (value) => createHash('sha256').update(value).digest('hex').toUpperCase();
const copy = readJson('docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json');
const reuse = readJson('docs/PREDICTIVE_RUNTIME_V2_OWNER_REUSE_AUDIT.json');
const quality = readJson('docs/PREDICTIVE_RUNTIME_V2_CONTENT_QUALITY_AUDIT.json');
const contexts = Object.entries(copy.contexts);
const claims = (context, owner) => context.claims
  .filter((claim) => claim.emitted && claim.semanticOwner === owner)
  .map((claim) => claim.text);
const riskClause = (text) => text.match(/(?:ในช่วงเดียวกัน)\s+(.+)$/u)?.[1]?.trim() ?? null;

let pastFutureTenseMismatchContexts = 0;
let unresolvedWorkDirectionConflictContexts = 0;
let currentDomainTo12MonthClauseDuplicate = 0;
let currentDomainToNextClauseDuplicate = 0;
let healthAndRestPhraseOccurrences = 0;
const duplicateLedger = [];

for (const [contextId, context] of contexts) {
  if (claims(context, 'past').some((text) => text.includes('จะ'))) {
    pastFutureTenseMismatchContexts += 1;
  }
  if (claims(context, 'work').some((text) => text.includes('จะเดินหน้า') && text.includes('เดินช้าลง'))) {
    unresolvedWorkDirectionConflictContexts += 1;
  }
  const rolling12 = claims(context, 'rolling12').join(' ');
  const next = claims(context, 'next').join(' ');
  for (const owner of ['work', 'finance', 'relationship', 'health']) {
    for (const text of claims(context, owner)) {
      const clause = riskClause(text);
      if (!clause) continue;
      if (rolling12.includes(clause)) {
        currentDomainTo12MonthClauseDuplicate += 1;
        duplicateLedger.push({ contextId, sourceOwner: owner, targetOwner: 'rolling12', clause });
      }
      if (next.includes(clause)) {
        currentDomainToNextClauseDuplicate += 1;
        duplicateLedger.push({ contextId, sourceOwner: owner, targetOwner: 'next', clause });
      }
    }
  }
  healthAndRestPhraseOccurrences += (context.readerLines.join('\n').match(/ด้านสุขภาพและการพัก/gu) ?? []).length;
}

const ownerReuse = Object.fromEntries(['work', 'finance', 'relationship', 'health'].map((owner) => [owner, {
  distinctParagraphs: reuse.owners[owner].distinctParagraphCount,
  mostReusedParagraph: reuse.owners[owner].mostReusedParagraph,
  mostReusedCount: reuse.owners[owner].reuseCount,
}]));

const truth = {
  version: 1,
  status: 'ENGINEERING_COVERAGE_PASS_PRODUCT_CONTENT_FAIL',
  ownerAcceptance: 'NOT_GRANTED',
  ownerHumanReview: 'PENDING',
  productContentStatus: 'NO_GO',
  sourceFiles: {
    readerCopy: 'docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json',
    ownerReuse: 'docs/PREDICTIVE_RUNTIME_V2_OWNER_REUSE_AUDIT.json',
    previousMachineAudit: 'docs/PREDICTIVE_RUNTIME_V2_CONTENT_QUALITY_AUDIT.json',
  },
  counts: {
    contexts: contexts.length,
    pastFutureTenseMismatchContexts,
    unresolvedWorkDirectionConflictContexts,
    currentDomainTo12MonthClauseDuplicate,
    currentDomainToNextClauseDuplicate,
    healthAndRestPhraseOccurrences,
  },
  ownerReportedComparison: {
    pastFutureTenseMismatchContexts: { ownerReported: 39, actual: pastFutureTenseMismatchContexts },
    unresolvedWorkDirectionConflictContexts: { ownerReported: 43, actual: unresolvedWorkDirectionConflictContexts },
    currentDomainTo12MonthClauseDuplicate: { ownerReported: 98, actual: currentDomainTo12MonthClauseDuplicate },
    currentDomainToNextClauseDuplicate: { ownerReported: 33, actual: currentDomainToNextClauseDuplicate },
    healthAndRestPhraseOccurrences: {
      ownerReported: 46,
      actual: healthAndRestPhraseOccurrences,
      reason: 'Raw reader-claim scan finds 34 health-owner and 13 rolling-12 occurrences.',
    },
  },
  ownerReuse,
  duplicateLedger,
  previousAuditTruthCorrection: {
    generatedFromMachineCounters: true,
    provesHumanReading: false,
    historicalStatus: quality.summary?.historicalStatus ?? quality.summary?.status ?? null,
    correctedClassification: 'MACHINE_CONTENT_AUDIT',
    correctedResult: 'NO_GO',
  },
};

const jsonText = `${JSON.stringify(truth, null, 2)}\n`;
const mdText = `# PR115 OR2 Truth Correction\n\nStatus: **ENGINEERING COVERAGE PASS — PRODUCT CONTENT FAIL — OWNER ACCEPTANCE NOT GRANTED**\n\nThe OR2 files proved selector, period, profile, export and metadata coverage. They did not prove that a person completed two editorial-reading passes, nor that the generated prose met the Product Content contract. The historical file name \`PREDICTIVE_RUNTIME_V2_HUMAN_REVIEW_49_CONTEXTS.md\` is retained for audit continuity, but its content is reclassified as **MACHINE_CONTENT_AUDIT**. \`ownerHumanReview=PENDING\` and \`productContentStatus=NO_GO\`.\n\n## Recomputed from the committed OR2 evidence\n\n- Past claims using future-tense \`จะ\` after the period ended: **${pastFutureTenseMismatchContexts}/${contexts.length} contexts**.\n- Work paragraphs containing both \`จะเดินหน้า\` and \`เดินช้าลง\`: **${unresolvedWorkDirectionConflictContexts}/${contexts.length} contexts**.\n- Current-domain risk clauses copied into rolling 12 months: **${currentDomainTo12MonthClauseDuplicate}**.\n- Current-domain risk clauses copied into next-life-period: **${currentDomainToNextClauseDuplicate}**.\n- \`ด้านสุขภาพและการพัก\`: **${healthAndRestPhraseOccurrences} actual occurrences**. Owner reported 46; the raw claim scan finds 34 in health-owner claims and 13 in rolling-12 claims, so the evidence record uses 47.\n- Work: **${ownerReuse.work.distinctParagraphs} distinct**, most reused **${ownerReuse.work.mostReusedCount} contexts**.\n- Finance: **${ownerReuse.finance.distinctParagraphs} distinct**, most reused **${ownerReuse.finance.mostReusedCount} contexts**.\n- Relationship: **${ownerReuse.relationship.distinctParagraphs} distinct**, most reused **${ownerReuse.relationship.mostReusedCount} contexts**.\n- Health: **${ownerReuse.health.distinctParagraphs} distinct**, most reused **${ownerReuse.health.mostReusedCount} contexts**.\n\nClause duplication is measured by extracting the Current domain risk clause after \`ในช่วงเดียวกัน\` and checking whether that exact clause is present in the rolling-12 or next-life-period owner, including when the target appends another sentence fragment.\n\nOR3 does not modify Production runtime. Candidate 0011 remains a regression oracle, while the current exact-fixture runtime override remains a release blocker.\n`;

const jsonPath = 'docs/PREDICTIVE_RUNTIME_V2_OR2_TRUTH_CORRECTION.json';
const mdPath = 'docs/PREDICTIVE_RUNTIME_V2_OR2_TRUTH_CORRECTION.md';
const correctedAudit = (source) => {
  const historicalStatus = source.summary.historicalStatus ?? source.summary.status;
  const historicalMachineGeneratedFields = source.summary.historicalMachineGeneratedFields ?? {
    humanReviewContexts: source.summary.humanReviewContexts ?? 49,
    humanReviewFailures: source.summary.humanReviewFailures ?? 0,
  };
  const summary = {
    ...source.summary,
    status: 'MACHINE_CONTENT_AUDIT_NO_GO',
    historicalStatus,
    auditClassification: 'MACHINE_CONTENT_AUDIT',
    ownerHumanReview: 'PENDING',
    productContentStatus: 'NO_GO',
    ownerAcceptance: 'NOT_GRANTED',
    machineContentAuditContexts: 49,
    historicalMachineGeneratedFields,
  };
  delete summary.humanReviewContexts;
  delete summary.humanReviewFailures;
  return { ...source, summary };
};
const readerCopyPath = 'docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json';
const qualityPath = 'docs/PREDICTIVE_RUNTIME_V2_CONTENT_QUALITY_AUDIT.json';
const expectedReaderCopy = `${JSON.stringify(correctedAudit(copy), null, 2)}\n`;
const expectedQuality = `${JSON.stringify(correctedAudit(quality), null, 2)}\n`;
if (check) {
  if (readFileSync(jsonPath, 'utf8') !== jsonText || readFileSync(mdPath, 'utf8') !== mdText
      || readFileSync(readerCopyPath, 'utf8') !== expectedReaderCopy
      || readFileSync(qualityPath, 'utf8') !== expectedQuality) {
    throw new Error('OR2 truth-correction outputs are stale');
  }
} else {
  writeFileSync(jsonPath, jsonText);
  writeFileSync(mdPath, mdText);
  writeFileSync(readerCopyPath, expectedReaderCopy);
  writeFileSync(qualityPath, expectedQuality);
}
console.log(JSON.stringify({
  status: truth.status,
  counts: truth.counts,
  truthSha256: sha256(jsonText),
}));
