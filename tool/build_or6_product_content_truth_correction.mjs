#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const load = (file) => JSON.parse(fs.readFileSync(path.join(ROOT, file), 'utf8'));
const oracle = load('docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json');
const candidate18 = load('docs/CANDIDATE_0018_RESOLVED_RULE_CHAIN_MAP.json').known.claims;
const c18 = new Map(candidate18.map((claim) => [claim.claimId, claim.fullReaderText]));

const delta = {
  'RC11-K-OVERVIEW-01': { to: [], classes: ['REMOVED'] },
  'RC11-K-PAST-01': { to: ['RC18-K-PAST-0-10'], classes: ['WEAKENED', 'CHANGED_TIMING'] },
  'RC11-K-PAST-02': { to: ['RC18-K-PAST-11-29'], classes: ['WEAKENED'] },
  'RC11-K-PAST-03': { to: [], classes: ['REMOVED'] },
  'RC11-K-PAST-04': { to: ['RC18-K-PAST-30-41'], classes: ['WEAKENED'] },
  'RC11-K-PAST-05': { to: [], classes: ['REMOVED'] },
  'RC11-K-CURRENT-01': { to: ['RC18-K-CURRENT'], classes: ['WEAKENED'] },
  'RC11-K-WORK-01': { to: ['RC18-K-WORK-CURRENT-NEXT12'], classes: ['WEAKENED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-WORK-02': { to: ['RC18-K-WORK-CURRENT-NEXT12'], classes: ['WEAKENED', 'GENERALIZED_COMMON_SENSE', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-FINANCE-01': { to: ['RC18-K-FINANCE-CURRENT-NEXT12'], classes: ['WEAKENED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-FINANCE-02': { to: ['RC18-K-FINANCE-CURRENT-NEXT12'], classes: ['WEAKENED', 'GENERALIZED_COMMON_SENSE', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-RELATIONSHIP-01': { to: ['RC18-K-RELATIONSHIP-CURRENT-NEXT12'], classes: ['WEAKENED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-RELATIONSHIP-02': { to: ['RC18-K-RELATIONSHIP-CURRENT-NEXT12'], classes: ['WEAKENED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-HEALTH-01': { to: ['RC18-K-HEALTH-CURRENT-NEXT12'], classes: ['WEAKENED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-HEALTH-02': { to: ['RC18-K-HEALTH-CURRENT-NEXT12'], classes: ['REMOVED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-SUPPORT-01': { to: ['RC18-K-SUPPORT'], classes: ['UNCHANGED_MEANING'] },
  'RC11-K-SUPPORT-02': { to: ['RC18-K-SUPPORT'], classes: ['WEAKENED'] },
  'RC11-K-HORIZON-01': { to: ['RC18-K-WORK-CURRENT-NEXT12'], classes: ['WEAKENED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-HORIZON-02': { to: ['RC18-K-FINANCE-CURRENT-NEXT12', 'RC18-K-RELATIONSHIP-CURRENT-NEXT12'], classes: ['WEAKENED', 'PREDICTION_TO_MEASUREMENT_OR_ADVICE'] },
  'RC11-K-HORIZON-03': { to: ['RC18-K-SUPPORT'], classes: ['WEAKENED', 'CHANGED_TIMING'] },
  'RC11-K-NEXT-01': { to: ['RC18-K-NEXT-FINANCE'], classes: ['WEAKENED', 'GENERALIZED_COMMON_SENSE'] },
  'RC11-K-NEXT-02': { to: ['RC18-K-NEXT-CAREER'], classes: ['WEAKENED'] },
};

const predictions = oracle.claims.filter((claim) => claim.claimKind === 'PREDICTION');
const sections = predictions.map((claim) => {
  const record = delta[claim.readerClaimId];
  const after = record.to.length === 0
    ? '**Candidate 0018:** ไม่มี paragraph ที่คงข้อความหรือความหมายนี้ไว้'
    : record.to.map((id) => `**Candidate 0018 — \`${id}\`:** ${c18.get(id)}`).join('\n\n');
  return `## ${claim.readerClaimId}\n\n- Section: ${claim.section}\n- Classification: ${record.classes.map((value) => `\`${value}\``).join(', ')}\n\n**Candidate 0011 — exact Owner-accepted text:** ${claim.exactText}\n\n${after}\n\n**Correction:** OR6 ต้องไม่ใช้การผ่านโครงสร้าง chain หรือการลดความซ้ำเป็นเหตุลบรายละเอียดที่ Owner รับแล้ว ข้อความ Candidate 0011 ด้านบนจึงคงเดิมเป็น oracle; Candidate 0018 เป็นเพียงหลักฐานว่าตัว resolver ทำงานและไม่ใช่ runtime target.\n`;
}).join('\n');

const content = `# OR6 Product Content Truth Correction\n\nStatus: **CANDIDATE 0018 OWNER-REJECTED — CANDIDATE 0011 RESTORED AS IMMUTABLE GOLDEN ORACLE**\n\nOR6 resolver passed its technical evidence-binding, typed-material, negative-control and structural checks. That is retained progress. Owner rejected Candidate 0018 for implementation because it reduced the 22 Owner-accepted Candidate 0011 prediction paragraphs to 13 prediction paragraphs, weakened or removed accepted detail, generalized some content into common-sense measurement, and moved predictive meaning toward advice. No Candidate 0019 is created.\n\nDedupe is a presentation constraint, not authority to delete accepted content. A structural/evidence PASS is not a Product Content PASS. Candidate 0017 and Candidate 0018 remain historical evidence only and are not runtime oracles. The sole oracle is \`docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md\`, bound to accepted Phase 1 HEAD \`2c82dc4b09fa9ded8b6527266801375179bb0ea6\` and PR112 merge \`5dc59c44020a135934d1b8cefceae9606bfa736f\`. Owner acceptance establishes exact copy and product-interpretation authority; it does not establish verbatim source quotation, real-world accuracy or guaranteed outcomes.\n\n## Delta summary\n\n- Candidate 0011 prediction paragraphs: 22\n- Candidate 0018 prediction paragraphs: 13\n- Candidate 0011 exact paragraphs retained as oracle: 22\n- Candidate 0011 paragraphs rewritten or deleted in OR7: 0\n- Candidate 0019: not created\n\nThe classifications below are exhaustive across all 22 accepted prediction paragraphs: \`UNCHANGED_MEANING\`, \`WEAKENED\`, \`GENERALIZED_COMMON_SENSE\`, \`REMOVED\`, \`PREDICTION_TO_MEASUREMENT_OR_ADVICE\`, \`CHANGED_TIMING\`, and \`ADDED\`. No \`ADDED\` Candidate 0018 paragraph expands Candidate 0011; the Candidate 0018 output is a 13-paragraph reduction. Multiple labels apply where a merged Candidate 0018 paragraph changed more than one property.\n\n${sections}`;

fs.writeFileSync(path.join(ROOT, 'docs/OR6_PRODUCT_CONTENT_TRUTH_CORRECTION.md'), `${content.replace(/\n+$/u, '')}\n`, 'utf8');
process.stdout.write(`claims=${predictions.length}\n`);
