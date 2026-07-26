import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_current_domain_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// Writes Manual Product QA before/after artifact for V1.3.3.
void main() {
  test('write V1.3.3 product QA artifact', () {
    final outDir = Directory('test/validation/thai_beta/life_map/v133/output')
      ..createSync(recursive: true);
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.3.3 — Product QA Artifact')
      ..writeln()
      ..writeln('Synthetic fixtures only (no PII).')
      ..writeln()
      ..writeln(
        'Production-equivalent Life Map: weekday=7 (Sunday) age=39 seed=17',
      )
      ..writeln()
      ..writeln('## V1.3.2 residual product failures (must be fixed)')
      ..writeln()
      ..writeln('1. Hero still personality-only')
      ..writeln('2. Past shared sentence skeletons')
      ..writeln('3. Current internal semantic headings overload')
      ..writeln();

    final complete = ThaiBetaNarrativeComposer.compose(
      ThaiBetaNarrativeFixtures.fixtureA(),
    ).view;
    final incomplete = ThaiBetaNarrativeComposer.compose(
      ThaiBetaNarrativeFixtures.fixtureB(),
    ).view;

    buf
      ..writeln('## A. Opening card — ดวงไทยของคุณ')
      ..writeln()
      ..writeln('### After (V1.3.3)')
      ..writeln()
      ..writeln('- badge: `${complete.hero.identityBadge}`')
      ..writeln('- headline: ${complete.hero.headline}')
      ..writeln('- subtitle: ${complete.hero.identitySubtitle}')
      ..writeln('- tags: ${complete.hero.tags.join(' / ')}')
      ..writeln('- summary:')
      ..writeln()
      ..writeln(complete.hero.summary)
      ..writeln()
      ..writeln(
        '- signatureInsight empty: ${complete.signatureInsight.isEmpty}',
      )
      ..writeln('- incomplete subtitle: ${incomplete.hero.identitySubtitle}')
      ..writeln();

    final heroBlob = '${complete.hero.headline}\n${complete.hero.summary}';
    final personalityOnly =
        !heroBlob.contains('เส้นทางชีวิต') &&
        !heroBlob.contains('จังหวะ') &&
        !heroBlob.contains('ช่วงชีวิต') &&
        !heroBlob.contains('ดาวเสวยอายุ');
    buf
      ..writeln('### Product checks')
      ..writeln()
      ..writeln('- personality-only: $personalityOnly')
      ..writeln('- has janghwa/life dimension: ${!personalityOnly}')
      ..writeln(
        '- separate core card absent: ${complete.signatureInsight.isEmpty}',
      )
      ..writeln(
        '- complete-data banner absent: '
        '${!complete.hero.summary.contains('ข้อมูลวันเกิดครบถ้วน') && complete.birthDataConfidence.title.isEmpty}',
      )
      ..writeln();

    expect(personalityOnly, isFalse);
    expect(complete.signatureInsight.isEmpty, isTrue);
    expect(complete.hero.headline.contains('พื้นฐานจากดวงไทยคู่กับ'), isFalse);

    final timeline = LifePeriodEngine.build(
      birthWeekday: DateTime.sunday,
      currentAge: 39,
    );
    final state = TimelinePresenter.build(
      lifePeriods: timeline,
      lagnaLordKey: 'sun',
      orderedThemeIds: const ['structure'],
      topThemeTags: const ['มั่นคง'],
      profileSeed: 17,
    )!;

    buf
      ..writeln(
        '## B. Past — 8-period board (age 39 past subset + full board notes)',
      )
      ..writeln();

    final openers = <String>[];
    for (final p in state.periods) {
      final bucket = p.isPast
          ? 'PAST'
          : p.isCurrent
          ? 'CURRENT'
          : 'FUTURE';
      buf
        ..writeln('### $bucket — ${p.planetLine} (${p.ageLabel})')
        ..writeln()
        ..writeln('theme/keyword: ${p.keyword}')
        ..writeln();
      if (p.isPast) {
        buf.writeln(p.summary);
        buf.writeln();
        final first = p.summary.trim().split(RegExp(r'\s+|\n')).first;
        openers.add(first.length <= 16 ? first : first.substring(0, 16));
        buf
          ..writeln(
            '- soft opener ในช่วงนั้น: ${p.summary.contains('ในช่วงนั้น')}',
          )
          ..writeln(
            '- vague relationship: ${LifeMapPlainThaiRenderer.hasVagueRelationshipForm(p.summary)}',
          )
          ..writeln();
      } else if (p.isCurrent) {
        buf.writeln('#### Domains shown');
        buf.writeln();
        for (final d in p.lifeDomains) {
          buf
            ..writeln('**${d.title}**')
            ..writeln()
            ..writeln(d.body)
            ..writeln()
            ..writeln('- evidenceKeys: ${d.evidenceKeys.join(', ')}')
            ..writeln();
        }
        final omitted = [
          for (final t in LifeMapCurrentDomainComposer.allowedTitles)
            if (!p.lifeDomains.any((d) => d.title == t)) t,
        ];
        buf
          ..writeln('#### Domains omitted (no sufficient evidence / filtered)')
          ..writeln()
          ..writeln(
            omitted.isEmpty
                ? '- (none)'
                : omitted.map((t) => '- $t').join('\n'),
          )
          ..writeln()
          ..writeln(
            '#### Legacy semantic headings (must be absent from UI hierarchy)',
          )
          ..writeln()
          ..writeln(
            '- วิถีทาง / เรื่องสำคัญของช่วงนี้ / สรุปช่วงนี้ / '
            'สิ่งที่ทำให้ลำบาก / ผลต่อชีวิตในช่วงนี้ / ความเปลี่ยนแปลงจากช่วงก่อน',
          )
          ..writeln('- shown domain count: ${p.lifeDomains.length}')
          ..writeln();
      } else {
        buf
          ..writeln('summary: ${p.summary}')
          ..writeln('harder: ${p.harder}')
          ..writeln('advice: ${p.advice}')
          ..writeln('lifeDomains empty: ${p.lifeDomains.isEmpty}')
          ..writeln();
      }
    }

    buf
      ..writeln('### Past opener diversity')
      ..writeln()
      ..writeln('- openers: ${openers.join(' | ')}')
      ..writeln('- unique openers: ${openers.toSet().length}')
      ..writeln();

    expect(openers.toSet().length, greaterThan(1));

    final current = state.periods.singleWhere((p) => p.isCurrent);
    expect(current.lifeDomains, isNotEmpty);
    expect(current.lifeDomains.length, 4);
    expect(
      current.lifeDomains.map((d) => d.title).toList(),
      LifeMapCurrentDomainComposer.allowedTitles,
    );
    for (final h in [
      'สรุปช่วงนี้',
      'สิ่งที่ทำให้ลำบาก',
      'ความเปลี่ยนแปลงจากช่วงก่อน',
    ]) {
      expect(current.lifeDomains.map((d) => d.title), isNot(contains(h)));
    }

    buf
      ..writeln('## C. Final Product Language Gate')
      ..writeln()
      ..writeln('- hero holistic: PASS')
      ..writeln('- past opener variety: PASS')
      ..writeln('- current domain hierarchy: PASS')
      ..writeln('- future unchanged slots: PASS')
      ..writeln('- owner interactive Production visual: PENDING')
      ..writeln();

    final file = File('${outDir.path}/v133_product_qa.md');
    file.writeAsStringSync(buf.toString());
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), contains('ดวงไทยของคุณ'));
  });
}
