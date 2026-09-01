#!/usr/bin/env node

import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
export const SOURCE_PATH = 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md';
export const ACCEPTED_HEAD = '2c82dc4b09fa9ded8b6527266801375179bb0ea6';
export const MERGE_SHA = '5dc59c44020a135934d1b8cefceae9606bfa736f';
export const ORACLE_PATH = 'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json';

const normalizeLf = (value) => value.replace(/\r\n?/g, '\n');
const sha256 = (value) => crypto.createHash('sha256').update(value, 'utf8').digest('hex').toUpperCase();

export function readerBlock(markdown) {
  const normalized = normalizeLf(markdown);
  const startMarker = 'Reader-facing candidate begins below.\n';
  const endMarker = '\nReader-facing candidate ends above.';
  const start = normalized.indexOf(startMarker);
  const end = normalized.indexOf(endMarker, start + startMarker.length);
  if (start < 0 || end < 0) throw new Error('Candidate 0011 reader-facing boundaries are missing');
  return normalized.slice(start + startMarker.length, end).trim();
}

export function parseClaims(markdown) {
  const block = readerBlock(markdown);
  const lines = block.split('\n');
  let section = null;
  const sectionOrder = [];
  const claims = [];
  for (let index = 0; index < lines.length; index += 1) {
    const heading = lines[index].match(/^(#{1,3})\s+(.+)$/u);
    if (heading) {
      section = heading[2].trim();
      if (!sectionOrder.includes(section)) sectionOrder.push(section);
      continue;
    }
    const marker = lines[index].match(/^<!-- readerClaimId: ([A-Z0-9-]+) -->$/u);
    if (!marker) continue;
    const body = [];
    for (let cursor = index + 1; cursor < lines.length; cursor += 1) {
      if (/^(?:#{1,3}\s|<!-- readerClaimId:)/u.test(lines[cursor])) break;
      if (lines[cursor].trim()) body.push(lines[cursor].trim());
    }
    if (body.length !== 1) throw new Error(`${marker[1]} must own exactly one complete paragraph; found ${body.length}`);
    const claimKind = marker[1].includes('-ADVICE-') ? 'ADVICE' : marker[1].includes('-DISCLOSURE-') ? 'DISCLOSURE' : 'PREDICTION';
    claims.push({
      readerClaimId: marker[1],
      surface: 'Known',
      section,
      claimKind,
      authorityClass: claimKind === 'ADVICE' ? 'ADVICE' : claimKind === 'DISCLOSURE' ? 'DISCLOSURE' : 'OWNER_ACCEPTED_PRODUCT_INTERPRETATION',
      exactText: body[0],
      acceptanceReference: claimKind === 'PREDICTION' ? {
        decision: 'Owner Final Content Review PASS',
        acceptedHead: ACCEPTED_HEAD,
        mergeSha: MERGE_SHA,
        scope: 'copy_and_product_interpretation_authority_only',
        doesNotEstablish: ['source_quotation', 'real_world_accuracy'],
      } : null,
    });
  }
  return { block, sectionOrder, claims };
}

export function buildOracle() {
  const acceptedMarkdown = normalizeLf(execFileSync('git', ['show', `${ACCEPTED_HEAD}:${SOURCE_PATH}`], { cwd: ROOT, encoding: 'utf8' }));
  const currentMarkdown = normalizeLf(fs.readFileSync(path.join(ROOT, SOURCE_PATH), 'utf8'));
  const accepted = parseClaims(acceptedMarkdown);
  const current = parseClaims(currentMarkdown);
  if (accepted.block !== current.block) throw new Error('Current Candidate 0011 reader-facing block differs from accepted HEAD');
  if (JSON.stringify(accepted.claims.map((claim) => claim.exactText)) !== JSON.stringify(current.claims.map((claim) => claim.exactText))) throw new Error('Current Candidate 0011 claims differ from accepted HEAD');
  const predictionCount = accepted.claims.filter((claim) => claim.claimKind === 'PREDICTION').length;
  const adviceCount = accepted.claims.filter((claim) => claim.claimKind === 'ADVICE').length;
  const disclosureCount = accepted.claims.filter((claim) => claim.claimKind === 'DISCLOSURE').length;
  return {
    version: 1,
    status: 'OWNER_ACCEPTED_IMMUTABLE_GOLDEN_ORACLE_NOT_RUNTIME',
    candidateId: '0011',
    source: {
      repositoryPath: SOURCE_PATH,
      acceptedHead: ACCEPTED_HEAD,
      mergeSha: MERGE_SHA,
      acceptedReaderFacingSha256: sha256(accepted.block),
      currentReaderFacingSha256: sha256(current.block),
      hashCanonicalization: 'UTF-8; CRLF normalized to LF; exact bytes between reader-facing boundary markers; outer whitespace trimmed; HTML readerClaimId comments retained',
    },
    acceptanceBoundary: {
      establishes: ['exact_reader_copy', 'section_order', 'claim_order', 'product_interpretation_authority'],
      doesNotEstablish: ['verbatim_source_quotation', 'predictive_accuracy', 'real_world_outcome'],
    },
    counts: {
      claims: accepted.claims.length,
      predictionParagraphs: predictionCount,
      advice: adviceCount,
      disclosure: disclosureCount,
      adviceAndDisclosure: adviceCount + disclosureCount,
    },
    sectionOrder: accepted.sectionOrder,
    claimOrder: accepted.claims.map((claim) => claim.readerClaimId),
    claims: accepted.claims,
  };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  fs.writeFileSync(path.join(ROOT, ORACLE_PATH), `${JSON.stringify(buildOracle(), null, 2)}\n`, 'utf8');
  process.stdout.write(`${ORACLE_PATH}\n`);
}
