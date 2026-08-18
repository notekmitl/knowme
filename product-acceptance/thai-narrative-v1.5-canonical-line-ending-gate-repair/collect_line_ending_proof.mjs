import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const evidenceDir = dirname(fileURLToPath(import.meta.url));
const repo = join(evidenceDir, '..', '..');
const probe = JSON.parse(
  readFileSync(join(evidenceDir, 'byte-level-root-cause-probe.json'), 'utf8'),
);

const sha256 = (bytes) =>
  createHash('sha256').update(bytes).digest('hex').toUpperCase();

function byteStats(bytes) {
  let crlf = 0;
  let standaloneCr = 0;
  let standaloneLf = 0;
  for (let index = 0; index < bytes.length; index += 1) {
    if (bytes[index] === 13) {
      if (bytes[index + 1] === 10) {
        crlf += 1;
        index += 1;
      } else {
        standaloneCr += 1;
      }
    } else if (bytes[index] === 10) {
      standaloneLf += 1;
    }
  }
  const text = bytes.toString('utf8');
  return {
    bytes: bytes.length,
    sha256: sha256(bytes),
    utf8CodePoints: [...text].length,
    crlf,
    standaloneCr,
    standaloneLf,
    trailingNewline: text.endsWith('\n') || text.endsWith('\r'),
    blankLines: text.replaceAll('\r\n', '\n').replaceAll('\r', '\n')
      .split('\n').slice(0, -1).filter((line) => line.length === 0).length,
  };
}

const comparisons = probe.comparisons.map((item) => {
  const absolutePath = join(repo, ...item.fixturePath.split('/'));
  const worktreeBytes = readFileSync(absolutePath);
  const blobBytes = execFileSync(
    'git',
    ['cat-file', 'blob', `HEAD:${item.fixturePath}`],
    { cwd: repo, encoding: 'buffer', maxBuffer: 1024 * 1024 },
  );
  const loaderText = worktreeBytes.toString('utf8');
  const normalizedText = loaderText
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n');
  const normalizedBytes = Buffer.from(normalizedText, 'utf8');
  return {
    case: `${item.fixture}/${item.format}`,
    fixturePath: item.fixturePath,
    gitBlob: byteStats(blobBytes),
    worktree: byteStats(worktreeBytes),
    fixtureLoader: {
      ...byteStats(Buffer.from(loaderText, 'utf8')),
      utf16CodeUnits: loaderText.length,
    },
    pipeline: {
      bytes: item.pipelineBytes,
      sha256: item.pipelineSha256.toUpperCase(),
      ...item.pipelineLineEndings,
      trailingNewline: item.pipelineTrailingNewline,
      blankLines: item.pipelineBlankLines,
    },
    firstRawDifference: item.rawFirstDifference,
    normalized: byteStats(normalizedBytes),
    normalizedExactToPipeline:
      sha256(normalizedBytes) === item.pipelineSha256.toUpperCase() &&
      normalizedBytes.length === item.pipelineBytes,
    gitBlobExactToPipeline:
      sha256(blobBytes) === item.pipelineSha256.toUpperCase() &&
      blobBytes.length === item.pipelineBytes,
    normalizedExactToGitBlob: normalizedBytes.equals(blobBytes),
  };
});

const fixturePaths = [...new Set(probe.comparisons.map((item) => item.fixturePath))];
const attrs = execFileSync(
  'git',
  ['check-attr', 'text', 'eol', 'working-tree-encoding', '--', ...fixturePaths],
  { cwd: repo, encoding: 'utf8' },
).trim().split(/\r?\n/);
const autocrlf = execFileSync(
  'git',
  ['config', '--show-origin', '--get-all', 'core.autocrlf'],
  { cwd: repo, encoding: 'utf8' },
).trim();

const result = {
  schema: 'knowme-v15-git-blob-worktree-loader-comparison-v1',
  head: execFileSync('git', ['rev-parse', 'HEAD'], { cwd: repo, encoding: 'utf8' }).trim(),
  gitConfig: { coreAutocrlf: autocrlf, coreEol: null, coreSafecrlf: null },
  gitAttributes: attrs,
  comparisonCount: comparisons.length,
  normalizedExactCount: comparisons.filter((item) => item.normalizedExactToPipeline).length,
  hiddenDifferenceCount: comparisons.filter(
    (item) => !item.normalizedExactToPipeline || !item.normalizedExactToGitBlob,
  ).length,
  comparisons,
};

writeFileSync(
  join(evidenceDir, 'git-blob-worktree-loader-comparison.json'),
  `${JSON.stringify(result, null, 2)}\n`,
  'utf8',
);
