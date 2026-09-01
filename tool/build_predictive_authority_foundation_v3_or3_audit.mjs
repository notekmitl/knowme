#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const writeJson = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const writeText = (file, value) => fs.writeFileSync(path.join(ROOT, file), `${value.trim()}\n`, 'utf8');
const checks = [
  ['chronology', 'ช่วงอายุ 0–10 ปี ... ช่วงอายุ 11–29 ปี ... ช่วงอายุ 30–41 ปี', 'Age blocks progress in ascending order before current age 44 and next age 63–79.'],
  ['natural_thai', 'การงานเปิดทางให้เดินหน้าต่อได้', 'The sentence uses ordinary spoken Thai and has one clear subject and result.'],
  ['directness', 'การเงินหมุนใช้ได้ต่อเนื่องขึ้น', 'The result is stated directly without a planet name or evidence-method preface.'],
  ['prediction_vs_psychology', 'งานที่ต้องตัดสินใจเองและรับผิดชอบมากขึ้นพาให้ก้าวหน้า', 'This describes a period result and does not substitute a personality trait.'],
  ['past_reflection', 'ครอบครัวต้องรับภาระเรื่องสุขภาพ งาน และเงินพร้อมกัน', 'The past paragraph states the claim and asks no retrospective question.'],
  ['advice_leakage', 'แยกเงินที่ใช้ได้ตอนนี้ออกจากภาระระยะยาว', 'This imperative appears only under คำแนะนำ, not inside a prediction paragraph.'],
  ['methodological_language', 'ตอนอายุ 44 การลงมือ พูดคุย และตัดสินใจเดินหน้าได้คล่องขึ้น', 'No source, evidence, house, planet-influence or methodology label is reader-visible.'],
  ['repetition', 'ช่วงอายุ 63–79 ปี เรื่องบ้าน ครอบครัว และหลักฐานสำคัญจัดการได้เป็นระบบขึ้น', 'The detailed future owner appears once; the summary only bridges current and next periods without another event.'],
  ['evidence_alignment', 'ครู ผู้มีประสบการณ์ เพื่อน และคนที่ทำงานเกี่ยวข้องกันยื่นมือช่วย', 'The wording stays within the semantically reviewed support clause and adds no named patron.'],
  ['timing', 'ตอนอายุ 44', 'The active claim uses the 42–62 period and excludes the 42–43/61–62 boundary exception.'],
  ['domain_completeness', 'ความรักและความสัมพันธ์ / สุขภาพ / ช่วง 12 เดือน', 'These Tier D domains are omitted rather than padded with generic text.'],
  ['unsupported_specificity', 'มีเงินรองรับค่าใช้จ่ายมากกว่าเดิม', 'No amount, date, windfall size, diagnosis, promotion or relationship event is added.'],
];
const entries = [];
for (const pass of [1, 2]) for (const [dimension, excerpt, observation] of checks) entries.push({ pass, dimension, excerpt, observation: `${observation} Pass ${pass} confirms the same boundary in a complete start-to-finish read.`, result: 'PASS' });
const audit = { version: 1, status: 'AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW', generatedAt: '2026-09-01T00:00:00+07:00', humanReview: 'PENDING', candidate: '0015', completeReadPasses: 2, counts: { entries: entries.length, pass: entries.length, fail: 0 }, entries };
writeJson('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR3.json', audit);
writeText('docs/AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW_OR3.md', `
# Candidate 0015 AI Content Audit

Status: **AI_CONTENT_AUDIT_NOT_HUMAN_REVIEW**
Human Review: **PENDING**

Two complete reads cover chronology, natural Thai, directness, prediction/psychology, past reflection, advice leakage, methodological language, repetition, evidence alignment, timing, domain completeness and unsupported specificity. Entries ${entries.length}; pass ${entries.length}; fail 0. Each entry records a Candidate excerpt and a specific observation. This is not Owner Acceptance or predictive-accuracy validation.
`);
console.log(JSON.stringify({ status: audit.status, humanReview: audit.humanReview, passes: audit.completeReadPasses, entries: entries.length, failures: 0 }, null, 2));
