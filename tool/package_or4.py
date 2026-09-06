"""Build a new OR4 evidence ZIP and independently verify its extracted bytes."""
import argparse
import hashlib
import json
import re
import shutil
import subprocess
import zipfile
from pathlib import Path, PurePosixPath

parser = argparse.ArgumentParser()
parser.add_argument('--destination', required=True)
args = parser.parse_args()
repo = Path.cwd().resolve()
head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
base = '8587c74d7202a809458459a29c508be1181d2fe5'
parent = Path(args.destination).resolve()
name = 'OWNER_REVIEW_THAI_PREDICTIVE_NARRATIVE_V2_RUNTIME_V2_OR4_SINGLE_PATH_' + head[:7]
stage, archive, extracted = parent / name, parent / (name + '.zip'), parent / (name + '_EXTRACTED')
assert not stage.exists() and not archive.exists() and not extracted.exists(), 'Never overwrite review evidence'
paths = subprocess.check_output(['git', 'diff', '--name-only', base, head], text=True).splitlines()
paths = [p for p in paths if p.startswith(('docs/OR4_', 'docs/CANDIDATE_0020_', 'tool/or4_', 'tool/build_or4_', 'test/evidence/or4_'))]
stage.mkdir()
for rel in paths:
    dest = stage / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(repo / rel, dest)
guide = f'''# PR115 OR4 Owner Review — CONTENT FOUNDATION NO-GO

Content/evidence commit: {head}

Start with docs/OR4_SEMANTIC_FEASIBILITY.md and docs/CANDIDATE_0020_ACTUAL_0035.md.
OR3 history and its ZIP have not been edited. Truth correction reproduces all Owner counts.
The new renderer uses one pure function and dynamic age binding for all 49 contexts and Actual 00:35.
Candidate 0020 is incomplete: prediction paragraphs 0/22, full predictive contexts 0/49.
It contains exact period facts and records omitted content. It is not a replacement accepted report.
Proposed domain templates are UNVERIFIED and not emitted. Zero domain error counters have zero emitted prediction coverage.

Evidence blockers:
- The existing 00:35 export has context/period/text, but not typed signatures or claim bindings.
- The stored typed resolution is 00:03 at 2026-08-07, not 00:35 at 2026-08-29.
- The rem0 Saturday representative in the 49-context set is age 30, not the target age 44.
- A serialized forecast key is not proof of a complete Canon-domain/direction/timing/conflict/certainty interpretation.

Validation: 48/48 Node tests (including historical OR3 regression tests); actual OR4 negative controls 27/27 rejected.
Historical test names asserting OR3 semantic success remain historical and are superseded by OR4 truth correction.
Candidate0020 determinism: two generation passes equal. Immutable Candidate0011 reader SHA unchanged.
All 8 age counters are zero with individual inspected rows. All 5 domain counters are zero with omissions disclosed.
Full Flutter/analyzer not rerun: Dart/application/Flutter-test delta is zero.
PreCommit and PostCommit passed for the evidence commit.

The JSON files retain full inputs or a hash-bound component-library reference, generated text, period rows and omission traces.
Validation tools run from the repository checkout at the evidence commit; historical input dependencies are repository-relative.
No Web, infographic, PDF, raster or other Product artifacts were regenerated.
Owner human review PENDING; Product Content NO_GO; branch runtime NO_GO. Production runtime was not inspected or changed.
PR115 must remain Open + Draft, unmerged and undeployed.
'''
(stage / 'OWNER_REVIEW.md').write_text(guide, encoding='utf-8')
sha = lambda data: hashlib.sha256(data).hexdigest().upper()
entries = [{'path': p.relative_to(stage).as_posix(), 'bytes': p.stat().st_size, 'sha256': sha(p.read_bytes())} for p in sorted(stage.rglob('*')) if p.is_file()]
manifest = {'version': 1, 'evidenceCommit': head, 'status': 'CONTENT_FOUNDATION_NO_GO', 'files': entries}
(stage / 'MANIFEST.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
sums = [f'{sha(p.read_bytes())}  {p.relative_to(stage).as_posix()}' for p in sorted(stage.rglob('*')) if p.is_file()]
(stage / 'SHA256SUMS.txt').write_text('\n'.join(sums) + '\n', encoding='utf-8')
with zipfile.ZipFile(archive, 'x', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for p in sorted(stage.rglob('*')):
        if p.is_file():
            z.write(p, p.relative_to(stage).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None, 'CRC mismatch'
    assert len(z.namelist()) == len(set(z.namelist())), 'duplicate ZIP entry'
    for n in z.namelist():
        p = PurePosixPath(n)
        assert not p.is_absolute() and '..' not in p.parts and ':' not in n and '\\' not in n, 'unsafe path'
    z.extractall(extracted)
actual = {p.relative_to(extracted).as_posix() for p in extracted.rglob('*') if p.is_file()}
expected = {e['path'] for e in entries} | {'MANIFEST.json', 'SHA256SUMS.txt'}
assert actual == expected, 'manifest missing/extra'
for e in entries:
    data = (extracted / e['path']).read_bytes()
    assert len(data) == e['bytes'] and sha(data) == e['sha256'], e['path']
for line in (extracted / 'SHA256SUMS.txt').read_text(encoding='utf-8').splitlines():
    h, p = line.split('  ', 1)
    assert sha((extracted / p).read_bytes()) == h, p
secrets = re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|AIza[\w-]{30,}|gh[pousr]_[A-Za-z0-9]{30,}')
absolute = re.compile(r'(?<![\w])[A-Za-z]:[\\/](?:Users|home|tmp)[\\/]|/Users/[^\s]+|/home/[^\s]+')
for rel in actual:
    text = (extracted / rel).read_text(encoding='utf-8-sig')
    assert not secrets.search(text), f'secret {rel}'
    assert not absolute.search(text), f'absolute local path {rel}'
result = {'zip': str(archive), 'sha256': sha(archive.read_bytes()), 'manifestEntries': len(entries), 'extractedFiles': len(actual), 'crcErrors': 0, 'extractionErrors': 0, 'missing': 0, 'extra': 0, 'hashErrors': 0, 'sizeErrors': 0, 'secretErrors': 0, 'absolutePathErrors': 0, 'secretScanScope': 'private keys, Firebase API key pattern, GitHub token patterns; not proof against all possible secrets'}
(parent / (name + '_VALIDATION.json')).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
print(json.dumps(result))
