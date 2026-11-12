"""Generate and inspect real reader output offline from the repository root."""

import argparse
import json
import re
import runpy
from collections import Counter, defaultdict
from pathlib import Path


QA = Path('.preview-qa')
WESTERN = Path('backend/app/services/astrology/reader.py')
CASES = QA / 'r6-1-western-cases.json'
CATALOG = QA / 'r6-1-corpus.json'


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(content, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def seed(reader):
    signs = list(reader['SIGN_TH'])
    aspects = ['none', 'conjunction', 'trine', 'sextile', 'square', 'opposition']
    cases = []
    for sign_index, sign in enumerate(signs):
        for variant, aspect in enumerate(aspects):
            index = len(cases)
            house = [0, 1, 2, 6, 8, 10][variant]
            planet = [*reader['PLANET_TH'], 'unlisted'][index % 8]
            element = list(reader['ELEMENT_TH'])[index % 5]
            modality = list(reader['MODALITY_TH'])[(sign_index + variant) % 4]
            planets = {
                'mercury': {'sign': sign, 'house': house},
                'mars': {'sign': signs[(sign_index + 4) % 12]},
                'venus': {'sign': signs[(sign_index + 7) % 12]},
            }
            cases.append({
                'sign': sign, 'aspect': aspect, 'house': house,
                'element': element, 'modality': modality,
                'reader': reader['build_reader'](
                    {'sun': sign, 'moon': signs[(sign_index + 1) % 12],
                     'rising': signs[(sign_index + 2) % 12]},
                    planets,
                    {'elements': {'dominant': element}, 'modalities': {'dominant': modality},
                     'dominant_planets': [{'planet': planet}],
                     'major_aspects': [] if aspect == 'none' else [
                         {'planet1': 'moon', 'planet2': 'venus', 'aspect': aspect,
                          'orb': 1, 'exact_angle': 90},
                     ]},
                ),
            })
    write(CASES, cases)


def normalized(text):
    return ' '.join(text.split())


def pairs(corpus):
    for case in corpus['western']:
        yield 'western', 'overview', case['overviewRaw'], case['overview']
        for section in case['sections']:
            yield 'western', section['id'], section['body'], section['after']
    for lens in ['thai', 'chinese']:
        for case in corpus[lens]:
            for before, after in zip(case['raw'], case['projected'], strict=True):
                key = (before.get('id') or before['title']).split(' · ')[0]
                before_body = '\n\n'.join(before['paragraphs'])
                after_body = '\n\n'.join(after['paragraphs'])
                yield lens, key, before_body, after_body
                if lens == 'chinese':
                    for field in ['title', 'intro']:
                        if before[field]:
                            yield lens, f'{key}/{field}', before[field], after[field]
                    for left, right in zip(before['rows'], after['rows'], strict=True):
                        for field in ['label', 'value']:
                            yield lens, f'{key}/row-{field}', left[field], right[field]
                    for left, right in zip(before['notes'], after['notes'], strict=True):
                        yield lens, f'{key}/note', left, right


def review(reader, output):
    corpus = read(CATALOG)
    unique = defaultdict(set)
    for lens, key, before, after in pairs(corpus):
        if after.strip():
            unique[lens, key].add((before, after))

    groups = {
        '_SUN_OVERVIEW': ['overview'], '_MOON_OVERVIEW': ['overview', 'love'],
        '_RISING_OVERVIEW': ['overview'], '_SUN_CHOICE': ['identity'],
        '_MOON_DECISION': ['identity'], '_RISING_DECISION': ['identity'],
        '_MERCURY_WORK': ['work'], '_MARS_WORK': ['work'], '_MODALITY_WORK': ['work'],
        '_VENUS_MONEY': ['money'], '_VENUS_LOVE': ['love'],
        '_MOON_RECOVERY': ['wellbeing'], '_PLANET_ROLE': ['strengths'],
        '_ELEMENT_VOICE': ['strengths', 'cautions'],
    }
    western = []
    for group, sections in groups.items():
        fields = set().union(*(unique['western', s] for s in sections))
        for key, clauses in reader[group].items():
            parts = list(clauses.values()) if isinstance(clauses, dict) else (
                [clauses] if isinstance(clauses, str) else list(clauses)
            )
            for i, raw in enumerate(parts):
                # Overview drops this prefix before inserting the selected impression.
                match = raw.removeprefix('มีคนคิดว่าคุณ') if group == '_RISING_OVERVIEW' else raw
                seen = [(before, after) for before, after in fields if match in before]
                unchanged = sum(match in after for _, after in seen)
                western.append({
                    'source': f'{group}[{key}][{i}]', 'raw': raw,
                    'assembled': len(seen), 'verbatim_after_projection': unchanged,
                })

    # Diagnostic candidates only. Keeping an authored technical term and leaving
    # an ordinary sentence unchanged both require editorial review in TEMPLATES.md.
    words = re.compile(
        r'กำหนดกติกาตายตัว|จุดสังเกตเชิงโครงสร้าง|เจรจาพื้นที่|จุดตรวจเรื่องงบและภาระ|'
        r'รูปแบบปฏิสัมพันธ์|มองระบบ เห็นความเชื่อมโยง|ภาพรวมของ|ขอบเขต|ทรัพยากร|'
        r'แกนหลัก|ตั้งหลัก|ก้าวถัดไป|ต่อยอด|พลังชีวิต|([^\s]{4,})\s+\1'
    )
    inventory = []
    candidates = []
    for (lens, key), values in sorted(unique.items()):
        counts = Counter()
        for before, after in sorted(values):
            counts['verbatim' if normalized(before) == normalized(after) else 'changed'] += 1
            for paragraph in after.split('\n\n'):
                flagged = {match[0] for match in words.finditer(paragraph)}
                if flagged:
                    counts['flagged_paragraphs'] += 1
                    candidates.append({'lens': lens, 'field': key, 'terms': sorted(flagged),
                                       'before': before, 'after': paragraph.strip()})
        inventory.append({'lens': lens, 'field': key, **counts})
    write(output / 'template-counts.json', {'western_sources': western, 'assembled_fields': inventory})
    write(QA / 'r6-1-review-candidates.json', candidates)
    print(f'{len(western)} Western clauses, {len(inventory)} assembled fields, {len(candidates)} reading candidates')
    unseen = [row['source'] for row in western if not row['assembled']]
    if unseen:
        print('Unseen Western clauses:', ', '.join(unseen))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seed', action='store_true', help='prepare backend output for the Dart capture')
    parser.add_argument('--out', type=Path, default=QA)
    args = parser.parse_args()
    source = runpy.run_path(str(WESTERN))
    if args.seed:
        seed(source)
    else:
        review(source, args.out)
