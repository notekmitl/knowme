"""Compare the r6 and r6.1 outputs of trial_readability_snapshot_test.dart."""

import hashlib
import json
from pathlib import Path

from review_templates import QA, read, write


OUT = Path(__file__).parent
BASE, NEW = (read(QA / f'{revision}-assembled.json') for revision in ['r6', 'r6-1'])
OWNER = read(QA / 'r6-1-owner.json')
ORIGINAL_OWNER = read(QA / 'r6-owner-assembled.json')
assert BASE['asOf'] == NEW['asOf']


def quote(text):
    return '\n\n'.join(f'> {part.strip()}' for part in text.split('\n\n') if part.strip()) + '\n\n'


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, ensure_ascii=False).encode()).hexdigest()


def count_paragraphs(document):
    return sum(len(s['paragraphs']) for s in document['sections'])


parity = {'baseline': BASE['revision'], 'revision': NEW['revision'], 'as_of': NEW['asOf'], 'cases': {}}
browser = {}
for case in ['a', 'b', 'unknown']:
    left, right = BASE[case], NEW[case]
    fields = [field for field in ['thaiBefore', 'heroBefore', 'chineseBefore', 'selectedFacts', 'gaps', 'conflicts'] if field in right]
    assert all(left[field] == right[field] for field in fields), case
    western = ['id', 'basis', 'before']
    overall = ['title', 'before', 'thaiEvidence', 'chineseEvidence', 'westernBasis']
    for section, keys in [('western', western), ('overall', overall)]:
        for a, b in zip(left.get(section, []), right.get(section, []), strict=True):
            assert all(a[k] == b[k] for k in keys), (case, section)
    for a, b in zip(left.get('dashboard', []), right.get('dashboard', []), strict=True):
        assert {k: v for k, v in a.items() if k != 'after'} == {k: v for k, v in b.items() if k != 'after'}
    parity['cases'][case] = {
        'matched_fields': fields,
        'western_and_overall_source_and_evidence_match': True,
        'dashboard_source_binding_matches': True,
        'facts_sha256': digest(right['selectedFacts']) if 'selectedFacts' in right else None,
        'before_print_paragraphs': count_paragraphs(left['thaiAfter']),
        'after_print_paragraphs': count_paragraphs(right['thaiAfter']),
    }
    browser[case] = [{'title': s['displayTitle'], 'paragraphs': s['paragraphs']} for s in right.get('overall', [])]
assert BASE['incompleteChinese']['before'] == NEW['incompleteChinese']['before']
assert [s['source'] for s in ORIGINAL_OWNER] == [s['source'] for s in OWNER]
parity.update(incomplete_chinese_raw_match=True, owner_legacy_raw_match=True)
write(OUT / 'evidence-parity.json', parity)
write(OUT / 'overall-readings.json', browser)


def chinese(sections):
    blocks = []
    for section in sections:
        blocks.append(f"#### {section['title']}\n\n")
        blocks.extend(quote(p) for p in [section['intro'], *section['paragraphs']] if p)
        blocks.extend(quote(r['label'] + ' · ' + r['value']) for r in section['rows'])
        blocks.extend(quote(p) for p in section['notes'])
    return blocks


full = ['# คำอ่านที่ประกอบจริง r6.1\n\nใช้ข้อมูลทดสอบและวันอ้างอิงเดิม\n\n']
for case in ['a', 'b', 'unknown']:
    result = NEW[case]
    full.append(f'## {case}\n\n')
    if 'overall' in result:
        full.append('### ดวงรวม\n\n')
        for topic in browser[case]:
            full.append(f"#### {topic['title']}\n\n")
            full.extend(quote(p) for p in topic['paragraphs'])
    full.append('### ไทย\n\n')
    full.extend(quote(p) for p in result['heroAfter'].values())
    full.extend(quote(t['title'] + ' · ' + t['after']) for t in result['dashboard'])
    for section in result['thaiAfter']['sections']:
        full.append(f"#### {section['title']}\n\n")
        full.extend(quote(p) for p in section['paragraphs'])
    if 'chineseAfter' in result:
        full.append('### จีน\n\n')
        full.extend(chinese(result['chineseAfter']))
    if 'western' in result:
        full.append('### ตะวันตก\n\n')
        full.append(quote(result['westernOverview']['after']))
        for section in result['western']:
            full.append(f"#### {section['id']}\n\n")
            full.extend([quote(section['after']), quote(section['basis'])])
full.append('## จีน · ข้อมูลไม่ครบ\n\n')
full.extend(chinese(NEW['incompleteChinese']['after']))
full.append('## ดวงรวม · owner-wording\n\n')
for topic in OWNER:
    full.append(f"### {topic['title']}\n\n")
    full.extend(quote(p) for p in topic['paragraphs'])
for fixture in ['v2-a', 'v2-b', 'v2-missing', 'lichunUnknown', 'jieUnknown']:
    report = next(c['projected'] for c in read(QA / 'r6-1-corpus.json')['chinese'] if c['case'] == fixture and c['year'] == 2026)
    full.append(f'## จีน · {fixture}\n\n')
    full.extend(chinese(report))
(OUT / 'FULL_READINGS.md').write_text(''.join(full).rstrip() + '\n', encoding='utf-8')


def western_work(snapshot):
    return next(section['after'] for section in snapshot['a']['western'] if section['id'] == 'work')


def chinese_fallback(snapshot, section, marker):
    rows = snapshot['incompleteChinese']['after'][section]['rows']
    row = next(row for row in rows if row['label'].startswith(marker))
    return row['label'] + ' · ' + row['value']


def thai_section(snapshot, field):
    return '\n\n'.join(next(s['paragraphs'] for s in snapshot['a']['thaiAfter']['sections'] if s['id'] == field))


pairs = [
    ('ตะวันตก A · การงาน', 'reader.py · _MERCURY_WORK[Aquarius], _MARS_WORK, _MODALITY_WORK, _work_house_effect',
     western_work(BASE), western_work(NEW), 'ทักษะดาวพุธ การแก้ปัญหา มาตรฐาน และหน้าที่เป็นคนละใจความ เงื่อนไขเรื่องสิทธิ์ตัดสินใจและข้อควรระวังยังอยู่'),
    ('จีน V1 · การเงินเมื่อกลุ่มเงินมี 2 ช่อง', 'bazi_symbolic_reading_engine.dart · _financeReading, _financePracticeTh[peer]',
     chinese_fallback(BASE, 1, 'การเงินและทรัพยากร'), chinese_fallback(NEW, 1, 'การเงินและสิ่งที่ใช้ทำงาน'),
     'เก็บจำนวนช่องและข้อเทียบกับกลุ่มที่นับได้มากที่สุด แยกการตรวจงบและหน้าที่ออกจากวิธีแยกเงินส่วนตัว เงินร่วม และสิทธิ์ตัดสินใจ'),
    ('จีน V1 · ความสัมพันธ์', 'bazi_symbolic_reading_engine.dart · _natalAreas, _relationshipCopyTh[peer]',
     chinese_fallback(BASE, 1, 'ความสัมพันธ์และการอยู่ร่วมกัน'), chinese_fallback(NEW, 1, 'ความสัมพันธ์และการอยู่ร่วมกัน'),
     'ยังให้สังเกตวิธีอยู่ด้วยกัน และยังระบุว่าใช้ทำนายคู่ครองหรือผลความสัมพันธ์ไม่ได้'),
    ('ไทย A · การเงินในรายงานและฉบับพิมพ์', 'ThaiBetaReportExportDocument · report-body-06 → TrialReportDocuments.thai',
     thai_section(BASE, 'report-body-06'), thai_section(NEW, 'report-body-06'),
     'ยังให้ดูทั้งเงินที่เก็บและทางเลือกที่เงินสำรองช่วยให้มีเพิ่ม'),
    ('ดวงรวม A · วิธีคิดเรื่องงาน', 'TrialOverallTopicCopy._workMethod → WesternNatalLifeSemantics',
     BASE['a']['overall'][0]['paragraphs'][2], NEW['a']['overall'][0]['paragraphs'][2],
     'ยังบอกทั้งการมองความเกี่ยวข้องของส่วนต่าง ๆ และการเสนอวิธีใหม่ อยู่คนละย่อหน้ากับข้อสังเกตไทย'),
]
comparison = ['# ก่อน–หลังและต้นทาง r6.1\n\n[คำอ่านเต็ม](FULL_READINGS.md) · [ผลเทียบข้อมูล](evidence-parity.json)\n\n']
for title, source, before, after, reason in pairs:
    assert before != after, title
    comparison.extend([f'## {title}\n\nต้นทาง `{source}`\n\n**r6**\n\n', quote(before), '**r6.1**\n\n', quote(after), reason + '\n\n'])
(OUT / 'READINGS.md').write_text(''.join(comparison).rstrip() + '\n', encoding='utf-8')
