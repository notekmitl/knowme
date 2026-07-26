import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// Writes Manual Product QA before/after artifact for V1.3.2.
void main() {
  test('write V1.3.2 product QA artifact', () {
    final outDir = Directory('test/validation/thai_beta/life_map/v132/output')
      ..createSync(recursive: true);
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.3.2 — Product QA Artifact')
      ..writeln()
      ..writeln('Synthetic fixtures only (no PII).')
      ..writeln()
      ..writeln('## V1.3.1 failure phrases (must be absent)')
      ..writeln()
      ..writeln('- separate card `แก่นที่พอเห็นได้จากข้อมูลที่มี`')
      ..writeln('- success banner `ข้อมูลวันเกิดครบถ้วน`')
      ..writeln('- Past soft opener `ในช่วงนั้น`')
      ..writeln('- Current `รูปแบบความรัก/ใกล้ชิดเปลี่ยน` / `ตั้งขอบเขตใหม่`')
      ..writeln();

    final complete = ThaiBetaNarrativeComposer.compose(
      ThaiBetaNarrativeFixtures.fixtureA(),
    ).view;
    final incomplete = ThaiBetaNarrativeComposer.compose(
      ThaiBetaNarrativeFixtures.fixtureB(),
    ).view;

    buf
      ..writeln('## Opening hierarchy')
      ..writeln()
      ..writeln('### Complete birth data')
      ..writeln()
      ..writeln('- hero badge: `${complete.hero.identityBadge}`')
      ..writeln('- hero headline: ${complete.hero.headline}')
      ..writeln('- hero subtitle: ${complete.hero.identitySubtitle}')
      ..writeln('- hero tags: ${complete.hero.tags.join(' / ')}')
      ..writeln('- hero summary:')
      ..writeln()
      ..writeln(complete.hero.summary)
      ..writeln()
      ..writeln(
        '- signatureInsight empty: ${complete.signatureInsight.isEmpty}',
      )
      ..writeln(
        '- birthDataConfidence complete/title: '
        '${complete.birthDataConfidence.isComplete}/'
        '`${complete.birthDataConfidence.title}`',
      )
      ..writeln()
      ..writeln('### Incomplete birth data')
      ..writeln()
      ..writeln('- hero subtitle: ${incomplete.hero.identitySubtitle}')
      ..writeln(
        '- birthDataConfidence complete/title: '
        '${incomplete.birthDataConfidence.isComplete}/'
        '`${incomplete.birthDataConfidence.title}`',
      )
      ..writeln();

    expect(complete.signatureInsight.isEmpty, isTrue);
    expect(complete.birthDataConfidence.title, isEmpty);
    expect(incomplete.hero.identitySubtitle, contains('ไม่มีเวลาเกิด'));

    buf.writeln('## Primary Life Map — weekday=7 age=39');
    buf.writeln();
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

    for (final p in state.periods) {
      final phase = p.isPast
          ? 'PAST'
          : p.isCurrent
          ? 'CURRENT'
          : 'FUTURE';
      final card = [
        p.summary,
        if (p.harder.trim().isNotEmpty) 'harder: ${p.harder}',
        if (p.advice.trim().isNotEmpty) 'advice: ${p.advice}',
      ].join('\n\n');
      final soft = LifeMapPlainThaiRenderer.hasPastSoftOpener(card);
      final vague = LifeMapPlainThaiRenderer.hasVagueRelationshipForm(card);
      buf
        ..writeln('### $phase — ${p.planetLine} (${p.ageLabel})')
        ..writeln()
        ..writeln(card)
        ..writeln()
        ..writeln('- soft opener: $soft')
        ..writeln('- vague relationship form: $vague')
        ..writeln(
          '- `ช่วงนั้น` count: '
          '${LifeMapPlainThaiRenderer.countMarker(card, 'ช่วงนั้น')}',
        )
        ..writeln();
      expect(soft, isFalse);
      expect(vague, isFalse);
      expect(card.contains('ในช่วงนั้น'), isFalse);
      expect(card.contains('รูปแบบความรักเปลี่ยน'), isFalse);
      expect(card.contains('ตั้งขอบเขตใหม่'), isFalse);
    }

    // Extra weekday × age samples for Product QA breadth.
    for (final weekday in [
      DateTime.sunday,
      DateTime.monday,
      DateTime.wednesday,
      DateTime.friday,
    ]) {
      for (final age in [12, 25, 39, 55]) {
        final sample = TimelinePresenter.build(
          lifePeriods: LifePeriodEngine.build(
            birthWeekday: weekday,
            currentAge: age,
          ),
          lagnaLordKey: 'sun',
          orderedThemeIds: const ['structure'],
          topThemeTags: const ['มั่นคง'],
          profileSeed: weekday + age,
        )!;
        buf
          ..writeln('## Sample weekday=$weekday age=$age')
          ..writeln();
        for (final p in sample.periods) {
          final phase = p.isPast
              ? 'PAST'
              : p.isCurrent
              ? 'CURRENT'
              : 'FUTURE';
          buf
            ..writeln('### $phase — ${p.planetLine}')
            ..writeln()
            ..writeln(p.summary)
            ..writeln();
          if (p.harder.trim().isNotEmpty) {
            buf.writeln('harder: ${p.harder}');
            buf.writeln();
          }
          if (p.advice.trim().isNotEmpty) {
            buf.writeln('advice: ${p.advice}');
            buf.writeln();
          }
          expect(p.summary.contains('ในช่วงนั้น'), isFalse);
          expect(
            LifeMapPlainThaiRenderer.hasVagueRelationshipForm(
              '${p.summary}\n${p.harder}\n${p.advice}',
            ),
            isFalse,
          );
        }
      }
    }

    final file = File('${outDir.path}/v132_product_qa.md');
    file.writeAsStringSync(buf.toString());
    expect(file.existsSync(), isTrue);
  });
}
